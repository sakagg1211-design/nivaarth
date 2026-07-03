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
    final progress = (healthScore / 100).clamp(0.0, 1.0).toDouble();
    final tone = _tone(healthScore);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.health_and_safety_outlined,
                  color: tone,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Text('Portfolio Health', style: AppTypography.title),
              ),
              _Badge(label: action, color: tone),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                healthScore.toStringAsFixed(0),
                style: AppTypography.heading1.copyWith(
                  color: tone,
                  fontSize: 42,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '/100',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _status(healthScore),
                style: AppTypography.caption.copyWith(color: tone),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: tone,
              backgroundColor: AppColors.surfaceSecondary,
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
    if (score >= 80) return 'Strong portfolio';
    if (score >= 60) return 'Good portfolio';
    if (score >= 40) return 'Needs attention';
    return 'High risk';
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.caption.copyWith(color: color),
      ),
    );
  }
}
