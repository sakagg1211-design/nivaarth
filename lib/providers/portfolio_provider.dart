import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/portfolio.dart';
import '../repositories/portfolio_repository.dart';

final portfolioRepositoryProvider =
    Provider<PortfolioRepository>((ref) {
  return PortfolioRepository();
});

final portfolioProvider =
    FutureProvider<List<Portfolio>>((ref) async {
  final repository =
      ref.read(portfolioRepositoryProvider);

  return repository.getPortfolio();
});