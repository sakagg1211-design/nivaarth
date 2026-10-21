class Price {
  final String instrument;
  final double currentPrice;
  final double dayHigh;
  final double dayLow;
  final double volume;
  final double previousClose;
  final DateTime? lastUpdated;

  const Price({
    required this.instrument,
    required this.currentPrice,
    required this.dayHigh,
    required this.dayLow,
    required this.volume,
    this.previousClose = 0.0,
    required this.lastUpdated,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    final cur = (json["CurrentPrice"] as num?)?.toDouble() ?? 0;
    final low = (json["DayLow"] as num?)?.toDouble() ?? 0;
    final prev = (json["PreviousClose"] as num?)?.toDouble() ?? cur;

    return Price(
      instrument: json["Instrument"]?.toString() ?? "",
      currentPrice: cur,
      dayHigh: (json["DayHigh"] as num?)?.toDouble() ?? 0,
      dayLow: low,
      volume: (json["Volume"] as num?)?.toDouble() ?? 0,
      previousClose: prev,
      lastUpdated: json["LastUpdated"] == null
          ? null
          : DateTime.parse(json["LastUpdated"]),
    );
  }
}