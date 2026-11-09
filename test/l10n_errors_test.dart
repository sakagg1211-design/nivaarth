import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/error_messages.dart';
import 'package:mobile/core/utils/holding_math.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/live_portfolio.dart';
import 'package:mobile/models/portfolio.dart';
import 'package:mobile/models/portfolio_analysis.dart';
import 'package:mobile/repositories/trade_repository.dart';
import 'package:mobile/services/recommendation_engine.dart';

final en = lookupAppLocalizations(const Locale('en'));
final hi = lookupAppLocalizations(const Locale('en', 'IN'));

final _h = LivePortfolio(
  portfolio: Portfolio(
    id: 'A', instrument: 'ABC', companyName: 'A', yahooSymbol: 'A', qty: 1, avgPrice: 90, totalInvested: 90,
    currentValue: 100, netPL: 10, sector: '', industry: '', status: 'ACTIVE', investmentThesis: '',
  ),
  currentPrice: 100, currentValue: 100, netPL: 10, returnPercent: -7.5, todayReturnPercent: 1,
);

PortfolioAnalysis analysis({double ret = 12.5, int loss = 2, int unpriced = 1}) => PortfolioAnalysis(
      totalInvested: 100, currentValue: 112.5, totalPnL: 12.5, returnPercent: ret, totalStocks: 6, profitStocks: 4,
      lossStocks: loss, unpricedStocks: unpriced, healthScore: 71, riskScore: 20, biggestWinner: _h, biggestLoser: _h,
    );

List<String> numbers(String s) => RegExp(r'\d+(\.\d+)?').allMatches(s).map((m) => m.group(0)!).toList()..sort();

void main() {
  group('errors follow the language', () {
    test('selling more than held', () {
      const e = OversellException(5, 10);
      expect(TradeRepository.message(e, en), 'Not enough shares: you have 5, selling 10.');
      expect(TradeRepository.message(e, hi), 'Itne shares nahi hain: 5 hain, 10 bech rahe ho.');
    });
    test('a repository error is worded at display', () {
      final e = TextError((t) => t.errSymbolNotListed);
      expect(TradeRepository.message(e, en), 'This symbol is not in the NSE list. Choose the stock from search.');
      expect(TradeRepository.message(e, hi), 'Ye symbol NSE list mein nahi mila. Search se stock chuno.');
    });
    test('other errors keep their own text', () {
      expect(TradeRepository.message(Exception('from server'), hi), 'from server');
    });
  });

  group('dashboard briefing', () {
    final engine = RecommendationEngine();

    test('English is unchanged', () {
      final r = engine.generate(analysis(), en);
      expect(r.reasons.first, 'Overall return: +12.50%.');
      expect(r.reasons[1], '4 of 6 holdings are above their buy price.');
    });

    test('Hinglish has the same numbers in different words', () {
      final a = engine.generate(analysis(), en), b = engine.generate(analysis(), hi);
      expect(b.title, isNot(a.title));
      expect(b.reasons, isNot(a.reasons));
      expect(numbers(b.reasons.join(' ')), numbers(a.reasons.join(' ')));
    });
  });
}
