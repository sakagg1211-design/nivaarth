import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stock_score.dart';
import '../repositories/stock_score_repository.dart';

final stockScoreRepositoryProvider =
    Provider<StockScoreRepository>((ref) {
  return StockScoreRepository();
});

final stockScoresProvider =
    FutureProvider<List<StockScore>>((ref) async {
  final repository =
      ref.read(stockScoreRepositoryProvider);

  return repository.getScores();
});

final stockScoreProvider =
    FutureProvider.family<StockScore?, String>(
  (ref, instrument) async {
    final repository =
        ref.read(stockScoreRepositoryProvider);

    return repository.getByInstrument(instrument);
  },
);