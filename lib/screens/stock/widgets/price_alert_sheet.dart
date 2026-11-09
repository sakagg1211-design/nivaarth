import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/price_alert.dart';
import '../../../providers/price_alert_provider.dart';

const _muted = Color(0xFF8E929B);
const _gold = Color(0xFFE5A93C);

/// One active alert with a delete button; used in the sheet and on the alerts page.
class PriceAlertTile extends ConsumerWidget {
  final PriceAlert alert;
  final bool showSymbol;
  const PriceAlertTile({super.key, required this.alert, this.showSymbol = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = '${alert.isAbove ? 'Upar jaaye' : 'Neeche aaye'}: ₹${alert.targetPrice.toStringAsFixed(2)}';
    return Row(
      children: [
        Icon(alert.isAbove ? Icons.north_east_rounded : Icons.south_east_rounded, color: _muted, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(showSymbol ? '${alert.instrument} · $text' : text,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
        IconButton(
          tooltip: 'Alert hatao',
          icon: const Icon(Icons.delete_outline_rounded, color: _muted, size: 20),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              await ref.read(priceAlertRepositoryProvider).remove(alert.id);
            } catch (_) {
              messenger.showSnackBar(const SnackBar(content: Text('Alert hata nahi paaye. Dobara try karo.')));
              return;
            }
            // Outside the try: a sheet closed meanwhile must not report a delete that worked as failed
            if (context.mounted) ref.invalidate(activePriceAlertsProvider);
          },
        ),
      ],
    );
  }
}

/// Bottom sheet on the stock page: set a price alert and see this stock's active ones.
class PriceAlertSheet extends ConsumerStatefulWidget {
  final String symbol;
  final double currentPrice;
  const PriceAlertSheet({super.key, required this.symbol, required this.currentPrice});

  @override
  ConsumerState<PriceAlertSheet> createState() => _PriceAlertSheetState();
}

class _PriceAlertSheetState extends ConsumerState<PriceAlertSheet> {
  final _controller = TextEditingController();
  String _direction = PriceAlert.above;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final target = double.tryParse(_controller.text.trim());
    final existing = ref.read(activePriceAlertsProvider).valueOrNull ?? const <PriceAlert>[];
    final sym = widget.symbol.trim().toUpperCase();
    final problem = PriceAlert.validate(_direction, target, widget.currentPrice) ??
        (existing.any((a) => a.instrument.toUpperCase() == sym && a.matches(_direction, target!))
            ? 'Ye alert pehle se laga hai'
            : existing.length >= PriceAlert.maxActive
                ? 'Ek saath ${PriceAlert.maxActive} alert tak laga sakte ho'
                : null);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      await ref.read(priceAlertRepositoryProvider).add(widget.symbol, _direction, target!);
      ref.invalidate(activePriceAlertsProvider);
      _controller.clear();
    } catch (_) {
      if (mounted) setState(() => _error = 'Alert save nahi hua. Dobara try karo.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sym = widget.symbol.trim().toUpperCase();
    // valueOrNull: if the list cannot load, the form must still open (.value would throw)
    final mine = (ref.watch(activePriceAlertsProvider).valueOrNull ?? const <PriceAlert>[])
        .where((a) => a.instrument.toUpperCase() == sym)
        .toList();
    return Container(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF16171B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price alert · $sym',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            if (widget.currentPrice > 0) ...[
              const SizedBox(height: 4),
              Text('Abhi ka bhaav ₹${widget.currentPrice.toStringAsFixed(2)}',
                  style: const TextStyle(color: _muted, fontSize: 12.5)),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                _choice('Upar jaaye', PriceAlert.above),
                const SizedBox(width: 8),
                _choice('Neeche aaye', PriceAlert.below),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              style: const TextStyle(color: Colors.white),
              cursorColor: _gold, // the app theme's cursor is dark, invisible on this sheet
              decoration: InputDecoration(
                hintText: 'Bhaav (₹)',
                hintStyle: const TextStyle(color: _muted),
                errorText: _error,
                filled: true,
                fillColor: Colors.white.withValues(alpha: .05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _gold, foregroundColor: Colors.black),
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Save ho raha hai...' : 'Alert lagao'),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Market ke samay bhaav har 5 minute mein check hota hai. Bhaav pahunchne par Notifications mein dikhega.',
              style: TextStyle(color: _muted, fontSize: 11),
            ),
            if (mine.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final a in mine) PriceAlertTile(alert: a),
            ],
          ],
          ),
        ),
      ),
    );
  }

  Widget _choice(String label, String value) {
    final active = _direction == value;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() {
          _direction = value;
          _error = null;
        }),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white.withValues(alpha: .1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: active ? .25 : .08)),
          ),
          child: Text(label,
              style: TextStyle(color: active ? Colors.white : _muted, fontSize: 13, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

/// All active price alerts, opened from Notifications.
class PriceAlertsPage extends ConsumerWidget {
  const PriceAlertsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(activePriceAlertsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0C0D10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111215),
        foregroundColor: Colors.white,
        title: const Text('Mere price alerts',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _gold)),
        error: (_, _) => const Center(child: Text('Alerts load nahi hue', style: TextStyle(color: _muted))),
        data: (list) => list.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Koi active alert nahi. Kisi stock ke page se alert lagao.',
                      textAlign: TextAlign.center, style: TextStyle(color: _muted)),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [for (final a in list) PriceAlertTile(alert: a, showSymbol: true)],
              ),
      ),
    );
  }
}
