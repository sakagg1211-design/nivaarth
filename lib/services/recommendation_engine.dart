import '../models/ai_recommendation.dart';
import '../models/portfolio_analysis.dart';

class RecommendationEngine {
  AIRecommendation generate(
    PortfolioAnalysis analysis,
  ) {
    RecommendationType recommendation;
    int confidence;
    String title;
    String summary;

    final List<String> reasons = [];
    final List<String> actions = [];

    // =========================
    // RULE 1
    // Excellent Portfolio
    // =========================

    if (analysis.returnPercent >= 20 &&
        analysis.healthScore >= 80) {
      recommendation = RecommendationType.strongBuy;

      confidence = 96;

      title = "Excellent Portfolio";

      summary =
          "Your portfolio is performing exceptionally well.";

      reasons.add(
        "Overall return is above 20%.",
      );

      reasons.add(
        "Health Score is excellent.",
      );

      reasons.add(
        "${analysis.profitStocks} stocks are profitable.",
      );

      actions.add(
        "Continue holding quality stocks.",
      );

      actions.add(
        "Book profits only after target achievement.",
      );
    }

    // =========================
    // RULE 2
    // Healthy
    // =========================

    else if (analysis.returnPercent >= 10) {
      recommendation = RecommendationType.buy;

      confidence = 90;

      title = "Healthy Portfolio";

      summary =
          "Portfolio is generating healthy returns.";

      reasons.add(
        "Positive portfolio performance.",
      );

      actions.add(
        "Continue accumulation.",
      );
    }

    // =========================
    // RULE 3
    // Stable
    // =========================

    else if (analysis.returnPercent >= 0) {
      recommendation = RecommendationType.hold;

      confidence = 82;

      title = "Stable Portfolio";

      summary =
          "Portfolio is stable.";

      reasons.add(
        "Portfolio remains profitable.",
      );

      actions.add(
        "Monitor weak performers.",
      );

      actions.add(
        "Continue SIP.",
      );
    }

    // =========================
    // RULE 4
    // Weak
    // =========================

    else if (analysis.returnPercent >= -10) {
      recommendation =
          RecommendationType.accumulate;

      confidence = 74;

      title = "Temporary Weakness";

      summary =
          "Current drawdown appears manageable.";

      reasons.add(
        "Loss is still within acceptable range.",
      );

      actions.add(
        "Avoid panic selling.",
      );

      actions.add(
        "Average only quality businesses.",
      );
    }

    // =========================
    // RULE 5
    // High Risk
    // =========================

    else {
      recommendation = RecommendationType.reduce;

      confidence = 92;

      title = "Portfolio Needs Attention";

      summary =
          "Risk has increased significantly.";

      reasons.add(
        "Portfolio return below -10%.",
      );

      reasons.add(
        "${analysis.lossStocks} stocks are currently in loss.",
      );

      reasons.add(
        "Risk score is elevated.",
      );

      actions.add(
        "Review weakest holdings.",
      );

      actions.add(
        "Increase cash allocation.",
      );

      actions.add(
        "Avoid averaging every falling stock.",
      );
    }

    return AIRecommendation(
      recommendation: recommendation,
      confidence: confidence,
      title: title,
      summary: summary,
      reasons: reasons,
      actions: actions,
    );
  }
}