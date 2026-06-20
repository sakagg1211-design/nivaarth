class StockScore {
  final String instrument;

  final String companyName;

  final int businessQuality;

  final int financialStrength;

  final int growth;

  final int valuation;

  final int technical;

  final int risk;

  final int overallScore;

  final String recommendation;

  final int confidence;

  final DateTime? lastUpdated;

  const StockScore({
    required this.instrument,
    required this.companyName,
    required this.businessQuality,
    required this.financialStrength,
    required this.growth,
    required this.valuation,
    required this.technical,
    required this.risk,
    required this.overallScore,
    required this.recommendation,
    required this.confidence,
    required this.lastUpdated,
  });

  factory StockScore.fromJson(
    Map<String, dynamic> json,
  ) {
    return StockScore(
      instrument:
          json["Instrument"]?.toString() ?? "",

      companyName:
          json["Company_name"]?.toString() ?? "",

      businessQuality:
          (json["BusinessQuality"] as num?)
                  ?.toInt() ??
              0,

      financialStrength:
          (json["FinancialStrength"] as num?)
                  ?.toInt() ??
              0,

      growth:
          (json["Growth"] as num?)
                  ?.toInt() ??
              0,

      valuation:
          (json["Valuation"] as num?)
                  ?.toInt() ??
              0,

      technical:
          (json["Technical"] as num?)
                  ?.toInt() ??
              0,

      risk:
          (json["Risk"] as num?)
                  ?.toInt() ??
              0,

      overallScore:
          (json["OverallScore"] as num?)
                  ?.toInt() ??
              0,

      recommendation:
          json["Recommendation"]
                  ?.toString() ??
              "",

      confidence:
          (json["Confidence"] as num?)
                  ?.toInt() ??
              0,

      lastUpdated:
          json["LastUpdated"] == null
              ? null
              : DateTime.tryParse(
                  json["LastUpdated"]),
    );
  }
}