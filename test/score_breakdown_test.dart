import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/models/stock_score.dart';
import 'package:mobile/screens/stock/widgets/score_breakdown_section.dart';

// Shape written by backend build_score_breakdown() for JIOFIN (v2.4.1)
const jiofin = {
  'version': 'v2.4.1',
  'final': 6,
  'pillars': [
    {'key': 'quality', 'label': 'Quality', 'score': 20.0, 'status': 'PROVISIONAL_ROE_ONLY', 'weight': 0.5, 'parts': [
      {'label': 'Return on capital', 'points': 10.0, 'max': 50, 'detail': 'ROE 1.2% (bank / NBFC scale)', 'status': 'VALID'},
    ]},
    {'key': 'valuation', 'label': 'Valuation', 'score': 10.7, 'status': 'VALID', 'weight': 0.3, 'parts': []},
    {'key': 'momentum', 'label': 'Momentum', 'score': 10.0, 'status': 'VALID', 'weight': 0.2, 'parts': []},
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
  testWidgets('shows pillars, weights, hurdle and the final score', (tester) async {
    await pump(tester, jiofin);
    expect(find.text('Quality  ·  50% weight'), findsOneWidget);
    expect(find.text('20 / 100'), findsOneWidget);
    expect(find.text('15.2'), findsOneWidget);
    expect(find.text('× 0.40 (quality below 55)'), findsOneWidget);
    expect(find.text('6 / 100'), findsOneWidget);
  });

  testWidgets('missing breakdown shows a plain message, no bars', (tester) async {
    await pump(tester, null);
    expect(find.text('The breakdown appears after the next score update.'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  test('score_breakdown is read from the StockScores row', () {
    final s = StockScore.fromJson({'Instrument': 'JIOFIN', 'OverallScore': 6, 'score_breakdown': jiofin});
    expect(s.scoreBreakdown?['final'], 6);
    expect(StockScore.fromJson({'Instrument': 'X', 'OverallScore': 6}).scoreBreakdown, isNull);
  });
}
