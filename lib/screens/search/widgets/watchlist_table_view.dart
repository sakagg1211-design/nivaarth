import '../../../core/utils/formatters.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/symbol_utils.dart';
import '../../../models/live_portfolio.dart';
import '../../../models/portfolio.dart';
import '../../../models/watchlist_item.dart';
import '../../stock/stock_detail_page.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/utils/watch_takeaway.dart';
import '../../../core/theme/app_colors.dart';

class WatchlistTableView extends StatelessWidget {
  final List<WatchlistItem> items;
  final ValueChanged<WatchlistItem>? onItemTap;
  final ValueChanged<WatchlistItem>? onDelete;

  const WatchlistTableView({
    super.key,
    required this.items,
    this.onItemTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.bookmark_border_rounded,
                      color: AppColors.textTertiary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.t.watchEmptyTitle,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.t.watchEmptyBody,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Phones scroll the 780px table sideways; wider screens stretch it to fit,
    // giving the extra room to the company name and the takeaway text.
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > _minTableWidth;
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: wide ? constraints.maxWidth : _minTableWidth,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length + 1, // +1 for Header row
                separatorBuilder: (context, index) => Divider(
                  color: AppColors.surfaceSecondary,
                  height: 1,
                  thickness: 1,
                ),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildTableHeader(context, wide);
                  }

                  final item = items[index - 1];
                  return _buildTableRow(context, item, wide);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableHeader(BuildContext context, bool wide) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          SizedBox(
            width: _companyWidth(wide),
            child: Text(
              context.t.watchColCompany,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              context.t.watchColScore,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              context.t.watchColAdded,
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 105,
            child: Text(
              context.t.watchColLatest,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              context.t.watchColReturns,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ),
          Expanded(
            child: Text(
              context.t.watchColTech,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              context.t.watchColAction,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const double _minTableWidth = 780;

  double _companyWidth(bool wide) => wide ? 220 : 150;

  Widget _buildTableRow(BuildContext context, WatchlistItem item, bool wide) {
    final isPos = item.dayChangePercent >= 0;
    final changeColor = isPos
        ? AppColors.success
        : AppColors.danger;
    final isRetPos = item.returnPercent >= 0;
    final retColor = isRetPos
        ? AppColors.success
        : AppColors.danger;

    return InkWell(
      onTap: () {
        if (onItemTap != null) {
          onItemTap!(item);
          return;
        }

        final targetStock = LivePortfolio(
          portfolio: Portfolio(
            id: '0',
            instrument: item.instrument,
            companyName: item.companyName,
            yahooSymbol: SymbolUtils.getYahooSymbol(item.instrument),
            qty: 0,
            avgPrice: item.addedPrice,
            totalInvested: 0.0,
            currentValue: 0.0,
            netPL: 0.0,
            sector: SymbolUtils.getSector(item.instrument),
            industry: '',
            status: 'WATCHLIST',
            investmentThesis: takeawayText(item, context.t),
          ),
          currentPrice: item.latestPrice,
          currentValue: 0.0,
          netPL: 0.0,
          returnPercent: item.returnPercent,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StockDetailPage(stock: targetStock),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        color: AppColors.surface,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Company Name
            SizedBox(
              width: _companyWidth(wide),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.info,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.instrument,
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Score (Clean badge without lock symbol)
            SizedBox(
              width: 60,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.20)),
                  ),
                  child: Text(
                    (item.score != null && item.score! > 0)
                        ? '${item.score}'
                        : '—',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),

            // Added Price (Column requested by user)
            SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Formatters.currency(item.addedPrice),
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    context.t.watchEntry,
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Latest Price & Day Change
            SizedBox(
              width: 105,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Formatters.currency(item.latestPrice),
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${isPos ? '+' : ''}${item.dayChangePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Returns & Tracked Date
            SizedBox(
              width: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${isRetPos ? '+' : ''}${item.returnPercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: retColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    item.trackedDate,
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Technical Pill & Takeaway
            Expanded(
              child: Row(
                children: [
                  Builder(
                    builder: (context) {
                      final compliantTag = SymbolUtils.toCompliantVerdict(
                        item.technicalTag,
                      );
                      final upper = compliantTag.toUpperCase();
                      final Color tagBg;
                      if (upper.contains('STRONG') ||
                          upper.contains('OUTPERFORM')) {
                        tagBg = AppColors.success;
                      } else if (upper.contains('MODERATE') ||
                          upper.contains('STRENGTH')) {
                        tagBg = AppColors.success;
                      } else if (upper.contains('WATCH') ||
                          upper.contains('NEUTRAL') ||
                          upper.contains('RANGE')) {
                        tagBg = AppColors.accent;
                      } else if (upper.contains('ELEVATED') ||
                          upper.contains('RISK') && !upper.contains('HIGH')) {
                        tagBg = AppColors.warning;
                      } else if (upper.contains('HIGH RISK') ||
                          upper.contains('UNDERPERFORM') ||
                          upper.contains('AVOID')) {
                        tagBg = AppColors.danger;
                      } else {
                        tagBg = AppColors.line;
                      }

                      final Color textColor =
                          (tagBg == AppColors.success ||
                              tagBg == AppColors.success)
                          ? Colors.black
                          : tagBg == AppColors.line ? AppColors.ink : Colors.white;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          compliantTag,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.3,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      takeawayText(item, context.t),
                      maxLines: wide ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.inkSoft,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Delete Action Button
            SizedBox(
              width: 44,
              child: IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.danger,
                  size: 19,
                ),
                tooltip: context.t.watchRemove,
                onPressed: () {
                  if (onDelete != null) {
                    onDelete!(item);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
