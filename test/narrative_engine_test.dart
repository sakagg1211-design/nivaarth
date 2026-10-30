import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/utils/verdict_narrative_engine.dart';
import 'package:mobile/models/stock_score.dart';

const breakdown = {
  'final': 61,
  'pillars': [
    {'key': 'quality', 'label': 'Quality', 'score': 63.0, 'weight': 0.5, 'parts': [
      {'label': 'Return on capital', 'points': 23.0, 'max': 50, 'detail': 'ROCE 13.4%'},
      {'label': 'Debt', 'points': 25.0, 'max': 30, 'detail': '0.44x debt to equity'},
    ]},
    {'key': 'valuation', 'label': 'Valuation', 'score': 43.0, 'weight': 0.3, 'parts': [
      {'label': 'P/E vs sector', 'points': 20.0, 'max': 60, 'detail': 'P/E 35.7; costlier than 67% of 49 sector peers'},
    ]},
    {'key': 'momentum', 'label': 'Momentum', 'score': 70.0, 'weight': 0.2, 'parts': []},
  ],
  'weighted': 61.5,
  'hurdle_factor': null,
  'risk_cap': null,
  'provisional_cap': null,
};

StockScore motherson({Map<String, dynamic>? b}) => StockScore(
      instrument: 'MOTHERSON',
      companyName: 'Samvardhana Motherson International Ltd.',
      businessQuality: 0,
      financialStrength: 0,
      growth: 0,
      valuation: 0,
      technical: 0,
      risk: 0,
      overallScore: 61,
      recommendation: 'FAIR VALUE / CORE',
      confidence: 100,
      lastUpdated: null,
      scoreBreakdown: b,
    );

void main() {
  test('equity narrative comes from the breakdown numbers', () {
    final n = VerdictNarrativeEngine.generate(score: motherson(b: Map<String, dynamic>.from(breakdown)), isOwned: true);
    expect(n.analystBriefing, contains('NV Score of 61/100'));
    expect(n.primaryCatalyst.title, 'Highest pillar: Momentum');
    expect(n.primaryRisk.title, 'Lowest pillar: Valuation');
    expect(n.primaryRisk.description, contains('P/E 35.7'));
    expect(n.playbook.toWatch, contains('P/E vs sector scores 20 of 60'));
    expect(n.playbook.dataShows, startsWith('In your portfolio.'));
  });

  test('no breakdown yet: plain message, no story', () {
    final n = VerdictNarrativeEngine.generate(score: motherson());
    expect(n.analystBriefing, contains('breakdown appears after the next score update'));
  });
}
