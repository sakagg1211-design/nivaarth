import '../../models/live_portfolio.dart';

/// One sector of the user's holdings today. [weight] is its share of the portfolio's value,
/// [change] the value-weighted percent move since the previous close.
class SectorMove {
  final String label;
  final double weight;
  final double change;
  final int stocks;
  const SectorMove(this.label, this.weight, this.change, this.stocks);
}

class TodayMoves {
  const TodayMoves._();

  static const others = 'Others';

  /// Largest sectors first; past [maxGroups] the smallest fold into Others, which always comes last.
  static List<SectorMove> sectors(
    Iterable<({String sector, double value, double todayPL})> items, {
    int maxGroups = 8,
  }) {
    final value = <String, double>{};
    final pl = <String, double>{};
    final count = <String, int>{};
    var total = 0.0;
    for (final i in items) {
      if (i.value <= 0) continue;
      value[i.sector] = (value[i.sector] ?? 0) + i.value;
      pl[i.sector] = (pl[i.sector] ?? 0) + i.todayPL;
      count[i.sector] = (count[i.sector] ?? 0) + 1;
      total += i.value;
    }
    if (total <= 0) return const [];
    SectorMove make(String label, double v, double p, int n) =>
        SectorMove(label, v / total * 100, v - p > 0 ? p / (v - p) * 100 : 0, n);

    final named = value.keys.where((k) => k != others).toList()..sort((a, b) => value[b]!.compareTo(value[a]!));
    final kept = named.take(maxGroups - 1).toList();
    var restValue = value[others] ?? 0.0, restPl = pl[others] ?? 0.0;
    var restCount = count[others] ?? 0;
    if (named.length == maxGroups && restCount == 0) {
      kept.add(named.last); // exactly enough room: no need for an Others box
    } else {
      for (final k in named.skip(maxGroups - 1)) {
        restValue += value[k]!;
        restPl += pl[k]!;
        restCount += count[k]!;
      }
    }
    return [
      for (final k in kept) make(k, value[k]!, pl[k]!, count[k]!),
      if (restCount > 0) make(others, restValue, restPl, restCount),
    ];
  }

  static List<LivePortfolio> _priced(Iterable<LivePortfolio> h) => h.where((x) => !x.isPriceUnavailable).toList();

  static List<LivePortfolio> gainers(Iterable<LivePortfolio> holdings, {int limit = 5}) =>
      (_priced(holdings).where((h) => h.todayReturnPercent > 0).toList()
            ..sort((a, b) => b.todayReturnPercent.compareTo(a.todayReturnPercent)))
          .take(limit)
          .toList();

  static List<LivePortfolio> losers(Iterable<LivePortfolio> holdings, {int limit = 5}) =>
      (_priced(holdings).where((h) => h.todayReturnPercent < 0).toList()
            ..sort((a, b) => a.todayReturnPercent.compareTo(b.todayReturnPercent)))
          .take(limit)
          .toList();
}
