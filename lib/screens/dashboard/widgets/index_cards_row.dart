import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/layout/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/market_pulse.dart';
import '../../../providers/market_pulse_provider.dart';
import '../index_detail_page.dart';
import '../../../core/l10n/l10n_ext.dart';

Color get _surface => AppColors.surface;
Color get _muted => AppColors.textSecondary;
const _yahoo = {'NIFTY 50': '^NSEI', 'SENSEX': '^BSESN'};

/// NIFTY 50, SENSEX, Nifty Bank and Nifty IT, each with today's sparkline.
class IndexCardsRow extends ConsumerWidget {
  const IndexCardsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pulse = ref.watch(marketPulseProvider).valueOrNull;
    final quotes = pulse?.indices ?? [for (final n in indexOrder) IndexQuote(n)];
    if (Breakpoints.isDesktop(context)) {
      return Row(
        children: [
          for (var i = 0; i < quotes.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: _IndexCard(quotes[i])),
          ],
        ],
      );
    }
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: quotes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => SizedBox(width: 160, child: _IndexCard(quotes[i])),
      ),
    );
  }
}

class _IndexCard extends StatelessWidget {
  final IndexQuote q;
  const _IndexCard(this.q);

  @override
  Widget build(BuildContext context) {
    final up = (q.change ?? 0) >= 0;
    final color = q.change == null ? _muted : (up ? AppColors.success : AppColors.danger);
    final yahoo = _yahoo[q.name];
    final card = Container(
      height: 120,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ink.withValues(alpha: .06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q.name, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.ink, fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(q.value == null ? '—' : Formatters.number(double.parse(q.value!.toStringAsFixed(2))),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          Row(
            children: [
              if (q.change != null) Icon(up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 12, color: color),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    q.change == null ? '—' : '${q.change! >= 0 ? '+' : ''}${q.change!.toStringAsFixed(2)}  (${Formatters.percent(q.pct!, signed: true)})',
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(child: q.spark.length < 2 ? const SizedBox.shrink() : _Spark(q, color)),
        ],
      ),
    );
    final labelled = Semantics(
      label: context.t.semIndex(q.name, q.value == null ? context.t.semNoData : Formatters.number(double.parse(q.value!.toStringAsFixed(2))),
          q.pct == null ? context.t.semNoData : Formatters.percent(q.pct!, signed: true)),
      excludeSemantics: true,
      child: card,
    );
    if (yahoo == null) return labelled;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => IndexDetailPage(symbol: yahoo, name: q.name))),
      child: labelled,
    );
  }
}

class _Spark extends StatelessWidget {
  final IndexQuote q;
  final Color color;
  const _Spark(this.q, this.color);

  @override
  Widget build(BuildContext context) {
    final values = [...q.spark, if (q.prevClose != null) q.prevClose!];
    final lo = values.reduce((a, b) => a < b ? a : b), hi = values.reduce((a, b) => a > b ? a : b);
    final pad = (hi - lo) * .1 + .01;
    return LineChart(
      LineChartData(
        minY: lo - pad,
        maxY: hi + pad,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        extraLinesData: ExtraLinesData(horizontalLines: [
          if (q.prevClose != null) HorizontalLine(y: q.prevClose!, color: AppColors.ink.withValues(alpha: 0.38), strokeWidth: 1, dashArray: const [2, 3]),
        ]),
        lineBarsData: [
          LineChartBarData(
            spots: [for (var i = 0; i < q.spark.length; i++) FlSpot(i.toDouble(), q.spark[i])],
            color: color,
            barWidth: 1.5,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
