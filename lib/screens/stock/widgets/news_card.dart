import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

enum NewsImpact {
  positive,
  neutral,
  negative,
}

class NewsItem {
  final String title;
  final String source;
  final String time;
  final NewsImpact impact;

  const NewsItem({
    required this.title,
    required this.source,
    required this.time,
    required this.impact,
  });
}

class NewsCard extends StatelessWidget {
  final List<NewsItem> news;

  const NewsCard({
    super.key,
    required this.news,
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
                  Icons.newspaper_rounded,
                  color: AppColors.primary,
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
                      "Latest News",
                      style: AppTypography
                          .titleLarge
                          .copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    Text(
                      "AI curated market updates",
                      style: AppTypography
                          .bodySmall,
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withValues(
                    alpha: .10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  "${news.length}",
                  style: AppTypography
                      .bodySmall
                      .copyWith(
                    color:
                        AppColors.primary,
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

          if (news.isEmpty)

            const _EmptyNews()

          else

            ...news.map(
              (item) => _NewsTile(
                item: item,
              ),
            ),
                    ],
      ),
    );
  }
}

class _NewsTile extends StatelessWidget {
  final NewsItem item;

  const _NewsTile({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {

    final Color impactColor =
        _impactColor(item.impact);

    return Padding(

      padding: const EdgeInsets.only(
        bottom: AppSpacing.lg,
      ),

      child: Row(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: impactColor.withValues(
                alpha: .10,
              ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              _impactIcon(item.impact),
              color: impactColor,
              size: 20,
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
                  item.title,
                  maxLines: 3,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      AppTypography.bodyMedium
                          .copyWith(
                    fontWeight:
                        FontWeight.w700,
                    height: 1.45,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [

                    _MetaChip(
                      icon:
                          Icons.public_rounded,
                      text: item.source,
                    ),

                    _MetaChip(
                      icon:
                          Icons.schedule_rounded,
                      text: item.time,
                    ),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            impactColor.withValues(
                          alpha: .10,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Text(
                        _impactLabel(
                          item.impact,
                        ),
                        style: AppTypography
                            .bodySmall
                            .copyWith(
                          color:
                              impactColor,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _impactColor(
    NewsImpact impact,
  ) {
    switch (impact) {
      case NewsImpact.positive:
        return AppColors.success;

      case NewsImpact.negative:
        return AppColors.danger;

      case NewsImpact.neutral:
        return AppColors.warning;
    }
  }

  IconData _impactIcon(
    NewsImpact impact,
  ) {
    switch (impact) {
      case NewsImpact.positive:
        return Icons.trending_up_rounded;

      case NewsImpact.negative:
        return Icons.trending_down_rounded;

      case NewsImpact.neutral:
        return Icons.remove_rounded;
    }
  }

  String _impactLabel(
    NewsImpact impact,
  ) {
    switch (impact) {
      case NewsImpact.positive:
        return "Positive";

      case NewsImpact.negative:
        return "Negative";

      case NewsImpact.neutral:
        return "Neutral";
    }
  }
}
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(
          18,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),

          const SizedBox(
            width: 6,
          ),

          Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNews extends StatelessWidget {
  const _EmptyNews();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 36,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
      ),
      child: Column(
        children: [

          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: .10,
              ),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: const Icon(
              Icons.newspaper_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          Text(
            "No News Available",
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          Text(
            "Latest company news and market updates will automatically appear here when available.",
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          const SizedBox(
            height: AppSpacing.lg,
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: .10,
              ),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
            child: Text(
              "Auto Refresh",
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}