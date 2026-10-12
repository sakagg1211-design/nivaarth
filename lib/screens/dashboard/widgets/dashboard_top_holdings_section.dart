import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/symbol_utils.dart';
import '../../../models/live_portfolio.dart';
import '../../stock/stock_detail_page.dart';

class DashboardTopHoldingsSection extends StatelessWidget {
  final List<LivePortfolio> holdings;
  final VoidCallback? onViewAll;

  const DashboardTopHoldingsSection({
    super.key,
    required this.holdings,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (holdings.isEmpty) return const SizedBox.shrink();

    // 1. Calculate Real Sector Allocation using SymbolUtils.getSector
    final Map<String, double> sectorTotals = {};
    double grandTotal = 0;
    for (final h in holdings) {
      final sector = SymbolUtils.getSector(
        h.portfolio.instrument,
        dbSector: h.portfolio.sector,
      );
      sectorTotals[sector] = (sectorTotals[sector] ?? 0) + h.currentValue;
      grandTotal += h.currentValue;
    }

    final sortedSectors = sectorTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Top 3 sectors
    final top3Sectors = sortedSectors.take(3).toList();

    // Top Holdings: sorted by highest Current Value (₹) descending
    final sortedHoldings = List<LivePortfolio>.from(holdings)
      ..sort((a, b) => b.currentValue.compareTo(a.currentValue));
    final displayHoldings = sortedHoldings.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sector Allocation Heading
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sector Allocation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              '${sortedSectors.length} Sectors Active',
              style: const TextStyle(
                color: Color(0xFF757A85),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Top 3 Sectors Allocation Bars
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF16171B),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF282A30), width: 1),
          ),
          child: Column(
            children: top3Sectors.asMap().entries.map((entry) {
              final index = entry.key;
              final sector = entry.value;
              final percent = grandTotal > 0
                  ? ((sector.value / grandTotal) * 100).clamp(0.0, 100.0)
                  : 0.0;

              // Color accents for top 3 sectors
              const barColors = [
                Color(0xFFE5A93C), // Gold for #1
                Color(0xFF38BDF8), // Sky Blue for #2
                Color(0xFFA78BFA), // Violet for #3
              ];
              final barColor = barColors[index % barColors.length];

              return Padding(
                padding: EdgeInsets.only(bottom: index < top3Sectors.length - 1 ? 12 : 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: barColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              sector.key,
                              style: const TextStyle(
                                color: Color(0xFFE5E7EB),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${percent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: barColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (percent / 100).clamp(0.01, 1.0),
                        minHeight: 5,
                        backgroundColor: const Color(0xFF23252B),
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // Top Holdings Header + "View all"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top Holdings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Ranked by highest current valuation (₹)',
                  style: TextStyle(
                    color: Color(0xFF757A85),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (onViewAll != null)
              InkWell(
                onTap: onViewAll,
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: Color(0xFFE5A93C),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Holdings List items
        ...displayHoldings.map((h) {
          final sym = SymbolUtils.normalize(h.portfolio.instrument);
          final compName = SymbolUtils.getDisplayName(
            h.portfolio.instrument,
            dbCompanyName: h.portfolio.companyName,
          );
          final isProfit = h.returnPercent >= 0;
          final tone = isProfit ? const Color(0xFF00E676) : const Color(0xFFFF5252);

          String valStr;
          if (h.currentValue >= 100000) {
            valStr = '₹${(h.currentValue / 100000).toStringAsFixed(2)} L';
          } else if (h.currentValue >= 1000) {
            valStr = '₹${(h.currentValue / 1000).toStringAsFixed(1)}K';
          } else {
            valStr = Formatters.currency0(h.currentValue);
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF16171B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF282A30),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StockDetailPage(stock: h),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // White rounded square avatar
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            sym.isNotEmpty ? sym.substring(0, 1) : 'S',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Stock name & company
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              sym,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              compName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF757A85),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Value and % return
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            valStr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.percent(h.returnPercent, signed: true),
                            style: TextStyle(
                              color: tone,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
