import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/market_pulse.dart';

// 19 Nov 2026, 11:00 IST = 05:30 UTC, a Thursday, market open
final openNow = DateTime.utc(2026, 11, 19, 5, 30);
final closedNow = DateTime.utc(2026, 11, 19, 13, 0);

Map<String, dynamic> lp(String sym, num cur, num prev, DateTime updatedUtc) =>
    {'Instrument': sym, 'CurrentPrice': cur, 'PreviousClose': prev, 'LastUpdated': updatedUtc.toIso8601String()};

void main() {
  final fresh = DateTime.utc(2026, 11, 19, 5, 25);
  final yesterday = DateTime.utc(2026, 11, 18, 10, 0);
  final members = {for (var i = 0; i < 8; i++) 'M$i'};
  List<Map<String, dynamic>> memberRows(DateTime at) => [for (var i = 0; i < 8; i++) lp('M$i', 100 + (i - 4) * 2, 100, at)];

  test('movers are Nifty 50 only and top 5 each way', () {
    final p = buildMarketPulse(
      latest: [...memberRows(fresh), lp('NOTMEMBER', 200, 100, fresh)],
      nifty50: members,
      intraday: const [],
      sectors: const {},
      now: openNow,
    );
    expect(p.gainers.map((m) => m.symbol), ['M7', 'M6', 'M5']);
    expect(p.losers.map((m) => m.symbol), ['M0', 'M1', 'M2', 'M3']);
    expect(p.gainers.first.pct, closeTo(6, 1e-9));
    expect(p.gainers.any((m) => m.symbol == 'NOTMEMBER'), isFalse);
    expect(p.gainers.length, lessThanOrEqualTo(5));
  });

  test('a member with an older row is left out', () {
    final p = buildMarketPulse(
      latest: [...memberRows(fresh).take(7), lp('M7', 130, 100, yesterday)],
      nifty50: members,
      intraday: const [],
      sectors: const {},
      now: openNow,
    );
    expect(p.gainers.any((m) => m.symbol == 'M7'), isFalse);
    expect(p.advances, 2); // M5, M6 up; M4 flat
    expect(p.declines, 4);
  });

  test('live mood names the leading sectors', () {
    final p = buildMarketPulse(
      latest: memberRows(fresh),
      nifty50: members,
      intraday: const [],
      sectors: {'M7': 'Tech', 'M6': 'Tech', 'M0': 'Bank', 'M5': 'Others'},
      now: openNow,
    );
    expect(p.live, isTrue);
    expect(p.leaders.first.$1, 'Tech');
    expect(p.leaders.any((l) => l.$1 == 'Others'), isFalse);
  });

  test('closed market uses MarketBreadth and no leaders', () {
    final p = buildMarketPulse(
      latest: memberRows(yesterday),
      nifty50: members,
      intraday: const [],
      sectors: {'M7': 'Tech'},
      now: closedNow,
      breadthRow: {'trade_date': '2026-11-18', 'advances': 878, 'declines': 2121},
    );
    expect(p.live, isFalse);
    expect(p.advances, 878);
    expect(p.declines, 2121);
    expect(p.leaders, isEmpty);
    expect(p.asOf, DateTime(2026, 11, 18));
    expect(p.gainers, isNotEmpty); // yesterday's session is still the latest one
  });

  test('spark is the day\'s intraday prices in time order, indices in fixed order', () {
    final p = buildMarketPulse(
      latest: [lp('SENSEX', 82031.81, 82532.19, fresh), lp('NIFTY 50', 25227.95, 25387.4, fresh)],
      nifty50: const {},
      intraday: [
        {'Instrument': 'NIFTY 50', 'ts': '2026-11-19T09:25:00+05:30', 'price': 25230},
        {'Instrument': 'NIFTY 50', 'ts': '2026-11-19T09:20:00+05:30', 'price': 25300},
      ],
      sectors: const {},
      now: openNow,
    );
    expect(p.indices.map((i) => i.name), ['NIFTY 50', 'SENSEX', 'NIFTY BANK', 'NIFTY IT']);
    expect(p.indices.first.spark, [25300, 25230]);
    expect(p.indices.first.change, closeTo(-159.45, 1e-6));
    expect(p.indices.first.prevClose, 25387.4);
  });

  test('a missing index gives nulls, not zero', () {
    final p = buildMarketPulse(latest: const [], nifty50: const {}, intraday: const [], sectors: const {}, now: openNow);
    final bank = p.indices.firstWhere((i) => i.name == 'NIFTY BANK');
    expect(bank.value, isNull);
    expect(bank.pct, isNull);
    expect(bank.spark, isEmpty);
  });
}
