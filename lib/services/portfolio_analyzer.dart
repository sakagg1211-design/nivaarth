import '../models/live_portfolio.dart';
import '../models/portfolio.dart';
import '../models/portfolio_analysis.dart';

class PortfolioAnalyzer {
  PortfolioAnalysis analyze(
  List<LivePortfolio> portfolio,
) {
    if (portfolio.isEmpty) {
      final defaultHolding = LivePortfolio(
        portfolio: Portfolio(
          id: '0',
          instrument: 'N/A',
          companyName: 'No holdings yet',
          yahooSymbol: '',
          qty: 0,
          avgPrice: 0.0,
          totalInvested: 0.0,
          currentValue: 0.0,
          netPL: 0.0,
          sector: 'General',
          industry: 'General',
          status: 'ACTIVE',
          investmentThesis: '',
        ),
        currentPrice: 0.0,
        currentValue: 0.0,
        netPL: 0.0,
        returnPercent: 0.0,
      );

      return PortfolioAnalysis(
        totalInvested: 0.0,
        currentValue: 0.0,
        totalPnL: 0.0,
        returnPercent: 0.0,
        todayPnL: 0.0,
        todayReturnPercent: 0.0,
        totalStocks: 0,
        profitStocks: 0,
        lossStocks: 0,
        healthScore: 0,
        riskScore: 0,
        biggestWinner: defaultHolding,
        biggestLoser: defaultHolding,
      );
    }

    double totalInvested = 0;
    double currentValue = 0;
    double previousPortfolioValue = 0;
    double totalPnL = 0;

    int profitStocks = 0;
    int lossStocks = 0;
    int unpricedStocks = 0;
    int staleStocks = 0;

    // Holdings with no price would add their invested amount but zero value,
    // so every total below is computed over priced holdings only.
    final priced =
        portfolio.where((s) => !s.isPriceUnavailable).toList();

    LivePortfolio biggestWinner =
        priced.isNotEmpty ? priced.first : portfolio.first;
    LivePortfolio biggestLoser = biggestWinner;

    for (final stock in portfolio) {
      if (stock.isPriceUnavailable) {
        unpricedStocks++;
        continue;
      }
      if (stock.isStale) {
        staleStocks++;
      }

      totalInvested += stock.portfolio.totalInvested;
      currentValue += stock.currentValue;
      previousPortfolioValue += (stock.currentValue - stock.todayPL);
      totalPnL += stock.netPL;

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

    final double riskScore = priced.isEmpty
        ? 0
        : (lossStocks / priced.length) * 100;

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
      unpricedStocks: unpricedStocks,
      staleStocks: staleStocks,

      // Portfolio Health is now handled by PortfolioHealthEngine
      healthScore: 0,

      riskScore: riskScore,
      biggestWinner: biggestWinner,
      biggestLoser: biggestLoser,
    );
  }
}