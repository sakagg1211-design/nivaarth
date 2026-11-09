import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../providers/risk_provider.dart';
import '../../risk/risk_lab_page.dart';
import '../../../core/l10n/l10n_ext.dart';

const _muted = Color(0xFF8E929B);
const _up = Color(0xFF199E70);
const _down = Color(0xFFD95926);

/// India VIX and how many stocks rose or fell in the latest session.
class MacroCard extends ConsumerWidget {
  const MacroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(macroProvider).valueOrNull;
    if (data == null || data.isEmpty) return const SizedBox.shrink();
    final n = NumberFormat.decimalPattern('en_IN');
    final vixChange = data.vixChangePct;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF16171B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('India VIX', style: TextStyle(color: _muted, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(data.vix?.toStringAsFixed(2) ?? '—',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    Text(
                      vixChange == null ? '—' : '${vixChange >= 0 ? '+' : ''}${vixChange.toStringAsFixed(2)}%',
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.breadthDate == null
                          ? context.t.macroBreadth
                          : 'Breadth · ${DateFormat('d MMM').format(data.breadthDate!)}',
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    if (data.hasBreadth) ...[
                      Row(
                        children: [
                          Text(context.t.macroAdvances(n.format(data.advances)),
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                          const Spacer(),
                          Text(context.t.macroDeclines(n.format(data.declines)),
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: SizedBox(
                          height: 6,
                          child: Row(
                            children: [
                              Expanded(flex: data.advances! < 1 ? 1 : data.advances!, child: Container(color: _up)),
                              const SizedBox(width: 2),
                              Expanded(flex: data.declines! < 1 ? 1 : data.declines!, child: Container(color: _down)),
                            ],
                          ),
                        ),
                      ),
                    ] else
                      const Text('—', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE5A93C),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.science_outlined, size: 16),
              label: Text(context.t.macroWhatIf, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RiskLabPage()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
