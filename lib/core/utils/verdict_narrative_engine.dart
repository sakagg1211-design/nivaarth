import '../../models/stock_score.dart';
import 'symbol_utils.dart';

class VerdictSignal {
  final String title;
  final String description;
  final String scoreLabel;
  final bool isPositive;

  const VerdictSignal({
    required this.title,
    required this.description,
    required this.scoreLabel,
    required this.isPositive,
  });
}

class TacticalPlaybook {
  final String existingHoldersGuideline;
  final String freshCapitalGuideline;
  final String keyMonitorable;

  const TacticalPlaybook({
    required this.existingHoldersGuideline,
    required this.freshCapitalGuideline,
    required this.keyMonitorable,
  });
}

class VerdictNarrative {
  final String archetypeTag;
  final String archetypeIcon;
  final String analystBriefing;
  final VerdictSignal primaryCatalyst;
  final VerdictSignal primaryRisk;
  final TacticalPlaybook playbook;
  final String convictionLabel;

  const VerdictNarrative({
    required this.archetypeTag,
    required this.archetypeIcon,
    required this.analystBriefing,
    required this.primaryCatalyst,
    required this.primaryRisk,
    required this.playbook,
    required this.convictionLabel,
  });
}

class VerdictNarrativeEngine {
  const VerdictNarrativeEngine._();

  static const Set<String> _psuSymbols = {
    'LT',
    'IRFC',
    'NBCC',
    'BHEL',
    'BEL',
    'POWERGRID',
    'COALINDIA',
    'NTPC',
    'SBIN',
    'ONGC',
    'IOC',
    'GAIL',
    'PFC',
    'RECLTD',
    'RVNL',
    'IRCON',
    'NHPC',
    'SJVN',
    'MAHABANK',
    'BANKBARODA',
    'PNB',
    'CANBK',
    'HAL',
    'HINDCOPPER',
    'SAIL',
    'NMDC',
    'OIL',
    'BPCL',
    'HPCL',
  };

  static VerdictNarrative generate({
    required StockScore score,
    String? companyName,
    String? sector,
    String? industry,
    bool isOwned = false,
  }) {
    final cleanSym = SymbolUtils.normalize(score.instrument).toUpperCase();
    final isEtf = SymbolUtils.isEtf(cleanSym);

    final resolvedName = (companyName != null &&
            companyName.trim().isNotEmpty &&
            companyName.trim().toUpperCase() != cleanSym)
        ? companyName.trim()
        : (score.companyName.trim().isNotEmpty &&
                score.companyName.trim().toUpperCase() != cleanSym)
            ? score.companyName.trim()
            : SymbolUtils.getDisplayName(cleanSym);

    // Prevent duplicate ticker like "Infibeam Avenues (CCAVENUE) (CCAVENUE)"
    final displayName = resolvedName.toUpperCase().contains(cleanSym)
        ? resolvedName
        : '$resolvedName ($cleanSym)';

    final resolvedSector = SymbolUtils.getSector(cleanSym, dbSector: sector);

    // -------------------------------------------------------------
    // 1. ETF / COMMODITY / BASKET ASSET PATH
    // -------------------------------------------------------------
    if (isEtf) {
      return VerdictNarrative(
        archetypeTag: 'Defensive Capital Shield',
        archetypeIcon: '🛡️',
        analystBriefing: score.analystVerdict?.trim().isNotEmpty == true
            ? score.analystVerdict!.trim()
            : '$displayName operates as an institutional-grade passive investment vehicle tracking $resolvedSector. Backed by underlying physical assets or index baskets, it eliminates single-company credit and governance risks while providing essential macroeconomic hedging.',
        primaryCatalyst: VerdictSignal(
          title: 'Systemic Diversification & Zero Credit Risk',
          description:
              'Eliminates company-specific insolvency risk with direct asset-class exposure and high exchange liquidity.',
          scoreLabel: 'Rating: ${score.risk}/5',
          isPositive: true,
        ),
        primaryRisk: const VerdictSignal(
          title: 'Macro Commodity & Benchmark Beta',
          description:
              'Returns are tied to global macro interest rates and commodity cycles without internal alpha generation.',
          scoreLabel: 'Risk: Moderate',
          isPositive: false,
        ),
        playbook: TacticalPlaybook(
          existingHoldersGuideline: isOwned
              ? 'Maintain strategic asset-allocation weight (5-15% of portfolio). Continue disciplined systematic SIP.'
              : 'Core portfolio hedge. Hold through broader macroeconomic volatility.',
          freshCapitalGuideline:
              'Accumulate systematically during broader macro pullbacks rather than chasing spikes at all-time highs.',
          keyMonitorable:
              'Global real interest rate yields, US Dollar index (DXY) trajectory, and central bank demand.',
        ),
        convictionLabel: 'Institutional Defensive Allocation',
      );
    }

    // -------------------------------------------------------------
    // 1B. EXCLUDED ASSET CLASS PATH (HOLDING CO, INSURANCE, REIT)
    // -------------------------------------------------------------
    if (score.isExcluded) {
      final rec = score.recommendation.toUpperCase();
      final isHold = rec.contains('HOLDING');
      final isIns = rec.contains('INSURANCE');
      final isReit = rec.contains('REIT') || rec.contains('INVIT');

      final archetype = isHold
          ? 'Investment Holding Company (SOTP Required)'
          : (isIns
              ? 'Actuarial Underwriting Entity (EV Model Required)'
              : (isReit
                  ? 'Yield Distribution Trust (NAV Required)'
                  : 'Specialized Asset Class (Score Excluded)'));

      final icon = isHold ? '🏢' : (isIns ? '☂️' : (isReit ? '🏗️' : '📋'));

      return VerdictNarrative(
        archetypeTag: archetype,
        archetypeIcon: icon,
        analystBriefing: score.analystVerdict?.trim().isNotEmpty == true
            ? score.analystVerdict!.trim()
            : (isHold
                ? '$displayName functions as an equity investment holding company. Standard operating ROCE and P/E ratios are mathematically distorted by holding company discounts and non-operating dividend income. Valuation must be assessed via Sum-of-the-Parts (SOTP) net asset value.'
                : (isIns
                    ? '$displayName operates an actuarial insurance underwriting portfolio. Statutory accounting and premium float dynamics make industrial ROCE metrics non-applicable; valuation is driven by Value of New Business (VNB) margins and Embedded Value (EV).'
                    : '$displayName is a structured trust vehicle distributing rental/infrastructure cash flows. Standard industrial scoring is withheld in favor of Net Asset Value (NAV) and distribution yield.')),
        primaryCatalyst: VerdictSignal(
          title: isHold ? 'Underlying Portfolio Holdings NAV' : (isIns ? 'Float Compounding & VNB Expansion' : 'Predictable Distribution Yield'),
          description: isHold
              ? 'Value realization is linked to the market capitalization growth of listed subsidiaries and unlisted associates.'
              : (isIns
                  ? 'Long-duration customer float and growing policyholder retention fuel actuarial book value expansion.'
                  : 'High dividend payout mandates and pass-through tax structures provide tangible cash distribution.'),
          scoreLabel: 'Coverage: Specialized',
          isPositive: true,
        ),
        primaryRisk: VerdictSignal(
          title: isHold ? 'Holding Company Discount Persistence' : (isIns ? 'Actuarial Claims / Surrender Risk' : 'Interest Rate Sensitivity'),
          description: isHold
              ? 'Holding company share prices often trade below the value of their underlying holdings; the gap varies by company and over time.'
              : (isIns
                  ? 'Regulatory commission caps and sudden mortality/morbidity claims spikes can pressure quarterly margins.'
                  : 'Rising benchmark yields increase the discount rate and compress trust capital value.'),
          scoreLabel: 'Risk: Specialized',
          isPositive: false,
        ),
        playbook: TacticalPlaybook(
          existingHoldersGuideline: isOwned
              ? 'Currently in your portfolio. The 1-100 score is not calculated for this category; review it on the metrics listed below.'
              : 'The 1-100 score is not calculated for this category because standard operating ratios do not apply.',
          freshCapitalGuideline:
              'Relevant metrics for this category: NAV discount (holding companies), EV / VNB (insurance), distribution yield (REITs / InvITs).',
          keyMonitorable: isHold
              ? 'Market value of core subsidiary holdings and parent capital allocation track record.'
              : (isIns ? 'VNB margins, persistency ratios, and solvency margin ratio.' : 'Occupancy rates, weighted average lease expiry (WALE), and yield spreads over G-Sec.'),
        ),
        convictionLabel: 'Specialized Asset Class (Score Excluded)',
      );
    }

    // -------------------------------------------------------------
    // 2. EQUITIES FACTOR ANALYSIS
    // -------------------------------------------------------------
    final bqPct = score.businessQuality / 25.0;
    final fsPct = score.financialStrength / 25.0;
    final grPct = score.growth / 20.0;
    final valPct = score.valuation / 15.0;
    final techPct = score.technical / 10.0;

    final isPsu = _psuSymbols.contains(cleanSym) ||
        resolvedName.toUpperCase().contains('CORP') ||
        resolvedName.toUpperCase().contains('INDIA') ||
        resolvedName.toUpperCase().contains('RAIL') ||
        resolvedName.toUpperCase().contains('POWER') ||
        resolvedName.toUpperCase().contains('BHARAT');

    // Determine Archetype
    String archetypeTag;
    String archetypeIcon;
    String briefingText;
    VerdictSignal primaryCatalyst;
    VerdictSignal primaryRisk;
    TacticalPlaybook playbook;

    if (isPsu && fsPct >= 0.65) {
      if (techPct < 0.60) {
        archetypeTag = 'Sovereign Asset in Consolidation';
        archetypeIcon = '🏛️';
        briefingText = score.analystVerdict?.trim().isNotEmpty == true
            ? score.analystVerdict!.trim()
            : '$displayName demonstrates exceptional balance sheet solvency (${score.financialStrength}/25) backed by sovereign infrastructure patronage. Current sideways price action reflects healthy long-term base building following multi-quarter order-book expansion.';
        primaryCatalyst = VerdictSignal(
          title: 'Sovereign Moat & Financial Solvency',
          description:
              'Protected borrowing spreads and critical national infrastructure mandates provide an institutional safety net.',
          scoreLabel: '${score.financialStrength}/25 FS',
          isPositive: true,
        );
        primaryRisk = VerdictSignal(
          title: 'Technical Momentum Consolidation',
          description:
              'Price remains in a supply-absorption range (${score.technical}/10 Tech); breakout requires institutional volume expansion.',
          scoreLabel: '${score.technical}/10 Tech',
          isPositive: false,
        );
        playbook = TacticalPlaybook(
          existingHoldersGuideline: isOwned
              ? 'Currently in your portfolio. Hold firmly through base-building. Sovereign backing and clean solvency (${score.financialStrength}/25 FS) provide high downside protection; avoid panic selling.'
              : 'Core sovereign infrastructure holding. Established holders should hold firmly; sovereign backing provides strong downside protection.',
          freshCapitalGuideline: isOwned
              ? 'Position already established. Only add incrementally in defined technical support bands rather than chasing impulsive intraday spikes.'
              : 'Accumulate systematically in defined support bands rather than chasing impulsive intraday moves.',
          keyMonitorable:
              'Government capex budget releases and quarterly order backlog execution rate.',
        );
      } else {
        archetypeTag = 'Sovereign Capex & Momentum Beneficiary';
        archetypeIcon = '⚡';
        briefingText = score.analystVerdict?.trim().isNotEmpty == true
            ? score.analystVerdict!.trim()
            : '$displayName is benefiting from sustained institutional sponsorship and national capex tailwinds. Robust technical momentum (${score.technical}/10) is firmly supported by clean balance-sheet solvency (${score.financialStrength}/25).';
        primaryCatalyst = VerdictSignal(
          title: 'Institutional Order Inflow & Momentum',
          description:
              'Multi-year order book visibility backed by persistent delivery-based institutional accumulation.',
          scoreLabel: '${score.technical}/10 Tech',
          isPositive: true,
        );
        primaryRisk = VerdictSignal(
          title: 'Execution Cadence & Valuation Multiple',
          description:
              'Valuation multiple (${score.valuation}/15) requires flawless quarterly execution without project delays.',
          scoreLabel: '${score.valuation}/15 Val',
          isPositive: false,
        );
        playbook = TacticalPlaybook(
          existingHoldersGuideline: isOwned
              ? 'Currently generating strong alpha in your portfolio. Hold with a trailing stop-loss below the 50-day EMA to let compounding run.'
              : 'Hold with a trailing stop-loss below the 50-day EMA. Allow compounding trend to run.',
          freshCapitalGuideline: isOwned
              ? 'Maintain existing allocation cap; pyramid cautiously only on mild 2-3% pullbacks towards the 20-day EMA.'
              : 'Stagger entries in tranches; avoid lump-sum buying during gap-up breakout sessions.',
          keyMonitorable:
              'New order award announcements and operating EBITDA margin defense.',
        );
      }
    } else if (bqPct >= 0.72 && fsPct >= 0.72) {
      if (valPct <= 0.45) {
        archetypeTag = 'High-Moat Quality (Valuation Squeeze)';
        archetypeIcon = '💎';
        briefingText = score.analystVerdict?.trim().isNotEmpty == true
            ? score.analystVerdict!.trim()
            : '$displayName commands elite business quality (${score.businessQuality}/25) with top-quartile return metrics and fortress solvency (${score.financialStrength}/25). However, elevated market multiples leave limited cushion for execution slippage.';
        primaryCatalyst = VerdictSignal(
          title: 'Industry-Leading Return Ratios & Moat',
          description:
              'Superior capital efficiency, robust pricing power, and consistent operating cash flow generation.',
          scoreLabel: '${score.businessQuality}/25 BQ',
          isPositive: true,
        );
        primaryRisk = VerdictSignal(
          title: 'Rich Valuation Re-rating Friction',
          description:
              'Priced for growth perfection (${score.valuation}/15 Val); any quarterly moderation could trigger multiple contraction.',
          scoreLabel: '${score.valuation}/15 Val',
          isPositive: false,
        );
        playbook = TacticalPlaybook(
          existingHoldersGuideline: isOwned
              ? 'Core portfolio compounder. Maintain high holding conviction through cyclical valuation digestion; do not attempt aggressive market timing.'
              : 'Core portfolio compounder. Continue holding through cyclical volatility; do not attempt aggressive timing.',
          freshCapitalGuideline: isOwned
              ? 'Position already active. Maintain weight and add incrementally only during sector-wide drawdowns for superior margin of safety.'
              : 'Look for market-wide pullbacks or earnings dips to establish initial positions with an improved margin of safety.',
          keyMonitorable:
              'Quarterly EBITDA margin sustainability and free cash flow conversion efficiency.',
        );
      } else {
        archetypeTag = 'High-Moat Compounder at Fair Value';
        archetypeIcon = '🚀';
        briefingText = score.analystVerdict?.trim().isNotEmpty == true
            ? score.analystVerdict!.trim()
            : '$displayName combines top-decile operational quality (${score.businessQuality}/25), pristine financial health (${score.financialStrength}/25), and sensible entry valuation (${score.valuation}/15). An institutional core compounder candidate.';
        primaryCatalyst = VerdictSignal(
          title: 'Durable Moat & Capital Efficiency',
          description:
              'High ROCE supported by conservative debt structure and clear competitive industry dominance.',
          scoreLabel: '${score.businessQuality}/25 BQ',
          isPositive: true,
        );
        primaryRisk = VerdictSignal(
          title: 'Macro Sector Rotation & Beta Sensitivity',
          description:
              'Short-term price action remains subject to broader market liquidity rather than company-specific degradation.',
          scoreLabel: '${score.risk}/5 Risk',
          isPositive: false,
        );
        playbook = TacticalPlaybook(
          existingHoldersGuideline: isOwned
              ? 'Anchor holding in your portfolio. High capital return efficiency and robust balance sheet warrant patient multi-year compounding.'
              : 'Maintain strong holding conviction. High-quality long-term compounder suitable for core weighting.',
          freshCapitalGuideline: isOwned
              ? 'Favorable setup to incrementally expand portfolio weighting during routine base consolidations.'
              : 'Favorable risk-reward profile for progressive accumulation at current market levels.',
          keyMonitorable:
              'Sustained market share expansion and incremental return on invested capital.',
        );
      }
    } else if (valPct <= 0.52 && techPct >= 0.60) {
      archetypeTag = 'Valuation vs Momentum Tug-of-War';
      archetypeIcon = '⚖️';
      briefingText = score.analystVerdict?.trim().isNotEmpty == true
          ? score.analystVerdict!.trim()
          : '$displayName is in an active tug-of-war: technical trend momentum (${score.technical}/10) remains resilient, but elevated earnings valuation (${score.valuation}/15) caps upside velocity without accelerating profit growth.';
      primaryCatalyst = VerdictSignal(
        title: 'Technical Momentum & Relative Strength',
        description:
          'Buyers consistently defending intermediate moving average supports with constructive price action.',
        scoreLabel: '${score.technical}/10 Tech',
        isPositive: true,
      );
      primaryRisk = VerdictSignal(
        title: 'Valuation Multiple Drag',
        description:
          'Premium multiples (${score.valuation}/15 Val) leave minimal buffer for quarterly earnings surprises.',
        scoreLabel: '${score.valuation}/15 Val',
        isPositive: false,
      );
      playbook = TacticalPlaybook(
        existingHoldersGuideline: isOwned
            ? 'Held in your portfolio. Protect accumulated gains with a trailing stop-loss below key support. Consider trimming into parabolic momentum spikes.'
            : 'Hold with a disciplined trailing stop-loss below key support. Consider partial profit booking on momentum spikes.',
        freshCapitalGuideline: isOwned
            ? 'Avoid increasing position weight at premium multiples until valuation consolidates.'
            : 'Wait for a consolidation base or valuation pullback before committing significant fresh capital.',
        keyMonitorable:
          'Quarterly revenue guidance revisions and operating profit margin trajectory.',
      );
    } else if (valPct >= 0.70 && techPct <= 0.45) {
      archetypeTag = 'Undervalued Mean-Reversion Play';
      archetypeIcon = '📉';
      briefingText = score.analystVerdict?.trim().isNotEmpty == true
          ? score.analystVerdict!.trim()
          : '$displayName trades at an attractive valuation multiple (${score.valuation}/15) offering significant margin of safety. While technical momentum (${score.technical}/10) is currently subdued, downside appears structurally cushioned.';
      primaryCatalyst = VerdictSignal(
        title: 'Valuation Margin of Safety',
        description:
          'Deep discount to intrinsic historical averages creates an asymmetric risk-reward setup.',
        scoreLabel: '${score.valuation}/15 Val',
        isPositive: true,
      );
      primaryRisk = VerdictSignal(
        title: 'Technical Trend Inertia',
        description:
          'Extended base building may test investor patience until fresh institutional volume triggers a breakout.',
        scoreLabel: '${score.technical}/10 Tech',
        isPositive: false,
      );
      playbook = TacticalPlaybook(
        existingHoldersGuideline: isOwned
            ? 'Currently held in your portfolio. Downside is structurally cushioned at these multiples; resist panic-selling at cyclical bottoms.'
            : 'Do not panic exit at discounted valuations. Allow mean-reversion cycle to mature.',
        freshCapitalGuideline: isOwned
            ? 'Disciplined dollar-cost averaging can be utilized if balance sheet solvency remains intact.'
            : 'Value investors can begin staggered accumulation; momentum traders should await trendline confirmation.',
        keyMonitorable:
          'Institutional delivery volumes crossing above the 20-day average.',
      );
    } else if (techPct >= 0.80 && grPct >= 0.65) {
      archetypeTag = 'High-Beta Momentum Outperformer';
      archetypeIcon = '🔥';
      briefingText = score.analystVerdict?.trim().isNotEmpty == true
          ? score.analystVerdict!.trim()
          : '$displayName is in an aggressive upward impulse, powered by accelerating quarterly growth (${score.growth}/20) and bullish technical alignment (${score.technical}/10). Strong institutional volume sponsorship is evident.';
      primaryCatalyst = VerdictSignal(
        title: 'Growth Acceleration & Price Impulse',
        description:
          'Expanding earnings delivery paired with multi-timeframe moving average breakouts.',
        scoreLabel: '${score.technical}/10 Tech',
        isPositive: true,
      );
      primaryRisk = VerdictSignal(
        title: 'High Volatility & Profit-Taking Flushes',
        description:
          'Stretched momentum makes the stock vulnerable to sharp, sudden mean-reverting pullbacks.',
        scoreLabel: '${score.risk}/5 Risk',
        isPositive: false,
      );
      playbook = TacticalPlaybook(
        existingHoldersGuideline: isOwned
            ? 'Riding strong momentum in your portfolio. Protect capital with a dynamic trailing stop along the 20-day EMA; trim small portions into extreme parabolic candles.'
            : 'Ride the momentum with trailing stop-loss along the 20-day EMA. Trim small portions into extreme parabolic candles.',
        freshCapitalGuideline: isOwned
            ? 'Hold current position size; avoid chasing extended green candles with fresh capital.'
            : 'Enter strictly on retests of the 20/50 EMA; never chase extended green candles.',
        keyMonitorable:
          'Volume dry-up during corrective pullbacks vs expansion during upward breaks.',
      );
    } else if ((score.overallScore ?? 0) >= 50) {
      archetypeTag = 'Balanced Mid-Cycle Consolidator';
      archetypeIcon = '📊';
      briefingText = score.analystVerdict?.trim().isNotEmpty == true
          ? score.analystVerdict!.trim()
          : '$displayName exhibits a balanced profile in $resolvedSector with stable baseline operations (${score.businessQuality}/25 BQ). Ongoing business execution is steady, but clear catalytic triggers are required for decisive re-rating.';
      primaryCatalyst = VerdictSignal(
        title: 'Operational Baseline in $resolvedSector',
        description:
          'Consistent revenue model with established client relationships and solvent financial footing.',
        scoreLabel: '${score.businessQuality}/25 BQ',
        isPositive: true,
      );
      primaryRisk = VerdictSignal(
        title: 'Growth Velocity Headwind',
        description:
          'Growth cadence (${score.growth}/20) tracks sector averages rather than commanding market-share capture.',
        scoreLabel: '${score.growth}/20 Growth',
        isPositive: false,
      );
      playbook = TacticalPlaybook(
        existingHoldersGuideline: isOwned
            ? 'Held in portfolio. Maintain position weight but monitor upcoming quarterly earnings closely for operational inflection.'
            : 'Hold existing position. Rebalance if quarterly earnings fail to demonstrate sequential improvement.',
        freshCapitalGuideline: isOwned
            ? 'Maintain current position size without adding until catalytic growth emerges.'
            : 'Maintain neutral stance; compare risk-reward against higher-scoring sector alternatives.',
        keyMonitorable:
          'Working capital cycle compression and quarterly margin trend.',
      );
    } else {
      archetypeTag = 'Fundamental Compression & Elevated Risk';
      archetypeIcon = '⚠️';
      briefingText = score.analystVerdict?.trim().isNotEmpty == true
          ? score.analystVerdict!.trim()
          : '$displayName reflects elevated quantitative caution with an overall score of ${score.overallScore}/100. Subdued fundamentals or decelerating technical momentum suggest a disciplined capital preservation stance.';
      primaryCatalyst = VerdictSignal(
        title: 'Potential Operational Sunk-Cost Floor',
        description:
          'Low market expectations mean any decisive turnaround could establish an operational inflection bottom.',
        scoreLabel: '${score.valuation}/15 Val',
        isPositive: true,
      );
      primaryRisk = VerdictSignal(
        title: 'Fundamental Solvency & Momentum Drag',
        description:
          'Sub-par return metrics or balance-sheet leverage (${score.financialStrength}/25 FS) constrain institutional inflows.',
        scoreLabel: '${score.overallScore}/100 Overall',
        isPositive: false,
      );
      playbook = TacticalPlaybook(
        existingHoldersGuideline: isOwned
            ? 'Capital preservation alert: Currently in your portfolio. Strictly review position sizing; consider reallocating capital into higher-conviction compounders.'
            : 'Evaluate position sizing. Consider trimming or reallocating capital into higher-conviction compounders.',
        freshCapitalGuideline: isOwned
            ? 'Strictly avoid averaging down until verifiable operational turnaround is confirmed across consecutive quarters.'
            : 'Avoid fresh capital deployment until clear fundamental turnaround is verified across two consecutive quarters.',
        keyMonitorable:
          'Debt reduction announcements and operating cash flow positive inflection.',
      );
    }

    final compliantRec = SymbolUtils.toCompliantVerdict(score.recommendation).toUpperCase();

    String convictionLabel;
    if (compliantRec.contains('HIGH RISK') || compliantRec.contains('FLAG') || compliantRec.contains('AVOID')) {
      convictionLabel = 'Critical Risk Factor Breached';
    } else if (compliantRec.contains('BELOW HURDLE')) {
      convictionLabel = 'Below Hurdle Rate (ROCE < 8%)';
    } else if (compliantRec.contains('EXTENDED VALUE')) {
      convictionLabel = 'Valuation Multiple Overhang';
    } else if (compliantRec.contains('WAIT FOR DIP') || compliantRec.contains('DIP')) {
      convictionLabel = 'Consolidation / Base Setup';
    } else if (compliantRec.contains('ELEVATED VALUATION') || compliantRec.contains('TRIM')) {
      convictionLabel = 'Valuation Stretched / Consolidating';
    } else if (compliantRec.contains('NEUTRAL') || compliantRec.contains('WATCH')) {
      convictionLabel = 'Neutral / Quarterly Monitor';
    } else if ((score.overallScore ?? 0) >= 75) {
      convictionLabel = 'High Quantitative Factor Rank';
    } else if ((score.overallScore ?? 0) >= 60) {
      convictionLabel = 'Robust Factor Profile';
    } else if ((score.overallScore ?? 0) >= 45) {
      convictionLabel = 'Neutral Factor Profile';
    } else {
      convictionLabel = 'Defensive Risk Profile';
    }

    return VerdictNarrative(
      archetypeTag: archetypeTag,
      archetypeIcon: archetypeIcon,
      analystBriefing: briefingText,
      primaryCatalyst: primaryCatalyst,
      primaryRisk: primaryRisk,
      playbook: playbook,
      convictionLabel: convictionLabel,
    );
  }
}
