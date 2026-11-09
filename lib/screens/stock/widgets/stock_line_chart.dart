import '../../../core/utils/formatters.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/chart_point.dart';
import '../../../core/l10n/l10n_ext.dart';

/// Date text for the crosshair, at the precision the selected range has.
String chartDateLabel(DateTime time, String range) {
  switch (range.toUpperCase()) {
    case '1D':
      return DateFormat('h:mm a').format(time);
    case '1W':
      return DateFormat('d MMM, h:mm a').format(time);
    case 'ALL':
      return DateFormat('MMM yyyy').format(time);
    default:
      return DateFormat('d MMM yyyy').format(time);
  }
}

/// Volume in lakh/crore style (12.3L, 1.5Cr).
String chartVolumeLabel(int volume) => NumberFormat.compact(locale: 'en_IN').format(volume);

class StockLineChart extends StatelessWidget {
  final List<ChartPoint> series;
  final bool isPositive;
  final String range;

  const StockLineChart({
    super.key,
    required this.series,
    required this.isPositive,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    if (series.length < 2) {
      return Center(
        child: Text(
          context.t.chartUpdating,
          style: TextStyle(color: Color(0xFF8E929B), fontSize: 13),
        ),
      );
    }

    final closes = series.map((p) => p.close).toList();
    double minY = closes.reduce((a, b) => a < b ? a : b);
    double maxY = closes.reduce((a, b) => a > b ? a : b);

    // Give a little breathing room on top and bottom
    final padding = (maxY - minY) * 0.08;
    if (padding > 0) {
      minY -= padding;
      maxY += padding;
    } else {
      minY *= 0.98;
      maxY *= 1.02;
    }

    final chartColor = isPositive ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    final spots = <FlSpot>[];
    for (int i = 0; i < series.length; i++) {
      spots.add(FlSpot(i.toDouble(), series[i].close));
    }

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          // Always land on the nearest bar, however few bars the range has
          touchSpotThreshold: 100000,
          getTouchLineEnd: (_, _) => maxY,
          getTouchedSpotIndicator: (bar, indexes) => indexes
              .map((_) => TouchedSpotIndicatorData(
                    FlLine(color: Colors.white.withValues(alpha: .35), strokeWidth: 1, dashArray: const [3, 3]),
                    FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, b, i) => FlDotCirclePainter(
                        radius: 4,
                        color: chartColor,
                        strokeWidth: 2,
                        strokeColor: const Color(0xFF16171B),
                      ),
                    ),
                  ))
              .toList(),
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (_) => const Color(0xFF1E2026),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final p = series[spot.x.toInt()];
                return LineTooltipItem(
                  '${Formatters.currency(p.close)}\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                  children: [
                    TextSpan(
                      text: chartDateLabel(p.time, range),
                      style: const TextStyle(color: Color(0xFF8E929B), fontWeight: FontWeight.w500, fontSize: 11),
                    ),
                    if (p.volume > 0)
                      TextSpan(
                        text: '\nVol ${chartVolumeLabel(p.volume)}',
                        style: const TextStyle(color: Color(0xFF8E929B), fontWeight: FontWeight.w500, fontSize: 11),
                      ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            color: chartColor,
            barWidth: 2.2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  chartColor.withValues(alpha: 0.28),
                  chartColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
