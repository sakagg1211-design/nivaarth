class LiveMarketQuote {
  final String symbol;
  final double currentPrice;
  final double previousClose;
  final double change;
  final double changePercent;
  final double dayHigh;
  final double dayLow;
  final int volume;
  final DateTime timestamp;

  const LiveMarketQuote({
    required this.symbol,
    required this.currentPrice,
    required this.previousClose,
    required this.change,
    required this.changePercent,
    required this.dayHigh,
    required this.dayLow,
    required this.volume,
    required this.timestamp,
  });

  bool get isPositive => change >= 0;

  /// Close of the last daily candle from a trading day before the one of [tradeSecs] (IST),
  /// or null. Yahoo's chartPreviousClose for indices can lag a day (on 30 Oct 2026 NIFTY's was
  /// the 28 Oct close), which made the day change about 3x too large.
  static double? previousSessionClose(List<dynamic>? timestamps, List<dynamic>? closes, int? tradeSecs) {
    if (timestamps == null || closes == null || tradeSecs == null) return null;
    const istOffset = 19800;
    int istDay(int secs) => (secs + istOffset) ~/ 86400;
    final tradeDay = istDay(tradeSecs);
    double? prev;
    for (var i = 0; i < timestamps.length && i < closes.length; i++) {
      final t = timestamps[i];
      final c = closes[i];
      if (t is num && c is num && istDay(t.toInt()) < tradeDay) prev = c.toDouble();
    }
    return prev;
  }

  /// [timestamps] / [closes] are the daily candles of a range=5d&interval=1d chart; when given,
  /// the previous close comes from them instead of the meta fields.
  factory LiveMarketQuote.fromYahooMeta(
    String symbol,
    Map<String, dynamic> meta, {
    List<dynamic>? timestamps,
    List<dynamic>? closes,
  }) {
    final price = (meta['regularMarketPrice'] as num?)?.toDouble() ?? 0.0;
    final prevClose = previousSessionClose(timestamps, closes, (meta['regularMarketTime'] as num?)?.toInt()) ??
        (meta['previousClose'] as num?)?.toDouble() ??
        (meta['chartPreviousClose'] as num?)?.toDouble() ??
        price;
    final change = price - prevClose;
    final changePercent = prevClose > 0 ? (change / prevClose) * 100 : 0.0;
    final dayHigh = (meta['regularMarketDayHigh'] as num?)?.toDouble() ?? price;
    final dayLow = (meta['regularMarketDayLow'] as num?)?.toDouble() ?? price;
    final volume = (meta['regularMarketVolume'] as num?)?.toInt() ?? 0;
    // Exchange time of the last trade (epoch seconds), not the fetch time
    final tradeSecs = (meta['regularMarketTime'] as num?)?.toInt();

    return LiveMarketQuote(
      symbol: symbol,
      currentPrice: price,
      previousClose: prevClose,
      change: change,
      changePercent: changePercent,
      dayHigh: dayHigh,
      dayLow: dayLow,
      volume: volume,
      timestamp: tradeSecs != null
          ? DateTime.fromMillisecondsSinceEpoch(tradeSecs * 1000)
          : DateTime.now(),
    );
  }
}
