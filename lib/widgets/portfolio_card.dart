import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_radius.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../models/live_portfolio.dart';
import '../screens/stock/stock_detail_page.dart';

class PortfolioCard extends StatelessWidget {
  final LivePortfolio stock;

  const PortfolioCard({
    super.key,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    final portfolio = stock.portfolio;
    final isProfit = stock.netPL >= 0;
    final tone = isProfit ? AppColors.success : AppColors.danger;

    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StockDetailPage(stock: stock),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Center(
                      child: Text(
                        portfolio.instrument.isEmpty
                            ? '-'
                            : portfolio.instrument.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
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
                          portfolio.instrument,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.title,
                        ),
                        if (portfolio.companyName.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            portfolio.companyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  if (portfolio.status.isNotEmpty)
                    _Tag(label: portfolio.status, color: AppColors.accent),
                  if (portfolio.sector.isNotEmpty)
                    _Tag(label: portfolio.sector, color: AppColors.mint),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      label: 'Current Value',
                      value: _money(stock.currentValue, decimals: 2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _MetricTile(
                      label: 'Net P&L',
                      value: _money(stock.netPL, decimals: 2, signed: true),
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
                      label: 'Avg Price',
                      value: _money(portfolio.avgPrice, decimals: 2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _MetricTile(
                      label: 'Return',
                      value: _percent(stock.returnPercent, signed: true),
                      color: tone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _DetailRow('Quantity', portfolio.qty.toString()),
              _DetailRow(
                'Invested',
                _money(portfolio.totalInvested, decimals: 2),
              ),
              _DetailRow(
                'Current Price',
                _money(stock.currentPrice, decimals: 2),
              ),
            ],
          ),
        ),
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

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;

  const _DetailRow(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTypography.caption)),
          Text(value, style: AppTypography.body.copyWith(color: AppColors.ink)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({
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

String _money(num value, {int decimals = 0, bool signed = false}) {
  final prefix = signed && value >= 0 ? '+' : '';
  return '$prefix\u20B9${value.toStringAsFixed(decimals)}';
}

String _percent(num value, {bool signed = false}) {
  final prefix = signed && value >= 0 ? '+' : '';
  return '$prefix${value.toStringAsFixed(2)}%';
}
