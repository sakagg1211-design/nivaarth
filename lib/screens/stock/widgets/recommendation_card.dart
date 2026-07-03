import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/stock_score.dart';

class RecommendationCard extends StatelessWidget {
  final StockScore score;

  const RecommendationCard({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = _recommendationColor();

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
              Icon(
                Icons.psychology_alt_rounded,
                color: color,
              ),

              const SizedBox(width: AppSpacing.sm),

              Text(
                "AI Recommendation",
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius: BorderRadius.circular(
                AppRadius.lg,
              ),
            ),
            child: Text(
              score.recommendation,
              style: AppTypography.titleMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          _ReasonTile(
            icon: Icons.trending_up,
            title: "Growth",
            value: score.growth,
          ),

          _ReasonTile(
            icon: Icons.account_balance,
            title: "Financial Strength",
            value: score.financialStrength,
          ),

          _ReasonTile(
            icon: Icons.business_center,
            title: "Business Quality",
            value: score.businessQuality,
          ),

          _ReasonTile(
            icon: Icons.bar_chart,
            title: "Technical",
            value: score.technical,
          ),

          _ReasonTile(
            icon: Icons.sell,
            title: "Valuation",
            value: score.valuation,
          ),

          _ReasonTile(
            icon: Icons.warning_amber_rounded,
            title: "Risk",
            value: score.risk,
          ),

          const SizedBox(height: AppSpacing.lg),

          Container(
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
              _summary(),
              style: AppTypography.bodyMedium.copyWith(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _recommendationColor() {
    switch (score.recommendation.toUpperCase()) {
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

  String _summary() {
    if (score.overallScore >= 80) {
      return "This stock demonstrates excellent fundamentals with strong business quality, healthy financials and attractive growth prospects. AI suggests accumulation for long-term investors.";
    }

    if (score.overallScore >= 60) {
      return "Overall business quality is healthy. Continue monitoring quarterly results and valuation before increasing allocation.";
    }

    return "Current score indicates elevated risk. Review valuation, technical trend and business fundamentals before taking fresh positions.";
  }
}

class _ReasonTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;

  const _ReasonTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyMedium,
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(
                AppRadius.lg,
              ),
            ),
            child: Text(
              "$value",
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}