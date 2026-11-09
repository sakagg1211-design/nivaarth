import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/utils/formatters.dart';
import '../../models/portfolio.dart';
import '../../models/trade.dart';
import '../../providers/privacy_provider.dart';
import '../../repositories/portfolio_repository.dart';
import '../../repositories/trade_repository.dart';
import 'trade_book_page.dart';
import '../../core/l10n/l10n_ext.dart';

/// One fully sold stock: what was bought and sold in all, the realized P&L (average cost,
/// from Portfolio.realized_pl) and the day of the last sell.
class ClosedPosition {
  final Portfolio holding;
  final double bought;
  final double sold;
  final DateTime? lastSell;
  final int trades;

  const ClosedPosition({
    required this.holding,
    required this.bought,
    required this.sold,
    required this.lastSell,
    required this.trades,
  });

  double get realizedPl => holding.realizedPl;

  /// Realized P&L on the cost of the shares sold (sold value minus P&L)
  double? get realizedPercent {
    final cost = sold - realizedPl;
    return cost > 0 ? realizedPl / cost * 100 : null;
  }

  /// Closed holdings with their trades, most recently closed first
  static List<ClosedPosition> build(List<Portfolio> closed, List<Trade> trades) {
    final out = <ClosedPosition>[];
    for (final h in closed) {
      final mine = trades.where((t) => t.instrument.toUpperCase() == h.instrument.toUpperCase()).toList();
      double bought = 0, sold = 0;
      DateTime? lastSell;
      for (final t in mine) {
        if (t.side == TradeSide.buy) {
          bought += t.qty * t.price;
        } else {
          sold += t.qty * t.price;
          if (lastSell == null || t.tradeDate.isAfter(lastSell)) lastSell = t.tradeDate;
        }
      }
      out.add(ClosedPosition(holding: h, bought: bought, sold: sold, lastSell: lastSell, trades: mine.length));
    }
    out.sort((a, b) => (b.lastSell ?? DateTime(1970)).compareTo(a.lastSell ?? DateTime(1970)));
    return out;
  }
}

/// Fully sold stocks (Status CLOSED). They are not in the main Portfolio list; their trades stay
/// in the Trade book. Buying one again from Add Holding reopens it.
class ClosedPositionsPage extends ConsumerStatefulWidget {
  const ClosedPositionsPage({super.key});

  @override
  ConsumerState<ClosedPositionsPage> createState() => _ClosedPositionsPageState();
}

class _ClosedPositionsPageState extends ConsumerState<ClosedPositionsPage> {
  late Future<List<ClosedPosition>> _future;
  static final _dayFormat = DateFormat('d MMM yyyy');

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ClosedPosition>> _load() async {
    final results = await Future.wait([
      PortfolioRepository().getClosedPositions(),
      TradeRepository().getAllTrades(),
    ]);
    return ClosedPosition.build(results[0] as List<Portfolio>, results[1] as List<Trade>);
  }

  Future<void> _reload() async {
    final next = _load();
    setState(() => _future = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    final hide = ref.watch(privacyModeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0D10),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(context.t.closedTitle, style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: () => ref.read(privacyModeProvider.notifier).toggle(),
            icon: Icon(hide ? Icons.visibility_off_rounded : Icons.visibility_rounded),
            color: hide ? const Color(0xFFE5A93C) : const Color(0xFF8E929B),
            tooltip: hide ? context.t.tipShowValues : context.t.tipHideValues,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: FutureBuilder<List<ClosedPosition>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFE5A93C)));
                }
                if (snapshot.hasError) {
                  return _message(Icons.error_outline_rounded, context.t.closedLoadFailed,
                      context.t.commonCheckInternet,
                      action: TextButton(onPressed: _reload, child: Text(context.t.commonTryAgain)));
                }
                final items = snapshot.data ?? const [];
                if (items.isEmpty) {
                  return _message(Icons.inventory_2_outlined, context.t.closedEmptyTitle,
                      context.t.closedEmptyBody);
                }
                final total = items.fold<double>(0, (s, p) => s + p.realizedPl);
                return RefreshIndicator(
                  onRefresh: _reload,
                  color: const Color(0xFFE5A93C),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      if (i == 0) return _totalCard(total, items.length, hide);
                      return _tile(items[i - 1], hide);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Color _tone(double v) => v >= 0 ? const Color(0xFF00E676) : const Color(0xFFFF5252);

  Widget _totalCard(double total, int count, bool hide) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16171B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(context.t.closedCount(count),
                style: const TextStyle(color: Color(0xFF8E929B), fontSize: 13)),
          ),
          Text(
            hide ? context.t.closedRealized('••••') : context.t.closedRealized(Formatters.currency(total, signed: true)),
            style: TextStyle(color: hide ? Colors.white70 : _tone(total), fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _tile(ClosedPosition p, bool hide) {
    final pct = p.realizedPercent;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TradeBookPage(initialQuery: p.holding.instrument)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF16171B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: .06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.holding.instrument,
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                      if (p.holding.companyName.isNotEmpty)
                        Text(p.holding.companyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xFF8E929B), fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      hide ? '••••' : Formatters.currency(p.realizedPl, signed: true),
                      style: TextStyle(
                          color: hide ? Colors.white70 : _tone(p.realizedPl), fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    if (pct != null)
                      Text(Formatters.percent(pct, signed: true),
                          style: TextStyle(color: _tone(p.realizedPl), fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              [
                context.t.tradeBought(hide ? '••••' : Formatters.currency0(p.bought)),
                context.t.tradeSold(hide ? '••••' : Formatters.currency0(p.sold)),
                if (p.lastSell != null) context.t.closedLastSell(_dayFormat.format(p.lastSell!)),
                context.t.closedTrades(p.trades),
              ].join(' · '),
              style: const TextStyle(color: Color(0xFF858A94), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(IconData icon, String title, String body, {Widget? action}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: const Color(0xFF8E929B)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(body, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF8E929B), fontSize: 13)),
            if (action != null) ...[const SizedBox(height: 16), action],
          ],
        ),
      ),
    );
  }
}
