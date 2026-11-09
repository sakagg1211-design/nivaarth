import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
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
    return Row(
      children: [
        for (var i = 0; i < _ranges.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(child: _chip(_ranges[i])),
        ],
      ],
    );
  }

  Widget _chip(String range) {
    final selected = range == selectedRange;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(range),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          height: 38,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outline.withValues(alpha: 0.30),
            ),
          ),
          child: Center(
            child: Text(
              range,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.background : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
