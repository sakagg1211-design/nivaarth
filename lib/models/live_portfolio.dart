import 'portfolio.dart';

class LivePortfolio {
  final Portfolio portfolio;

  final double currentPrice;
  final double currentValue;
  final double netPL;
  final double returnPercent;

  const LivePortfolio({
    required this.portfolio,
    required this.currentPrice,
    required this.currentValue,
    required this.netPL,
    required this.returnPercent,
  });
}