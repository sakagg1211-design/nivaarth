import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/account_value.dart';
import 'package:mobile/core/utils/market_pulse.dart';
import 'package:mobile/core/utils/today_facts.dart';
import 'package:mobile/providers/account_value_provider.dart';
import 'package:mobile/providers/live_portfolio_provider.dart';
import 'package:mobile/providers/locale_provider.dart';
import 'package:mobile/providers/market_pulse_provider.dart';
import 'package:mobile/providers/news_provider.dart';
import 'package:mobile/providers/today_facts_provider.dart';
import 'package:mobile/screens/dashboard/widgets/index_cards_row.dart';
import 'package:mobile/screens/dashboard/widgets/nifty_movers_card.dart';
import 'package:mobile/screens/dashboard/widgets/pulse_strip.dart';
import 'package:mobile/screens/dashboard/widgets/today_facts_card.dart';

import 'helpers/localized_app.dart';

MarketPulse pulse({bool live = true}) => MarketPulse(
      indices: const [
        IndexQuote('NIFTY 50', value: 25227.95, change: -159.45, pct: -0.63, spark: [25300, 25250, 25228], prevClose: 25387.4),
        IndexQuote('SENSEX', value: 82031.81, change: -500.38, pct: -0.61),
        IndexQuote('NIFTY BANK'),
        IndexQuote('NIFTY IT', value: 31262.3, change: -391.8, pct: -1.24),
      ],
      gainers: const [Mover('TITAN', 2.1, 3561), Mover('ITC', 1.2, 410)],
      losers: const [Mover('INFY', -2.4, 1500)],
      advances: live ? 18 : 878,
      declines: live ? 31 : 2121,
      leaders: live ? const [('Financial Services', 0.4)] : const [],
      live: live,
      asOf: DateTime(2026, 11, 18),
    );

AccountToday today({double value = 1000, double prevClose = 980, HourChange? hour}) => AccountToday(
      [ValuePoint(DateTime(2026, 11, 19, 9, 20), 990, 900), ValuePoint(DateTime(2026, 11, 19, 10, 30), value, 900)],
      value,
      prevClose,
      900,
      hour,
    );

Widget host(Widget child, {Locale locale = englishLocale, MarketPulse? p, AccountToday? t, List<Fact> facts = const []}) => ProviderScope(
      overrides: [
        marketPulseProvider.overrideWith((ref) async => p),
        accountTodayProvider.overrideWith((ref) async => t),
        todayFactsProvider.overrideWith((ref) async => facts),
        livePortfolioProvider.overrideWith((ref) async => const []),
        holdingsNewsProvider.overrideWith((ref) async => null),
      ],
      child: localizedApp(locale: locale, home: Scaffold(body: SingleChildScrollView(child: child))),
    );

void main() {
  testWidgets('index cards show four in order with a dash for missing', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(const IndexCardsRow(), p: pulse()));
    await tester.pumpAndSettle();
    final names = ['NIFTY 50', 'SENSEX', 'NIFTY BANK', 'NIFTY IT'];
    final xs = [for (final n in names) tester.getTopLeft(find.text(n)).dx];
    expect(xs, [...xs]..sort());
    expect(find.text('—'), findsWidgets); // Nifty Bank has no data
    expect(find.textContaining('-0.63%'), findsOneWidget);
  });

  testWidgets('pulse hides the last-hour line when the market is closed', (tester) async {
    final h = HourChange(DateTime(2026, 11, 19, 9, 30), 0.4, 'POLYCAB');
    await tester.pumpWidget(host(const PulseStrip(open: true), t: today(hour: h), p: pulse()));
    await tester.pumpAndSettle();
    expect(find.textContaining('POLYCAB'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pumpWidget(host(const PulseStrip(open: false), t: today(hour: h), p: pulse()));
    await tester.pumpAndSettle();
    expect(find.textContaining('POLYCAB'), findsNothing);
  });

  testWidgets('pulse button text follows the sign of today\'s change', (tester) async {
    bool? asked;
    await tester.pumpWidget(host(PulseStrip(open: true, onWhy: (up) => asked = up), t: today(value: 970, prevClose: 980), p: pulse()));
    await tester.pumpAndSettle();
    expect(find.text('Why did it fall today?'), findsOneWidget);
    await tester.tap(find.text('Why did it fall today?'));
    expect(asked, isFalse);
    await tester.pumpWidget(Container());
    await tester.pumpWidget(host(PulseStrip(open: true, onWhy: (_) {}), t: today(), p: pulse()));
    await tester.pumpAndSettle();
    expect(find.text('Why did it rise today?'), findsOneWidget);
  });

  testWidgets('pulse shows only percentages, so Privacy Mode has nothing to mask', (tester) async {
    await tester.pumpWidget(host(const PulseStrip(open: true), t: today(), p: pulse()));
    await tester.pumpAndSettle();
    expect(find.textContaining('₹'), findsNothing);
    expect(find.textContaining('Nifty -0.63%'), findsOneWidget);
  });

  testWidgets('facts card is hidden with no facts and shows at most three', (tester) async {
    await tester.pumpWidget(host(const TodayFactsCard()));
    await tester.pumpAndSettle();
    expect(find.text('Aaj ki baatein'), findsNothing);
    final facts = [
      const Fact(FactKind.low52, 65, symbol: 'A', values: {'price': 100}),
      const Fact(FactKind.scoreDown, 55, symbol: 'B', values: {'from': 41, 'to': 31}),
      const Fact(FactKind.stalePrice, 30, values: {'count': 2}),
    ];
    await tester.pumpWidget(Container());
    await tester.pumpWidget(host(const TodayFactsCard(), facts: facts));
    await tester.pumpAndSettle();
    expect(find.text('Aaj ki baatein'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(3));
  });

  testWidgets('movers card says only Nifty 50 and shows the mood', (tester) async {
    await tester.pumpWidget(host(const NiftyMoversCard(), p: pulse()));
    await tester.pumpAndSettle();
    expect(find.text('* Top gainers and losers: only Nifty 50'), findsOneWidget);
    expect(find.text('Nifty 50: 18 up · 31 down'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pumpWidget(host(const NiftyMoversCard(), p: pulse(live: false)));
    await tester.pumpAndSettle();
    expect(find.text('Market: 878 up · 2121 down (18 Nov)'), findsOneWidget);
  });

  test('the old NV Briefing is gone from the Dashboard', () {
    final src = File('lib/screens/dashboard/dashboard_page.dart').readAsStringSync();
    expect(src.contains('NV Briefing'), isFalse);
    expect(src.contains('AIBriefingCard'), isFalse);
    expect(src.contains('MarketIndicesBar'), isFalse);
  });

  testWidgets('the new Dashboard cards fit 320 wide in Hinglish', (tester) async {
    tester.view.physicalSize = const Size(320, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final facts = [const Fact(FactKind.topDrag, 61, symbol: 'AVERYLONGSYMBOLNAME', values: {'pct': -0.62})];
    await tester.pumpWidget(host(
      Column(children: [const IndexCardsRow(), PulseStrip(open: true, onWhy: (_) {}), const TodayFactsCard(), const NiftyMoversCard()]),
      locale: hinglishLocale,
      p: pulse(),
      t: today(hour: HourChange(DateTime(2026, 11, 19, 9, 30), 0.4, 'POLYCAB')),
      facts: facts,
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Aaj kyun badha?'), findsOneWidget);
  });
}
