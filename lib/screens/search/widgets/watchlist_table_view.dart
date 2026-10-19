import 'package:flutter/material.dart';

import '../../../core/utils/symbol_utils.dart';
import '../../../models/live_portfolio.dart';
import '../../../models/portfolio.dart';
import '../../../models/watchlist_item.dart';
import '../../stock/stock_detail_page.dart';

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
                      color: const Color(0xFF16171B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.bookmark_border_rounded,
                      color: Color(0xFF757A85),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No stocks in watchlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Search any stock and tap "+ Save" to track it here.\nPull down to sync and refresh.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF757A85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: 780,
          child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length + 1, // +1 for Header row
          separatorBuilder: (_, __) => const Divider(
            color: Color(0xFF23252B),
            height: 1,
            thickness: 1,
          ),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildTableHeader();
            }

            final item = items[index - 1];
            return _buildTableRow(context, item);
          },
        ),
      ),
    ),
  );
}

  Widget _buildTableHeader() {
    return Container(
      color: const Color(0xFF131418),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: const Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              'Company ⬍',
              style: TextStyle(
                color: Color(0xFF8E929B),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              'Score ⬍',
              style: TextStyle(
                color: Color(0xFF8E929B),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              'Added Price',
              style: TextStyle(
                color: Color(0xFFE5A93C),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 105,
            child: Text(
              'Latest Price ⬍\nChange',
              style: TextStyle(
                color: Color(0xFF8E929B),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              'Returns ⬍\nTracked Date',
              style: TextStyle(
                color: Color(0xFF8E929B),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Technical & Things you should know',
              style: TextStyle(
                color: Color(0xFF8E929B),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              'Action',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8E929B),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, WatchlistItem item) {
    final isPos = item.dayChangePercent >= 0;
    final changeColor = isPos ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    final isRetPos = item.returnPercent >= 0;
    final retColor = isRetPos ? const Color(0xFF00E676) : const Color(0xFFFF5252);

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
            investmentThesis: item.keyTakeaway,
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
        color: const Color(0xFF16171B),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Company Name
            SizedBox(
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.instrument,
                    style: const TextStyle(
                      color: Color(0xFF757A85),
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
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0x1FE5A93C),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0x33E5A93C)),
                  ),
                  child: Text(
                    '${item.score}',
                    style: const TextStyle(
                      color: Color(0xFFE5A93C),
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
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
                    '₹${item.addedPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    'Entry Point',
                    style: TextStyle(
                      color: Color(0xFF757A85),
                      fontSize: 10,
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
                    '₹${item.latestPrice.toStringAsFixed(2)}',
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
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    item.trackedDate,
                    style: const TextStyle(
                      color: Color(0xFF757A85),
                      fontSize: 10,
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
                      final upper = item.technicalTag.toUpperCase();
                      final Color tagBg;
                      if (upper.contains('STRONG') || upper.contains('OUTPERFORM') || upper.contains('BUY')) {
                        tagBg = const Color(0xFF00E676);
                      } else if (upper.contains('ACCUMULATE')) {
                        tagBg = const Color(0xFF4ADE80);
                      } else if (upper.contains('HOLD') || upper.contains('NEUTRAL') || upper.contains('RANGE')) {
                        tagBg = const Color(0xFFE5A93C);
                      } else if (upper.contains('CAUTION') || upper.contains('REDUCE')) {
                        tagBg = const Color(0xFFFF9800);
                      } else if (upper.contains('SELL') || upper.contains('UNDERPERFORM') || upper.contains('AVOID')) {
                        tagBg = const Color(0xFFFF5252);
                      } else {
                        tagBg = const Color(0xFF282A30);
                      }

                      final Color textColor = (tagBg == const Color(0xFF00E676) || tagBg == const Color(0xFF4ADE80))
                          ? Colors.black
                          : Colors.white;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.technicalTag.toUpperCase(),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 9.5,
                            letterSpacing: 0.3,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.keyTakeaway,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFC9D1D8),
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
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFFF5252),
                  size: 19,
                ),
                tooltip: 'Remove from Watchlist',
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
