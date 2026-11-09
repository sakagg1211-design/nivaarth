import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/symbol_utils.dart';
import '../../../models/stock_score.dart';
import '../score_methodology_page.dart';
import 'score_breakdown_section.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../l10n/app_localizations.dart';

class AiScoreCard extends StatelessWidget {
  final StockScore score;

  const AiScoreCard({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {

    final Color scoreColor =
        _scoreColor(score.overallScore);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        border: Border.all(
          color: AppColors.outline.withValues(
            alpha: .25,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: .05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: .10,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(
                width: AppSpacing.sm,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "NV Score",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      context.t.aiRulesBased,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: context.t.aiHowWorks,
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScoreMethodologyPage()),
                ),
              ),
              _RecommendationChip(
                recommendation: score.recommendation,
              ),
            ],
          ),

          const SizedBox(
            height: 28,
          ),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,

            children: [

              SizedBox(
                height: 120,
                width: 120,

                child: Stack(
                  alignment:
                      Alignment.center,

                  children: [

                    SizedBox(
                      height: 120,
                      width: 120,

                      child:
                          CircularProgressIndicator(
                        value: score.overallScore != null
                            ? (score.overallScore! / 100)
                            : 0.0,

                        strokeWidth: 11,

                        backgroundColor:
                            AppColors.outline.withValues(
                          alpha: .20,
                        ),

                        valueColor:
                            AlwaysStoppedAnimation(
                          scoreColor,
                        ),
                      ),
                    ),

                    Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [

                        Text(
                          score.overallScore != null
                              ? "${score.overallScore}"
                              : "N/A",
                          style: AppTypography.displaySmall.copyWith(
                            color: scoreColor,
                            fontWeight: FontWeight.w900,
                            fontSize: score.overallScore != null ? 32 : 24,
                          ),
                        ),

                        Text(
                          score.overallScore != null ? "/100" : "EXCLUDED",
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 24,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      score.companyName.isEmpty
                          ? score.instrument
                          : score.companyName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: AppSpacing.xs,
                    ),

                    Text(
                      score.instrument,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    if (score.isExcluded ||
                        score.provisionalCreditPending ||
                        score.provisionalBrokerMTF ||
                        score.debtNotAssessed) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: [
                          if (score.isExcluded)
                            _buildInstitutionalBadge(
                              label: score.isDataPending
                                  ? context.t.aiDataPending
                                  : (score.recommendation.toUpperCase().contains("DATA REVIEW")
                                      ? context.t.aiDataReview
                                      : context.t.aiExcluded),
                              icon: Icons.block_outlined,
                              color: Colors.amber,
                            ),
                          if (score.provisionalCreditPending)
                            _buildInstitutionalBadge(
                              label: context.t.aiCreditPending,
                              icon: Icons.account_balance_outlined,
                              color: Colors.blue,
                            ),
                          if (score.provisionalBrokerMTF)
                            _buildInstitutionalBadge(
                              label: context.t.aiBrokerLeverage,
                              icon: Icons.account_balance_wallet_outlined,
                              color: Colors.purple,
                            ),
                          if (score.debtNotAssessed)
                            _buildInstitutionalBadge(
                              label: context.t.aiDebtNotAssessed,
                              icon: Icons.warning_amber_rounded,
                              color: Colors.orange,
                            ),
                        ],
                      ),
                    ],

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    Row(
                      children: [

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: scoreColor.withValues(
                              alpha: .12,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),
                          child: Text(
                            _ratingText(
                              score.overallScore,
                            ),
                            style:
                                AppTypography.bodySmall
                                    .copyWith(
                              color: scoreColor,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        const Spacer(),

                        Text(
                          context.t.briefCoverage(score.confidence),
                          style: AppTypography.bodySmall
                              .copyWith(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                        AppRadius.lg,
                      ),
                      child:
                          LinearProgressIndicator(
                        minHeight: 8,
                        value:
                            score.confidence /
                                100,
                        backgroundColor:
                            AppColors.outline
                                .withValues(
                          alpha: .20,
                        ),
                        valueColor:
                            AlwaysStoppedAnimation(
                          scoreColor,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    Text(
                      _summary(context.t),
                      style:
                          AppTypography.bodySmall
                              .copyWith(
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.xl,
          ),

          Divider(
            color: AppColors.outline.withValues(
              alpha: .30,
            ),
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          Row(
            children: [
              Text(
                context.t.aiWhyScore,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScoreMethodologyPage()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x1FE5A93C),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x33E5A93C)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.psychology_outlined, size: 14, color: Color(0xFFE5A93C)),
                      SizedBox(width: 4),
                      Text(
                        context.t.aiMethodology,
                        style: TextStyle(
                          color: Color(0xFFE5A93C),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          ScoreBreakdownSection(breakdown: score.scoreBreakdown),

          const SizedBox(
            height: AppSpacing.xl,
          ),
        ],
      ),
    );
  }

  static Widget _buildInstitutionalBadge({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  Color _scoreColor(int? score) {
    if (score == null) {
      return Colors.amber;
    }

    if (score >= 80) {
      return AppColors.success;
    }

    if (score >= 60) {
      return Colors.orange;
    }

    return AppColors.danger;
  }

  String _ratingText(int? score) {
    if (score == null) {
      return "Excluded";
    }

    if (score >= 85) {
      return "Excellent";
    }

    if (score >= 70) {
      return "Strong";
    }

    if (score >= 55) {
      return "Average";
    }

    return "Weak";
  }

  String _summary(AppLocalizations t) {
    if (score.isDataPending) {
      return t.aiNoScore(score.pendingReason ?? 'not enough quality data');
    }
    if (score.isExcluded) {
      final rec = score.recommendation.toUpperCase();
      if (rec.contains("DATA REVIEW")) {
        return t.aiReviewBody;
      }
      if (rec.contains("INSURANCE")) {
        return t.aiInsurance;
      } else if (rec.contains("HOLDING")) {
        return t.aiHolding;
      } else if (rec.contains("REIT") || rec.contains("INVIT")) {
        return t.aiReit;
      }
      return t.aiSpecialised;
    }

    // Built from the score breakdown: which pillars are high or low, with their numbers
    final pillars = ((score.scoreBreakdown?['pillars'] as List?) ?? const [])
        .whereType<Map>()
        .where((p) => p['score'] is num)
        .toList()
      ..sort((x, y) => (y['score'] as num).compareTo(x['score'] as num));
    if (pillars.isEmpty) {
      return t.aiScoreOnly(score.overallScore ?? '—');
    }
    String line(Map p) => "${p['label']} ${(p['score'] as num).round()}/100";
    final text = StringBuffer(t.aiHighest(score.overallScore ?? '—', line(pillars.first)));
    if (pillars.length > 1) text.write(t.aiLowest(line(pillars.last)));
    text.write(".");
    if (score.scoreBreakdown?['risk_cap'] != null) {
      text.write(t.aiRiskCap(score.scoreBreakdown!['risk_cap']));
    } else if (score.scoreBreakdown?['hurdle_factor'] != null) {
      text.write(t.aiHurdle);
    }
    return text.toString();
  }
}

class _RecommendationChip extends StatelessWidget {
  final String recommendation;

  const _RecommendationChip({
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = SymbolUtils.toCompliantVerdict(recommendation);
    final Color color = _color(formatted);

    return Container(
      constraints: const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: .12,
        ),
        borderRadius: BorderRadius.circular(
          24,
        ),
        border: Border.all(
          color: color.withValues(alpha: .30),
        ),
      ),
      child: Text(
        formatted,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: .3,
          fontSize: 11,
        ),
      ),
    );
  }

  Color _color(String formattedRec) {
    final upper = formattedRec.toUpperCase();
    if (upper.contains("ROBUST") || upper.contains("ACCUMULATE") || upper.contains("OUTPERFORM") || upper == "BUY") {
      return const Color(0xFF4ADE80);
    }
    if (upper.contains("DIP") || upper.contains("WAIT FOR DIP")) {
      return const Color(0xFF38BDF8); // Cyan/blue
    }
    if (upper.contains("HIGH RISK") || upper.contains("FLAG") || upper.contains("AVOID") || upper.contains("SELL")) {
      return AppColors.danger;
    }
    if (upper.contains("TRIM") || upper.contains("BELOW HURDLE") || upper.contains("EXTENDED") || upper.contains("ELEVATED")) {
      return Colors.orange;
    }
    return AppColors.warning;
  }
}