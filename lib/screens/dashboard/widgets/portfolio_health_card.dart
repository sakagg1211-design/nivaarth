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
    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            "Portfolio Health",
            style: AppTypography.title.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Row(
            children: [
              Text(
                healthScore.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),

              const Spacer(),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold
                      .withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  action,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          LinearProgressIndicator(
            value: healthScore / 100,
            minHeight: 8,
            borderRadius:
                BorderRadius.circular(20),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Text(
            _status(healthScore),
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _status(double score) {
    if (score >= 80) {
      return "Strong Portfolio";
    }

    if (score >= 60) {
      return "Good Portfolio";
    }

    if (score >= 40) {
      return "Average Portfolio";
    }

    return "Weak Portfolio";
  }
}