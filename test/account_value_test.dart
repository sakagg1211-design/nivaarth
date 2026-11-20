import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/account_value.dart';

Map<String, dynamic> row(String d, num v, num inv, {bool assumed = false, int priced = 1}) =>
    {'trade_date': d, 'value': v, 'invested': inv, 'assumed': assumed, 'stocks_priced': priced, 'stocks_held': 1};

Map<String, dynamic> px(String sym, String ts, num p) => {'Instrument': sym, 'ts': ts, 'price': p};

void main() {
  group('history', () {
    test('fromRows reads numeric strings and keeps the assumed flag', () {
      final h = AccountHistory.fromRows([
        {'trade_date': '2026-01-05', 'value': '120.5', 'invested': '100', 'assumed': true, 'stocks_priced': 1, 'stocks_held': 1},
        row('2026-01-06', 121, 100),
      ]);
      expect(h.points.first.value, 120.5);
      expect(h.points.first.assumed, isTrue);
      expect(h.points.last.assumed, isFalse);
      expect(h.hasAssumed, isTrue);
    });

    test('leading days with nothing priced are dropped', () {
      final h = AccountHistory.fromRows([row('2026-01-05', 0, 0, priced: 0), row('2026-01-06', 50, 40)]);
      expect(h.points.length, 1);
    });

    test('slice m1 starts on or after one calendar month back', () {
      final rows = [for (var i = 0; i < 90; i++) row(DateTime(2026, 1, 1).add(Duration(days: i)).toIso8601String().substring(0, 10), 100 + i, 100)];
      final s = AccountHistory.fromRows(rows).slice(ValueRange.m1);
      final last = DateTime(2026, 1, 1).add(const Duration(days: 89));
      expect(s.last.time, last);
      // 31 March back one calendar month is 28 February, not DateTime's overflow to 3 March
      expect(s.first.time, DateTime(2026, 2, 28));
    });

    test('ranges leaves out a range the data does not reach, d1 always there', () {
      final rows = [for (var i = 0; i < 45; i++) row(DateTime(2026, 1, 1).add(Duration(days: i)).toIso8601String().substring(0, 10), 100, 100)];
      expect(AccountHistory.fromRows(rows).ranges, [ValueRange.d1, ValueRange.m1]);
    });

    test('a full year of data reaches 1Y even if it starts a few days after the cut', () {
      final rows = [for (var i = 3; i <= 365; i++) row(DateTime(2025, 11, 19).add(Duration(days: i)).toIso8601String().substring(0, 10), 100, 100)];
      expect(AccountHistory.fromRows(rows).ranges, contains(ValueRange.y1));
    });
  });

  group('intraday', () {
    test('UTC stamps from the database become local times', () {
      final l = intradayLine(qty: {'A': 1}, rows: [px('A', '2026-11-19T03:50:00+00:00', 10)]);
      expect(l.single.time.isUtc, isFalse);
      expect(l.single.time, DateTime.utc(2026, 11, 19, 3, 50).toLocal());
      final h = lastHour(qty: {'A': 1}, rows: [px('A', '2026-11-19T03:50:00+00:00', 10), px('A', '2026-11-19T04:50:00+00:00', 11)]);
      expect(h!.from.isUtc, isFalse);
    });

    test('today starts at midnight IST, given as a UTC instant', () {
      expect(istDayStartUtc(DateTime.utc(2026, 11, 19, 20)), DateTime.utc(2026, 11, 19, 18, 30));
      expect(istDayStartUtc(DateTime.utc(2026, 11, 19, 17)), DateTime.utc(2026, 11, 18, 18, 30));
    });

    test('pages are read until a short page', () async {
      final asked = <List<int>>[];
      final all = await fetchAllPages<int>((from, to) async {
        asked.add([from, to]);
        return List.generate(from < 4 ? 2 : 1, (i) => from + i);
      }, size: 2);
      expect(all, [0, 1, 2, 3, 4]);
      expect(asked, [[0, 1], [2, 3], [4, 5]]);
    });

    test('sums quantity times price per time', () {
      final l = intradayLine(qty: {'A': 2, 'B': 1}, rows: [
        px('A', '2026-11-19T09:20:00+05:30', 10), px('B', '2026-11-19T09:20:00+05:30', 5),
        px('A', '2026-11-19T09:25:00+05:30', 11), px('B', '2026-11-19T09:25:00+05:30', 5),
      ]);
      expect(l.map((p) => p.value), [25, 27]);
    });

    test('carries a missing price forward, not zero', () {
      final l = intradayLine(qty: {'A': 2, 'B': 1}, rows: [
        px('A', '2026-11-19T09:20:00+05:30', 10), px('B', '2026-11-19T09:20:00+05:30', 5),
        px('A', '2026-11-19T09:25:00+05:30', 12),
      ]);
      expect(l.last.value, 29);
    });

    test('times before every holding has a price are dropped', () {
      final l = intradayLine(qty: {'A': 2, 'B': 1}, rows: [
        px('A', '2026-11-19T09:15:00+05:30', 10),
        px('A', '2026-11-19T09:20:00+05:30', 10), px('B', '2026-11-19T09:20:00+05:30', 5),
      ]);
      expect(l.length, 1);
      expect(l.single.value, 25);
    });

    test('symbols not held are ignored', () {
      final l = intradayLine(qty: {'A': 1}, rows: [px('A', '2026-11-19T09:20:00+05:30', 10), px('NIFTY 50', '2026-11-19T09:20:00+05:30', 25000)]);
      expect(l.single.value, 10);
    });

    test('no rows is empty', () {
      expect(intradayLine(qty: {'A': 1}, rows: const []), isEmpty);
    });
  });

  group('last hour', () {
    String ts(int h, int m) => DateTime(2026, 11, 19, h, m).toIso8601String();
    final rows = [
      px('A', ts(10, 0), 100), px('B', ts(10, 0), 50),
      px('A', ts(10, 30), 101), px('B', ts(10, 30), 50),
      px('A', ts(11, 5), 104), px('B', ts(11, 5), 49),
    ];

    test('change since about an hour ago, and who moved it most', () {
      final h = lastHour(qty: {'A': 10, 'B': 10}, rows: rows)!;
      expect(h.from, DateTime(2026, 11, 19, 10, 0));
      // 1500 -> 1530
      expect(h.pct, closeTo(2, 1e-9));
      expect(h.mover, 'A');
    });

    test('null when the line is shorter than an hour', () {
      expect(lastHour(qty: {'A': 10}, rows: [px('A', ts(10, 0), 100), px('A', ts(10, 40), 101)]), isNull);
    });

    test('null with no rows', () {
      expect(lastHour(qty: {'A': 10}, rows: const []), isNull);
    });
  });
}
