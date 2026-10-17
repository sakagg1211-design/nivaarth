import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/symbol_utils.dart';
import '../models/stock_score.dart';
import '../models/watchlist_item.dart';

class WatchlistNotifier extends StateNotifier<List<WatchlistItem>> {
  static const String _localKey = 'nivaarth_local_watchlist_v1';
  final SupabaseClient _supabase = Supabase.instance.client;

  WatchlistNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    // 1. Instant Local Disk Restore (Survives app kill/recent tasks)
    await _loadFromLocal();
    // 2. Multi-user Cloud Sync from Supabase
    await loadCloudWatchlist();
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_localKey);
      if (list != null && list.isNotEmpty) {
        final items = list.map((str) {
          final json = jsonDecode(str) as Map<String, dynamic>;
          return WatchlistItem.fromJson(json);
        }).toList();
        if (items.isNotEmpty) {
          state = items;
        }
      }
    } catch (_) {}
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = state.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(_localKey, list);
    } catch (_) {}
  }

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
          return WatchlistItem.fromJson(json as Map<String, dynamic>);
        }).toList();

        if (loaded.isNotEmpty) {
          // Merge unique items from cloud into local state
          final existingSymbols = state.map((e) => SymbolUtils.normalize(e.instrument)).toSet();
          final newFromCloud = loaded.where((e) => !existingSymbols.contains(SymbolUtils.normalize(e.instrument))).toList();
          if (newFromCloud.isNotEmpty) {
            state = [...state, ...newFromCloud];
            _saveToLocal();
          }
        }
      }
    } catch (_) {
      // Offline or table pending migration, local state remains fully preserved
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
    _saveToLocal();
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
    _saveToLocal();
    _syncAddToCloud(newItem);
    return true;
  }

  void remove(String symbol) {
    final norm = SymbolUtils.normalize(symbol);
    state = state.where((item) => SymbolUtils.normalize(item.instrument) != norm).toList();
    _saveToLocal();
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
