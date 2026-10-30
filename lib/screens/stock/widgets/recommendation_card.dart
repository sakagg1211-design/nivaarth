import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/symbol_utils.dart';
import '../../../core/utils/verdict_narrative_engine.dart';
import '../../../models/stock_score.dart';

class RecommendationCard extends StatelessWidget {
  final StockScore score;
  final String? companyName;
  final String? sector;
  final String? industry;
  final bool isOwned;

  const RecommendationCard({
    super.key,
    required this.score,
    this.companyName,
    this.sector,
    this.industry,
    this.isOwned = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color recColor = _recommendationColor();
    final narrative = VerdictNarrativeEngine.generate(
      score: score,
      companyName: companyName,
      sector: sector,
      industry: industry,
      isOwned: isOwned,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.line,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------------------------------------------------------
          // 1. TOP HEADER: TITLE & RECOMMENDATION BADGE
          // -------------------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: recColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: recColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  Icons.psychology_alt_rounded,
                  color: recColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "NV Verdict",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      narrative.profileLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                constraints: const BoxConstraints(maxWidth: 140),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: recColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: recColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  SymbolUtils.toCompliantVerdict(score.recommendation),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium.copyWith(
                    color: recColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // -------------------------------------------------------------------
          // 2. DYNAMIC ARCHETYPE PILL
          // -------------------------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF383A42),
              ),
            ),
            child: Row(
              children: [
                Text(
                  narrative.archetypeIcon,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    narrative.archetypeTag,
                    style: const TextStyle(
                      color: Color(0xFFF3F4F6),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "ARCHETYPE",
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // -------------------------------------------------------------------
          // 3. BESPOKE EXECUTIVE ANALYST BRIEFING
          // -------------------------------------------------------------------
          Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF111215),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF22242A),
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    color: recColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.format_quote_rounded,
                                size: 15,
                                color: recColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "DATA SUMMARY",
                                style: TextStyle(
                                  color: recColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            narrative.analystBriefing,
                            style: const TextStyle(
                              color: Color(0xFFD6D9E0),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // -------------------------------------------------------------------
          // 4. STRUCTURED SIGNAL DUALITY (CATALYST vs RISK)
          // -------------------------------------------------------------------
          _SignalTile(
            title: narrative.primaryCatalyst.title,
            description: narrative.primaryCatalyst.description,
            tag: narrative.primaryCatalyst.scoreLabel,
            isBullish: true,
          ),

          const SizedBox(height: 10),

          _SignalTile(
            title: narrative.primaryRisk.title,
            description: narrative.primaryRisk.description,
            tag: narrative.primaryRisk.scoreLabel,
            isBullish: false,
          ),

          const SizedBox(height: 18),

          // -------------------------------------------------------------------
          // 5. WHAT THE DATA SHOWS / NUMBER TO WATCH
          // -------------------------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.line,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Tactical Playbook",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (isOwned ? AppColors.accent : AppColors.textSecondary)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isOwned ? "HELD IN PORTFOLIO" : "DISCOVERY MODE",
                        style: TextStyle(
                          color: isOwned ? AppColors.accent : AppColors.textSecondary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(
                  color: Color(0xFF2E3038),
                  height: 1,
                ),
                const SizedBox(height: 12),

                // What the numbers show
                _PlaybookRow(
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: const Color(0xFFE5A93C),
                  title: "What the data shows",
                  guideline: narrative.playbook.dataShows,
                ),

                const SizedBox(height: 12),

                // The input holding the score down
                _PlaybookRow(
                  icon: Icons.add_chart_rounded,
                  iconColor: const Color(0xFF00E676),
                  title: "Number to watch",
                  guideline: narrative.playbook.toWatch,
                ),

                const SizedBox(height: 12),

                // Key Metric to Watch
                _PlaybookRow(
                  icon: Icons.remove_red_eye_outlined,
                  iconColor: const Color(0xFFA78BFA),
                  title: "What updates the score",
                  guideline: narrative.playbook.updatesWith,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // -------------------------------------------------------------------
          // 6. QUANT FOOTER
          // -------------------------------------------------------------------
          Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 13,
                color: Color(0xFF757A85),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Data coverage: ${score.confidence}% • Synthesized from 6 quantitative pillars",
                  style: const TextStyle(
                    color: Color(0xFF757A85),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _recommendationColor() {
    final rec = SymbolUtils.toCompliantVerdict(score.recommendation).toUpperCase();
    if (rec.contains("ROBUST") || rec.contains("ACCUMULATE") || rec.contains("STRONG OUTPERFORM") || rec.contains("OUTPERFORM") || rec == "BUY") {
      return AppColors.success;
    }
    if (rec.contains("DIP") || rec.contains("WAIT FOR DIP")) {
      return const Color(0xFF38BDF8);
    }
    if (rec.contains("HIGH RISK") || rec.contains("FLAG") || rec.contains("AVOID") || rec.contains("SELL") || rec.contains("UNDERPERFORM")) {
      return AppColors.danger;
    }
    if (rec.contains("TRIM") || rec.contains("BELOW HURDLE") || rec.contains("EXTENDED") || rec.contains("ELEVATED") || rec.contains("CAUTION")) {
      return const Color(0xFFFF7043);
    }
    return AppColors.warning;
  }
}

class _SignalTile extends StatelessWidget {
  final String title;
  final String description;
  final String tag;
  final bool isBullish;

  const _SignalTile({
    required this.title,
    required this.description,
    required this.tag,
    required this.isBullish,
  });

  @override
  Widget build(BuildContext context) {
    final color = isBullish ? AppColors.success : const Color(0xFFFF7043);
    final bgColor = color.withValues(alpha: 0.06);
    final borderColor = color.withValues(alpha: 0.22);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isBullish
                    ? Icons.check_circle_outline_rounded
                    : Icons.warning_amber_rounded,
                size: 15,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                isBullish ? "PRIMARY CATALYST" : "KEY MONITORABLE & RISK",
                style: TextStyle(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaybookRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String guideline;

  const _PlaybookRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.guideline,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                guideline,
                style: const TextStyle(
                  color: Color(0xFFD1D5DB),
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}