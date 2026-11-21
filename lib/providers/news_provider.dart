import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stock_news.dart';
import '../services/backend_service.dart';

/// "Aaj kyun hila" for one stock (Stock Detail).
final stockNewsProvider = FutureProvider.autoDispose.family<StockNews?, String>(
  (ref, symbol) => BackendService().getStockNews(symbol),
);

/// The dashboard auto-refreshes every 2 minutes; holdings news follows it at most every 15.
bool newsRefreshDue(DateTime last, DateTime now) => now.difference(last) >= const Duration(minutes: 15);

/// Holdings with headlines this session (Dashboard card and Aaj ki baatein counts).
final holdingsNewsProvider = FutureProvider.autoDispose<HoldingsNews?>((ref) => BackendService().getHoldingsNews());
