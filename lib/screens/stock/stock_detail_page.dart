import '../../core/utils/formatters.dart';
import '../../core/utils/market_hours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

import '../../core/utils/symbol_utils.dart';
import '../../models/live_portfolio.dart';
import '../../models/stock_score.dart';

import '../../providers/listing_provider.dart';
import '../../providers/live_quote_provider.dart';
import '../../providers/price_alert_provider.dart';
import '../../providers/stock_insights_provider.dart';
import '../../providers/privacy_provider.dart';
import '../../providers/stock_score_provider.dart';
import '../../providers/watchlist_provider.dart';

import '../../widgets/listing_badges.dart';
import 'widgets/stock_header.dart';
import 'widgets/peer_comparison_card.dart';
import 'widgets/price_alert_sheet.dart';
import 'widgets/stock_radar_card.dart';
import 'widgets/stock_line_chart.dart';
import 'widgets/chart_card.dart';
import 'widgets/chart_selector.dart';
import 'widgets/holding_card.dart';
import 'widgets/company_overview_card.dart';
import 'widgets/investment_thesis_card.dart';
import 'widgets/ai_score_card.dart';
import 'widgets/recommendation_card.dart';
import 'widgets/news_card.dart';
import '../portfolio/widgets/add_holding_sheet.dart';
import '../../services/backend_service.dart';
import '../../core/l10n/l10n_ext.dart';

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

  void _openAddHolding(BuildContext context, String symbol, String companyName, double price) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddHoldingSheet(
        initialInstrument: symbol,
        initialCompanyName: companyName,
        initialPrice: price,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final stock = widget.stock;
    final portfolio = stock.portfolio;
    final cleanSym = SymbolUtils.normalize(portfolio.instrument);
    final classification = ref.watch(stockClassificationProvider(cleanSym)).valueOrNull;
    final isSaved = ref.watch(watchlistProvider.notifier).isSaved(portfolio.instrument);

    final scoreAsync = ref.watch(
      stockScoreProvider(
        portfolio.instrument,
      ),
    );

    final isOwned = portfolio.qty > 0 || portfolio.status == 'PORTFOLIO';

    final liveQuote = ref.watch(liveQuoteProvider(cleanSym)).valueOrNull;

    // Preserving 100% accurate database values for owned portfolio assets
    final double displayPrice;
    final double displayChange;
    final double displayReturnPercent;

    if (isOwned) {
      displayPrice = stock.currentPrice;
      displayChange = stock.netPL;
      displayReturnPercent = stock.returnPercent;
    } else {
      displayPrice = (liveQuote != null && liveQuote.currentPrice > 0)
          ? liveQuote.currentPrice
          : stock.currentPrice;
      displayChange = (liveQuote != null && liveQuote.currentPrice > 0)
          ? liveQuote.change
          : stock.netPL;
      displayReturnPercent = (liveQuote != null && liveQuote.currentPrice > 0)
          ? liveQuote.changePercent
          : stock.returnPercent;
    }

    final double? todayPL = isOwned
        ? (stock.todayPL != 0
            ? stock.todayPL
            : ((liveQuote != null && liveQuote.previousClose > 0)
                ? (displayPrice - liveQuote.previousClose) * portfolio.qty
                : 0.0))
        : null;

    final double? todayReturnPercent = isOwned
        ? (stock.todayReturnPercent != 0
            ? stock.todayReturnPercent
            : ((liveQuote != null && liveQuote.previousClose > 0)
                ? ((displayPrice - liveQuote.previousClose) / liveQuote.previousClose) * 100
                : 0.0))
        : null;

    final isProfit = displayChange >= 0;

    final score = scoreAsync.valueOrNull;
    String? computedTrend;
    if (score != null && score.technical > 0) {
      if (score.technical >= 7) {
        computedTrend = "Bullish";
      } else if (score.technical <= 4) {
        computedTrend = "Bearish";
      } else {
        computedTrend = "Neutral";
      }
    }

    final chartPointsAsync = ref.watch(
      stockChartProvider(
        ChartQuery(cleanSym, _selectedRange),
      ),
    );

    final isDesktop = Breakpoints.isDesktop(context);
    final alertCount = (ref.watch(activePriceAlertsProvider).valueOrNull ?? const [])
        .where((a) => a.instrument.toUpperCase() == cleanSym.toUpperCase())
        .length;

    final Widget overview = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StockHeader(
          hideMoney: ref.watch(privacyModeProvider),
          instrument:
              portfolio.instrument,
          companyName:
              portfolio.companyName,
          status:
              isOwned ? 'PORTFOLIO' : portfolio.status,
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
          todayPL: todayPL,
          todayReturnPercent: todayReturnPercent,
          onSaveToggle: () {
            final notifier = ref.read(watchlistProvider.notifier);
            if (isSaved) {
              notifier.remove(portfolio.instrument);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.t.savedRemoved(portfolio.instrument)),
                  backgroundColor: AppColors.surface,
                ),
              );
            } else {
              notifier.addBySymbol(
                symbol: portfolio.instrument,
                companyName: portfolio.companyName,
                price: stock.currentPrice,
                score: scoreAsync.valueOrNull?.overallScore ?? 0,
                tag: scoreAsync.valueOrNull?.recommendation ?? '',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.t.savedAdded(portfolio.instrument, Formatters.currency(stock.currentPrice))),
                  backgroundColor: AppColors.surface,
                ),
              );
            }
          },
        ),

        // SME / Z / T2T badges and how old the fundamentals are
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ListingInfoStrip(info: ref.watch(listingInfoProvider(cleanSym)).valueOrNull),
        ),

        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.inkSoft,
              padding: const EdgeInsets.symmetric(vertical: 4),
              visualDensity: VisualDensity.compact,
            ),
            icon: const Icon(Icons.notifications_active_outlined, size: 16),
            label: Text(
              alertCount > 0 ? context.t.alertButtonCount(alertCount) : context.t.alertButton,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => PriceAlertSheet(symbol: cleanSym, currentPrice: displayPrice),
            ),
          ),
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
                  Icon(
                    Icons.insights_rounded,
                    size: 16,
                    color: AppColors.inkSoft,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.t.stockPricePerformance,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const Spacer(),
                  // "Real-time" only while NSE trades
                  if (isMarketOpenIst(DateTime.now().toUtc()))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ink.withValues(alpha: .06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "NSE Real-time",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.line),
                ),
                child: chartPointsAsync.when(
                  loading: () => Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      context.t.stockChartSoon,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  data: (points) {
                    if (points.length < 2) {
                      return Center(
                        child: Text(
                          context.t.stockChartSoon,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }
                    return StockLineChart(
                      series: points,
                      isPositive: isProfit,
                      range: _selectedRange,
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
        ] else ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.visibility_rounded,
                    color: AppColors.inkSoft,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t.stockWatchlistAsset,
                        style: TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        context.t.stockNotOwned,
                        style: TextStyle(
                          color: AppColors.textTertiary,
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
          sector: classification?.sector ?? SymbolUtils.getSector(portfolio.instrument, dbSector: portfolio.sector),
          industry: classification?.industry ??
              SymbolUtils.getIndustry(
                portfolio.instrument,
                dbIndustry: portfolio.industry,
              ),
          status: isOwned ? portfolio.status : 'DISCOVERY',
        ),

        if (InvestmentThesisCard.isUserWritten(portfolio.investmentThesis)) ...[
          const SizedBox(height: 16),
          InvestmentThesisCard(thesis: portfolio.investmentThesis),
        ],
      ],
    );

    final Widget scoreSection = scoreAsync.when(

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
            context.t.stockScoreFailed,
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
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.ink.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.inkSoft,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NV Quantitative Engine',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            context.t.stockAnalyzing(cleanSym),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                LinearProgressIndicator(
                  backgroundColor: AppColors.surfaceSecondary,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.inkSoft),
                  minHeight: 3,
                ),
                const SizedBox(height: 14),
                Text(
                  context.t.stockScoring,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
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

            StockRadarCard(
              symbol: cleanSym,
              companyName: portfolio.companyName.isNotEmpty ? portfolio.companyName : cleanSym,
              score: score,
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            PeerComparisonCard(symbol: cleanSym, score: score),

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

            NewsCard(symbol: cleanSym),

            const SizedBox(height: 24),

            // Regulatory Notice & Educational Disclaimer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceSecondary),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 15, color: AppColors.textTertiary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Regulatory Notice: Nivaarth is a financial analytics and research technology platform. All quantitative scores, factor models, and signals are algorithmically computed for educational purposes only and do not constitute SEBI-registered investment advice.',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      },

    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ink, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          portfolio.instrument,
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _openAddHolding(
                context,
                portfolio.instrument,
                portfolio.companyName,
                displayPrice,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isOwned ? AppColors.success.withValues(alpha: 0.15) : AppColors.info.withAlpha(0x1F),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isOwned ? AppColors.success.withValues(alpha: 0.30) : AppColors.info.withAlpha(0x4D),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOwned ? Icons.account_balance_wallet_rounded : Icons.add_business_rounded,
                      color: isOwned ? AppColors.success : AppColors.info,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOwned ? context.t.metricHoldings : '+ Port',
                      style: TextStyle(
                        color: isOwned ? AppColors.success : AppColors.info,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                      content: Text(context.t.savedRemoved(portfolio.instrument)),
                      backgroundColor: AppColors.surface,
                    ),
                  );
                } else {
                  notifier.addBySymbol(
                    symbol: portfolio.instrument,
                    companyName: portfolio.companyName,
                    price: stock.currentPrice,
                    score: scoreAsync.valueOrNull?.overallScore ?? 0,
                    tag: scoreAsync.valueOrNull?.recommendation ?? '',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.t.savedAdded(portfolio.instrument, Formatters.currency(stock.currentPrice))),
                      backgroundColor: AppColors.surface,
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSaved ? AppColors.ink.withValues(alpha: 0.14) : AppColors.ink.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.ink.withValues(alpha: 0.20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
                      color: AppColors.inkSoft,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isSaved ? context.t.stockSaved : context.t.stockSave,
                      style: TextStyle(
                        color: AppColors.inkSoft,
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
        padding: EdgeInsets.fromLTRB(
          isDesktop ? 24 : 16,
          10,
          isDesktop ? 24 : 16,
          32,
        ),
        child: isDesktop
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: Breakpoints.contentMaxWidth),
                  // Wide screens: price & position on the left, NV score on the right.
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: overview),
                      const SizedBox(width: 20),
                      Expanded(flex: 5, child: scoreSection),
                    ],
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  overview,
                  const SizedBox(height: AppSpacing.lg),
                  scoreSection,
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
      ),
    );
  }
}