import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/symbol_utils.dart';
import '../../models/live_portfolio.dart';
import '../../models/portfolio.dart';
import '../../providers/live_portfolio_provider.dart';
import '../../providers/live_quote_provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/watchlist_provider.dart';
import '../stock/stock_detail_page.dart';
import 'widgets/watchlist_table_view.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String query = '';
  int _activeTab = 0; // 0: Explore / Search, 1: My Saved List (Watchlist)

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(searchProvider(query));
    final savedList = ref.watch(watchlistProvider);
    final watchlistNotifier = ref.read(watchlistProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D10),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Search & Watchlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x1FE5A93C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x33E5A93C)),
                    ),
                    child: Text(
                      '${savedList.length} Tracked',
                      style: const TextStyle(
                        color: Color(0xFFE5A93C),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Instant price discovery, NV conviction & watchlist tracking.',
                style: TextStyle(
                  color: Color(0xFF8E929B),
                  fontSize: 12.5,
                ),
              ),

              const SizedBox(height: 14),

              // Two Tab Pill Segment: [Explore & Search] | [MY SAVED LIST]
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFF16171B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF282A30)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _activeTab == 0 ? const Color(0xFF23252B) : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_rounded,
                                size: 16,
                                color: _activeTab == 0 ? const Color(0xFFE5A93C) : const Color(0xFF8E929B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Explore Stocks',
                                style: TextStyle(
                                  color: _activeTab == 0 ? Colors.white : const Color(0xFF8E929B),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _activeTab == 1 ? const Color(0xFF23252B) : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bookmark_rounded,
                                size: 16,
                                color: _activeTab == 1 ? const Color(0xFFE5A93C) : const Color(0xFF8E929B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'MY SAVED LIST',
                                style: TextStyle(
                                  color: _activeTab == 1 ? Colors.white : const Color(0xFF8E929B),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              if (_activeTab == 0) ...[
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search stock by symbol or name (e.g. TAT, KEI, APO)...',
                    hintStyle: const TextStyle(color: Color(0xFF757A85), fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8E929B)),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Color(0xFF8E929B), size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                query = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF16171B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF282A30)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF282A30)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5A93C), width: 1.2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      query = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: result.when(
                    loading: () => const _SearchState(
                      icon: Icons.manage_search_rounded,
                      title: 'Searching market universe',
                      message: 'Matching symbols and AI scores.',
                      loading: true,
                    ),
                    error: (e, _) => _SearchState(
                      icon: Icons.error_outline_rounded,
                      title: 'Search unavailable',
                      message: e.toString(),
                    ),
                    data: (stocks) {
                      if (query.isEmpty) {
                        return const _SearchState(
                          icon: Icons.search_rounded,
                          title: 'Start with a symbol',
                          message: 'Search any stock to view 100-point conviction score.',
                        );
                      }

                      if (stocks.isEmpty) {
                        return const _SearchState(
                          icon: Icons.remove_circle_outline_rounded,
                          title: 'No stock found',
                          message: 'Try another instrument or company name.',
                        );
                      }

                    return RefreshIndicator(
                      color: const Color(0xFFE5A93C),
                      backgroundColor: const Color(0xFF16171B),
                      onRefresh: () async {
                        ref.invalidate(searchProvider(query));
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                        itemCount: stocks.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final stock = stocks[index];

                        return Material(
                          color: const Color(0xFF16171B),
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: Color(0xFF282A30)),
                          ),
                          child: ListTile(
                            minVerticalPadding: 12,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 4,
                            ),
                            onTap: () {
                              final portfolioAsync = ref.read(livePortfolioProvider);
                              final liveList = portfolioAsync.value ?? [];
                              LivePortfolio? matchingHolding;
                              for (final h in liveList) {
                                if (SymbolUtils.normalize(h.portfolio.instrument) ==
                                    SymbolUtils.normalize(stock.instrument)) {
                                  matchingHolding = h;
                                  break;
                                }
                              }

                              final cleanSym = SymbolUtils.normalize(stock.instrument);
                              final liveQuote = ref.read(liveQuoteProvider(cleanSym)).value;
                              final livePrice = (liveQuote != null && liveQuote.currentPrice > 0)
                                  ? liveQuote.currentPrice
                                  : SymbolUtils.getEstimatedPrice(cleanSym);

                              final displayName = stock.companyName.isNotEmpty && stock.companyName.toUpperCase() != cleanSym
                                  ? stock.companyName
                                  : SymbolUtils.getDisplayName(cleanSym);

                              final targetStock = matchingHolding ??
                                  LivePortfolio(
                                    portfolio: Portfolio(
                                      id: '0',
                                      instrument: cleanSym,
                                      companyName: displayName,
                                      yahooSymbol: SymbolUtils.getYahooSymbol(cleanSym),
                                      qty: 0,
                                      avgPrice: 0.0,
                                      totalInvested: 0.0,
                                      currentValue: 0.0,
                                      netPL: 0.0,
                                      sector: SymbolUtils.getSector(cleanSym),
                                      industry: SymbolUtils.getIndustry(cleanSym),
                                      status: 'WATCHLIST',
                                      investmentThesis: SymbolUtils.getEstimatedThesis(cleanSym),
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
                            },
                            leading: Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  stock.instrument.isEmpty
                                      ? '-'
                                      : stock.instrument.substring(0, 1),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              SymbolUtils.normalize(stock.instrument),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                stock.companyName.isNotEmpty &&
                                        stock.companyName.toUpperCase() !=
                                            SymbolUtils.normalize(stock.instrument)
                                    ? stock.companyName
                                    : SymbolUtils.getDisplayName(stock.instrument),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF8E929B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Real-Time Live Market Price Display
                                _LivePriceColumn(symbol: stock.instrument),
                                const SizedBox(width: 10),
                                _ScoreBadge(score: stock.overallScore),
                                const SizedBox(width: 8),
                                Builder(
                                  builder: (context) {
                                    final isSaved = watchlistNotifier.isSaved(stock.instrument);
                                    return InkWell(
                                      onTap: () {
                                        if (isSaved) {
                                          watchlistNotifier.remove(stock.instrument);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${stock.instrument} removed from MY SAVED LIST'),
                                              backgroundColor: const Color(0xFF16171B),
                                            ),
                                          );
                                        } else {
                                          final liveQuote = ref.read(liveQuoteProvider(SymbolUtils.normalize(stock.instrument))).value;
                                          final rawPrice = (liveQuote != null && liveQuote.currentPrice > 0)
                                              ? liveQuote.currentPrice
                                              : SymbolUtils.getEstimatedPrice(stock.instrument);
                                          final savePrice = rawPrice > 0 ? rawPrice : 0.0;
                                          final changePct = (liveQuote != null && liveQuote.currentPrice > 0)
                                              ? liveQuote.changePercent
                                              : 0.0;

                                          watchlistNotifier.addStock(
                                            stock,
                                            customPrice: savePrice > 0 ? savePrice : null,
                                            dayChangePercent: changePct,
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                savePrice > 0
                                                    ? '${SymbolUtils.normalize(stock.instrument)} saved at ₹${savePrice.toStringAsFixed(2)}'
                                                    : '${SymbolUtils.normalize(stock.instrument)} added to watchlist',
                                              ),
                                              backgroundColor: const Color(0xFF16171B),
                                            ),
                                          );
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSaved
                                              ? const Color(0x33E5A93C)
                                              : const Color(0x1FE5A93C),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0x33E5A93C),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isSaved ? Icons.bookmark_rounded : Icons.add_rounded,
                                              color: const Color(0xFFE5A93C),
                                              size: 14,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              isSaved ? 'Saved' : 'Save',
                                              style: const TextStyle(
                                                color: Color(0xFFE5A93C),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF757A85),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            ] else ...[
              // Tab 1: MY SAVED LIST (Watchlist Table View matching attached image 4)
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFFE5A93C),
                  backgroundColor: const Color(0xFF16171B),
                  onRefresh: () async {
                    await watchlistNotifier.refreshWatchlist();
                  },
                  child: WatchlistTableView(
                    items: savedList,
                    onDelete: (item) {
                      watchlistNotifier.remove(item.instrument);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.instrument} removed from MY SAVED LIST'),
                          backgroundColor: const Color(0xFF16171B),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;

  const _ScoreBadge({
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    if (score <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: const Text(
          'ANALYZE',
          style: TextStyle(
            color: Color(0xFF8E929B),
            fontWeight: FontWeight.w700,
            fontSize: 9.5,
          ),
        ),
      );
    }

    final color = _scoreColor(score);

    return Container(
      width: 48,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '$score',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }

  Color _scoreColor(int value) {
    if (value >= 80) return const Color(0xFF00E676);
    if (value >= 60) return const Color(0xFFE5A93C);
    if (value >= 40) return const Color(0xFFFF9800);
    return const Color(0xFFFF5252);
  }
}

class _SearchState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool loading;

  const _SearchState({
    required this.icon,
    required this.title,
    required this.message,
    this.loading = false,
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
          ],
        ),
      ),
    );
  }
}

class _LivePriceColumn extends ConsumerWidget {
  final String symbol;

  const _LivePriceColumn({required this.symbol});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clean = SymbolUtils.normalize(symbol);
    final quoteAsync = ref.watch(liveQuoteProvider(clean));

    return quoteAsync.when(
      data: (quote) {
        final price = quote.currentPrice > 0
            ? quote.currentPrice
            : SymbolUtils.getEstimatedPrice(clean);
        final isPos = quote.change >= 0;
        final hasChange = quote.changePercent != 0.0;
        final changeText = hasChange
            ? '${isPos ? '+' : ''}${quote.changePercent.toStringAsFixed(2)}%'
            : (price > 0 ? 'Live NSE' : 'Pending');

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              price > 0 ? '₹${price.toStringAsFixed(2)}' : 'Syncing...',
              style: TextStyle(
                color: price > 0 ? Colors.white : const Color(0xFF8E929B),
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasChange && price > 0) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPos ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  changeText,
                  style: TextStyle(
                    color: hasChange
                        ? (isPos ? const Color(0xFF00E676) : const Color(0xFFFF5252))
                        : const Color(0xFF8E929B),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () {
        final estPrice = SymbolUtils.getEstimatedPrice(clean);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              estPrice > 0 ? '₹${estPrice.toStringAsFixed(2)}' : 'Syncing...',
              style: TextStyle(
                color: estPrice > 0 ? Colors.white : const Color(0xFF8E929B),
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Live NSE',
              style: TextStyle(
                color: Color(0xFF8E929B),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        );
      },
      error: (error, stack) {
        final estPrice = SymbolUtils.getEstimatedPrice(clean);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              estPrice > 0 ? '₹${estPrice.toStringAsFixed(2)}' : '—',
              style: const TextStyle(
                color: Color(0xFF8E929B),
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Offline',
              style: TextStyle(
                color: Color(0xFF8E929B),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}
