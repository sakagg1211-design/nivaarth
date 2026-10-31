import '../../models/stock_score.dart';
import 'symbol_utils.dart';

class VerdictSignal {
  final String title;
  final String description;
  final String scoreLabel;
  final bool isPositive;

  const VerdictSignal({
    required this.title,
    required this.description,
    required this.scoreLabel,
    required this.isPositive,
  });
}

/// Factual lines for the card: what the numbers show, which number to watch, what updates them.
/// Never an instruction to buy, sell, hold, add or trim.
class TacticalPlaybook {
  final String dataShows;
  final String toWatch;
  final String updatesWith;

  const TacticalPlaybook({
    required this.dataShows,
    required this.toWatch,
    required this.updatesWith,
  });
}

class VerdictNarrative {
  final String archetypeTag;
  final String archetypeIcon;
  final String analystBriefing;
  final VerdictSignal primaryCatalyst;
  final VerdictSignal primaryRisk;
  final TacticalPlaybook playbook;
  final String profileLabel;

  const VerdictNarrative({
    required this.archetypeTag,
    required this.archetypeIcon,
    required this.analystBriefing,
    required this.primaryCatalyst,
    required this.primaryRisk,
    required this.playbook,
    required this.profileLabel,
  });
}

class VerdictNarrativeEngine {
  const VerdictNarrativeEngine._();

  static VerdictNarrative generate({
    required StockScore score,
    String? companyName,
    String? sector,
    String? industry,
    bool isOwned = false,
  }) {
    final cleanSym = SymbolUtils.normalize(score.instrument).toUpperCase();
    final isEtf = SymbolUtils.isEtf(cleanSym);

    final resolvedName = (companyName != null &&
            companyName.trim().isNotEmpty &&
            companyName.trim().toUpperCase() != cleanSym)
        ? companyName.trim()
        : (score.companyName.trim().isNotEmpty &&
                score.companyName.trim().toUpperCase() != cleanSym)
            ? score.companyName.trim()
            : SymbolUtils.getDisplayName(cleanSym);

    // Prevent duplicate ticker like "Infibeam Avenues (CCAVENUE) (CCAVENUE)"
    final displayName = resolvedName.toUpperCase().contains(cleanSym)
        ? resolvedName
        : '$resolvedName ($cleanSym)';

    final resolvedSector = SymbolUtils.getSector(cleanSym, dbSector: sector);

    // -------------------------------------------------------------
    // 1. ETF / COMMODITY / BASKET ASSET PATH
    // -------------------------------------------------------------
    if (isEtf) {
      return VerdictNarrative(
        archetypeTag: 'Exchange-Traded Fund',
        archetypeIcon: '🧺',
        analystBriefing: '$displayName is an exchange-traded fund that tracks $resolvedSector. Its price follows the '
            'underlying basket, so company-level ratios such as ROCE do not apply; the NV Score gives it a fixed '
            'quality of 75 and valuation of 60 and scores only its 12-month return rank.',
        primaryCatalyst: const VerdictSignal(
          title: 'Diversified basket',
          description: 'Holds many securities (or a commodity), so the results of one company move it less than a single stock.',
          scoreLabel: 'ETF',
          isPositive: true,
        ),
        primaryRisk: const VerdictSignal(
          title: 'Moves with its benchmark',
          description: 'Returns follow the index or commodity it tracks, including its falls.',
          scoreLabel: 'ETF',
          isPositive: false,
        ),
        playbook: TacticalPlaybook(
          dataShows: isOwned
              ? 'In your portfolio. NV Score ${score.overallScore ?? '—'}/100, set mostly by its 12-month return rank.'
              : 'NV Score ${score.overallScore ?? '—'}/100, set mostly by its 12-month return rank.',
          toWatch: 'Tracking difference against its benchmark and the expense ratio (from the fund house factsheet).',
          updatesWith: 'Daily closing prices update the 12-month return rank.',
        ),
        profileLabel: 'Exchange-Traded Fund',
      );
    }

    // -------------------------------------------------------------
    // 1B. EXCLUDED ASSET CLASS PATH (HOLDING CO, INSURANCE, REIT)
    // -------------------------------------------------------------
    if (score.isExcluded) {
      final rec = score.recommendation.toUpperCase();

      // Source data failed the exchange cross-check: say so plainly, no asset-class story
      if (rec.contains('DATA REVIEW')) {
        return VerdictNarrative(
          archetypeTag: 'Data Under Review',
          archetypeIcon: '🔍',
          analystBriefing: 'The fundamentals we hold for $displayName did not match exchange data: the market '
              'cap or price belongs to a different company. The score is withheld until the data is corrected.',
          primaryCatalyst: const VerdictSignal(
            title: 'What we checked',
            description: 'Stored market cap and price were compared with the NSE closing price and an independent market-cap source.',
            scoreLabel: 'Check: Failed',
            isPositive: false,
          ),
          primaryRisk: const VerdictSignal(
            title: 'Why no score',
            description: 'A score built on another company\'s numbers would be misleading, so none is shown.',
            scoreLabel: 'Score: Withheld',
            isPositive: false,
          ),
          playbook: TacticalPlaybook(
            dataShows: isOwned
                ? 'Currently in your portfolio. Your holding, price and P&L are unaffected; only the NV Score is withheld.'
                : 'Only the NV Score is withheld; the live price is unaffected.',
            toWatch: 'Check the company\'s latest results on the NSE / BSE website until the data is corrected.',
            updatesWith: 'The score returns automatically once the data passes the check.',
          ),
          profileLabel: 'Data Under Review',
        );
      }

      final isHold = rec.contains('HOLDING');
      final isIns = rec.contains('INSURANCE');
      final isReit = rec.contains('REIT') || rec.contains('INVIT');

      final archetype = isHold
          ? 'Investment Holding Company (SOTP Required)'
          : (isIns
              ? 'Actuarial Underwriting Entity (EV Model Required)'
              : (isReit
                  ? 'Yield Distribution Trust (NAV Required)'
                  : 'Specialized Asset Class (Score Excluded)'));

      final icon = isHold ? '🏢' : (isIns ? '☂️' : (isReit ? '🏗️' : '📋'));

      return VerdictNarrative(
        archetypeTag: archetype,
        archetypeIcon: icon,
        analystBriefing: score.analystVerdict?.trim().isNotEmpty == true
            ? score.analystVerdict!.trim()
            : (isHold
                ? '$displayName functions as an equity investment holding company. Standard operating ROCE and P/E ratios are mathematically distorted by holding company discounts and non-operating dividend income. Valuation must be assessed via Sum-of-the-Parts (SOTP) net asset value.'
                : (isIns
                    ? '$displayName operates an actuarial insurance underwriting portfolio. Statutory accounting and premium float dynamics make industrial ROCE metrics non-applicable; valuation is driven by Value of New Business (VNB) margins and Embedded Value (EV).'
                    : '$displayName is a structured trust vehicle distributing rental/infrastructure cash flows. Standard industrial scoring is withheld in favor of Net Asset Value (NAV) and distribution yield.')),
        primaryCatalyst: VerdictSignal(
          title: isHold ? 'Underlying Portfolio Holdings NAV' : (isIns ? 'Float Compounding & VNB Expansion' : 'Predictable Distribution Yield'),
          description: isHold
              ? 'Value realization is linked to the market capitalization growth of listed subsidiaries and unlisted associates.'
              : (isIns
                  ? 'Long-duration customer float and growing policyholder retention fuel actuarial book value expansion.'
                  : 'High dividend payout mandates and pass-through tax structures provide tangible cash distribution.'),
          scoreLabel: 'Coverage: Specialized',
          isPositive: true,
        ),
        primaryRisk: VerdictSignal(
          title: isHold ? 'Holding Company Discount Persistence' : (isIns ? 'Actuarial Claims / Surrender Risk' : 'Interest Rate Sensitivity'),
          description: isHold
              ? 'Holding company share prices often trade below the value of their underlying holdings; the gap varies by company and over time.'
              : (isIns
                  ? 'Regulatory commission caps and sudden mortality/morbidity claims spikes can pressure quarterly margins.'
                  : 'Rising benchmark yields increase the discount rate and compress trust capital value.'),
          scoreLabel: 'Risk: Specialized',
          isPositive: false,
        ),
        playbook: TacticalPlaybook(
          dataShows: isOwned
              ? 'Currently in your portfolio. The 1-100 score is not calculated for this category; review it on the metrics listed below.'
              : 'The 1-100 score is not calculated for this category because standard operating ratios do not apply.',
          toWatch:
              'Relevant metrics for this category: NAV discount (holding companies), EV / VNB (insurance), distribution yield (REITs / InvITs).',
          updatesWith: isHold
              ? 'Market value of core subsidiary holdings and parent capital allocation track record.'
              : (isIns ? 'VNB margins, persistency ratios, and solvency margin ratio.' : 'Occupancy rates, weighted average lease expiry (WALE), and yield spreads over G-Sec.'),
        ),
        profileLabel: 'Specialized Asset Class (Score Excluded)',
      );
    }

    // -------------------------------------------------------------
    // 2. EQUITIES: built only from the score breakdown (no stories, no advice)
    // -------------------------------------------------------------
    final b = score.scoreBreakdown;
    final pillars = ((b?['pillars'] as List?) ?? const [])
        .whereType<Map>()
        .map((p) => Map<String, dynamic>.from(p))
        .toList();
    final scored = pillars.where((p) => p['score'] is num).toList()
      ..sort((x, y) => (y['score'] as num).compareTo(x['score'] as num));
    final overall = score.overallScore;

    if (b == null || scored.isEmpty || overall == null) {
      return VerdictNarrative(
        archetypeTag: 'Score Profile',
        archetypeIcon: '📊',
        analystBriefing: overall == null
            ? '$displayName has no NV Score yet.'
            : '$displayName has an NV Score of $overall/100. The pillar-by-pillar breakdown appears after the next score update.',
        primaryCatalyst: const VerdictSignal(
          title: 'Breakdown pending',
          description: 'Quality, valuation and price-trend details load with the next nightly score update.',
          scoreLabel: '—',
          isPositive: true,
        ),
        primaryRisk: const VerdictSignal(
          title: 'Breakdown pending',
          description: 'No pillar data to compare yet.',
          scoreLabel: '—',
          isPositive: false,
        ),
        playbook: TacticalPlaybook(
          dataShows: isOwned ? 'In your portfolio. NV Score ${overall ?? '—'}/100.' : 'NV Score ${overall ?? '—'}/100.',
          toWatch: 'The breakdown below the score shows which pillar moves it.',
          updatesWith: _updatesWith,
        ),
        profileLabel: _profileLabel(score),
      );
    }

    final strongest = scored.first;
    final weakest = scored.last;
    final hurdle = b['hurdle_factor'] as num?;
    final qualityCap = b['quality_cap'];
    final riskCap = b['risk_cap'];
    final cap = b['provisional_cap'];

    final briefing = StringBuffer('$displayName has an NV Score of $overall/100. ')
      ..write(scored.map(_pillarSummary).join('; '))
      ..write('.');
    final missing = pillars.where((p) => p['score'] is! num).map((p) => p['label']).toList();
    if (missing.isNotEmpty) {
      briefing.write(' ${missing.join(' and ')}: no data yet, so the other pillars carry its weight.');
    }
    if (riskCap != null) {
      briefing.write(' A risk check failed (pledge, net worth or debt), which caps the score at $riskCap.');
    } else if (qualityCap != null) {
      briefing.write(' Its quality pillar caps the score at $qualityCap (54 below quality 55, no cap from 65).');
    } else if (hurdle != null) {
      briefing.write(' Quality is below 55, so the weighted score is multiplied by ${hurdle.toStringAsFixed(2)}.');
    }
    if (cap != null) {
      briefing.write(' Banks, NBFCs and brokers are capped at $cap until credit data is added.');
    }

    final shows = StringBuffer(isOwned ? 'In your portfolio. ' : '')
      ..write('Highest pillar: ${_pillarSummary(strongest)}. Lowest pillar: ${_pillarSummary(weakest)}.');

    return VerdictNarrative(
      archetypeTag: _archetype(scored, riskCap != null),
      archetypeIcon: riskCap != null ? '⚠️' : '📊',
      analystBriefing: briefing.toString(),
      primaryCatalyst: VerdictSignal(
        title: 'Highest pillar: ${strongest['label']}',
        description: _partsText(strongest),
        scoreLabel: '${_num(strongest['score'])}/100',
        isPositive: true,
      ),
      primaryRisk: VerdictSignal(
        title: 'Lowest pillar: ${weakest['label']}',
        description: _partsText(weakest),
        scoreLabel: '${_num(weakest['score'])}/100',
        isPositive: false,
      ),
      playbook: TacticalPlaybook(
        dataShows: shows.toString(),
        toWatch: _toWatch(weakest),
        updatesWith: _updatesWith,
      ),
      profileLabel: _profileLabel(score),
    );
  }

  static const String _updatesWith =
      'Quarterly results update return on capital, debt, cash flow and growth; daily closing prices update '
      'valuation and the 12-month return rank.';

  static String _num(dynamic v) => v is num ? v.round().toString() : '—';

  static String _pillarSummary(Map<String, dynamic> p) => '${p['label']} ${_num(p['score'])}/100';

  /// The pillar's inputs as one sentence, e.g. "ROCE 13.4%; 0.44x debt to equity".
  static String _partsText(Map<String, dynamic> p) {
    final details = ((p['parts'] as List?) ?? const [])
        .whereType<Map>()
        .map((x) => x['detail'])
        .whereType<String>()
        .where((d) => d.isNotEmpty)
        .toList();
    return details.isEmpty ? 'No detail available for this pillar.' : '${details.join('; ')}.';
  }

  /// The lowest-scoring input of the weakest pillar: the number that holds the score down.
  static String _toWatch(Map<String, dynamic> p) {
    final parts = ((p['parts'] as List?) ?? const [])
        .whereType<Map>()
        .where((x) => x['points'] is num && x['max'] is num && x['detail'] is String)
        .toList()
      ..sort((x, y) => ((x['points'] as num) / (x['max'] as num)).compareTo((y['points'] as num) / (y['max'] as num)));
    if (parts.isEmpty) return 'The ${p['label']} pillar has the most room to move the score.';
    final low = parts.first;
    return '${low['label']} scores ${_num(low['points'])} of ${_num(low['max'])} (${low['detail']}).';
  }

  static String _archetype(List<Map<String, dynamic>> scored, bool riskFlag) {
    if (riskFlag) return 'Risk Flag';
    double? s(String key) {
      for (final p in scored) {
        if (p['key'] == key) return (p['score'] as num).toDouble();
      }
      return null;
    }

    final q = s('quality');
    final v = s('valuation');
    if (q != null && q < 55) return 'Below Quality Hurdle';
    if (q != null && q >= 70 && v != null && v >= 65) return 'Strong Quality, Lower Valuation';
    if (q != null && q >= 70 && v != null && v < 35) return 'Strong Quality, High Valuation';
    if (q != null && q >= 70) return 'Strong Quality';
    return 'Mixed Profile';
  }

  static String _profileLabel(StockScore score) {
    final o = score.overallScore;
    if (o == null) return 'Not Scored';
    if (o >= 85) return 'Score Band: Excellent';
    if (o >= 70) return 'Score Band: Strong';
    if (o >= 55) return 'Score Band: Average';
    return 'Score Band: Weak';
  }
}
