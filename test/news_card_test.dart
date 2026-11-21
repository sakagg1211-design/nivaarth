import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/stock_news.dart';
import 'package:mobile/providers/news_provider.dart';
import 'package:mobile/screens/stock/widgets/news_card.dart';

import 'helpers/localized_app.dart';

NewsHeadline h(int id, String title) =>
    NewsHeadline(id: id, title: title, source: 'Mint', url: 'https://x/$id', publishedAt: DateTime(2026, 11, 20, 11, 20));

StockNews news({
  bool live = true,
  MoveSplit move = const MoveSplit(stockPct: -4.2, niftyPct: -0.8, sector: 'Technology', sectorPct: -3.6, kind: 'sector'),
  List<NewsHeadline> session = const [],
  List<NewsHeadline> after = const [],
  List<NewsHeadline> recent = const [],
  String? summary,
}) =>
    StockNews(
      sessionDate: DateTime(2026, 11, 20),
      live: live,
      move: move,
      summaryEn: summary,
      summaryHi: summary,
      session: session,
      afterClose: after,
      recent: recent,
    );

Widget host(StockNews? n) => ProviderScope(
      overrides: [stockNewsProvider('TCS').overrideWith((ref) async => n)],
      child: localizedApp(home: const Scaffold(body: SingleChildScrollView(child: NewsCard(symbol: 'TCS')))),
    );

void main() {
  testWidgets('shows move rows and hides a null sector', (tester) async {
    await tester.pumpWidget(host(news(move: const MoveSplit(stockPct: -4.2, niftyPct: -0.8, kind: 'own'))));
    await tester.pumpAndSettle();
    expect(find.text('TCS'), findsOneWidget);
    expect(find.text('-4.20%'), findsOneWidget);
    expect(find.text('Nifty 50'), findsOneWidget);
    expect(find.text('-0.80%'), findsOneWidget);
    expect(find.text('Technology'), findsNothing);
  });

  testWidgets('sector kind shows the sector sentence and the summary', (tester) async {
    await tester.pumpWidget(host(news(session: [h(1, 'US clients cut tech spending')], summary: 'About US client spending')));
    await tester.pumpAndSettle();
    expect(find.text('Its sector moved the same way.'), findsOneWidget);
    expect(find.text('About US client spending'), findsOneWidget);
    expect(find.text('US clients cut tech spending'), findsOneWidget);
    expect(find.text('Live'), findsOneWidget);
  });

  testWidgets('against kind says it moved the other way; no kind says nothing', (tester) async {
    await tester.pumpWidget(host(news(move: const MoveSplit(stockPct: 0.6, niftyPct: -1.5, kind: 'against'))));
    await tester.pumpAndSettle();
    expect(find.text('It moved the other way from the market or its sector.'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pumpWidget(host(news(move: const MoveSplit(stockPct: 3.0))));
    await tester.pumpAndSettle();
    expect(find.textContaining('market'), findsNothing);
    expect(find.textContaining('sector'), findsNothing);
  });

  testWidgets('after-close group appears only when not live', (tester) async {
    await tester.pumpWidget(host(news(live: false, after: [h(2, 'Results after the bell')])));
    await tester.pumpAndSettle();
    expect(find.text('After market close'), findsOneWidget);
    expect(find.text('20 Nov close'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pumpWidget(host(news(live: true, after: [h(2, 'Results after the bell')])));
    await tester.pumpAndSettle();
    expect(find.text('After market close'), findsNothing);
  });

  testWidgets('title says "today" only while live', (tester) async {
    await tester.pumpWidget(host(news(live: true)));
    await tester.pumpAndSettle();
    expect(find.text('Why it moved today'), findsOneWidget);
    await tester.pumpWidget(Container());
    await tester.pumpWidget(host(news(live: false)));
    await tester.pumpAndSettle();
    expect(find.text('Why it moved'), findsOneWidget);
  });

  testWidgets('empty lists show the empty text but keep move rows', (tester) async {
    await tester.pumpWidget(host(news()));
    await tester.pumpAndSettle();
    expect(find.text('No news for this stock in the last 14 days.'), findsOneWidget);
    expect(find.text('-4.20%'), findsOneWidget);
  });

  testWidgets('split day shows the split note and no summary', (tester) async {
    await tester.pumpWidget(host(news(move: const MoveSplit(stockPct: -50, niftyPct: 0.1, kind: 'split_day'), summary: 'x')));
    await tester.pumpAndSettle();
    expect(find.textContaining('split or bonus'), findsOneWidget);
    expect(find.text('x'), findsNothing);
  });

  testWidgets('no positive or negative label anywhere', (tester) async {
    await tester.pumpWidget(host(news(session: [h(1, 'TCS wins deal')], recent: [h(3, 'Old news')])));
    await tester.pumpAndSettle();
    final bad = RegExp('positive|negative|bullish|bearish', caseSensitive: false);
    final texts = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data ?? '').toList();
    expect(texts.where(bad.hasMatch), isEmpty);
  });

  testWidgets('nothing is shown when the backend gives nothing', (tester) async {
    await tester.pumpWidget(host(null));
    await tester.pumpAndSettle();
    expect(find.byType(Text), findsNothing);
  });
}
