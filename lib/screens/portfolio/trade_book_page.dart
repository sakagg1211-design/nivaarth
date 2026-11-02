import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/utils/formatters.dart';
import '../../core/utils/holding_math.dart';
import '../../models/trade.dart';
import '../../providers/privacy_provider.dart';
import '../../repositories/trade_repository.dart';

/// Day-wise list of every buy and sell of the user, newest day first, with what was bought
/// and sold each day and the realized P&L (average cost) of each sell.
class TradeBookPage extends ConsumerStatefulWidget {
  const TradeBookPage({super.key});

  @override
  ConsumerState<TradeBookPage> createState() => _TradeBookPageState();
}

class _TradeBookPageState extends ConsumerState<TradeBookPage> {
  late Future<List<Trade>> _tradesFuture;
  final _searchController = TextEditingController();
  String _query = '';

  static final _dayFormat = DateFormat('EEE, d MMM yyyy');

  @override
  void initState() {
    super.initState();
    _tradesFuture = TradeRepository().getAllTrades();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final next = TradeRepository().getAllTrades();
    setState(() => _tradesFuture = next);
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
        title: const Text('Trade book', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: () => ref.read(privacyModeProvider.notifier).toggle(),
            icon: Icon(hide ? Icons.visibility_off_rounded : Icons.visibility_rounded),
            color: hide ? const Color(0xFFE5A93C) : const Color(0xFF8E929B),
            tooltip: hide ? 'Show Values' : 'Hide Values (Privacy Mode)',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: FutureBuilder<List<Trade>>(
              future: _tradesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE5A93C)),
                  );
                }
                if (snapshot.hasError) {
                  return _message(
                    Icons.error_outline_rounded,
                    'Trades load nahi hue',
                    TradeRepository.message(snapshot.error!),
                    action: ElevatedButton(onPressed: _reload, child: const Text('Try Again')),
                  );
                }
                final all = snapshot.data ?? const <Trade>[];
                if (all.isEmpty) {
                  return _message(
                    Icons.receipt_long_rounded,
                    'Abhi koi trade nahi',
                    'Stock add karne, kharidne ya bechne par har trade yahan din ke hisaab se dikhega.',
                  );
                }

                final sellPl = HoldingMath.sellPl(all); // from every trade, before filtering
                final q = _query.trim().toUpperCase();
                final shown = q.isEmpty ? all : all.where((t) => t.instrument.contains(q)).toList();
                final days = <DateTime, List<Trade>>{};
                for (final t in shown) {
                  final d = DateTime(t.tradeDate.year, t.tradeDate.month, t.tradeDate.day);
                  days.putIfAbsent(d, () => []).add(t);
                }
                final keys = days.keys.toList()..sort((a, b) => b.compareTo(a));

                return RefreshIndicator(
                  onRefresh: _reload,
                  color: const Color(0xFFE5A93C),
                  backgroundColor: const Color(0xFF16171B),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      TextField(
                        controller: _searchController,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Stock se dhundo (jaise POLYCAB)',
                          hintStyle: const TextStyle(color: Color(0xFF8E929B), fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8E929B), size: 18),
                          filled: true,
                          fillColor: const Color(0xFF1E2024),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF282A30)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF282A30)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE5A93C), width: 1.2),
                          ),
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${shown.length} trades · ${keys.length} din',
                        style: const TextStyle(color: Color(0xFF8E929B), fontSize: 12.5),
                      ),
                      if (shown.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: Text(
                            'Is naam ka koi trade nahi mila.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF8E929B), fontSize: 13),
                          ),
                        ),
                      for (final day in keys) _daySection(day, days[day]!, sellPl, hide),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _daySection(DateTime day, List<Trade> trades, Map<String, double> sellPl, bool hide) {
    double bought = 0, sold = 0;
    for (final t in trades) {
      if (t.side == TradeSide.buy) {
        bought += t.qty * t.price;
      } else {
        sold += t.qty * t.price;
      }
    }
    final totals = [
      if (bought > 0) 'Kharida ${hide ? '••••' : Formatters.currency0(bought)}',
      if (sold > 0) 'Becha ${hide ? '••••' : Formatters.currency0(sold)}',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _dayFormat.format(day),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
              Text(totals, style: const TextStyle(color: Color(0xFF8E929B), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          for (final t in trades) _tradeRow(t, sellPl[t.id], hide),
        ],
      ),
    );
  }

  Widget _tradeRow(Trade t, double? pl, bool hide) {
    final isBuy = t.side == TradeSide.buy;
    final tone = isBuy ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    final qty = t.qty == t.qty.roundToDouble() ? t.qty.toStringAsFixed(0) : t.qty.toString();
    final subtitle = [
      '$qty @ ${hide ? '••••' : Formatters.currency(t.price)}',
      if (t.isOpening) 'Shuruaati holding',
      if (t.brokerName != 'Manual') t.brokerName,
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF16171B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF23252B)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              isBuy ? 'BUY' : 'SELL',
              textAlign: TextAlign.center,
              style: TextStyle(color: tone, fontSize: 10.5, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.instrument,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Color(0xFF8E929B), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hide ? '••••' : Formatters.currency(t.qty * t.price),
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              ),
              if (pl != null) ...[
                const SizedBox(height: 2),
                Text(
                  hide ? 'P&L ••••' : 'P&L ${Formatters.currency(pl, signed: true)}',
                  style: TextStyle(
                    color: hide
                        ? const Color(0xFF8E929B)
                        : (pl >= 0 ? const Color(0xFF00E676) : const Color(0xFFFF5252)),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ],
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
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8E929B), fontSize: 13),
            ),
            if (action != null) ...[const SizedBox(height: 16), action],
          ],
        ),
      ),
    );
  }
}
