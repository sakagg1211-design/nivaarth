import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// "Why this score": the three pillars that actually make up the NV Score, with their
/// weights and inputs, and the arithmetic from the weighted score to the final number.
/// Everything shown comes from StockScores.score_breakdown (backend build_score_breakdown).
class ScoreBreakdownSection extends StatelessWidget {
  final Map<String, dynamic>? breakdown;

  const ScoreBreakdownSection({super.key, required this.breakdown});

  static const _pillarColors = {
    'quality': Colors.blue,
    'valuation': Colors.deepPurple,
    'momentum': Colors.teal,
  };

  static const _pillarHints = {
    'quality': 'Return on capital, debt and cash conversion',
    'valuation': 'P/E vs sector peers and earnings yield',
    'momentum': 'Price trend, RSI and MACD',
  };

  @override
  Widget build(BuildContext context) {
    final b = breakdown;
    if (b == null || b['final'] == null) {
      return Text(
        b == null
            ? 'The breakdown appears after the next score update.'
            : 'No score for this stock, so there is no breakdown.',
        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
      );
    }

    final pillars = (b['pillars'] as List? ?? const [])
        .whereType<Map>()
        .map((p) => Map<String, dynamic>.from(p))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final p in pillars) ...[
          _PillarTile(
            pillar: p,
            color: _pillarColors[p['key']] ?? AppColors.accent,
            hint: _pillarHints[p['key']] ?? '',
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        _MathCard(breakdown: b),
      ],
    );
  }
}

String _num(dynamic v, {int digits = 0}) =>
    v == null ? '—' : (v as num).toStringAsFixed(digits);

class _PillarTile extends StatelessWidget {
  final Map<String, dynamic> pillar;
  final Color color;
  final String hint;

  const _PillarTile({required this.pillar, required this.color, required this.hint});

  @override
  Widget build(BuildContext context) {
    final score = pillar['score'] as num?;
    final weight = pillar['weight'] as num?;
    final parts = (pillar['parts'] as List? ?? const [])
        .whereType<Map>()
        .map((p) => Map<String, dynamic>.from(p))
        .toList();
    final weightText = weight == null ? 'not counted' : '${(weight * 100).round()}% weight';

    // Material (not a coloured Container) so the expansion tile's ink and background paint correctly
    return Material(
      color: AppColors.surfaceSecondary,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
          iconColor: AppColors.textSecondary,
          collapsedIconColor: AppColors.textSecondary,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${pillar['label']}  ·  $weightText',
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    score == null ? 'Not assessed' : '${_num(score)} / 100',
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(hint, style: const TextStyle(color: Color(0xFF757A85), fontSize: 10.5)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: ((score ?? 0) / 100).clamp(0.0, 1.0).toDouble(),
                  backgroundColor: AppColors.outline.withValues(alpha: .20),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
          children: [
            for (final part in parts) _PartRow(part: part),
          ],
        ),
      ),
    );
  }
}

class _PartRow extends StatelessWidget {
  final Map<String, dynamic> part;

  const _PartRow({required this.part});

  @override
  Widget build(BuildContext context) {
    final points = part['points'] as num?;
    final detail = part['detail'] as String?;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${part['label']}', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700)),
                if (detail != null)
                  Text(detail, style: const TextStyle(color: Color(0xFF8E929B), fontSize: 11, height: 1.35)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            points == null ? '—' : '${_num(points, digits: 1)} / ${_num(part['max'])}',
            style: AppTypography.bodySmall.copyWith(color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _MathCard extends StatelessWidget {
  final Map<String, dynamic> breakdown;

  const _MathCard({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[];
    final riskCap = breakdown['risk_cap'];
    if (riskCap != null) {
      rows.add(MapEntry('Risk flag', 'Score capped at $riskCap (pledge, net worth or debt check failed)'));
    } else {
      rows.add(MapEntry('Weighted score', _num(breakdown['weighted'], digits: 1)));
      final hurdle = breakdown['hurdle_factor'] as num?;
      if (hurdle != null) {
        rows.add(MapEntry('Quality hurdle', '× ${hurdle.toStringAsFixed(2)} (quality below 55)'));
      }
      final cap = breakdown['provisional_cap'];
      if (cap != null) {
        rows.add(MapEntry('Lender / broker cap', 'Capped at $cap until credit data is added'));
      }
    }
    for (final note in (breakdown['notes'] as List? ?? const [])) {
      rows.add(MapEntry('Note', '$note'));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline.withValues(alpha: .40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(r.key, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                  ),
                  Expanded(child: Text(r.value, style: AppTypography.bodySmall)),
                ],
              ),
            ),
          const Divider(height: AppSpacing.md),
          Row(
            children: [
              Text('NV Score', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(
                '${breakdown['final']} / 100',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
