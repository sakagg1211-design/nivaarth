import 'dart:math' as math;

class PerformancePoint {
  final DateTime date;
  final double portfolio;
  final double nifty;
  final int stocks;
  const PerformancePoint(this.date, this.portfolio, this.nifty, this.stocks);
}

enum PerformanceRange {
  m1('1M', 1),
  m3('3M', 3),
  m6('6M', 6),
  y1('1Y', 12),
  all('All', 0);

  final String label;
  final int months;
  const PerformanceRange(this.label, this.months);
}

/// Indexed daily series of today's holdings against Nifty, as returned by portfolio_performance().
class PerformanceSeries {
  final List<PerformancePoint> points;
  final int held;
  const PerformanceSeries(this.points, this.held);

  static const minSessions = 20;

  factory PerformanceSeries.fromRows(List<Map<String, dynamic>> rows) {
    double n(Object? v) => v is num ? v.toDouble() : double.parse(v.toString());
    return PerformanceSeries(
      [
        // Days before any holding had data say nothing about the portfolio
        for (final r in rows.skipWhile((r) => n(r['stocks_priced']) == 0))
          PerformancePoint(
            DateTime.parse(r['trade_date'].toString()),
            n(r['portfolio_index']),
            n(r['nifty_index']),
            n(r['stocks_priced']).toInt(),
          ),
      ],
      rows.isEmpty ? 0 : n(rows.first['stocks_held']).toInt(),
    );
  }

  bool get hasEnough => points.length >= minSessions;
  bool get partial => points.isNotEmpty && points.first.stocks < held;

  DateTime _cutoff(PerformanceRange range) {
    final last = points.last.date;
    final month = DateTime(last.year, last.month - range.months, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0).day;
    return DateTime(month.year, month.month, math.min(last.day, monthEnd));
  }

  List<PerformanceRange> get ranges {
    if (points.isEmpty) return const [];
    return [
      for (final r in PerformanceRange.values)
        if (r == PerformanceRange.all || !points.first.date.isAfter(_cutoff(r))) r,
    ];
  }

  /// Percent change of both lines from the first session of [range].
  List<PerformancePoint> slice(PerformanceRange range) {
    if (points.isEmpty) return const [];
    final inRange = range == PerformanceRange.all
        ? points
        : points.where((p) => !p.date.isBefore(_cutoff(range))).toList();
    final base = inRange.first;
    return [
      for (final p in inRange)
        PerformancePoint(p.date, (p.portfolio / base.portfolio - 1) * 100, (p.nifty / base.nifty - 1) * 100, p.stocks),
    ];
  }
}
