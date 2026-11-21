import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/live_portfolio_provider.dart';
import '../../../providers/news_provider.dart';
import '../../../providers/privacy_provider.dart';
import '../../stock/stock_detail_page.dart';

const _surface = Color(0xFF16171B);
const _muted = Color(0xFF8E929B);
final _day = DateFormat('d MMM');
final _time = DateFormat('HH:mm');

/// "Aapki holdings ki khabrein": holdings with headlines this session, biggest rupee move first.
/// Hidden when none of them has news.
class HoldingsNewsCard extends ConsumerWidget {
  const HoldingsNewsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(holdingsNewsProvider).valueOrNull;
    if (n == null || n.top.isEmpty) return const SizedBox.shrink();
    final t = context.t;
    final hide = ref.watch(privacyModeProvider);
    final holdings = ref.watch(livePortfolioProvider).valueOrNull ?? const [];

    // The card brings its own top gap, so a hidden card leaves no empty space on the Dashboard
    return Container(
      margin: const EdgeInsets.only(top: 14),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(t.newsHoldingsTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(n.live ? t.newsLive : t.newsSessionClose(_day.format(n.sessionDate)),
                    style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final it in n.top.take(5))
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                final stock = holdings.where((h) => h.portfolio.instrument.trim().toUpperCase() == it.symbol).firstOrNull;
                if (stock != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => StockDetailPage(stock: stock)));
                }
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(it.symbol,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                                const SizedBox(width: 8),
                                if (it.stockPct != null)
                                  Text(Formatters.percent(it.stockPct!, signed: true),
                                      style: TextStyle(
                                          color: it.stockPct! < 0 ? AppColors.danger : AppColors.success,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700)),
                                const SizedBox(width: 6),
                                if (it.rupeeMove != null)
                                  Text(hide ? '••••' : Formatters.currency0(it.rupeeMove!, signed: true),
                                      style: const TextStyle(color: _muted, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(it.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3)),
                            const SizedBox(height: 2),
                            Text('${it.source} · ${_time.format(it.publishedAt)}',
                                style: const TextStyle(color: _muted, fontSize: 11)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 18, color: _muted),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
