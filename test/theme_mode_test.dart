import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/widgets/theme_switcher.dart';
import 'helpers/localized_app.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/providers/theme_mode_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() => AppColors.isLight = false);

  test('dark palette keeps today\'s values; light uses the spec palette', () {
    AppColors.isLight = false;
    expect(AppColors.background, const Color(0xFF0C0D10));
    expect(AppColors.textPrimary, const Color(0xFFFFFFFF));
    AppColors.isLight = true;
    expect(AppColors.background, const Color(0xFFF6F5F1));
    expect(AppColors.textPrimary, const Color(0xFF15161A));
    expect(AppColors.accent, const Color(0xFFB07A1C));
    expect(AppColors.surface, const Color(0xFFFFFFFF));
  });

  test('saved choice is read back; nothing saved means dark', () async {
    SharedPreferences.setMockInitialValues({'app_theme': 'light'});
    expect(await ThemeModeNotifier.loadSaved(), AppThemeChoice.light);
    SharedPreferences.setMockInitialValues({});
    expect(await ThemeModeNotifier.loadSaved(), AppThemeChoice.dark);
  });

  test('set saves the choice', () async {
    SharedPreferences.setMockInitialValues({});
    final n = ThemeModeNotifier();
    await n.set(AppThemeChoice.phone);
    expect(n.state, AppThemeChoice.phone);
    expect((await SharedPreferences.getInstance()).getString('app_theme'), 'phone');
  });

  // Shows the palette's background so the test can read which mode the app is in
  const probeKey = Key('probe');
  Widget probe() => Builder(builder: (_) => ColoredBox(key: probeKey, color: AppColors.background, child: const SizedBox.expand()));
  Color probeColor(WidgetTester t) => t.widget<ColoredBox>(find.byKey(probeKey)).color;

  Widget app(AppThemeChoice choice) => ProviderScope(
        overrides: [themeModeProvider.overrideWith((ref) => ThemeModeNotifier(choice))],
        child: NivaarthApp(home: probe()),
      );

  testWidgets('light choice paints the light palette', (tester) async {
    await tester.pumpWidget(app(AppThemeChoice.light));
    await tester.pumpAndSettle();
    expect(probeColor(tester), const Color(0xFFF6F5F1));
  });

  testWidgets('phone choice follows the phone dark setting, also when it changes', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpWidget(app(AppThemeChoice.phone));
    await tester.pumpAndSettle();
    expect(probeColor(tester), const Color(0xFF0C0D10));
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(probeColor(tester), const Color(0xFFF6F5F1));
  });

  testWidgets('switching theme with another page open does not crash', (tester) async {
    late WidgetRef refHolder;
    await tester.pumpWidget(ProviderScope(
      child: Consumer(builder: (context, ref, _) {
        refHolder = ref;
        return NivaarthApp(home: Builder(builder: (ctx) => TextButton(
          onPressed: () => Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const Text('second'))),
          child: const Text('open'),
        )));
      }),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await refHolder.read(themeModeProvider.notifier).set(AppThemeChoice.light);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(AppColors.isLight, isTrue);
  });

  testWidgets('tapping Light in the theme setting switches and saves it', (tester) async {
    SharedPreferences.setMockInitialValues({});
    late WidgetRef refHolder;
    await tester.pumpWidget(ProviderScope(child: Consumer(builder: (c, ref, _) {
      refHolder = ref;
      return localizedApp(home: const Scaffold(body: ThemeSwitcher()));
    })));
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(refHolder.read(themeModeProvider), AppThemeChoice.light);
    expect((await SharedPreferences.getInstance()).getString('app_theme'), 'light');
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
  });
}
