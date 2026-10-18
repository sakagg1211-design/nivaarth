import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

import '../../core/utils/symbol_utils.dart';
import '../../models/live_portfolio.dart';
import '../../models/stock_score.dart';

import '../../providers/live_quote_provider.dart';
import '../../providers/stock_score_provider.dart';
import '../../providers/watchlist_provider.dart';

import 'widgets/stock_header.dart';
import 'widgets/stock_line_chart.dart';
import 'widgets/chart_card.dart';
import 'widgets/chart_selector.dart';
import 'widgets/holding_card.dart';
import 'widgets/stats_grid.dart';
import 'widgets/company_overview_card.dart';
import 'widgets/investment_thesis_card.dart';
import 'widgets/ai_score_card.dart';
import 'widgets/recommendation_card.dart';
import 'widgets/news_card.dart';
import '../../services/backend_service.dart';

class StockDetailPage extends ConsumerStatefulWidget {
  final LivePortfolio stock;

  const StockDetailPage({
    super.key,
    required this.stock,
  });

  @override
  ConsumerState<StockDetailPage> createState() =>
      _StockDetailPageState();
}

class _StockDetailPageState
    extends ConsumerState<StockDetailPage> {

  String _selectedRange = "1D";
  bool _isOnboarding = false;

  void _triggerAutoOnboard(String cleanSym) {
    if (_isOnboarding) return;
    _isOnboarding = true;
    BackendService().onboardStock(instrument: cleanSym).then((res) {
      if (mounted) {
        ref.invalidate(stockScoreProvider(widget.stock.portfolio.instrument));
      }
    }).catchError((_) {}).whenComplete(() {
      if (mounted) {
        setState(() => _isOnboarding = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final stock = widget.stock;
    final portfolio = stock.portfolio;
    final cleanSym = SymbolUtils.normalize(portfolio.instrument);
    final isSaved = ref.watch(watchlistProvider.notifier).isSaved(portfolio.instrument);

    final scoreAsync = ref.watch(
      stockScoreProvider(
        portfolio.instrument,
      ),
    );

    final isOwned = portfolio.qty > 0;

    // Preserving 100% accurate database values for owned portfolio assets
    final double displayPrice;
    final double displayChange;
    final double displayReturnPercent;

    if (isOwned) {
      displayPrice = stock.currentPrice;
      displayChange = stock.netPL;
      displayReturnPercent = stock.returnPercent;
    } else {
      final liveQuote = ref.watch(liveQuoteProvider(cleanSym)).value;
      displayPrice = (liveQuote != null && liveQuote.currentPrice > 0)
          ? liveQuote.currentPrice
          : (stock.currentPrice > 0 ? stock.currentPrice : SymbolUtils.getEstimatedPrice(cleanSym));
      displayChange = (liveQuote != null && liveQuote.currentPrice > 0)
          ? liveQuote.change
          : stock.netPL;
      displayReturnPercent = (liveQuote != null && liveQuote.currentPrice > 0)
          ? liveQuote.changePercent
          : stock.returnPercent;
    }

    final isProfit = displayChange >= 0;

    final score = scoreAsync.value;
    String? computedTrend;
    if (score != null && score.technical > 0) {
      if (score.technical >= 7) {
        computedTrend = "Bullish";
      } else if (score.technical <= 4) {
        computedTrend = "Bearish";
      } else {
        computedTrend = "Neutral";
      }
    } else if (stock.returnPercent != 0) {
      computedTrend = stock.returnPercent > 0 ? "Bullish" : "Bearish";
    }

    final chartPointsAsync = ref.watch(
      stockChartProvider(
        ChartQuery(cleanSym, _selectedRange),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D10),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0C0D10),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          portfolio.instrument,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                final notifier = ref.read(watchlistProvider.notifier);
                if (isSaved) {
                  notifier.remove(portfolio.instrument);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${portfolio.instrument} removed from MY SAVED LIST'),
                      backgroundColor: const Color(0xFF16171B),
                    ),
                  );
                } else {
                  notifier.addBySymbol(
                    symbol: portfolio.instrument,
                    companyName: portfolio.companyName,
                    price: stock.currentPrice,
                    score: scoreAsync.value?.overallScore ?? 78,
                    tag: scoreAsync.value?.recommendation ?? 'BUY',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${portfolio.instrument} saved to MY SAVED LIST at ₹${stock.currentPrice.toStringAsFixed(2)}'),
                      backgroundColor: const Color(0xFF16171B),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSaved ? const Color(0x33E5A93C) : const Color(0x1FE5A93C),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0x4DE5A93C),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
                      color: const Color(0xFFE5A93C),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isSaved ? 'Saved' : '+ Save',
                      style: const TextStyle(
                        color: Color(0xFFE5A93C),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          32,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            StockHeader(
              instrument:
                  portfolio.instrument,
              companyName:
                  portfolio.companyName,
              status:
                  portfolio.status,
              currentPrice:
                  displayPrice,
              netPL:
                  displayChange,
              returnPercent:
                  displayReturnPercent,
              isProfit:
                  isProfit,
              trend: computedTrend,
              isSaved: isSaved,
              onSaveToggle: () {
                final notifier = ref.read(watchlistProvider.notifier);
                if (isSaved) {
                  notifier.remove(portfolio.instrument);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${portfolio.instrument} removed from MY SAVED LIST'),
                      backgroundColor: const Color(0xFF16171B),
                    ),
                  );
                } else {
                  notifier.addBySymbol(
                    symbol: portfolio.instrument,
                    companyName: portfolio.companyName,
                    price: stock.currentPrice,
                    score: scoreAsync.value?.overallScore ?? 78,
                    tag: scoreAsync.value?.recommendation ?? 'BUY',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${portfolio.instrument} saved to MY SAVED LIST at ₹${stock.currentPrice.toStringAsFixed(2)}'),
                      backgroundColor: const Color(0xFF16171B),
                    ),
                  );
                }
              },
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            ChartCard(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Row(
                    children: [
                      const Icon(
                        Icons.insights_rounded,
                        size: 16,
                        color: Color(0xFFE5A93C),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Price Performance",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "NSE Real-time",
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8E929B),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  ChartSelector(
                    selectedRange:
                        _selectedRange,

                    onChanged: (value) {

                      setState(() {

                        _selectedRange =
                            value;

                      });

                    },
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  Container(
                    height: 220,
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 8, bottom: 4, left: 4, right: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16171B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF282A30)),
                    ),
                    child: chartPointsAsync.when(
                      loading: () => const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFE5A93C),
                          ),
                        ),
                      ),
                      error: (_, __) => const Center(
                        child: Text(
                          "Historical Chart Coming Soon",
                          style: TextStyle(
                            color: Color(0xFF8E929B),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      data: (points) {
                        if (points.length < 2) {
                          return const Center(
                            child: Text(
                              "Historical Chart Coming Soon",
                              style: TextStyle(
                                color: Color(0xFF8E929B),
                                fontSize: 13,
                              ),
                            ),
                          );
                        }
                        return StockLineChart(
                          points: points,
                          isPositive: isProfit,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            if (isOwned) ...[
              const SizedBox(height: 16),
              HoldingCard(stock: stock),
              const SizedBox(height: 16),
              StatsGrid(
                items: [
                  StatItem(
                    title: "Quantity",
                    value: portfolio.qty.toString(),
                    icon: Icons.inventory_2_outlined,
                  ),
                  StatItem(
                    title: "Average",
                    value: "₹${portfolio.avgPrice.toStringAsFixed(2)}",
                    icon: Icons.payments_outlined,
                  ),
                  StatItem(
                    title: "Current",
                    value: "₹${stock.currentPrice.toStringAsFixed(2)}",
                    icon: Icons.show_chart,
                  ),
                  StatItem(
                    title: "Return",
                    value: "${stock.returnPercent.toStringAsFixed(2)}%",
                    icon: Icons.trending_up,
                    color: stock.netPL >= 0 ? AppColors.success : AppColors.danger,
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF16171B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF282A30)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0x1FE5A93C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.visibility_rounded,
                        color: Color(0xFFE5A93C),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Watchlist Asset',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Not currently in your owned portfolio.',
                            style: TextStyle(
                              color: Color(0xFF757A85),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            CompanyOverviewCard(
              companyName: portfolio.companyName.isNotEmpty
                  ? portfolio.companyName
                  : SymbolUtils.getDisplayName(portfolio.instrument),
              sector: portfolio.sector.isNotEmpty
                  ? portfolio.sector
                  : SymbolUtils.getSector(portfolio.instrument),
              industry: SymbolUtils.getIndustry(
                portfolio.instrument,
                dbIndustry: portfolio.industry,
              ),
              status: isOwned ? portfolio.status : 'DISCOVERY',
            ),

            const SizedBox(height: 16),

            InvestmentThesisCard(
              thesis:
                  portfolio.investmentThesis,
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            scoreAsync.when(

              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child:
                      CircularProgressIndicator(),
                ),
              ),

              error: (error, stack) {

                return Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: Text(
                    "Unable to load AI Score",
                    style: TextStyle(
                      color:
                          AppColors.danger,
                    ),
                  ),
                );

              },

              data: (StockScore? score) {
                if (score == null) {
                  // Trigger real quantitative onboarding in backend
                  _triggerAutoOnboard(cleanSym);

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16171B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF282A30)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0x1FE5A93C),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Color(0xFFE5A93C),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'NV Quantitative Engine',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Analyzing $cleanSym signals...',
                                    style: const TextStyle(
                                      color: Color(0xFF8E929B),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFE5A93C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const LinearProgressIndicator(
                          backgroundColor: Color(0xFF23252B),
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE5A93C)),
                          minHeight: 3,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Evaluating 6 institutional pillars: Business Quality, Financial Strength, Growth, Valuation, Technical & Risk.',
                          style: TextStyle(
                            color: Color(0xFF757A85),
                            fontSize: 11.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(

                  children: [

                    AiScoreCard(
                      score: score,
                    ),

                    const SizedBox(
                      height: AppSpacing.lg,
                    ),

                    RecommendationCard(
                      score: score,
                      companyName: portfolio.companyName,
                      sector: portfolio.sector,
                      industry: portfolio.industry,
                      isOwned: isOwned,
                    ),

                    const SizedBox(
                      height: AppSpacing.lg,
                    ),

                    const NewsCard(
                      news: [],
                    ),
                  ],
                );

              },

            ),

            const SizedBox(
              height: AppSpacing.xxl,
            ),

          ],
        ),
      ),
    );
  }
}