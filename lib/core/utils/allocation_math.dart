/// One group of the portfolio (Large cap, or a sector) and its share of the value.
class AllocationSlice {
  final String label;
  final double value;
  final double percent;
  final int stocks;
  const AllocationSlice(this.label, this.value, this.percent, this.stocks);
}

class AllocationMath {
  const AllocationMath._();

  static const large = 'Large cap';
  static const mid = 'Mid cap';
  static const small = 'Small cap';
  static const etf = 'ETF';
  static const unknown = 'Data nahi';
  static const others = 'Others';

  /// SEBI-style tiers by market-cap rank: rank 1-100 Large, 101-250 Mid, the rest Small.
  /// [largeCut] / [midCut] are the market caps (Rs cr) of the 100th and 250th companies.
  static String capTier(double? marketCapCr, double largeCut, double midCut, {bool isEtf = false}) {
    if (isEtf) return etf;
    if (marketCapCr == null || marketCapCr <= 0) return unknown;
    if (marketCapCr >= largeCut) return large;
    if (marketCapCr >= midCut) return mid;
    return small;
  }

  static bool isPartlyPaid(String symbol) => RegExp(r'P\d$').hasMatch(symbol.toUpperCase());

  /// Market caps of the 100th and 250th company from a list sorted largest first. Partly-paid
  /// lines (RELIANCEP1, UPLPP1) are the same company again, so they do not take a rank.
  /// Null when the list is too short to rank.
  static ({double large, double mid})? cutOffs(Iterable<({String symbol, double cap})> byCapDesc) {
    final companies = byCapDesc.where((r) => !isPartlyPaid(r.symbol)).toList();
    if (companies.length < 250) return null;
    return (large: companies[99].cap, mid: companies[249].cap);
  }

  /// ETFs and other funds carry an ISIN starting INF; company shares start INE. The symbol is
  /// used only when there is no ISIN, and never by "contains GOLD": GOLDIAM and SKYGOLD are companies.
  static bool isFund(String? isin, String? category, String symbol) {
    final code = (isin ?? '').trim().toUpperCase();
    if (code.startsWith('INF') || (category ?? '').toUpperCase() == 'ETF') return true;
    if (code.isNotEmpty) return false;
    final s = symbol.toUpperCase();
    return s.endsWith('BEES') || s.endsWith('ETF');
  }

  /// Slices by value, largest first. Groups past [maxSlices] fold into Others, so the donut stays
  /// readable and colours stay distinct.
  static List<AllocationSlice> slices(Iterable<({String group, double value})> holdings, {int? maxSlices}) {
    final values = <String, double>{};
    final counts = <String, int>{};
    var total = 0.0;
    for (final h in holdings) {
      if (h.value <= 0) continue;
      values[h.group] = (values[h.group] ?? 0) + h.value;
      counts[h.group] = (counts[h.group] ?? 0) + 1;
      total += h.value;
    }
    if (total <= 0) return const [];
    final out = [
      for (final e in values.entries) AllocationSlice(e.key, e.value, e.value / total * 100, counts[e.key]!),
    ]..sort((a, b) => b.value.compareTo(a.value));
    if (maxSlices == null || out.length <= maxSlices) return out;
    // Holdings with no sector are already an Others group; it joins the fold, never a second row
    final keep = out.where((s) => s.label != others).take(maxSlices - 1).toList();
    final rest = out.where((s) => !keep.contains(s));
    final v = rest.fold<double>(0, (s, x) => s + x.value);
    keep.add(AllocationSlice(others, v, v / total * 100, rest.fold<int>(0, (s, x) => s + x.stocks)));
    return keep;
  }
}
