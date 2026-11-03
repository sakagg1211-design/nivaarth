import '../core/utils/symbol_utils.dart';
import '../models/live_market_quote.dart';
import '../models/live_portfolio.dart';
import '../services/market_quote_service.dart';
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
    if (portfolio.isEmpty) return [];

    // Fallback: Fetch Supabase LatestPrices to NEVER silently assume avgPrice
    final dbPricesList = await priceRepository.getPricesFor(
      portfolio.map((s) => SymbolUtils.normalize(s.instrument)).toSet().toList(),
    );
    final dbPrices = {
      for (final p in dbPricesList) SymbolUtils.normalize(p.instrument): p,
    };

    // Live quotes in batches (a pull-to-refresh has just fetched them; the 45 s cache serves them)
    final Map<String, LiveMarketQuote> quoteMap =
        await MarketQuoteService.instance.fetchMany(portfolio.map((s) => s.instrument));

    return portfolio.map((stock) {
      final clean = SymbolUtils.normalize(stock.instrument);
      final quote = quoteMap[clean];
      final dbPrice = dbPrices[clean];

      final double? livePrice = (quote != null && quote.currentPrice > 0)
          ? quote.currentPrice
          : null;
      // Stale = not refreshed now: no quote, the database fallback, or an older kept quote
      final bool isStale = livePrice == null || !quote!.isFresh;

      final double currentPrice = livePrice ??
          ((dbPrice != null && dbPrice.currentPrice > 0)
              ? dbPrice.currentPrice
              : 0.0);

      final bool isPriceUnavailable = currentPrice == 0.0;

      final double currentValue = currentPrice * stock.qty;
      final double netPL = isPriceUnavailable
          ? 0.0
          : (currentValue - stock.totalInvested);
      final double returnPercent = (stock.totalInvested == 0 || isPriceUnavailable)
          ? 0.0
          : (netPL / stock.totalInvested) * 100.0;

      // Previous close: the quote's (NSE bhavcopy close where available, see
      // LiveMarketQuote.withOfficialPreviousClose), else LatestPrices
      final double prevClose = (quote != null && quote.currentPrice > 0 && quote.previousClose > 0)
          ? quote.previousClose
          : (dbPrice != null && dbPrice.previousClose > 0
              ? dbPrice.previousClose
              : currentPrice);

      final double dayPointChange = (currentPrice > 0 && prevClose > 0 && !isPriceUnavailable)
          ? (currentPrice - prevClose)
          : 0.0;

      final double todayPL = dayPointChange * stock.qty;
      final double todayReturnPercent = (prevClose > 0 && !isPriceUnavailable)
          ? (dayPointChange / prevClose) * 100.0
          : 0.0;

      return LivePortfolio(
        portfolio: stock,
        currentPrice: currentPrice,
        currentValue: currentValue,
        netPL: netPL,
        returnPercent: returnPercent,
        todayPL: todayPL,
        todayReturnPercent: todayReturnPercent,
        isStale: isStale,
        isPriceUnavailable: isPriceUnavailable,
        priceTime: isPriceUnavailable
            ? null
            : (livePrice == null ? dbPrice?.lastUpdated : quote?.timestamp),
        fetchedAt: isStale ? null : quote.fetchedAt,
      );
    }).toList();
  }
}