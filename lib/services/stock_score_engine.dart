import '../core/utils/symbol_utils.dart';
import '../models/live_portfolio.dart';
import '../models/stock_score.dart';

class StockScoreEngine {
  const StockScoreEngine();

  List<StockScore> portfolioScores(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    final Map<String, StockScore> scoreMap = {};

    for (final score in scores) {
      final key = score.instrument
          .toUpperCase()
          .replaceAll(".NS", "");

      scoreMap[key] = score;
    }

    final List<StockScore> result = [];

    for (final holding in portfolio) {
      final symbol = holding.portfolio.instrument
          .toUpperCase()
          .replaceAll("-BE", "")
          .replaceAll(".NS", "");

      if (scoreMap.containsKey(symbol)) {
        result.add(scoreMap[symbol]!);
      }
    }
    return result;
  }

  StockScore getTopOpportunity(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    final portfolioOnly = portfolioScores(portfolio, scores)
        .where((s) => s.overallScore != null)
        .toList();

    if (portfolioOnly.isEmpty) {
      final scoredOnly = scores.where((s) => s.overallScore != null).toList();
      if (scoredOnly.isNotEmpty) {
        final sorted = List<StockScore>.from(scoredOnly)
          ..sort((a, b) => (b.overallScore ?? -1).compareTo(a.overallScore ?? -1));
        return sorted.first;
      }
      return StockScore.empty();
    }

    portfolioOnly.sort(
      (a, b) => (b.overallScore ?? -1).compareTo(a.overallScore ?? -1),
    );

    return portfolioOnly.first;
  }

  StockScore getWeakestHolding(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    final portfolioOnly = portfolioScores(portfolio, scores)
        .where((s) => s.overallScore != null)
        .toList();

    if (portfolioOnly.isEmpty) {
      final scoredOnly = scores.where((s) => s.overallScore != null).toList();
      if (scoredOnly.isNotEmpty) {
        final sorted = List<StockScore>.from(scoredOnly)
          ..sort((a, b) => (a.overallScore ?? 999).compareTo(b.overallScore ?? 999));
        return sorted.first;
      }
      return StockScore.empty();
    }

    portfolioOnly.sort(
      (a, b) => (a.overallScore ?? 999).compareTo(b.overallScore ?? 999),
    );

    return portfolioOnly.first;
  }

  double getAverageScore(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    if (portfolio.isEmpty || scores.isEmpty) {
      return 0;
    }

    final scoreMap = {
      for (final s in scores) SymbolUtils.normalize(s.instrument): s,
    };

    double weighted = 0;
    double totalValue = 0;

    for (final h in portfolio) {
      final key = SymbolUtils.normalize(h.portfolio.instrument);
      final s = scoreMap[key];
      if (s == null || s.overallScore == null) continue;

      final val = h.currentValue > 0 ? h.currentValue : h.portfolio.totalInvested;
      if (val <= 0) continue;

      weighted += s.overallScore! * val;
      totalValue += val;
    }

    return totalValue == 0 ? 0 : (weighted / totalValue);
  }

  /// Value-weighted share of the scoring inputs that were actually available
  /// (backend DataCoverage, stored in StockScores.Confidence). Excluded stocks
  /// carry no coverage, so they are skipped. Null when nothing is scored.
  double? getDataCoverage(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    final scoreMap = {
      for (final s in scores) SymbolUtils.normalize(s.instrument): s,
    };

    double weighted = 0;
    double totalValue = 0;

    for (final h in portfolio) {
      final s = scoreMap[SymbolUtils.normalize(h.portfolio.instrument)];
      if (s == null || s.overallScore == null) continue;

      final val = h.currentValue > 0 ? h.currentValue : h.portfolio.totalInvested;
      if (val <= 0) continue;

      weighted += s.confidence * val;
      totalValue += val;
    }

    return totalValue == 0 ? null : (weighted / totalValue);
  }

  int strongBuyCount(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    return portfolioScores(portfolio, scores)
        .where(
          (e) {
            final rec = e.recommendation.toLowerCase();
            return rec.contains("strong") || rec.contains("outperform");
          },
        )
        .length;
  }

  int buyCount(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    return portfolioScores(portfolio, scores)
        .where(
          (e) {
            final rec = e.recommendation.toLowerCase();
            return rec.contains("outperform") ||
                rec.contains("strength") ||
                rec == "buy" ||
                rec == "accumulate";
          },
        )
        .length;
  }

  int sellCount(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    return portfolioScores(portfolio, scores)
        .where(
          (e) {
            final rec = e.recommendation.toLowerCase();
            return rec.contains("high risk") ||
                rec.contains("underperform") ||
                rec == "sell";
          },
        )
        .length;
  }

  List<StockScore> highRiskStocks(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    return portfolioScores(portfolio, scores)
        .where((e) => e.risk <= 2 || (e.overallScore != null && e.overallScore! < 45))
        .toList();
  }

  List<StockScore> lowConfidenceStocks(
    List<LivePortfolio> portfolio,
    List<StockScore> scores,
  ) {
    return portfolioScores(portfolio, scores)
        .where((e) => e.confidence < 60)
        .toList();
  }
}

int calculateScore(StockScore stock) {
  final baseOverall = stock.overallScore;
  if (baseOverall != null) return baseOverall;

  final score =
      (stock.businessQuality * 0.25) +
      (stock.financialStrength * 0.25) +
      (stock.growth * 0.20) +
      (stock.technical * 0.15) +
      (stock.valuation * 0.10) -
      (stock.risk * 0.05);

  return score.round().clamp(0, 100);
}