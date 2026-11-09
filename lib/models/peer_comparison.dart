import '../core/utils/allocation_math.dart';

double? numOrNull(Object? v) => v is num ? v.toDouble() : null;

/// One company's row from ScreenerFundamentals for the peer table.
class PeerRow {
  final String symbol;
  final String name;
  final double? marketCapCr;
  final double? pe;
  final double? pb;
  final double? roce;
  final double? roe;
  final double? roa;
  final double? debtToEquity;
  final double? salesGrowth5Y;
  final double? profitGrowth5Y;

  const PeerRow({
    required this.symbol,
    required this.name,
    this.marketCapCr,
    this.pe,
    this.pb,
    this.roce,
    this.roe,
    this.roa,
    this.debtToEquity,
    this.salesGrowth5Y,
    this.profitGrowth5Y,
  });

  factory PeerRow.fromJson(Map<String, dynamic> j) => PeerRow(
        symbol: j['Instrument'].toString().toUpperCase(),
        name: (j['Company'] ?? j['Instrument']).toString(),
        marketCapCr: numOrNull(j['MarketCapCr']),
        pe: numOrNull(j['PE']),
        pb: numOrNull(j['PriceToBook']),
        roce: numOrNull(j['ROCE']),
        roe: numOrNull(j['ROE']),
        roa: numOrNull(j['ROA']),
        debtToEquity: numOrNull(j['DebtToEquity']),
        salesGrowth5Y: numOrNull(j['SalesGrowth5Y']),
        profitGrowth5Y: numOrNull(j['ProfitGrowth5Y']),
      );
}

/// A stock and the other companies in its industry, largest first.
class PeerData {
  static const defaultPeers = 3;

  final String industry;
  final PeerRow self;
  final List<PeerRow> others;
  const PeerData(this.industry, this.self, this.others);

  List<PeerRow> get largest => others.take(defaultPeers).toList();

  /// Null when the stock has no row or no peers. Partly-paid lines are the same company again.
  static PeerData? fromRows(String industry, String symbol, Iterable<Map<String, dynamic>> rows) {
    final all = rows
        .map(PeerRow.fromJson)
        .where((r) => !AllocationMath.isPartlyPaid(r.symbol))
        .toList();
    final sym = symbol.trim().toUpperCase();
    final self = all.where((r) => r.symbol == sym).firstOrNull;
    if (self == null) return null;
    final others = all.where((r) => r.symbol != sym && (r.marketCapCr ?? 0) > 0).toList()
      ..sort((a, b) => b.marketCapCr!.compareTo(a.marketCapCr!));
    if (others.isEmpty) return null;
    return PeerData(industry, self, others);
  }
}

/// Value for a table cell. [positiveOnly] is for ratios that mean nothing below zero (P/E of a loss-maker).
String peerCell(double? v, {int digits = 1, String suffix = '', bool positiveOnly = false}) {
  if (v == null || (positiveOnly && v <= 0)) return '—';
  return '${v.toStringAsFixed(digits)}$suffix';
}
