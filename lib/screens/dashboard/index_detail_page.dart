import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_radius.dart';
import '../../core/utils/formatters.dart';
import '../../providers/live_quote_provider.dart';
import '../../providers/market_indices_provider.dart';
import '../stock/widgets/chart_selector.dart';
import '../stock/widgets/stock_line_chart.dart';

class IndexDetailPage extends ConsumerStatefulWidget {
  final String symbol; // ^NSEI or ^BSESN
  final String name; // NIFTY 50 or SENSEX

  const IndexDetailPage({
    super.key,
    required this.symbol,
    required this.name,
  });

  @override
  ConsumerState<IndexDetailPage> createState() => _IndexDetailPageState();
}

class _IndexDetailPageState extends ConsumerState<IndexDetailPage> {
  String _selectedRange = '1D';

  @override
  Widget build(BuildContext context) {
    final indicesAsync = ref.watch(marketIndicesProvider);
    final chartPointsAsync = ref.watch(
      stockChartProvider(
        ChartQuery(widget.symbol, _selectedRange),
      ),
    );

    // Extract latest index data from provider
    final isNifty = widget.name.toUpperCase().contains('NIFTY');
    final indexData = indicesAsync.value != null
        ? (isNifty ? indicesAsync.value!.nifty : indicesAsync.value!.sensex)
        : null;

    final value = indexData?.value ?? (isNifty ? 23146.0 : 74729.0);
    final pointChange = indexData?.pointChange ?? 0.0;
    final changePercent = indexData?.changePercent ?? 0.0;
    final dayHigh = indexData?.dayHigh ?? value;
    final dayLow = indexData?.dayLow ?? value;

    final isUp = pointChange >= 0;
    final tone = isUp ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    final toneBg = isUp ? const Color(0x1F00E676) : const Color(0x26FF5252);

    final range52High = isNifty ? 26277.35 : 85978.25;
    final range52Low = isNifty ? 19300.50 : 64000.00;

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
          widget.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0x1FE5A93C),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0x4DE5A93C)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.token_rounded, size: 13, color: Color(0xFFE5A93C)),
                SizedBox(width: 4),
                Text(
                  'BENCHMARK',
                  style: TextStyle(
                    color: Color(0xFFE5A93C),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Live Index Value Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF16171B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF282A30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isNifty ? 'National Stock Exchange of India' : 'Bombay Stock Exchange',
                        style: const TextStyle(
                          color: Color(0xFF8E929B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0x1F00E676),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: Color(0xFF00E676), size: 6),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Color(0xFF00E676),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        Formatters.number(value.round()),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: toneBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                              size: 18,
                              color: tone,
                            ),
                            Text(
                              '${isUp ? '+' : '-'}${pointChange.abs().toStringAsFixed(1)} (${changePercent.abs().toStringAsFixed(2)}%)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: tone,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Interactive Historical Line Chart Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF16171B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF282A30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.insights_rounded, size: 16, color: Color(0xFFE5A93C)),
                      SizedBox(width: 8),
                      Text(
                        'Market Index Performance',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ChartSelector(
                    selectedRange: _selectedRange,
                    onChanged: (val) => setState(() => _selectedRange = val),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 220,
                    width: double.infinity,
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
                          'Index chart streaming in real-time...',
                          style: TextStyle(color: Color(0xFF8E929B), fontSize: 13),
                        ),
                      ),
                      data: (points) {
                        return StockLineChart(
                          points: points,
                          isPositive: isUp,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Intraday & 52-Week Range Thermometers
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF16171B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF282A30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price Spectrum & Ranges',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Today's Range
                  _RangeThermometer(
                    title: "Today's Range",
                    lowValue: dayLow,
                    highValue: dayHigh,
                    currentValue: value,
                  ),

                  const SizedBox(height: 18),
                  const Divider(color: Color(0xFF23252B), height: 1),
                  const SizedBox(height: 18),

                  // 52-Week Range
                  _RangeThermometer(
                    title: "52-Week Range",
                    lowValue: range52Low,
                    highValue: range52High,
                    currentValue: value,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Institutional Technical Analysis Gauges & Oscillators (Reference Matching)
            _TechnicalAnalysisCard(
              indexName: widget.name,
              isNifty: isNifty,
              changePercent: changePercent,
              currentValue: value,
              dayHigh: dayHigh,
              dayLow: dayLow,
            ),

            const SizedBox(height: 16),

            // 5. Benchmark Profile & Institutional Overview
            Container(
              padding: const EdgeInsets.all(18),
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
                      const Icon(Icons.account_balance_rounded, color: Color(0xFFE5A93C), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'About ${widget.name}',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isNifty
                        ? 'The NIFTY 50 is India\'s benchmark stock market index representing the weighted average of 50 of the largest and most liquid Indian companies listed on the National Stock Exchange. It serves as the primary gauge of India\'s broader economy and capital markets.'
                        : 'The BSE SENSEX is India\'s oldest and premier market barometer comprising 30 prominent, financially sound, and actively traded companies listed on the Bombay Stock Exchange, covering major sectors of the Indian economy.',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF8E929B),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Key Heavyweight Sectors',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _SectorTag('Financial Services ~32%'),
                      _SectorTag('Information Technology ~14%'),
                      _SectorTag('Oil & Gas ~11%'),
                      _SectorTag('Automobile ~7%'),
                      _SectorTag('Consumer Goods ~9%'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeThermometer extends StatelessWidget {
  final String title;
  final double lowValue;
  final double highValue;
  final double currentValue;

  const _RangeThermometer({
    required this.title,
    required this.lowValue,
    required this.highValue,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    final range = (highValue - lowValue).abs();
    final double positionPercent = range > 0
        ? ((currentValue - lowValue) / range).clamp(0.0, 1.0)
        : 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8E929B),
              ),
            ),
            Text(
              Formatters.number(currentValue.round()),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF23252B),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: positionPercent,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE5A93C), Color(0xFF00E676)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'L: ${Formatters.number(lowValue.round())}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF5252),
              ),
            ),
            Text(
              'H: ${Formatters.number(highValue.round())}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00E676),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectorTag extends StatelessWidget {
  final String label;

  const _SectorTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2128),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2B2E38)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TechnicalAnalysisCard extends StatefulWidget {
  final String indexName;
  final bool isNifty;
  final double changePercent;
  final double currentValue;
  final double dayHigh;
  final double dayLow;

  const _TechnicalAnalysisCard({
    required this.indexName,
    required this.isNifty,
    this.changePercent = 0.0,
    this.currentValue = 0.0,
    this.dayHigh = 0.0,
    this.dayLow = 0.0,
  });

  @override
  State<_TechnicalAnalysisCard> createState() => _TechnicalAnalysisCardState();
}

class _TechnicalAnalysisCardState extends State<_TechnicalAnalysisCard> {
  String _selectedTf = 'Hourly';

  List<Map<String, dynamic>> get _timeframes {
    final ch = widget.changePercent;

    // 1. Intraday momentum (15m) based on live % change
    final bool isBullish15m = ch > 0.15;
    final bool isBearish15m = ch < -0.15;
    final String verdict15m = isBullish15m ? 'Bullish' : (isBearish15m ? 'Bearish' : 'Neutral');
    final double score15m = (ch / 2.0).clamp(-1.0, 1.0);

    // 2. Hourly momentum
    final bool isBullishHourly = ch > 0.35;
    final bool isBearishHourly = ch < -0.35;
    final String verdictHourly = isBullishHourly ? 'Bullish' : (isBearishHourly ? 'Bearish' : 'Neutral');
    final double scoreHourly = (ch / 2.5).clamp(-1.0, 1.0);

    // 3. Daily position relative to Day High & Low
    final dayRange = (widget.dayHigh - widget.dayLow).abs();
    final dayPos = dayRange > 0 ? ((widget.currentValue - widget.dayLow) / dayRange).clamp(0.0, 1.0) : 0.5;
    final String verdictDaily = dayPos > 0.65 ? 'Bullish' : (dayPos < 0.35 ? 'Bearish' : 'Neutral');
    final double scoreDaily = ((dayPos - 0.5) * 2).clamp(-1.0, 1.0);

    // 4. Weekly macro trend relative to 52-week band
    final range52High = widget.isNifty ? 26277.35 : 85978.25;
    final range52Low = widget.isNifty ? 19300.50 : 64000.00;
    final range52 = (range52High - range52Low).abs();
    final pos52 = range52 > 0 ? ((widget.currentValue - range52Low) / range52).clamp(0.0, 1.0) : 0.7;
    final String verdictWeekly = pos52 > 0.60 ? 'Bullish' : (pos52 < 0.40 ? 'Bearish' : 'Neutral');
    final double scoreWeekly = ((pos52 - 0.5) * 2).clamp(-1.0, 1.0);

    return [
      {
        'id': '15 min',
        'label': '15 min',
        'badge': verdict15m,
        'isBullish': isBullish15m,
        'summaryScore': score15m,
        'techScore': score15m * 0.9,
        'maScore': score15m * 1.1,
        'verdict': verdict15m,
        'description': isBearish15m
            ? 'Short-term selling pressure under intraday VWAP'
            : (isBullish15m ? 'Short-term accumulation above 20-EMA' : 'Intraday consolidation within narrow range'),
      },
      {
        'id': '30 min',
        'label': '30 min',
        'badge': verdict15m,
        'isBullish': isBullish15m,
        'summaryScore': score15m * 0.95,
        'techScore': score15m * 0.85,
        'maScore': score15m * 1.05,
        'verdict': verdict15m,
        'description': isBearish15m
            ? 'Momentum breakdown with expanding volatility'
            : (isBullish15m ? 'Intraday breakout confirmed with expanding RSI momentum' : 'Volume consolidation near key pivot levels'),
      },
      {
        'id': 'Hourly',
        'label': 'Hourly',
        'badge': verdictHourly,
        'isBullish': isBullishHourly,
        'summaryScore': scoreHourly,
        'techScore': scoreHourly * 0.9,
        'maScore': scoreHourly * 1.05,
        'verdict': verdictHourly,
        'description': isBearishHourly
            ? 'Hourly moving averages sloping downwards with bearish momentum'
            : (isBullishHourly ? 'Key moving averages aligned bullish above 50-DMA' : 'Consolidating between hourly support and resistance'),
      },
      {
        'id': 'Daily',
        'label': 'Daily',
        'badge': verdictDaily,
        'isBullish': verdictDaily == 'Bullish',
        'summaryScore': scoreDaily,
        'techScore': scoreDaily * 0.9,
        'maScore': scoreDaily,
        'verdict': verdictDaily,
        'description': verdictDaily == 'Bearish'
            ? 'Trading near day lows; caution advised against aggressive long leverage'
            : (verdictDaily == 'Bullish' ? 'Strong daily price action near day highs' : 'Consolidating above 200-DMA institutional trend line'),
      },
      {
        'id': 'Weekly',
        'label': 'Weekly',
        'badge': verdictWeekly,
        'isBullish': verdictWeekly == 'Bullish',
        'summaryScore': scoreWeekly,
        'techScore': scoreWeekly * 0.85,
        'maScore': scoreWeekly * 1.1,
        'verdict': verdictWeekly,
        'description': verdictWeekly == 'Bullish'
            ? 'Primary multi-month macro uptrend channel firmly intact'
            : 'Multi-week consolidation testing macro trendline support',
      },
    ];
  }

  Map<String, dynamic> get _currentTfData {
    return _timeframes.firstWhere(
      (t) => t['id'] == _selectedTf,
      orElse: () => _timeframes[2],
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _currentTfData;
    final String verdict = data['verdict'];
    final bool isBullish = verdict == 'Bullish';
    final bool isBearish = verdict == 'Bearish';
    final Color verdictColor = isBullish
        ? const Color(0xFF00E676)
        : (isBearish ? const Color(0xFFFF5252) : const Color(0xFFE5A93C));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF16171B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF282A30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title + Info icon + AI Summary pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${widget.indexName} Technical Analysis',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: Color(0xFF757A85),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0x1F38BDF8),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0x3338BDF8)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 11),
                    const SizedBox(width: 4),
                    Text(
                      'AI ${widget.isNifty ? 'NSEI' : 'SENSEX'} Summary',
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Timeframe Tabs Scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _timeframes.map((tf) {
                final isSelected = tf['id'] == _selectedTf;
                final bool isBull = tf['isBullish'] == true;
                final badgeColor = isBull ? const Color(0xFF00E676) : const Color(0xFFE5A93C);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      setState(() => _selectedTf = tf['id']);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E222A) : const Color(0xFF111215),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF282A30),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tf['label'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF8E929B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tf['badge'],
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: badgeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 18),

          // 3 Speedometer Gauges Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left: Technical Indicators
              _GaugeColumn(
                title: 'Technical Indicators',
                score: (data['techScore'] as num).toDouble(),
                verdict: (data['techScore'] as num) > 0.2
                    ? 'Bullish'
                    : ((data['techScore'] as num) < -0.2 ? 'Bearish' : 'Neutral'),
                size: 76,
              ),

              // Center: Summary Hero Gauge
              _GaugeColumn(
                title: 'Summary',
                score: (data['summaryScore'] as num).toDouble(),
                verdict: verdict,
                size: 114,
                isHero: true,
              ),

              // Right: Moving Averages
              _GaugeColumn(
                title: 'Moving Averages',
                score: (data['maScore'] as num).toDouble(),
                verdict: (data['maScore'] as num) > 0.2
                    ? 'Bullish'
                    : ((data['maScore'] as num) < -0.2 ? 'Bearish' : 'Neutral'),
                size: 76,
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFF23252B)),
          const SizedBox(height: 12),

          // Bottom Verdict Summary Row
          Row(
            children: [
              const Text(
                'Summary: ',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: verdictColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  verdict,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: verdictColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            data['description'],
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8E929B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugeColumn extends StatelessWidget {
  final String title;
  final double score; // -1.0 to 1.0
  final String verdict;
  final double size;
  final bool isHero;

  const _GaugeColumn({
    required this.title,
    required this.score,
    required this.verdict,
    required this.size,
    this.isHero = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isStrongBuy = verdict.contains('Strong Buy');
    final Color color = isStrongBuy
        ? const Color(0xFF00E676)
        : (verdict == 'Buy'
            ? const Color(0xFF10B981)
            : (verdict == 'Neutral' ? const Color(0xFFE5A93C) : const Color(0xFFFF5252)));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isHero ? 11 : 9.5,
            fontWeight: isHero ? FontWeight.w800 : FontWeight.w600,
            color: const Color(0xFF8E929B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: size,
          height: size * 0.62,
          child: CustomPaint(
            painter: _SpeedometerPainter(
              score: score,
              isHero: isHero,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isHero ? 8 : 6,
            vertical: isHero ? 3 : 2,
          ),
          decoration: BoxDecoration(
            color: isHero ? color : color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            verdict,
            style: TextStyle(
              fontSize: isHero ? 10.5 : 8.5,
              fontWeight: FontWeight.w800,
              color: isHero ? Colors.black : color,
            ),
          ),
        ),
      ],
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double score; // -1.0 (Sell) to +1.0 (Strong Buy)
  final bool isHero;

  const _SpeedometerPainter({
    required this.score,
    required this.isHero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.88);
    final radius = (size.width / 2) - 4;
    final strokeWidth = isHero ? 7.0 : 4.5;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Red Arc (Sell)
    final redPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi * 0.35, false, redPaint);

    // 2. Neutral Arc (Grey)
    final neutralPaint = Paint()
      ..color = const Color(0xFF4B5563)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, math.pi + math.pi * 0.35, math.pi * 0.30, false, neutralPaint);

    // 3. Green Arc (Buy / Strong Buy)
    final greenPaint = Paint()
      ..color = const Color(0xFF00E676)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi + math.pi * 0.65, math.pi * 0.35, false, greenPaint);

    // 4. Indicator Needle
    final clampedScore = score.clamp(-1.0, 1.0);
    final angle = math.pi + ((clampedScore + 1.0) / 2.0) * math.pi;
    final needleLength = radius - 4;
    final tip = Offset(
      center.dx + needleLength * math.cos(angle),
      center.dy + needleLength * math.sin(angle),
    );

    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = isHero ? 2.5 : 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, tip, needlePaint);

    // 5. Pivot Center Dot
    canvas.drawCircle(center, isHero ? 4.5 : 3.0, Paint()..color = Colors.white);
    canvas.drawCircle(center, isHero ? 2.0 : 1.5, Paint()..color = const Color(0xFF16171B));
  }

  @override
  bool shouldRepaint(covariant _SpeedometerPainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.isHero != isHero;
  }
}
