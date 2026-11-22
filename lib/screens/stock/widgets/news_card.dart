import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/stock_news.dart';
import '../../../providers/locale_provider.dart';
import '../../../providers/news_provider.dart';

final _day = DateFormat('d MMM');
final _time = DateFormat('d MMM, HH:mm');

/// "Aaj kyun hila": the stock's move next to Nifty 50 and its sector, a one-line summary of the
/// session's headlines, and the headlines with their sources. Facts only: no good/bad labels.
class NewsCard extends ConsumerWidget {
  final String symbol;
  const NewsCard({super.key, required this.symbol});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(stockNewsProvider(symbol));
    final n = async.valueOrNull;
    if (async.isLoading) return const _Skeleton();
    if (n == null) return const SizedBox.shrink();
    final t = context.t;
    final hinglish = Localizations.localeOf(context) == hinglishLocale;
    final summary = n.move.kind == 'split_day' ? null : (hinglish ? n.summaryHi : n.summaryEn);
    final sentence = _sentence(n.move.kind, t);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.outline.withValues(alpha: .18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.newspaper_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(n.live ? t.newsTitle : t.newsTitleClosed, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold))),
              _Chip(n.live ? t.newsLive : t.newsSessionClose(_day.format(n.sessionDate))),
            ],
          ),
          if (n.move.stockPct != null) ...[
            const SizedBox(height: AppSpacing.md),
            _MoveRow(symbol, n.move.stockPct!, strong: true),
            if (n.move.niftyPct != null) _MoveRow('Nifty 50', n.move.niftyPct!),
            if (n.move.sectorPct != null && n.move.sector != null) _MoveRow(n.move.sector!, n.move.sectorPct!),
          ],
          if (sentence != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(sentence, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4)),
          ],
          if (summary != null && summary.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(summary, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, height: 1.4)),
          ],
          const SizedBox(height: AppSpacing.md),
          if (n.isEmpty)
            Text(t.newsEmptyBody, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary))
          else ...[
            if (n.session.isNotEmpty) _Group(t.newsSessionHeadlines, n.session),
            if (!n.live && n.afterClose.isNotEmpty) _Group(t.newsAfterClose, n.afterClose),
            if (n.recent.isNotEmpty) _Group(t.newsRecent, n.recent),
          ],
        ],
      ),
    );
  }

  static String? _sentence(String? kind, AppLocalizations t) => switch (kind) {
        'market' => t.newsKindMarket,
        'sector' => t.newsKindSector,
        'own' => t.newsKindOwn,
        'against' => t.newsKindAgainst,
        'flat' => t.newsKindFlat,
        'split_day' => t.newsKindSplit,
        _ => null,
      };
}

class _MoveRow extends StatelessWidget {
  final String label;
  final double pct;
  final bool strong;
  const _MoveRow(this.label, this.pct, {this.strong = false});

  @override
  Widget build(BuildContext context) {
    final color = pct > 0 ? AppColors.success : (pct < 0 ? AppColors.danger : AppColors.textSecondary);
    final style = AppTypography.bodyMedium.copyWith(fontWeight: strong ? FontWeight.w700 : FontWeight.w500);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style, overflow: TextOverflow.ellipsis)),
          Text(Formatters.percent(pct, signed: true), style: style.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final String title;
  final List<NewsHeadline> items;
  const _Group(this.title, this.items);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          for (final h in items)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: h.url.isEmpty ? null : () => launchUrl(Uri.parse(h.url), mode: LaunchMode.externalApplication),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.title, maxLines: 3, overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, height: 1.35)),
                      const SizedBox(height: 2),
                      Text('${h.source} · ${_time.format(h.publishedAt)}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
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

class _Chip extends StatelessWidget {
  final String text;
  const _Chip(this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      );
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) => Container(
        height: 120,
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg)),
      );
}
