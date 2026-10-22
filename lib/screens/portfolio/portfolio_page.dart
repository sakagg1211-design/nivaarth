import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/live_portfolio.dart';
import '../../providers/live_portfolio_provider.dart';
import '../../services/market_sync_service.dart';
import '../../widgets/portfolio_card.dart';
import 'widgets/add_holding_sheet.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D10),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_showBackToTop) ...[
            FloatingActionButton.small(
              heroTag: 'portfolio_go_top',
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                );
              },
              backgroundColor: const Color(0xFF1E2024),
              foregroundColor: const Color(0xFFE5A93C),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF282A30)),
              ),
              child: const Icon(Icons.arrow_upward_rounded, size: 20),
            ),
            const SizedBox(height: 10),
          ],
          FloatingActionButton.extended(
            heroTag: 'portfolio_add_holding',
            onPressed: _openAddHoldingSheet,
            backgroundColor: const Color(0xFFE5A93C),
            foregroundColor: Colors.black,
            elevation: 4,
            icon: const Icon(Icons.add_rounded, color: Colors.black),
            label: const Text(
              'Add Holding',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: portfolioAsync.when(
          loading: () => const _PortfolioState(
            icon: Icons.hourglass_empty_rounded,
            title: 'Loading holdings',
            message: 'Pulling your live portfolio positions.',
            loading: true,
          ),
          error: (e, _) => _PortfolioState(
            icon: Icons.error_outline_rounded,
            title: 'Portfolio unavailable',
            message: e.toString(),
            action: ElevatedButton(
              onPressed: () => ref.invalidate(livePortfolioProvider),
              child: const Text('Try Again'),
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
                          color: const Color(0xFF16171B),
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: const Color(0xFF282A30)),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        'No Portfolio Holdings Yet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Add your investment positions to unlock real-time Indian stock valuations, P&L, and AI scores.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF8E929B),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE5A93C),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: _openAddHoldingSheet,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text(
                          'Add Your First Stock',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
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
              color: const Color(0xFFE5A93C),
              backgroundColor: const Color(0xFF16171B),
              child: RawScrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 4.5,
                radius: const Radius.circular(8),
                thumbColor: const Color(0xFFE5A93C).withValues(alpha: 0.8),
                interactive: true,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        12,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Portfolio',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _openAddHoldingSheet,
                                    icon: const Icon(Icons.add_circle_outline_rounded),
                                    color: const Color(0xFFE5A93C),
                                    tooltip: 'Add Holding',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${stocks.length} holdings under active tracking.',
                                style: const TextStyle(
                                  color: Color(0xFF8E929B),
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
                              ),

                              const SizedBox(height: 16),

                              // Sorting & Filter Controls
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Holdings',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<PortfolioSortOption>(
                                    initialValue: _selectedSort,
                                    color: const Color(0xFF1E2024),
                                    onSelected: (option) {
                                      setState(() => _selectedSort = option);
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.md),
                                      side: const BorderSide(
                                        color: Color(0xFF282A30),
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF16171B),
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.pill),
                                        border: Border.all(
                                          color: const Color(0xFF282A30),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.sort_rounded,
                                            size: 15,
                                            color: Color(0xFFC7CDD6),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _getSortLabel(_selectedSort),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: PortfolioSortOption.alphabetical,
                                        child: Text(
                                          'Alphabetical (A-Z)',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: PortfolioSortOption.todayGainers,
                                        child: Text(
                                          "Today's Top Gainers (₹)",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: PortfolioSortOption.todayLosers,
                                        child: Text(
                                          "Today's Top Losers (₹)",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: PortfolioSortOption.bestPnL,
                                        child: Text(
                                          'Overall Top Gainers (%)',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: PortfolioSortOption.worstPnL,
                                        child: Text(
                                          'Overall Top Losers (%)',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: PortfolioSortOption.highestValue,
                                        child: Text(
                                          'Highest Value (₹)',
                                          style: TextStyle(color: Colors.white),
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
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      84, // Extra padding for Floating Action Button
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 880),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isTwoCol = constraints.maxWidth >= 540;
                              final crossAxisCount = isTwoCol ? 2 : 1;

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  mainAxisExtent: 148,
                                ),
                                itemCount: sortedStocks.length,
                                itemBuilder: (context, index) {
                                  return PortfolioCard(stock: sortedStocks[index]);
                                },
                              );
                            },
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
        return "Today's Gainers";
      case PortfolioSortOption.todayLosers:
        return "Today's Losers";
      case PortfolioSortOption.bestPnL:
        return 'Top Gainers';
      case PortfolioSortOption.worstPnL:
        return 'Top Losers';
      case PortfolioSortOption.highestValue:
        return 'Valuation';
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

  const _SummaryAndHeatmapSection({
    required this.totalStocks,
    required this.totalInvested,
    required this.totalCurrentValue,
    required this.totalPnL,
    required this.totalReturn,
    required this.isProfit,
    required this.stocks,
  });

  @override
  Widget build(BuildContext context) {
    final tone = isProfit ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    final toneBg = isProfit ? const Color(0x1F00E676) : const Color(0x26FF5252);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF16171B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF282A30),
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
                        const Text(
                          'PORTFOLIO VALUATION',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8E929B),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          Formatters.currency0(totalCurrentValue),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
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
                            Formatters.percent(totalReturn, signed: true),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: tone,
                            ),
                          ),
                          Text(
                            Formatters.currency0(totalPnL, signed: true),
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
                decoration: const BoxDecoration(
                  color: Color(0xFF111215),
                  border: Border(
                    top: BorderSide(color: Color(0xFF22242B), width: 0.8),
                    bottom: BorderSide(color: Color(0xFF22242B), width: 0.8),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    _InlineMetric('Invested', Formatters.currency0(totalInvested)),
                    Container(width: 1, height: 26, color: const Color(0xFF282A30)),
                    _InlineMetric('Holdings', '$totalStocks Positions'),
                    Container(width: 1, height: 26, color: const Color(0xFF282A30)),
                    _InlineMetric('Win Ratio', _calculateWinRatio()),
                  ],
                ),
              ),

              // Heatmap Visual Strip
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.grid_view_rounded,
                              size: 13,
                              color: Color(0xFFE5A93C),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Return Heatmap',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${stocks.where((s) => s.returnPercent >= 0).length} Up • ${stocks.where((s) => s.returnPercent < 0).length} Down',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF757A85),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Heatmap Chips
                    _PortfolioHeatmapGrid(stocks: stocks),
                  ],
                ),
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
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF757A85),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioHeatmapGrid extends StatelessWidget {
  final List<LivePortfolio> stocks;

  const _PortfolioHeatmapGrid({required this.stocks});

  @override
  Widget build(BuildContext context) {
    if (stocks.isEmpty) {
      return const SizedBox(
        height: 40,
        child: Center(
          child: Text(
            'No holdings to display',
            style: TextStyle(fontSize: 12, color: Color(0xFF757A85)),
          ),
        ),
      );
    }

    final displayStocks = stocks;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: displayStocks.map((stock) {
        final ret = stock.returnPercent;
        final isProf = ret >= 0;

        Color bg;
        Color fg;

        if (isProf) {
          if (ret > 25) {
            bg = const Color(0xFF0C9F6E);
            fg = Colors.white;
          } else if (ret > 5) {
            bg = const Color(0xFF10B981);
            fg = Colors.white;
          } else {
            bg = const Color(0xFF064E3B);
            fg = const Color(0xFF6EE7B7);
          }
        } else {
          if (ret < -25) {
            bg = const Color(0xFFDC2626);
            fg = Colors.white;
          } else if (ret < -5) {
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
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                clean,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                Formatters.percent(ret, signed: true),
                style: TextStyle(
                  fontSize: 10,
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
                color: const Color(0xFF16171B),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: const Color(0xFF282A30)),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8E929B),
                fontSize: 14,
              ),
            ),
            if (loading) ...[
              const SizedBox(height: AppSpacing.lg),
              const SizedBox(
                width: 140,
                child: LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: Color(0xFF23252B),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE5A93C)),
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
