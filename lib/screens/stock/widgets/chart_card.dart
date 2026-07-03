import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class ChartCard extends StatelessWidget {
  final Widget child;

  const ChartCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.xl,
        ),
        border: Border.all(
          color: AppColors.outline.withValues(
            alpha: .18,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: .05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [

          Container(
            height: 4,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: .20,
              ),
              borderRadius:
                  BorderRadius.circular(
                100,
              ),
            ),
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [

                  AppColors.primary.withValues(
                    alpha: .035,
                  ),

                  Colors.transparent,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(
                AppRadius.lg,
              ),
            ),
            child: child,
          ),
                    const SizedBox(
            height: AppSpacing.md,
          ),

          Container(
            height: 1,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.outline.withValues(
                    alpha: .30,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),
        ],
      ),
    );
  }
}