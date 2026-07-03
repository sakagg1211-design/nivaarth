import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/search_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(searchProvider(query));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Search', style: AppTypography.heading1),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Find stocks by instrument and review their AI score.',
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Search stocks',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: result.when(
                  loading: () => const _SearchState(
                    icon: Icons.manage_search_rounded,
                    title: 'Searching market universe',
                    message: 'Matching symbols and AI scores.',
                    loading: true,
                  ),
                  error: (e, _) => _SearchState(
                    icon: Icons.error_outline_rounded,
                    title: 'Search unavailable',
                    message: e.toString(),
                  ),
                  data: (stocks) {
                    if (query.isEmpty) {
                      return const _SearchState(
                        icon: Icons.search_rounded,
                        title: 'Start with a symbol',
                        message: 'Search any stock to see recommendations.',
                      );
                    }

                    if (stocks.isEmpty) {
                      return const _SearchState(
                        icon: Icons.remove_circle_outline_rounded,
                        title: 'No stock found',
                        message: 'Try another instrument or company name.',
                      );
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                      itemCount: stocks.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final stock = stocks[index];

                        return Material(
                          color: AppColors.surface,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            side: const BorderSide(color: AppColors.line),
                          ),
                          child: ListTile(
                            minVerticalPadding: AppSpacing.md,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Stock detail from search is coming in next sprint.',
                                  ),
                                ),
                              );
                            },
                            leading: Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                color: AppColors.ink,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                              ),
                              child: Center(
                                child: Text(
                                  stock.instrument.isEmpty
                                      ? '-'
                                      : stock.instrument.substring(0, 1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              stock.instrument,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.title,
                            ),
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.only(top: AppSpacing.xs),
                              child: Text(
                                stock.recommendation,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption,
                              ),
                            ),
                            trailing: _ScoreBadge(score: stock.overallScore),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(score);

    return Container(
      width: 48,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '$score',
        style: AppTypography.title.copyWith(color: color),
      ),
    );
  }

  Color _scoreColor(int value) {
    if (value >= 80) return AppColors.success;
    if (value >= 60) return AppColors.accent;
    if (value >= 40) return AppColors.warning;
    return AppColors.danger;
  }
}

class _SearchState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool loading;

  const _SearchState({
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
