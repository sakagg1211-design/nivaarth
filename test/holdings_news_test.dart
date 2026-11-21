import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/market_pulse.dart';
import 'package:mobile/core/utils/today_facts.dart';
import 'package:mobile/models/stock_news.dart';
import 'package:mobile/providers/live_portfolio_provider.dart';
import 'package:mobile/providers/market_pulse_provider.dart';
import 'package:mobile/providers/news_provider.dart';
import 'package:mobile/providers/today_facts_provider.dart';
import 'package:mobile/screens/dashboard/widgets/holdings_news_card.dart';
import 'package:mobile/screens/dashboard/widgets/nifty_movers_card.dart';
import 'package:mobile/screens/dashboard/widgets/today_facts_card.dart';

import 'helpers/localized_app.dart';

HoldingNewsItem item(String s, double move) => HoldingNewsItem(
    symbol: s, stockPct: -1.5, rupeeMove: move, count: 2, title: '$s headline', source: 'Mint', publishedAt: DateTime(2026, 11, 20, 11, 20));

HoldingsNews hn(List<HoldingNewsItem> top, {Map<String, int> counts = const {}}) =>
    HoldingsNews(sessionDate: DateTime(2026, 11, 20), live: true, counts: counts, top: top);

Widget host(Widget child, {HoldingsNews? news, List<Fact> facts = const [], MarketPulse? pulse}) => ProviderScope(
      overrides: [
        holdingsNewsProvider.overrideWith((ref) async => news),
        todayFactsProvider.overrideWith((ref) async => facts),
        livePortfolioProvider.overrideWith((ref) async => const []),
        marketPulseProvider.overrideWith((ref) async => pulse),
      ],
      child: localizedApp(home: Scaffold(body: SingleChildScrollView(child: child))),
    );

MarketPulse pulse({required bool live, DateTime? asOf}) => MarketPulse(
      indices: const [],
      gainers: const [Mover('TITAN', 2.1, 3561)],
      losers: const [Mover('INFY', -2.4, 1500)],
      live: live,
      asOf: asOf,
    );

void main() {
  testWidgets('holdings card hidden when top is empty', (tester) async {
    await tester.pumpWidget(host(const HoldingsNewsCard(), news: hn(const [])));
    await tester.pumpAndSettle();
    expect(find.text('News on your holdings'), findsNothing);
  });

  testWidgets('holdings card shows at most 5 rows in given order', (tester) async {
    final top = [for (var i = 0; i < 6; i++) item('S$i', -100.0 * (6 - i))];
    await tester.pumpWidget(host(const HoldingsNewsCard(), news: hn(top)));
    await tester.pumpAndSettle();
    expect(find.text('News on your holdings'), findsOneWidget);
    expect(find.text('S0 headline'), findsOneWidget);
    expect(find.text('S4 headline'), findsOneWidget);
    expect(find.text('S5 headline'), findsNothing);
    expect(tester.getTopLeft(find.text('S0')).dy, lessThan(tester.getTopLeft(find.text('S1')).dy));
  });

  testWidgets('fact row shows news count only when count > 0', (tester) async {
    const facts = [
      Fact(FactKind.topDrag, 70, symbol: 'TCS', values: {'pct': -1.2}),
      Fact(FactKind.topLift, 60, symbol: 'INFY', values: {'pct': 0.5}),
    ];
    await tester.pumpWidget(host(const TodayFactsCard(), facts: facts, news: hn(const [], counts: {'TCS': 2})));
    await tester.pumpAndSettle();
    expect(find.text('2 news today'), findsOneWidget);
    expect(find.textContaining('news today'), findsOneWidget);
  });

  testWidgets('movers title shows Live when live', (tester) async {
    await tester.pumpWidget(host(const NiftyMoversCard(), pulse: pulse(live: true, asOf: DateTime(2026, 11, 20))));
    await tester.pumpAndSettle();
    expect(find.text('Live'), findsOneWidget);
  });

  testWidgets('movers title shows "20 Nov close" when closed with no breadth row', (tester) async {
    await tester.pumpWidget(host(const NiftyMoversCard(), pulse: pulse(live: false, asOf: DateTime(2026, 11, 20))));
    await tester.pumpAndSettle();
    expect(find.text('20 Nov close'), findsOneWidget);
  });
}
