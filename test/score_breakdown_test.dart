import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/models/stock_score.dart';
import 'package:mobile/screens/stock/widgets/score_breakdown_section.dart';

// Shape written by backend build_score_breakdown() (v2.5): quality below 55 caps the score at 54
const weakQuality = {
  'version': 'v2.5.0',
  'final': 54,
  'pillars': [
    {'key': 'quality', 'label': 'Quality', 'score': 42.8, 'status': 'VALID', 'weight': 0.55, 'parts': [
      {'label': 'Return on capital', 'points': 10.0, 'max': 40, 'detail': 'ROCE 10.0%', 'status': 'VALID'},
      {'label': 'Growth', 'points': 17.8, 'max': 20, 'detail': '24.7% a year sales (5Y)', 'status': 'VALID'},
    ]},
    {'key': 'valuation', 'label': 'Valuation', 'score': 80.0, 'status': 'VALID', 'weight': 0.3, 'parts': []},
    {'key': 'momentum', 'label': 'Momentum', 'score': 83.3, 'status': 'VALID', 'weight': 0.15, 'parts': [
      {'label': '12-1 month return rank', 'points': 83.3, 'max': 100,
       'detail': '+31.1% over 12 months to a month ago; higher than 83% of stocks', 'status': 'VALID'},
    ]},
  ],
  'weighted': 60.0,
  'hurdle_factor': null,
  'quality_cap': 54,
  'risk_cap': null,
  'provisional_cap': null,
  'notes': [],
};

// v2.4.1 rows (before the nightly v2.5 rewrite) carry the multiplier instead
const v241 = {
  'version': 'v2.4.1',
  'final': 6,
  'pillars': [
    {'key': 'quality', 'label': 'Quality', 'score': 20.0, 'status': 'PROVISIONAL_ROE_ONLY', 'weight': 0.5, 'parts': []},
  ],
  'weighted': 15.2,
  'hurdle_factor': 0.4,
  'risk_cap': null,
  'provisional_cap': null,
  'notes': [],
};

Future<void> pump(WidgetTester tester, Map<String, dynamic>? b) => tester.pumpWidget(
      MaterialApp(home: Scaffold(body: SingleChildScrollView(child: ScoreBreakdownSection(breakdown: b)))),
    );

void main() {
  testWidgets('shows pillars, weights, the quality cap and the final score', (tester) async {
    await pump(tester, weakQuality);
    expect(find.text('Quality  ·  55% weight'), findsOneWidget);
    expect(find.text('Momentum  ·  15% weight'), findsOneWidget);
    expect(find.text('60.0'), findsOneWidget);
    expect(find.text('Capped at 54 (54 below quality 55, rising to no cap at 65)'), findsOneWidget);
    expect(find.text('54 / 100'), findsOneWidget);
    await tester.tap(find.text('Momentum  ·  15% weight'));
    await tester.pumpAndSettle();
    expect(find.textContaining('higher than 83% of stocks'), findsOneWidget);
  });

  testWidgets('older v2.4 rows still show the multiplier', (tester) async {
    await pump(tester, v241);
    expect(find.text('× 0.40 (quality below 55)'), findsOneWidget);
  });

  testWidgets('missing breakdown shows a plain message, no bars', (tester) async {
    await pump(tester, null);
    expect(find.text('The breakdown appears after the next score update.'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  test('score_breakdown is read from the StockScores row', () {
    final s = StockScore.fromJson({'Instrument': 'X', 'OverallScore': 54, 'score_breakdown': weakQuality});
    expect(s.scoreBreakdown?['final'], 54);
    expect(StockScore.fromJson({'Instrument': 'X', 'OverallScore': 6}).scoreBreakdown, isNull);
  });
}
