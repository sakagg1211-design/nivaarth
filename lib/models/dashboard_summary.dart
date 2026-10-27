import 'package:mobile/models/ai_recommendation.dart';
import 'package:mobile/models/live_portfolio.dart';
import 'package:mobile/models/stock_score.dart';

class DashboardSummary {
  final double totalInvested;
  final double currentValue;
  final double totalPnL;
  final double returnPercent;
  final double todayPnL;
  final double todayReturnPercent;

  final int totalStocks;
  final int unpricedStocks;
  final int staleStocks;
  final DateTime? pricesAsOf;

  // Value-weighted data coverage of scored holdings (0-100), null when none scored
  final double? dataCoverage;

  final LivePortfolio biggestWinner;
  final LivePortfolio biggestLoser;

  final double portfolioHealth;
  final double businessHealth;
  final double financialHealth;
  final double growthHealth;
  final double valuationHealth;
  final double technicalHealth;
  final double riskHealth;

final String portfolioHealthStatus;

  // ==========================
  // AI
  // ==========================

  final AIRecommendation aiRecommendation;

  final StockScore topOpportunity;

  final StockScore weakestHolding;

  const DashboardSummary({
    required this.totalInvested,
    required this.currentValue,
    required this.totalPnL,
    required this.returnPercent,
    this.todayPnL = 0.0,
    this.todayReturnPercent = 0.0,
    required this.totalStocks,
    this.unpricedStocks = 0,
    this.staleStocks = 0,
    this.pricesAsOf,
    this.dataCoverage,
    required this.biggestWinner,
    required this.biggestLoser,
    required this.portfolioHealth,
    required this.aiRecommendation,
    required this.topOpportunity,
    required this.weakestHolding,
    required this.businessHealth,
    required this.financialHealth,
    required this.growthHealth,
    required this.valuationHealth,
    required this.technicalHealth,
    required this.riskHealth,

required this.portfolioHealthStatus,
  });
}