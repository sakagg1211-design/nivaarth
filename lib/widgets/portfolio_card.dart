import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_radius.dart';
import '../core/utils/formatters.dart';
import '../core/utils/symbol_utils.dart';
import '../models/live_portfolio.dart';
import '../providers/dashboard_provider.dart';
import '../providers/live_portfolio_provider.dart';
import '../providers/portfolio_provider.dart';
import '../repositories/portfolio_repository.dart';
import '../screens/portfolio/widgets/edit_holding_sheet.dart';
import '../screens/stock/stock_detail_page.dart';

class PortfolioCard extends ConsumerWidget {
  final LivePortfolio stock;

  const PortfolioCard({
    super.key,
    required this.stock,
  });

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2024),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF282A30)),
        ),
        title: Row(
          children: [
            const Icon(Icons.delete_forever_rounded, color: Color(0xFFFF5252), size: 24),
            const SizedBox(width: 8),
            Text(
              'Remove ${stock.portfolio.instrument}?',
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${stock.portfolio.instrument} from your portfolio?',
          style: const TextStyle(color: Color(0xFF8E929B), fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E929B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PortfolioRepository().deleteHolding(stock.portfolio.id);
      ref.invalidate(portfolioProvider);
      ref.invalidate(livePortfolioProvider);
      ref.invalidate(dashboardProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${stock.portfolio.instrument} removed.'),
            backgroundColor: const Color(0xFFFF5252),
          ),
        );
      }
    }
  }

  void _openEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditHoldingSheet(stock: stock),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = stock.portfolio;
    final isProfit = stock.netPL >= 0;
    final tone = isProfit ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    final toneBg = isProfit ? const Color(0x1F00E676) : const Color(0x26FF5252);

    final displayName = SymbolUtils.getDisplayName(
      portfolio.instrument,
      dbCompanyName: portfolio.companyName,
    );
    final cleanSymbol = SymbolUtils.normalize(portfolio.instrument);

    final isDayProfit = stock.todayPL >= 0;
    final dayTone = isDayProfit ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    final dayToneBg = isDayProfit ? const Color(0x1F00E676) : const Color(0x26FF5252);

    return Material(
      color: const Color(0xFF16171B),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF282A30), width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StockDetailPage(stock: stock),
            ),
          );
        },
        onLongPress: () => _openEdit(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Avatar + Symbol & Company + Return Pill + Options
              Row(
                children: [
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Center(
                      child: Text(
                        cleanSymbol.isEmpty ? '-' : cleanSymbol.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cleanSymbol,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF8E929B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              Formatters.currency(stock.currentPrice),
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${stock.todayReturnPercent >= 0 ? '+' : ''}${Formatters.currency(stock.todayPL / (stock.portfolio.qty > 0 ? stock.portfolio.qty : 1))} (${Formatters.percent(stock.todayReturnPercent, signed: true)})',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: stock.todayReturnPercent >= 0
                                    ? const Color(0xFF00E676)
                                    : const Color(0xFFFF5252),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Right Column: ACTIVE badge + Menu on top, Return Pill below
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x1F00E676),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF00E676),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF8E929B)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            color: const Color(0xFF1E2024),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Color(0xFF282A30)),
                            ),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 16, color: Color(0xFFE5A93C)),
                                    SizedBox(width: 8),
                                    Text('Edit Holding', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFFF5252)),
                                    SizedBox(width: 8),
                                    Text('Delete Holding', style: TextStyle(color: Color(0xFFFF5252), fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (val) {
                              if (val == 'edit') {
                                _openEdit(context);
                              } else if (val == 'delete') {
                                _confirmDelete(context, ref);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Return Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: toneBg,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          Formatters.percent(stock.returnPercent, signed: true),
                          style: TextStyle(
                            color: tone,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFF23252B)),
              const SizedBox(height: 8),
              // Metrics Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CompactMetric(
                    label: 'Qty',
                    value: '${portfolio.qty}',
                  ),
                  _CompactMetric(
                    label: 'Avg',
                    value: Formatters.currency(portfolio.avgPrice),
                  ),
                  _CompactMetric(
                    label: 'Value',
                    value: Formatters.currency0(stock.currentValue),
                  ),
                  _CompactMetric(
                    label: 'Total P&L',
                    value: Formatters.currency0(stock.netPL, signed: true),
                    valueColor: tone,
                    alignEnd: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Day's P&L Strip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
                decoration: BoxDecoration(
                  color: dayToneBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDayProfit ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                      color: dayTone,
                      size: 18,
                    ),
                    const Text(
                      "1D P&L: ",
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF8E929B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${Formatters.currency0(stock.todayPL, signed: true)} (${Formatters.percent(stock.todayReturnPercent, signed: true)})',
                      style: TextStyle(
                        fontSize: 11,
                        color: dayTone,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'LTP: ${Formatters.currency(stock.currentPrice)}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFFC7CDD6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool alignEnd;

  const _CompactMetric({
    required this.label,
    required this.value,
    this.valueColor,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            color: Color(0xFF8E929B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }
}
