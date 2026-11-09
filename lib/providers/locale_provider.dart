import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const englishLocale = Locale('en');
// en_IN carries Hinglish: Flutter's own widgets stay English, which a Hindi locale would not
const hinglishLocale = Locale('en', 'IN');

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) => LocaleNotifier());

class LocaleNotifier extends StateNotifier<Locale> {
  static const _prefsKey = 'app_language';

  LocaleNotifier([super.initial = englishLocale]);

  /// Read before the first frame so a saved Hinglish choice never flashes English.
  static Future<Locale> loadSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefsKey) == 'en_IN' ? hinglishLocale : englishLocale;
    } catch (_) {
      return englishLocale;
    }
  }

  Future<void> set(Locale locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, locale == hinglishLocale ? 'en_IN' : 'en');
    } catch (_) {}
  }
}
