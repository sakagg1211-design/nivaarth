/// One point of the account value line. [assumed] marks days before the user's OPENING
/// holdings were entered, which the graph assumes were already held.
class ValuePoint {
  final DateTime time;
  final double value;
  final double invested;
  final bool assumed;
  const ValuePoint(this.time, this.value, this.invested, {this.assumed = false});
}

enum ValueRange {
  d1('1D', 0),
  m1('1M', 1),
  m6('6M', 6),
  y1('1Y', 12);

  final String label;
  final int months;
  const ValueRange(this.label, this.months);
}

double _n(Object? v) => v is num ? v.toDouble() : double.parse(v.toString());

/// Daily account value from account_value_history().
class AccountHistory {
  final List<ValuePoint> points;
  const AccountHistory(this.points);

  // The history covers 365 days ending at the last close, so it starts a few days after "a year ago".
  static const _slack = Duration(days: 7);

  factory AccountHistory.fromRows(List<Map<String, dynamic>> rows) => AccountHistory([
        for (final r in rows.skipWhile((r) => _n(r['stocks_priced']) == 0))
          ValuePoint(
            DateTime.parse(r['trade_date'].toString()),
            _n(r['value']),
            _n(r['invested']),
            assumed: r['assumed'] == true,
          ),
      ]);

  bool get hasAssumed => points.any((p) => p.assumed);

  DateTime _cutoff(ValueRange r) {
    final last = points.last.time;
    final month = DateTime(last.year, last.month - r.months, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0).day;
    return DateTime(month.year, month.month, last.day > monthEnd ? monthEnd : last.day);
  }

  List<ValueRange> get ranges => [
        ValueRange.d1,
        if (points.isNotEmpty)
          for (final r in ValueRange.values.skip(1))
            if (!points.first.time.isAfter(_cutoff(r).add(_slack))) r,
      ];

  /// Points of a daily range; 1D comes from [intradayLine] instead.
  List<ValuePoint> slice(ValueRange r) {
    if (points.isEmpty || r == ValueRange.d1) return const [];
    final cut = _cutoff(r);
    return points.where((p) => !p.time.isBefore(cut)).toList();
  }
}

/// Today's value per 5-minute stamp: held quantity times the latest price seen so far for each
/// holding. Stamps before every held symbol that appears in [rows] has a price are dropped.
List<ValuePoint> intradayLine({
  required Map<String, num> qty,
  required List<Map<String, dynamic>> rows,
  double invested = 0,
}) {
  final byTime = <DateTime, Map<String, double>>{};
  for (final r in rows) {
    final sym = r['Instrument'].toString();
    if (!qty.containsKey(sym)) continue;
    (byTime[DateTime.parse(r['ts'].toString()).toLocal()] ??= {})[sym] = _n(r['price']);
  }
  final present = {for (final m in byTime.values) ...m.keys};
  final last = <String, double>{};
  final out = <ValuePoint>[];
  for (final t in byTime.keys.toList()..sort()) {
    last.addAll(byTime[t]!);
    if (last.length < present.length) continue;
    out.add(ValuePoint(t, last.entries.fold(0.0, (a, e) => a + qty[e.key]! * e.value), invested));
  }
  return out;
}

/// Midnight IST of the IST day that [nowUtc] falls in, as a UTC instant.
DateTime istDayStartUtc(DateTime nowUtc) {
  const ist = Duration(hours: 5, minutes: 30);
  final d = nowUtc.toUtc().add(ist);
  return DateTime.utc(d.year, d.month, d.day).subtract(ist);
}

/// Reads [page] (inclusive row range) until a page comes back short: Supabase caps a read at 1,000 rows.
Future<List<T>> fetchAllPages<T>(Future<List<T>> Function(int from, int to) page, {int size = 1000}) async {
  final out = <T>[];
  for (var from = 0;; from += size) {
    final rows = await page(from, from + size - 1);
    out.addAll(rows);
    if (rows.length < size) return out;
  }
}

class HourChange {
  final DateTime from;
  final double pct;
  final String? mover;
  const HourChange(this.from, this.pct, this.mover);
}

/// Change of today's value from the last stamp at least an hour before the newest one, and the
/// holding whose price move added or took away the most in that time. Null under an hour of data.
HourChange? lastHour({required Map<String, num> qty, required List<Map<String, dynamic>> rows}) {
  final byTime = <DateTime, Map<String, double>>{};
  for (final r in rows) {
    final sym = r['Instrument'].toString();
    if (!qty.containsKey(sym)) continue;
    (byTime[DateTime.parse(r['ts'].toString()).toLocal()] ??= {})[sym] = _n(r['price']);
  }
  if (byTime.isEmpty) return null;
  final times = byTime.keys.toList()..sort();
  final present = {for (final m in byTime.values) ...m.keys};
  final snaps = <DateTime, Map<String, double>>{};
  final last = <String, double>{};
  for (final t in times) {
    last.addAll(byTime[t]!);
    if (last.length == present.length) snaps[t] = Map.of(last);
  }
  if (snaps.isEmpty) return null;
  final end = snaps.keys.last;
  final from = snaps.keys.where((t) => !t.isAfter(end.subtract(const Duration(hours: 1)))).lastOrNull;
  if (from == null) return null;
  double value(Map<String, double> p) => p.entries.fold(0.0, (a, e) => a + qty[e.key]! * e.value);
  final a = snaps[from]!, b = snaps[end]!;
  if (value(a) <= 0) return null;
  String? mover;
  var best = 0.0;
  for (final s in b.keys) {
    final move = (qty[s]! * (b[s]! - a[s]!)).abs();
    if (move > best) {
      best = move;
      mover = s;
    }
  }
  return HourChange(from, (value(b) / value(a) - 1) * 100, mover);
}
