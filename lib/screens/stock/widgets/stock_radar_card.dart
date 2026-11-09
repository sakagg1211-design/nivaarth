import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/stock_insights.dart';
import '../../../models/stock_score.dart';
import '../../../providers/stock_insights_provider.dart';
import 'share_card.dart';

const _muted = Color(0xFF8E929B);
const _line = Color(0xFF3987E5);

/// The shape on a fixed 0-100 scale, so two stocks' shapes can be compared.
class ScoreRadar extends StatelessWidget {
  final List<RadarAxis> axes;
  const ScoreRadar({super.key, required this.axes});

  /// Only corners with a real number: a missing one drawn at 0 would look like the worst score.
  /// The table under the chart still lists it, as "—".
  List<RadarAxis> get _drawn => axes.where((a) => a.value != null).toList();

  RadarDataSet _anchor(double v) => RadarDataSet(
        dataEntries: [for (final _ in _drawn) RadarEntry(value: v)],
        fillColor: Colors.transparent,
        borderColor: Colors.transparent,
        borderWidth: 0,
        entryRadius: 0,
      );

  @override
  Widget build(BuildContext context) {
    final grid = BorderSide(color: Colors.white.withValues(alpha: .1));
    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        dataSets: [
          // fl_chart scales to the data's own range; these two invisible rings pin it to 0 and 100
          _anchor(0),
          _anchor(100),
          RadarDataSet(
            dataEntries: [for (final a in _drawn) RadarEntry(value: a.value!)],
            fillColor: _line.withValues(alpha: .22),
            borderColor: _line,
            borderWidth: 2,
            entryRadius: 3,
          ),
        ],
        tickCount: 3,
        ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 1),
        tickBorderData: grid,
        gridBorderData: grid,
        radarBorderData: grid,
        radarBackgroundColor: Colors.transparent,
        radarTouchData: RadarTouchData(enabled: false),
        titleTextStyle: const TextStyle(color: Colors.white70, fontSize: 11),
        titlePositionPercentageOffset: 0.14,
        getTitle: (i, _) => RadarChartTitle(text: _drawn[i].shortLabel),
      ),
      duration: Duration.zero,
    );
  }
}

class BadgeWrap extends StatelessWidget {
  final List<StockBadge> badges;
  const BadgeWrap({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final b in badges)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: b.caution ? const Color(0x80E5A93C) : Colors.white.withValues(alpha: .16)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  b.caution ? Icons.warning_amber_rounded : Icons.check_rounded,
                  size: 13,
                  color: b.caution ? const Color(0xFFE5A93C) : _muted,
                ),
                const SizedBox(width: 4),
                Text(b.label, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Six-corner picture of the score, the facts as badges, and the table with the same numbers.
class StockRadarCard extends ConsumerWidget {
  final String symbol;
  final String companyName;
  final StockScore score;
  const StockRadarCard({super.key, required this.symbol, required this.companyName, required this.score});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facts = ref.watch(stockFactsProvider(symbol)).valueOrNull;
    final lender = StockInsights.isLender(score.scoreBreakdown);
    final badges = StockInsights.badges(
      facts,
      lender: lender,
      pledgeReviewed: StockInsights.pledgeReviewed(score.scoreBreakdown),
    );
    final axes = StockInsights.radarAxes(score.scoreBreakdown);
    final draw = StockInsights.canDrawRadar(axes);
    if (!draw && badges.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16171B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Score ka aakar',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              ),
              if (score.overallScore != null)
                IconButton(
                  tooltip: 'Share',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.ios_share_rounded, color: _muted, size: 18),
                  onPressed: () => showShareCard(
                    context,
                    fileName: 'Nivaarth_$symbol.png',
                    card: StockShareCard(symbol: symbol, companyName: companyName, score: score, badges: badges),
                  ),
                ),
            ],
          ),
          if (badges.isNotEmpty) ...[
            const SizedBox(height: 8),
            BadgeWrap(badges: badges),
          ],
          if (draw) ...[
            const SizedBox(height: 12),
            SizedBox(height: 230, child: ScoreRadar(axes: axes)),
            const SizedBox(height: 12),
            for (final a in axes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(child: Text(a.label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                    Text(a.value == null ? '—' : a.value!.round().toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            Text(
              lender
                  ? 'Har score 0–100, bahar ki taraf zyada. Leverage mein zyada score yani kam leverage.'
                  : 'Har score 0–100, bahar ki taraf zyada. Debt mein zyada score yani kam karz.',
              style: const TextStyle(color: _muted, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
