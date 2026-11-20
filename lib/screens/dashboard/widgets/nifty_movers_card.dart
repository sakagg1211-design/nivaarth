import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/market_pulse.dart';
import '../../../providers/market_pulse_provider.dart';

const _surface = Color(0xFF16171B);
const _muted = Color(0xFF8E929B);
final _day = DateFormat('d MMM');

/// Nifty 50 top gainers and losers, with the market's mood: live Nifty 50 breadth in market
/// hours, the whole market's breadth from the last session after the close.
class NiftyMoversCard extends ConsumerWidget {
  const NiftyMoversCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(marketPulseProvider).valueOrNull;
    if (p == null || (p.gainers.isEmpty && p.losers.isEmpty && p.advances == null)) return const SizedBox.shrink();
    final t = context.t;

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
          Text(t.moversTitle, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          if (p.advances != null && p.declines != null) ...[
            const SizedBox(height: 6),
            Text(
              p.live
                  ? t.moodLive('${p.advances}', '${p.declines}')
                  : t.moodClosed('${p.advances}', '${p.declines}', p.asOf == null ? '—' : _day.format(p.asOf!)),
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            if (p.leaders.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final l in p.leaders)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(8)),
                      child: Text('${l.$1} ${Formatters.percent(l.$2, signed: true)}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ],
          ],
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Column(t.movesGainers, p.gainers)),
              const SizedBox(width: 16),
              Expanded(child: _Column(t.movesLosers, p.losers)),
            ],
          ),
          const SizedBox(height: 10),
          Text(t.moversFootnote, style: const TextStyle(color: _muted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _Column extends StatelessWidget {
  final String title;
  final List<Mover> items;
  const _Column(this.title, this.items);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        if (items.isEmpty) const Text('—', style: TextStyle(color: _muted, fontSize: 13)),
        for (final m in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(m.symbol, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ),
                Text(Formatters.percent(m.pct, signed: true),
                    style: TextStyle(color: m.pct >= 0 ? AppColors.success : AppColors.danger, fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
      ],
    );
  }
}
