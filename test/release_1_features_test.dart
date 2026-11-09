import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/allocation_math.dart';
import 'package:mobile/models/chart_point.dart';
import 'package:mobile/models/price_alert.dart';
import 'package:mobile/providers/allocation_provider.dart';
import 'package:mobile/providers/price_alert_provider.dart';
import 'package:mobile/screens/dashboard/widgets/allocation_card.dart';
import 'package:mobile/screens/stock/widgets/price_alert_sheet.dart';
import 'package:mobile/screens/stock/widgets/stock_line_chart.dart';

void main() {
  group('market-cap tiers', () {
    test('uses the 100th and 250th company as cut-offs', () {
      expect(AllocationMath.capTier(100000, 90000, 30000), AllocationMath.large);
      expect(AllocationMath.capTier(90000, 90000, 30000), AllocationMath.large);
      expect(AllocationMath.capTier(89999, 90000, 30000), AllocationMath.mid);
      expect(AllocationMath.capTier(29999, 90000, 30000), AllocationMath.small);
    });
    test('missing market cap is not guessed, ETF has its own bucket', () {
      expect(AllocationMath.capTier(null, 90000, 30000), AllocationMath.unknown);
      expect(AllocationMath.capTier(0, 90000, 30000), AllocationMath.unknown);
      expect(AllocationMath.capTier(500, 90000, 30000, isEtf: true), AllocationMath.etf);
    });
  });

  group('cut-offs and funds', () {
    test('partly-paid lines do not take a rank', () {
      final rows = [
        (symbol: 'RELIANCE', cap: 5000.0),
        (symbol: 'RELIANCEP1', cap: 4999.0),
        (symbol: 'UPLPP1', cap: 4998.0),
        for (var i = 0; i < 260; i++) (symbol: 'S$i', cap: 4000.0 - i),
      ];
      final c = AllocationMath.cutOffs(rows)!;
      // RELIANCE is rank 1, so S0 is rank 2: rank 100 is S98, rank 250 is S248
      expect(c.large, 4000.0 - 98);
      expect(c.mid, 4000.0 - 248);
    });
    test('too few companies gives no cut-offs', () {
      expect(AllocationMath.cutOffs([(symbol: 'A', cap: 1.0)]), isNull);
    });
    test('fund ISINs are ETFs whatever the symbol; company shares are not', () {
      expect(AllocationMath.isFund('INF769K01LJ8', 'EQUITY', 'MIDSMALL'), isTrue);
      expect(AllocationMath.isFund('INF277KA1984', 'EQUITY', 'TATSILV'), isTrue);
      expect(AllocationMath.isFund('INE002A01018', 'EQUITY', 'RELIANCE'), isFalse);
      expect(AllocationMath.isFund(null, 'ETF', 'X'), isTrue);
      expect(AllocationMath.isFund(null, null, 'X'), isFalse);
    });
    test('a company with GOLD or SILV in its name is not an ETF', () {
      expect(AllocationMath.isFund('INE000A01011', 'EQUITY', 'GOLDIAM'), isFalse);
      expect(AllocationMath.isFund('INE000A01011', 'EQUITY', 'SILVERTUC'), isFalse);
      expect(AllocationMath.isFund(null, null, 'GOLDIAM'), isFalse);
      expect(AllocationMath.isFund(null, null, 'NIFTYBEES'), isTrue);
    });
  });

  group('allocation screens survive a failed load', () {
    testWidgets('price alert sheet still opens when the list cannot load', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [activePriceAlertsProvider.overrideWith((ref) => Future.error(Exception('no table')))],
        child: const MaterialApp(home: Scaffold(body: PriceAlertSheet(symbol: 'TCS', currentPrice: 100))),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Alert lagao'), findsOneWidget);
    });
    testWidgets('many alerts on a short screen scroll instead of overflowing', (tester) async {
      tester.view.physicalSize = const Size(320, 420);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final many = [
        for (var i = 0; i < 15; i++)
          PriceAlert(id: '$i', instrument: 'TCS', direction: PriceAlert.above, targetPrice: 110.0 + i),
      ];
      await tester.pumpWidget(ProviderScope(
        overrides: [activePriceAlertsProvider.overrideWith((ref) async => many)],
        child: const MaterialApp(
          home: Scaffold(body: Align(alignment: Alignment.bottomCenter, child: PriceAlertSheet(symbol: 'TCS', currentPrice: 100))),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
    testWidgets('sheet refuses the same alert twice and past the limit', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      Future<void> pump(List<PriceAlert> list) async {
        await tester.pumpWidget(ProviderScope(
          key: UniqueKey(),
          overrides: [activePriceAlertsProvider.overrideWith((ref) async => list)],
          child: const MaterialApp(
            home: Scaffold(body: Align(alignment: Alignment.bottomCenter, child: PriceAlertSheet(symbol: 'TCS', currentPrice: 100))),
          ),
        ));
        await tester.pumpAndSettle();
      }

      await pump(const [PriceAlert(id: '1', instrument: 'TCS', direction: PriceAlert.above, targetPrice: 110)]);
      await tester.enterText(find.byType(TextField), '110');
      await tester.tap(find.text('Alert lagao'));
      await tester.pumpAndSettle();
      expect(find.text('Ye alert pehle se laga hai'), findsOneWidget);

      await pump([
        for (var i = 0; i < PriceAlert.maxActive; i++)
          PriceAlert(id: '$i', instrument: 'S$i', direction: PriceAlert.above, targetPrice: 110),
      ]);
      await tester.enterText(find.byType(TextField), '150');
      await tester.tap(find.text('Alert lagao'));
      await tester.pumpAndSettle();
      expect(find.textContaining('${PriceAlert.maxActive} alert tak'), findsOneWidget);
    });
    testWidgets('alerts page draws on the dark background', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          activePriceAlertsProvider.overrideWith((ref) async => [
                const PriceAlert(id: '1', instrument: 'TCS', direction: PriceAlert.below, targetPrice: 90),
              ]),
        ],
        child: const MaterialApp(home: PriceAlertsPage()),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, const Color(0xFF0C0D10));
      expect(find.textContaining('TCS'), findsOneWidget);
    });
    testWidgets('dashboard card hides itself on an error', (tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [allocationProvider.overrideWith((ref) => Future.error(Exception('offline')))],
        child: const MaterialApp(home: Scaffold(body: AllocationCard())),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Portfolio ka bantwara'), findsNothing);
    });
    testWidgets('a long sector name stays inside the donut hole on a small phone', (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final slices = [AllocationSlice('Communication Services', 100, 100, 1)];
      await tester.pumpWidget(ProviderScope(
        overrides: [allocationProvider.overrideWith((ref) async => PortfolioAllocation(slices, slices))],
        child: const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: AllocationCard()))),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.text('Communication Services')).width, lessThanOrEqualTo(92));
    });
    testWidgets('eight named sectors get eight different colours', (tester) async {
      final slices = [for (var i = 0; i < 8; i++) AllocationSlice('S$i', 10, 12.5, 1)];
      expect(allocationColors(slices).values.take(8).toSet().length, 8);
    });
  });

  group('slices', () {
    test('percentages add to 100, largest first, counts per group', () {
      final s = AllocationMath.slices([
        (group: 'A', value: 50.0),
        (group: 'B', value: 150.0),
        (group: 'A', value: 50.0),
      ]);
      expect(s.map((x) => x.label), ['B', 'A']);
      expect(s[0].percent, 60);
      expect(s[1].percent, 40);
      expect(s[1].stocks, 2);
    });
    test('groups past the limit fold into Others and keep the total', () {
      final s = AllocationMath.slices(
        [for (var i = 0; i < 12; i++) (group: 'S$i', value: 100.0 - i)],
        maxSlices: 8,
      );
      expect(s.length, 8);
      expect(s.last.label, AllocationMath.others);
      expect(s.last.stocks, 5);
      expect(s.fold<double>(0, (t, x) => t + x.percent), closeTo(100, 1e-9));
    });
    test('holdings with no sector and the fold share one Others row', () {
      final s = AllocationMath.slices([
        (group: AllocationMath.others, value: 1000.0),
        for (var i = 0; i < 12; i++) (group: 'S$i', value: 100.0 - i),
      ], maxSlices: 8);
      expect(s.length, 8);
      expect(s.where((x) => x.label == AllocationMath.others).length, 1);
      expect(s.last.label, AllocationMath.others);
      expect(s.fold<double>(0, (t, x) => t + x.percent), closeTo(100, 1e-9));
    });
    test('zero-value holdings are ignored; nothing to show is empty', () {
      expect(AllocationMath.slices([(group: 'A', value: 0.0)]), isEmpty);
    });
  });

  group('chart points', () {
    test('skips null closes without shifting time or volume', () {
      final p = ChartPoint.fromYahoo([1762659000, 1762659300, 1762659600], [100, null, 102.5], [10, 20, null]);
      expect(p.length, 2);
      expect(p[1].close, 102.5);
      expect(p[1].volume, 0);
      expect(p[0].volume, 10);
    });
    test('time is India time whatever the device zone', () {
      // 2025-11-09 03:45 UTC is 09:15 IST
      final p = ChartPoint.fromYahoo([1762659900], [1], [1]);
      expect(chartDateLabel(p[0].time, '1D'), '9:15 AM');
      expect(chartDateLabel(p[0].time, '1M'), '9 Nov 2025');
      expect(chartDateLabel(p[0].time, 'ALL'), 'Nov 2025');
    });
    test('volume uses lakh and crore', () {
      expect(chartVolumeLabel(1200000), '12L');
      expect(chartVolumeLabel(15000000), '1.5Cr');
    });
    test('no data gives no points', () {
      expect(ChartPoint.fromYahoo(null, [1], [1]), isEmpty);
    });
  });

  group('price alert validation', () {
    test('above must be over the current price', () {
      expect(PriceAlert.validate(PriceAlert.above, 110, 100), isNull);
      expect(PriceAlert.validate(PriceAlert.above, 100, 100), isNotNull);
      expect(PriceAlert.validate(PriceAlert.above, 90, 100), isNotNull);
    });
    test('below must be under the current price', () {
      expect(PriceAlert.validate(PriceAlert.below, 90, 100), isNull);
      expect(PriceAlert.validate(PriceAlert.below, 100, 100), isNotNull);
    });
    test('the same alert twice is recognised', () {
      const a = PriceAlert(id: '1', instrument: 'TCS', direction: PriceAlert.above, targetPrice: 110);
      expect(a.matches(PriceAlert.above, 110), isTrue);
      expect(a.matches(PriceAlert.below, 110), isFalse);
      expect(a.matches(PriceAlert.above, 110.5), isFalse);
    });
    test('bad input is refused; unknown current price only needs a valid target', () {
      expect(PriceAlert.validate(PriceAlert.above, null, 100), isNotNull);
      expect(PriceAlert.validate(PriceAlert.above, 0, 100), isNotNull);
      expect(PriceAlert.validate(PriceAlert.below, 50, 0), isNull);
    });
  });
}
