enum RecommendationType {
  strongBuy,
  buy,
  accumulate,
  hold,
  reduce,
  sell;

  String get label {
    switch (this) {
      case RecommendationType.strongBuy:
        return 'STRONG OUTPERFORM';
      case RecommendationType.buy:
        return 'OUTPERFORM';
      case RecommendationType.accumulate:
        return 'MODERATE STRENGTH';
      case RecommendationType.hold:
        return 'NEUTRAL / WATCH';
      case RecommendationType.reduce:
        return 'ELEVATED RISK';
      case RecommendationType.sell:
        return 'HIGH RISK';
    }
  }
}

class AIRecommendation {
  final RecommendationType recommendation;

  final int confidence;

  final String title;

  final String summary;

  final List<String> reasons;

  final List<String> actions;

  const AIRecommendation({
    required this.recommendation,
    required this.confidence,
    required this.title,
    required this.summary,
    required this.reasons,
    required this.actions,
  });
}