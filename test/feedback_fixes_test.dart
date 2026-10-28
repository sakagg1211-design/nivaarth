import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/utils/error_messages.dart';
import 'package:mobile/core/utils/symbol_utils.dart';
import 'package:mobile/models/live_portfolio.dart';
import 'package:mobile/models/portfolio.dart';
import 'package:mobile/models/stock_score.dart';
import 'package:mobile/repositories/stock_repository.dart';
import 'package:mobile/services/stock_score_engine.dart';

StockScore score(String sym, int? overall, {String name = ''}) => StockScore(
      instrument: sym,
      companyName: name,
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
    );

LivePortfolio holding(String sym) => LivePortfolio(
      portfolio: Portfolio(
        id: sym,
        instrument: sym,
        companyName: sym,
        yahooSymbol: '$sym.NS',
        qty: 10,
        avgPrice: 100,
        totalInvested: 1000,
        currentValue: 1000,
        netPL: 0,
        sector: '',
        industry: '',
        status: 'PORTFOLIO',
        investmentThesis: '',
      ),
      currentPrice: 100,
      currentValue: 1000,
      netPL: 0,
      returnPercent: 0,
    );

void main() {
  test('exact ticker ranks first even when higher-scored partial matches exist', () {
    final ranked = StockRepository.rankByRelevance([
      score('BELRISE', 90, name: 'Belrise Industries'),
      score('ABELLON', 80, name: 'Abellon Clean Energy'),
      score('BEL', 55, name: 'Bharat Electronics Ltd.'),
    ], 'BEL');
    expect(ranked.first.instrument, 'BEL');
    expect(ranked[1].instrument, 'BELRISE', reason: 'ticker prefix comes next');
  });

  test('renamed ticker resolves to the current symbol', () {
    expect(SymbolUtils.normalize('ZOMATO'), 'ETERNAL');
    final ranked = StockRepository.rankByRelevance([
      score('ETERNALX', 70),
      score('ETERNAL', 27, name: 'Eternal Ltd.'),
    ], 'ZOMATO');
    expect(ranked.first.instrument, 'ETERNAL');
  });

  test('strongest and weakest come only from the user\'s holdings', () {
    const engine = StockScoreEngine();
    final scores = [score('TCS', 96), score('BEL', 55), score('RBA', 8)];
    expect(engine.getTopOpportunity([holding('BEL'), holding('RBA')], scores).instrument, 'BEL');
    expect(engine.getWeakestHolding([holding('BEL'), holding('RBA')], scores).instrument, 'RBA');
    // No scored holding: empty, never a stock from the wider market
    expect(engine.getTopOpportunity([holding('XYZ')], scores).instrument, isEmpty);
    expect(engine.getWeakestHolding([holding('XYZ')], scores).instrument, isEmpty);
  });

  test('network errors get a plain message', () {
    final msg = ErrorMessages.friendly(Exception(
        "ClientException with SocketException: Failed host lookup: 'example.supabase.co'"));
    expect(msg, startsWith('No internet connection'));
    expect(ErrorMessages.isNetworkError(Exception('Bad state: no element')), isFalse);
  });
}
