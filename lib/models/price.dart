class Price {
  final String instrument;
  final double currentPrice;
  final double dayHigh;
  final double dayLow;
  final double volume;
  final DateTime? lastUpdated;

  const Price({
    required this.instrument,
    required this.currentPrice,
    required this.dayHigh,
    required this.dayLow,
    required this.volume,
    required this.lastUpdated,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      instrument: json["Instrument"]?.toString() ?? "",

      currentPrice:
          (json["CurrentPrice"] as num?)?.toDouble() ?? 0,

      dayHigh:
          (json["DayHigh"] as num?)?.toDouble() ?? 0,

      dayLow:
          (json["DayLow"] as num?)?.toDouble() ?? 0,

      volume:
          (json["Volume"] as num?)?.toDouble() ?? 0,

      lastUpdated: json["LastUpdated"] == null
          ? null
          : DateTime.parse(json["LastUpdated"]),
    );
  }
}