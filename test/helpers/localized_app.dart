import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/providers/locale_provider.dart';

Widget localizedApp({required Widget home, Locale locale = englishLocale, ThemeData? theme}) => MaterialApp(
      locale: locale,
      theme: theme,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    );
