import '../core/utils/symbol_utils.dart';

class StockScore {
  final String instrument;
  final String companyName;
  final int businessQuality;
  final int financialStrength;
  final int growth;
  final int valuation;
  final int technical;
  final int risk;
  final int? overallScore;
  final String recommendation;
  final int confidence;
  final DateTime? lastUpdated;
  final String? analystVerdict;
  final bool debtNotAssessed;
  final bool provisionalCreditPending;
  final bool provisionalBrokerMTF;
  /// How OverallScore was built (backend build_score_breakdown, migration 11); null on older rows
  final Map<String, dynamic>? scoreBreakdown;

  bool get isExcluded => overallScore == null;

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
    this.analystVerdict,
    this.debtNotAssessed = false,
    this.provisionalCreditPending = false,
    this.provisionalBrokerMTF = false,
    this.scoreBreakdown,
  });

  factory StockScore.empty() {
    return const StockScore(
      instrument: "",
      companyName: "",
      businessQuality: 0,
      financialStrength: 0,
      growth: 0,
      valuation: 0,
      technical: 0,
      risk: 0,
      overallScore: null,
      recommendation: "NEUTRAL / WATCH",
      confidence: 0,
      lastUpdated: null,
      analystVerdict: null,
      debtNotAssessed: false,
      provisionalCreditPending: false,
      provisionalBrokerMTF: false,
    );
  }

  factory StockScore.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawOverall = json["OverallScore"] ?? json["overall_score"];
    return StockScore(
      instrument:
          json["Instrument"]?.toString() ?? json["symbol"]?.toString() ?? "",

      companyName:
          json["Company_name"]?.toString() ?? json["company_name"]?.toString() ?? "",

      businessQuality:
          (json["BusinessQuality"] as num?)?.toInt() ??
          (json["business_quality"] as num?)?.toInt() ??
          0,

      financialStrength:
          (json["FinancialStrength"] as num?)?.toInt() ??
          (json["financial_strength"] as num?)?.toInt() ??
          0,

      growth:
          (json["Growth"] as num?)?.toInt() ??
          (json["growth"] as num?)?.toInt() ??
          0,

      valuation:
          (json["Valuation"] as num?)?.toInt() ??
          (json["valuation"] as num?)?.toInt() ??
          0,

      technical:
          (json["Technical"] as num?)?.toInt() ??
          (json["technical"] as num?)?.toInt() ??
          0,

      risk:
          (json["Risk"] as num?)?.toInt() ??
          (json["risk"] as num?)?.toInt() ??
          0,

      overallScore: (rawOverall as num?)?.toInt(),

      recommendation:
          SymbolUtils.toCompliantVerdict(json["Recommendation"]?.toString() ?? json["recommendation"]?.toString()),

      confidence:
          (json["Confidence"] as num?)?.toInt() ??
          (json["confidence"] as num?)?.toInt() ??
          0,

      lastUpdated:
          json["LastUpdated"] == null && json["last_updated"] == null
              ? null
              : DateTime.tryParse(
                  (json["LastUpdated"] ?? json["last_updated"]).toString()),
      analystVerdict: json["AnalystVerdict"]?.toString() ??
          json["analyst_verdict"]?.toString(),
      debtNotAssessed: json["DebtNotAssessed"] == true ||
          json["debt_not_assessed"] == true,
      provisionalCreditPending: json["ProvisionalCreditPending"] == true ||
          json["provisional_credit_pending"] == true,
      provisionalBrokerMTF: json["ProvisionalBrokerMTF"] == true ||
          json["provisional_broker_mtf"] == true,
      scoreBreakdown: json["score_breakdown"] is Map
          ? Map<String, dynamic>.from(json["score_breakdown"] as Map)
          : null,
    );
  }
}