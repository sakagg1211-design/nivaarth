import '../../models/stock_score.dart';
import 'symbol_utils.dart';
import '../../l10n/app_localizations.dart';

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
    required AppLocalizations t,
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
        archetypeTag: t.narrEtf,
        archetypeIcon: '🧺',
        analystBriefing: t.narrEtfBrief(displayName, resolvedSector),
        primaryCatalyst: VerdictSignal(
          title: t.narrEtfBasket,
          description: t.narrEtfBasketBody,
          scoreLabel: 'ETF',
          isPositive: true,
        ),
        primaryRisk: VerdictSignal(
          title: t.narrEtfBenchmark,
          description: t.narrEtfBenchmarkBody,
          scoreLabel: 'ETF',
          isPositive: false,
        ),
        playbook: TacticalPlaybook(
          dataShows: isOwned
              ? t.narrEtfOwned(score.overallScore ?? '—')
              : t.narrEtfNotOwned(score.overallScore ?? '—'),
          toWatch: t.narrEtfWatch,
          updatesWith: t.narrEtfUpdates,
        ),
        profileLabel: t.narrEtf,
      );
    }

    // -------------------------------------------------------------
    // 1B. EXCLUDED ASSET CLASS PATH (HOLDING CO, INSURANCE, REIT)
    // -------------------------------------------------------------
    if (score.isDataPending) {
      final why = score.pendingReason ?? t.narrNotEnough;
      return VerdictNarrative(
        archetypeTag: t.aiDataPending,
        archetypeIcon: '⏳',
        analystBriefing: t.narrPendingBrief(displayName, why),
        primaryCatalyst: VerdictSignal(
          title: t.narrMissing,
          description: t.narrMissingBody(why),
          scoreLabel: t.narrScorePending,
          isPositive: false,
        ),
        primaryRisk: VerdictSignal(
          title: t.narrWhyNoScore,
          description: t.narrNoAssumed,
          scoreLabel: t.narrInputsIncomplete,
          isPositive: false,
        ),
        playbook: TacticalPlaybook(
          dataShows: isOwned
              ? t.narrPendingOwned
              : t.narrPendingNotOwned,
          toWatch: t.narrPendingWatch,
          updatesWith: t.narrPendingUpdates,
        ),
        profileLabel: t.aiDataPending,
      );
    }

    if (score.isExcluded) {
      final rec = score.recommendation.toUpperCase();

      // Source data failed the exchange cross-check: say so plainly, no asset-class story
      if (rec.contains('DATA REVIEW')) {
        return VerdictNarrative(
          archetypeTag: t.aiDataReview,
          archetypeIcon: '🔍',
          analystBriefing: t.narrReviewBrief(displayName),
          primaryCatalyst: VerdictSignal(
            title: t.narrChecked,
            description: t.narrCheckedBody,
            scoreLabel: t.narrCheckFailed,
            isPositive: false,
          ),
          primaryRisk: VerdictSignal(
            title: t.narrWhyNoScore,
            description: t.narrWrongNumbers,
            scoreLabel: t.narrScoreWithheld,
            isPositive: false,
          ),
          playbook: TacticalPlaybook(
            dataShows: isOwned
                ? t.narrReviewOwned
                : t.narrReviewNotOwned,
            toWatch: t.narrReviewWatch,
            updatesWith: t.narrReviewUpdates,
          ),
          profileLabel: t.aiDataReview,
        );
      }

      final isHold = rec.contains('HOLDING');
      final isIns = rec.contains('INSURANCE');
      final isReit = rec.contains('REIT') || rec.contains('INVIT');

      final archetype = isHold
          ? t.narrHoldingTag
          : (isIns
              ? t.narrInsuranceTag
              : (isReit
                  ? t.narrTrustTag
                  : t.narrSpecialTag));

      final icon = isHold ? '🏢' : (isIns ? '☂️' : (isReit ? '🏗️' : '📋'));

      return VerdictNarrative(
        archetypeTag: archetype,
        archetypeIcon: icon,
        analystBriefing: score.analystVerdict?.trim().isNotEmpty == true
            ? score.analystVerdict!.trim()
            : (isHold
                ? t.narrHoldingBrief(displayName)
                : (isIns
                    ? t.narrInsuranceBrief(displayName)
                    : t.narrTrustBrief(displayName))),
        primaryCatalyst: VerdictSignal(
          title: isHold ? t.narrHoldingNav : (isIns ? t.narrFloat : t.narrDistribution),
          description: isHold
              ? t.narrHoldingNavBody
              : (isIns
                  ? t.narrFloatBody
                  : t.narrDistributionBody),
          scoreLabel: t.narrCoverage,
          isPositive: true,
        ),
        primaryRisk: VerdictSignal(
          title: isHold ? t.narrDiscount : (isIns ? t.narrClaims : t.narrRate),
          description: isHold
              ? t.narrDiscountBody
              : (isIns
                  ? t.narrClaimsBody
                  : t.narrRateBody),
          scoreLabel: t.narrRiskSpecial,
          isPositive: false,
        ),
        playbook: TacticalPlaybook(
          dataShows: isOwned
              ? t.narrSpecialOwned
              : t.narrSpecialNotOwned,
          toWatch:
              t.narrSpecialMetrics,
          updatesWith: isHold
              ? t.narrSpecialHold
              : (isIns ? t.narrSpecialIns : t.narrSpecialTrust),
        ),
        profileLabel: t.narrSpecialTag,
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
        archetypeTag: t.narrScoreProfile,
        archetypeIcon: '📊',
        analystBriefing: overall == null
            ? t.narrNoScore(displayName)
            : t.narrScoreNoBreakdown(displayName, overall),
        primaryCatalyst: VerdictSignal(
          title: t.narrBreakdownPending,
          description: t.narrBreakdownNext,
          scoreLabel: '—',
          isPositive: true,
        ),
        primaryRisk: VerdictSignal(
          title: t.narrBreakdownPending,
          description: t.narrNoPillars,
          scoreLabel: '—',
          isPositive: false,
        ),
        playbook: TacticalPlaybook(
          dataShows: isOwned ? t.narrOwnedScore(overall ?? '—') : t.narrScoreLine(overall ?? '—'),
          toWatch: t.narrBreakdownWatch,
          updatesWith: t.narrUpdates,
        ),
        profileLabel: _profileLabel(score, t),
      );
    }

    final strongest = scored.first;
    final weakest = scored.last;
    final hurdle = b['hurdle_factor'] as num?;
    final qualityCap = b['quality_cap'];
    final riskCap = b['risk_cap'];
    final cap = b['provisional_cap'];

    final briefing = StringBuffer(t.narrHasScore(displayName, overall))
      ..write(scored.map(_pillarSummary).join('; '))
      ..write('.');
    final missing = pillars.where((p) => p['score'] is! num).map((p) => p['label']).toList();
    if (missing.isNotEmpty) {
      briefing.write(t.narrMissingPillars(missing.join(' ${t.commonAnd} ')));
    }
    if (riskCap != null) {
      briefing.write(t.narrRiskCap(riskCap));
    } else if (qualityCap != null) {
      briefing.write(t.narrQualityCap(qualityCap));
    } else if (hurdle != null) {
      briefing.write(t.narrHurdle(hurdle.toStringAsFixed(2)));
    }
    if (cap != null) {
      briefing.write(t.narrLenderCap(cap));
    }

    final shows = StringBuffer(isOwned ? t.narrInPortfolio : '')
      ..write(t.narrHighLow(_pillarSummary(strongest), _pillarSummary(weakest)));

    return VerdictNarrative(
      archetypeTag: _archetype(scored, riskCap != null, t),
      archetypeIcon: riskCap != null ? '⚠️' : '📊',
      analystBriefing: briefing.toString(),
      primaryCatalyst: VerdictSignal(
        title: t.narrHighest(strongest['label']),
        description: _partsText(strongest, t),
        scoreLabel: '${_num(strongest['score'])}/100',
        isPositive: true,
      ),
      primaryRisk: VerdictSignal(
        title: t.narrLowest(weakest['label']),
        description: _partsText(weakest, t),
        scoreLabel: '${_num(weakest['score'])}/100',
        isPositive: false,
      ),
      playbook: TacticalPlaybook(
        dataShows: shows.toString(),
        toWatch: _toWatch(weakest, t),
        updatesWith: t.narrUpdates,
      ),
      profileLabel: _profileLabel(score, t),
    );
  }

  
  static String _num(dynamic v) => v is num ? v.round().toString() : '—';

  static String _pillarSummary(Map<String, dynamic> p) => '${p['label']} ${_num(p['score'])}/100';

  /// The pillar's inputs as one sentence, e.g. "ROCE 13.4%; 0.44x debt to equity".
  static String _partsText(Map<String, dynamic> p, AppLocalizations t) {
    final details = ((p['parts'] as List?) ?? const [])
        .whereType<Map>()
        .map((x) => x['detail'])
        .whereType<String>()
        .where((d) => d.isNotEmpty)
        .toList();
    return details.isEmpty ? t.narrNoDetail : '${details.join('; ')}.';
  }

  /// The lowest-scoring input of the weakest pillar: the number that holds the score down.
  static String _toWatch(Map<String, dynamic> p, AppLocalizations t) {
    final parts = ((p['parts'] as List?) ?? const [])
        .whereType<Map>()
        .where((x) => x['points'] is num && x['max'] is num && x['detail'] is String)
        .toList()
      ..sort((x, y) => ((x['points'] as num) / (x['max'] as num)).compareTo((y['points'] as num) / (y['max'] as num)));
    if (parts.isEmpty) return t.narrMostRoom(p['label']);
    final low = parts.first;
    return t.narrPartScore(low['label'], _num(low['points']), _num(low['max']), low['detail']);
  }

  static String _archetype(List<Map<String, dynamic>> scored, bool riskFlag, AppLocalizations t) {
    if (riskFlag) return t.narrRiskFlag;
    double? s(String key) {
      for (final p in scored) {
        if (p['key'] == key) return (p['score'] as num).toDouble();
      }
      return null;
    }

    final q = s('quality');
    final v = s('valuation');
    if (q != null && q < 55) return t.narrBelowHurdle;
    if (q != null && q >= 70 && v != null && v >= 65) return t.narrStrongLowVal;
    if (q != null && q >= 70 && v != null && v < 35) return t.narrStrongHighVal;
    if (q != null && q >= 70) return t.narrStrongQuality;
    return t.narrMixed;
  }

  static String _profileLabel(StockScore score, AppLocalizations t) {
    final o = score.overallScore;
    if (o == null) return t.narrNotScored;
    if (o >= 85) return t.narrBandExcellent;
    if (o >= 70) return t.narrBandStrong;
    if (o >= 55) return t.narrBandAverage;
    return t.narrBandWeak;
  }
}
