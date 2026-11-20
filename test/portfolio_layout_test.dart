import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/live_portfolio.dart';
import 'package:mobile/models/portfolio.dart';
import 'package:mobile/providers/account_value_provider.dart';
import 'package:mobile/providers/investment_style_provider.dart';
import 'package:mobile/providers/live_portfolio_provider.dart';
import 'package:mobile/screens/portfolio/portfolio_page.dart';
import 'package:mobile/screens/portfolio/widgets/today_moves_card.dart';
import 'package:mobile/widgets/portfolio_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/localized_app.dart';

LivePortfolio h(String s) => LivePortfolio(
      portfolio: Portfolio(id: s, instrument: s, companyName: '$s Ltd', yahooSymbol: s, qty: 10, avgPrice: 90, totalInvested: 900,
          currentValue: 1000, netPL: 100, sector: '', industry: '', status: 'ACTIVE', investmentThesis: ''),
      currentPrice: 100, currentValue: 1000, netPL: 100, returnPercent: 11.1, todayReturnPercent: 1,
    );

Widget host(int n) => ProviderScope(
      overrides: [
        livePortfolioProvider.overrideWith((ref) async => [for (var i = 0; i < n; i++) h('STK$i')]),
        accountHistoryFetchProvider.overrideWithValue(() async => const []),
        todayMovesProvider.overrideWith((ref) async => null),
        investmentStyleProvider.overrideWith((ref) async => null),
      ],
      child: localizedApp(home: const PortfolioPage()),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> phone(WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('holdings come before the return heatmap', (tester) async {
    await phone(tester);
    await tester.pumpWidget(host(4));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Return Heatmap'), 300, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byType(PortfolioCard).first).dy, lessThan(tester.getTopLeft(find.text('Return Heatmap')).dy));
  });

  testWidgets('the last holding is not covered by the add button', (tester) async {
    await phone(tester);
    await tester.pumpWidget(host(3));
    await tester.pumpAndSettle();
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -5000));
    await tester.pumpAndSettle();
    final fab = tester.getRect(find.byType(FloatingActionButton).last);
    // whatever is at the very bottom of the list must sit above the button
    final lastCard = tester.getRect(find.byType(PortfolioCard).last);
    expect(lastCard.overlaps(fab), isFalse);
  });

  testWidgets('the collapsed add button keeps its label for TalkBack', (tester) async {
    await phone(tester);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(12));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Add Holding'), findsNothing); // collapsed: no visible label
    expect(find.byTooltip('Add Holding'), findsOneWidget);
    handle.dispose();
  });
}
