import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/allocation_math.dart';
import 'package:mobile/core/utils/risk_math.dart';
import 'package:mobile/models/stock_score.dart';
import 'package:mobile/providers/risk_provider.dart';
import 'package:mobile/providers/search_provider.dart';
import 'package:mobile/screens/dashboard/widgets/macro_card.dart';
import 'package:mobile/screens/risk/risk_lab_page.dart';

void main() {
  const a = RiskHolding('A', 300, 1.5, 'Tech');
  const b = RiskHolding('B', 100, 0.5, 'Energy');
  const c = RiskHolding('C', 100, null, 'Energy');

  group('snapshot', () {
    test('beta is value-weighted, weights are of the whole portfolio', () {
      final s = RiskMath.snapshot(const [a, b]);
      expect(s.beta, closeTo(1.25, 1e-9));
      expect(s.stockWeight['A'], 75);
      expect(s.sectorWeight['Energy'], 25);
      expect(s.coveragePct, 100);
    });
    test('a missing beta is left out of the beta and counted', () {
      final s = RiskMath.snapshot(const [a, c]);
      expect(s.beta, closeTo(1.5, 1e-9));
      expect(s.uncoveredCount, 1);
      expect(s.coveragePct, 75);
      expect(s.stockWeight['C'], 25);
    });
    test('no betas: no number', () {
      expect(RiskMath.snapshot(const [c]).beta, isNull);
      expect(RiskMath.snapshot(const []).beta, isNull);
    });
  });

  group('stress', () {
    test('value x beta x fall, largest loss first', () {
      final r = RiskMath.stress(const [b, a], 10);
      expect(r.change, closeTo(-50, 1e-9)); // -45 and -5
      expect(r.changePct, closeTo(-12.5, 1e-9));
      expect(r.lines.first.symbol, 'A');
    });
    test('a position cannot lose more than itself', () {
      final r = RiskMath.stress(const [RiskHolding('X', 100, 5, 'T')], 30);
      expect(r.change, -100);
    });
    test('a negative beta gains when the market falls', () {
      expect(RiskMath.stress(const [RiskHolding('G', 100, -0.2, 'ETF')], 10).change, closeTo(2, 1e-9));
    });
    test('no beta is excluded and counted, percent is of what was counted', () {
      final r = RiskMath.stress(const [a, c], 10);
      expect(r.uncoveredCount, 1);
      expect(r.coveredValue, 300);
      expect(r.changePct, closeTo(-15, 1e-9));
    });
  });

  group('what-if', () {
    test('adds to a held stock', () {
      final out = RiskMath.applyChange(const [a, b], 'B', delta: 100, beta: 9, sector: 'Z');
      expect(out.firstWhere((h) => h.symbol == 'B').value, 200);
      expect(out.firstWhere((h) => h.symbol == 'B').beta, 0.5);
    });
    test('a new stock uses the given beta and sector', () {
      final out = RiskMath.applyChange(const [a], 'N', delta: 100, beta: 2, sector: 'Auto');
      expect(out.last.beta, 2);
      expect(out.last.sector, 'Auto');
    });
    test('reducing past the holding removes it; reducing an unheld stock does nothing', () {
      expect(RiskMath.applyChange(const [a, b], 'B', delta: -500, beta: 1, sector: 'S').length, 1);
      expect(RiskMath.applyChange(const [a], 'N', delta: -5, beta: 1, sector: 'S').length, 1);
    });
    test('a fund gets no warning, and Others is not treated as a sector', () {
      final s = RiskMath.snapshot(const [
        RiskHolding('NIFTYBEES', 80, 1, AllocationMath.etf),
        RiskHolding('X', 20, 1, AllocationMath.others),
      ]);
      expect(RiskMath.warnings(s, 'NIFTYBEES', AllocationMath.etf), isEmpty);
      final other = RiskMath.snapshot(const [RiskHolding('X', 100, 1, AllocationMath.others)]);
      expect(RiskMath.warnings(other, 'X', AllocationMath.others).length, 1); // the stock line only
    });
    test('warns only above the 15% and 30% lines', () {
      final over = RiskMath.snapshot(const [RiskHolding('A', 16, 1, 'T'), RiskHolding('B', 84, 1, 'U')]);
      expect(RiskMath.warnings(over, 'A', 'T').length, 1);
      expect(RiskMath.warnings(over, 'B', 'U').length, 2);
      final exact = RiskMath.snapshot(const [RiskHolding('A', 15, 1, 'T'), RiskHolding('B', 85, 1, 'U')]);
      expect(RiskMath.warnings(exact, 'A', 'T'), isEmpty);
    });
  });

  group('screens', () {
    testWidgets('macro card shows dashes for a missing half and hides when empty', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [macroProvider.overrideWith((ref) async => const MacroData(vix: 13.4, vixChangePct: 2.1))],
        child: const MaterialApp(home: Scaffold(body: MacroCard())),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('13.40'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);

      await tester.pumpWidget(ProviderScope(
        key: UniqueKey(),
        overrides: [macroProvider.overrideWith((ref) async => const MacroData())],
        child: const MaterialApp(home: Scaffold(body: MacroCard())),
      ));
      await tester.pumpAndSettle();
      expect(find.text('India VIX'), findsNothing);
    });

    testWidgets('what-if finds a stock through the database search and shows the result', (tester) async {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      StockScore hit(String sym) => StockScore(
            instrument: sym, companyName: '$sym Ltd', businessQuality: 0, financialStrength: 0, growth: 0,
            valuation: 0, technical: 0, risk: 0, overallScore: 0, recommendation: '', confidence: 0, lastUpdated: null,
          );
      await tester.pumpWidget(ProviderScope(
        overrides: [
          riskHoldingsProvider.overrideWith((ref) async => const [a, b]),
          searchProvider.overrideWith((ref, q) async => q == 'SIEM' ? [hit('SIEMENS')] : <StockScore>[]),
          stockRiskProvider.overrideWith((ref, s) async => const RiskInfo(1.2, 'Industrials')),
        ],
        child: const MaterialApp(home: RiskLabPage()),
      ));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'SIEM');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SIEMENS Ltd'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '100');
      await tester.pumpAndSettle();
      expect(find.text('SIEMENS ka hissa'), findsOneWidget);
      expect(find.text('20.0%'), findsNWidgets(2)); // 100 of 500, for the stock and its sector
      expect(tester.takeException(), isNull);
    });

    testWidgets('risk page draws at 320 wide; a fall choice changes the figure', (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(ProviderScope(
        overrides: [riskHoldingsProvider.overrideWith((ref) async => const [a, b, c])],
        child: const MaterialApp(home: RiskLabPage()),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('-12.5%'), findsOneWidget);
      await tester.tap(find.text('-20%'));
      await tester.pumpAndSettle();
      expect(find.text('-25.0%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
