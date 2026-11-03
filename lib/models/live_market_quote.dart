class LiveMarketQuote {
  final String symbol;
  final double currentPrice;
  final double previousClose;
  final double change;
  final double changePercent;
  final double dayHigh;
  final double dayLow;
  final int volume;
  /// Exchange time of the last trade (Yahoo), or LatestPrices.LastUpdated for the database fallback
  final DateTime timestamp;
  /// Trading day (IST, date only) the previous close belongs to, when known
  final DateTime? previousCloseDate;
  /// When this quote was fetched. A refresh label uses this, not [timestamp]: a stock that has
  /// not traded since 11:11 still has a fresh 11:40 quote.
  final DateTime? fetchedAt;
  /// 'yahoo' (fetched now), 'database' (LatestPrices fallback), 'cache' (an earlier quote kept
  /// because this refresh failed) or 'none'
  final String source;

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
    this.previousCloseDate,
    this.fetchedAt,
    this.source = 'yahoo',
  });

  bool get isPositive => change >= 0;

  /// True when this refresh got a live quote (not a fallback or an older one)
  bool get isFresh => source == 'yahoo';

  static const int _istOffset = 19800;
  static int _istDay(int secs) => (secs + _istOffset) ~/ 86400;

  /// IST calendar day of [t] as a date-only DateTime
  static DateTime istDate(DateTime t) {
    final ist = t.toUtc().add(const Duration(hours: 5, minutes: 30));
    return DateTime(ist.year, ist.month, ist.day);
  }

  /// (close, IST day number) of the last daily candle from a trading day before the one of
  /// [tradeSecs], or null.
  static (double, int)? previousSession(List<dynamic>? timestamps, List<dynamic>? closes, int? tradeSecs) {
    if (timestamps == null || closes == null || tradeSecs == null) return null;
    final tradeDay = _istDay(tradeSecs);
    (double, int)? prev;
    for (var i = 0; i < timestamps.length && i < closes.length; i++) {
      final t = timestamps[i];
      final c = closes[i];
      if (t is num && c is num && _istDay(t.toInt()) < tradeDay) prev = (c.toDouble(), _istDay(t.toInt()));
    }
    return prev;
  }

  /// Close of the last daily candle from a trading day before the one of [tradeSecs] (IST),
  /// or null. Yahoo's chartPreviousClose for indices can lag a day (on 30 Oct 2026 NIFTY's was
  /// the 28 Oct close), which made the day change about 3x too large.
  static double? previousSessionClose(List<dynamic>? timestamps, List<dynamic>? closes, int? tradeSecs) =>
      previousSession(timestamps, closes, tradeSecs)?.$1;

  /// [timestamps] / [closes] are the daily candles of a range=5d&interval=1d chart; when given,
  /// the previous close comes from them instead of the meta fields.
  factory LiveMarketQuote.fromYahooMeta(
    String symbol,
    Map<String, dynamic> meta, {
    List<dynamic>? timestamps,
    List<dynamic>? closes,
  }) {
    final price = (meta['regularMarketPrice'] as num?)?.toDouble() ?? 0.0;
    // Exchange time of the last trade (epoch seconds), not the fetch time
    final tradeSecs = (meta['regularMarketTime'] as num?)?.toInt();
    final session = previousSession(timestamps, closes, tradeSecs);
    final prevClose = session?.$1 ??
        (meta['previousClose'] as num?)?.toDouble() ??
        (meta['chartPreviousClose'] as num?)?.toDouble() ??
        price;
    final change = price - prevClose;
    final changePercent = prevClose > 0 ? (change / prevClose) * 100 : 0.0;
    final dayHigh = (meta['regularMarketDayHigh'] as num?)?.toDouble() ?? price;
    final dayLow = (meta['regularMarketDayLow'] as num?)?.toDouble() ?? price;
    final volume = (meta['regularMarketVolume'] as num?)?.toInt() ?? 0;
    DateTime? prevDate;
    if (session != null) {
      final d = DateTime.utc(1970).add(Duration(days: session.$2));
      prevDate = DateTime(d.year, d.month, d.day);
    }

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
      previousCloseDate: prevDate,
      fetchedAt: DateTime.now(),
    );
  }

  /// The same quote measured against another previous close (the NSE bhavcopy close)
  LiveMarketQuote withPreviousClose(double prev, DateTime prevDate) {
    final change = currentPrice - prev;
    return LiveMarketQuote(
      symbol: symbol,
      currentPrice: currentPrice,
      previousClose: prev,
      change: change,
      changePercent: prev > 0 ? change / prev * 100 : 0.0,
      dayHigh: dayHigh,
      dayLow: dayLow,
      volume: volume,
      timestamp: timestamp,
      previousCloseDate: prevDate,
      fetchedAt: fetchedAt,
      source: source,
    );
  }

  /// This quote marked as kept from an earlier fetch
  LiveMarketQuote asCached() => LiveMarketQuote(
        symbol: symbol,
        currentPrice: currentPrice,
        previousClose: previousClose,
        change: change,
        changePercent: changePercent,
        dayHigh: dayHigh,
        dayLow: dayLow,
        volume: volume,
        timestamp: timestamp,
        previousCloseDate: previousCloseDate,
        fetchedAt: fetchedAt,
        source: 'cache',
      );

  /// The NSE bhavcopy close replaces Yahoo's previous close when it belongs to a day before the
  /// quote's trading day and is not older than Yahoo's own. Yahoo's daily candles sometimes miss
  /// the previous day for smaller stocks, which put two days of movement into "today"
  /// (GLOBALVECT +6% on a +2% day, 3 Nov 2026).
  LiveMarketQuote withOfficialPreviousClose(double? prev, DateTime? prevDate) {
    if (prev == null || prev <= 0 || prevDate == null || currentPrice <= 0) return this;
    if (!prevDate.isBefore(istDate(timestamp))) return this;
    if (previousCloseDate != null && previousCloseDate!.isAfter(prevDate)) return this;
    return withPreviousClose(prev, prevDate);
  }
}
