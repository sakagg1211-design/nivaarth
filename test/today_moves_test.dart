import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/today_moves.dart';
import 'package:mobile/models/live_portfolio.dart';
import 'package:mobile/models/portfolio.dart';
import 'package:mobile/screens/portfolio/widgets/today_moves_card.dart';
import 'helpers/localized_app.dart';

LivePortfolio h(String s, double pct, {bool unpriced = false}) => LivePortfolio(
      portfolio: Portfolio(
        id: s, instrument: s, companyName: s, yahooSymbol: s, qty: 1, avgPrice: 90, totalInvested: 90,
        currentValue: 100, netPL: 10, sector: '', industry: '', status: 'ACTIVE', investmentThesis: '',
      ),
      currentPrice: 100, currentValue: 100, netPL: 10, returnPercent: 11, todayReturnPercent: pct, isPriceUnavailable: unpriced,
    );

void main() {
  ({String sector, double value, double todayPL}) i(String s, double v, double p) => (sector: s, value: v, todayPL: p);

  group('sector moves', () {
    test('weight is the share of value, change is against the previous value', () {
      final m = TodayMoves.sectors([i('A', 300, 0), i('B', 100, 10)]);
      expect(m.first.label, 'A');
      expect(m.first.weight, 75);
      expect(m.last.change, closeTo(10 / 90 * 100, 1e-9));
    });
    test('stocks in a sector add up before the percent is taken', () {
      final m = TodayMoves.sectors([i('A', 110, 10), i('A', 90, -10)]);
      expect(m.single.change, closeTo(0, 1e-9));
      expect(m.single.stocks, 2);
    });
    test('past the limit the smallest fold into Others, shown last', () {
      final m = TodayMoves.sectors([for (var n = 0; n < 12; n++) i('S$n', 100.0 - n, 1)], maxGroups: 8);
      expect(m.length, 8);
      expect(m.last.label, TodayMoves.others);
      expect(m.last.stocks, 5);
      expect(m.fold<double>(0, (t, s) => t + s.weight), closeTo(100, 1e-9));
    });
    test('exactly the limit needs no Others box', () {
      final m = TodayMoves.sectors([for (var n = 0; n < 8; n++) i('S$n', 10, 0)], maxGroups: 8);
      expect(m.length, 8);
      expect(m.any((s) => s.label == TodayMoves.others), isFalse);
    });
    test('stocks with no sector stay in Others even under the limit', () {
      final m = TodayMoves.sectors([i(TodayMoves.others, 500, 0), i('A', 100, 0)]);
      expect(m.map((s) => s.label), ['A', TodayMoves.others]);
    });
    test('zero value holdings are ignored', () {
      expect(TodayMoves.sectors([i('A', 0, 0)]), isEmpty);
    });
  });

  group('movers', () {
    final all = [h('A', 3), h('B', 1), h('C', -2), h('D', -4), h('E', 0), h('F', 9, unpriced: true)];

    test('gainers: biggest rise first, nothing flat or unpriced', () {
      expect(TodayMoves.gainers(all).map((x) => x.portfolio.instrument), ['A', 'B']);
    });
    test('losers: biggest fall first', () {
      expect(TodayMoves.losers(all).map((x) => x.portfolio.instrument), ['D', 'C']);
    });
    test('limit', () {
      expect(TodayMoves.gainers([for (var n = 1; n < 9; n++) h('S$n', n.toDouble())]).length, 5);
    });
  });

  group('card', () {
    Widget host(TodayMovesData? d) => ProviderScope(
          overrides: [todayMovesProvider.overrideWith((ref) async => d)],
          child: localizedApp(home: Scaffold(body: SingleChildScrollView(child: TodayMovesCard()))),
        );

    testWidgets('fits a small phone with long sector names', (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final sectors = TodayMoves.sectors([
        for (final s in ['Financial Services', 'Consumer Cyclical', 'Communication Services', 'Basic Materials', 'Industrials', 'Technology', 'Healthcare', 'Energy', 'Utilities'])
          i(s, s.length.toDouble(), .1),
      ]);
      await tester.pumpWidget(host(TodayMovesData(sectors, [h('AVERYLONGSYMBOLNAME', 4.2)], const [])));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Top losers'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('hidden with nothing to show', (tester) async {
      await tester.pumpWidget(host(null));
      await tester.pumpAndSettle();
      expect(find.text('Sector heatmap'), findsNothing);
    });
  });
}
