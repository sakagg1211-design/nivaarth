import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/investment_style.dart';
import '../../../providers/investment_style_provider.dart';
import '../../../core/l10n/l10n_ext.dart';

const _surface = Color(0xFF16171B);
const _muted = Color(0xFF8E929B);
const _blue = Color(0xFF3987E5);
const _gold = Color(0xFFE5A93C);
const _labelWidth = 44.0;
const _totalWidth = 46.0;
const _headers = ['Growth', 'Growth\n+ Value', 'Value', 'Others'];

String _p(double v) => v < 0.05 ? '—' : '${v.toStringAsFixed(1)}%';
String _rank(double? v) => v == null ? '—' : v.round().toString();

/// Where the portfolio's money sits by company size and style. A description, never a suggestion.
class InvestmentStyleCard extends ConsumerWidget {
  const InvestmentStyleCard({super.key});

  void _sheet(BuildContext context, Widget child) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: _surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .8),
            child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: child),
          ),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grid = ref.watch(investmentStyleProvider).valueOrNull;
    if (grid == null) return const SizedBox.shrink();
    final top = grid.largest;
    final topValue = top == null ? 0.0 : grid.percent[top.$1][top.$2];

    Widget cell(int r, int c) {
      final v = grid.percent[r][c];
      final empty = v < 0.05;
      final strength = topValue > 0 ? v / topValue : 0.0;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Material(
            color: empty ? Colors.white.withValues(alpha: .03) : _blue.withValues(alpha: .14 + strength * .56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: top == (r, c) ? const BorderSide(color: _gold, width: 1.5) : BorderSide.none,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: empty ? null : () => _sheet(context, _CellStocks(grid, r, c)),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                child: Text(_p(v),
                    style: TextStyle(color: empty ? _muted : Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
      );
    }

    final extras = [
      if (grid.funds >= 0.05) context.t.styleFunds(_p(grid.funds)),
      if (grid.loss >= 0.05) context.t.styleLoss(_p(grid.loss)),
      if (grid.unclassified >= 0.05) context.t.styleNoData(_p(grid.unclassified)),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
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
              Expanded(
                child: Text(context.t.styleTitle,
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              ),
              IconButton(
                tooltip: context.t.styleWhatTip,
                icon: const Icon(Icons.info_outline_rounded, color: _muted, size: 20),
                onPressed: () => _sheet(context, const _Explainer()),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (top != null) ...[
                  Text(context.t.styleLargest, style: TextStyle(color: _muted, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text('${StyleGrid.rows[top.$1]} Cap · ${StyleGrid.cols[top.$2].replaceAll('+', ' + ')}',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  Text(context.t.stylePctPortfolio(topValue.toStringAsFixed(1)), style: const TextStyle(color: _muted, fontSize: 13)),
                  const SizedBox(height: 14),
                ],
                Row(
                  children: [
                    const SizedBox(width: _labelWidth),
                    for (final h in _headers)
                      Expanded(
                        child: Text(h,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: _muted, fontSize: 11, height: 1.2)),
                      ),
                    const SizedBox(width: _totalWidth),
                  ],
                ),
                const SizedBox(height: 4),
                for (var r = 0; r < StyleGrid.rows.length; r++)
                  Row(
                    children: [
                      SizedBox(
                        width: _labelWidth,
                        child: Text(StyleGrid.rows[r], style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ),
                      for (var c = 0; c < StyleGrid.cols.length; c++) cell(r, c),
                      SizedBox(
                        width: _totalWidth,
                        child: Text(_p(grid.rowTotal(r)),
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const SizedBox(
                      width: _labelWidth,
                      child: Text('Total', style: TextStyle(color: _muted, fontSize: 12)),
                    ),
                    for (var c = 0; c < StyleGrid.cols.length; c++)
                      Expanded(
                        child: Text(_p(grid.colTotal(c)),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    const SizedBox(width: _totalWidth),
                  ],
                ),
                if (extras.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(extras.join('  ·  '), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CellStocks extends StatelessWidget {
  final StyleGrid grid;
  final int row;
  final int col;
  const _CellStocks(this.grid, this.row, this.col);

  @override
  Widget build(BuildContext context) {
    final list = grid.stocks[row][col];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${StyleGrid.rows[row]} Cap · ${StyleGrid.cols[col].replaceAll('+', ' + ')}',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: Text('Stock', style: TextStyle(color: _muted, fontSize: 12))),
            SizedBox(width: 56, child: Text(context.t.styleShare, textAlign: TextAlign.right, style: TextStyle(color: _muted, fontSize: 12))),
            SizedBox(width: 56, child: Text('Growth', textAlign: TextAlign.right, style: TextStyle(color: _muted, fontSize: 12))),
            SizedBox(width: 48, child: Text('Value', textAlign: TextAlign.right, style: TextStyle(color: _muted, fontSize: 12))),
          ],
        ),
        const SizedBox(height: 6),
        for (final s in list)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Expanded(child: Text(s.symbol, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13))),
                SizedBox(width: 56, child: Text(_p(grid.weight(s)), textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 13))),
                SizedBox(width: 56, child: Text(_rank(s.growthRank), textAlign: TextAlign.right, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                SizedBox(width: 48, child: Text(_rank(s.valueRank), textAlign: TextAlign.right, style: const TextStyle(color: Colors.white70, fontSize: 13))),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Text(context.t.styleRankNote,
            style: TextStyle(color: _muted, fontSize: 12)),
      ],
    );
  }
}

class _Explainer extends StatelessWidget {
  const _Explainer();

  Widget _heading(String t) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
      );

  Widget _line(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.t.styleWhatTitle,
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        _line(context.t.styleWhatIntro),
        _heading(context.t.styleSizeHead),
        _line(context.t.styleLarge),
        _line(context.t.styleMid),
        _line(context.t.styleSmall),
        _line(context.t.styleMicro),
        _heading(context.t.styleTypeHead),
        _line(context.t.styleGrowth),
        _line(context.t.styleValue),
        _line(context.t.styleBoth),
        _line(context.t.styleOthers),
        _heading(context.t.styleTableHead),
        _line(context.t.styleTableBody),
        _line(context.t.styleTableBody2),
        _heading(context.t.styleHowHead),
        _line(context.t.styleHow1),
        _line(context.t.styleHow2),
        _line(context.t.styleHow3),
        _line(context.t.styleHow4),
        _heading(context.t.styleBelowHead),
        _line(context.t.styleBelowBody),
        _heading(context.t.styleNoteHead),
        _line(context.t.styleNoteBody),
      ],
    );
  }
}
