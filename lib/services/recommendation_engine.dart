import '../core/utils/formatters.dart';
import '../core/utils/symbol_utils.dart';
import '../models/ai_recommendation.dart';
import '../models/portfolio_analysis.dart';
import '../l10n/app_localizations.dart';

/// Dashboard "NV Verdict": a factual summary of the portfolio's numbers. It states what the
/// data shows and what to look at; it never tells the user to buy, sell, hold or add.
class RecommendationEngine {
  AIRecommendation generate(
    PortfolioAnalysis analysis,
    AppLocalizations t,
  ) {
    final RecommendationType state;
    final String title;
    final String summary;
    final ret = analysis.returnPercent;
    final retText = Formatters.percent(ret, signed: true);

    if (ret >= 20 && analysis.healthScore >= 80) {
      state = RecommendationType.strong;
      title = t.recoStrong;
      summary = t.recoAbove(retText);
    } else if (ret >= 10) {
      state = RecommendationType.healthy;
      title = t.recoPositive;
      summary = t.recoAbove(retText);
    } else if (ret >= 0) {
      state = RecommendationType.stable;
      title = t.recoNearCost;
      summary = t.recoAgainst(retText);
    } else if (ret >= -10) {
      state = RecommendationType.drawdown;
      title = t.recoMild;
      summary = t.recoBelow(retText);
    } else {
      state = RecommendationType.deepDrawdown;
      title = t.recoBelowCost;
      summary = t.recoBelow(retText);
    }

    final reasons = <String>[
      t.recoOverall(retText),
      t.recoAboveBuy(analysis.profitStocks, analysis.totalStocks),
      t.recoHealth(analysis.healthScore.round()),
    ];

    final checks = <String>[];
    if (analysis.lossStocks > 0) {
      checks.add(t.recoLoss(analysis.lossStocks));
    }
    if (analysis.totalStocks > 0 && analysis.biggestLoser.returnPercent < 0) {
      final sym = SymbolUtils.normalize(analysis.biggestLoser.portfolio.instrument);
      checks.add(t.recoLargestFall(sym, Formatters.percent(analysis.biggestLoser.returnPercent, signed: true)));
    }
    if (analysis.unpricedStocks > 0) {
      checks.add(t.recoUnpriced(analysis.unpricedStocks));
    } else if (analysis.staleStocks > 0) {
      checks.add(t.recoStale(analysis.staleStocks));
    }
    if (checks.isEmpty) {
      checks.add(t.recoNoneBelow);
    }

    return AIRecommendation(
      recommendation: state,
      title: title,
      summary: summary,
      reasons: reasons,
      actions: checks,
    );
  }
}
