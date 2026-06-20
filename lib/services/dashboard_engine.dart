import '../models/ai_recommendation.dart';
import '../models/dashboard_summary.dart';
import '../models/live_portfolio.dart';
import '../models/portfolio_analysis.dart';
import '../models/stock_score.dart';

import '../repositories/live_portfolio_repository.dart';
import '../repositories/portfolio_repository.dart';
import '../repositories/price_repository.dart';
import '../repositories/stock_score_repository.dart';

import 'portfolio_analyzer.dart';
import 'recommendation_engine.dart';
import 'stock_score_engine.dart';

class DashboardEngine {
  final LivePortfolioRepository liveRepository;

  final PortfolioAnalyzer portfolioAnalyzer;

  final RecommendationEngine recommendationEngine;

  final StockScoreRepository stockRepository;

  final StockScoreEngine stockScoreEngine;

  DashboardEngine()
      : liveRepository = LivePortfolioRepository(
          portfolioRepository: PortfolioRepository(),
          priceRepository: PriceRepository(),
        ),
        portfolioAnalyzer = PortfolioAnalyzer(),
        recommendationEngine = RecommendationEngine(),
        stockRepository = StockScoreRepository(),
        stockScoreEngine = const StockScoreEngine();

  Future<DashboardSummary> buildDashboard() async {
    // ==========================
    // Live Portfolio
    // ==========================

    final List<LivePortfolio> portfolio =
        await liveRepository.getPortfolio();

    // ==========================
    // Portfolio Analysis
    // ==========================

    final PortfolioAnalysis analysis =
        portfolioAnalyzer.analyze(portfolio);

    // ==========================
    // Stock Scores
    // ==========================

    final List<StockScore> scores =
        await stockRepository.getScores();

    final StockScore topOpportunity =
        stockScoreEngine.getTopOpportunity(scores);

    final StockScore weakestHolding =
        stockScoreEngine.getWeakestHolding(scores);

    // ==========================
    // AI Recommendation
    // ==========================

    final AIRecommendation ai =
        recommendationEngine.generate(analysis);

    // ==========================
    // Dashboard
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
      aiRecommendation: ai,
      topOpportunity: topOpportunity,
      weakestHolding: weakestHolding,
    );
  }
}