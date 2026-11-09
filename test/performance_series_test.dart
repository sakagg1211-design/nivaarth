import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/performance_series.dart';

final _start = DateTime(2025, 10, 9);

Map<String, dynamic> row(int day, num p, num n, {int stocks = 1, int held = 1}) => {
      'trade_date': _start.add(Duration(days: day)).toIso8601String().substring(0, 10),
      'portfolio_index': p,
      'nifty_index': n,
      'stocks_priced': stocks,
      'stocks_held': held,
    };

PerformanceSeries daily(int n, double Function(int) p) =>
    PerformanceSeries.fromRows([for (var i = 0; i < n; i++) row(i, p(i), 100)]);

void main() {
  test('slice starts at 0 and gives percent from its own first point', () {
    final s = PerformanceSeries.fromRows([row(0, 100, 100), row(1, 110, 105)]);
    final v = s.slice(PerformanceRange.all);
    expect(v.first.portfolio, 0);
    expect(v.last.portfolio, closeTo(10, 1e-9));
    expect(v.last.nifty, closeTo(5, 1e-9));
  });

  test('a shorter range rebases, it does not reuse the whole-period numbers', () {
    final s = daily(400, (i) => 100.0 + i);
    final v = s.slice(PerformanceRange.m1);
    expect(v.first.portfolio, 0);
    expect(v.last.date, s.points.last.date);
    expect(v.first.date.isBefore(s.points.last.date.subtract(const Duration(days: 32))), isFalse);
    final firstIndex = 100.0 + v.first.date.difference(_start).inDays;
    expect(v.last.portfolio, closeTo((499 / firstIndex - 1) * 100, 1e-9));
  });

  test('ranges the data does not reach are left out', () {
    expect(daily(45, (i) => 100.0).ranges, [PerformanceRange.m1, PerformanceRange.all]);
    expect(daily(400, (i) => 100.0).ranges, PerformanceRange.values);
  });

  test('all stays available on data shorter than a month', () {
    expect(daily(5, (i) => 100.0).ranges, [PerformanceRange.all]);
  });

  test('under 20 sessions is not enough', () {
    expect(daily(19, (i) => 100.0).hasEnough, isFalse);
    expect(daily(20, (i) => 100.0).hasEnough, isTrue);
  });

  test('partial when the earliest point had fewer stocks than are held', () {
    expect(PerformanceSeries.fromRows([row(0, 100, 100, stocks: 3, held: 5)]).partial, isTrue);
    expect(PerformanceSeries.fromRows([row(0, 100, 100, stocks: 5, held: 5)]).partial, isFalse);
  });

  test('numeric strings from the RPC are read', () {
    final s = PerformanceSeries.fromRows([
      {'trade_date': '2025-10-09', 'portfolio_index': '100.5', 'nifty_index': '100', 'stocks_priced': 1, 'stocks_held': 1},
    ]);
    expect(s.points.single.portfolio, 100.5);
  });

  test('days before any holding had data are dropped, not drawn as a flat line', () {
    final s = PerformanceSeries.fromRows([
      row(0, 100, 100, stocks: 0, held: 2),
      row(1, 100, 105, stocks: 0, held: 2),
      row(2, 100, 110, stocks: 1, held: 2),
      row(3, 120, 121, stocks: 1, held: 2),
    ]);
    expect(s.points.length, 2);
    expect(s.held, 2);
    expect(s.slice(PerformanceRange.all).last.portfolio, closeTo(20, 1e-9));
    expect(s.slice(PerformanceRange.all).last.nifty, closeTo(10, 1e-9));
  });

  test('a stock listed a few sessions ago does not pass the minimum', () {
    final rows = [for (var i = 0; i < 30; i++) row(i, 100, 100, stocks: i < 25 ? 0 : 1, held: 1)];
    expect(PerformanceSeries.fromRows(rows).hasEnough, isFalse);
  });

  test('no rows', () {
    final s = PerformanceSeries.fromRows(const []);
    expect(s.hasEnough, isFalse);
    expect(s.ranges, isEmpty);
    expect(s.partial, isFalse);
    expect(s.slice(PerformanceRange.all), isEmpty);
  });
}
