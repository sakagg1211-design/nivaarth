import '../../models/trade.dart';
import '../utils/holding_math.dart';

/// One equity trade from a Zerodha Console tradebook CSV.
class ImportedTrade {
  final String symbol;
  final String isin;
  final DateTime date;
  final TradeSide side;
  final double qty;
  final double price;
  final String tradeId;
  final String exchange;
  final DateTime? executedAt;

  /// Id stored as Trades.external_trade_id. Exchange trade numbers are unique per exchange only,
  /// so the exchange is part of it.
  String get key => exchange.isEmpty ? tradeId : '$exchange:$tradeId';

  const ImportedTrade({
    required this.symbol,
    required this.isin,
    required this.date,
    required this.side,
    required this.qty,
    required this.price,
    required this.tradeId,
    required this.exchange,
    this.executedAt,
  });
}

class SkippedRow {
  final int line;
  final String reason;
  const SkippedRow(this.line, this.reason);
}

class ParsedTradebook {
  final List<ImportedTrade> trades;
  final List<SkippedRow> skipped;
  const ParsedTradebook(this.trades, this.skipped);
}

/// Zerodha Console > Reports > Tradebook (Equity) CSV:
/// symbol, isin, trade_date, exchange, segment, series, trade_type, auction, quantity, price,
/// trade_id, order_id, order_execution_time. Columns are found by name, so their order and
/// extra columns do not matter. F&O, currency and commodity rows are skipped.
class ZerodhaTradebook {
  const ZerodhaTradebook._();

  static const required = ['symbol', 'trade_date', 'trade_type', 'quantity', 'price', 'trade_id'];

  static ParsedTradebook parse(String text) {
    final lines = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
    return parseTable([for (final l in lines) splitCsvLine(l)]);
  }

  /// "Trade Date" (Excel export) and "trade_date" (CSV) are the same column
  static String header(String h) => h.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');

  /// yyyy-mm-dd (CSV, Excel date cells) or dd-mm-yyyy / dd/mm/yyyy (Excel text cells)
  static DateTime? date(String v) {
    final t = v.trim();
    final iso = DateTime.tryParse(t);
    if (iso != null) return iso;
    final m = RegExp(r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})').firstMatch(t);
    if (m == null) return null;
    return DateTime(int.parse(m.group(3)!), int.parse(m.group(2)!), int.parse(m.group(1)!));
  }

  /// Rows of a CSV file or an Excel sheet. Title rows above the header (Console's Excel export
  /// has some) are passed over.
  static ParsedTradebook parseTable(List<List<String>> table) {
    final trades = <ImportedTrade>[];
    final skipped = <SkippedRow>[];
    var headerAt = -1;
    late Map<String, int> col;
    for (var i = 0; i < table.length; i++) {
      final cells = table[i].map(header).toList();
      if (required.every(cells.contains)) {
        headerAt = i;
        col = {for (var j = 0; j < cells.length; j++) cells[j]: j};
        break;
      }
    }
    if (headerAt < 0) {
      throw const FormatException(
          'Ye Zerodha tradebook nahi lagti: symbol, trade_date, trade_type, quantity, price, trade_id columns nahi mile.');
    }
    String cell(List<String> row, String name) {
      final j = col[name];
      return j == null || j >= row.length ? '' : row[j].trim();
    }

    for (var i = headerAt + 1; i < table.length; i++) {
      final row = table[i];
      if (row.every((c) => c.trim().isEmpty)) continue;
      final line = i + 1;
      final segment = cell(row, 'segment').toUpperCase();
      if (segment.isNotEmpty && segment != 'EQ') {
        skipped.add(SkippedRow(line, 'Equity nahi ($segment)'));
        continue;
      }
      final symbol = cell(row, 'symbol').toUpperCase();
      final day = date(cell(row, 'trade_date'));
      final type = cell(row, 'trade_type').toLowerCase();
      final qty = double.tryParse(cell(row, 'quantity').replaceAll(',', ''));
      final price = double.tryParse(cell(row, 'price').replaceAll(',', ''));
      final tradeId = cell(row, 'trade_id');
      if (symbol.isEmpty || day == null || qty == null || qty <= 0 || price == null || price <= 0 ||
          tradeId.isEmpty || (type != 'buy' && type != 'sell')) {
        skipped.add(SkippedRow(line, 'Row padhi nahi ja saki'));
        continue;
      }
      trades.add(ImportedTrade(
        symbol: symbol,
        isin: cell(row, 'isin').toUpperCase(),
        date: DateTime(day.year, day.month, day.day),
        side: type == 'sell' ? TradeSide.sell : TradeSide.buy,
        qty: qty,
        price: price,
        tradeId: tradeId.endsWith('.0') ? tradeId.substring(0, tradeId.length - 2) : tradeId,
        exchange: cell(row, 'exchange').toUpperCase(),
        executedAt: DateTime.tryParse(cell(row, 'order_execution_time')),
      ));
    }
    return ParsedTradebook(trades, skipped);
  }

  /// Splits one CSV line; double quotes may wrap a cell and "" is a quote inside one.
  static List<String> splitCsvLine(String line) {
    final out = <String>[];
    final cur = StringBuffer();
    var quoted = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (quoted) {
        if (ch == '"') {
          if (i + 1 < line.length && line[i + 1] == '"') {
            cur.write('"');
            i++;
          } else {
            quoted = false;
          }
        } else {
          cur.write(ch);
        }
      } else if (ch == '"') {
        quoted = true;
      } else if (ch == ',') {
        out.add(cur.toString());
        cur.clear();
      } else {
        cur.write(ch);
      }
    }
    out.add(cur.toString());
    return out;
  }
}

/// How one stock's tradebook trades go in. [replaceOpening]: the OPENING trade (the holding as it
/// was before trades existed) is removed and the tradebook rebuilds the holding; otherwise the
/// new trades are added on top of it.
enum ImportMode { replaceOpening, addOnTop }

/// The current holding of a stock, for the import preview.
class CurrentHolding {
  final double qty;
  final List<Trade> trades;
  const CurrentHolding({required this.qty, required this.trades});

  Trade? get opening {
    for (final t in trades) {
      if (t.isOpening) return t;
    }
    return null;
  }
}

/// One stock in the import: the new trades (duplicates removed) and the result each way.
class StockImport {
  final String symbol;
  final List<ImportedTrade> newTrades;
  final int duplicates;
  final bool listed;
  final CurrentHolding? current;
  ImportMode mode;

  StockImport({
    required this.symbol,
    required this.newTrades,
    required this.duplicates,
    required this.listed,
    required this.current,
    required this.mode,
  });

  double get tradebookNetQty =>
      newTrades.fold(0.0, (s, t) => s + (t.side == TradeSide.buy ? t.qty : -t.qty));

  bool get hasOpening => current?.opening != null;

  /// Trades entered by hand for this stock: the same real trade may also be in the tradebook
  int get manualTrades => (current?.trades ?? const <Trade>[]).where((t) => t.source == 'MANUAL').length;

  /// Trades the holding would be rebuilt from in [m]
  List<Trade> tradesFor(ImportMode m) {
    final existing = current?.trades ?? const <Trade>[];
    final kept = m == ImportMode.replaceOpening ? existing.where((t) => !t.isOpening) : existing;
    return [
      ...kept,
      for (final t in newTrades)
        Trade(
          id: 'import-${t.tradeId}',
          instrument: symbol,
          side: t.side,
          qty: t.qty,
          price: t.price,
          tradeDate: t.date,
          brokerName: 'Zerodha',
          source: 'IMPORT',
          createdAt: t.executedAt,
        ),
    ];
  }

  /// The holding after the import in [m], or null with [error] set when a sell would exceed the
  /// shares held at that date (an incomplete tradebook, or a bonus/split it does not show)
  HoldingSummary? resultFor(ImportMode m) {
    try {
      return HoldingMath.summarize(tradesFor(m));
    } on OversellException {
      return null;
    }
  }

  String? errorFor(ImportMode m) {
    try {
      HoldingMath.summarize(tradesFor(m));
      return null;
    } on OversellException catch (e) {
      return e.toString();
    }
  }
}

class ImportPlan {
  final List<StockImport> stocks;
  final List<SkippedRow> skipped;
  const ImportPlan(this.stocks, this.skipped);

  int get newTradeCount => stocks.where((s) => s.listed).fold(0, (n, s) => n + s.newTrades.length);
  int get duplicateCount => stocks.fold(0, (n, s) => n + s.duplicates);
  List<StockImport> get unlisted => stocks.where((s) => !s.listed).toList();

  /// [existingIds]: Zerodha trade ids already imported. [holdings]: the user's stocks with their
  /// trades. [isListed]: whether a symbol is in Nivaarth's stock list.
  /// Default mode: rebuild from the tradebook when it holds the stock's whole history (its net
  /// quantity equals the current holding), else add the new trades on top.
  static ImportPlan build(
    ParsedTradebook parsed, {
    required Set<String> existingIds,
    required Map<String, CurrentHolding> holdings,
    required bool Function(String symbol) isListed,
  }) {
    final bySymbol = <String, List<ImportedTrade>>{};
    for (final t in parsed.trades) {
      bySymbol.putIfAbsent(t.symbol, () => []).add(t);
    }
    final stocks = <StockImport>[];
    for (final e in bySymbol.entries) {
      final fresh = e.value.where((t) => !existingIds.contains(t.key)).toList();
      final current = holdings[e.key];
      final s = StockImport(
        symbol: e.key,
        newTrades: fresh,
        duplicates: e.value.length - fresh.length,
        listed: isListed(e.key),
        current: current,
        mode: ImportMode.addOnTop,
      );
      if (s.hasOpening && (s.tradebookNetQty - current!.qty).abs() < 1e-9) {
        s.mode = ImportMode.replaceOpening;
      }
      stocks.add(s);
    }
    stocks.sort((a, b) => a.symbol.compareTo(b.symbol));
    return ImportPlan(stocks, parsed.skipped);
  }
}
