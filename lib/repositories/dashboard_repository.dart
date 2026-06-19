import '../models/dashboard_summary.dart';
import '../models/live_portfolio.dart';
import 'live_portfolio_repository.dart';
import 'portfolio_repository.dart';
import 'price_repository.dart';

class DashboardRepository {
  final LivePortfolioRepository repository;

  DashboardRepository()
      : repository = LivePortfolioRepository(
          portfolioRepository: PortfolioRepository(),
          priceRepository: PriceRepository(),
        );

  Future<DashboardSummary> getDashboard() async {
    final List<LivePortfolio> portfolio =
        await repository.getPortfolio();

    double invested = 0;
    double current = 0;
    double pnl = 0;

    for (final stock in portfolio) {
      invested += stock.portfolio.totalInvested;
      current += stock.currentValue;
      pnl += stock.netPL;
    }

    final double returns =
        invested == 0 ? 0 : (pnl / invested) * 100;

    // Biggest Winner
    LivePortfolio biggestWinner = portfolio.first;

    // Biggest Loser
    LivePortfolio biggestLoser = portfolio.first;

    for (final stock in portfolio) {
      if (stock.returnPercent >
          biggestWinner.returnPercent) {
        biggestWinner = stock;
      }

      if (stock.returnPercent <
          biggestLoser.returnPercent) {
        biggestLoser = stock;
      }
    }

    // Portfolio Health Score (Temporary Logic)
    double health = 100;

    if (returns < 0) {
      health += returns;
    }

    if (health < 0) {
      health = 0;
    }

    if (health > 100) {
      health = 100;
    }

    // AI Recommendation (Temporary)
    String recommendation;

    if (returns >= 15) {
      recommendation =
          "Excellent portfolio. Continue holding quality stocks.";
    } else if (returns >= 5) {
      recommendation =
          "Portfolio is healthy. Keep monitoring opportunities.";
    } else if (returns >= 0) {
      recommendation =
          "Portfolio is stable. Look for accumulation opportunities.";
    } else {
      recommendation =
          "Review weak performers and rebalance the portfolio.";
    }

    return DashboardSummary(
      totalInvested: invested,
      currentValue: current,
      totalPnL: pnl,
      returnPercent: returns,
      totalStocks: portfolio.length,
      biggestWinner: biggestWinner,
      biggestLoser: biggestLoser,
      portfolioHealth: health,
      aiRecommendation: recommendation,
    );
  }
}