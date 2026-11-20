import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/account_value.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/account_value_provider.dart';
import '../../../providers/privacy_provider.dart';

const _surface = Color(0xFF16171B);
const _muted = Color(0xFF8E929B);
const _investedLine = Colors.white54;
const _mask = '••••';

final _day = DateFormat('d MMM');
final _dayYear = DateFormat('d MMM yyyy');
final _time = DateFormat('h:mm a');

/// ₹4.82L, ₹1.25Cr, ₹48.2K: short enough for an axis label.
String _compact(double v) {
  final a = v.abs();
  final s = a >= 1e7
      ? '${(a / 1e7).toStringAsFixed(2)}Cr'
      : a >= 1e5
          ? '${(a / 1e5).toStringAsFixed(2)}L'
          : a >= 1e3
              ? '${(a / 1e3).toStringAsFixed(1)}K'
              : a.toStringAsFixed(0);
  return '${v < 0 ? '-' : ''}₹$s';
}

/// Account value over time: rises when shares are added, falls when they are sold.
class AccountValueCard extends ConsumerStatefulWidget {
  const AccountValueCard({super.key});

  @override
  ConsumerState<AccountValueCard> createState() => _AccountValueCardState();
}

class _AccountValueCardState extends ConsumerState<AccountValueCard> {
  ValueRange? _range;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final today = ref.watch(accountTodayProvider).valueOrNull;
    // A new user's first day has no closed day yet, but today's line still shows
    final history = ref.watch(accountHistoryProvider).valueOrNull ?? const AccountHistory([]);
    if (history.points.isEmpty && (today?.line.isEmpty ?? true)) return const SizedBox.shrink();
    final hide = ref.watch(privacyModeProvider);

    final ranges = history.ranges;
    final range = _range != null && ranges.contains(_range) ? _range! : ranges.last;
    final intraday = range == ValueRange.d1;

    var points = intraday ? (today?.line ?? const <ValuePoint>[]) : history.slice(range);
    // Today's live value closes the daily line once the last close is from an earlier day
    if (!intraday && today != null && points.isNotEmpty) {
      final now = DateTime.now();
      final last = points.last.time;
      if (DateTime(now.year, now.month, now.day).isAfter(last)) {
        points = [...points, ValuePoint(now, today.value, today.invested)];
      }
    }
    final current = intraday ? today?.value : (points.isEmpty ? null : points.last.value);
    double? change, base;
    if (intraday) {
      base = today?.prevClose;
      if (current != null && base != null) change = current - base;
    } else if (points.isNotEmpty) {
      // Money put in or taken out is not gain: count only the move of the market
      final added = points.last.invested - points.first.invested;
      change = (points.last.value - points.first.value) - added;
      base = points.first.value + math.max(0, added);
    }
    final pct = (change != null && base != null && base > 0) ? change / base * 100 : null;
    final assumedShown = !intraday && points.any((p) => p.assumed);

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
          Text(t.acctTitle, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            current == null ? '—' : (hide ? _mask : Formatters.currency0(current)),
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.1),
          ),
          if (change != null && pct != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(change >= 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    size: 14, color: change >= 0 ? AppColors.success : AppColors.danger),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${Formatters.percent(pct, signed: true)}'
                    '${hide ? '' : '  (${Formatters.currency0(change, signed: true)})'}'
                    '  ${intraday ? t.heroToday : range.label}',
                    style: TextStyle(
                      color: change >= 0 ? AppColors.success : AppColors.danger,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (points.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              intraday ? '${_day.format(points.last.time)}, ${_time.format(points.last.time)}' : _dayYear.format(points.last.time),
              style: const TextStyle(color: _muted, fontSize: 11),
            ),
          ],
          Row(
            children: [
              for (final r in ranges) _RangeChip(r.label, selected: r == range, onTap: () => setState(() => _range = r)),
            ],
          ),
          if (points.length < 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(intraday ? t.acctNoIntraday : '—',
                    textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 12)),
              ),
            )
          else ...[
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _Legend(t.acctValue, color: AppColors.accent),
                if (intraday)
                  _Legend(t.acctPrevClose, color: _investedLine, dashed: true)
                else
                  _Legend(t.acctInvested, color: _investedLine, dashed: true),
              ],
            ),
            const SizedBox(height: 10),
            Semantics(label: t.semAccount(intraday ? t.heroToday : range.label, pct == null ? t.semNoData : Formatters.percent(pct, signed: true)), excludeSemantics: true, child: SizedBox(
              height: 190,
              child: _Chart(points, intraday: intraday, prevClose: today?.prevClose, hide: hide),
            )),
          ],
          const SizedBox(height: 8),
          if (assumedShown)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(t.acctAssumedNote(_dayYear.format(points.firstWhere((p) => !p.assumed, orElse: () => points.last).time)),
                  style: const TextStyle(color: _muted, fontSize: 11)),
            ),
          if (history.points.isNotEmpty)
            Text(t.acctFooter(_dayYear.format(history.points.last.time)), style: const TextStyle(color: _muted, fontSize: 11)),
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
  final bool dashed;
  const _Legend(this.text, {required this.color, this.dashed = false});

  @override
  Widget build(BuildContext context) {
    Widget dash(double w) => Container(width: w, height: 2, color: color);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dashed) ...[dash(6), const SizedBox(width: 3), dash(6)] else dash(15),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700))),
      ],
    );
  }
}

class _Chart extends StatelessWidget {
  final List<ValuePoint> points;
  final bool intraday;
  final double? prevClose;
  final bool hide;
  const _Chart(this.points, {required this.intraday, required this.prevClose, required this.hide});

  @override
  Widget build(BuildContext context) {
    final values = [
      ...points.map((p) => p.value),
      if (!intraday) ...points.map((p) => p.invested),
      if (intraday && prevClose != null) prevClose!,
    ];
    final low = values.reduce(math.min), high = values.reduce(math.max);
    final pad = math.max((high - low) * .08, high.abs() * .002 + 1);
    final minY = low - pad, maxY = high + pad;

    final spots = [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].value)];
    // The assumed part is drawn faint; it joins the real part at the first real point
    final firstReal = points.indexWhere((p) => !p.assumed);
    final assumedSpots = intraday || firstReal == 0
        ? const <FlSpot>[]
        : spots.sublist(0, firstReal < 0 ? spots.length : firstReal + 1);
    final realSpots = intraday || firstReal == 0 ? spots : (firstReal < 0 ? const <FlSpot>[] : spots.sublist(firstReal));

    LineChartBarData line(List<FlSpot> s, Color c, {List<int>? dash}) => LineChartBarData(
          spots: s,
          color: c,
          barWidth: 2,
          dashArray: dash,
          dotData: const FlDotData(show: false),
        );

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: Colors.white.withValues(alpha: .05), strokeWidth: 1),
        ),
        extraLinesData: ExtraLinesData(horizontalLines: [
          if (intraday && prevClose != null)
            HorizontalLine(y: prevClose!, color: _investedLine, strokeWidth: 1, dashArray: const [3, 4]),
        ]),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (v, meta) => (v == meta.min || v == meta.max)
                  ? const SizedBox.shrink()
                  : SideTitleWidget(
                      meta: meta,
                      child: Text(hide ? '••' : _compact(v), style: const TextStyle(color: _muted, fontSize: 10)),
                    ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchSpotThreshold: 100000,
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (_) => const Color(0xFF1E2026),
            getTooltipItems: (touched) => [
              for (final s in touched)
                identical(s, touched.first)
                    ? LineTooltipItem(
                        '${(intraday ? _time : _dayYear).format(points[s.x.toInt()].time)}\n'
                        '${hide ? _mask : Formatters.currency0(points[s.x.toInt()].value)}',
                        const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      )
                    : null,
            ],
          ),
        ),
        lineBarsData: [
          if (assumedSpots.isNotEmpty) line(assumedSpots, AppColors.accent.withValues(alpha: .35)),
          if (realSpots.isNotEmpty) line(realSpots, AppColors.accent),
          if (!intraday)
            line([for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].invested)], _investedLine,
                dash: const [5, 4]),
        ],
      ),
    );
  }
}
