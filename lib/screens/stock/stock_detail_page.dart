import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

import '../../models/live_portfolio.dart';
import '../../models/stock_score.dart';

import '../../providers/stock_score_provider.dart';

import 'widgets/stock_header.dart';
import 'widgets/chart_card.dart';
import 'widgets/chart_header.dart';
import 'widgets/chart_selector.dart';
import 'widgets/holding_card.dart';
import 'widgets/stats_grid.dart';
import 'widgets/company_overview_card.dart';
import 'widgets/investment_thesis_card.dart';
import 'widgets/ai_score_card.dart';
import 'widgets/recommendation_card.dart';
import 'widgets/news_card.dart';

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

  @override
  Widget build(BuildContext context) {

    final stock = widget.stock;
    final portfolio = stock.portfolio;

    final scoreAsync = ref.watch(
      stockScoreProvider(
        portfolio.instrument,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Text(
          portfolio.instrument,
        ),
      ),

      body: SingleChildScrollView(
        physics:
            const BouncingScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
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
                  stock.currentPrice,
              netPL:
                  stock.netPL,
              returnPercent:
                  stock.returnPercent,
              isProfit:
                  stock.netPL >= 0,
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            ChartCard(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  ChartHeader(
                    title:
                        portfolio.instrument,
                    currentPrice:
                        stock.currentPrice,
                    change:
                        stock.netPL,
                    changePercent:
                        stock.returnPercent,
                  ),

                  const SizedBox(
                    height: AppSpacing.lg,
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

                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),

                    child: const Center(
                      child: Text(
                        "Historical Chart Coming Soon",
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            HoldingCard(
              stock: stock,
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            StatsGrid(
              items: [

                StatItem(
                  title: "Quantity",
                  value:
                      portfolio.qty.toString(),
                  icon:
                      Icons.inventory_2_outlined,
                ),

                StatItem(
                  title: "Average",
                  value:
                      "₹${portfolio.avgPrice.toStringAsFixed(2)}",
                  icon:
                      Icons.payments_outlined,
                ),

                StatItem(
                  title: "Current",
                  value:
                      "₹${stock.currentPrice.toStringAsFixed(2)}",
                  icon:
                      Icons.show_chart,
                ),
                                StatItem(
                  title: "Return",
                  value:
                      "${stock.returnPercent.toStringAsFixed(2)}%",
                  icon:
                      Icons.trending_up,
                  color: stock.netPL >= 0
                      ? AppColors.success
                      : AppColors.danger,
                ),
              ],
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            CompanyOverviewCard(
              companyName:
                  portfolio.companyName,
              sector:
                  portfolio.sector,
              industry:
                  portfolio.industry,
              status:
                  portfolio.status,
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

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

                  return Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),
                    child: const Text(
                      "AI data not available.",
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