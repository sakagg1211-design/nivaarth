import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/price_alert.dart';

class PriceAlertRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<PriceAlert>> active() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return const [];
    final rows = await _client
        .from('PriceAlerts')
        .select('id,Instrument,direction,target_price')
        .eq('user_id', uid)
        .eq('status', 'ACTIVE')
        .order('created_at', ascending: false);
    return rows.map((r) => PriceAlert.fromJson(r)).toList();
  }

  Future<void> add(String instrument, String direction, double target) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('Not signed in');
    await _client.from('PriceAlerts').insert({
      'user_id': uid,
      'Instrument': instrument.trim().toUpperCase(),
      'direction': direction,
      'target_price': target,
    });
  }

  Future<void> remove(String id) => _client.from('PriceAlerts').delete().eq('id', id);
}

final priceAlertRepositoryProvider = Provider((ref) => PriceAlertRepository());

/// The signed-in user's alerts that have not fired yet.
final activePriceAlertsProvider = FutureProvider.autoDispose<List<PriceAlert>>((ref) {
  return ref.watch(priceAlertRepositoryProvider).active();
});
