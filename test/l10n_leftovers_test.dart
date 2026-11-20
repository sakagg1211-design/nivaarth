import 'dart:ui';

import 'package:flutter/material.dart' hide Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/stock_insights.dart';
import 'package:mobile/core/utils/watch_takeaway.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/watchlist_item.dart';
import 'package:mobile/providers/locale_provider.dart';
import 'package:mobile/screens/advisor/advisor_chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/localized_app.dart';

final en = lookupAppLocalizations(const Locale('en'));
final hi = lookupAppLocalizations(const Locale('en', 'IN'));

WatchlistItem item({String? kind, Map<String, dynamic>? args, String stored = 'stored text'}) => WatchlistItem(
      instrument: 'A',
      companyName: 'A Ltd',
      score: null,
      addedPrice: 10,
      latestPrice: 10,
      dayChangePercent: 0,
      volume: '—',
      returnPercent: 0,
      trackedDate: '20 Nov',
      technicalTag: 'X',
      keyTakeaway: stored,
      takeawayKind: kind,
      takeawayArgs: args,
    );

void main() {
  test('takeaway follows the language', () {
    final i = item(kind: 'none', args: {'sector': 'Energy'});
    expect(takeawayText(i, en), 'No NV Score yet (Energy).');
    expect(takeawayText(i, hi), 'Abhi NV Score nahi (Energy).');
    expect(takeawayText(item(kind: 'pillars', args: {'score': 64, 'pillars': 'Quality 60 · Valuation 40'}), en),
        'NV Score 64/100 · Quality 60 · Valuation 40');
  });

  test('an old saved watchlist item shows its stored text', () {
    expect(takeawayText(item(), hi), 'stored text');
  });

  test('kind and args survive saving and loading', () {
    final back = WatchlistItem.fromJson(item(kind: 'score', args: {'score': 70, 'sector': 'IT'}).toJson());
    expect(back.takeawayKind, 'score');
    expect(back.takeawayArgs!['score'], 70);
    expect(WatchlistItem.fromJson({'instrument': 'B'}).takeawayKind, isNull);
  });

  test('badges are Hinglish in Hinglish and keep their numbers', () {
    const f = StockFacts(debtToEquity: 0.05, pledged: 66.99, pat12m: -5);
    final e = StockInsights.badges(f, en, lender: false).map((b) => b.label).toList();
    final h = StockInsights.badges(f, hi, lender: false).map((b) => b.label).toList();
    expect(e.first, 'Debt-free (D/E 0.05)');
    expect(h.length, e.length);
    expect(h, isNot(e));
    expect(h.first, contains('0.05'));
  });

  testWidgets('the greeting changes when the language changes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    Widget app(Locale l) => ProviderScope(child: localizedApp(locale: l, home: const AdvisorChatPage()));
    await tester.pumpWidget(app(englishLocale));
    await tester.pumpAndSettle();
    expect(find.textContaining('I am your research assistant', findRichText: true), findsOneWidget);
    await tester.pumpWidget(app(hinglishLocale));
    await tester.pumpAndSettle();
    expect(find.textContaining('Main aapka research assistant hoon', findRichText: true), findsOneWidget);
  });
}
