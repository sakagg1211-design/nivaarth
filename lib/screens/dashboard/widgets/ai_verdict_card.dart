import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/ai_recommendation.dart';

class AIVerdictCard extends StatelessWidget {
  final AIRecommendation ai;

  const AIVerdictCard({
    super.key,
    required this.ai,
  });

  Color get color {
    switch (ai.recommendation) {
      case RecommendationType.strongBuy:
      case RecommendationType.buy:
        return AppColors.success;
      case RecommendationType.accumulate:
        return AppColors.accent;
      case RecommendationType.hold:
        return AppColors.warning;
      case RecommendationType.reduce:
        return AppColors.gold;
      case RecommendationType.sell:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidence = (ai.confidence / 100).clamp(0.0, 1.0).toDouble();

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
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: AppColors.violetSoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.violet,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Text('AI Verdict', style: AppTypography.title),
              ),
              _Pill(label: '${ai.confidence}%', color: color),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            ai.title,
            style: AppTypography.heading2.copyWith(color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(ai.summary, style: AppTypography.body),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 7,
              color: color,
              backgroundColor: AppColors.surfaceSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Reasons', style: AppTypography.title),
          const SizedBox(height: AppSpacing.sm),
          ...ai.reasons.map(
            (reason) => _InsightRow(
              icon: Icons.bolt_outlined,
              color: AppColors.accent,
              label: reason,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Actions', style: AppTypography.title),
          const SizedBox(height: AppSpacing.sm),
          ...ai.actions.map(
            (action) => _InsightRow(
              icon: Icons.check_rounded,
              color: AppColors.success,
              label: action,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({
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
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: color),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _InsightRow({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 22,
            width: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(label, style: AppTypography.body),
          ),
        ],
      ),
    );
  }
}
