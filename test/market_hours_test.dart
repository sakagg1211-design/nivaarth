import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/market_hours.dart';

DateTime ist(int d, int h, [int m = 0]) => DateTime.utc(2026, 11, d, h, m).subtract(const Duration(hours: 5, minutes: 30));

void main() {
  test('today\'s session has begun only on a trading day from 09:15 IST', () {
    expect(sessionStartedTodayIst(ist(20, 11)), isTrue); // Friday, open
    expect(sessionStartedTodayIst(ist(20, 18)), isTrue); // Friday, after the close: still today's session
    expect(sessionStartedTodayIst(ist(20, 8)), isFalse); // before the open
    expect(sessionStartedTodayIst(ist(21, 12)), isFalse); // Saturday
    expect(sessionStartedTodayIst(ist(24, 12)), isFalse); // NSE holiday
  });
}
