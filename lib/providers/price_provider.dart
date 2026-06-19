import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/price.dart';
import '../repositories/price_repository.dart';

final priceRepositoryProvider =
    Provider<PriceRepository>((ref) {
  return PriceRepository();
});

final pricesProvider =
    FutureProvider<List<Price>>((ref) async {
  final repository = ref.read(priceRepositoryProvider);

  return repository.getPrices();
});

final singlePriceProvider =
    FutureProvider.family<Price?, String>(
  (ref, instrument) async {
    final repository = ref.read(priceRepositoryProvider);

    return repository.getPrice(instrument);
  },
);