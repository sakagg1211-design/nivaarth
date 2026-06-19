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

    // Price Map
    final Map<String, double> priceMap = {};

    for (final price in prices) {
      priceMap[price.instrument.trim().toUpperCase()] =
          price.currentPrice;
    }

    // ===========================
    // DEBUG (Temporary)
    // ===========================

    print("========== PRICE MAP ==========");
    print(priceMap);

    // ===========================

    return portfolio.map((stock) {
      final key =
          stock.instrument.trim().toUpperCase();

      final double currentPrice =
          priceMap[key] ?? 0.0;

      print(
        "Stock : $key  ->  Price : $currentPrice",
      );

      final double currentValue =
          currentPrice * stock.qty;

      final double netPL =
          currentValue - stock.totalInvested;

      final double returnPercent =
          stock.totalInvested == 0
              ? 0.0
              : (netPL / stock.totalInvested) * 100.0;

      return LivePortfolio(
        portfolio: stock,
        currentPrice: currentPrice,
        currentValue: currentValue,
        netPL: netPL,
        returnPercent: returnPercent,
      );
    }).toList();
  }
}