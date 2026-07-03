import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class StatsGrid extends StatelessWidget {
  final List<StatItem> items;

  const StatsGrid({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Row(
          children: [

            Expanded(
              child: _StatTile(item: items[0]),
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: _StatTile(item: items[1]),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        Row(
          children: [

            Expanded(
              child: _StatTile(item: items[2]),
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: _StatTile(item: items[3]),
            ),
          ],
        ),
      ],
    );
  }
}

class StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const StatItem({
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });
}

class _StatTile extends StatelessWidget {
  final StatItem item;

  const _StatTile({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        item.color ?? AppColors.primary;

    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(
          AppRadius.card,
        ),
        border: Border.all(
          color: AppColors.outline.withValues(
            alpha: .18,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: .035,
            ),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [

          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: accent.withValues(
                alpha: .10,
              ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              item.icon,
              color: accent,
              size: 20,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  item.title,
                  style:
                      AppTypography.bodySmall
                          .copyWith(
                    color:
                        AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  item.value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                        letterSpacing: -0.2,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.chevron_right_rounded,
            color:
                AppColors.textTertiary,
            size: 18,
          ),
        ],
      ),
    );
  }
}