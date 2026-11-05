import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/listing_info.dart';
import '../repositories/listing_repository.dart';
import 'portfolio_provider.dart';

/// One stock's listing details (stock page)
final listingInfoProvider = FutureProvider.family<ListingInfo?, String>((ref, symbol) async {
  final map = await ListingRepository().forStocks([symbol]);
  return map[symbol.trim().toUpperCase()];
});

/// Listing details of every held stock in one query (portfolio list badges)
final heldListingProvider = FutureProvider<Map<String, ListingInfo>>((ref) async {
  final holdings = await ref.watch(portfolioProvider.future);
  return ListingRepository().forStocks(holdings.map((h) => h.instrument));
});
