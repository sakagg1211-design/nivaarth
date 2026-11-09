import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/performance_series.dart';
import 'live_portfolio_provider.dart';

final performanceFetchProvider = Provider<Future<List<Map<String, dynamic>>> Function()>(
  (ref) => () async {
    final rows = await Supabase.instance.client.rpc('portfolio_performance');
    return (rows as List).cast<Map<String, dynamic>>();
  },
);

final portfolioPerformanceProvider = FutureProvider.autoDispose<PerformanceSeries?>((ref) async {
  // Holdings and quantities only: the series is end-of-day, so a price refresh must not refetch it
  final holdings = ref.watch(livePortfolioProvider.select((a) =>
      a.valueOrNull?.map((h) => '${h.portfolio.instrument}:${h.portfolio.qty}').join(',')));
  if (holdings == null || holdings.isEmpty) return null;
  return PerformanceSeries.fromRows(await ref.watch(performanceFetchProvider)());
});
