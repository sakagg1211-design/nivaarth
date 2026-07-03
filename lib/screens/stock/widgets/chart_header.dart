import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class ChartHeader extends StatelessWidget {
  final String title;
  final double currentPrice;
  final double change;
  final double changePercent;

  const ChartHeader({
    super.key,
    required this.title,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
  });

  bool get _isPositive => change >= 0;

  @override
  Widget build(BuildContext context) {
    final Color gainColor =
        _isPositive ? AppColors.success : AppColors.danger;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                "Live Market Price",
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Text(
              _money(currentPrice),
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: gainColor.withOpacity(.10),
                borderRadius: BorderRadius.circular(
                  AppRadius.lg,
                ),
              ),
              child: Text(
                "${_money(change, signed: true)}  (${_percent(changePercent, signed: true)})",
                style: AppTypography.bodySmall.copyWith(
                  color: gainColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _money(
    num value, {
    bool signed = false,
  }) {
    final prefix =
        signed && value >= 0 ? "+" : "";

    return "$prefix₹${value.toStringAsFixed(2)}";
  }

  String _percent(
    num value, {
    bool signed = false,
  }) {
    final prefix =
        signed && value >= 0 ? "+" : "";

    return "$prefix${value.toStringAsFixed(2)}%";
  }
}