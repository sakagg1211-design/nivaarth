class StockScore {
  final String instrument;
  final int overallScore;
  final String recommendation;

  StockScore({
    required this.instrument,
    required this.overallScore,
    required this.recommendation,
  });

  factory StockScore.fromJson(Map<String, dynamic> json) {
    return StockScore(
      instrument: json["Instrument"],
      overallScore: json["OverallScore"] ?? 0,
      recommendation: json["Recommendation"] ?? "",
    );
  }
}