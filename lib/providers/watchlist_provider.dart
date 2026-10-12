import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/symbol_utils.dart';
import '../models/stock_score.dart';
import '../models/watchlist_item.dart';

class WatchlistNotifier extends StateNotifier<List<WatchlistItem>> {
  WatchlistNotifier() : super([]) {
    loadCloudWatchlist();
  }

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> loadCloudWatchlist() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('Watchlists')
          .select()
          .eq('user_id', user.id);

      if (response != null && response is List && response.isNotEmpty) {
        final loaded = response.map((json) {
          return WatchlistItem(
            instrument: json['instrument']?.toString() ?? '',
            companyName: json['company_name']?.toString() ?? '',
            score: (json['score'] as num?)?.toInt() ?? 78,
            addedPrice: (json['added_price'] as num?)?.toDouble() ?? 0.0,
            latestPrice: (json['latest_price'] as num?)?.toDouble() ?? 0.0,
            dayChangePercent: (json['day_change_percent'] as num?)?.toDouble() ?? 0.0,
            volume: json['volume']?.toString() ?? '145.2 k',
            returnPercent: (json['return_percent'] as num?)?.toDouble() ?? 0.0,
            trackedDate: json['tracked_date']?.toString() ?? 'Today',
            technicalTag: json['technical_tag']?.toString() ?? 'BUY',
            keyTakeaway: json['key_takeaway']?.toString() ?? 'Active monitored watchlist asset',
          );
        }).toList();

        if (loaded.isNotEmpty) {
          state = loaded;
        }
      }
    } catch (_) {
      // Table may not exist yet or offline, state remains in-memory
    }
  }

  bool isSaved(String symbol) {
    final norm = SymbolUtils.normalize(symbol);
    return state.any((item) => SymbolUtils.normalize(item.instrument) == norm);
  }

  bool addStock(StockScore stock, {double? customPrice}) {
    final sym = SymbolUtils.normalize(stock.instrument);
    if (isSaved(sym)) return false;

    final price = customPrice ?? SymbolUtils.getEstimatedPrice(sym);
    final compName = stock.companyName.isNotEmpty &&
            stock.companyName.toUpperCase() != sym
        ? stock.companyName
        : SymbolUtils.getDisplayName(sym);

    final sector = SymbolUtils.getSector(sym);
    final String tag;
    final String takeaway;
    if (stock.overallScore >= 85) {
      tag = 'STRONG BUY';
      takeaway = 'Market leader in $sector with resilient operating margins & robust ROE.';
    } else if (stock.overallScore >= 78) {
      tag = 'ACCUMULATE';
      takeaway = 'Steady compounding in $sector; healthy quarterly volume & earnings support.';
    } else if (stock.overallScore >= 68) {
      tag = 'CONSOLIDATING';
      takeaway = 'Trading within fair valuation band in $sector; monitor margin expansion.';
    } else if (stock.overallScore >= 58) {
      tag = 'CAUTION';
      takeaway = 'Elevated leverage or cyclical contraction; wait for price stabilization.';
    } else {
      tag = 'AVOID';
      takeaway = 'Weak fundamental scoring with elevated downside risk profile.';
    }

    final newItem = WatchlistItem(
      instrument: sym,
      companyName: compName,
      score: stock.overallScore,
      addedPrice: price,
      latestPrice: price,
      dayChangePercent: 0.85,
      volume: '154.2 k',
      returnPercent: 0.0,
      trackedDate: 'Today',
      technicalTag: tag,
      keyTakeaway: takeaway,
    );

    state = [...state, newItem];
    _syncAddToCloud(newItem);
    return true;
  }

  bool addBySymbol({
    required String symbol,
    required String companyName,
    required double price,
    int score = 78,
    String tag = 'BUY',
  }) {
    final sym = SymbolUtils.normalize(symbol);
    if (isSaved(sym)) return false;

    final sector = SymbolUtils.getSector(sym);
    final String computedTag;
    final String takeaway;
    if (score >= 85) {
      computedTag = 'STRONG BUY';
      takeaway = 'High conviction leader in $sector. Strong balance sheet & institutional backing.';
    } else if (score >= 78) {
      computedTag = 'ACCUMULATE';
      takeaway = 'Positive multi-quarter momentum in $sector; attractive accumulation zone.';
    } else if (score >= 68) {
      computedTag = 'RANGE BOUND';
      takeaway = 'Consolidating above support levels in $sector; watchful accumulation.';
    } else if (score >= 58) {
      computedTag = 'CAUTION';
      takeaway = 'Elevated volatility or margin compression; wait for clear breakout confirmation.';
    } else {
      computedTag = 'AVOID';
      takeaway = 'Sub-optimal financial metrics with high downside drawdown risk.';
    }

    final newItem = WatchlistItem(
      instrument: sym,
      companyName: companyName.isNotEmpty ? companyName : SymbolUtils.getDisplayName(sym),
      score: score,
      addedPrice: price,
      latestPrice: price,
      dayChangePercent: 0.85,
      volume: '154.2 k',
      returnPercent: 0.0,
      trackedDate: 'Today',
      technicalTag: computedTag,
      keyTakeaway: takeaway,
    );

    state = [...state, newItem];
    _syncAddToCloud(newItem);
    return true;
  }

  void remove(String symbol) {
    final norm = SymbolUtils.normalize(symbol);
    state = state.where((item) => SymbolUtils.normalize(item.instrument) != norm).toList();
    _syncRemoveFromCloud(norm);
  }

  void toggle(StockScore stock, {double? price}) {
    final sym = SymbolUtils.normalize(stock.instrument);
    if (isSaved(sym)) {
      remove(sym);
    } else {
      addStock(stock, customPrice: price);
    }
  }

  Future<void> _syncAddToCloud(WatchlistItem item) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('Watchlists').upsert({
        'user_id': user.id,
        'instrument': item.instrument,
        'company_name': item.companyName,
        'score': item.score,
        'added_price': item.addedPrice,
        'latest_price': item.latestPrice,
        'day_change_percent': item.dayChangePercent,
        'volume': item.volume,
        'return_percent': item.returnPercent,
        'tracked_date': item.trackedDate,
        'technical_tag': item.technicalTag,
        'key_takeaway': item.keyTakeaway,
      });
    } catch (_) {}
  }

  Future<void> _syncRemoveFromCloud(String normSymbol) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase
          .from('Watchlists')
          .delete()
          .eq('user_id', user.id)
          .eq('instrument', normSymbol);
    } catch (_) {}
  }
}

final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, List<WatchlistItem>>((ref) {
  return WatchlistNotifier();
});
