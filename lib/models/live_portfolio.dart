import 'portfolio.dart';

class LivePortfolio {
  final Portfolio portfolio;

  final double currentPrice;
  final double currentValue;
  final double netPL;
  final double returnPercent;
  final double todayPL;
  final double todayReturnPercent;
  final bool isStale;
  final bool isPriceUnavailable;

  // When the shown price was set: last trade time for a live quote,
  // LatestPrices.LastUpdated for the Supabase fallback.
  final DateTime? priceTime;

  const LivePortfolio({
    required this.portfolio,
    required this.currentPrice,
    required this.currentValue,
    required this.netPL,
    required this.returnPercent,
    this.todayPL = 0.0,
    this.todayReturnPercent = 0.0,
    this.isStale = false,
    this.isPriceUnavailable = false,
    this.priceTime,
  });
}