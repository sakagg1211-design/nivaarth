import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stock_score.dart';
import 'stock_provider.dart';

final searchProvider = FutureProvider.family<List<StockScore>, String>((
  ref,
  query,
) async {
  final trimmedQuery = query.trim();

  if (trimmedQuery.isEmpty) {
    return <StockScore>[];
  }

  final repository = ref.read(stockRepositoryProvider);

  return repository.searchStocks(trimmedQuery);
});
