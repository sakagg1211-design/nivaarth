import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class CompanyOverviewCard extends StatelessWidget {
  final String companyName;
  final String sector;
  final String industry;
  final String status;

  const CompanyOverviewCard({
    super.key,
    required this.companyName,
    required this.sector,
    required this.industry,
    required this.status,
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
            blurRadius: 14,
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
                  Icons.business,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(
                width: AppSpacing.md,
              ),

              Text(
                "Company Overview",
                style: AppTypography.titleLarge.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.xl,
          ),

          _OverviewTile(
            icon: Icons.apartment,
            title: "Company",
            value: companyName.isEmpty
                ? "--"
                : companyName,
          ),

          _Divider(),

          _OverviewTile(
            icon: Icons.category_outlined,
            title: "Sector",
            value: sector.isEmpty
                ? "--"
                : sector,
          ),

          _Divider(),

          _OverviewTile(
            icon: Icons.precision_manufacturing_outlined,
            title: "Industry",
            value: industry.isEmpty
                ? "--"
                : industry,
          ),

          _Divider(),

          _OverviewTile(
            icon: Icons.verified_outlined,
            title: "Status",
            value: status.isEmpty
                ? "--"
                : status,
            highlight: true,
          ),
                  ],
      ),
    );
  }
}

class _OverviewTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool highlight;

  const _OverviewTile({
    required this.icon,
    required this.title,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = highlight
        ? AppColors.success
        : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: accent.withValues(
                alpha: .10,
              ),
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: accent,
            ),
          ),

          const SizedBox(
            width: AppSpacing.md,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: AppTypography.bodySmall
                      .copyWith(
                    color: AppColors
                        .textSecondary,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  value,
                  style: AppTypography
                      .titleMedium
                      .copyWith(
                    fontWeight:
                        FontWeight.w700,
                    color: highlight
                        ? accent
                        : AppColors
                            .textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.outline.withValues(
        alpha: .20,
      ),
    );
  }
}