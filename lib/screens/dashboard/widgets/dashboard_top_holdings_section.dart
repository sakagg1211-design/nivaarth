import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/symbol_utils.dart';
import '../../../models/live_portfolio.dart';
import '../../../providers/privacy_provider.dart';
import '../../stock/stock_detail_page.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';

class DashboardTopHoldingsSection extends ConsumerWidget {
  final List<LivePortfolio> holdings;
  final VoidCallback? onViewAll;

  const DashboardTopHoldingsSection({
    super.key,
    required this.holdings,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (holdings.isEmpty) return const SizedBox.shrink();
    final isPrivacy = ref.watch(privacyModeProvider);

    // Top Holdings: sorted by highest Current Value (₹) descending
    final sortedHoldings = List<LivePortfolio>.from(holdings)
      ..sort((a, b) => b.currentValue.compareTo(a.currentValue));
    final displayHoldings = sortedHoldings.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Holdings Header + "View all"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t.topHoldingsTitle,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.t.topHoldingsSub,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (onViewAll != null)
              InkWell(
                onTap: onViewAll,
                child: Text(
                  context.t.commonViewAll,
                  style: TextStyle(
                    color: AppColors.textSecondary,
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
          final tone = isProfit ? AppColors.success : AppColors.danger;

          String valStr;
          if (isPrivacy) {
            valStr = '₹ ••••';
          } else if (h.currentValue >= 100000) {
            valStr = '₹${(h.currentValue / 100000).toStringAsFixed(2)} L';
          } else if (h.currentValue >= 1000) {
            valStr = '₹${(h.currentValue / 1000).toStringAsFixed(1)}K';
          } else {
            valStr = Formatters.currency0(h.currentValue);
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.line,
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
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            sym.isNotEmpty ? sym.substring(0, 1) : 'S',
                            style: TextStyle(
                              color: AppColors.background,
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
                              style: TextStyle(
                                color: AppColors.ink,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              compName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textTertiary,
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
                            style: TextStyle(
                              color: AppColors.ink,
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
