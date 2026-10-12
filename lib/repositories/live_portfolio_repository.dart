import '../models/live_portfolio.dart';
import 'portfolio_repository.dart';
import 'price_repository.dart';

class LivePortfolioRepository {
  final PortfolioRepository portfolioRepository;
  final PriceRepository priceRepository;

  LivePortfolioRepository({
    required this.portfolioRepository,
    required this.priceRepository,
  });

  Future<List<LivePortfolio>> getPortfolio() async {
    final portfolio = await portfolioRepository.getPortfolio();
    final prices = await priceRepository.getPrices();

    // Price & Previous Close Maps
    final Map<String, double> priceMap = {};
    final Map<String, double> prevCloseMap = {};

    for (final price in prices) {
      final sym = price.instrument.trim().toUpperCase();
      priceMap[sym] = price.currentPrice;
      prevCloseMap[sym] = price.previousClose > 0 ? price.previousClose : price.currentPrice;
    }

    return portfolio.map((stock) {
      final key =
          stock.instrument.trim().toUpperCase();

      final double currentPrice =
          priceMap[key] ?? 0.0;

      final double currentValue =
          currentPrice * stock.qty;

      final double netPL =
          currentValue - stock.totalInvested;

      final double returnPercent =
          stock.totalInvested == 0
              ? 0.0
              : (netPL / stock.totalInvested) * 100.0;

      final double prevClose = prevCloseMap[key] ?? currentPrice;
      final double todayPL = prevClose > 0
          ? (currentPrice - prevClose) * stock.qty
          : 0.0;
      final double todayReturnPercent = prevClose > 0
          ? ((currentPrice - prevClose) / prevClose) * 100.0
          : 0.0;

      return LivePortfolio(
        portfolio: stock,
        currentPrice: currentPrice,
        currentValue: currentValue,
        netPL: netPL,
        returnPercent: returnPercent,
        todayPL: todayPL,
        todayReturnPercent: todayReturnPercent,
      );
    }).toList();
  }
}