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

  factory LiveMarketQuote.fromYahooMeta(String symbol, Map<String, dynamic> meta) {
    final price = (meta['regularMarketPrice'] as num?)?.toDouble() ?? 0.0;
    final prevClose = (meta['previousClose'] as num?)?.toDouble() ??
        (meta['chartPreviousClose'] as num?)?.toDouble() ??
        price;
    final change = price - prevClose;
    final changePercent = prevClose > 0 ? (change / prevClose) * 100 : 0.0;
    final dayHigh = (meta['regularMarketDayHigh'] as num?)?.toDouble() ?? price;
    final dayLow = (meta['regularMarketDayLow'] as num?)?.toDouble() ?? price;
    final volume = (meta['regularMarketVolume'] as num?)?.toInt() ?? 0;

    return LiveMarketQuote(
      symbol: symbol,
      currentPrice: price,
      previousClose: prevClose,
      change: change,
      changePercent: changePercent,
      dayHigh: dayHigh,
      dayLow: dayLow,
      volume: volume,
      timestamp: DateTime.now(),
    );
  }
}
