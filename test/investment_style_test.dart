import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/investment_style.dart';
import 'package:mobile/providers/investment_style_provider.dart';
import 'package:mobile/screens/portfolio/widgets/investment_style_card.dart';
import 'helpers/localized_app.dart';
import 'package:mobile/providers/locale_provider.dart';

void main() {
  final grid = StyleGrid.build(const [
    StyleStock('TRENT', 40, 'Large', 'Growth', growthRank: 95, valueRank: 14),
    StyleStock('KEI', 20, 'Small', 'Growth'),
    StyleStock('ITC', 10, 'Large', 'Value'),
    StyleStock('NIFTYBEES', 20, '', StyleGrid.fund),
    StyleStock('LOSS', 10, 'Small', StyleGrid.lossMaking),
  ]);

  group('grid', () {
    test('every cell is a share of the whole portfolio', () {
      expect(grid.percent[0][0], 40);
      expect(grid.percent[2][0], 20);
      expect(grid.percent[0][2], 10);
    });
    test('funds and loss-makers sit outside the grid, and everything adds to 100', () {
      expect(grid.funds, 20);
      expect(grid.loss, 10);
      final inGrid = [for (var r = 0; r < 4; r++) grid.rowTotal(r)].reduce((a, b) => a + b);
      expect(inGrid + grid.funds + grid.loss + grid.unclassified, closeTo(100, 1e-9));
    });
    test('row and column totals', () {
      expect(grid.rowTotal(0), 50);
      expect(grid.colTotal(0), 60);
    });
    test('the largest cell is the biggest single box', () {
      expect(grid.largest, (0, 0));
    });
    test('an unknown style is counted as no data, not dropped', () {
      final g = StyleGrid.build(const [StyleStock('X', 10, 'Large', StyleGrid.notClassified), StyleStock('Y', 10, 'Large', 'Growth')]);
      expect(g.unclassified, 50);
    });
    test('nothing in the grid has no largest cell', () {
      expect(StyleGrid.build(const [StyleStock('E', 10, '', StyleGrid.fund)]).largest, isNull);
      expect(StyleGrid.build(const []).largest, isNull);
    });
  });

  group('card', () {
    Widget host(StyleGrid? g) => ProviderScope(
          overrides: [investmentStyleProvider.overrideWith((ref) async => g)],
          child: localizedApp(locale: hinglishLocale, home: Scaffold(body: SingleChildScrollView(child: InvestmentStyleCard()))),
        );

    testWidgets('shows the largest box and fits a small phone', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(host(grid));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Large Cap · Growth'), findsOneWidget);
      expect(find.textContaining('ETF / funds 20.0%'), findsOneWidget);
    });

    testWidgets('the i button explains the card in plain words', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(host(grid));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.info_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Investment style kya hai?'), findsOneWidget);
      expect(find.textContaining('salah nahi hai'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a box lists its stocks with their ranks', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(host(grid));
      await tester.pumpAndSettle();
      await tester.tap(find.text('40.0%'));
      await tester.pumpAndSettle();
      expect(find.text('TRENT'), findsOneWidget);
      expect(find.text('95'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hidden until the style table has data', (tester) async {
      await tester.pumpWidget(host(null));
      await tester.pumpAndSettle();
      expect(find.text('Investment style'), findsNothing);
    });
  });
}
