import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/live_portfolio_provider.dart';
import '../../providers/market_indices_provider.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/price_provider.dart';
import '../advisor/advisor_chat_page.dart';
import '../home/home_page.dart';
import 'widgets/ai_briefing_card.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_signals_grid.dart';
import 'widgets/dashboard_top_holdings_section.dart';
import 'widgets/market_indices_bar.dart';
import 'widgets/portfolio_health_card.dart';
import 'widgets/portfolio_hero_card.dart';
import '../portfolio/widgets/add_holding_sheet.dart';

class DashboardPage extends ConsumerStatefulWidget {
  final VoidCallback? onOpenAdvisor;

  const DashboardPage({super.key, this.onOpenAdvisor});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with WidgetsBindingObserver {
  bool _isRefreshing = false;
  DateTime _lastUpdated = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final difference = DateTime.now().difference(_lastUpdated);
      if (difference.inMinutes >= 5) {
        _refreshDashboard();
      }
    }
  }

  bool _checkIsMarketOpen() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30)); // IST
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      return false;
    }
    final startMinutes = 9 * 60 + 15;
    final endMinutes = 15 * 60 + 30;
    final currentMinutes = now.hour * 60 + now.minute;
    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  }

  Future<void> _refreshDashboard() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    try {
      ref.invalidate(dashboardProvider);
      ref.invalidate(livePortfolioProvider);
      ref.invalidate(portfolioProvider);
      ref.invalidate(pricesProvider);
      ref.invalidate(marketIndicesProvider);
      await Future.wait([
        ref.read(dashboardProvider.future),
        ref.read(marketIndicesProvider.future),
      ]);

      if (!mounted) return;
      setState(() {
        _lastUpdated = DateTime.now();
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Dashboard and market data refreshed.'),
            duration: Duration(seconds: 2),
          ),
        );
    } catch (error) {
      ref.invalidate(dashboardProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Refresh notice: $error')),
        );
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(dashboardProvider);
    final portfolioAsync = ref.watch(livePortfolioProvider);
    final isMarketOpen = _checkIsMarketOpen();

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D10),
      body: SafeArea(
        child: dashboard.when(
          loading: () => const _ScreenState(
            icon: Icons.hourglass_empty_rounded,
            title: 'Building portfolio cockpit',
            message: 'Fetching live valuation, health scores and AI signals.',
            loading: true,
          ),
          error: (e, _) => _ScreenState(
            icon: Icons.error_outline_rounded,
            title: 'Dashboard unavailable',
            message: e.toString(),
            action: ElevatedButton(
              onPressed: () => ref.invalidate(dashboardProvider),
              child: const Text('Try Again'),
            ),
          ),
          data: (data) {
            final liveStocks = portfolioAsync.value ?? [];

            return RefreshIndicator(
              onRefresh: _refreshDashboard,
              color: const Color(0xFFE5A93C),
              backgroundColor: const Color(0xFF16171B),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 540),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Sleek Compact Header (Good afternoon, Demo User + Actions)
                              const DashboardHeader(),

                              const SizedBox(height: 12),

                              // Live NIFTY 50 and SENSEX Benchmark Bar
                              const MarketIndicesBar(),

                              const SizedBox(height: 14),

                              if (data.totalStocks == 0) ...[
                                _buildNewUserOnboardingCard(context),
                              ] else ...[
                                // 2. Compact Portfolio Value Card
                                PortfolioHeroCard(
                                  currentValue: data.currentValue,
                                  investedValue: data.totalInvested,
                                  netPnL: data.totalPnL,
                                  returnPercent: data.returnPercent,
                                  todayPnL: data.todayPnL,
                                  todayReturnPercent: data.todayReturnPercent,
                                  holdings: data.totalStocks,
                                  aiConfidence: 74,
                                  isMarketOpen: isMarketOpen,
                                ),

                                const SizedBox(height: 14),

                                // 3. Compact AI Portfolio Health Gauge Card
                                PortfolioHealthCard(
                                  healthScore: data.portfolioHealth,
                                  action: data.aiRecommendation.recommendation.name.toUpperCase(),
                                  aiConfidence: data.aiRecommendation.confidence.toDouble(),
                                  onOpenAdvisor: widget.onOpenAdvisor ?? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const AdvisorChatPage()),
                                    );
                                  },
                                ),

                                const SizedBox(height: 14),

                                // 4. Compact 2x2 Micro Cards Grid (Winner, Weakest, Opportunity, Diversification)
                                DashboardSignalsGrid(
                                  summary: data,
                                  holdings: liveStocks,
                                ),
                              ],

                              const SizedBox(height: 22),

                              // 5. Today's AI Briefing & Insight Column (Attached Image 2)
                              Row(
                                children: [
                                  const Text(
                                    'NV Briefing',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0x1FE5A93C),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: const Color(0x33E5A93C),
                                      ),
                                    ),
                                    child: const Text(
                                      'TODAY',
                                      style: TextStyle(
                                        color: Color(0xFFE5A93C),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Signals ranked by conviction and risk.',
                                style: TextStyle(
                                  color: Color(0xFF8E929B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // AI Verdict & Health Insights Card (Reasons + Actions)
                              AIBriefingCard(ai: data.aiRecommendation),

                              const SizedBox(height: 22),

                              // 6. Sector Allocation Preview & Top Holdings List
                              DashboardTopHoldingsSection(
                                holdings: liveStocks,
                                onViewAll: () {
                                  // Switch to Portfolio tab if embedded in HomePage
                                  final homeState = context.findAncestorStateOfType<State<HomePage>>();
                                  if (homeState != null) {
                                    // ignore: invalid_use_of_protected_member
                                    homeState.setState(() {
                                      // ignore: avoid_dynamic_calls
                                      (homeState as dynamic).currentIndex = 1;
                                    });
                                  }
                                },
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNewUserOnboardingCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16171B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x33E5A93C)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5A93C).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: const Color(0x1FE5A93C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x40E5A93C)),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: Color(0xFFE5A93C),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Nivaarth Cockpit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Institutional AI Intelligence Engine Active',
                      style: TextStyle(
                        color: Color(0xFF8E929B),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Text(
            'Add your current equity holdings to activate real-time analytics:',
            style: TextStyle(
              color: Color(0xFFD1D5DB),
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),
          _buildOnboardingBullet(
            icon: Icons.auto_awesome_rounded,
            title: 'Deterministic 100-Point Conviction Scoring',
            subtitle: 'Quality (25), Solvency (25), Growth (20), Valuation (15), Tech (10)',
          ),
          const SizedBox(height: 8),
          _buildOnboardingBullet(
            icon: Icons.shield_outlined,
            title: 'Dynamic Portfolio Health & Risk Radar',
            subtitle: 'Real-time concentration limits, factor diversification & drift alerts',
          ),
          const SizedBox(height: 8),
          _buildOnboardingBullet(
            icon: Icons.psychology_outlined,
            title: 'NV Advisor Contextual Co-Pilot',
            subtitle: 'Ask questions about your holdings with institutional quantitative models',
          ),

          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5A93C),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const AddHoldingSheet(),
                );
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: Colors.black),
              label: const Text(
                'Add Your First Holding',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingBullet({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFFE5A93C)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF757A85),
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScreenState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final bool loading;
  final Widget? action;

  const _ScreenState({
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
              height: 52,
              width: 52,
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
                fontWeight: FontWeight.w700,
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