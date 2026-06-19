import '../models/dashboard_summary.dart';
import '../models/live_portfolio.dart';
import '../models/portfolio_analysis.dart';
import '../repositories/live_portfolio_repository.dart';
import '../repositories/portfolio_repository.dart';
import '../repositories/price_repository.dart';
import 'portfolio_analyzer.dart';
import 'recommendation_engine.dart';

class DashboardEngine {
  final LivePortfolioRepository liveRepository;

  final PortfolioAnalyzer portfolioAnalyzer;

  final RecommendationEngine recommendationEngine;

  DashboardEngine()
      : liveRepository = LivePortfolioRepository(
          portfolioRepository: PortfolioRepository(),
          priceRepository: PriceRepository(),
        ),
        portfolioAnalyzer = PortfolioAnalyzer(),
        recommendationEngine = RecommendationEngine();

  Future<DashboardSummary> buildDashboard() async {
    // ==========================
    // Load Live Portfolio
    // ==========================

    final List<LivePortfolio> portfolio =
        await liveRepository.getPortfolio();

    // ==========================
    // Portfolio Analysis
    // ==========================

    final PortfolioAnalysis analysis =
        portfolioAnalyzer.analyze(portfolio);

    // ==========================
    // AI Recommendation
    // ==========================

    final ai =
        recommendationEngine.generate(analysis);

    // ==========================
    // Dashboard Model
    // ==========================

    return DashboardSummary(
      totalInvested: analysis.totalInvested,
      currentValue: analysis.currentValue,
      totalPnL: analysis.totalPnL,
      returnPercent: analysis.returnPercent,
      totalStocks: analysis.totalStocks,
      biggestWinner: analysis.biggestWinner,
      biggestLoser: analysis.biggestLoser,
      portfolioHealth: analysis.healthScore,
      aiRecommendation: ai.summary,
    );
  }
}