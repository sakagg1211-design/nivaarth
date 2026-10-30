import '../core/utils/formatters.dart';
import '../core/utils/symbol_utils.dart';
import '../models/ai_recommendation.dart';
import '../models/portfolio_analysis.dart';

/// Dashboard "NV Verdict": a factual summary of the portfolio's numbers. It states what the
/// data shows and what to look at; it never tells the user to buy, sell, hold or add.
class RecommendationEngine {
  AIRecommendation generate(
    PortfolioAnalysis analysis,
  ) {
    final RecommendationType state;
    final String title;
    final String summary;
    final ret = analysis.returnPercent;
    final retText = Formatters.percent(ret, signed: true);

    if (ret >= 20 && analysis.healthScore >= 80) {
      state = RecommendationType.strong;
      title = 'Strong Returns';
      summary = 'Your holdings are $retText above their total cost.';
    } else if (ret >= 10) {
      state = RecommendationType.healthy;
      title = 'Positive Returns';
      summary = 'Your holdings are $retText above their total cost.';
    } else if (ret >= 0) {
      state = RecommendationType.stable;
      title = 'Near Cost';
      summary = 'Your holdings are $retText against their total cost.';
    } else if (ret >= -10) {
      state = RecommendationType.drawdown;
      title = 'Mild Drawdown';
      summary = 'Your holdings are $retText below their total cost.';
    } else {
      state = RecommendationType.deepDrawdown;
      title = 'Below Cost';
      summary = 'Your holdings are $retText below their total cost.';
    }

    final reasons = <String>[
      'Overall return: $retText.',
      '${analysis.profitStocks} of ${analysis.totalStocks} holdings are above their buy price.',
      'NV Health Index ${analysis.healthScore.round()}/100 (value-weighted average NV Score).',
    ];

    final checks = <String>[];
    if (analysis.lossStocks > 0) {
      checks.add('${analysis.lossStocks} holdings are below their buy price; each one\'s "Why this score" shows its lowest pillar.');
    }
    if (analysis.totalStocks > 0 && analysis.biggestLoser.returnPercent < 0) {
      final sym = SymbolUtils.normalize(analysis.biggestLoser.portfolio.instrument);
      checks.add('Largest fall: $sym (${Formatters.percent(analysis.biggestLoser.returnPercent, signed: true)}).');
    }
    if (analysis.unpricedStocks > 0) {
      checks.add('${analysis.unpricedStocks} holdings have no current price and are left out of the totals.');
    } else if (analysis.staleStocks > 0) {
      checks.add('${analysis.staleStocks} holdings show their last saved price, not a live one.');
    }
    if (checks.isEmpty) {
      checks.add('No holding is below its buy price.');
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
