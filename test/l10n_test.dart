import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/l10n/l10n_ext.dart';
import 'package:mobile/main.dart';
import 'package:mobile/providers/locale_provider.dart';
import 'package:mobile/widgets/language_switcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> arb(String name) =>
    jsonDecode(File('lib/l10n/$name').readAsStringSync()) as Map<String, dynamic>;

Iterable<String> messages(Map<String, dynamic> a) => a.keys.where((k) => !k.startsWith('@'));

Set<String> placeholders(String text) => RegExp(r'\{(\w+)').allMatches(text).map((m) => m.group(1)!).toSet();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final en = arb('app_en.arb');
  final hi = arb('app_en_IN.arb');

  test('both files have the same keys', () {
    expect(messages(hi).toSet(), messages(en).toSet());
  });

  test('every message has the same placeholders in both files', () {
    final bad = [
      for (final k in messages(en))
        if (placeholders(en[k] as String).length != placeholders(hi[k] as String).length ||
            !placeholders(en[k] as String).containsAll(placeholders(hi[k] as String)))
          k,
    ];
    expect(bad, isEmpty);
  });

  test('no Devanagari in Hinglish', () {
    final bad = messages(hi).where((k) => RegExp(r'[ऀ-ॿ]').hasMatch(hi[k] as String));
    expect(bad, isEmpty);
  });

  group('saved language', () {
    test('en_IN loads as Hinglish', () async {
      SharedPreferences.setMockInitialValues({'app_language': 'en_IN'});
      expect(await LocaleNotifier.loadSaved(), hinglishLocale);
    });
    test('an unknown value loads as English', () async {
      SharedPreferences.setMockInitialValues({'app_language': 'fr'});
      expect(await LocaleNotifier.loadSaved(), englishLocale);
    });
    test('nothing saved loads as English', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await LocaleNotifier.loadSaved(), englishLocale);
    });
    test('set saves and restores', () async {
      SharedPreferences.setMockInitialValues({});
      final n = LocaleNotifier();
      addTearDown(n.dispose);
      await n.set(hinglishLocale);
      expect(n.state, hinglishLocale);
      expect(await LocaleNotifier.loadSaved(), hinglishLocale);
    });
  });

  group('app', () {
    final probe = Builder(builder: (c) => Text(c.t.menuLanguage));

    testWidgets('an Indian phone does not switch the app to Hinglish by itself', (tester) async {
      tester.platformDispatcher.localeTestValue = const Locale('en', 'IN');
      tester.platformDispatcher.localesTestValue = const [Locale('en', 'IN')];
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await tester.pumpWidget(ProviderScope(child: NivaarthApp(home: probe)));
      await tester.pumpAndSettle();
      expect(find.text('Language'), findsOneWidget);
    });

    testWidgets('the switch changes open text at once', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(ProviderScope(
        child: NivaarthApp(
          home: Scaffold(body: Column(children: [probe, const LanguageSwitcher()])),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Language'), findsWidgets);
      await tester.tap(find.text('Hinglish'));
      await tester.pumpAndSettle();
      expect(find.text('Bhasha'), findsWidgets);
      expect(find.text('Language'), findsNothing);
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(find.text('Language'), findsWidgets);
    });

    testWidgets('choices are big enough to tap', (tester) async {
      await tester.pumpWidget(ProviderScope(child: NivaarthApp(home: const Scaffold(body: LanguageSwitcher()))));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.ancestor(of: find.text('Hinglish'), matching: find.byType(InkWell)).first).height,
          greaterThanOrEqualTo(48));
    });
  });
}
