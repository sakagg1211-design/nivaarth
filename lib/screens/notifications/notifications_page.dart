import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/symbol_utils.dart';
import '../../models/live_portfolio.dart';
import '../../models/portfolio.dart';
import '../../models/user_alert.dart';
import '../../providers/alerts_provider.dart';
import '../../providers/live_portfolio_provider.dart';
import '../../providers/live_quote_provider.dart';
import '../../providers/price_alert_provider.dart';
import '../stock/stock_detail_page.dart';
import '../stock/widgets/price_alert_sheet.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  /// Internal filter values; the chips show them through [filterLabel].
  static const filters = ['All', 'Risks', 'Scores', 'System'];

  static String filterLabel(String f, AppLocalizations t) => switch (f) {
        'Risks' => t.notifFilterRisks,
        'Scores' => t.notifFilterScores,
        'System' => t.notifFilterSystem,
        _ => t.notifFilterAll,
      };

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.t.tipNotifications,
          style: TextStyle(color: AppColors.ink, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: context.t.notifMarkAll,
            icon: Icon(Icons.done_all_rounded, color: AppColors.accent, size: 22),
            onPressed: () {
              ref.read(alertsProvider.notifier).markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.t.notifMarked),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            tooltip: context.t.commonRefresh,
            icon: Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 22),
            onPressed: () {
              ref.read(alertsProvider.notifier).fetchAlerts();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterBar(),
          _buildPriceAlertsRow(),

          // Alerts List
          Expanded(
            child: alertsAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 2,
                ),
              ),
              error: (err, _) => Center(
                child: Text(
                  context.t.notifFailed(err),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.ink.withValues(alpha: 0.54)),
                ),
              ),
              data: (alerts) {
                final filtered = _filterAlerts(alerts);

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  color: AppColors.accent,
                  backgroundColor: AppColors.surface,
                  onRefresh: () => ref.read(alertsProvider.notifier).fetchAlerts(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildAlertCard(item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAlertsRow() {
    final count = ref.watch(activePriceAlertsProvider).valueOrNull?.length;
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: Icon(Icons.notifications_active_outlined, color: AppColors.accent, size: 20),
        title: Text(context.t.alertsMine,
            style: TextStyle(color: AppColors.ink, fontSize: 14, fontWeight: FontWeight.w700)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (count != null) Text(context.t.notifActive(count), style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PriceAlertsPage()),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    const filters = NotificationsPage.filters;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceSecondary, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = _selectedFilter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(NotificationsPage.filterLabel(f, context.t)),
                selected: isSelected,
                selectedColor: AppColors.accent,
                backgroundColor: AppColors.surfaceSecondary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.accent : AppColors.line,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedFilter = f);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<UserAlert> _filterAlerts(List<UserAlert> alerts) {
    if (_selectedFilter == 'Risks') {
      return alerts.where((a) => a.type == AlertType.portfolioRisk).toList();
    } else if (_selectedFilter == 'Scores') {
      return alerts.where((a) => a.type == AlertType.nvScore || a.type == AlertType.priceAlert).toList();
    } else if (_selectedFilter == 'System') {
      return alerts.where((a) => a.type == AlertType.system).toList();
    }
    return alerts;
  }

  Widget _buildAlertCard(UserAlert alert) {
    Color accentColor;
    IconData icon;

    switch (alert.severity) {
      case AlertSeverity.success:
        accentColor = AppColors.success;
        icon = Icons.trending_up_rounded;
        break;
      case AlertSeverity.warning:
        accentColor = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        break;
      case AlertSeverity.danger:
        accentColor = AppColors.danger;
        icon = Icons.error_outline_rounded;
        break;
      case AlertSeverity.info:
        accentColor = AppColors.info;
        icon = Icons.info_outline_rounded;
        break;
    }

    return InkWell(
      onTap: () {
        ref.read(alertsProvider.notifier).markAsRead(alert.id);
        final rawSym = alert.symbol?.trim();
        if (rawSym != null && rawSym.isNotEmpty) {
          final sym = SymbolUtils.normalize(rawSym);
          final liveHoldings = ref.read(livePortfolioProvider).valueOrNull ?? [];
          final matchingHolding = liveHoldings.where((h) => SymbolUtils.normalize(h.portfolio.instrument) == sym).firstOrNull;

          final liveQuote = ref.read(liveQuoteProvider(sym)).valueOrNull;
          final livePrice = (liveQuote != null && liveQuote.currentPrice > 0)
              ? liveQuote.currentPrice
              : 0.0;

          final targetStock = matchingHolding ??
              LivePortfolio(
                portfolio: Portfolio(
                  id: '0',
                  instrument: sym,
                  companyName: SymbolUtils.getDisplayName(sym),
                  yahooSymbol: SymbolUtils.getYahooSymbol(sym),
                  qty: 0,
                  avgPrice: 0.0,
                  totalInvested: 0.0,
                  currentValue: 0.0,
                  netPL: 0.0,
                  sector: SymbolUtils.getSector(sym),
                  industry: SymbolUtils.getIndustry(sym),
                  status: 'WATCHLIST',
                  investmentThesis: '',
                ),
                currentPrice: livePrice,
                currentValue: 0.0,
                netPL: 0.0,
                returnPercent: 0.0,
              );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StockDetailPage(stock: targetStock),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: alert.isRead ? AppColors.surface : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: alert.isRead
                ? AppColors.line
                : accentColor.withValues(alpha: 0.35),
            width: alert.isRead ? 1 : 1.5,
          ),
          boxShadow: alert.isRead
              ? []
              : [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              height: 40,
              width: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 14,
                            fontWeight: alert.isRead ? FontWeight.w600 : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!alert.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: TextStyle(
                      color: AppColors.ink.withValues(alpha: 0.72),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(alert.createdAt),
                    style: TextStyle(
                      color: AppColors.ink.withValues(alpha: 0.38),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return context.t.notifJustNow;
    if (diff.inMinutes < 60) return context.t.notifMinutes(diff.inMinutes);
    if (diff.inHours < 24) return context.t.notifHours(diff.inHours);
    return context.t.notifDays(diff.inDays);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceSecondary,
              border: Border.all(color: AppColors.line),
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 32,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.t.notifEmptyTitle,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.t.notifEmptyBody,
            style: TextStyle(color: AppColors.ink.withValues(alpha: 0.54), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
