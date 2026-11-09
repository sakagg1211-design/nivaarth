import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/market_hours.dart';
import '../../../core/utils/symbol_utils.dart';
import '../../../core/utils/today_moves.dart';
import '../../../models/live_portfolio.dart';
import '../../../providers/live_portfolio_provider.dart';
import '../../../repositories/listing_repository.dart';
import '../../stock/stock_detail_page.dart';
import '../../../core/l10n/l10n_ext.dart';

const _surface = Color(0xFF16171B);
const _muted = Color(0xFF8E929B);
const _up = Color(0xFF0C9F6E);
const _down = Color(0xFFD64545);

String _pct(double v) => '${v > 0 ? '+' : ''}${v.toStringAsFixed(2)}%';

class TodayMovesData {
  final List<SectorMove> sectors;
  final List<LivePortfolio> gainers;
  final List<LivePortfolio> losers;
  const TodayMovesData(this.sectors, this.gainers, this.losers);
}

final todayMovesProvider = FutureProvider.autoDispose<TodayMovesData?>((ref) async {
  final holdings = await ref.watch(livePortfolioProvider.future);
  final priced = holdings.where((h) => !h.isPriceUnavailable && h.currentValue > 0).toList();
  if (priced.isEmpty) return null;
  final symbols = priced.map((h) => h.portfolio.instrument.trim().toUpperCase()).toSet().toList();
  final sectors = await ListingRepository().sectorsFor(symbols);
  return TodayMovesData(
    TodayMoves.sectors(priced.map((h) => (
          sector: sectors[h.portfolio.instrument.trim().toUpperCase()] ?? TodayMoves.others,
          value: h.currentValue,
          todayPL: h.todayPL,
        ))),
    TodayMoves.gainers(priced),
    TodayMoves.losers(priced),
  );
});

/// Today's move by sector and the holdings that moved most. Percentages only.
class TodayMovesCard extends ConsumerWidget {
  const TodayMovesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(todayMovesProvider).valueOrNull;
    if (data == null || data.sectors.isEmpty) return const SizedBox.shrink();
    final open = isMarketOpenIst(DateTime.now());

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
          Row(
            children: [
              const Expanded(
                child: Text('Sector heatmap',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              ),
              Text(open ? context.t.movesToday : context.t.movesLastSession, style: const TextStyle(color: _muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          _Heatmap(data.sectors),
          const SizedBox(height: 8),
          Text(context.t.movesLegend,
              style: TextStyle(color: _muted, fontSize: 11)),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Movers(context.t.movesGainers, data.gainers, _up)),
              const SizedBox(width: 16),
              Expanded(child: _Movers(context.t.movesLosers, data.losers, _down)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Heatmap extends StatelessWidget {
  final List<SectorMove> sectors;
  const _Heatmap(this.sectors);

  // A move of 2% or more is shown at full strength
  Color _color(double change) {
    if (change.abs() < 0.005) return Colors.white.withValues(alpha: .06);
    final strength = (change.abs() / 2).clamp(0.0, 1.0);
    return (change > 0 ? _up : _down).withValues(alpha: .28 + strength * .62);
  }

  @override
  Widget build(BuildContext context) {
    final rows = <List<SectorMove>>[
      for (var i = 0; i < sectors.length; i += 3) sectors.sublist(i, math.min(i + 3, sectors.length)),
    ];
    return Column(
      children: [
        for (final row in rows)
          SizedBox(
            // Taller rows for bigger shares, with room for two lines of text at the small end
            height: math.max(66, row.fold<double>(0, (a, s) => a + s.weight) * 2.2),
            child: Row(
              children: [
                for (final s in row)
                  Expanded(
                    // No box narrower than a sector name can fit
                    flex: (math.max(s.weight, row.fold<double>(0, (a, x) => a + x.weight) * .28) * 10).round().clamp(1, 1000),
                    child: Container(
                      margin: const EdgeInsets.all(1),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(color: _color(s.change), borderRadius: BorderRadius.circular(6)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(s.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(_pct(s.change),
                                maxLines: 1,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Movers extends StatelessWidget {
  final String title;
  final List<LivePortfolio> items;
  final Color color;
  const _Movers(this.title, this.items, this.color);

  @override
  Widget build(BuildContext context) {
    final largest = items.isEmpty ? 1.0 : items.map((h) => h.todayReturnPercent.abs()).reduce(math.max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        if (items.isEmpty) const Text('—', style: TextStyle(color: _muted, fontSize: 13)),
        for (final h in items)
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StockDetailPage(stock: h))),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(SymbolUtils.normalize(h.portfolio.instrument),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ),
                      Text(_pct(h.todayReturnPercent),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: (h.todayReturnPercent.abs() / largest).clamp(0.04, 1.0),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
