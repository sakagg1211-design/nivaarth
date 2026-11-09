import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_alert.dart';
import '../services/backend_service.dart';
import 'live_portfolio_provider.dart';
import '../l10n/app_localizations.dart';
import 'locale_provider.dart';

final alertsProvider = StateNotifierProvider<AlertsNotifier, AsyncValue<List<UserAlert>>>((ref) {
  return AlertsNotifier(ref);
});

class AlertsNotifier extends StateNotifier<AsyncValue<List<UserAlert>>> {
  final Ref ref;
  final BackendService _backendService = BackendService();

  Timer? _reload;

  AlertsNotifier(this.ref) : super(const AsyncValue.loading()) {
    ref.listen(localeProvider, (_, _) => fetchAlerts());
    fetchAlerts();
    // Price alerts are checked every 5 minutes, so an open app looks on the same beat
    _reload = Timer.periodic(const Duration(minutes: 5), (_) => fetchAlerts());
  }

  @override
  void dispose() {
    _reload?.cancel();
    super.dispose();
  }

  String _getReadStorageKey() {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    return uid != null ? 'nivaarth_read_alerts_$uid' : 'nivaarth_read_alerts_guest';
  }

  Future<Set<String>> _getReadAlertIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_getReadStorageKey()) ?? [];
      return list.toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveReadAlertId(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getReadStorageKey();
      final list = prefs.getStringList(key) ?? [];
      if (!list.contains(id)) {
        list.add(id);
        await prefs.setStringList(key, list);
      }
    } catch (_) {}
  }

  Future<void> _saveAllReadAlertIds(List<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getReadStorageKey();
      final list = prefs.getStringList(key) ?? [];
      final set = list.toSet()..addAll(ids);
      await prefs.setStringList(key, set.toList());
    } catch (_) {}
  }

  Future<void> fetchAlerts() async {
    final t = lookupAppLocalizations(ref.read(localeProvider));
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final userId = user?.id;

      // 1. Try Supabase UserAlerts table
      List<UserAlert> alerts = [];
      if (userId != null) {
        try {
          final res = await Supabase.instance.client
              .from('UserAlerts')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false);

          if (res.isNotEmpty) {
            alerts = res.map((item) => UserAlert.fromJson(item)).toList();
          }
        } catch (_) {
          // Table might not exist yet; gracefully fallback
        }
      }

      // 2. Smart alerts from the backend, alongside any stored ones (a triggered price alert
      // is a stored row and must not hide them)
      try {
        final backendAlerts = await _backendService.getSmartAlerts();
        alerts = [...alerts, ...backendAlerts.map((item) => UserAlert.fromJson(item))];
      } catch (_) {}

      // 3. Fallback: Synthesize local smart alerts from user's live holdings
      if (alerts.isEmpty) {
        final portfolioAsync = ref.read(livePortfolioProvider);
        final holdings = portfolioAsync.valueOrNull ?? [];

        if (holdings.isNotEmpty) {
          double totalVal = 0.0;
          for (final h in holdings) {
            totalVal += h.currentValue;
          }

          for (final h in holdings) {
            final weight = totalVal > 0 ? (h.currentValue / totalVal * 100) : 0.0;
            if (weight > 25.0 && holdings.length > 1) {
              alerts.add(UserAlert(
                id: 'local_conc_${h.portfolio.instrument}',
                title: t.alertWeightTitle(h.portfolio.instrument),
                message: t.alertWeightBody(h.portfolio.instrument, weight.toStringAsFixed(1)),
                type: AlertType.portfolioRisk,
                severity: AlertSeverity.warning,
                symbol: h.portfolio.instrument,
                isRead: false,
                createdAt: DateTime.now(),
              ));
            }
          }

          alerts.insert(
            0,
            UserAlert(
              id: 'local_health_active',
              title: t.alertChecksTitle,
              message: t.alertChecksBody(holdings.length),
              type: AlertType.system,
              severity: AlertSeverity.info,
              isRead: false,
              createdAt: DateTime.now(),
            ),
          );
        } else {
          alerts.add(
            UserAlert(
              id: 'local_welcome',
              title: t.dashWelcome,
              message: t.alertWelcomeBody,
              type: AlertType.system,
              severity: AlertSeverity.info,
              isRead: false,
              createdAt: DateTime.now(),
            ),
          );
        }
      }

      // 4. Map persistent read state from local storage
      final readIds = await _getReadAlertIds();
      final mappedAlerts = alerts.map((a) {
        if (readIds.contains(a.id)) {
          return a.copyWith(isRead: true);
        }
        return a;
      }).toList();

      if (mounted) state = AsyncValue.data(mappedAlerts);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  void markAsRead(String id) {
    _saveReadAlertId(id);

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null && !id.startsWith('local_')) {
      Supabase.instance.client
          .from('UserAlerts')
          .update({'is_read': true})
          .eq('id', id)
          .catchError((_) {});
    }

    state.whenData((list) {
      state = AsyncValue.data(
        list.map((a) => a.id == id ? a.copyWith(isRead: true) : a).toList(),
      );
    });
  }

  void markAllAsRead() {
    state.whenData((list) {
      final ids = list.map((a) => a.id).toList();
      _saveAllReadAlertIds(ids);

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        Supabase.instance.client
            .from('UserAlerts')
            .update({'is_read': true})
            .eq('user_id', user.id)
            .catchError((_) {});
      }

      state = AsyncValue.data(
        list.map((a) => a.copyWith(isRead: true)).toList(),
      );
    });
  }

  void clearAll() {
    state = const AsyncValue.data([]);
  }
}
