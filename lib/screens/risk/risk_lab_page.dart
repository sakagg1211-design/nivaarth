import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../core/utils/risk_math.dart';
import '../../core/utils/symbol_utils.dart';
import '../../models/stock_score.dart';
import '../../providers/privacy_provider.dart';
import '../../providers/risk_provider.dart';
import '../../providers/search_provider.dart';
import '../../core/l10n/l10n_ext.dart';

const _muted = Color(0xFF8E929B);
const _gold = Color(0xFFE5A93C);
const _surface = Color(0xFF16171B);
const _falls = [5.0, 10.0, 20.0, 30.0];

BoxDecoration _card() => BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: .06)),
    );

String _beta(double? b) => b == null ? '—' : b.toStringAsFixed(2);
String _pct(double v) => '${v.toStringAsFixed(1)}%';
String _stocks(int n) => n == 1 ? '1 stock' : '$n stocks';

/// "What if" sums on the user's own portfolio. Nothing here places or saves a trade.
class RiskLabPage extends ConsumerWidget {
  const RiskLabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(riskHoldingsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0C0D10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111215),
        foregroundColor: Colors.white,
        title: Text(context.t.macroWhatIf,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _gold)),
        error: (_, _) => Center(child: Text(context.t.riskLoadFailed, style: TextStyle(color: _muted))),
        data: (holdings) => holdings.isEmpty
            ? Center(child: Text(context.t.riskNoStocks, style: TextStyle(color: _muted)))
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _Summary(holdings),
                      const SizedBox(height: 14),
                      _StressCard(holdings),
                      const SizedBox(height: 14),
                      _WhatIfCard(holdings),
                      const SizedBox(height: 12),
                      Text(
                        context.t.riskDisclaimer,
                        style: TextStyle(color: _muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final List<RiskHolding> holdings;
  const _Summary(this.holdings);

  @override
  Widget build(BuildContext context) {
    final s = RiskMath.snapshot(holdings);
    final pe = RiskMath.portfolioPe(holdings);
    Widget metric(String label, String value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
          ],
        );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: metric('Portfolio beta', _beta(s.beta))),
              Expanded(child: metric('Portfolio P/E', pe.pe == null ? '—' : pe.pe!.toStringAsFixed(1))),
            ],
          ),
          const SizedBox(height: 4),
          Text(context.t.riskBetaNote,
              style: TextStyle(color: _muted, fontSize: 12)),
          if (s.uncoveredCount > 0) ...[
            const SizedBox(height: 6),
            Text(context.t.riskNoBeta(_stocks(s.uncoveredCount), _pct(s.coveragePct)),
                style: const TextStyle(color: _muted, fontSize: 12)),
          ],
          if (pe.excluded > 0 && pe.pe != null) ...[
            const SizedBox(height: 6),
            Text(context.t.riskPeExcluded(_stocks(pe.excluded), _pct(pe.coveragePct)),
                style: const TextStyle(color: _muted, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _StressCard extends ConsumerStatefulWidget {
  final List<RiskHolding> holdings;
  const _StressCard(this.holdings);

  @override
  ConsumerState<_StressCard> createState() => _StressCardState();
}

class _StressCardState extends ConsumerState<_StressCard> {
  double _fall = 10;

  @override
  Widget build(BuildContext context) {
    final hide = ref.watch(privacyModeProvider);
    final r = RiskMath.stress(widget.holdings, _fall);
    String money(double v) => hide ? '••••' : Formatters.currency0(v, signed: true);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t.riskIfFalls,
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final f in _falls) ...[
                Expanded(child: _Chip('-${f.toStringAsFixed(0)}%', f == _fall, () => setState(() => _fall = f))),
                if (f != _falls.last) const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: 14),
          if (r.coveredValue <= 0)
            Text(context.t.riskBetaNa, style: TextStyle(color: _muted))
          else ...[
            Text('${r.changePct >= 0 ? '+' : ''}${r.changePct.toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            Text(context.t.riskEstimated(money(r.change)), style: const TextStyle(color: _muted, fontSize: 13)),
            if (r.uncoveredCount > 0)
              Text(context.t.riskNotCounted(_stocks(r.uncoveredCount)),
                  style: const TextStyle(color: _muted, fontSize: 12)),
            const SizedBox(height: 10),
            Text(context.t.riskMostImpact, style: TextStyle(color: _muted, fontSize: 12)),
            const SizedBox(height: 4),
            for (final l in r.lines.take(5))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(child: Text(l.symbol, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                    Text(money(l.change),
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _WhatIfCard extends ConsumerStatefulWidget {
  final List<RiskHolding> holdings;
  const _WhatIfCard(this.holdings);

  @override
  ConsumerState<_WhatIfCard> createState() => _WhatIfCardState();
}

class _WhatIfCardState extends ConsumerState<_WhatIfCard> {
  final _search = TextEditingController();
  final _amount = TextEditingController();
  Timer? _debounce;
  String _query = '';
  String? _symbol;
  bool _add = true;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _amount.dispose();
    super.dispose();
  }

  InputDecoration _field(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _muted),
        filled: true,
        fillColor: Colors.white.withValues(alpha: .05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      );

  @override
  Widget build(BuildContext context) {
    final held = widget.holdings.map((h) => h.symbol).toSet();
    // The app's own stock search: it reads the database, so every listed stock can be found
    final matches = _symbol != null || _query.isEmpty
        ? const <StockScore>[]
        : (ref.watch(searchProvider(_query)).valueOrNull ?? const <StockScore>[]).take(6).toList();
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    final sym = _symbol;
    final info = sym == null ? null : ref.watch(stockRiskProvider(sym)).valueOrNull;

    Widget? result;
    if (sym != null && info != null && amount > 0) {
      final before = RiskMath.snapshot(widget.holdings);
      final after = RiskMath.snapshot(RiskMath.applyChange(
        widget.holdings,
        sym,
        delta: _add ? amount : -amount,
        beta: info.beta,
        sector: info.sector,
      ));
      final warnings = _add ? RiskMath.warnings(after, sym, info.sector, context.t) : const <String>[];
      Widget row(String label, String from, String to) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                Text(from, style: const TextStyle(color: _muted, fontSize: 13)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward_rounded, size: 14, color: _muted),
                ),
                Text(to, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          );
      result = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          row('Portfolio beta', _beta(before.beta), _beta(after.beta)),
          row(context.t.riskStockShare(sym), _pct(before.stockWeight[sym] ?? 0), _pct(after.stockWeight[sym] ?? 0)),
          row(context.t.riskStockShare(info.sector), _pct(before.sectorWeight[info.sector] ?? 0), _pct(after.sectorWeight[info.sector] ?? 0)),
          if (info.beta == null)
            Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(context.t.riskStockNoBeta,
                  style: TextStyle(color: _muted, fontSize: 12)),
            ),
          for (final w in warnings)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 15, color: _gold),
                  const SizedBox(width: 6),
                  Expanded(child: Text(w, style: const TextStyle(color: Colors.white, fontSize: 12))),
                ],
              ),
            ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t.riskIfChange,
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          TextField(
            controller: _search,
            style: const TextStyle(color: Colors.white),
            cursorColor: _gold,
            decoration: _field(context.t.riskStockField),
            onChanged: (v) {
              setState(() => _symbol = null);
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                if (mounted) setState(() => _query = v.trim());
              });
            },
          ),
          for (final m in matches)
            Builder(builder: (context) {
              final s = SymbolUtils.normalize(m.instrument);
              // The card's own colour would hide the tap ripple without this layer
              return Material(
                type: MaterialType.transparency,
                child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(s, style: const TextStyle(color: Colors.white, fontSize: 13)),
                subtitle: Text(m.companyName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 12)),
                trailing: held.contains(s) ? Text(context.t.riskYouHold, style: TextStyle(color: _muted, fontSize: 11)) : null,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _symbol = s;
                    _query = '';
                    _search.text = s;
                    if (!held.contains(s)) _add = true;
                  });
                },
                ),
              );
            }),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _Chip(context.t.riskAdd, _add, () => setState(() => _add = true))),
              const SizedBox(width: 6),
              Expanded(
                child: _Chip(context.t.riskReduce, !_add, () {
                  if (sym == null || held.contains(sym)) setState(() => _add = false);
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white),
            cursorColor: _gold,
            decoration: _field(context.t.riskAmount),
            onChanged: (_) => setState(() {}),
          ),
          ?result,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Chip(this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          color: active ? Colors.white.withValues(alpha: .1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: active ? .25 : .08)),
        ),
        child: Text(label,
            style: TextStyle(color: active ? Colors.white : _muted, fontSize: 13, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
