import '../models/ai_recommendation.dart';
import '../models/portfolio_analysis.dart';

class RecommendationEngine {
  int _calculateDynamicConfidence(PortfolioAnalysis analysis, {required double baseScore}) {
    double score = baseScore;

    // Asset breadth & data coverage
    if (analysis.totalStocks >= 20) {
      score += 6.0;
    } else if (analysis.totalStocks >= 10) {
      score += 4.0;
    } else if (analysis.totalStocks >= 4) {
      score += 2.0;
    }

    // Factor alignment (Health & Risk)
    final healthFactor = ((analysis.healthScore - 50.0) / 50.0) * 4.0;
    score += healthFactor;

    if (analysis.riskScore > 65) {
      score -= 4.0;
    } else if (analysis.riskScore < 35) {
      score += 3.0;
    }

    // Breadth consensus
    if (analysis.totalStocks > 0) {
      final winRatio = analysis.profitStocks / analysis.totalStocks;
      if (winRatio > 0.65 || winRatio < 0.25) {
        score += 3.0;
      }
    }

    return score.round().clamp(68, 95);
  }

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

      confidence = _calculateDynamicConfidence(analysis, baseScore: 84);

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

      confidence = _calculateDynamicConfidence(analysis, baseScore: 80);

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

      confidence = _calculateDynamicConfidence(analysis, baseScore: 74);

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

      confidence = _calculateDynamicConfidence(analysis, baseScore: 71);

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

      confidence = _calculateDynamicConfidence(analysis, baseScore: 81);

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
      confidence: confidence,
      title: title,
      summary: summary,
      reasons: reasons,
      actions: actions,
    );
  }
}