import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class PortfolioHealthCard extends StatelessWidget {
  final double healthScore;
  final String action;

  const PortfolioHealthCard({
    super.key,
    required this.healthScore,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        (healthScore / 100).clamp(0.0, 1.0).toDouble();

    final tone = _tone(healthScore);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        24,
        22,
        24,
        22,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.line,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(
              alpha: .05,
            ),
            blurRadius: 24,
            offset: const Offset(0, 12),
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
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: tone.withValues(
                    alpha: .12,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  Icons.health_and_safety_rounded,
                  color: tone,
                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Text(
                  "Portfolio Health",
                  style: AppTypography.title,
                ),
              ),

              _Badge(
                label: action,
                color: tone,
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                healthScore
                    .toStringAsFixed(0),
                style:
                    AppTypography.heading1.copyWith(
                  color: tone,
                  fontSize: 52,
                ),
              ),

              const SizedBox(width: 6),

              Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 8,
                ),
                child: Text(
                  "/100",
                  style:
                      AppTypography.caption.copyWith(
                    color: AppColors
                        .textTertiary,
                  ),
                ),
              ),

              const Spacer(),

              Text(
                _status(healthScore),
                style:
                    AppTypography.caption.copyWith(
                  color: tone,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              AppRadius.pill,
            ),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              color: tone,
              backgroundColor:
                  AppColors.surfaceSecondary,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            _message(healthScore),
            style: AppTypography.body.copyWith(
              color:
                  AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _tone(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.accent;
    if (score >= 40) return AppColors.warning;
    return AppColors.danger;
  }

  String _status(double score) {
    if (score >= 80) return "Strong portfolio";
    if (score >= 60) return "Good portfolio";
    if (score >= 40) return "Needs attention";
    return "High risk";
  }

  String _message(double score) {
    if (score >= 80) {
      return "Your portfolio is fundamentally strong. Continue monitoring and add quality businesses on corrections.";
    }

    if (score >= 60) {
      return "Portfolio quality is healthy. Small improvements can further strengthen long-term returns.";
    }

    if (score >= 40) {
      return "Review weak holdings and rebalance gradually. Focus on improving portfolio quality.";
    }

    return "Portfolio requires immediate attention. Reduce weak businesses and increase exposure to fundamentally strong companies.";
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: .10,
        ),
        borderRadius:
            BorderRadius.circular(
          AppRadius.pill,
        ),
        border: Border.all(
          color: color.withValues(
            alpha: .20,
          ),
        ),
      ),
      child: Text(
        label,
        style:
            AppTypography.caption.copyWith(
          color: color,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }
}