import '../../models/live_portfolio.dart';
import '../../models/stock_score.dart';
import 'symbol_utils.dart';

class HoldingScore {
  final String symbol;
  final int? score;
  final double value;
  const HoldingScore(this.symbol, this.score, this.value);
}

class HealthRow {
  final String symbol;
  final int? score;
  final double weightPct;
  const HealthRow(this.symbol, this.score, this.weightPct);
}

/// Each holding's NV Score and value, on the same rule PortfolioHealthEngine uses: current value,
/// or invested amount when there is no price.
List<HoldingScore> holdingScoresFrom(List<LivePortfolio> holdings, List<StockScore> scores) {
  final bySymbol = {for (final s in scores) SymbolUtils.normalize(s.instrument): s.overallScore};
  return [
    for (final h in holdings)
      HoldingScore(
        SymbolUtils.normalize(h.portfolio.instrument),
        bySymbol[SymbolUtils.normalize(h.portfolio.instrument)],
        h.currentValue > 0 ? h.currentValue : h.portfolio.totalInvested,
      ),
  ];
}

/// Value-weighted average NV Score of the scored holdings; null when none is scored.
double? weightedHealth(List<HoldingScore> s) {
  final scored = s.where((x) => x.score != null && x.value > 0);
  final total = scored.fold<double>(0, (a, x) => a + x.value);
  if (total == 0) return null;
  return scored.fold<double>(0, (a, x) => a + x.score! * x.value) / total;
}

/// Lowest score first, so what holds the number down is on top; unscored holdings last at 0%.
List<HealthRow> healthRows(List<HoldingScore> s) {
  final total = s.where((x) => x.score != null && x.value > 0).fold<double>(0, (a, x) => a + x.value);
  final rows = [
    for (final x in s) HealthRow(x.symbol, x.score, x.score != null && total > 0 ? x.value / total * 100 : 0),
  ];
  rows.sort((a, b) {
    if (a.score == null) return b.score == null ? 0 : 1;
    if (b.score == null) return -1;
    return a.score!.compareTo(b.score!);
  });
  return rows;
}
