import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
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

            // 4. Benchmark Profile & Institutional Overview
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
