import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/account_value.dart';
import '../core/utils/market_hours.dart';
import 'live_portfolio_provider.dart';

final accountHistoryFetchProvider = Provider<Future<List<Map<String, dynamic>>> Function()>(
  (ref) => () async {
    final rows = await Supabase.instance.client.rpc('account_value_history');
    return (rows as List).cast<Map<String, dynamic>>();
  },
);

/// Today's (IST) 5-minute prices for [symbols]. Older rows stay until the first run of the next
/// trading day, so the date filter keeps yesterday's line from showing as today.
final intradayFetchProvider = Provider<Future<List<Map<String, dynamic>>> Function(List<String> symbols)>(
  (ref) => (symbols) async {
    if (symbols.isEmpty) return const [];
    final since = istDayStartUtc(DateTime.now().toUtc()).toIso8601String();
    return fetchAllPages((from, to) async {
      final rows = await Supabase.instance.client
          .from('IntradayPrices')
          .select('Instrument,ts,price')
          .inFilter('Instrument', symbols)
          .gte('ts', since)
          .order('ts')
          .order('Instrument')
          .range(from, to);
      return (rows as List).cast<Map<String, dynamic>>();
    });
  },
);

final accountHistoryProvider = FutureProvider.autoDispose<AccountHistory?>((ref) async {
  // Holdings and quantities only: the history is end-of-day, so a price refresh must not refetch it
  final holdings = ref.watch(livePortfolioProvider.select((a) =>
      a.valueOrNull?.map((h) => '${h.portfolio.instrument}:${h.portfolio.qty}').join(',')));
  if (holdings == null || holdings.isEmpty) return null;
  return AccountHistory.fromRows(await ref.watch(accountHistoryFetchProvider)());
});

class AccountToday {
  final List<ValuePoint> line;
  final double value;
  final double prevClose;
  final double invested;
  final HourChange? hour;
  const AccountToday(this.line, this.value, this.prevClose, this.invested, [this.hour]);
}

final accountTodayProvider = FutureProvider.autoDispose<AccountToday?>((ref) async {
  final holdings = (await ref.watch(livePortfolioProvider.future))
      .where((h) => !h.isPriceUnavailable && h.portfolio.qty > 0)
      .toList();
  if (holdings.isEmpty) return null;
  if (isMarketOpenIst(DateTime.now().toUtc())) {
    final timer = Timer(const Duration(minutes: 5), ref.invalidateSelf);
    ref.onDispose(timer.cancel);
  }
  final qty = {for (final h in holdings) h.portfolio.instrument.trim().toUpperCase(): h.portfolio.qty};
  final value = holdings.fold<double>(0, (a, h) => a + h.currentValue);
  final invested = holdings.fold<double>(0, (a, h) => a + h.portfolio.totalInvested);
  final prevClose = holdings.fold<double>(0, (a, h) => a + h.currentValue - h.todayPL);
  List<Map<String, dynamic>> rows;
  try {
    rows = await ref.watch(intradayFetchProvider)(qty.keys.toList());
  } catch (_) {
    rows = const [];
  }
  return AccountToday(intradayLine(qty: qty, rows: rows, invested: invested), value, prevClose, invested, lastHour(qty: qty, rows: rows));
});
