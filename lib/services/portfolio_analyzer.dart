import '../models/live_portfolio.dart';
import '../models/portfolio_analysis.dart';

class PortfolioAnalyzer {
  PortfolioAnalysis analyze(
    List<LivePortfolio> portfolio,
  ) {
    if (portfolio.isEmpty) {
      throw Exception("Portfolio is empty");
    }

    double totalInvested = 0;
    double currentValue = 0;
    double totalPnL = 0;

    int profitStocks = 0;
    int lossStocks = 0;

    LivePortfolio biggestWinner = portfolio.first;
    LivePortfolio biggestLoser = portfolio.first;

    for (final stock in portfolio) {
      totalInvested += stock.portfolio.totalInvested;
      currentValue += stock.currentValue;
      totalPnL += stock.netPL;

      if (stock.netPL >= 0) {
        profitStocks++;
      } else {
        lossStocks++;
      }

      if (stock.returnPercent >
          biggestWinner.returnPercent) {
        biggestWinner = stock;
      }

      if (stock.returnPercent <
          biggestLoser.returnPercent) {
        biggestLoser = stock;
      }
    }

    final double returnPercent =
        totalInvested == 0
            ? 0
            : (totalPnL / totalInvested) * 100;

    // Temporary Health Score
    double healthScore = 100 + returnPercent;

    if (healthScore > 100) healthScore = 100;
    if (healthScore < 0) healthScore = 0;

    // Temporary Risk Score
    double riskScore =
        (lossStocks / portfolio.length) * 100;

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