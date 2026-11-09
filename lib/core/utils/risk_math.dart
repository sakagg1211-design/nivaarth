import 'allocation_math.dart';
import '../../l10n/app_localizations.dart';

/// One position for the what-if and stress sums. [beta] is null when it is not known.
class RiskHolding {
  final String symbol;
  final double value;
  final double? beta;
  final String sector;

  /// Null for funds and when Screener has none; zero or less for a loss-maker.
  final double? pe;
  const RiskHolding(this.symbol, this.value, this.beta, this.sector, {this.pe});
}

class RiskSnapshot {
  final double total;
  final double? beta;
  final double coveredValue;
  final int uncoveredCount;
  final Map<String, double> stockWeight;
  final Map<String, double> sectorWeight;

  const RiskSnapshot({
    required this.total,
    required this.beta,
    required this.coveredValue,
    required this.uncoveredCount,
    required this.stockWeight,
    required this.sectorWeight,
  });

  /// Share of the portfolio's value that has a beta, in percent.
  double get coveragePct => total > 0 ? coveredValue / total * 100 : 0;
}

class StressLine {
  final String symbol;
  final double change;
  const StressLine(this.symbol, this.change);
}

class StressResult {
  final double change;
  final double changePct;
  final double coveredValue;
  final int uncoveredCount;
  final List<StressLine> lines;
  const StressResult(this.change, this.changePct, this.coveredValue, this.uncoveredCount, this.lines);
}

class RiskMath {
  const RiskMath._();

  static const stockLimit = 15.0;
  static const sectorLimit = 30.0;

  static RiskSnapshot snapshot(List<RiskHolding> holdings) {
    var total = 0.0;
    var covered = 0.0;
    var weighted = 0.0;
    var uncovered = 0;
    final byStock = <String, double>{};
    final bySector = <String, double>{};
    for (final h in holdings) {
      if (h.value <= 0) continue;
      total += h.value;
      byStock[h.symbol] = (byStock[h.symbol] ?? 0) + h.value;
      bySector[h.sector] = (bySector[h.sector] ?? 0) + h.value;
      final b = h.beta;
      if (b == null) {
        uncovered++;
      } else {
        covered += h.value;
        weighted += h.value * b;
      }
    }
    Map<String, double> pct(Map<String, double> m) =>
        {for (final e in m.entries) e.key: total > 0 ? e.value / total * 100 : 0.0};
    return RiskSnapshot(
      total: total,
      beta: covered > 0 ? weighted / covered : null,
      coveredValue: covered,
      uncoveredCount: uncovered,
      stockWeight: pct(byStock),
      sectorWeight: pct(bySector),
    );
  }

  /// Total value over total earnings, the only way P/Es add up across holdings. Loss-makers and
  /// funds have no usable P/E, so they are left out and counted.
  static ({double? pe, int excluded, double coveragePct}) portfolioPe(List<RiskHolding> holdings) {
    var total = 0.0, covered = 0.0, earnings = 0.0;
    var excluded = 0;
    for (final h in holdings) {
      if (h.value <= 0) continue;
      total += h.value;
      final pe = h.pe;
      if (pe == null || pe <= 0) {
        excluded++;
      } else {
        covered += h.value;
        earnings += h.value / pe;
      }
    }
    return (pe: earnings > 0 ? covered / earnings : null, excluded: excluded, coveragePct: total > 0 ? covered / total * 100 : 0);
  }

  /// Estimated change if the market falls [fallPct] percent: value x beta x fall for each position
  /// with a beta, never more than the position itself. Positions without a beta are left out and counted.
  static StressResult stress(List<RiskHolding> holdings, double fallPct) {
    var change = 0.0;
    var covered = 0.0;
    var uncovered = 0;
    final lines = <StressLine>[];
    for (final h in holdings) {
      if (h.value <= 0) continue;
      final b = h.beta;
      if (b == null) {
        uncovered++;
        continue;
      }
      final move = -h.value * b * fallPct / 100;
      final capped = move < -h.value ? -h.value : move;
      change += capped;
      covered += h.value;
      lines.add(StressLine(h.symbol, capped));
    }
    lines.sort((a, b) => a.change.compareTo(b.change));
    return StressResult(change, covered > 0 ? change / covered * 100 : 0, covered, uncovered, lines);
  }

  /// The portfolio with [delta] rupees added to (or, if negative, taken from) [symbol].
  static List<RiskHolding> applyChange(
    List<RiskHolding> holdings,
    String symbol, {
    required double delta,
    required double? beta,
    required String sector,
  }) {
    final out = <RiskHolding>[];
    var found = false;
    for (final h in holdings) {
      if (h.symbol == symbol) {
        found = true;
        final v = h.value + delta;
        if (v > 0) out.add(RiskHolding(h.symbol, v, h.beta, h.sector, pe: h.pe));
      } else {
        out.add(h);
      }
    }
    if (!found && delta > 0) out.add(RiskHolding(symbol, delta, beta, sector));
    return out;
  }

  /// Plain statements for the lines this stock and sector would be over. A fund already holds many
  /// companies, and "Others" is not a sector, so neither is measured against these lines.
  static List<String> warnings(RiskSnapshot s, String symbol, String sector, AppLocalizations t) {
    final out = <String>[];
    if (sector == AllocationMath.etf) return out;
    final w = s.stockWeight[symbol] ?? 0;
    final sw = s.sectorWeight[sector] ?? 0;
    if (w > stockLimit) {
      out.add(t.riskWarnStock(symbol, w.toStringAsFixed(1), stockLimit.toStringAsFixed(0)));
    }
    if (sector != AllocationMath.others && sw > sectorLimit) {
      out.add(t.riskWarnStock(sector, sw.toStringAsFixed(1), sectorLimit.toStringAsFixed(0)));
    }
    return out;
  }
}
