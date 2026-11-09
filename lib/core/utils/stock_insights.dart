/// One corner of the radar. [value] is 0-100, null when the data is missing (shown as "—").
class RadarAxis {
  final String shortLabel;
  final String label;
  final double? value;
  const RadarAxis(this.shortLabel, this.label, this.value);
}

/// Facts about one stock from ScreenerFundamentals and TechnicalIndicators.
class StockFacts {
  final double? debtToEquity;
  final double? roce;
  final double? profitGrowth5Y;
  final double? pledged;
  final double? pat12m;
  final double? ema50;
  final double? ema200;
  final bool insurer;

  const StockFacts({
    this.insurer = false,
    this.debtToEquity,
    this.roce,
    this.profitGrowth5Y,
    this.pledged,
    this.pat12m,
    this.ema50,
    this.ema200,
  });
}

class StockBadge {
  final String label;
  final bool caution;
  const StockBadge(this.label, {this.caution = false});
}

class StockInsights {
  const StockInsights._();

  static const debtFreeMax = 0.05;
  static const highRoce = 20.0;
  static const highProfitGrowth = 15.0;
  static const highPledge = 25.0;

  /// An insurer's balance sheet is policy liabilities, so a near-zero D/E does not mean debt-free.
  /// "Insurance Brokers" are ordinary intermediaries and stay out of this.
  static bool isInsurer(String? category, String? peerIndustry) =>
      category?.toUpperCase() == 'INSURANCE' || (peerIndustry ?? '').startsWith('Insurance - ');

  /// The score's own note when a large pledge was checked against exchange filings and not counted as risk.
  static bool pledgeReviewed(Map<String, dynamic>? breakdown) =>
      ((breakdown?['notes'] as List?) ?? const []).any((n) => n.toString().contains('not counted as a high-risk pledge'));

  static const maxTechnicalAge = Duration(days: 10);

  /// An old indicator row must not claim today's trend.
  static bool isRecent(DateTime? asOf, DateTime now) => asOf != null && now.difference(asOf) <= maxTechnicalAge;

  static List<Map> _parts(Map? pillar) => ((pillar?['parts'] as List?) ?? const []).whereType<Map>().toList();

  static Map? _pillar(Map<String, dynamic>? breakdown, String key) {
    for (final p in (breakdown?['pillars'] as List?) ?? const []) {
      if (p is Map && p['key'] == key) return p;
    }
    return null;
  }

  /// Banks and NBFCs are scored on ROE, ROA, NIM and leverage instead of ROCE and debt.
  static bool isLender(Map<String, dynamic>? breakdown) =>
      _parts(_pillar(breakdown, 'quality')).any((p) => p['label'] == 'Return on equity');

  static bool _hasData(String status) => status == 'VALID' || status.startsWith('CONFIRMED_FAIL');

  static double? _partValue(Map part) {
    final points = part['points'];
    final max = part['max'];
    if (!_hasData(part['status']?.toString() ?? '') || points is! num || max is! num || max <= 0) return null;
    return (points / max * 100).clamp(0, 100).toDouble();
  }

  static double? _pillarValue(Map? pillar) {
    final parts = _parts(pillar);
    final score = pillar?['score'];
    if (score is! num || parts.isEmpty || !parts.any((p) => _hasData(p['status']?.toString() ?? ''))) return null;
    return score.clamp(0, 100).toDouble();
  }

  /// The radar's corners from the score breakdown: exactly what the score used, nothing recalculated.
  /// A part this stock is not scored on is left out; a part with no data stays, as null.
  static List<RadarAxis> radarAxes(Map<String, dynamic>? breakdown) {
    final quality = _pillar(breakdown, 'quality');
    final parts = _parts(quality);
    if (parts.isEmpty || parts.any((p) => p['label'] == 'ETF')) return const [];
    final lender = isLender(breakdown);
    const lenderSpec = [
      ('ROE', 'Return on equity'),
      ('ROA', 'Return on assets'),
      ('NIM', 'Net interest margin'),
      ('Leverage', 'Leverage'),
      ('Growth', 'Growth'),
    ];
    const companySpec = [
      ('ROCE', 'Return on capital'),
      ('Debt', 'Debt'),
      ('Cash', 'Cash conversion'),
      ('Growth', 'Growth'),
    ];
    final axes = <RadarAxis>[];
    for (final (short, label) in lender ? lenderSpec : companySpec) {
      for (final p in parts) {
        if (p['label'] == label) axes.add(RadarAxis(short, label, _partValue(p)));
      }
    }
    axes.add(RadarAxis('Valuation', 'Valuation', _pillarValue(_pillar(breakdown, 'valuation'))));
    if (!lender) axes.add(RadarAxis('Momentum', 'Momentum', _pillarValue(_pillar(breakdown, 'momentum'))));
    return axes;
  }

  /// A shape drawn from fewer than four real numbers would mislead more than it shows.
  static bool canDrawRadar(List<RadarAxis> axes) =>
      axes.length >= 3 && axes.where((a) => a.value != null).length >= 4;

  static String _n(double v, [int digits = 0]) => v.toStringAsFixed(digits);

  /// Plain statements of fact with the number in them. Nothing that reads as a call on the stock.
  static List<StockBadge> badges(StockFacts? f, {required bool lender, bool pledgeReviewed = false}) {
    if (f == null) return const [];
    final out = <StockBadge>[];
    final de = f.debtToEquity;
    if (!lender && !f.insurer && de != null && de >= 0 && de <= debtFreeMax) {
      out.add(StockBadge('Debt-free (D/E ${_n(de, 2)})'));
    }
    final roce = f.roce;
    final growth = f.profitGrowth5Y;
    if (!lender && roce != null && growth != null && roce >= highRoce && growth >= highProfitGrowth) {
      out.add(StockBadge('ROCE ${_n(roce)}% · profit growth ${_n(growth)}%'));
    }
    final e50 = f.ema50;
    final e200 = f.ema200;
    if (e50 != null && e200 != null && e50 > 0 && e200 > 0 && e50 > e200) {
      out.add(const StockBadge('50-EMA above 200-EMA'));
    }
    final pledged = f.pledged;
    if (pledged != null && pledged >= highPledge) {
      out.add(pledgeReviewed
          ? StockBadge('Promoter pledge ${_n(pledged)}% · filings checked')
          : StockBadge('Promoter pledge ${_n(pledged)}%', caution: true));
    }
    final pat = f.pat12m;
    if (pat != null && pat < 0) {
      out.add(const StockBadge('Loss-making (12M)', caution: true));
    }
    return out;
  }
}
