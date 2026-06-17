import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stock_score.dart';
import '../repositories/stock_repository.dart';

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return StockRepository();
});

final stockScoresProvider =
    FutureProvider<List<StockScore>>((ref) async {
  final repository = ref.read(stockRepositoryProvider);

  return repository.getScores();
});