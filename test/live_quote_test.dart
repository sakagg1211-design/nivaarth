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

  // GLOBALVECT on 3 Nov 2026: Yahoo had no 2 Nov candle yet, so its previous close was the
  // 30 Oct close and the app showed about +6% on a +2% day
  group('NSE previous close', () {
    final trade3Nov = DateTime.utc(2026, 11, 3, 5, 30).millisecondsSinceEpoch ~/ 1000; // 11:00 IST
    final yahoo = LiveMarketQuote.fromYahooMeta(
      'GLOBALVECT',
      {'regularMarketPrice': 117.3, 'regularMarketTime': trade3Nov},
      timestamps: [istMorning(10, 29), istMorning(10, 30)],
      closes: [119.27, 110.81],
    );

    test('Yahoo alone uses the 30 Oct candle', () {
      expect(yahoo.previousClose, 110.81);
      expect(yahoo.previousCloseDate, DateTime(2026, 10, 30));
      expect(yahoo.changePercent, closeTo(5.86, 0.01));
    });

    test('the 2 Nov bhavcopy close replaces it', () {
      final q = yahoo.withOfficialPreviousClose(114.96, DateTime(2026, 11, 2));
      expect(q.previousClose, 114.96);
      expect(q.changePercent, closeTo(2.04, 0.01));
      expect(q.isFresh, isTrue);
    });

    test('an older or same-day NSE close is not used', () {
      expect(yahoo.withOfficialPreviousClose(119.27, DateTime(2026, 10, 29)).previousClose, 110.81);
      expect(yahoo.withOfficialPreviousClose(117.0, DateTime(2026, 11, 3)).previousClose, 110.81);
    });

    test('a kept quote is not fresh', () {
      expect(yahoo.asCached().isFresh, isFalse);
    });
  });

  test('without candles the meta fields are still used', () {
    final q = LiveMarketQuote.fromYahooMeta('TCS', {'regularMarketPrice': 2502.6, 'chartPreviousClose': 2478.0});
    expect(q.previousClose, 2478.0);
  });
}
