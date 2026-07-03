import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/stock_score.dart';

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
            children: [

              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: .10,
                  ),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(
                width: AppSpacing.md,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      "AI Score",
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    Text(
                      "AI generated conviction score",
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),

              _RecommendationChip(
                recommendation:
                    score.recommendation,
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
                        value:
                            score.overallScore /
                                100,

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
                          "${score.overallScore}",
                          style: AppTypography.displaySmall.copyWith(
                            color:
                                scoreColor,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),

                        Text(
                          "/100",
                          style:
                              AppTypography.bodySmall,
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

                    const SizedBox(
                      height: AppSpacing.lg,
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
                          "${score.confidence}% Confidence",
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

          Text(
            "AI Breakdown",
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),
                    _ScoreTile(
            title: "Business Quality",
            value: score.businessQuality,
            color: Colors.blue,
            icon: Icons.business_center_outlined,
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _ScoreTile(
            title: "Financial Strength",
            value: score.financialStrength,
            color: AppColors.success,
            icon: Icons.account_balance_wallet_outlined,
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _ScoreTile(
            title: "Growth",
            value: score.growth,
            color: Colors.orange,
            icon: Icons.trending_up,
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _ScoreTile(
            title: "Valuation",
            value: score.valuation,
            color: Colors.deepPurple,
            icon: Icons.payments_outlined,
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _ScoreTile(
            title: "Technical",
            value: score.technical,
            color: Colors.teal,
            icon: Icons.show_chart,
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _ScoreTile(
            title: "Risk",
            value: score.risk,
            color: AppColors.danger,
            icon: Icons.warning_amber_rounded,
          ),

          const SizedBox(
            height: AppSpacing.xl,
          ),
        ],
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 80) {
      return AppColors.success;
    }

    if (score >= 60) {
      return Colors.orange;
    }

    return AppColors.danger;
  }

  String _ratingText(int score) {
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
    if (score.overallScore >= 80) {
      return "Business quality and financial strength remain excellent. Long-term outlook continues to be attractive.";
    }

    if (score.overallScore >= 60) {
      return "Overall fundamentals remain healthy. Monitor quarterly earnings and valuation before increasing allocation.";
    }

    return "Current AI score indicates elevated risk. Review technical trend, valuation and business quality before fresh buying.";
  }
}

class _ScoreTile extends StatelessWidget {

  final String title;
  final int value;
  final Color color;
  final IconData icon;

  const _ScoreTile({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: color,
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Text(
                "$value / 25",
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),
                    ClipRRect(
            borderRadius: BorderRadius.circular(
              AppRadius.lg,
            ),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: value / 25,
              backgroundColor:
                  AppColors.outline.withValues(
                alpha: .20,
              ),
              valueColor:
                  AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationChip extends StatelessWidget {
  final String recommendation;

  const _RecommendationChip({
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = _color();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: .12,
        ),
        borderRadius: BorderRadius.circular(
          24,
        ),
      ),
      child: Text(
        recommendation.toUpperCase(),
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: .3,
        ),
      ),
    );
  }

  Color _color() {
    switch (recommendation.toUpperCase()) {
      case "BUY":
      case "STRONG BUY":
        return AppColors.success;

      case "SELL":
      case "STRONG SELL":
        return AppColors.danger;

      default:
        return Colors.orange;
    }
  }
}