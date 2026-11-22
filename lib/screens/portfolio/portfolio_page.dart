import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/live_portfolio.dart';
import '../../providers/live_portfolio_provider.dart';
import '../../providers/privacy_provider.dart';
import '../../services/corporate_action_prompt.dart';
import '../../services/market_sync_service.dart';
import '../../widgets/portfolio_card.dart';
import 'closed_positions_page.dart';
import 'import_trades_page.dart';
import 'trade_book_page.dart';
import 'widgets/investment_style_card.dart';
import 'widgets/account_value_card.dart';
import 'widgets/today_moves_card.dart';
import 'widgets/add_holding_sheet.dart';
import '../../core/utils/error_messages.dart';
import '../../core/l10n/l10n_ext.dart';

enum PortfolioSortOption {
  alphabetical,
  bestPnL,
  worstPnL,
  highestValue,
  todayGainers,
  todayLosers,
}

class PortfolioPage extends ConsumerStatefulWidget {
  const PortfolioPage({super.key});

  @override
  ConsumerState<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends ConsumerState<PortfolioPage> {
  PortfolioSortOption _selectedSort = PortfolioSortOption.alphabetical;
  static const _holdingsPreview = 9; // fills three rows of the desktop grid
  bool _showAllHoldings = false;
  late final ScrollController _scrollController;
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final show = _scrollController.hasClients && _scrollController.offset > 240;
      if (show != _showBackToTop) {
        setState(() => _showBackToTop = show);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshPortfolio() async {
    try {
      await MarketSyncService.instance.syncAll(ref);
    } catch (_) {}
  }

  void _openAddHoldingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddHoldingSheet(),
    );
  }

  void _openClosedPositions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ClosedPositionsPage()),
    );
  }

  void _openTradeBook() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TradeBookPage()),
    );
  }

  List<LivePortfolio> _sortStocks(List<LivePortfolio> originalList) {
    final list = List<LivePortfolio>.from(originalList);
    switch (_selectedSort) {
      case PortfolioSortOption.alphabetical:
        list.sort((a, b) =>
            a.portfolio.instrument.compareTo(b.portfolio.instrument));
        break;
      case PortfolioSortOption.bestPnL:
        list.sort((a, b) => b.returnPercent.compareTo(a.returnPercent));
        break;
      case PortfolioSortOption.worstPnL:
        list.sort((a, b) => a.returnPercent.compareTo(b.returnPercent));
        break;
      case PortfolioSortOption.highestValue:
        list.sort((a, b) => b.currentValue.compareTo(a.currentValue));
        break;
      case PortfolioSortOption.todayGainers:
        list.sort((a, b) => b.todayPL.compareTo(a.todayPL));
        break;
      case PortfolioSortOption.todayLosers:
        list.sort((a, b) => a.todayPL.compareTo(b.todayPL));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final portfolioAsync = ref.watch(livePortfolioProvider);
    // Once per app session, after the holdings load: ask about bonus/split events
    if (portfolioAsync.hasValue && (portfolioAsync.valueOrNull?.isNotEmpty ?? false)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) CorporateActionPrompt.checkOnce(context, ref);
      });
    }
    final isPrivacy = ref.watch(privacyModeProvider);
    final isDesktop = Breakpoints.isDesktop(context);
    // Phone keeps its narrow reading widths; wide screens use the shell's column.
    final double headerMaxWidth = isDesktop ? double.infinity : 680;
    final double gridMaxWidth = isDesktop ? double.infinity : 880;
    final double sidePadding = isDesktop ? 24 : 16;

    return Scaffold(
      backgroundColor: AppColors.background,
      // Only back-to-top floats, after scrolling. Adding a holding lives in the header (+), so nothing
      // covers the account value footnote or a holding's 1D row at rest.
      floatingActionButton: _showBackToTop
          ? FloatingActionButton.small(
              heroTag: 'portfolio_go_top',
              tooltip: context.t.backToTop,
              onPressed: () => _scrollController.animateTo(0, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic),
              backgroundColor: AppColors.surfaceSecondary,
              foregroundColor: AppColors.ink,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.line),
              ),
              child: const Icon(Icons.arrow_upward_rounded, size: 20),
            )
          : null,
      body: SafeArea(
        child: portfolioAsync.when(
          loading: () => _PortfolioState(
            icon: Icons.hourglass_empty_rounded,
            title: context.t.portfolioLoadingTitle,
            message: context.t.portfolioLoadingBody,
            loading: true,
          ),
          error: (e, _) => _PortfolioState(
            icon: Icons.error_outline_rounded,
            title: context.t.portfolioUnavailable,
            message: ErrorMessages.friendly(e, context.t),
            action: ElevatedButton(
              onPressed: () => ref.invalidate(livePortfolioProvider),
              child: Text(context.t.commonTryAgain),
            ),
          ),
          data: (stocks) {
            if (stocks.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 32,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        context.t.portfolioEmptyTitle,
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        context.t.portfolioEmptyBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: _openAddHoldingSheet,
                        icon: const Icon(Icons.add_rounded),
                        label: Text(
                          context.t.portfolioAddFirst,
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      // Everything sold: the trades are still in the Trade book
                      TextButton.icon(
                        onPressed: _openTradeBook,
                        icon: const Icon(Icons.receipt_long_rounded, size: 18),
                        label: Text(context.t.portfolioOpenTradeBook),
                        style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ImportTradesPage()),
                        ),
                        icon: const Icon(Icons.upload_file_rounded, size: 18),
                        label: Text(context.t.portfolioImport),
                        style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                      ),
                      TextButton.icon(
                        onPressed: _openClosedPositions,
                        icon: const Icon(Icons.inventory_2_outlined, size: 18),
                        label: Text(context.t.closedTitle),
                        style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }

            double totalInvested = 0;
            double totalCurrentValue = 0;
            double totalPnL = 0;

            for (final stock in stocks) {
              // No price at all: invested would count but value would be 0.
              if (stock.isPriceUnavailable) continue;
              totalInvested += stock.portfolio.totalInvested;
              totalCurrentValue += stock.currentValue;
              totalPnL += stock.netPL;
            }

            final totalReturn = totalInvested == 0
                ? 0.0
                : (totalPnL / totalInvested) * 100;
            final isProfit = totalPnL >= 0;

            final sortedStocks = _sortStocks(stocks);

            return RefreshIndicator(
              onRefresh: _refreshPortfolio,
              color: AppColors.ink,
              backgroundColor: AppColors.surface,
              child: RawScrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 4.5,
                radius: const Radius.circular(8),
                thumbColor: AppColors.textSecondary.withValues(alpha: 0.8),
                interactive: true,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        sidePadding,
                        16,
                        sidePadding,
                        12,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: headerMaxWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Portfolio',
                                      style: TextStyle(
                                        color: AppColors.ink,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _openClosedPositions,
                                    icon: const Icon(Icons.inventory_2_outlined),
                                    color: AppColors.textSecondary,
                                    tooltip: context.t.closedTitle,
                                  ),
                                  IconButton(
                                    onPressed: _openTradeBook,
                                    icon: const Icon(Icons.receipt_long_rounded),
                                    color: AppColors.textSecondary,
                                    tooltip: context.t.tradeBookTitle,
                                  ),
                                  IconButton(
                                    onPressed: () => ref.read(privacyModeProvider.notifier).toggle(),
                                    icon: Icon(isPrivacy ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                                    color: isPrivacy ? AppColors.ink : AppColors.textSecondary,
                                    tooltip: isPrivacy ? context.t.tipShowValues : context.t.tipHideValues,
                                  ),
                                  IconButton(
                                    onPressed: _openAddHoldingSheet,
                                    icon: const Icon(Icons.add_circle_outline_rounded),
                                    color: AppColors.accent,
                                    tooltip: context.t.addHolding,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.t.portfolioTracked(stocks.length),
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Unified Valuation Card + Integrated Return Heatmap Chips
                              _SummaryAndHeatmapSection(
                                totalStocks: stocks.length,
                                totalInvested: totalInvested,
                                totalCurrentValue: totalCurrentValue,
                                totalPnL: totalPnL,
                                totalReturn: totalReturn,
                                isProfit: isProfit,
                                stocks: sortedStocks,
                                isPrivacy: isPrivacy,
                                showHeatmap: false,
                              ),

                              const SizedBox(height: 16),

                              const AccountValueCard(),

                              const SizedBox(height: 16),



                              // Sorting & Filter Controls
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Holdings',
                                      style: TextStyle(
                                        color: AppColors.ink,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<PortfolioSortOption>(
                                    initialValue: _selectedSort,
                                    color: AppColors.surfaceSecondary,
                                    onSelected: (option) {
                                      setState(() => _selectedSort = option);
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.md),
                                      side: BorderSide(
                                        color: AppColors.line,
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.pill),
                                        border: Border.all(
                                          color: AppColors.line,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.sort_rounded,
                                            size: 15,
                                            color: AppColors.inkSoft,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _getSortLabel(_selectedSort),
                                            style: TextStyle(
                                              color: AppColors.ink,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: PortfolioSortOption.alphabetical,
                                        child: Text(
                                          context.t.sortAlphabetical,
                                          style: TextStyle(color: AppColors.ink),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: PortfolioSortOption.todayGainers,
                                        child: Text(
                                          context.t.sortTodayGainers,
                                          style: TextStyle(color: AppColors.ink),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: PortfolioSortOption.todayLosers,
                                        child: Text(
                                          context.t.sortTodayLosers,
                                          style: TextStyle(color: AppColors.ink),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: PortfolioSortOption.bestPnL,
                                        child: Text(
                                          context.t.sortOverallGainers,
                                          style: TextStyle(color: AppColors.ink),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: PortfolioSortOption.worstPnL,
                                        child: Text(
                                          context.t.sortOverallLosers,
                                          style: TextStyle(color: AppColors.ink),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: PortfolioSortOption.highestValue,
                                        child: Text(
                                          context.t.sortHighestValue,
                                          style: TextStyle(color: AppColors.ink),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      sidePadding,
                      0,
                      sidePadding,
                      96, // room for the add button, so it never covers the last card
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: gridMaxWidth),
                          child: Column(
                            children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final shown = _showAllHoldings
                                  ? sortedStocks
                                  : sortedStocks.take(_holdingsPreview).toList();
                              final isTwoCol = constraints.maxWidth >= 540;
                              final columns = constraints.maxWidth >= 1050 ? 3 : 2;

                              if (!isTwoCol) {
                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: shown.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    return PortfolioCard(stock: shown[index]);
                                  },
                                );
                              }

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  mainAxisExtent: 185,
                                ),
                                itemCount: shown.length,
                                itemBuilder: (context, index) {
                                  return PortfolioCard(stock: shown[index]);
                                },
                              );
                            },
                          ),
                          if (sortedStocks.length > _holdingsPreview)
                            TextButton(
                              style: TextButton.styleFrom(foregroundColor: AppColors.ink),
                              onPressed: () => setState(() => _showAllHoldings = !_showAllHoldings),
                              child: Text(
                                _showAllHoldings ? context.t.commonShowLess : context.t.commonSeeAll(sortedStocks.length),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ),
                          const SizedBox(height: 16),
                          _HeatmapCard(stocks: sortedStocks),
                          const SizedBox(height: 16),
                          const TodayMovesCard(),
                          const SizedBox(height: 16),
                          const InvestmentStyleCard(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

  String _getSortLabel(PortfolioSortOption option) {
    switch (option) {
      case PortfolioSortOption.alphabetical:
        return 'A-Z';
      case PortfolioSortOption.todayGainers:
        return context.t.sortShortTodayGainers;
      case PortfolioSortOption.todayLosers:
        return context.t.sortShortTodayLosers;
      case PortfolioSortOption.bestPnL:
        return context.t.sortShortGainers;
      case PortfolioSortOption.worstPnL:
        return context.t.sortShortLosers;
      case PortfolioSortOption.highestValue:
        return context.t.sortShortValue;
    }
  }
}

class _SummaryAndHeatmapSection extends StatelessWidget {
  final int totalStocks;
  final double totalInvested;
  final double totalCurrentValue;
  final double totalPnL;
  final double totalReturn;
  final bool isProfit;
  final List<LivePortfolio> stocks;
  final bool isPrivacy;
  final bool showHeatmap;

  const _SummaryAndHeatmapSection({
    required this.totalStocks,
    required this.totalInvested,
    required this.totalCurrentValue,
    required this.totalPnL,
    required this.totalReturn,
    required this.isProfit,
    required this.stocks,
    this.isPrivacy = false,
    this.showHeatmap = true,
  });

  @override
  Widget build(BuildContext context) {
    final tone = isProfit ? AppColors.success : AppColors.danger;
    final toneBg = isProfit ? AppColors.success.withValues(alpha: 0.12) : AppColors.danger.withValues(alpha: 0.15);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Breakpoints.isDesktop(context) ? double.infinity : 680,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.line,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Header Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t.portfolioValuation,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isPrivacy ? '₹ ••••••' : Formatters.currency0(totalCurrentValue),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: toneBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isPrivacy ? '••••' : Formatters.percent(totalReturn, signed: true),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: tone,
                            ),
                          ),
                          Text(
                            isPrivacy ? '••••••' : Formatters.currency0(totalPnL, signed: true),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: tone,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 3 Key Stats Strip
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.line, width: 0.8),
                    bottom: BorderSide(color: AppColors.line, width: 0.8),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    _InlineMetric(context.t.metricInvested, isPrivacy ? '••••••' : Formatters.currency0(totalInvested)),
                    Container(width: 1, height: 26, color: AppColors.line),
                    _InlineMetric(context.t.metricHoldings, context.t.metricPositions(totalStocks)),
                    Container(width: 1, height: 26, color: AppColors.line),
                    _InlineMetric(context.t.metricWinRatio, _calculateWinRatio()),
                  ],
                ),
              ),

              // Heatmap Visual Strip (overall return or today's move)
              if (showHeatmap)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: _ReturnHeatmap(stocks: stocks),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateWinRatio() {
    if (stocks.isEmpty) return '0%';
    final winners = stocks.where((s) => s.returnPercent >= 0).length;
    final ratio = (winners / stocks.length) * 100;
    return '${ratio.toStringAsFixed(0)}%';
  }
}

/// The return heatmap as its own card, below the holdings.
class _HeatmapCard extends StatelessWidget {
  final List<LivePortfolio> stocks;
  const _HeatmapCard({required this.stocks});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ink.withValues(alpha: .06)),
      ),
      child: _ReturnHeatmap(stocks: stocks),
    );
  }
}

class _InlineMetric extends StatelessWidget {
  final String label;
  final String value;

  const _InlineMetric(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Which return the heatmap colours: since purchase, or today's move
enum _HeatmapMode { overall, today }

class _ReturnHeatmap extends StatefulWidget {
  final List<LivePortfolio> stocks;

  const _ReturnHeatmap({required this.stocks});

  @override
  State<_ReturnHeatmap> createState() => _ReturnHeatmapState();
}

class _ReturnHeatmapState extends State<_ReturnHeatmap> {
  _HeatmapMode _mode = _HeatmapMode.overall;
  // Biggest gainers first (all green, then red); tap the sort chip to show losers first
  bool _gainersFirst = true;

  double _value(LivePortfolio s) =>
      _mode == _HeatmapMode.overall ? s.returnPercent : s.todayReturnPercent;

  @override
  Widget build(BuildContext context) {
    final stocks = List<LivePortfolio>.from(widget.stocks)
      ..sort((a, b) => _gainersFirst ? _value(b).compareTo(_value(a)) : _value(a).compareTo(_value(b)));
    final up = stocks.where((s) => _value(s) >= 0).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.grid_view_rounded, size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                context.t.heatReturnTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink),
              ),
            ),
            const Spacer(),
            Text(
              context.t.heatUpDown(up, stocks.length - up),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Wraps to a second line on a narrow phone instead of overflowing
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _modeChip(context.t.heatOverall, _HeatmapMode.overall),
            _modeChip(context.t.heatTodayPl, _HeatmapMode.today),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _gainersFirst = !_gainersFirst),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _gainersFirst ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _gainersFirst ? context.t.heatGainersFirst : context.t.heatLosersFirst,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _PortfolioHeatmapGrid(
          stocks: stocks,
          value: _value,
          // A day's move is much smaller than a holding's lifetime return, so its colour bands are tighter
          strong: _mode == _HeatmapMode.overall ? 25 : 3,
          mild: _mode == _HeatmapMode.overall ? 5 : 1,
        ),
      ],
    );
  }

  Widget _modeChip(String label, _HeatmapMode mode) {
    final selected = _mode == mode;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() => _mode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppColors.ink : AppColors.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.ink : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PortfolioHeatmapGrid extends StatelessWidget {
  final List<LivePortfolio> stocks;
  final double Function(LivePortfolio) value;
  final double strong;
  final double mild;

  const _PortfolioHeatmapGrid({
    required this.stocks,
    required this.value,
    required this.strong,
    required this.mild,
  });

  @override
  Widget build(BuildContext context) {
    if (stocks.isEmpty) {
      return SizedBox(
        height: 40,
        child: Center(
          child: Text(
            context.t.heatEmpty,
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: stocks.map((stock) {
        final ret = value(stock);
        final isProf = ret >= 0;

        Color bg;
        Color fg;

        if (isProf) {
          if (ret > strong) {
            bg = const Color(0xFF0C9F6E);
            fg = Colors.white;
          } else if (ret > mild) {
            bg = const Color(0xFF10B981);
            fg = Colors.white;
          } else {
            bg = const Color(0xFF064E3B);
            fg = const Color(0xFF6EE7B7);
          }
        } else {
          if (ret < -strong) {
            bg = const Color(0xFFDC2626);
            fg = Colors.white;
          } else if (ret < -mild) {
            bg = const Color(0xFFEF4444);
            fg = Colors.white;
          } else {
            bg = const Color(0xFF450A0A);
            fg = const Color(0xFFFCA5A5);
          }
        }

        final clean = stock.portfolio.instrument
            .replaceAll('.NS', '')
            .replaceAll('.BO', '');

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4.5),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                clean,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                Formatters.percent(ret, signed: true),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PortfolioState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool loading;
  final Widget? action;

  const _PortfolioState({
    required this.icon,
    required this.title,
    required this.message,
    this.loading = false,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.line),
              ),
              child: Icon(icon, color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            if (loading) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: 140,
                child: LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: AppColors.surfaceSecondary,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.ink),
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
