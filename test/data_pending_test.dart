import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/stock_score.dart';

// v2.7: a null score is either excluded (asset class / data review) or pending (too little data)
void main() {
  Map<String, dynamic> row(Object? score, String rec, Map<String, dynamic>? breakdown) => {
        'Instrument': 'X',
        'OverallScore': score,
        'Recommendation': rec,
        'score_breakdown': breakdown,
      };

  test('a pending score is not shown as excluded', () {
    final s = StockScore.fromJson(row(null, 'DATA PENDING',
        {'final': null, 'pending': 'Only 1 of 4 quality inputs available'}));
    expect(s.isExcluded, isTrue);
    expect(s.isDataPending, isTrue);
    expect(s.pendingReason, 'Only 1 of 4 quality inputs available');
  });

  test('an excluded asset class is not pending', () {
    final s = StockScore.fromJson(row(null, 'SCORE EXCLUDED (INSURANCE)', {'final': null, 'excluded': 'INSURANCE'}));
    expect(s.isDataPending, isFalse);
  });

  test('pillar scores and quality coverage come from the breakdown', () {
    final s = StockScore.fromJson(row(71, 'FAIR VALUE / CORE', {
      'final': 71,
      'pillars': [
        {
          'key': 'quality',
          'score': 92.6,
          'parts': [
            {'status': 'VALID'},
            {'status': 'VALID'},
            {'status': 'DATA_UNAVAILABLE'},
            {'status': 'CONFIRMED_FAIL'},
          ],
        },
        {'key': 'valuation', 'score': 41.2, 'parts': []},
        {'key': 'momentum', 'score': null, 'parts': []},
      ],
    }));
    expect(s.pillarScore('quality'), 93);
    expect(s.pillarScore('valuation'), 41);
    expect(s.pillarScore('momentum'), isNull);
    expect(s.qualityCoverage, (3, 4));
  });
}
