import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/import/zerodha_tradebook.dart';
import 'package:mobile/models/portfolio.dart';
import 'package:mobile/models/trade.dart';
import 'package:mobile/screens/dashboard/widgets/portfolio_hero_card.dart';
import 'package:mobile/screens/portfolio/closed_positions_page.dart';
import 'package:mobile/l10n/app_localizations.dart';

// Made-up tradebook in Zerodha Console's column layout (not real account data)
const csv = '''symbol,isin,trade_date,exchange,segment,series,trade_type,auction,quantity,price,trade_id,order_id,order_execution_time
KEI,INE878B01027,2026-01-05,NSE,EQ,EQ,buy,false,10.000000,4000.00,T1,O1,2026-01-05T10:00:00
KEI,INE878B01027,2026-02-05,NSE,EQ,EQ,buy,false,10.000000,4400.00,T2,O2,2026-02-05T10:00:00
KEI,INE878B01027,2026-03-05,NSE,EQ,EQ,sell,false,5.000000,5000.00,T3,O3,2026-03-05T10:00:00
"IRCTC",INE335Y01020,2026-10-30,BSE,EQ,A,buy,false,"21",439.20,T4,O4,2026-10-30T13:18:32
NIFTY26NOVFUT,,2026-10-30,NFO,FO,,buy,false,75,24000,T5,O5,2026-10-30T10:00:00
ZZZNEW,,2026-04-01,NSE,EQ,EQ,sell,false,5,100,T6,O6,2026-04-01T10:00:00
''';

Trade opening(String sym, double qty, double price) => Trade(
      id: 'open-$sym',
      instrument: sym,
      side: TradeSide.buy,
      qty: qty,
      price: price,
      tradeDate: DateTime(2026, 11, 3),
      source: 'OPENING',
    );

final en = lookupAppLocalizations(const Locale('en'));

void main() {
  final parsed = ZerodhaTradebook.parse(csv);

  test('equity rows are read, F&O rows skipped, quoted cells handled', () {
    expect(parsed.trades.length, 5);
    expect(parsed.skipped.single.reason, contains('FO'));
    final irctc = parsed.trades.firstWhere((t) => t.symbol == 'IRCTC');
    expect(irctc.qty, 21);
    expect(irctc.exchange, 'BSE');
    expect(irctc.date, DateTime(2026, 10, 30));
  });

  test('a file without the tradebook columns is refused', () {
    expect(() => ZerodhaTradebook.parse('a,b,c\n1,2,3'), throwsFormatException);
  });

  ImportPlan plan({Set<String> ids = const {}}) => ImportPlan.build(
        parsed,
        existingIds: ids,
        holdings: {
          // KEI held as an OPENING of 15 shares: the tradebook (10 + 10 - 5) is its whole history
          'KEI': CurrentHolding(qty: 15, trades: [opening('KEI', 15, 4200)]),
        },
        isListed: (_) => true,
      );

  test('tradebook equal to the holding rebuilds it from the tradebook', () {
    final kei = plan().stocks.firstWhere((s) => s.symbol == 'KEI');
    expect(kei.mode, ImportMode.replaceOpening);
    final r = kei.resultFor(ImportMode.replaceOpening)!;
    expect(r.qty, 15);
    expect(r.avgPrice, closeTo(4200, 1e-9)); // (40,000 + 44,000) / 20
    expect(r.realizedPl, closeTo(4000, 1e-9)); // 5 x (5,000 - 4,200)
    // Added on top the opening would count the same shares twice
    expect(kei.resultFor(ImportMode.addOnTop)!.qty, 30);
  });

  test('already imported trade ids are skipped', () {
    final kei = plan(ids: {'NSE:T1', 'NSE:T2'}).stocks.firstWhere((s) => s.symbol == 'KEI');
    expect(kei.newTrades.map((t) => t.tradeId), ['T3']);
    expect(kei.duplicates, 2);
  });

  test('trade ids carry the exchange (NSE and BSE numbers can repeat)', () {
    expect(parsed.trades.firstWhere((t) => t.symbol == 'IRCTC').key, 'BSE:T4');
  });

  test('a sell with no shares bought before it is not imported', () {
    final z = plan().stocks.firstWhere((s) => s.symbol == 'ZZZNEW');
    expect(z.errorFor(z.mode), contains('Itne shares nahi hain'));
  });

  test('closed positions: totals, last sell and percent on cost', () {
    final h = Portfolio.fromJson({
      'id': 'p1',
      'Instrument': 'POLYCAB',
      'Qty': 0,
      'Avg Price': 7590,
      'Total Invested': 0,
      'realized_pl': 3300,
      'Status': 'CLOSED',
    });
    final trades = [
      Trade(id: 'a', instrument: 'POLYCAB', side: TradeSide.buy, qty: 10, price: 7590, tradeDate: DateTime(2026, 11, 1)),
      Trade(id: 'b', instrument: 'POLYCAB', side: TradeSide.sell, qty: 10, price: 7920, tradeDate: DateTime(2026, 11, 3)),
    ];
    final p = ClosedPosition.build([h], trades).single;
    expect(p.bought, 75900);
    expect(p.sold, 79200);
    expect(p.lastSell, DateTime(2026, 11, 3));
    expect(p.realizedPercent, closeTo(4.35, 0.01));
  });

  test('quiet stocks: refreshed but no trade for 15 minutes, market open only', () {
    final f = DateTime.utc(2026, 11, 4, 6, 10);
    final stocks = [
      (symbol: 'GLOBALVECT', lastTrade: DateTime.utc(2026, 11, 4, 5, 41), fetchedAt: f),
      (symbol: 'TCS', lastTrade: DateTime.utc(2026, 11, 4, 6, 9), fetchedAt: f),
    ];
    expect(PortfolioHeroCard.quietStocks(stocks, isMarketOpen: true), ['GLOBALVECT']);
    // A feed 20 minutes late for every stock marks none of them
    final late = [
      (symbol: 'A', lastTrade: DateTime.utc(2026, 11, 4, 5, 50), fetchedAt: f),
      (symbol: 'B', lastTrade: DateTime.utc(2026, 11, 4, 5, 49), fetchedAt: f),
    ];
    expect(PortfolioHeroCard.quietStocks(late, isMarketOpen: true), isEmpty);
    expect(PortfolioHeroCard.quietStocks(stocks, isMarketOpen: false), isEmpty);
    expect(PortfolioHeroCard.quietNote(['A', 'B', 'C', 'D'], en), contains('(A, B, C +1)'));
    expect(PortfolioHeroCard.quietNote(const [], en), isNull);
  });
}
