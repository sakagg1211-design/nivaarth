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
            : '$resolvedName ($cleanSym) operates as an institutional-grade passive investment vehicle tracking $resolvedSector. Backed by underlying physical assets or index baskets, it eliminates single-company credit and governance risks while providing essential macroeconomic hedging.',
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
            : '$resolvedName ($cleanSym) demonstrates exceptional balance sheet solvency (${score.financialStrength}/25) backed by sovereign infrastructure patronage. Current sideways price action reflects healthy long-term base building following multi-quarter order-book expansion.';
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
          existingHoldersGuideline:
              'Hold firmly. Sovereign backing and strong balance sheet provide high downside protection. Avoid panic selling.',
          freshCapitalGuideline:
              'Accumulate systematically in defined support bands rather than chasing impulsive intraday moves.',
          keyMonitorable:
              'Government capex budget releases and quarterly order backlog execution rate.',
        );
      } else {
        archetypeTag = 'Sovereign Capex & Momentum Beneficiary';
        archetypeIcon = '⚡';
        briefingText = score.analystVerdict?.trim().isNotEmpty == true
            ? score.analystVerdict!.trim()
            : '$resolvedName ($cleanSym) is benefiting from sustained institutional sponsorship and national capex tailwinds. Robust technical momentum (${score.technical}/10) is firmly supported by clean balance-sheet solvency (${score.financialStrength}/25).';
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
          existingHoldersGuideline:
              'Hold with a trailing stop-loss below the 50-day EMA. Allow compounding trend to run.',
          freshCapitalGuideline:
              'Stagger entries in tranches; avoid lump-sum buying during gap-up breakout sessions.',
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
            : '$resolvedName ($cleanSym) commands elite business quality (${score.businessQuality}/25) with top-quartile return metrics and fortress solvency (${score.financialStrength}/25). However, elevated market multiples leave limited cushion for execution slippage.';
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
          existingHoldersGuideline:
              'Core portfolio compounder. Continue holding through cyclical volatility; do not attempt aggressive timing.',
          freshCapitalGuideline:
              'Look for market-wide pullbacks or earnings dips to establish positions with an improved margin of safety.',
          keyMonitorable:
              'Quarterly EBITDA margin sustainability and free cash flow conversion efficiency.',
        );
      } else {
        archetypeTag = 'High-Moat Compounder at Fair Value';
        archetypeIcon = '🚀';
        briefingText = score.analystVerdict?.trim().isNotEmpty == true
            ? score.analystVerdict!.trim()
            : '$resolvedName ($cleanSym) combines top-decile operational quality (${score.businessQuality}/25), pristine financial health (${score.financialStrength}/25), and sensible entry valuation (${score.valuation}/15). An institutional core compounder candidate.';
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
          existingHoldersGuideline:
              'Maintain strong holding conviction. High-quality long-term compounder suitable for core weighting.',
          freshCapitalGuideline:
              'Favorable risk-reward profile for progressive accumulation at current market levels.',
          keyMonitorable:
              'Sustained market share expansion and incremental return on invested capital.',
        );
      }
    } else if (valPct <= 0.52 && techPct >= 0.60) {
      archetypeTag = 'Valuation vs Momentum Tug-of-War';
      archetypeIcon = '⚖️';
      briefingText = score.analystVerdict?.trim().isNotEmpty == true
          ? score.analystVerdict!.trim()
          : '$resolvedName ($cleanSym) is in an active tug-of-war: technical trend momentum (${score.technical}/10) remains resilient, but elevated earnings valuation (${score.valuation}/15) caps upside velocity without accelerating profit growth.';
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
        existingHoldersGuideline:
            'Hold with a disciplined trailing stop-loss below key support. Consider partial profit booking on momentum spikes.',
        freshCapitalGuideline:
            'Wait for a consolidation base or valuation pullback before committing significant fresh capital.',
        keyMonitorable:
            'Quarterly revenue guidance revisions and operating profit margin trajectory.',
      );
    } else if (valPct >= 0.70 && techPct <= 0.45) {
      archetypeTag = 'Undervalued Mean-Reversion Play';
      archetypeIcon = '📉';
      briefingText = score.analystVerdict?.trim().isNotEmpty == true
          ? score.analystVerdict!.trim()
          : '$resolvedName ($cleanSym) trades at an attractive valuation multiple (${score.valuation}/15) offering significant margin of safety. While technical momentum (${score.technical}/10) is currently subdued, downside appears structurally cushioned.';
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
        existingHoldersGuideline:
            'Do not panic exit at discounted valuations. Allow mean-reversion cycle to mature.',
        freshCapitalGuideline:
            'Value investors can begin staggered accumulation; momentum traders should await trendline confirmation.',
        keyMonitorable:
            'Institutional delivery volumes crossing above the 20-day average.',
      );
    } else if (techPct >= 0.80 && grPct >= 0.65) {
      archetypeTag = 'High-Beta Momentum Outperformer';
      archetypeIcon = '🔥';
      briefingText = score.analystVerdict?.trim().isNotEmpty == true
          ? score.analystVerdict!.trim()
          : '$resolvedName ($cleanSym) is in an aggressive upward impulse, powered by accelerating quarterly growth (${score.growth}/20) and bullish technical alignment (${score.technical}/10). Strong institutional volume sponsorship is evident.';
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
        existingHoldersGuideline:
            'Ride the momentum with trailing stop-loss along the 20-day EMA. Trim small portions into extreme parabolic candles.',
        freshCapitalGuideline:
            'Enter strictly on retests of the 20/50 EMA; never chase extended green candles.',
        keyMonitorable:
            'Volume dry-up during corrective pullbacks vs expansion during upward breaks.',
      );
    } else if (score.overallScore >= 50) {
      archetypeTag = 'Balanced Mid-Cycle Consolidator';
      archetypeIcon = '📊';
      briefingText = score.analystVerdict?.trim().isNotEmpty == true
          ? score.analystVerdict!.trim()
          : '$resolvedName ($cleanSym) exhibits a balanced profile in $resolvedSector with stable baseline operations (${score.businessQuality}/25 BQ). Ongoing business execution is steady, but clear catalytic triggers are required for decisive re-rating.';
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
        existingHoldersGuideline:
            'Hold existing position. Rebalance if quarterly earnings fail to demonstrate sequential improvement.',
        freshCapitalGuideline:
            'Maintain neutral stance; compare risk-reward against higher-scoring sector alternatives.',
        keyMonitorable:
            'Working capital cycle compression and quarterly margin trend.',
      );
    } else {
      archetypeTag = 'Fundamental Compression & Elevated Risk';
      archetypeIcon = '⚠️';
      briefingText = score.analystVerdict?.trim().isNotEmpty == true
          ? score.analystVerdict!.trim()
          : '$resolvedName ($cleanSym) reflects elevated quantitative caution with an overall score of ${score.overallScore}/100. Subdued fundamentals or decelerating technical momentum suggest a disciplined capital preservation stance.';
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
        existingHoldersGuideline:
            'Evaluate position sizing. Consider trimming or reallocating capital into higher-conviction compounders.',
        freshCapitalGuideline:
            'Avoid fresh capital deployment until clear fundamental turnaround is verified across two consecutive quarters.',
        keyMonitorable:
            'Debt reduction announcements and operating cash flow positive inflection.',
      );
    }

    String convictionLabel;
    if (score.overallScore >= 75) {
      convictionLabel = 'Institutional High-Conviction';
    } else if (score.overallScore >= 60) {
      convictionLabel = 'Institutional Accumulate';
    } else if (score.overallScore >= 45) {
      convictionLabel = 'Neutral Allocation';
    } else {
      convictionLabel = 'Defensive Risk Management';
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
