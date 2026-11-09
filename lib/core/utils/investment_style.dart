/// One holding with its size row and style column (table StockStyle, migration 27).
class StyleStock {
  final String symbol;
  final double value;
  final String tier;
  final String style;
  final double? growthRank;
  final double? valueRank;
  const StyleStock(this.symbol, this.value, this.tier, this.style, {this.growthRank, this.valueRank});
}

/// The Large/Mid/Small/Micro by style grid, every figure a percent of the whole portfolio.
class StyleGrid {
  static const rows = ['Large', 'Mid', 'Small', 'Micro'];
  static const cols = ['Growth', 'Growth+Value', 'Value', 'Others'];
  static const fund = 'Fund';
  static const lossMaking = 'Loss-making';
  static const notClassified = 'Not classified';

  final List<List<double>> percent;
  final List<List<List<StyleStock>>> stocks;
  final double funds;
  final double loss;
  final double unclassified;
  final double total;

  const StyleGrid._(this.percent, this.stocks, this.funds, this.loss, this.unclassified, this.total);

  double rowTotal(int r) => percent[r].fold(0, (a, b) => a + b);
  double colTotal(int c) => percent.fold(0, (a, r) => a + r[c]);

  /// The largest cell as (row, column), or null when nothing lands in the grid.
  (int, int)? get largest {
    (int, int)? at;
    var best = 0.0;
    for (var r = 0; r < rows.length; r++) {
      for (var c = 0; c < cols.length; c++) {
        if (percent[r][c] > best) {
          best = percent[r][c];
          at = (r, c);
        }
      }
    }
    return at;
  }

  double weight(StyleStock s) => total > 0 ? s.value / total * 100 : 0;

  factory StyleGrid.build(List<StyleStock> holdings) {
    final total = holdings.fold<double>(0, (a, h) => a + (h.value > 0 ? h.value : 0));
    double pct(double v) => total > 0 ? v / total * 100 : 0;
    final cells = [
      for (var r = 0; r < rows.length; r++) [for (var c = 0; c < cols.length; c++) <StyleStock>[]],
    ];
    var funds = 0.0, loss = 0.0, unclassified = 0.0;
    for (final h in holdings) {
      if (h.value <= 0) continue;
      final r = rows.indexOf(h.tier);
      final c = cols.indexOf(h.style);
      if (r >= 0 && c >= 0) {
        cells[r][c].add(h);
      } else if (h.style == fund) {
        funds += h.value;
      } else if (h.style == lossMaking) {
        loss += h.value;
      } else {
        unclassified += h.value;
      }
    }
    for (final row in cells) {
      for (final cell in row) {
        cell.sort((a, b) => b.value.compareTo(a.value));
      }
    }
    return StyleGrid._(
      [
        for (final row in cells) [for (final cell in row) pct(cell.fold<double>(0, (a, h) => a + h.value))],
      ],
      cells,
      pct(funds),
      pct(loss),
      pct(unclassified),
      total,
    );
  }
}
