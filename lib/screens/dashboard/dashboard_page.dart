import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/dashboard_provider.dart';
import 'widgets/ai_verdict_card.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/portfolio_health_card.dart';
import 'widgets/top_opportunity_card.dart';
import 'widgets/weakest_holding_card.dart';
import 'widgets/portfolio_hero_card.dart';

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
                        const SizedBox(height: 28),
                        PortfolioHeroCard(
                         currentValue: data.currentValue,
                          investedValue: data.totalInvested,
                          netPnL: data.totalPnL,
                          returnPercent: data.returnPercent,
                          holdings: data.totalStocks,
                          aiConfidence: 74,
                        ),
                        const SizedBox(height: 28),
                       
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
    final color = valueColor ?? Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: .06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: .2,
            ),
          ),

          const SizedBox(height: 6),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
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