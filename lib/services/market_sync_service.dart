import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/symbol_utils.dart';
import '../providers/dashboard_provider.dart';
import '../providers/live_portfolio_provider.dart';
import '../providers/market_indices_provider.dart';
import '../providers/portfolio_provider.dart';
import '../providers/watchlist_provider.dart';
import 'market_quote_service.dart';

class MarketSyncService {
  MarketSyncService._();
  static final MarketSyncService instance = MarketSyncService._();

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  /// Performs a unified, parallel batch sync of all user-tracked assets
  /// (all Portfolio holdings + all Watchlist stocks) in a single high-performance pipeline.
  Future<void> syncAll(WidgetRef ref) async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // 1. Collect all unique symbols currently tracked by user
      final portfolioList = ref.read(portfolioProvider).value ?? [];
      final watchlistList = ref.read(watchlistProvider);

      final Set<String> symbolsToSync = {};
      for (final p in portfolioList) {
        final clean = SymbolUtils.normalize(p.instrument);
        if (clean.isNotEmpty) symbolsToSync.add(clean);
      }
      for (final w in watchlistList) {
        final clean = SymbolUtils.normalize(w.instrument);
        if (clean.isNotEmpty) symbolsToSync.add(clean);
      }

      // 2. Parallel pre-fetch live quotes across the union
      if (symbolsToSync.isNotEmpty) {
        await Future.wait(
          symbolsToSync.map((sym) => MarketQuoteService.instance.fetchLiveQuote(sym)),
        );
      }

      // 3. Atomically refresh providers using fresh in-memory cached quotes
      await Future.wait([
        ref.refresh(dashboardProvider.future),
        ref.refresh(livePortfolioProvider.future),
        ref.refresh(marketIndicesProvider.future),
        ref.read(watchlistProvider.notifier).refreshWatchlist(),
      ]);
    } catch (_) {
      // Fallback: Individual providers handle partial offline recovery gracefully
    } finally {
      _isSyncing = false;
    }
  }
}
