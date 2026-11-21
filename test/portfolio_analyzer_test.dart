import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/live_portfolio.dart';
import 'package:mobile/models/portfolio.dart';
import 'package:mobile/services/portfolio_analyzer.dart';

LivePortfolio h(String s, {required double value, required double todayPL, required double todayPct}) => LivePortfolio(
      portfolio: Portfolio(
        id: s, instrument: s, companyName: s, yahooSymbol: s, qty: 10, avgPrice: 90, totalInvested: 900,
        currentValue: value, netPL: 0, sector: '', industry: '', status: 'ACTIVE', investmentThesis: '',
      ),
      currentPrice: value / 10, currentValue: value, netPL: value - 900, returnPercent: 0,
      todayPL: todayPL, todayReturnPercent: todayPct,
    );

void main() {
  test('a split-day stock (move over 40%) is not counted as a loss in today\'s total', () {
    // SP split 1:2: 2000 -> 1000 reads as -1000 against the unadjusted close, but nothing was lost
    final a = PortfolioAnalyzer().analyze([
      h('TCS', value: 970, todayPL: -30, todayPct: -3),
      h('SP', value: 1000, todayPL: -1000, todayPct: -50),
    ]);
    expect(a.todayPnL, closeTo(-30, 0.001));
  });
}
