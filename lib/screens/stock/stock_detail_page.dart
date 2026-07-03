import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/live_portfolio.dart';
import '../../models/stock_score.dart';
import '../../providers/stock_score_provider.dart';

class StockDetailPage extends ConsumerWidget {
  final LivePortfolio stock;

  const StockDetailPage({
    super.key,
    required this.stock,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = stock.portfolio;

    final double currentValue = stock.currentValue;
    final double netPL = stock.netPL;
    final bool isProfit = netPL >= 0;
    final scoreAsync = ref.watch(
      stockScoreProvider(
        portfolio.instrument,
      ),
    );

    final double returnPercent = portfolio.totalInvested == 0
        ? 0.0
        : (netPL / portfolio.totalInvested) * 100.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(portfolio.instrument),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StockHeader(
              instrument: portfolio.instrument,
              companyName: portfolio.companyName,
              status: portfolio.status,
              isProfit: isProfit,
              netPL: netPL,
              returnPercent: returnPercent,
            ),
            const SizedBox(height: AppSpacing.lg),
            _DetailSection(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Holding Details',
              children: [
                _MetricRow('Quantity', portfolio.qty.toString()),
                _MetricRow(
                  'Average Price',
                  _money(portfolio.avgPrice, decimals: 2),
                ),
                _MetricRow(
                  'Invested',
                  _money(portfolio.totalInvested, decimals: 2),
                ),
                _MetricRow(
                  'Current Value',
                  _money(currentValue, decimals: 2),
                ),
                _MetricRow(
                  'Net P&L',
                  _money(netPL, decimals: 2, signed: true),
                  color: isProfit ? AppColors.success : AppColors.danger,
                ),
                _MetricRow(
                  'Return',
                  _percent(returnPercent, signed: true),
                  color: isProfit ? AppColors.success : AppColors.danger,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _DetailSection(
              icon: Icons.business_outlined,
              title: 'Company Information',
              children: [
                _MetricRow(
                  'Sector',
                  portfolio.sector.isEmpty ? '--' : portfolio.sector,
                ),
                _MetricRow(
                  'Industry',
                  portfolio.industry.isEmpty ? '--' : portfolio.industry,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _ThesisSection(
              text: portfolio.investmentThesis.isEmpty
                  ? 'No investment thesis available.'
                  : portfolio.investmentThesis,
            ),
            const SizedBox(height: AppSpacing.lg),
            _aiPanel(scoreAsync),
          ],
        ),
      ),
    );
  }

  Widget _aiPanel(AsyncValue<StockScore?> scoreAsync) {
    return _DetailSection(
      icon: Icons.auto_awesome_rounded,
      title: 'AI Analysis',
      children: [
        scoreAsync.when(
          data: (score) {
            if (score == null) {
              return const _MetricRow('AI Score', 'N/A');
            }

            final scoreColor = _overallScoreColor(score.overallScore);
            final recommendationColor =
                _recommendationColor(score.recommendation);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('AI Score', style: AppTypography.caption),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${score.overallScore}/100',
                            style: AppTypography.heading1.copyWith(
                              color: scoreColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _RecommendationBadge(
                      label: score.recommendation,
                      color: recommendationColor,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value:
                        (score.overallScore / 100).clamp(0.0, 1.0).toDouble(),
                    minHeight: 8,
                    color: scoreColor,
                    backgroundColor: AppColors.surfaceSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _MetricRow('Confidence', '${score.confidence}%'),
                const Divider(height: AppSpacing.xl),
                _MetricRow(
                  'Business Quality',
                  '${score.businessQuality}/25',
                  color: _metricColor(score.businessQuality, 25),
                ),
                _MetricRow(
                  'Financial Strength',
                  '${score.financialStrength}/25',
                  color: _metricColor(score.financialStrength, 25),
                ),
                _MetricRow(
                  'Growth',
                  '${score.growth}/20',
                  color: _metricColor(score.growth, 20),
                ),
                _MetricRow(
                  'Valuation',
                  '${score.valuation}/15',
                  color: _metricColor(score.valuation, 15),
                ),
                _MetricRow(
                  'Technical',
                  '${score.technical}/10',
                  color: _metricColor(score.technical, 10),
                ),
                _MetricRow(
                  'Risk',
                  '${score.risk}/5',
                  color: _metricColor(score.risk, 5),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Suggested Actions', style: AppTypography.title),
                const SizedBox(height: AppSpacing.sm),
                _ActionList(actions: _actionsFor(score.recommendation)),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: LinearProgressIndicator(minHeight: 3),
          ),
          error: (_, __) => const _MetricRow('AI Score', 'Error'),
        ),
      ],
    );
  }

  Color _overallScoreColor(int value) {
    if (value >= 80) return AppColors.success;
    if (value >= 60) return AppColors.accent;
    if (value >= 40) return AppColors.warning;
    return AppColors.danger;
  }

  Color _metricColor(int value, int max) {
    final percent = value / max;
    if (percent >= 0.80) return AppColors.success;
    if (percent >= 0.60) return AppColors.accent;
    if (percent >= 0.40) return AppColors.warning;
    return AppColors.danger;
  }

  Color _recommendationColor(String recommendation) {
    switch (recommendation.toUpperCase()) {
      case 'STRONG BUY':
      case 'BUY':
        return AppColors.success;
      case 'SELL':
      case 'REDUCE':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  List<String> _actionsFor(String recommendation) {
    switch (recommendation.toUpperCase()) {
      case 'BUY':
      case 'STRONG BUY':
        return [
          'Accumulate on market dips',
          'Hold for long term',
          'Review after quarterly results',
        ];
      case 'HOLD':
        return [
          'Continue holding',
          'Monitor quarterly results',
          'Avoid emotional selling',
        ];
      case 'REDUCE':
        return [
          'Avoid fresh buying',
          'Review business performance',
          'Reduce on strong rallies',
        ];
      case 'SELL':
        return [
          'Exit on strength',
          'Reallocate capital',
          'Avoid averaging down',
        ];
      default:
        return [
          'Review latest financials',
        ];
    }
  }
}

class _StockHeader extends StatelessWidget {
  final String instrument;
  final String companyName;
  final String status;
  final bool isProfit;
  final double netPL;
  final double returnPercent;

  const _StockHeader({
    required this.instrument,
    required this.companyName,
    required this.status,
    required this.isProfit,
    required this.netPL,
    required this.returnPercent,
  });

  @override
  Widget build(BuildContext context) {
    final tone = isProfit ? AppColors.success : AppColors.danger;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.14),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                child: Center(
                  child: Text(
                    instrument.isEmpty ? '-' : instrument.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instrument,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      companyName.isEmpty
                          ? 'Company Name Coming Soon'
                          : companyName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (status.isNotEmpty)
                _DarkPill(label: status, color: AppColors.accent),
              _DarkPill(
                label: _money(netPL, decimals: 2, signed: true),
                color: tone,
              ),
              _DarkPill(
                label: _percent(returnPercent, signed: true),
                color: tone,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _DetailSection({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: AppColors.textPrimary, size: 19),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(title, style: AppTypography.title),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }
}

class _ThesisSection extends StatelessWidget {
  final String text;

  const _ThesisSection({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      icon: Icons.notes_rounded,
      title: 'Investment Thesis',
      children: [
        Text(text, style: AppTypography.body),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String title;
  final String value;
  final Color? color;

  const _MetricRow(
    this.title,
    this.value, {
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(title, style: AppTypography.caption),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.body.copyWith(
                color: color ?? AppColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _RecommendationBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: color),
      ),
    );
  }
}

class _DarkPill extends StatelessWidget {
  final String label;
  final Color color;

  const _DarkPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ActionList extends StatelessWidget {
  final List<String> actions;

  const _ActionList({
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: actions
          .map(
            (action) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 22,
                    width: 22,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: const BoxDecoration(
                      color: AppColors.successSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(action, style: AppTypography.body),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

String _money(num value, {int decimals = 0, bool signed = false}) {
  final prefix = signed && value >= 0 ? '+' : '';
  return '$prefix\u20B9${value.toStringAsFixed(decimals)}';
}

String _percent(num value, {bool signed = false}) {
  final prefix = signed && value >= 0 ? '+' : '';
  return '$prefix${value.toStringAsFixed(2)}%';
}
