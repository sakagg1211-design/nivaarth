import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeChoice { dark, light, phone }

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, AppThemeChoice>((ref) => ThemeModeNotifier());

class ThemeModeNotifier extends StateNotifier<AppThemeChoice> {
  static const _prefsKey = 'app_theme';

  ThemeModeNotifier([super.initial = AppThemeChoice.dark]);

  /// Read before the first frame so a saved light choice never flashes dark.
  static Future<AppThemeChoice> loadSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      return AppThemeChoice.values.firstWhere((c) => c.name == saved, orElse: () => AppThemeChoice.dark);
    } catch (_) {
      return AppThemeChoice.dark;
    }
  }

  Future<void> set(AppThemeChoice choice) async {
    state = choice;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, choice.name);
    } catch (_) {}
  }
}
