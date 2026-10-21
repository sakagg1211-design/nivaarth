import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/symbol_utils.dart';
import '../models/stock_score.dart';
import '../models/watchlist_item.dart';

class WatchlistNotifier extends StateNotifier<List<WatchlistItem>> {
  String _getLocalKey() {
    final uid = _supabase.auth.currentUser?.id;
    return uid != null ? 'nivaarth_watchlist_$uid' : 'nivaarth_guest_watchlist_v1';
  }

  final SupabaseClient _supabase = Supabase.instance.client;

  WatchlistNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    // 1. Instant Local Disk Restore for current user
    await _loadFromLocal();
    // 2. Multi-user Cloud Sync from Supabase
    await loadCloudWatchlist();
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_getLocalKey());
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
      await prefs.setStringList(_getLocalKey(), list);
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

      if (response.isNotEmpty) {
        final loaded = response.map((json) {
          return WatchlistItem.fromJson(json);
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

  String _formatToday() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  bool addStock(StockScore stock, {double? customPrice, double? dayChangePercent}) {
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
    if (stock.recommendation.isNotEmpty && stock.recommendation != 'PENDING') {
      tag = stock.recommendation;
    } else if (stock.overallScore >= 80) {
      tag = 'STRONG OUTPERFORM';
    } else if (stock.overallScore >= 70) {
      tag = 'OUTPERFORM';
    } else if (stock.overallScore >= 60) {
      tag = 'ACCUMULATE';
    } else if (stock.overallScore >= 45) {
      tag = 'NEUTRAL / HOLD';
    } else if (stock.overallScore >= 35) {
      tag = 'CAUTION';
    } else {
      tag = 'UNDERPERFORM';
    }

    if (stock.overallScore >= 80) {
      takeaway = 'Market leader in $sector with resilient operating margins & robust ROE.';
    } else if (stock.overallScore >= 60) {
      takeaway = 'Steady compounding in $sector; healthy quarterly volume & earnings support.';
    } else if (stock.overallScore >= 45) {
      takeaway = 'Trading within fair valuation band in $sector; monitor margin expansion.';
    } else {
      takeaway = 'Elevated leverage or cyclical contraction; wait for price stabilization.';
    }

    final newItem = WatchlistItem(
      instrument: sym,
      companyName: compName,
      score: stock.overallScore,
      addedPrice: price,
      latestPrice: price,
      dayChangePercent: dayChangePercent ?? 0.0,
      volume: '154.2 k',
      returnPercent: 0.0,
      trackedDate: _formatToday(),
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
    int score = 0,
    String tag = '',
  }) {
    final sym = SymbolUtils.normalize(symbol);
    if (isSaved(sym)) return false;

    final sector = SymbolUtils.getSector(sym);
    final String computedTag;
    final String takeaway;
    if (tag.isNotEmpty && tag != 'BUY' && tag != 'PENDING') {
      computedTag = tag;
    } else if (score >= 80) {
      computedTag = 'STRONG OUTPERFORM';
    } else if (score >= 70) {
      computedTag = 'OUTPERFORM';
    } else if (score >= 60) {
      computedTag = 'ACCUMULATE';
    } else if (score >= 45) {
      computedTag = 'NEUTRAL / HOLD';
    } else if (score >= 35) {
      computedTag = 'CAUTION';
    } else if (score > 0) {
      computedTag = 'UNDERPERFORM';
    } else {
      computedTag = 'MONITORED';
    }

    if (score >= 75) {
      takeaway = 'High conviction leader in $sector. Strong balance sheet & institutional backing.';
    } else if (score >= 60) {
      takeaway = 'Positive multi-quarter momentum in $sector; attractive accumulation zone.';
    } else {
      takeaway = 'Consolidating above support levels in $sector; watchful accumulation.';
    }

    final newItem = WatchlistItem(
      instrument: sym,
      companyName: companyName.isNotEmpty ? companyName : SymbolUtils.getDisplayName(sym),
      score: score,
      addedPrice: price,
      latestPrice: price,
      dayChangePercent: 0.0,
      volume: '154.2 k',
      returnPercent: 0.0,
      trackedDate: _formatToday(),
      technicalTag: computedTag,
      keyTakeaway: takeaway,
    );

    state = [...state, newItem];
    _saveToLocal();
    _syncAddToCloud(newItem);
    return true;
  }

  /// Pull-to-Refresh: Updates live quotes, recalculates return %, and refreshes scores
  Future<void> refreshWatchlist() async {
    if (state.isEmpty) return;

    final updated = <WatchlistItem>[];
    for (final item in state) {
      try {
        final sym = SymbolUtils.normalize(item.instrument);
        double freshPrice = item.latestPrice;
        double changePct = item.dayChangePercent;
        int freshScore = item.score;
        String freshTag = item.technicalTag;

        // 1. Fetch latest price
        try {
          final priceRow = await _supabase
              .from('LatestPrices')
              .select()
              .eq('Instrument', sym)
              .maybeSingle();
          if (priceRow != null) {
            final p = (priceRow['CurrentPrice'] ?? priceRow['price']) as num?;
            if (p != null && p > 0) freshPrice = p.toDouble();
            final ch = (priceRow['ChangePercent'] ?? priceRow['change_percent']) as num?;
            if (ch != null) changePct = ch.toDouble();
          }
        } catch (_) {}

        // 2. Fetch latest authentic score
        try {
          final scoreRow = await _supabase
              .from('StockScores')
              .select()
              .eq('Instrument', sym)
              .maybeSingle();
          if (scoreRow != null) {
            final sc = (scoreRow['OverallScore'] ?? scoreRow['overall_score']) as num?;
            if (sc != null && sc > 0) freshScore = sc.toInt();
            final rec = (scoreRow['Recommendation'] ?? scoreRow['recommendation'])?.toString();
            if (rec != null && rec.isNotEmpty) freshTag = rec;
          }
        } catch (_) {}

        // 3. Authentic Return Calculation: preserve addedPrice, calculate live return
        final retPct = item.addedPrice > 0
            ? ((freshPrice - item.addedPrice) / item.addedPrice) * 100
            : 0.0;

        updated.add(
          WatchlistItem(
            instrument: item.instrument,
            companyName: item.companyName,
            score: freshScore,
            addedPrice: item.addedPrice, // Fixed at entry!
            latestPrice: freshPrice,     // Live price
            dayChangePercent: changePct,
            volume: item.volume,
            returnPercent: retPct,       // Live return
            trackedDate: item.trackedDate.isNotEmpty ? item.trackedDate : _formatToday(),
            technicalTag: freshTag,
            keyTakeaway: item.keyTakeaway,
          ),
        );
      } catch (_) {
        updated.add(item);
      }
    }

    state = updated;
    await _saveToLocal();
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
