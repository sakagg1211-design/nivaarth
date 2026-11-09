import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/allocation_math.dart';
import '../core/utils/investment_style.dart';
import '../models/peer_comparison.dart';
import '../repositories/listing_repository.dart';
import 'live_portfolio_provider.dart';

/// The user's holdings on the style grid. Null until the nightly style table has been filled.
final investmentStyleProvider = FutureProvider.autoDispose<StyleGrid?>((ref) async {
  final holdings = await ref.watch(livePortfolioProvider.future);
  final priced = holdings.where((h) => !h.isPriceUnavailable && h.currentValue > 0).toList();
  if (priced.isEmpty) return null;
  final symbols = priced.map((h) => h.portfolio.instrument.trim().toUpperCase()).toSet().toList();

  final client = Supabase.instance.client;
  final styles = <String, Map<String, dynamic>>{};
  for (var i = 0; i < symbols.length; i += 200) {
    final part = symbols.sublist(i, i + 200 > symbols.length ? symbols.length : i + 200);
    final rows = await client.from('StockStyle').select('Instrument,cap_tier,style,growth_rank,value_rank').inFilter('Instrument', part);
    for (final r in rows) {
      styles[r['Instrument'].toString().toUpperCase()] = Map<String, dynamic>.from(r as Map);
    }
  }
  if (styles.isEmpty) return null;
  final sectors = await ListingRepository().sectorsFor(symbols);

  return StyleGrid.build([
    for (final h in priced)
      () {
        final s = h.portfolio.instrument.trim().toUpperCase();
        final row = styles[s];
        final isFund = sectors[s] == AllocationMath.etf;
        return StyleStock(
          s,
          h.currentValue,
          row?['cap_tier']?.toString() ?? '',
          isFund ? StyleGrid.fund : (row?['style']?.toString() ?? StyleGrid.notClassified),
          growthRank: numOrNull(row?['growth_rank']),
          valueRank: numOrNull(row?['value_rank']),
        );
      }(),
  ]);
});
