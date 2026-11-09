import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/stock_insights.dart';
import '../../../models/peer_comparison.dart';
import '../../../models/stock_score.dart';
import '../../../providers/stock_insights_provider.dart';
import '../../../providers/stock_score_provider.dart';
import '../../../core/l10n/l10n_ext.dart';

const _muted = Color(0xFF8E929B);
const _labelWidth = 112.0;
const _columnWidth = 88.0;
const _rowHeight = 30.0;

/// Side-by-side numbers for the stock, its three largest industry peers and one peer the user picks.
/// No cell is highlighted: the table shows the figures and leaves the reading to the user.
class PeerComparisonCard extends ConsumerStatefulWidget {
  final String symbol;
  final StockScore score;
  const PeerComparisonCard({super.key, required this.symbol, required this.score});

  @override
  ConsumerState<PeerComparisonCard> createState() => _PeerComparisonCardState();
}

class _PeerComparisonCardState extends ConsumerState<PeerComparisonCard> {
  PeerRow? _picked;

  Future<void> _pick(PeerData data, List<PeerRow> shown) async {
    final options = data.others.where((p) => !shown.any((s) => s.symbol == p.symbol)).toList();
    final choice = await showModalBottomSheet<PeerRow>(
      context: context,
      backgroundColor: const Color(0xFF16171B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheet) => SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: options.length,
          itemBuilder: (_, i) => ListTile(
            title: Text(options[i].symbol, style: const TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: Text(options[i].name, style: const TextStyle(color: _muted, fontSize: 12)),
            onTap: () => Navigator.pop(sheet, options[i]),
          ),
        ),
      ),
    );
    if (choice != null && mounted) setState(() => _picked = choice);
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(peerComparisonProvider(widget.symbol)).valueOrNull;
    if (data == null) return const SizedBox.shrink();
    final columns = [data.self, ...data.largest, ?_picked];
    final canPick = data.others.length > data.largest.length + (_picked == null ? 0 : 1);
    final lender = StockInsights.isLender(widget.score.scoreBreakdown);

    final scores = {
      for (final c in columns)
        c.symbol: c.symbol == data.self.symbol
            ? widget.score
            : ref.watch(stockScoreProvider(c.symbol)).valueOrNull,
    };
    String pillar(PeerRow c, String key) => scores[c.symbol]?.pillarScore(key)?.toString() ?? '—';

    final rows = <(String, String Function(PeerRow))>[
      ('NV Score', (c) => scores[c.symbol]?.overallScore?.toString() ?? '—'),
      ('Quality', (c) => pillar(c, 'quality')),
      ('Valuation', (c) => pillar(c, 'valuation')),
      ('Momentum', (c) => pillar(c, 'momentum')),
      if (lender) ...[
        ('P/B', (c) => peerCell(c.pb, digits: 2, positiveOnly: true)),
        ('ROE', (c) => peerCell(c.roe, suffix: '%')),
        ('ROA', (c) => peerCell(c.roa, digits: 2, suffix: '%')),
      ] else ...[
        ('P/E', (c) => peerCell(c.pe, positiveOnly: true)),
        ('ROCE', (c) => peerCell(c.roce, suffix: '%')),
        ('Debt/Equity', (c) => peerCell(c.debtToEquity, digits: 2)),
      ],
      ('Sales growth 5Y', (c) => peerCell(c.salesGrowth5Y, suffix: '%')),
      ('Profit growth 5Y', (c) => peerCell(c.profitGrowth5Y, suffix: '%')),
    ];

    Widget cell(String text, {bool strong = false}) => SizedBox(
          width: _columnWidth,
          height: _rowHeight,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.white, fontSize: 13, fontWeight: strong ? FontWeight.w800 : FontWeight.w500)),
          ),
        );

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
          Text(context.t.peersTitle,
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(data.industry, style: const TextStyle(color: _muted, fontSize: 12)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _labelWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: _rowHeight),
                    for (final r in rows)
                      SizedBox(
                        height: _rowHeight,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(r.$1, style: const TextStyle(color: _muted, fontSize: 12)),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          for (final c in columns)
                            Tooltip(message: c.name, child: cell(c.symbol, strong: true)),
                        ],
                      ),
                      for (final r in rows)
                        Row(
                          children: [
                            for (final c in columns) cell(r.$2(c)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (canPick) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE5A93C),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
                icon: Icon(_picked == null ? Icons.add_rounded : Icons.swap_horiz_rounded, size: 16),
                label: Text(_picked == null ? context.t.peersAdd : context.t.peersChange,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                onPressed: () => _pick(data, columns),
              ),
            ),
          ],
          Text(context.t.peersDashNote,
              style: TextStyle(color: _muted, fontSize: 11)),
        ],
      ),
    );
  }
}
