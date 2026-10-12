import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StockLineChart extends StatelessWidget {
  final List<double> points;
  final bool isPositive;

  const StockLineChart({
    super.key,
    required this.points,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return const Center(
        child: Text(
          'Chart updating...',
          style: TextStyle(color: Color(0xFF8E929B), fontSize: 13),
        ),
      );
    }

    double minY = points.reduce((a, b) => a < b ? a : b);
    double maxY = points.reduce((a, b) => a > b ? a : b);

    // Give a 5% breathing room on top and bottom
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
    for (int i = 0; i < points.length; i++) {
      spots.add(FlSpot(i.toDouble(), points[i]));
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
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1E2026),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '₹${spot.y.toStringAsFixed(2)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
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
