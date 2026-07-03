import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class InvestmentThesisCard extends StatelessWidget {
  final String thesis;

  const InvestmentThesisCard({
    super.key,
    required this.thesis,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = thesis.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        border: Border.all(
          color: AppColors.outline.withOpacity(.25),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              const Icon(
                Icons.lightbulb_outline,
                color: AppColors.primary,
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              Text(
                "Investment Thesis",
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(
                AppRadius.lg,
              ),
            ),
            child: Text(
              hasData
                  ? thesis
                  : "No investment thesis available for this stock yet.",
              style: AppTypography.bodyMedium.copyWith(
                height: 1.6,
                color: hasData
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),

          if (hasData) ...[
            const SizedBox(
              height: AppSpacing.lg,
            ),

            Row(
              children: const [

                Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: AppColors.success,
                ),

                SizedBox(
                  width: AppSpacing.sm,
                ),

                Expanded(
                  child: Text(
                    "Review this thesis after every quarterly result.",
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}