import '../models/live_portfolio.dart';
import '../models/stock_score.dart';

class StockScoreEngine {
  const StockScoreEngine();

  List<StockScore> portfolioScores(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    final Map<String, StockScore> scoreMap = {};

for (final score in scores) {
  final key = score.instrument
      .toUpperCase()
      .replaceAll(".NS", "");

  scoreMap[key] = score;
}

    final List<StockScore> result = [];

    for (final holding in portfolio) {
  final symbol = holding.portfolio.instrument
    .toUpperCase()
    .replaceAll("-BE", "")
    .replaceAll(".NS", "");

  print("Portfolio : $symbol");

  if (scoreMap.containsKey(symbol)) {
    print("Matched : $symbol");
    result.add(scoreMap[symbol]!);
  } else {
    print("Not Found : $symbol");
  }
}
print(scoreMap.keys.toList());
    return result;
  }

  StockScore getTopOpportunity(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    final portfolioOnly =
        portfolioScores(portfolio, scores);

    if (portfolioOnly.isEmpty) {
      throw Exception(
        "No Stock Scores Found",
      );
    }

    portfolioOnly.sort(
      (a, b) =>
          b.overallScore.compareTo(
        a.overallScore,
      ),
    );

    return portfolioOnly.first;
  }

  StockScore getWeakestHolding(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    final portfolioOnly =
        portfolioScores(portfolio, scores);

    if (portfolioOnly.isEmpty) {
      throw Exception(
        "No Stock Scores Found",
      );
    }

    portfolioOnly.sort(
      (a, b) =>
          a.overallScore.compareTo(
        b.overallScore,
      ),
    );

    return portfolioOnly.first;
  }

  double getAverageScore(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    final portfolioOnly =
        portfolioScores(portfolio, scores);

    if (portfolioOnly.isEmpty) {
      return 0;
    }

    double total = 0;

    for (final stock in portfolioOnly) {
      total += stock.overallScore;
    }

    return total / portfolioOnly.length;
  }

  int strongBuyCount(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    return portfolioScores(portfolio, scores)
        .where(
          (e) =>
              e.recommendation
                  .toLowerCase() ==
              "strong buy",
        )
        .length;
  }

  int buyCount(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    return portfolioScores(portfolio, scores)
        .where(
          (e) =>
              e.recommendation
                  .toLowerCase() ==
              "buy",
        )
        .length;
  }

  int sellCount(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    return portfolioScores(portfolio, scores)
        .where(
          (e) =>
              e.recommendation
                  .toLowerCase() ==
              "sell",
        )
        .length;
  }

  List<StockScore> highRiskStocks(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    return portfolioScores(portfolio, scores)
        .where((e) => e.risk >= 70)
        .toList();
  }

  List<StockScore> lowConfidenceStocks(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    return portfolioScores(portfolio, scores)
        .where((e) => e.confidence < 60)
        .toList();
  }
}