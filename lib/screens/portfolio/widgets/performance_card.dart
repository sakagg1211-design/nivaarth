import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/performance_series.dart';
import '../../../providers/portfolio_performance_provider.dart';
import '../../../core/l10n/l10n_ext.dart';

const _surface = Color(0xFF16171B);
const _muted = Color(0xFF8E929B);
const _niftyLine = Colors.white54;

String _pct(double v) => '${v > 0 ? '+' : ''}${v.toStringAsFixed(2)}%';
final _date = DateFormat('d MMM yyyy');

/// Today's holdings carried back against Nifty. Percentages only, so Privacy Mode has nothing to mask.
class PerformanceCard extends ConsumerStatefulWidget {
  const PerformanceCard({super.key});

  @override
  ConsumerState<PerformanceCard> createState() => _PerformanceCardState();
}

class _PerformanceCardState extends ConsumerState<PerformanceCard> {
  PerformanceRange _range = PerformanceRange.all;

  @override
  Widget build(BuildContext context) {
    final series = ref.watch(portfolioPerformanceProvider).valueOrNull;
    if (series == null || !series.hasEnough) return const SizedBox.shrink();
    final ranges = series.ranges;
    final range = ranges.contains(_range) ? _range : PerformanceRange.all;
    final points = series.slice(range);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Portfolio vs Nifty',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(context.t.perfBackcast,
              style: TextStyle(color: _muted, fontSize: 12)),
          Row(
            children: [
              for (final r in ranges)
                _RangeChip(r.label, selected: r == range, onTap: () => setState(() => _range = r)),
            ],
          ),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              _Legend('Portfolio ${_pct(points.last.portfolio)}', color: AppColors.accent, textColor: Colors.white),
              _Legend('Nifty (NIFTYBEES) ${_pct(points.last.nifty)}',
                  color: _niftyLine, textColor: Colors.white70, dashed: true),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(height: 200, child: _Chart(points)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_date.format(points.first.date), style: const TextStyle(color: _muted, fontSize: 11)),
              Text(_date.format(points.last.date), style: const TextStyle(color: _muted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Text(context.t.perfFooter(_date.format(points.last.date)),
              style: const TextStyle(color: _muted, fontSize: 11)),
          if (series.partial) ...[
            const SizedBox(height: 4),
            Text(context.t.perfPartial,
                style: TextStyle(color: _muted, fontSize: 11)),
          ],
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RangeChip(this.label, {required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: selected ? Colors.white.withValues(alpha: .12) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(label,
                style: TextStyle(
                  color: selected ? Colors.white : _muted,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                )),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final bool dashed;
  const _Legend(this.text, {required this.color, required this.textColor, this.dashed = false});

  @override
  Widget build(BuildContext context) {
    Widget dash(double width) => Container(width: width, height: 2, color: color);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dashed) ...[dash(6), const SizedBox(width: 3), dash(6)] else dash(15),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w700))),
      ],
    );
  }
}

class _Chart extends StatelessWidget {
  final List<PerformancePoint> points;
  const _Chart(this.points);

  // Round axis steps so the labels read as 5%, 10%, 20% and so on
  static double _step(double span) {
    for (final s in const [1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0]) {
      if (span / s <= 4) return s;
    }
    return 200;
  }

  @override
  Widget build(BuildContext context) {
    final values = points.expand((p) => [p.portfolio, p.nifty]);
    final low = math.min(0.0, values.reduce(math.min));
    final high = math.max(0.0, values.reduce(math.max));
    final step = _step(high - low);
    final minY = (low / step).floorToDouble() * step;
    final maxY = math.max((high / step).ceilToDouble() * step, minY + step);

    List<FlSpot> spots(double Function(PerformancePoint) value) =>
        [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), value(points[i]))];

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: step,
          getDrawingHorizontalLine: (_) => FlLine(color: Colors.white.withValues(alpha: .05), strokeWidth: 1),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [HorizontalLine(y: 0, color: Colors.white.withValues(alpha: .25), strokeWidth: 1)],
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: step,
              getTitlesWidget: (v, meta) => SideTitleWidget(
                meta: meta,
                child: Text('${v.round()}%', style: const TextStyle(color: _muted, fontSize: 10)),
              ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchSpotThreshold: 100000,
          getTouchLineEnd: (_, _) => maxY,
          getTouchedSpotIndicator: (bar, indexes) => indexes
              .map((_) => TouchedSpotIndicatorData(
                    FlLine(color: Colors.white.withValues(alpha: .35), strokeWidth: 1, dashArray: const [3, 3]),
                    FlDotData(
                      getDotPainter: (spot, percent, b, i) => FlDotCirclePainter(
                        radius: 4,
                        color: b.color ?? Colors.white,
                        strokeWidth: 2,
                        strokeColor: _surface,
                      ),
                    ),
                  ))
              .toList(),
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (_) => const Color(0xFF1E2026),
            getTooltipItems: (spots) => [
              for (final s in spots)
                LineTooltipItem(
                  // The date heads whichever line the chart lists first
                  '${identical(s, spots.first) ? '${_date.format(points[s.x.toInt()].date)}\n' : ''}'
                  '${s.barIndex == 0 ? 'Portfolio' : 'Nifty'} ${_pct(s.y)}',
                  const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots((p) => p.portfolio),
            color: AppColors.accent,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: spots((p) => p.nifty),
            color: _niftyLine,
            barWidth: 2,
            dashArray: const [5, 4],
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
