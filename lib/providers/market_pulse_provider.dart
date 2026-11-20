import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/market_hours.dart';
import '../core/utils/market_pulse.dart';
import '../repositories/listing_repository.dart';

/// Whether NSE is open now; a provider so screens and tests read the same answer.
final marketOpenProvider = Provider<bool>((ref) => isMarketOpenIst(DateTime.now().toUtc()));

/// Index cards, Nifty 50 movers and market mood. Refreshes every 5 minutes in market hours.
final marketPulseProvider = FutureProvider.autoDispose<MarketPulse?>((ref) async {
  final now = DateTime.now().toUtc();
  if (isMarketOpenIst(now)) {
    final timer = Timer(const Duration(minutes: 5), ref.invalidateSelf);
    ref.onDispose(timer.cancel);
  }
  final db = Supabase.instance.client;
  Future<List<Map<String, dynamic>>> rows(Future<dynamic> Function() q) async {
    try {
      return ((await q()) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return const [];
    }
  }

  final members = {
    for (final r in await rows(() => db.from('IndexMembers').select('Instrument').eq('index_name', 'NIFTY 50')))
      r['Instrument'].toString().toUpperCase(),
  };
  final latest = await rows(() => db
      .from('LatestPrices')
      .select('Instrument,CurrentPrice,PreviousClose,LastUpdated')
      .inFilter('Instrument', [...indexOrder, ...members]));
  final intraday = await rows(
      () => db.from('IntradayPrices').select('Instrument,ts,price').inFilter('Instrument', indexOrder).order('ts'));
  final breadth = await rows(() => db.from('MarketBreadth').select('trade_date,advances,declines').order('trade_date', ascending: false).limit(1));
  Map<String, String> sectors = const {};
  try {
    sectors = await ListingRepository().sectorsFor(members.toList());
  } catch (_) {}
  return buildMarketPulse(
    latest: latest,
    nifty50: members,
    intraday: intraday,
    sectors: sectors,
    now: now,
    breadthRow: breadth.isEmpty ? null : breadth.first,
  );
});
