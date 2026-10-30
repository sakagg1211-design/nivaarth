import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/models/live_market_quote.dart';

// NIFTY 50 on 30 Oct 2026: Yahoo's chartPreviousClose was 22698.8 (the 28 Oct close)
int istMorning(int month, int day) => DateTime.utc(2026, month, day, 3, 45).millisecondsSinceEpoch ~/ 1000;

void main() {
  final timestamps = [istMorning(10, 28), istMorning(10, 29), istMorning(10, 30)];
  final closes = [22698.85, 22936.75, 23053.1];
  final tradeSecs = DateTime.utc(2026, 10, 30, 10, 1).millisecondsSinceEpoch ~/ 1000; // 3:31 PM IST

  test('previous close is the last candle before the trading day', () {
    expect(LiveMarketQuote.previousSessionClose(timestamps, closes, tradeSecs), 22936.75);
  });

  test('day change uses the candle close, not a stale chartPreviousClose', () {
    final q = LiveMarketQuote.fromYahooMeta(
      '^NSEI',
      {'regularMarketPrice': 23053.1, 'chartPreviousClose': 22698.8, 'regularMarketTime': tradeSecs},
      timestamps: timestamps,
      closes: closes,
    );
    expect(q.change, closeTo(116.35, 0.01));
    expect(q.changePercent, closeTo(0.507, 0.001));
  });

  test('without candles the meta fields are still used', () {
    final q = LiveMarketQuote.fromYahooMeta('TCS', {'regularMarketPrice': 2502.6, 'chartPreviousClose': 2478.0});
    expect(q.previousClose, 2478.0);
  });
}
