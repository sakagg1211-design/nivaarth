import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/allocation_math.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/allocation_provider.dart';
import '../../../providers/privacy_provider.dart';
import '../../stock/widgets/share_card.dart';

/// Colour-blind-safe categorical order, validated against the card surface (dark mode).
const _series = [
  Color(0xFF3987E5), // blue
  Color(0xFFD95926), // orange
  Color(0xFF199E70), // aqua
  Color(0xFFC98500), // yellow
  Color(0xFFD55181), // magenta
  Color(0xFF008300), // green
  Color(0xFF9085E9), // violet
  Color(0xFFE66767), // red
];
const _neutral = Color(0xFF6B6F78);

/// A tier or sector keeps its colour when values move: colours follow the name, not the size.
Map<String, Color> allocationColors(List<AllocationSlice> slices, {List<String>? order}) {
  final named = (order ?? (slices.map((s) => s.label).toList()..sort()))
      .where((l) => l != AllocationMath.others && l != AllocationMath.unknown)
      .toList();
  return {
    for (var i = 0; i < named.length; i++) named[i]: _series[i % _series.length],
    AllocationMath.others: _neutral,
    AllocationMath.unknown: _neutral,
  };
}

/// Dashboard card: Large / Mid / Small cap and sector split of the portfolio (donut + table).
class AllocationCard extends ConsumerStatefulWidget {
  const AllocationCard({super.key});

  @override
  ConsumerState<AllocationCard> createState() => _AllocationCardState();
}

class _AllocationCardState extends ConsumerState<AllocationCard> {
  bool _sector = false;
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    // valueOrNull: a failed load hides the card; .value would throw here and break the dashboard
    final data = ref.watch(allocationProvider).valueOrNull;
    final hide = ref.watch(privacyModeProvider);
    if (data == null) return const SizedBox.shrink();
    final slices = _sector ? data.bySector : data.byCap;
    if (slices.isEmpty) return const SizedBox.shrink();
    final colors = allocationColors(slices,
        order: _sector
            ? null
            : const [AllocationMath.large, AllocationMath.mid, AllocationMath.small, AllocationMath.etf]);
    final focus = _touched >= 0 && _touched < slices.length ? slices[_touched] : slices.first;

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
                child: Text('Portfolio ka bantwara',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              ),
              _tab('Market cap', !_sector, () => setState(() {
                    _sector = false;
                    _touched = -1;
                  })),
              const SizedBox(width: 6),
              _tab('Sector', _sector, () => setState(() {
                    _sector = true;
                    _touched = -1;
                  })),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 54,
                    startDegreeOffset: -90,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        final i = response?.touchedSection?.touchedSectionIndex ?? -1;
                        if (event.isInterestedForInteractions && i != _touched) {
                          setState(() => _touched = i);
                        }
                      },
                    ),
                    sections: [
                      for (var i = 0; i < slices.length; i++)
                        PieChartSectionData(
                          value: slices[i].value,
                          color: colors[slices[i].label] ?? _neutral,
                          radius: i == _touched ? 30 : 24,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
                IgnorePointer(
                  child: SizedBox(
                    width: 92, // stays inside the 108px hole
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(Formatters.percent(focus.percent),
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                        Text(focus.label,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xFF8E929B), fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final s in slices)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: colors[s.label] ?? _neutral, borderRadius: BorderRadius.circular(3)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${s.label} · ${s.stocks}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                  ),
                  Text(hide ? '••••' : Formatters.currency0(s.value),
                      style: const TextStyle(color: Color(0xFF8E929B), fontSize: 12)),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 60,
                    child: Text(Formatters.percent(s.percent),
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          if (!_sector) ...[
            const SizedBox(height: 6),
            const Text('Large: top 100 companies by market cap · Mid: 101–250 · Small: baaki',
                style: TextStyle(color: Color(0xFF8E929B), fontSize: 10.5)),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8E929B),
                padding: const EdgeInsets.symmetric(vertical: 4),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.ios_share_rounded, size: 15),
              label: const Text('Share', style: TextStyle(fontSize: 12)),
              onPressed: () => showShareCard(
                context,
                fileName: 'Nivaarth_portfolio.png',
                card: AllocationShareCard(
                  title: _sector ? 'Portfolio: sector ke hisaab se' : 'Portfolio: market cap ke hisaab se',
                  slices: slices,
                  colors: colors,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? Colors.white.withValues(alpha: .1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? Colors.white : const Color(0xFF8E929B), fontSize: 11.5, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
