import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/market_hours.dart';
import '../../../providers/account_value_provider.dart';
import '../../../providers/market_pulse_provider.dart';

const _muted = Color(0xFF8E929B);
final _time = DateFormat('h:mm a');

/// The live part of the portfolio card: today's line, the last hour, today against Nifty and the
/// "kyun" button. Percentages only, so Privacy Mode has nothing to hide here.
class PulseStrip extends ConsumerWidget {
  final void Function(bool up)? onWhy;

  /// Market open or not; left null in the app so the clock decides, set in tests.
  final bool? open;
  const PulseStrip({super.key, this.onWhy, this.open});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final today = ref.watch(accountTodayProvider).valueOrNull;
    if (today == null || today.prevClose <= 0) return const SizedBox.shrink();
    final niftyPct = ref.watch(marketPulseProvider).valueOrNull?.indices.first.pct;
    final todayPct = (today.value / today.prevClose - 1) * 100;
    final up = todayPct >= 0;
    final open = this.open ?? isMarketOpenIst(DateTime.now().toUtc());
    final hour = open ? today.hour : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (today.line.length >= 2) ...[
          SizedBox(
            height: 48,
            child: LineChart(
              LineChartData(
                minY: [...today.line.map((p) => p.value), today.prevClose].reduce((a, b) => a < b ? a : b) * .999,
                maxY: [...today.line.map((p) => p.value), today.prevClose].reduce((a, b) => a > b ? a : b) * 1.001,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                extraLinesData: ExtraLinesData(horizontalLines: [
                  HorizontalLine(y: today.prevClose, color: Colors.white38, strokeWidth: 1, dashArray: const [2, 3]),
                ]),
                lineBarsData: [
                  LineChartBarData(
                    spots: [for (var i = 0; i < today.line.length; i++) FlSpot(i.toDouble(), today.line[i].value)],
                    color: AppColors.accent,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (hour != null && hour.mover != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(t.pulseLastHour(_time.format(hour.from), Formatters.percent(hour.pct, signed: true), hour.mover!),
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        if (niftyPct != null)
          Text(t.pulseVsNifty(Formatters.percent(todayPct, signed: true), Formatters.percent(niftyPct, signed: true)),
              style: const TextStyle(color: _muted, fontSize: 12)),
        if (onWhy != null) ...[
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: TextButton.icon(
              onPressed: () => onWhy!(up),
              style: TextButton.styleFrom(foregroundColor: Colors.white, padding: EdgeInsets.zero),
              icon: const Icon(Icons.smart_toy_outlined, size: 16),
              label: Text(up ? t.pulseWhyUp : t.pulseWhyDown,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ],
    );
  }
}
