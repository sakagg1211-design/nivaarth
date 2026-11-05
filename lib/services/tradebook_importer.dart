import 'dart:convert';
import 'dart:typed_data';

import '../core/import/xlsx_rows.dart';
import '../core/import/zerodha_tradebook.dart';
import '../models/portfolio.dart';
import '../models/trade.dart';
import '../repositories/portfolio_repository.dart';
import '../repositories/trade_repository.dart';

class ImportResult {
  final int imported;
  final List<String> doneStocks;
  final Map<String, String> failedStocks;
  const ImportResult(this.imported, this.doneStocks, this.failedStocks);
}

/// Zerodha tradebook -> Trades. Each stock goes in on its own: its new trades in time order
/// through add_trade (source IMPORT, so a second import skips them by trade id), then, when the
/// tradebook rebuilds the holding, the OPENING trade is removed. If any step fails, that stock's
/// imported trades are deleted again and the holding stays as it was.
class TradebookImporter {
  static const broker = 'Zerodha';

  final TradeRepository trades;
  final PortfolioRepository portfolio;

  TradebookImporter({TradeRepository? trades, PortfolioRepository? portfolio})
      : trades = trades ?? TradeRepository(),
        portfolio = portfolio ?? PortfolioRepository();

  /// A Console tradebook file: Excel (.xlsx) or CSV
  Future<ImportPlan> prepareFile(String fileName, Uint8List bytes) {
    final parsed = fileName.toLowerCase().endsWith('.xlsx')
        ? ZerodhaTradebook.parseTable(xlsxRows(bytes))
        : ZerodhaTradebook.parse(utf8.decode(bytes, allowMalformed: true));
    return preparePlan(parsed);
  }

  Future<ImportPlan> prepare(String csvText) => preparePlan(ZerodhaTradebook.parse(csvText));

  Future<ImportPlan> preparePlan(ParsedTradebook parsed) async {
    final symbols = parsed.trades.map((t) => t.symbol).toSet();
    final results = await Future.wait([
      trades.importedTradeIds(broker),
      portfolio.listedAmong(symbols),
      trades.getAllTrades(),
      portfolio.getPortfolio(),
      portfolio.getClosedPositions(),
    ]);
    final ids = results[0] as Set<String>;
    final listed = results[1] as Set<String>;
    final all = results[2] as List<Trade>;
    final rows = [...results[3] as List<Portfolio>, ...results[4] as List<Portfolio>];
    final holdings = <String, CurrentHolding>{
      for (final h in rows)
        h.instrument.toUpperCase(): CurrentHolding(
          qty: h.qty.toDouble(),
          trades: all.where((t) => t.instrument.toUpperCase() == h.instrument.toUpperCase()).toList(),
        ),
    };
    return ImportPlan.build(parsed, existingIds: ids, holdings: holdings, isListed: listed.contains);
  }

  /// Stocks that will be written: listed, with new trades, and no oversell in their mode
  static List<StockImport> writable(ImportPlan plan) => plan.stocks
      .where((s) => s.listed && s.newTrades.isNotEmpty && s.errorFor(s.mode) == null)
      .toList();

  Future<ImportResult> run(ImportPlan plan, {void Function(int done, int total)? onProgress}) async {
    final stocks = writable(plan);
    var imported = 0;
    final done = <String>[];
    final failed = <String, String>{};
    for (var i = 0; i < stocks.length; i++) {
      final s = stocks[i];
      final ordered = [...s.newTrades]..sort((a, b) {
          final d = a.date.compareTo(b.date);
          if (d != 0) return d;
          final ea = a.executedAt, eb = b.executedAt;
          if (ea != null && eb != null && ea != eb) return ea.compareTo(eb);
          return a.side == b.side ? 0 : (a.side == TradeSide.buy ? -1 : 1);
        });
      final inserted = <String>[];
      try {
        for (final t in ordered) {
          inserted.add(await trades.importTrade(
            instrument: s.symbol,
            side: t.side,
            qty: t.qty,
            price: t.price,
            tradeDate: t.date,
            broker: broker,
            externalTradeId: t.key,
          ));
        }
        final opening = s.current?.opening;
        if (s.mode == ImportMode.replaceOpening && opening != null) {
          await trades.deleteTrade(opening.id);
        }
        imported += inserted.length;
        done.add(s.symbol);
      } catch (e) {
        for (final id in inserted.reversed) {
          try {
            await trades.deleteTrade(id);
          } catch (_) {}
        }
        failed[s.symbol] = TradeRepository.message(e);
      }
      onProgress?.call(i + 1, stocks.length);
    }
    return ImportResult(imported, done, failed);
  }
}
