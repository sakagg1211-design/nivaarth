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
    double previousPortfolioValue = 0;
    double totalPnL = 0;
    double todayPnL = 0;

    int profitStocks = 0;
    int lossStocks = 0;

    LivePortfolio biggestWinner = portfolio.first;
    LivePortfolio biggestLoser = portfolio.first;

    for (final stock in portfolio) {
      totalInvested += stock.portfolio.totalInvested;
      currentValue += stock.currentValue;
      previousPortfolioValue += (stock.currentValue - stock.todayPL);
      totalPnL += stock.netPL;
      todayPnL += stock.todayPL;

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
    }

    final double returnPercent = totalInvested == 0
        ? 0
        : (totalPnL / totalInvested) * 100;

    // Today P&L = Current Portfolio Value - Previous Portfolio Value
    final double finalTodayPnL = currentValue - previousPortfolioValue;
    final double todayReturnPercent = previousPortfolioValue > 0
        ? (finalTodayPnL / previousPortfolioValue) * 100
        : 0.0;

    final double riskScore =
        (lossStocks / portfolio.length) * 100;

    return PortfolioAnalysis(
      totalInvested: totalInvested,
      currentValue: currentValue,
      totalPnL: totalPnL,
      returnPercent: returnPercent,
      todayPnL: finalTodayPnL,
      todayReturnPercent: todayReturnPercent,
      totalStocks: portfolio.length,
      profitStocks: profitStocks,
      lossStocks: lossStocks,

      // Portfolio Health is now handled by PortfolioHealthEngine
      healthScore: 0,

      riskScore: riskScore,
      biggestWinner: biggestWinner,
      biggestLoser: biggestLoser,
    );
  }
}