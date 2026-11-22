import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_radius.dart';
import '../core/utils/formatters.dart';
import '../core/utils/symbol_utils.dart';
import '../models/live_portfolio.dart';
import '../providers/dashboard_provider.dart';
import '../providers/listing_provider.dart';
import '../providers/live_portfolio_provider.dart';
import '../providers/portfolio_provider.dart';
import '../providers/privacy_provider.dart';
import '../repositories/trade_repository.dart';
import '../screens/portfolio/widgets/edit_holding_sheet.dart';
import '../screens/stock/stock_detail_page.dart';
import 'listing_badges.dart';
import '../core/l10n/l10n_ext.dart';
import '../core/theme/app_colors.dart';

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
        backgroundColor: AppColors.surfaceSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.line),
        ),
        title: Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: AppColors.danger, size: 24),
            const SizedBox(width: 8),
            Text(
              context.t.holdingRemoveTitle(stock.portfolio.instrument),
              style: TextStyle(color: AppColors.ink, fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          context.t.holdingRemoveBody(stock.portfolio.instrument),
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.t.commonCancel, style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.t.commonDelete, style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await TradeRepository().deleteHolding(stock.portfolio.instrument);
      ref.invalidate(portfolioProvider);
      ref.invalidate(livePortfolioProvider);
      ref.invalidate(dashboardProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.t.holdingRemoved(stock.portfolio.instrument), style: const TextStyle(color: Colors.white)),
            backgroundColor: AppColors.danger,
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
    final isPrivacy = ref.watch(privacyModeProvider);
    final portfolio = stock.portfolio;
    final isProfit = stock.netPL >= 0;
    final tone = isProfit ? AppColors.success : AppColors.danger;
    final toneBg = isProfit ? AppColors.success.withValues(alpha: 0.12) : AppColors.danger.withValues(alpha: 0.15);

    final displayName = SymbolUtils.getDisplayName(
      portfolio.instrument,
      dbCompanyName: portfolio.companyName,
    );
    final cleanSymbol = SymbolUtils.normalize(portfolio.instrument);

    final isDayProfit = stock.todayPL >= 0;
    final dayTone = isDayProfit ? AppColors.success : AppColors.danger;
    final dayToneBg = isDayProfit ? AppColors.success.withValues(alpha: 0.12) : AppColors.danger.withValues(alpha: 0.15);

    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.line, width: 1),
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
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Center(
                      child: Text(
                        cleanSymbol.isEmpty ? '-' : cleanSymbol.substring(0, 1),
                        style: TextStyle(
                          color: AppColors.background,
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
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                cleanSymbol,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ListingBadges(
                              info: ref.watch(heldListingProvider).valueOrNull?[cleanSymbol],
                              dense: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (stock.isPriceUnavailable)
                          Text(
                            context.t.commonPriceUnavailable,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning,
                            ),
                          )
                        else
                        Row(
                          children: [
                            if (stock.isStale) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  'DELAYED',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.warning,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                            ],
                            Text(
                              Formatters.currency(stock.currentPrice),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                '${stock.todayReturnPercent >= 0 ? '+' : ''}${Formatters.currency(stock.todayPL / (stock.portfolio.qty > 0 ? stock.portfolio.qty : 1))} (${Formatters.percent(stock.todayReturnPercent, signed: true)})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: stock.todayReturnPercent >= 0
                                      ? AppColors.success
                                      : AppColors.danger,
                                ),
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
                              color: AppColors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ACTIVE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.success,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textSecondary),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            color: AppColors.surfaceSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: AppColors.line),
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 16, color: AppColors.accent),
                                    SizedBox(width: 8),
                                    Text(context.t.holdingEdit, style: TextStyle(color: AppColors.ink, fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger),
                                    SizedBox(width: 8),
                                    Text(context.t.holdingDelete, style: TextStyle(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.w600)),
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
                          isPrivacy ? '••••' : Formatters.percent(stock.returnPercent, signed: true),
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
              Divider(height: 1, color: AppColors.surfaceSecondary),
              const SizedBox(height: 8),
              // Metrics Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CompactMetric(
                    label: 'Qty',
                    value: isPrivacy ? '••••' : '${portfolio.qty}',
                  ),
                  _CompactMetric(
                    label: 'Avg',
                    value: isPrivacy ? '••••' : Formatters.currency(portfolio.avgPrice),
                  ),
                  _CompactMetric(
                    label: 'Value',
                    value: isPrivacy ? '••••••' : Formatters.currency0(stock.currentValue),
                  ),
                  _CompactMetric(
                    label: 'Total P&L',
                    value: isPrivacy ? '••••••' : Formatters.currency0(stock.netPL, signed: true),
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
                    Text(
                      "1D P&L: ",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Flexible(
                      child: Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      isPrivacy
                          ? '••••••'
                          : '${Formatters.currency0(stock.todayPL, signed: true)} (${Formatters.percent(stock.todayReturnPercent, signed: true)})',
                      style: TextStyle(
                        fontSize: 11,
                        color: dayTone,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    ),
                    const Spacer(),
                    Text(
                      context.t.cardLtp(Formatters.currency(stock.currentPrice)),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.inkSoft,
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
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: valueColor ?? AppColors.ink,
          ),
        ),
      ],
    );
  }
}
