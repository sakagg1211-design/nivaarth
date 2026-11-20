import 'market_hours.dart';

const indexOrder = ['NIFTY 50', 'SENSEX', 'NIFTY BANK', 'NIFTY IT'];

class IndexQuote {
  final String name;
  final double? value;
  final double? change;
  final double? pct;
  final List<double> spark;
  final double? prevClose;
  const IndexQuote(this.name, {this.value, this.change, this.pct, this.spark = const [], this.prevClose});
}

class Mover {
  final String symbol;
  final double pct;
  final double price;
  const Mover(this.symbol, this.pct, this.price);
}

class MarketPulse {
  final List<IndexQuote> indices;
  final List<Mover> gainers;
  final List<Mover> losers;
  final int? advances;
  final int? declines;
  final List<(String, double)> leaders;
  final bool live;
  final DateTime? asOf;
  const MarketPulse({
    required this.indices,
    required this.gainers,
    required this.losers,
    this.advances,
    this.declines,
    this.leaders = const [],
    required this.live,
    this.asOf,
  });
}

double? _d(Object? v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));

DateTime _ist(DateTime utc) => utc.toUtc().add(const Duration(hours: 5, minutes: 30));
DateTime _istDay(DateTime utc) {
  final i = _ist(utc);
  return DateTime(i.year, i.month, i.day);
}

/// Index cards, Nifty 50 movers and market mood from LatestPrices, IntradayPrices and MarketBreadth.
/// Movers count only members priced in the latest session, so a suspended stock is not "unchanged".
MarketPulse buildMarketPulse({
  required List<Map<String, dynamic>> latest,
  required Set<String> nifty50,
  required List<Map<String, dynamic>> intraday,
  required Map<String, String> sectors,
  required DateTime now,
  Map<String, dynamic>? breadthRow,
}) {
  final byName = {for (final r in latest) r['Instrument'].toString(): r};

  final sparks = <String, List<(DateTime, double)>>{};
  for (final r in intraday) {
    final p = _d(r['price']);
    if (p == null) continue;
    (sparks[r['Instrument'].toString()] ??= []).add((DateTime.parse(r['ts'].toString()), p));
  }

  final indices = [
    for (final name in indexOrder)
      () {
        final r = byName[name];
        final cur = _d(r?['CurrentPrice']), prev = _d(r?['PreviousClose']);
        final ok = cur != null && cur > 0 && prev != null && prev > 0;
        final s = [...?sparks[name]]..sort((a, b) => a.$1.compareTo(b.$1));
        return IndexQuote(
          name,
          value: cur != null && cur > 0 ? cur : null,
          change: ok ? cur - prev : null,
          pct: ok ? (cur / prev - 1) * 100 : null,
          spark: [for (final x in s) x.$2],
          prevClose: prev != null && prev > 0 ? prev : null,
        );
      }(),
  ];

  final memberRows = [for (final m in nifty50) if (byName[m] != null) byName[m]!];
  DateTime? updated(Map<String, dynamic> r) => r['LastUpdated'] == null ? null : DateTime.tryParse(r['LastUpdated'].toString());
  final days = [for (final r in memberRows) if (updated(r) != null) _istDay(updated(r)!)];
  final session = days.isEmpty ? null : days.reduce((a, b) => a.isAfter(b) ? a : b);

  final movers = <Mover>[];
  for (final r in memberRows) {
    final u = updated(r);
    final cur = _d(r['CurrentPrice']), prev = _d(r['PreviousClose']);
    if (u == null || _istDay(u) != session || cur == null || cur <= 0 || prev == null || prev <= 0) continue;
    movers.add(Mover(r['Instrument'].toString(), (cur / prev - 1) * 100, cur));
  }
  final gainers = movers.where((m) => m.pct > 0).toList()..sort((a, b) => b.pct.compareTo(a.pct));
  final losers = movers.where((m) => m.pct < 0).toList()..sort((a, b) => a.pct.compareTo(b.pct));

  final live = isMarketOpenIst(now) &&
      memberRows.any((r) => updated(r) != null && now.toUtc().difference(updated(r)!.toUtc()).inMinutes.abs() <= 15);

  if (live) {
    final bySector = <String, List<double>>{};
    for (final m in movers) {
      final s = sectors[m.symbol];
      if (s == null || s == 'Others' || s == 'ETF') continue;
      (bySector[s] ??= []).add(m.pct);
    }
    final leaders = [for (final e in bySector.entries) (e.key, e.value.reduce((a, b) => a + b) / e.value.length)]
      ..sort((a, b) => b.$2.compareTo(a.$2));
    return MarketPulse(
      indices: indices,
      gainers: gainers.take(5).toList(),
      losers: losers.take(5).toList(),
      advances: movers.where((m) => m.pct > 0).length,
      declines: movers.where((m) => m.pct < 0).length,
      leaders: leaders.take(3).toList(),
      live: true,
      asOf: now,
    );
  }
  return MarketPulse(
    indices: indices,
    gainers: gainers.take(5).toList(),
    losers: losers.take(5).toList(),
    advances: breadthRow == null ? null : (breadthRow['advances'] as num?)?.toInt(),
    declines: breadthRow == null ? null : (breadthRow['declines'] as num?)?.toInt(),
    live: false,
    asOf: breadthRow?['trade_date'] == null ? session : DateTime.tryParse(breadthRow!['trade_date'].toString()),
  );
}
