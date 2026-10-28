import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/symbol_utils.dart';
import '../../../models/stock_score.dart';
import '../score_methodology_page.dart';
import 'score_breakdown_section.dart';

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
                      "Rules-based research score",
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
                tooltip: 'How the NV Score works',
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
                            fontSize: 9.5,
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
                              label: score.recommendation.toUpperCase().contains("DATA REVIEW")
                                  ? "Data Under Review"
                                  : "Score Excluded",
                              icon: Icons.block_outlined,
                              color: Colors.amber,
                            ),
                          if (score.provisionalCreditPending)
                            _buildInstitutionalBadge(
                              label: "Credit Pending",
                              icon: Icons.account_balance_outlined,
                              color: Colors.blue,
                            ),
                          if (score.provisionalBrokerMTF)
                            _buildInstitutionalBadge(
                              label: "Broker MTF Leverage",
                              icon: Icons.account_balance_wallet_outlined,
                              color: Colors.purple,
                            ),
                          if (score.debtNotAssessed)
                            _buildInstitutionalBadge(
                              label: "Debt Not Assessed",
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
                          "${score.confidence}% Data coverage",
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
                      _summary(),
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
                "Why this score",
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.psychology_outlined, size: 14, color: Color(0xFFE5A93C)),
                      SizedBox(width: 4),
                      Text(
                        "Methodology",
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
              fontSize: 10,
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

  String _summary() {
    if (score.isExcluded) {
      final rec = score.recommendation.toUpperCase();
      if (rec.contains("DATA REVIEW")) {
        return "The source data for this stock did not match the exchange (market cap or price belong to a different company), so it is being reviewed. No score is shown rather than a score built on wrong numbers.";
      }
      if (rec.contains("INSURANCE")) {
        return "Life and General Insurance firms operate on actuarial float and statutory accounting. Quantitative 1-100 scoring is withheld until dedicated Embedded Value (EV) models are integrated.";
      } else if (rec.contains("HOLDING")) {
        return "Investment holding companies trade at variable net asset value (NAV) discounts. Standard operating multiples (P/E, ROCE) are not applicable; specialized SOTP research is recommended.";
      } else if (rec.contains("REIT") || rec.contains("INVIT")) {
        return "Real Estate & Infrastructure Investment Trusts operate on distribution yield and Net Asset Value (NAV). Standard industrial scoring is withheld.";
      }
      return "The 1-100 score is not calculated for this stock: its accounts need a specialised valuation method.";
    }

    final rec = SymbolUtils.toCompliantVerdict(score.recommendation).toUpperCase();
    final bq = score.businessQuality;
    final val = score.valuation;
    final tech = score.technical;
    final risk = score.risk;
    final growth = score.growth;

    // 1. Critical Risk / High Pledging Override (e.g. SEPC, A2ZINFRA)
    if (risk == 0 || rec.contains("HIGH RISK") || rec.contains("FLAG") || rec.contains("AVOID")) {
      return "Critical risk threshold breached (elevated promoter share encumbrance or capital distress). Quant safety framework strictly enforces capital preservation over short-term price swings.";
    }

    // 2. High Quality Business with Premium Valuation Overhang (e.g. TITAN)
    if (bq >= 15 && val <= 5) {
      if (tech <= 4) {
        return "Core business franchise & ROE remain superior, but shares trade at a premium valuation multiple with short-term chart consolidation. Research score reflects valuation overhang rather than business weakness.";
      }
      return "Exceptional industry moat and capital compounding, but current market multiple leaves modest margin of safety for fresh allocation.";
    }

    // 3. High Growth with Low Operating Hurdle / Margin Expansion Awaited (e.g. CCAVENUE)
    if (growth >= 14 && bq < 12) {
      return "Robust top-line revenue expansion, but operating return on capital (ROCE) remains below the 8% cost-of-capital hurdle. Framework awaits operating margin expansion before accumulate eligibility.";
    }

    // 4. Strong Fundamentals awaiting Technical Confirmation
    if (score.overallScore != null && score.overallScore! >= 70 && tech <= 5) {
      return "Business fundamentals demonstrate healthy return on capital. Technical momentum data remains under active tracking; framework awaits moving average base confirmation.";
    }

    // 5. Overvalued with Technical Breakdown (e.g. ASIANPAINT)
    if (rec.contains("TRIM") || rec.contains("ELEVATED VALUATION")) {
      return "Extended valuation multiple coupled with moving average breakdown indicates ongoing consolidation. Framework suggests disciplined portfolio review.";
    }

    // 6. Below Capital Efficiency Hurdle (e.g. TITAGARH)
    if (rec.contains("BELOW HURDLE") || bq < 10) {
      return "Return on capital (ROCE/ROE) remains below institutional hurdle rates against prevailing multiples. Capital allocation efficiency requires quarterly monitoring.";
    }

    // 7. General High Conviction Accumulate
    if (score.overallScore != null && score.overallScore! >= 75) {
      return "Superior capital efficiency, pristine solvency, and attractive risk-reward alignment. Quantitative composite remains in institutional accumulation territory.";
    }

    if (score.overallScore != null && score.overallScore! >= 60) {
      return "Healthy underlying business fundamentals with balanced risk-reward. Monitor quarterly execution and entry valuation before increasing allocation.";
    }

    return "Current conviction score reflects mixed factor balance across valuation, quality, and momentum. Prudent research discipline suggested before fresh capital commitment.";
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
          fontSize: 10.5,
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