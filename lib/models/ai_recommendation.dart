enum RecommendationType {
  strongBuy,
  buy,
  accumulate,
  hold,
  reduce,
  sell,
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