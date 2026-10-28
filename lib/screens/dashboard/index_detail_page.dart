
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/indicators.dart';
import '../../core/utils/market_hours.dart';
import '../../providers/live_quote_provider.dart';
import '../../services/market_quote_service.dart';
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

    // No made-up level while loading or when unavailable: value 0 shows as a dash
    final value = indexData?.value ?? 0.0;
    final hasValue = value > 0;
    final marketOpen = isMarketOpenIst(DateTime.now());
    final history = ref.watch(dailyHistoryProvider(widget.symbol));
    final hist = history.value;
    final pointChange = indexData?.pointChange ?? 0.0;
    final changePercent = indexData?.changePercent ?? 0.0;
    final dayHigh = indexData?.dayHigh ?? value;
    final dayLow = indexData?.dayLow ?? value;

    final isUp = pointChange >= 0;
    final tone = isUp ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    final toneBg = isUp ? const Color(0x1F00E676) : const Color(0x26FF5252);


    // Wide screens: same centered column as the rest of the app; padding (not a
    // box) so the whole page still scrolls.
    final width = MediaQuery.sizeOf(context).width;
    final side = width > Breakpoints.contentMaxWidth + 48
        ? (width - Breakpoints.contentMaxWidth) / 2
        : (Breakpoints.isDesktop(context) ? 24.0 : 16.0);

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
        padding: EdgeInsets.fromLTRB(side, 8, side, 32),
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
                          color: (hasValue && marketOpen ? const Color(0xFF00E676) : const Color(0xFF8E929B))
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle,
                                color: hasValue && marketOpen ? const Color(0xFF00E676) : const Color(0xFF8E929B),
                                size: 6),
                            const SizedBox(width: 4),
                            Text(
                              !hasValue ? 'UNAVAILABLE' : (marketOpen ? 'LIVE' : 'MARKET CLOSED'),
                              style: TextStyle(
                                color: hasValue && marketOpen ? const Color(0xFF00E676) : const Color(0xFF8E929B),
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
                        hasValue ? Formatters.number(value.round()) : '—',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (hasValue)
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
                      error: (error, stack) => const Center(
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
                  if (hasValue)
                    _RangeThermometer(
                      title: "Today's Range",
                      lowValue: dayLow,
                      highValue: dayHigh,
                      currentValue: value,
                    )
                  else
                    const Text("Today's range unavailable",
                        style: TextStyle(fontSize: 12, color: Color(0xFF8E929B))),

                  const SizedBox(height: 18),
                  const Divider(color: Color(0xFF23252B), height: 1),
                  const SizedBox(height: 18),

                  // 52-Week Range from Yahoo's daily history (never a fixed number)
                  if (hasValue && hist?.high52 != null && hist?.low52 != null)
                    _RangeThermometer(
                      title: "52-Week Range",
                      lowValue: hist!.low52!,
                      highValue: hist.high52!,
                      currentValue: value,
                    )
                  else
                    Text(
                      history.isLoading ? '52-week range loading…' : '52-week range unavailable',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF8E929B)),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Institutional Technical Analysis Gauges & Oscillators (Reference Matching)
            _IndicatorCard(history: history, currentValue: value),

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
                    'Largest sectors in the index',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Names only: exact weights change every month and we have no live source for them
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _SectorTag('Financial Services'),
                      _SectorTag('Information Technology'),
                      _SectorTag('Oil & Gas'),
                      _SectorTag('Automobile'),
                      _SectorTag('Consumer Goods'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isNifty
                        ? 'Current sector weights are in the monthly NIFTY 50 factsheet on niftyindices.com.'
                        : 'Current sector weights are in the BSE SENSEX factsheet on bseindia.com.',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF8E929B)),
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

/// Technical indicators computed from one year of daily closes (Yahoo). Replaces the earlier
/// card whose "Bullish / Bearish" labels were derived only from today's % change.
class _IndicatorCard extends StatelessWidget {
  final AsyncValue<DailyHistory?> history;
  final double currentValue;

  const _IndicatorCard({required this.history, required this.currentValue});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Text(
            'Technical Indicators',
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'Calculated from daily closing prices over the last year.',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF8E929B)),
          ),
          const SizedBox(height: 14),
          ...history.when(
            loading: () => [_note('Loading daily prices…')],
            error: (_, _) => [_note('Indicators unavailable right now.')],
            data: (h) => _rows(h),
          ),
        ],
      ),
    );
  }

  List<Widget> _rows(DailyHistory? h) {
    if (h == null || h.closes.length < 15) return [_note('Indicators unavailable right now.')];
    final closes = h.closes;
    final price = currentValue > 0 ? currentValue : closes.last;
    final rows = <Widget>[];
    void average(String label, double? avg) {
      if (avg == null) return;
      final above = price >= avg;
      rows.add(_row(label, Formatters.number(avg.round()), above ? 'Price above' : 'Price below', above));
    }

    average('20-day EMA', Indicators.ema(closes, 20));
    average('50-day average', Indicators.sma(closes, 50));
    average('200-day average', Indicators.sma(closes, 200));
    final rsi = Indicators.rsi(closes);
    if (rsi != null) {
      final state = rsi >= 70 ? 'Overbought zone (70+)' : (rsi <= 30 ? 'Oversold zone (30-)' : 'Neutral zone');
      rows.add(_row('RSI (14 days)', rsi.toStringAsFixed(1), state, null));
    }
    return rows.isEmpty ? [_note('Not enough daily prices yet.')] : rows;
  }

  static Widget _note(String text) =>
      Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF8E929B)));

  /// [positive] colours the status: true green, false red, null neutral
  static Widget _row(String label, String value, String status, bool? positive) {
    final color = positive == null
        ? const Color(0xFFC7CDD6)
        : (positive ? const Color(0xFF00E676) : const Color(0xFFFF5252));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          Text(value, style: const TextStyle(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          SizedBox(
            width: 140,
            child: Text(
              status,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11.5, color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

