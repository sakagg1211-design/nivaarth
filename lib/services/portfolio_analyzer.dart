import '../models/live_portfolio.dart';
import '../models/portfolio_analysis.dart';
import '../models/stock_score.dart';

class PortfolioAnalyzer {
  PortfolioAnalysis analyze(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    if (portfolio.isEmpty) {
      throw Exception("Portfolio is empty");
    }

    double totalInvested = 0;
    double currentValue = 0;
    double totalPnL = 0;

    int profitStocks = 0;
    int lossStocks = 0;

    double weightedOverall = 0;
    double totalWeight = 0;

    LivePortfolio biggestWinner = portfolio.first;
    LivePortfolio biggestLoser = portfolio.first;

    for (final stock in portfolio) {
      totalInvested += stock.portfolio.totalInvested;
      currentValue += stock.currentValue;
      totalPnL += stock.netPL;
      print(
  "Portfolio: ${stock.portfolio.instrument}",
);

      if (stock.netPL >= 0) {
        profitStocks++;
      } else {
        lossStocks++;
      }

      if (stock.returnPercent > biggestWinner.returnPercent) {
        biggestWinner = stock;
      }

      if (stock.returnPercent < biggestLoser.returnPercent) {
        biggestLoser = stock;
      }

      // Match stock with score
      try {
        final StockScore score = scores.firstWhere(
          (s) => s.instrument == stock.portfolio.instrument,
        );
        print(
  "Matched: ${score.instrument}",
);

print(
  "${score.instrument} -> Overall: ${score.overallScore}, Invested: ${stock.portfolio.totalInvested}",
);
        weightedOverall +=
            score.overallScore * stock.portfolio.totalInvested;

        totalWeight += stock.portfolio.totalInvested;
      } catch (_) {
        print(
  "Not Found: ${stock.portfolio.instrument}",
);
        // Ignore stocks not found in score table
      }
    }
print("Total Weight = $totalWeight");
print("Weighted Overall = $weightedOverall");
    final double returnPercent = totalInvested == 0
        ? 0
        : (totalPnL / totalInvested) * 100;

    // Portfolio Health (Investment Weighted)
    final double healthScore = totalWeight == 0
        ? 0
        : weightedOverall / totalWeight;

    // Risk Score
    final double riskScore =
        (lossStocks / portfolio.length) * 100;

        print("================================");
print("Total Weight : $totalWeight");
print("Weighted Overall : $weightedOverall");
print("Health Score : $healthScore");
print("================================");

    return PortfolioAnalysis(
      totalInvested: totalInvested,
      currentValue: currentValue,
      totalPnL: totalPnL,
      returnPercent: returnPercent,
      totalStocks: portfolio.length,
      profitStocks: profitStocks,
      lossStocks: lossStocks,
      healthScore: healthScore,
      riskScore: riskScore,
      biggestWinner: biggestWinner,
      biggestLoser: biggestLoser,
    );
  }
}