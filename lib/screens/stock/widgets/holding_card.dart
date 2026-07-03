import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/live_portfolio.dart';

class HoldingCard extends StatelessWidget {
  final LivePortfolio stock;

  const HoldingCard({
    super.key,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    final portfolio = stock.portfolio;

    final bool isProfit =
        stock.netPL >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        border: Border.all(
          color: AppColors.outline.withValues(
            alpha: .18,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: .04,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: .10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(
                width: AppSpacing.md,
              ),

              Expanded(
                child: Text(
                  "Holding Details",
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isProfit
                      ? AppColors.success.withValues(
                          alpha: .10,
                        )
                      : AppColors.danger.withValues(
                          alpha: .10,
                        ),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  isProfit
                      ? "PROFIT"
                      : "LOSS",
                  style: AppTypography.bodySmall.copyWith(
                    color: isProfit
                        ? AppColors.success
                        : AppColors.danger,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.xl,
          ),

          _HoldingRow(
            "Quantity",
            portfolio.qty.toString(),
            Icons.inventory_2_outlined,
          ),

          _HoldingRow(
            "Average Price",
            _money(portfolio.avgPrice),
            Icons.payments_outlined,
          ),

          _HoldingRow(
            "Current Price",
            _money(stock.currentPrice),
            Icons.show_chart,
          ),

          _HoldingRow(
            "Invested Value",
            _money(portfolio.totalInvested),
            Icons.account_balance_wallet_outlined,
          ),
                    _HoldingRow(
            "Current Value",
            _money(stock.currentValue),
            Icons.savings_outlined,
          ),

          _HoldingRow(
            "Net P&L",
            _money(
              stock.netPL,
              signed: true,
            ),
            Icons.trending_up,
            valueColor: isProfit
                ? AppColors.success
                : AppColors.danger,
          ),

          _HoldingRow(
            "Return",
            _percent(
              stock.returnPercent,
            ),
            Icons.percent,
            valueColor: isProfit
                ? AppColors.success
                : AppColors.danger,
          ),
        ],
      ),
    );
  }

  static String _money(
    num value, {
    bool signed = false,
  }) {
    final prefix =
        signed && value >= 0 ? "+" : "";

    return "$prefix₹${value.toStringAsFixed(2)}";
  }

  static String _percent(
    num value,
  ) {
    return "${value.toStringAsFixed(2)}%";
  }
}

class _HoldingRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _HoldingRow(
    this.title,
    this.value,
    this.icon, {
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [

          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: .08,
              ),
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(
            width: AppSpacing.md,
          ),

          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                color:
                    AppColors.textSecondary,
              ),
            ),
          ),

          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              fontWeight:
                  FontWeight.w700,
              color: valueColor ??
                  AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}