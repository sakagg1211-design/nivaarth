import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/performance_series.dart';
import 'package:mobile/models/live_portfolio.dart';
import 'package:mobile/models/portfolio.dart';
import 'package:mobile/providers/live_portfolio_provider.dart';
import 'package:mobile/providers/portfolio_performance_provider.dart';
import 'package:mobile/screens/portfolio/widgets/performance_card.dart';
import 'helpers/localized_app.dart';
import 'package:mobile/providers/locale_provider.dart';

LivePortfolio h(String s, {int qty = 1, double price = 100}) => LivePortfolio(
      portfolio: Portfolio(
        id: s, instrument: s, companyName: s, yahooSymbol: s, qty: qty, avgPrice: 90, totalInvested: 90,
        currentValue: 100, netPL: 10, sector: '', industry: '', status: 'ACTIVE', investmentThesis: '',
      ),
      currentPrice: price, currentValue: price, netPL: 10, returnPercent: 11, todayReturnPercent: 1,
    );

List<Map<String, dynamic>> rows(int n, {int stocks = 2}) => [
      for (var i = 0; i < n; i++)
        {
          'trade_date': DateTime(2025, 10, 9).add(Duration(days: i)).toIso8601String().substring(0, 10),
          'portfolio_index': 100 + i * .5,
          'nifty_index': 100 + i * .2,
          'stocks_priced': stocks,
          'stocks_held': 2,
        },
    ];

String pct(double v) => '${v > 0 ? '+' : ''}${v.toStringAsFixed(2)}%';

Widget host(Future<List<Map<String, dynamic>>> Function() fetch) => ProviderScope(
      overrides: [
        livePortfolioProvider.overrideWith((ref) async => [h('A')]),
        performanceFetchProvider.overrideWithValue(fetch),
      ],
      child: localizedApp(locale: hinglishLocale, home: Scaffold(body: SingleChildScrollView(child: PerformanceCard()))),
    );

void main() {
  const title = 'Portfolio vs Nifty';

  testWidgets('hidden when there is too little data', (tester) async {
    await tester.pumpWidget(host(() async => rows(19)));
    await tester.pumpAndSettle();
    expect(find.text(title), findsNothing);
  });

  testWidgets('hidden when the fetch fails', (tester) async {
    await tester.pumpWidget(host(() async => throw Exception('rpc down')));
    await tester.pumpAndSettle();
    expect(find.text(title), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('says it is a back-cast and names the benchmark', (tester) async {
    await tester.pumpWidget(host(() async => rows(45)));
    await tester.pumpAndSettle();
    expect(find.text(title), findsOneWidget);
    expect(find.textContaining('asli return nahi'), findsOneWidget);
    expect(find.textContaining('NIFTYBEES'), findsOneWidget);
    expect(find.textContaining('dividend shamil nahi'), findsOneWidget);
    expect(find.textContaining('₹'), findsNothing);
  });

  testWidgets('changing range changes the legend numbers', (tester) async {
    final data = rows(45);
    final s = PerformanceSeries.fromRows(data);
    await tester.pumpWidget(host(() async => data));
    await tester.pumpAndSettle();
    final all = 'Portfolio ${pct(s.slice(PerformanceRange.all).last.portfolio)}';
    final month = 'Portfolio ${pct(s.slice(PerformanceRange.m1).last.portfolio)}';
    expect(all, isNot(month));
    expect(find.text(all), findsOneWidget);
    await tester.tap(find.text('1M'));
    await tester.pumpAndSettle();
    expect(find.text(month), findsOneWidget);
    expect(find.text(all), findsNothing);
  });

  testWidgets('a range the data does not reach has no chip', (tester) async {
    await tester.pumpWidget(host(() async => rows(45)));
    await tester.pumpAndSettle();
    expect(find.text('1Y'), findsNothing);
  });

  testWidgets('partial note only when partial', (tester) async {
    await tester.pumpWidget(host(() async => rows(45)));
    await tester.pumpAndSettle();
    expect(find.textContaining('poora purana data nahi'), findsNothing);
    await tester.pumpWidget(Container());
    await tester.pumpWidget(host(() async => rows(45, stocks: 1)));
    await tester.pumpAndSettle();
    expect(find.textContaining('poora purana data nahi'), findsOneWidget);
  });

  testWidgets('fits 320 wide', (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(() async => rows(400, stocks: 1)));
    await tester.pumpAndSettle();
    expect(find.text(title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('price ticks do not refetch, a quantity change does', () async {
    final source = StateProvider<List<LivePortfolio>>((ref) => [h('A')]);
    var calls = 0;
    final container = ProviderContainer(overrides: [
      livePortfolioProvider.overrideWith((ref) async => ref.watch(source)),
      performanceFetchProvider.overrideWithValue(() async {
        calls++;
        return rows(45);
      }),
    ]);
    addTearDown(container.dispose);
    container.listen(portfolioPerformanceProvider, (_, _) {});
    Future<void> settle() async {
      for (var i = 0; i < 5; i++) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    await settle();
    expect(calls, 1);
    container.read(source.notifier).state = [h('A', price: 123)];
    await settle();
    expect(calls, 1);
    container.read(source.notifier).state = [h('A', qty: 2, price: 123)];
    await settle();
    expect(calls, 2);
  });

  test('no holdings: nothing is fetched', () async {
    var calls = 0;
    final container = ProviderContainer(overrides: [
      livePortfolioProvider.overrideWith((ref) async => const <LivePortfolio>[]),
      performanceFetchProvider.overrideWithValue(() async {
        calls++;
        return const [];
      }),
    ]);
    addTearDown(container.dispose);
    container.listen(portfolioPerformanceProvider, (_, _) {});
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(calls, 0);
  });
}
