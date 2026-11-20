import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/account_value.dart';
import '../core/utils/today_facts.dart';
import '../repositories/listing_repository.dart';
import 'account_value_provider.dart';
import 'live_portfolio_provider.dart';
import 'market_pulse_provider.dart';
import 'price_alert_provider.dart';

double? _d(Object? v) => v == null ? null : (v is num ? v.toDouble() : double.tryParse(v.toString()));

/// The top 3 facts of today for the Dashboard. Each source is optional: a missing one only
/// removes the facts that need it.
final todayFactsProvider = FutureProvider.autoDispose<List<Fact>>((ref) async {
  final holdings = (await ref.watch(livePortfolioProvider.future))
      .where((h) => h.portfolio.qty > 0 && !h.isPriceUnavailable && h.currentValue > 0)
      .toList();
  if (holdings.isEmpty) return const [];
  final symbols = [for (final h in holdings) h.portfolio.instrument.trim().toUpperCase()];
  final db = Supabase.instance.client;

  var signals = <String, FactSignal>{};
  try {
    final rows = (await db.rpc('holding_signals')) as List;
    signals = {
      for (final r in rows.cast<Map<String, dynamic>>())
        r['Instrument'].toString(): FactSignal(
          high52: _d(r['high_52w']),
          low52: _d(r['low_52w']),
          avgVolume20: _d(r['avg_volume_20']),
          scoreNow: (r['score_now'] as num?)?.toInt(),
          scoreWeekAgo: (r['score_week_ago'] as num?)?.toInt(),
        ),
    };
  } catch (_) {}
  var volumes = <String, double>{};
  try {
    final rows = (await db.from('LatestPrices').select('Instrument,Volume').inFilter('Instrument', symbols)) as List;
    volumes = {for (final r in rows.cast<Map<String, dynamic>>()) if (_d(r['Volume']) != null) r['Instrument'].toString(): _d(r['Volume'])!};
  } catch (_) {}
  var sectors = <String, String>{};
  try {
    sectors = await ListingRepository().sectorsFor(symbols);
  } catch (_) {}
  var alerts = const <FactAlert>[];
  try {
    alerts = [for (final a in await ref.watch(activePriceAlertsProvider.future)) FactAlert(a.instrument.toUpperCase(), a.targetPrice)];
  } catch (_) {}
  double? niftyPct;
  try {
    niftyPct = (await ref.watch(marketPulseProvider.future))?.indices.first.pct;
  } catch (_) {}
  var history = const <ValuePoint>[];
  try {
    history = (await ref.watch(accountHistoryProvider.future))?.points ?? const [];
  } catch (_) {}

  return todayFacts(FactInputs(
    holdings: [
      for (final h in holdings)
        FactHolding(
          symbol: h.portfolio.instrument.trim().toUpperCase(),
          value: h.currentValue,
          todayPct: h.todayReturnPercent,
          price: h.currentPrice,
          volume: volumes[h.portfolio.instrument.trim().toUpperCase()],
          stale: h.isStale,
          sector: sectors[h.portfolio.instrument.trim().toUpperCase()] ?? 'Others',
        ),
    ],
    niftyPct: niftyPct,
    signals: signals,
    alerts: alerts,
    history: history,
    todayValue: holdings.fold<double>(0, (a, h) => a + h.currentValue),
  ));
});
