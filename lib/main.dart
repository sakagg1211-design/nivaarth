import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();
  final savedLocale = await LocaleNotifier.loadSaved();

  runApp(
    ProviderScope(
      overrides: [localeProvider.overrideWith((ref) => LocaleNotifier(savedLocale))],
      child: const NivaarthApp(),
    ),
  );
}

class NivaarthApp extends ConsumerWidget {
  final Widget home;
  const NivaarthApp({super.key, this.home = const SplashScreen()});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NIVAARTH',
      theme: AppTheme.darkTheme,
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    );
  }
}
