import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/providers/locale_provider.dart';
import 'package:mobile/screens/login/welcome_screen.dart';
import 'package:mobile/screens/stock/score_methodology_page.dart';
import 'package:mobile/widgets/language_switcher.dart';

import 'helpers/localized_app.dart';

void main() {
  // shortcut: login, sign-up and forgot-password read Supabase.instance at build, so they are not pumped here
  final screens = <String, (Widget, String, String)>{
    'welcome': (const WelcomeScreen(), 'Sign In', 'Sign in'),
    'methodology': (const ScoreMethodologyPage(), 'What the score is', 'Score kya hai'),
    'language switch': (const Scaffold(body: LanguageSwitcher()), 'Language', 'Bhasha'),
  };

  for (final e in screens.entries) {
    for (final hinglish in [false, true]) {
      testWidgets('${e.key} fits 320 wide in ${hinglish ? 'Hinglish' : 'English'}', (tester) async {
        tester.view.physicalSize = const Size(320, 720);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(ProviderScope(
          child: localizedApp(home: e.value.$1, locale: hinglish ? hinglishLocale : englishLocale),
        ));
        await tester.pump(const Duration(seconds: 1));
        expect(tester.takeException(), isNull);
        expect(find.text(hinglish ? e.value.$3 : e.value.$2, skipOffstage: false), findsWidgets);
      });
    }
  }

  test('button and chip words stay short in Hinglish', () {
    Map<String, dynamic> read(String n) => jsonDecode(File('lib/l10n/$n').readAsStringSync()) as Map<String, dynamic>;
    final en = read('app_en.arb'), hi = read('app_en_IN.arb');
    final long = [
      for (final k in en.keys)
        if (!k.startsWith('@') && k != '@@locale' && (en[k] as String).length <= 14 && (hi[k] as String).length > (en[k] as String).length * 1.3 + 10)
          '$k: ${en[k]} -> ${hi[k]}',
    ];
    expect(long, isEmpty, reason: long.join('\n'));
  });
}
