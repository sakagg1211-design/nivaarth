import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/utils/indicators.dart';
import 'package:mobile/core/utils/market_hours.dart';
import 'package:mobile/providers/market_indices_provider.dart';

void main() {
  test('SMA and EMA from closes, null when too few', () {
    final closes = <double>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    expect(Indicators.sma(closes, 5), 8.0);
    expect(Indicators.sma(closes, 11), isNull);
    // EMA(3): seed 2.0, then k = 0.5 each step -> converges to price - 1
    expect(Indicators.ema(closes, 3), closeTo(9.0, 1e-9));
  });

  test('RSI: only gains is 100, only losses is 0, flat-ish mix in between', () {
    final up = List<double>.generate(20, (i) => 100.0 + i);
    final down = List<double>.generate(20, (i) => 100.0 - i);
    expect(Indicators.rsi(up), 100);
    expect(Indicators.rsi(down), closeTo(0, 1e-9));
    final zigzag = List<double>.generate(30, (i) => i.isEven ? 100.0 : 101.0);
    expect(Indicators.rsi(zigzag), inInclusiveRange(40, 60));
    expect(Indicators.rsi(<double>[1, 2, 3]), isNull);
  });

  test('an unavailable index has no made-up level', () {
    const item = MarketIndexItem.unavailable('NIFTY 50');
    expect(item.isAvailable, isFalse);
    expect(item.value, 0);
  });

  test('market hours in IST', () {
    expect(isMarketOpenIst(DateTime.utc(2026, 10, 29, 4, 0)), isTrue); // Thu 09:30 IST
    expect(isMarketOpenIst(DateTime.utc(2026, 10, 29, 10, 1)), isFalse); // Thu 15:31 IST
  });
}
