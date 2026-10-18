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
      final key = stock.instrument.trim().toUpperCase();
      final yfKey = stock.yahooSymbol.trim().toUpperCase();

      // Check both instrument and yahooSymbol in priceMap
      double currentPrice = priceMap[key] ?? priceMap[yfKey] ?? 0.0;

      // If price not yet in LatestPrices, fallback to DB stored currentValue or avgPrice
      if (currentPrice <= 0 && stock.qty > 0 && stock.currentValue != null && stock.currentValue! > 0) {
        currentPrice = stock.currentValue! / stock.qty;
      }
      if (currentPrice <= 0 && stock.avgPrice > 0) {
        currentPrice = stock.avgPrice;
      }

      final double currentValue = currentPrice * stock.qty;

      final double netPL = currentValue - stock.totalInvested;

      final double returnPercent = stock.totalInvested == 0
          ? 0.0
          : (netPL / stock.totalInvested) * 100.0;

      final double prevClose = prevCloseMap[key] ?? currentPrice;
      // If prevClose is available and distinct, compute previous value from it.
      // Otherwise fallback to DB stored currentValue as the previous baseline.
      final double prevStockVal = (prevClose > 0 && prevClose != currentPrice)
          ? (prevClose * stock.qty)
          : ((stock.currentValue != null && stock.currentValue! > 0)
              ? stock.currentValue!
              : currentValue);

      final double todayPL = currentValue - prevStockVal;
      final double todayReturnPercent = prevStockVal > 0
          ? (todayPL / prevStockVal) * 100.0
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