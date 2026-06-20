import '../models/stock_score.dart';

class StockScoreEngine {
  const StockScoreEngine();

  // ==========================
  // Best Stock
  // ==========================

  StockScore getTopOpportunity(
    List<StockScore> scores,
  ) {
    if (scores.isEmpty) {
      throw Exception("No Stock Scores Found");
    }

    StockScore best = scores.first;

    for (final stock in scores) {
      if (stock.overallScore >
          best.overallScore) {
        best = stock;
      }
    }

    return best;
  }

  // ==========================
  // Weakest Stock
  // ==========================

  StockScore getWeakestHolding(
    List<StockScore> scores,
  ) {
    if (scores.isEmpty) {
      throw Exception("No Stock Scores Found");
    }

    StockScore worst = scores.first;

    for (final stock in scores) {
      if (stock.overallScore <
          worst.overallScore) {
        worst = stock;
      }
    }

    return worst;
  }

  // ==========================
  // Average Score
  // ==========================

  double getAverageScore(
    List<StockScore> scores,
  ) {
    if (scores.isEmpty) return 0;

    double total = 0;

    for (final stock in scores) {
      total += stock.overallScore;
    }

    return total / scores.length;
  }

  // ==========================
  // Strong Buy Count
  // ==========================

  int strongBuyCount(
    List<StockScore> scores,
  ) {
    return scores
        .where(
          (e) =>
              e.recommendation
                  .toLowerCase() ==
              "strong buy",
        )
        .length;
  }

  // ==========================
  // Buy Count
  // ==========================

  int buyCount(
    List<StockScore> scores,
  ) {
    return scores
        .where(
          (e) =>
              e.recommendation
                  .toLowerCase() ==
              "buy",
        )
        .length;
  }

  // ==========================
  // Sell Count
  // ==========================

  int sellCount(
    List<StockScore> scores,
  ) {
    return scores
        .where(
          (e) =>
              e.recommendation
                  .toLowerCase() ==
              "sell",
        )
        .length;
  }

  // ==========================
  // High Risk Stocks
  // ==========================

  List<StockScore> highRiskStocks(
    List<StockScore> scores,
  ) {
    return scores
        .where(
          (e) => e.risk >= 70,
        )
        .toList();
  }

  // ==========================
  // Low Confidence Stocks
  // ==========================

  List<StockScore> lowConfidenceStocks(
    List<StockScore> scores,
  ) {
    return scores
        .where(
          (e) => e.confidence < 60,
        )
        .toList();
  }
}