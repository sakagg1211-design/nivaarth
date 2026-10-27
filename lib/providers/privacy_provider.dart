import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global privacy mode provider.
/// When true, financial values (current value, invested amount, P&L) are masked with bullets.
/// The choice is saved on the device and restored on the next app start.
final privacyModeProvider = StateNotifierProvider<PrivacyModeNotifier, bool>(
  (ref) => PrivacyModeNotifier(),
);

class PrivacyModeNotifier extends StateNotifier<bool> {
  static const _prefsKey = 'privacy_mode_enabled';
  bool _toggledBeforeLoad = false;

  PrivacyModeNotifier() : super(false) {
    _loadFromLocal();
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_prefsKey);
      // A tap during startup wins over the stored value
      if (saved != null && !_toggledBeforeLoad && mounted) {
        state = saved;
      }
    } catch (_) {}
  }

  Future<void> toggle() async {
    _toggledBeforeLoad = true;
    state = !state;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, state);
    } catch (_) {}
  }
}
