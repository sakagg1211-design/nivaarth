import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/stock_score.dart';

class WeakestHoldingCard extends StatelessWidget {
  final StockScore stock;

  const WeakestHoldingCard({
    super.key,
    required this.stock,
  });

  Color get scoreColor {
    if (stock.overallScore < 40) return AppColors.danger;
    if (stock.overallScore < 60) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (stock.overallScore / 100).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.priority_high_rounded,
                  color: scoreColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Text('Weakest Holding', style: AppTypography.title),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            stock.companyName.isEmpty ? stock.instrument : stock.companyName,
            style: AppTypography.heading2,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(stock.instrument, style: AppTypography.body),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Text('Overall Score', style: AppTypography.caption),
              const Spacer(),
              Text(
                '${stock.overallScore}',
                style: AppTypography.metric.copyWith(color: scoreColor),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              color: scoreColor,
              backgroundColor: AppColors.surfaceSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _Chip(label: 'Business', value: stock.businessQuality),
              _Chip(label: 'Financial', value: stock.financialStrength),
              _Chip(label: 'Growth', value: stock.growth),
              _Chip(label: 'Technical', value: stock.technical),
              _Chip(label: 'Risk', value: stock.risk),
              _Chip(label: 'Confidence', value: stock.confidence),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: scoreColor.withValues(alpha: 0.22)),
            ),
            child: Text(
              stock.recommendation,
              textAlign: TextAlign.center,
              style: AppTypography.title.copyWith(color: scoreColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final int value;

  const _Chip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        '$label $value',
        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
