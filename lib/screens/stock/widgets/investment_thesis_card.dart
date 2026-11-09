import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/l10n/l10n_ext.dart';

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
          color: AppColors.outline.withValues(alpha: 0.25),
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
                context.t.thesisTitle,
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
                  : context.t.thesisNone,
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
              children: [

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
                    context.t.thesisReview,
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