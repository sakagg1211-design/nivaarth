import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/live_portfolio.dart';
import '../repositories/live_portfolio_repository.dart';
import '../repositories/portfolio_repository.dart';
import '../repositories/price_repository.dart';

final livePortfolioRepositoryProvider =
    Provider<LivePortfolioRepository>((ref) {
  return LivePortfolioRepository(
    portfolioRepository: PortfolioRepository(),
    priceRepository: PriceRepository(),
  );
});

final livePortfolioProvider =
    FutureProvider<List<LivePortfolio>>((ref) async {
  final repository =
      ref.read(livePortfolioRepositoryProvider);

  return repository.getPortfolio();
});