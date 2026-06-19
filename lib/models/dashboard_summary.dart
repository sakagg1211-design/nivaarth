import 'package:mobile/models/live_portfolio.dart';

class DashboardSummary {
  final double totalInvested;
  final double currentValue;
  final double totalPnL;
  final double returnPercent;

  final int totalStocks;

  final LivePortfolio biggestWinner;
  final LivePortfolio biggestLoser;

  final double portfolioHealth;

  final String aiRecommendation;

  const DashboardSummary({
    required this.totalInvested,
    required this.currentValue,
    required this.totalPnL,
    required this.returnPercent,
    required this.totalStocks,
    required this.biggestWinner,
    required this.biggestLoser,
    required this.portfolioHealth,
    required this.aiRecommendation,
  });
}