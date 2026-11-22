import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/symbol_utils.dart';
import '../../../core/utils/today_facts.dart';
import '../../../providers/live_portfolio_provider.dart';
import '../../../providers/news_provider.dart';
import '../../../providers/today_facts_provider.dart';
import '../../stock/stock_detail_page.dart';

Color get _surface => AppColors.surface;
Color get _muted => AppColors.textSecondary;

const _down = {FactKind.topDrag, FactKind.low52, FactKind.scoreDown};
const _up = {FactKind.topLift, FactKind.high52, FactKind.scoreUp, FactKind.yearHigh, FactKind.upStreak};

/// "Aaj ki baatein": the three facts about today that matter most. Hidden when there are none.
class TodayFactsCard extends ConsumerWidget {
  final VoidCallback? onOpenPortfolio;
  const TodayFactsCard({super.key, this.onOpenPortfolio});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facts = ref.watch(todayFactsProvider).valueOrNull ?? const <Fact>[];
    if (facts.isEmpty) return const SizedBox.shrink();
    final holdings = ref.watch(livePortfolioProvider).valueOrNull ?? const [];
    final newsCounts = ref.watch(holdingsNewsProvider).valueOrNull?.counts ?? const <String, int>{};

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ink.withValues(alpha: .06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t.factsTitle, style: TextStyle(color: AppColors.ink, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          for (final f in facts)
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                final stock = f.symbol == null
                    ? null
                    : holdings.where((h) => SymbolUtils.normalize(h.portfolio.instrument) == SymbolUtils.normalize(f.symbol!)).firstOrNull;
                if (stock != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => StockDetailPage(stock: stock)));
                } else {
                  onOpenPortfolio?.call();
                }
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Row(
                  children: [
                    Icon(
                      _down.contains(f.kind)
                          ? Icons.south_east_rounded
                          : _up.contains(f.kind)
                              ? Icons.north_east_rounded
                              : Icons.info_outline_rounded,
                      size: 16,
                      color: _down.contains(f.kind)
                          ? AppColors.danger
                          : _up.contains(f.kind)
                              ? AppColors.success
                              : _muted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(factText(f, context.t),
                              style: TextStyle(color: AppColors.ink, fontSize: 13, height: 1.3, fontWeight: FontWeight.w500)),
                          if ((newsCounts[f.symbol == null ? '' : SymbolUtils.normalize(f.symbol!)] ?? 0) > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(context.t.newsCountToday(newsCounts[SymbolUtils.normalize(f.symbol!)]!),
                                  style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, size: 18, color: _muted),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
