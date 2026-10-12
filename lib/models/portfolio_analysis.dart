import 'package:mobile/models/live_portfolio.dart';

class PortfolioAnalysis {
  final double totalInvested;
  final double currentValue;
  final double totalPnL;
  final double returnPercent;
  final double todayPnL;
  final double todayReturnPercent;

  final int totalStocks;
  final int profitStocks;
  final int lossStocks;

  final double healthScore;
  final double riskScore;

  final LivePortfolio biggestWinner;
  final LivePortfolio biggestLoser;

  const PortfolioAnalysis({
    required this.totalInvested,
    required this.currentValue,
    required this.totalPnL,
    required this.returnPercent,
    this.todayPnL = 0.0,
    this.todayReturnPercent = 0.0,
    required this.totalStocks,
    required this.profitStocks,
    required this.lossStocks,
    required this.healthScore,
    required this.riskScore,
    required this.biggestWinner,
    required this.biggestLoser,
  });
}