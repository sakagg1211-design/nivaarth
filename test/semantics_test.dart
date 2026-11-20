import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/allocation_math.dart';
import 'package:mobile/core/utils/market_pulse.dart';
import 'package:mobile/core/utils/today_moves.dart';
import 'package:mobile/models/live_portfolio.dart';
import 'package:mobile/models/portfolio.dart';
import 'package:mobile/providers/account_value_provider.dart';
import 'package:mobile/providers/allocation_provider.dart';
import 'package:mobile/providers/live_portfolio_provider.dart';
import 'package:mobile/providers/market_pulse_provider.dart';
import 'package:mobile/screens/dashboard/widgets/allocation_card.dart';
import 'package:mobile/screens/dashboard/widgets/index_cards_row.dart';
import 'package:mobile/screens/dashboard/widgets/portfolio_health_card.dart';
import 'package:mobile/screens/portfolio/widgets/account_value_card.dart';
import 'package:mobile/screens/portfolio/widgets/today_moves_card.dart';

import 'helpers/localized_app.dart';

LivePortfolio h(String s) => LivePortfolio(
      portfolio: Portfolio(id: s, instrument: s, companyName: s, yahooSymbol: s, qty: 10, avgPrice: 90, totalInvested: 900,
          currentValue: 1000, netPL: 0, sector: '', industry: '', status: 'ACTIVE', investmentThesis: ''),
      currentPrice: 100, currentValue: 1000, netPL: 0, returnPercent: 0, todayReturnPercent: 0,
    );

Widget host(Widget child, List<Override> overrides) =>
    ProviderScope(overrides: overrides, child: localizedApp(home: Scaffold(body: SingleChildScrollView(child: child))));

final _today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

void main() {
  testWidgets('allocation donut reads its slices', (tester) async {
    final handle = tester.ensureSemantics();
    const s = [AllocationSlice('Large cap', 720, 72, 4), AllocationSlice('Small cap', 280, 28, 2)];
    await tester.pumpWidget(host(const AllocationCard(), [
      allocationProvider.overrideWith((ref) async => const PortfolioAllocation(s, s)),
    ]));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('Market cap: Large cap 72%, Small cap 28%')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('sector heatmap reads each sector and its move', (tester) async {
    final handle = tester.ensureSemantics();
    final sectors = TodayMoves.sectors([(sector: 'Energy', value: 600.0, todayPL: 6.0), (sector: 'Technology', value: 400.0, todayPL: -4.0)]);
    await tester.pumpWidget(host(const TodayMovesCard(), [
      todayMovesProvider.overrideWith((ref) async => TodayMovesData(sectors, const [], const [])),
    ]));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp(r'Sector heatmap: Energy \+1\.01%, Technology -0\.99%')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('account value chart reads the range change, no rupees', (tester) async {
    final handle = tester.ensureSemantics();
    final rows = [
      for (var i = 0; i < 365; i++)
        {
          'trade_date': _today.subtract(Duration(days: 364 - i)).toIso8601String().substring(0, 10),
          'value': 1000 + i, 'invested': 1000, 'assumed': false, 'stocks_priced': 1, 'stocks_held': 1,
        },
    ];
    await tester.pumpWidget(host(const AccountValueCard(), [
      livePortfolioProvider.overrideWith((ref) async => [h('A')]),
      accountHistoryFetchProvider.overrideWithValue(() async => rows),
      intradayFetchProvider.overrideWithValue((_) async => const []),
    ]));
    await tester.pumpAndSettle();
    final label = find.bySemanticsLabel(RegExp(r'^Account value, 1Y: \+'));
    expect(label, findsOneWidget);
    expect(tester.getSemantics(label).label.contains('₹'), isFalse);
    handle.dispose();
  });

  testWidgets('health ring reads the score and status', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(const PortfolioHealthCard(healthScore: 64, action: ''), const []));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('NV Health 64 out of 100, Average')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('index card reads value and move, and says no data instead of null', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(const IndexCardsRow(), [
      marketPulseProvider.overrideWith((ref) async => const MarketPulse(
            indices: [IndexQuote('NIFTY 50', value: 25227.95, change: -159.45, pct: -0.63), IndexQuote('NIFTY BANK')],
            gainers: [],
            losers: [],
            live: false,
          )),
    ]));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('NIFTY 50 25,227.95, -0.63%')), findsOneWidget);
    final bank = find.bySemanticsLabel(RegExp('NIFTY BANK'));
    expect(tester.getSemantics(bank).label, contains('no data'));
    expect(tester.getSemantics(bank).label.contains('null'), isFalse);
    handle.dispose();
  });
}
