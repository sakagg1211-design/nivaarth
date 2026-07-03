import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/live_portfolio_provider.dart';
import '../../widgets/portfolio_card.dart';

class PortfolioPage extends ConsumerWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(livePortfolioProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: portfolio.when(
          loading: () => const _PortfolioState(
            icon: Icons.hourglass_empty_rounded,
            title: 'Loading holdings',
            message: 'Pulling your live portfolio positions.',
            loading: true,
          ),
          error: (e, _) => _PortfolioState(
            icon: Icons.error_outline_rounded,
            title: 'Portfolio unavailable',
            message: e.toString(),
          ),
          data: (stocks) {
            if (stocks.isEmpty) {
              return const _PortfolioState(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Portfolio is empty',
                message: 'Add holdings to unlock live P&L and AI review.',
              );
            }

            double totalInvested = 0;
            double totalCurrentValue = 0;
            double totalPnL = 0;

            for (final stock in stocks) {
              totalInvested += stock.portfolio.totalInvested;
              totalCurrentValue += stock.currentValue;
              totalPnL += stock.netPL;
            }

            final totalReturn = totalInvested == 0
                ? 0.0
                : (totalPnL / totalInvested) * 100;
            final isProfit = totalPnL >= 0;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Portfolio', style: AppTypography.heading1),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '${stocks.length} holdings under active review.',
                          style: AppTypography.body,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _SummaryCard(
                          totalStocks: stocks.length,
                          totalInvested: totalInvested,
                          totalCurrentValue: totalCurrentValue,
                          totalPnL: totalPnL,
                          totalReturn: totalReturn,
                          isProfit: isProfit,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Holdings',
                                style: AppTypography.heading2,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSecondary,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                                border: Border.all(color: AppColors.line),
                              ),
                              child: Text(
                                'Live',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  sliver: SliverList.separated(
                    itemCount: stocks.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return PortfolioCard(stock: stocks[index]);
                    },
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

class _SummaryCard extends StatelessWidget {
  final int totalStocks;
  final double totalInvested;
  final double totalCurrentValue;
  final double totalPnL;
  final double totalReturn;
  final bool isProfit;

  const _SummaryCard({
    required this.totalStocks,
    required this.totalInvested,
    required this.totalCurrentValue,
    required this.totalPnL,
    required this.totalReturn,
    required this.isProfit,
  });

  @override
  Widget build(BuildContext context) {
    final tone = isProfit ? AppColors.success : AppColors.danger;

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
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Portfolio Summary', style: AppTypography.title),
              ),
              Text(
                _percent(totalReturn, signed: true),
                style: AppTypography.title.copyWith(color: tone),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Current Value',
                  value: _money(totalCurrentValue, decimals: 2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricTile(
                  label: 'Net P&L',
                  value: _money(totalPnL, decimals: 2, signed: true),
                  color: tone,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Invested',
                  value: _money(totalInvested, decimals: 2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricTile(
                  label: 'Stocks',
                  value: totalStocks.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MetricTile({
    required this.label,
    required this.value,
    this.color,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.title.copyWith(
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool loading;

  const _PortfolioState({
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
