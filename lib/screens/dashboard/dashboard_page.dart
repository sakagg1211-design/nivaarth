import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/dashboard_provider.dart';
import 'widgets/ai_verdict_card.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/portfolio_health_card.dart';
import 'widgets/top_opportunity_card.dart';
import 'widgets/weakest_holding_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: dashboard.when(
          loading: () => const _ScreenState(
            icon: Icons.hourglass_empty_rounded,
            title: 'Building your portfolio view',
            message: 'Fetching live value, health and AI signals.',
            loading: true,
          ),
          error: (e, _) => _ScreenState(
            icon: Icons.error_outline_rounded,
            title: 'Dashboard unavailable',
            message: e.toString(),
          ),
          data: (data) {
            final isProfit = data.totalPnL >= 0;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DashboardHeader(),
                        const SizedBox(height: AppSpacing.xl),
                        PortfolioHealthCard(
                          healthScore: data.portfolioHealth,
                          action: data.aiRecommendation.recommendation.name
                              .toUpperCase(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _SnapshotCard(
                          currentValue: data.currentValue,
                          totalInvested: data.totalInvested,
                          totalPnL: data.totalPnL,
                          returnPercent: data.returnPercent,
                          totalStocks: data.totalStocks,
                          isProfit: isProfit,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: _MoveCard(
                                icon: Icons.north_east_rounded,
                                title: 'Biggest Winner',
                                instrument:
                                    data.biggestWinner.portfolio.instrument,
                                value: _percent(
                                  data.biggestWinner.returnPercent,
                                  signed: true,
                                ),
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Flexible(
                              fit: FlexFit.loose,
                              child: _MoveCard(
                                icon: Icons.south_east_rounded,
                                title: 'Biggest Loser',
                                instrument:
                                    data.biggestLoser.portfolio.instrument,
                                value: _percent(
                                  data.biggestLoser.returnPercent,
                                  signed: true,
                                ),
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        const _SectionHeader(
                          title: 'AI Briefing',
                          subtitle: 'Signals ranked by conviction and risk.',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AIVerdictCard(ai: data.aiRecommendation),
                        const SizedBox(height: AppSpacing.lg),
                        TopOpportunityCard(stock: data.topOpportunity),
                        const SizedBox(height: AppSpacing.lg),
                        WeakestHoldingCard(stock: data.weakestHolding),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  final double currentValue;
  final double totalInvested;
  final double totalPnL;
  final double returnPercent;
  final int totalStocks;
  final bool isProfit;

  const _SnapshotCard({
    required this.currentValue,
    required this.totalInvested,
    required this.totalPnL,
    required this.returnPercent,
    required this.totalStocks,
    required this.isProfit,
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
            color: AppColors.ink.withValues(alpha: 0.16),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Portfolio Snapshot',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  _percent(returnPercent, signed: true),
                  style: TextStyle(
                    color: tone,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _money(currentValue, decimals: 2),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _DarkMetricTile(
                  title: 'Invested',
                  value: _money(totalInvested),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _DarkMetricTile(
                  title: 'Stocks',
                  value: totalStocks.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _DarkMetricTile(
                  title: 'Net P&L',
                  value: _money(totalPnL, signed: true),
                  valueColor: tone,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _DarkMetricTile(
                  title: 'Return',
                  value: _percent(returnPercent, signed: true),
                  valueColor: tone,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DarkMetricTile extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _DarkMetricTile({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoveCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String instrument;
  final String value;
  final Color color;

  const _MoveCard({
    required this.icon,
    required this.title,
    required this.instrument,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 132,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title.copyWith(
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption,
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            instrument,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.title,
          ),
        ],
      ),
    );
  }
}
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.heading2),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: AppTypography.body),
      ],
    );
  }
}

class _ScreenState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool loading;

  const _ScreenState({
    required this.icon,
    required this.title,
    required this.message,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.line),
              ),
              child: Icon(icon, color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, textAlign: TextAlign.center, style: AppTypography.title),
            const SizedBox(height: AppSpacing.sm),
            Text(message, textAlign: TextAlign.center, style: AppTypography.body),
            if (loading) ...[
              const SizedBox(height: AppSpacing.lg),
              const SizedBox(
                width: 160,
                child: LinearProgressIndicator(minHeight: 3),
              ),
            ],
          ],
        ),
      ),
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