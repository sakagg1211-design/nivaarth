import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/stock_score.dart';

class TopOpportunityCard extends StatelessWidget {
  final StockScore stock;

  const TopOpportunityCard({
    super.key,
    required this.stock,
  });

  Color get scoreColor {
    if (stock.overallScore >= 90) return AppColors.success;
    if (stock.overallScore >= 75) return AppColors.mint;
    if (stock.overallScore >= 60) return AppColors.warning;
    return AppColors.danger;
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
          const _SectionLabel(
            icon: Icons.trending_up_rounded,
            label: 'Top Opportunity',
            color: AppColors.success,
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
          _MetricGrid(
            values: [
              _ScoreMetric('Business', stock.businessQuality),
              _ScoreMetric('Financial', stock.financialStrength),
              _ScoreMetric('Growth', stock.growth),
              _ScoreMetric('Technical', stock.technical),
              _ScoreMetric('Risk', stock.risk),
              _ScoreMetric('Confidence', stock.confidence),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _RecommendationPill(
            label: stock.recommendation,
            color: scoreColor,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: color, size: 19),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(label, style: AppTypography.title),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final List<_ScoreMetric> values;

  const _MetricGrid({
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: values
          .map(
            (metric) => SizedBox(
              width: (MediaQuery.sizeOf(context).width - 64) / 2,
              child: _MetricTile(metric: metric),
            ),
          )
          .toList(),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final _ScoreMetric metric;

  const _MetricTile({
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              metric.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption,
            ),
          ),
          Text(
            '${metric.value}',
            style: AppTypography.title,
          ),
        ],
      ),
    );
  }
}

class _RecommendationPill extends StatelessWidget {
  final String label;
  final Color color;

  const _RecommendationPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.title.copyWith(color: color),
      ),
    );
  }
}

class _ScoreMetric {
  final String label;
  final int value;

  const _ScoreMetric(this.label, this.value);
}
