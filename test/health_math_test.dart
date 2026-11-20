import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/health_math.dart';
import 'package:mobile/models/live_portfolio.dart';
import 'package:mobile/models/portfolio.dart';
import 'package:mobile/models/stock_score.dart';
import 'package:mobile/services/portfolio_health_engine.dart';

LivePortfolio h(String s, double value) => LivePortfolio(
      portfolio: Portfolio(id: s, instrument: s, companyName: s, yahooSymbol: s, qty: 1, avgPrice: value, totalInvested: value,
          currentValue: value, netPL: 0, sector: '', industry: '', status: 'ACTIVE', investmentThesis: ''),
      currentPrice: value, currentValue: value, netPL: 0, returnPercent: 0, todayReturnPercent: 0,
    );

StockScore sc(String s, int? o) => StockScore(instrument: s, companyName: s, businessQuality: 0, financialStrength: 0, growth: 0,
    valuation: 0, technical: 0, risk: 0, overallScore: o, recommendation: 'X', confidence: 90, lastUpdated: null);

void main() {
  final holdings = [h('A', 3000), h('B', 1000), h('C', 6000), h('D', 500)];
  final scores = [sc('A', 70), sc('B', 40), sc('C', 55), sc('D', null)];

  test('weighted health equals the card number', () {
    final engine = const PortfolioHealthEngine().calculate(holdings, scores).overall;
    expect(weightedHealth(holdingScoresFrom(holdings, scores)), closeTo(engine, 1e-9));
  });

  test('lowest score comes first, unscored last', () {
    final rows = healthRows(holdingScoresFrom(holdings, scores));
    expect(rows.map((r) => r.symbol), ['B', 'C', 'A', 'D']);
    expect(rows.last.score, isNull);
  });

  test('weights are shares of the scored value', () {
    final rows = healthRows(holdingScoresFrom(holdings, scores));
    expect(rows.firstWhere((r) => r.symbol == 'C').weightPct, closeTo(60, 1e-9));
    expect(rows.firstWhere((r) => r.symbol == 'D').weightPct, 0);
  });

  test('no scores gives null', () {
    expect(weightedHealth(holdingScoresFrom(holdings, [sc('A', null)])), isNull);
    expect(weightedHealth(const []), isNull);
  });
}
