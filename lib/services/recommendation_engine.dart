import '../models/ai_recommendation.dart';
import '../models/portfolio_analysis.dart';

class RecommendationEngine {
  AIRecommendation generate(
    PortfolioAnalysis analysis,
  ) {
    RecommendationType recommendation;
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
        "Continue holding quality businesses.",
      );

      actions.add(
        "Review profit booking near resistance zones.",
      );
    }

    // =========================
    // RULE 2
    // Healthy
    // =========================

    else if (analysis.returnPercent >= 10) {
      recommendation = RecommendationType.buy;

      title = "Healthy Portfolio";

      summary =
          "Portfolio is generating healthy returns.";

      reasons.add(
        "Positive portfolio performance.",
      );

      actions.add(
        "Continue steady accumulation.",
      );
    }

    // =========================
    // RULE 3
    // Stable
    // =========================

    else if (analysis.returnPercent >= 0) {
      recommendation = RecommendationType.hold;

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
        "Continue disciplined investing.",
      );
    }

    // =========================
    // RULE 4
    // Weak
    // =========================

    else if (analysis.returnPercent >= -10) {
      recommendation =
          RecommendationType.accumulate;


      title = "Temporary Weakness";

      summary =
          "Current drawdown appears manageable.";

      reasons.add(
        "Drawdown is still within normal market bands.",
      );

      actions.add(
        "Maintain investment horizon; avoid panic selling.",
      );

      actions.add(
        "Accumulate only fundamentally sound businesses.",
      );
    }

    // =========================
    // RULE 5
    // High Risk
    // =========================

    else {
      recommendation = RecommendationType.reduce;

      title = "Portfolio Needs Attention";

      summary =
          "Risk metrics have increased across holdings.";

      reasons.add(
        "Portfolio return dropped below -10%.",
      );

      reasons.add(
        "${analysis.lossStocks} holdings are currently in loss.",
      );

      reasons.add(
        "Risk score is elevated.",
      );

      actions.add(
        "Review risk exposure on underperforming holdings.",
      );

      actions.add(
        "Consider preserving cash liquidity.",
      );

      actions.add(
        "Avoid aggressive averaging in falling cyclical stocks.",
      );
    }

    return AIRecommendation(
      recommendation: recommendation,
      title: title,
      summary: summary,
      reasons: reasons,
      actions: actions,
    );
  }
}