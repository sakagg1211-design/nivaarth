import 'package:mobile/core/utils/verdict_narrative_engine.dart';
import 'package:mobile/models/stock_score.dart';

const _breakdown = {
  'final': 54,
  'pillars': [
    {'key': 'quality', 'label': 'Quality', 'score': 49.0, 'weight': 0.5, 'parts': [
      {'label': 'Return on capital', 'points': 23.0, 'max': 50, 'detail': 'ROCE 13.4%'},
    ]},
    {'key': 'valuation', 'label': 'Valuation', 'score': 43.0, 'weight': 0.3, 'parts': <Map<String, dynamic>>[]},
    {'key': 'momentum', 'label': 'Momentum', 'score': null, 'weight': null, 'parts': <Map<String, dynamic>>[]},
  ],
  'weighted': 61.5,
  'hurdle_factor': 0.85,
  'risk_cap': 40,
  'quality_cap': 54,
  'provisional_cap': 50,
};

StockScore _s(String sym, String rec, int? overall, {Map<String, dynamic>? b}) => StockScore(
      instrument: sym,
      companyName: 'Sample Co Ltd.',
      businessQuality: 0,
      financialStrength: 0,
      growth: 0,
      valuation: 0,
      technical: 0,
      risk: 0,
      overallScore: overall,
      recommendation: rec,
      confidence: 100,
      lastUpdated: null,
      scoreBreakdown: b,
    );

/// One input for each path of the engine, owned and not owned.
final narrativeSamples = <String, StockScore>{
  'etf': _s('NIFTYBEES', 'FAIR VALUE', 60),
  'pending': _s('AAA', 'DATA PENDING', null),
  'review': _s('AAA', 'DATA REVIEW', null),
  'holding': _s('AAA', 'SPECIALIZED: HOLDING COMPANY', null),
  'insurance': _s('AAA', 'SPECIALIZED: INSURANCE', null),
  'reit': _s('AAA', 'SPECIALIZED: REIT', null),
  'other': _s('AAA', 'SPECIALIZED: EXCLUDED', null),
  'noBreakdown': _s('AAA', 'FAIR VALUE', 61),
  'scored': _s('AAA', 'FAIR VALUE', 54, b: _breakdown),
};

Map<String, dynamic> dumpNarrative(VerdictNarrative n) => {
      'archetypeTag': n.archetypeTag,
      'analystBriefing': n.analystBriefing,
      'profileLabel': n.profileLabel,
      'catalyst': [n.primaryCatalyst.title, n.primaryCatalyst.description, n.primaryCatalyst.scoreLabel],
      'risk': [n.primaryRisk.title, n.primaryRisk.description, n.primaryRisk.scoreLabel],
      'playbook': [n.playbook.dataShows, n.playbook.toWatch, n.playbook.updatesWith],
    };
