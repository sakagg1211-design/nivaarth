import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stock_score.dart';
import 'stock_provider.dart';

final searchProvider =
    FutureProvider.family<List<StockScore>, String>((ref, query) async {
  if (query.trim().isEmpty) {
    return [];
  }

  final repository = ref.read(stockRepositoryProvider);

  return repository.searchStocks(query);
});