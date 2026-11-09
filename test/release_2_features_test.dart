import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/market_hours.dart';
import 'package:mobile/core/utils/stock_insights.dart';
import 'package:mobile/core/utils/symbol_utils.dart';
import 'package:mobile/models/peer_comparison.dart';
import 'package:mobile/models/stock_score.dart';
import 'package:mobile/providers/stock_insights_provider.dart';
import 'package:mobile/providers/stock_score_provider.dart';
import 'package:mobile/screens/stock/widgets/peer_comparison_card.dart';
import 'package:mobile/screens/stock/widgets/stock_radar_card.dart';
import 'helpers/localized_app.dart';
import 'package:mobile/providers/locale_provider.dart';

Map<String, dynamic> part(String label, num points, num max, [String status = 'VALID']) =>
    {'label': label, 'points': points, 'max': max, 'status': status};

Map<String, dynamic> company({String debt = 'VALID', String momentum = 'VALID'}) => {
      'pillars': [
        {
          'key': 'quality',
          'score': 80,
          'parts': [
            part('Return on capital', 40, 40),
            part('Debt', 20, 25, debt),
            part('Cash conversion', 0, 15, 'CONFIRMED_FAIL'),
            part('Growth', 10, 20),
          ],
        },
        {'key': 'valuation', 'score': 68.6, 'parts': [part('P/E vs sector', 26, 50)]},
        {'key': 'momentum', 'score': 23.6, 'parts': [part('12-1 month return rank', 23.6, 100, momentum)]},
      ],
    };

Map<String, dynamic> lender({bool nim = true}) => {
      'pillars': [
        {
          'key': 'quality',
          'score': 76,
          'parts': [
            part('Return on equity', 24, 30),
            part('Return on assets', 18, 25),
            if (nim) part('Net interest margin', 6, 15),
            part('Leverage', 10, 10),
            part('Growth', 17, 20),
          ],
        },
        {'key': 'valuation', 'score': 39, 'parts': [part('P/B vs peers', 6, 60)]},
        {'key': 'momentum', 'score': 26, 'parts': [part('12-1 month return rank', 26, 100)]},
      ],
    };

StockScore score(Map<String, dynamic>? b, {int? overall = 70}) => StockScore.empty().copyForTest(b, overall);

extension on StockScore {
  StockScore copyForTest(Map<String, dynamic>? b, int? overall) => StockScore(
        instrument: 'TCS',
        companyName: 'TCS',
        businessQuality: 0,
        financialStrength: 0,
        growth: 0,
        valuation: 0,
        technical: 0,
        risk: 0,
        overallScore: overall,
        recommendation: '',
        confidence: 0,
        lastUpdated: null,
        scoreBreakdown: b,
      );
}

void main() {
  group('audit fixes', () {
    test('a company with GOLD or SILV in its name is not an ETF', () {
      for (final s in ['GOLDIAM', 'SKYGOLD', 'GOLDSTAR', 'SILVERTUC', 'GOLDTECH']) {
        expect(SymbolUtils.isEtf(s), isFalse, reason: s);
      }
      for (final s in ['GOLDBEES', 'SILVERBEES', 'NIFTYBEES', 'TATSILV', 'MIDSMALL', 'NIFTYIETF']) {
        expect(SymbolUtils.isEtf(s), isTrue, reason: s);
      }
    });
    test('market is shut on an exchange holiday, open the next day', () {
      expect(isMarketOpenIst(DateTime.utc(2026, 11, 10, 6)), isFalse); // Tuesday, Diwali Balipratipada
      expect(isMarketOpenIst(DateTime.utc(2026, 11, 11, 6)), isTrue);
      expect(isMarketOpenIst(DateTime.utc(2026, 11, 11, 11)), isFalse); // after 15:30 IST
    });
  });

  group('radar axes', () {
    test('company: six corners from the same numbers as the score', () {
      final a = StockInsights.radarAxes(company());
      expect(a.map((x) => x.shortLabel), ['ROCE', 'Debt', 'Cash', 'Growth', 'Valuation', 'Momentum']);
      expect(a.map((x) => x.value?.round()), [100, 80, 0, 50, 69, 24]);
    });
    test('missing data is null, never zero; a confirmed fail is a real zero', () {
      final a = StockInsights.radarAxes(company(debt: 'DATA_UNAVAILABLE', momentum: 'MOMENTUM_UNAVAILABLE'));
      expect(a[1].value, isNull);
      expect(a[2].value, 0);
      expect(a[5].value, isNull);
    });
    test('broker with exempted debt shows no debt number', () {
      expect(StockInsights.radarAxes(company(debt: 'EXEMPTED_BROKER_MTF'))[1].value, isNull);
    });
    test('bank: lender corners, no momentum', () {
      final a = StockInsights.radarAxes(lender());
      expect(a.map((x) => x.shortLabel), ['ROE', 'ROA', 'NIM', 'Leverage', 'Growth', 'Valuation']);
      expect(StockInsights.isLender(lender()), isTrue);
    });
    test('NBFC without NIM has five corners', () {
      expect(StockInsights.radarAxes(lender(nim: false)).length, 5);
    });
    test('ETF or no breakdown has no radar', () {
      final etf = {
        'pillars': [
          {'key': 'quality', 'score': 0, 'parts': [part('ETF', 0, 1)]},
        ],
      };
      expect(StockInsights.radarAxes(etf), isEmpty);
      expect(StockInsights.radarAxes(null), isEmpty);
    });
    test('too few real numbers: no shape', () {
      const axes = [RadarAxis('A', 'A', 1), RadarAxis('B', 'B', 2), RadarAxis('C', 'C', 3), RadarAxis('D', 'D', null)];
      expect(StockInsights.canDrawRadar(axes), isFalse);
      expect(StockInsights.canDrawRadar(StockInsights.radarAxes(company())), isTrue);
    });
  });

  group('badges', () {
    List<String> labels(StockFacts f, {bool lender = false}) =>
        StockInsights.badges(f, lender: lender).map((b) => b.label).toList();

    test('debt-free only at or under 0.05 D/E, and never for lenders', () {
      expect(labels(const StockFacts(debtToEquity: 0.05)), ['Debt-free (D/E 0.05)']);
      expect(labels(const StockFacts(debtToEquity: 0.06)), isEmpty);
      expect(labels(const StockFacts(debtToEquity: 0.0), lender: true), isEmpty);
    });
    test('insurers never get debt-free; brokers are not insurers', () {
      expect(labels(const StockFacts(debtToEquity: 0.0, insurer: true)), isEmpty);
      expect(StockInsights.isInsurer('INSURANCE', 'Insurance - Life'), isTrue);
      expect(StockInsights.isInsurer('EQUITY', 'Insurance - Property & Casualty'), isTrue); // GODIGIT
      expect(StockInsights.isInsurer('EQUITY', 'Insurance Brokers'), isFalse); // POLICYBZR
      expect(StockInsights.isInsurer('EQUITY', null), isFalse);
      expect(StockInsights.isInsurer(null, null), isFalse);
    });
    test('a pledge checked against filings keeps its number but loses the warning', () {
      final notes = {
        'notes': ["Promoter shares are pledged for a private-equity owner's holding-company loan "
            '(checked against exchange filings); not counted as a high-risk pledge.'],
      };
      expect(StockInsights.pledgeReviewed(notes), isTrue);
      expect(StockInsights.pledgeReviewed(const {'notes': ['Something else']}), isFalse);
      expect(StockInsights.pledgeReviewed(null), isFalse);
      final b = StockInsights.badges(const StockFacts(pledged: 66.99), lender: false, pledgeReviewed: true);
      expect(b.single.label, 'Promoter pledge 67% · filings checked');
      expect(b.single.caution, isFalse);
    });
    test('an old EMA row does not count', () {
      final now = DateTime(2026, 11, 20);
      expect(StockInsights.isRecent(DateTime(2026, 11, 11), now), isTrue);
      expect(StockInsights.isRecent(DateTime(2026, 11, 10), now), isTrue);
      expect(StockInsights.isRecent(DateTime(2026, 11, 9), now), isFalse);
      expect(StockInsights.isRecent(null, now), isFalse);
    });
    test('ROCE and growth must both clear the line', () {
      expect(labels(const StockFacts(roce: 20, profitGrowth5Y: 15)), ['ROCE 20% · profit growth 15%']);
      expect(labels(const StockFacts(roce: 63, profitGrowth5Y: 9)), isEmpty);
      expect(labels(const StockFacts(roce: 63)), isEmpty);
    });
    test('EMA badge needs both figures', () {
      expect(labels(const StockFacts(ema50: 11, ema200: 10)), ['50-EMA above 200-EMA']);
      expect(labels(const StockFacts(ema50: 9, ema200: 10)), isEmpty);
      expect(labels(const StockFacts(ema50: 11)), isEmpty);
    });
    test('pledge and losses are cautions; missing data says nothing', () {
      final b = StockInsights.badges(const StockFacts(pledged: 32, pat12m: -5), lender: false);
      expect(b.map((x) => x.label), ['Promoter pledge 32%', 'Loss-making (12M)']);
      expect(b.every((x) => x.caution), isTrue);
      expect(labels(const StockFacts()), isEmpty);
      expect(StockInsights.badges(null, lender: false), isEmpty);
    });
  });

  group('peers', () {
    Map<String, dynamic> row(String s, num? cap) => {'Instrument': s, 'Company': s, 'MarketCapCr': cap, 'PE': 20};

    test('three largest others, partly-paid and capless left out', () {
      final d = PeerData.fromRows('X', 'TCS', [
        row('TCS', 900), row('INFY', 500), row('WIPRO', 200), row('HCLTECH', 300), row('LTIM', 100),
        row('INFYP1', 490), row('NOCAP', null),
      ])!;
      expect(d.largest.map((p) => p.symbol), ['INFY', 'HCLTECH', 'WIPRO']);
      expect(d.others.length, 4);
    });
    test('no row or no peers: nothing to show', () {
      expect(PeerData.fromRows('X', 'TCS', [row('INFY', 1)]), isNull);
      expect(PeerData.fromRows('X', 'TCS', [row('TCS', 1)]), isNull);
    });
    test('cells show a dash, and P/E of a loss-maker is a dash', () {
      expect(peerCell(null), '—');
      expect(peerCell(-3, positiveOnly: true), '—');
      expect(peerCell(16.57), '16.6');
      expect(peerCell(-3, suffix: '%'), '-3.0%');
    });
  });

  group('cards', () {
    Widget host(List<Override> o, Widget child) =>
        ProviderScope(overrides: o, child: localizedApp(locale: hinglishLocale, home: Scaffold(body: SingleChildScrollView(child: child))));

    testWidgets('radar card at 320 wide, and it survives failed facts', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(host(
        [stockFactsProvider.overrideWith((ref, s) => Future.error(Exception('x')))],
        StockRadarCard(symbol: 'TCS', companyName: 'TCS', score: score(company())),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Return on capital'), findsOneWidget);
    });

    testWidgets('radar card is hidden when there is nothing to draw', (tester) async {
      await tester.pumpWidget(host(
        [stockFactsProvider.overrideWith((ref, s) async => null)],
        StockRadarCard(symbol: 'X', companyName: 'X', score: score(null, overall: null)),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Score ka aakar'), findsNothing);
    });

    testWidgets('peer table: dashes for unknown scores, pick adds a column', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      Map<String, dynamic> r(String s, num cap) => {'Instrument': s, 'Company': '$s Ltd', 'MarketCapCr': cap, 'PE': 20};
      final data = PeerData.fromRows('IT', 'TCS', [r('TCS', 9), r('A', 8), r('B', 7), r('C', 6), r('D', 5), r('E', 4)]);
      await tester.pumpWidget(host(
        [
          peerComparisonProvider.overrideWith((ref, s) async => data),
          stockScoreProvider.overrideWith((ref, s) => Future.error(Exception('x'))),
        ],
        PeerComparisonCard(symbol: 'TCS', score: score(company())),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('70'), findsOneWidget);
      await tester.tap(find.text('Aur peer jodo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('D'));
      await tester.pumpAndSettle();
      expect(find.text('Peer badlo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no pick button once every peer is already in the table', (tester) async {
      Map<String, dynamic> r(String s, num cap) => {'Instrument': s, 'Company': '$s Ltd', 'MarketCapCr': cap, 'PE': 20};
      final data = PeerData.fromRows('IT', 'TCS', [r('TCS', 9), r('A', 8), r('B', 7), r('C', 6), r('D', 5)]);
      await tester.pumpWidget(host(
        [
          peerComparisonProvider.overrideWith((ref, s) async => data),
          stockScoreProvider.overrideWith((ref, s) async => null),
        ],
        PeerComparisonCard(symbol: 'TCS', score: score(company())),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aur peer jodo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('D'));
      await tester.pumpAndSettle();
      expect(find.text('Peer badlo'), findsNothing);
      expect(find.text('Aur peer jodo'), findsNothing);
    });

    testWidgets('radar leaves out a missing corner instead of drawing it at zero', (tester) async {
      const axes = [
        RadarAxis('A', 'A', 80),
        RadarAxis('B', 'B', null),
        RadarAxis('C', 'C', 60),
        RadarAxis('D', 'D', 40),
        RadarAxis('E', 'E', 20),
      ];
      await tester.pumpWidget(localizedApp(locale: hinglishLocale, 
        home: Scaffold(body: SizedBox(height: 220, width: 300, child: ScoreRadar(axes: axes))),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final sets = tester.widget<RadarChart>(find.byType(RadarChart)).data.dataSets;
      expect(sets.every((s) => s.dataEntries.length == 4), isTrue);
      expect(sets.last.dataEntries.map((e) => e.value), [80, 60, 40, 20]);
    });
  });
}
