import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_alert.dart';
import '../services/backend_service.dart';
import 'live_portfolio_provider.dart';

final alertsProvider = StateNotifierProvider<AlertsNotifier, AsyncValue<List<UserAlert>>>((ref) {
  return AlertsNotifier(ref);
});

class AlertsNotifier extends StateNotifier<AsyncValue<List<UserAlert>>> {
  final Ref ref;
  final BackendService _backendService = BackendService();

  AlertsNotifier(this.ref) : super(const AsyncValue.loading()) {
    fetchAlerts();
  }

  Future<void> fetchAlerts() async {
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

          if (res is List && res.isNotEmpty) {
            alerts = res.map((item) => UserAlert.fromJson(item)).toList();
          }
        } catch (_) {
          // Table might not exist yet; gracefully fallback
        }
      }

      // 2. If no alerts from DB, query backend smart alert service
      if (alerts.isEmpty) {
        final backendAlerts = await _backendService.getSmartAlerts(userId: userId);
        if (backendAlerts.isNotEmpty) {
          alerts = backendAlerts.map((item) => UserAlert.fromJson(item)).toList();
        }
      }

      // 3. Fallback: Synthesize local smart alerts from user's live holdings
      if (alerts.isEmpty) {
        final portfolioAsync = ref.read(livePortfolioProvider);
        final holdings = portfolioAsync.value ?? [];

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
                title: 'High Weight: ${h.portfolio.instrument}',
                message: '${h.portfolio.instrument} accounts for ${weight.toStringAsFixed(1)}% of your portfolio. Consider rebalancing.',
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
              title: 'NV Market Guardian Active 🟢',
              message: 'Nivaarth AI is actively tracking your ${holdings.length} portfolio positions in real-time.',
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
              title: 'Welcome to Nivaarth Cockpit',
              message: 'Add your holdings in Portfolio to enable automated AI risk monitoring and price alerts.',
              type: AlertType.system,
              severity: AlertSeverity.info,
              isRead: false,
              createdAt: DateTime.now(),
            ),
          );
        }
      }

      state = AsyncValue.data(alerts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void markAsRead(String id) {
    state.whenData((list) {
      state = AsyncValue.data(
        list.map((a) => a.id == id ? a.copyWith(isRead: true) : a).toList(),
      );
    });
  }

  void markAllAsRead() {
    state.whenData((list) {
      state = AsyncValue.data(
        list.map((a) => a.copyWith(isRead: true)).toList(),
      );
    });
  }

  void clearAll() {
    state = const AsyncValue.data([]);
  }
}
