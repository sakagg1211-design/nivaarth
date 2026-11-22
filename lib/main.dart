import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_mode_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();
  final savedLocale = await LocaleNotifier.loadSaved();
  // Read before the first frame so a saved light choice never flashes dark
  final savedTheme = await ThemeModeNotifier.loadSaved();

  runApp(
    ProviderScope(
      overrides: [
        localeProvider.overrideWith((ref) => LocaleNotifier(savedLocale)),
        themeModeProvider.overrideWith((ref) => ThemeModeNotifier(savedTheme)),
      ],
      child: const NivaarthApp(),
    ),
  );
}

class NivaarthApp extends ConsumerWidget {
  final Widget home;
  const NivaarthApp({super.key, this.home = const SplashScreen()});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choice = ref.watch(themeModeProvider);
    final light = choice == AppThemeChoice.light ||
        (choice == AppThemeChoice.phone && MediaQuery.platformBrightnessOf(context) == Brightness.light);
    AppColors.isLight = light;
    SystemChrome.setSystemUIOverlayStyle(light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light);
    return MaterialApp(
      // A new key when the mode flips rebuilds the whole app (the navigator keeps a global key, so
      // re-keying only its subtree would not), so every widget reads the new palette; it reopens home
      key: ValueKey(light),
      debugShowCheckedModeBanner: false,
      title: 'NIVAARTH',
      theme: AppTheme.current,
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    );
  }
}
