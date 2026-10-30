/// Where the portfolio stands against its cost; a state, never a buy / sell call
enum RecommendationType {
  strong,
  healthy,
  stable,
  drawdown,
  deepDrawdown;

  String get label {
    switch (this) {
      case RecommendationType.strong:
        return 'STRONG';
      case RecommendationType.healthy:
        return 'HEALTHY';
      case RecommendationType.stable:
        return 'STABLE';
      case RecommendationType.drawdown:
        return 'IN DRAWDOWN';
      case RecommendationType.deepDrawdown:
        return 'BELOW COST';
    }
  }
}

class AIRecommendation {
  final RecommendationType recommendation;

  final String title;

  final String summary;

  final List<String> reasons;

  /// Factual "what to check" items (shown under "What to check")
  final List<String> actions;

  const AIRecommendation({
    required this.recommendation,
    required this.title,
    required this.summary,
    required this.reasons,
    required this.actions,
  });
}