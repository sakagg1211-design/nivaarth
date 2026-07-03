import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class ChartSelector extends StatelessWidget {
  final String selectedRange;
  final ValueChanged<String> onChanged;

  const ChartSelector({
    super.key,
    required this.selectedRange,
    required this.onChanged,
  });

  static const List<String> _ranges = [
    '1D',
    '1W',
    '1M',
    '3M',
    '1Y',
    'ALL',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _ranges.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final range = _ranges[index];
          final selected = range == selectedRange;

          return GestureDetector(
            onTap: () => onChanged(range),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(
                  AppRadius.lg,
                ),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.outline.withOpacity(.30),
                ),
              ),
              child: Center(
                child: Text(
                  range,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}