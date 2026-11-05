import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/corporate_action_math.dart';
import '../core/utils/formatters.dart';
import '../providers/dashboard_provider.dart';
import '../providers/live_portfolio_provider.dart';
import '../providers/portfolio_provider.dart';
import '../providers/privacy_provider.dart';
import '../repositories/portfolio_repository.dart';
import '../repositories/trade_repository.dart';

/// Bonus/split events after a holding's trades: the app asks, the user confirms (decided 5 Nov
/// 2026). "Haan" adds the extra shares as a price-0 BUY (source CORP_ACT, broker trade id = the
/// event id, so it is never added twice); "Nahi" is remembered on this device.
class CorporateActionPrompt {
  CorporateActionPrompt._();
  static const broker = 'Corporate action';
  static bool _checkedThisSession = false;

  static String _declinedKey(String userId) => 'corp_action_declined_$userId';

  static Future<void> checkOnce(BuildContext context, WidgetRef ref) async {
    if (_checkedThisSession) return;
    _checkedThisSession = true;
    try {
      await _check(context, ref);
    } catch (_) {
      // Before migration 20 there is no CorporateActions table; nothing to ask
    }
  }

  static Future<void> _check(BuildContext context, WidgetRef ref) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;
    final holdings = await PortfolioRepository().getPortfolio();
    if (holdings.isEmpty) return;
    final symbols = holdings.map((h) => h.instrument.toUpperCase()).toSet().toList();
    final rows = await client.from('CorporateActions').select().inFilter('Instrument', symbols);
    final actions = rows.map((r) => CorporateAction.fromJson(Map<String, dynamic>.from(r as Map))).toList();
    if (actions.isEmpty) return;

    final trades = TradeRepository();
    final all = await trades.getAllTrades();
    final applied = await trades.importedTradeIds(broker);
    final prefs = await SharedPreferences.getInstance();
    final declined = (prefs.getStringList(_declinedKey(user.id)) ?? const <String>[]).toSet();

    final pending = <PendingAdjustment>[];
    for (final sym in symbols) {
      final mine = actions.where((a) => a.instrument == sym).toList();
      if (mine.isEmpty) continue;
      pending.addAll(CorporateActionMath.pending(
        all.where((t) => t.instrument.toUpperCase() == sym).toList(),
        mine,
        appliedIds: applied,
        declinedIds: declined,
      ));
    }

    var changed = false;
    for (final p in pending) {
      if (!context.mounted) break;
      final yes = await _ask(context, p, ref.read(privacyModeProvider));
      if (yes == true) {
        await trades.addCorporateAction(
          instrument: p.action.instrument,
          extraShares: p.extraShares,
          exDate: p.action.exDate,
          eventId: p.action.id,
          note: '${p.action.label} x${p.action.multiplier}',
        );
        changed = true;
      } else if (yes == false) {
        declined.add(p.action.id);
        await prefs.setStringList(_declinedKey(user.id), declined.toList());
      }
    }
    if (changed) {
      ref.invalidate(portfolioProvider);
      ref.invalidate(livePortfolioProvider);
      ref.invalidate(dashboardProvider);
    }
  }

  /// true = add, false = no (remembered), null = later (asked again next time)
  static Future<bool?> _ask(BuildContext context, PendingAdjustment p, bool hide) {
    String money(double v) => hide ? '••••' : Formatters.currency(v);
    String q(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
    final a = p.action;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2024),
        title: Text('${a.instrument}: ${a.label} aaya', style: const TextStyle(color: Colors.white, fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ex-date ${DateFormat('d MMM yyyy').format(a.exDate)}: har 1 share par ab ${q(a.multiplier)} shares. '
              'Us din aapke paas ${q(p.sharesBefore)} shares the, to ${p.extraShares} naye shares (₹0 par) judenge.',
              style: const TextStyle(color: Color(0xFFB0B4BC), fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text('Abhi: ${q(p.now.qty)} shares @ ${money(p.now.avgPrice)}',
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            Text('Update ke baad: ${q(p.after.qty)} shares @ ${money(p.after.avgPrice)}',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            Text('Invested wahi rahega: ${money(p.after.totalInvested)}',
                style: const TextStyle(color: Color(0xFF8E929B), fontSize: 12)),
            if (p.fractionDropped) ...[
              const SizedBox(height: 8),
              const Text('Adhoora share nahi joda: broker uske badle paise deta hai.',
                  style: TextStyle(color: Color(0xFFFFB74D), fontSize: 12)),
            ],
            const SizedBox(height: 8),
            const Text('Broker app me shares ki ginti se mila lo. Galat ho to baad me Trade book se hata sakte ho.',
                style: TextStyle(color: Color(0xFF6B6F78), fontSize: 11)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Baad me')),
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Nahi')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Haan, jodo')),
        ],
      ),
    );
  }
}
