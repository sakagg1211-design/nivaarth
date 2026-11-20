import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/live_portfolio.dart';
import 'package:mobile/models/portfolio.dart';
import 'package:mobile/providers/account_value_provider.dart';
import 'package:mobile/providers/live_portfolio_provider.dart';
import 'package:mobile/providers/locale_provider.dart';
import 'package:mobile/providers/privacy_provider.dart';
import 'package:mobile/screens/portfolio/widgets/account_value_card.dart';

import 'helpers/localized_app.dart';

LivePortfolio h(String s, {int qty = 10, double price = 100, double todayPL = 20}) => LivePortfolio(
      portfolio: Portfolio(
        id: s, instrument: s, companyName: s, yahooSymbol: s, qty: qty, avgPrice: 90, totalInvested: qty * 90,
        currentValue: qty * price, netPL: 0, sector: '', industry: '', status: 'ACTIVE', investmentThesis: '',
      ),
      currentPrice: price, currentValue: qty * price, netPL: 0, returnPercent: 0, todayPL: todayPL, todayReturnPercent: 2,
    );

final _today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

List<Map<String, dynamic>> days(int n, {int assumedDays = 0, double Function(int)? value, double Function(int)? invested}) => [
      for (var i = 0; i < n; i++)
        {
          // the last day is today, so no live point is appended after the history
          'trade_date': _today.subtract(Duration(days: n - 1 - i)).toIso8601String().substring(0, 10),
          'value': value?.call(i) ?? 1000 + i,
          'invested': invested?.call(i) ?? 900,
          'assumed': i < assumedDays,
          'stocks_priced': 1,
          'stocks_held': 1,
        },
    ];

Widget host(List<Map<String, dynamic>> history, {List<Map<String, dynamic>> intraday = const [], bool hide = false, Locale locale = englishLocale}) =>
    ProviderScope(
      overrides: [
        livePortfolioProvider.overrideWith((ref) async => [h('A')]),
        accountHistoryFetchProvider.overrideWithValue(() async => history),
        intradayFetchProvider.overrideWithValue((_) async => intraday),
        privacyModeProvider.overrideWith((ref) => _FixedPrivacy(hide)),
      ],
      child: localizedApp(locale: locale, home: const Scaffold(body: SingleChildScrollView(child: AccountValueCard()))),
    );

class _FixedPrivacy extends PrivacyModeNotifier {
  _FixedPrivacy(bool on) {
    state = on;
  }
}

void main() {
  const title = 'Account value';

  testWidgets('hidden with no history', (tester) async {
    await tester.pumpWidget(host(const []));
    await tester.pumpAndSettle();
    expect(find.text(title), findsNothing);
  });

  testWidgets('a new user with no history yet still sees today', (tester) async {
    final ts = DateTime.now().toUtc().toIso8601String();
    await tester.pumpWidget(host(const [], intraday: [{'Instrument': 'A', 'ts': ts, 'price': 100}]));
    await tester.pumpAndSettle();
    expect(find.text(title), findsOneWidget);
  });

  testWidgets('shows the assumed note only when the range has assumed points', (tester) async {
    await tester.pumpWidget(host(days(365, assumedDays: 300)));
    await tester.pumpAndSettle();
    expect(find.textContaining('assumes today'), findsOneWidget);
    await tester.tap(find.text('1M'));
    await tester.pumpAndSettle();
    expect(find.textContaining('assumes today'), findsNothing);
  });

  testWidgets('legend names value and invested', (tester) async {
    await tester.pumpWidget(host(days(365)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Invested'), findsWidgets);
  });

  testWidgets('money added by a buy is not counted as gain', (tester) async {
    // value 1000 -> 1600 because 500 was invested on day 20, so the market gain is 100 on a base of 1500
    await tester.pumpWidget(host(days(30, value: (i) => i < 20 ? 1000.0 : 1600.0, invested: (i) => i < 20 ? 900.0 : 1400.0)));
    await tester.pumpAndSettle();
    expect(find.textContaining('+6.67%'), findsOneWidget);
    expect(find.textContaining('+60.00%'), findsNothing);
  });

  testWidgets('a sell lowers value and invested together, not counted as a loss', (tester) async {
    await tester.pumpWidget(host(days(30, value: (i) => i < 20 ? 1000.0 : 500.0, invested: (i) => i < 20 ? 900.0 : 450.0)));
    await tester.pumpAndSettle();
    expect(find.textContaining('-50.00%'), findsNothing);
  });

  testWidgets('Privacy Mode shows no rupee sign', (tester) async {
    await tester.pumpWidget(host(days(365), hide: true));
    await tester.pumpAndSettle();
    expect(find.textContaining('₹'), findsNothing);
    expect(find.textContaining('%'), findsWidgets);
  });

  testWidgets('1D with no intraday rows says the line starts at market open', (tester) async {
    await tester.pumpWidget(host(days(365)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1D'));
    await tester.pumpAndSettle();
    expect(find.text("Today's line starts when the market opens."), findsOneWidget);
  });

  testWidgets('1D shows the previous close and the change against it', (tester) async {
    final today = DateTime.now();
    String ts(int m) => DateTime(today.year, today.month, today.day, 9, 15 + m).toIso8601String();
    await tester.pumpWidget(host(days(365), intraday: [
      {'Instrument': 'A', 'ts': ts(0), 'price': 98},
      {'Instrument': 'A', 'ts': ts(5), 'price': 99},
    ]));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1D'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Previous close'), findsOneWidget);
    // live value 1000 against previous close 980 (1000 minus today's P&L of 20)
    expect(find.textContaining('+2.04%'), findsOneWidget);
  });

  testWidgets('fits 320 wide in Hinglish', (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(host(days(365, assumedDays: 300), locale: hinglishLocale));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('price ticks do not refetch history, a quantity change does', () async {
    final source = StateProvider<List<LivePortfolio>>((ref) => [h('A')]);
    var calls = 0;
    final container = ProviderContainer(overrides: [
      livePortfolioProvider.overrideWith((ref) async => ref.watch(source)),
      accountHistoryFetchProvider.overrideWithValue(() async {
        calls++;
        return days(30);
      }),
    ]);
    addTearDown(container.dispose);
    container.listen(accountHistoryProvider, (_, _) {});
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
    container.read(source.notifier).state = [h('A', qty: 20, price: 123)];
    await settle();
    expect(calls, 2);
  });
}
