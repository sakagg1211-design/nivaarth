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

  // Holdings with no price at all (left out of every total) and holdings
  // priced from the Supabase fallback instead of a live quote.
  final int unpricedStocks;
  final int staleStocks;

  // Oldest price time among priced holdings: the whole total is only as fresh as this
  final DateTime? pricesAsOf;

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
    this.unpricedStocks = 0,
    this.staleStocks = 0,
    this.pricesAsOf,
    required this.healthScore,
    required this.riskScore,
    required this.biggestWinner,
    required this.biggestLoser,
  });
}