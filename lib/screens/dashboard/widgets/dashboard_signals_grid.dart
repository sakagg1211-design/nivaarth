import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/symbol_utils.dart';
import '../../../models/dashboard_summary.dart';
import '../../../providers/allocation_provider.dart';
import '../../../core/l10n/l10n_ext.dart';

class DashboardSignalsGrid extends ConsumerWidget {
  final DashboardSummary summary;

  const DashboardSignalsGrid({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Missing data shows a dash, never a placeholder stock or number
    const dash = '—';

    // 1. Biggest Winner
    final winnerSym = SymbolUtils.normalize(summary.biggestWinner.portfolio.instrument);
    final winnerPct = summary.biggestWinner.returnPercent;

    // 2. Weakest / Biggest Loser
    final weakestSym = SymbolUtils.normalize(summary.biggestLoser.portfolio.instrument);
    final weakestPct = summary.biggestLoser.returnPercent;

    // 3. Strongest holding: highest NV score among the user's own holdings
    final strongSym = SymbolUtils.normalize(summary.topOpportunity.instrument);
    final strongScore = summary.topOpportunity.overallScore;
    final hasStrong = strongSym.isNotEmpty && strongScore != null;

    // 4. Diversification: how evenly the value is spread over the sectors on the bantwara card
    final allocation = ref.watch(allocationProvider).valueOrNull;
    final divScore = allocation?.diversificationScore;
    final topSector = allocation?.topSectorPct;

    return Column(
      children: [
        // Row 1: BIGGEST WINNER | WEAKEST
        Row(
          children: [
            Expanded(
              child: _SignalMicroCard(
                title: context.t.signalWinner,
                subtitle: winnerSym.isEmpty ? dash : winnerSym,
                value: winnerSym.isEmpty ? dash : Formatters.percent(winnerPct, signed: true),
                valueColor: winnerPct >= 0 ? const Color(0xFF00E676) : const Color(0xFFFF5252),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SignalMicroCard(
                title: context.t.signalWeakest,
                subtitle: weakestSym.isEmpty ? dash : weakestSym,
                value: weakestSym.isEmpty ? dash : Formatters.percent(weakestPct, signed: true),
                valueColor: weakestPct < 0 ? const Color(0xFFFF5252) : const Color(0xFF00E676),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Row 2: TOP OPPORTUNITY | DIVERSIFICATION
        Row(
          children: [
            Expanded(
              child: _SignalMicroCard(
                title: context.t.signalStrongest,
                subtitle: hasStrong ? strongSym : context.t.signalNotAssessed,
                value: hasStrong ? '$strongScore/100' : dash,
                valueColor: const Color(0xFFE5A93C),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SignalMicroCard(
                title: context.t.signalDiversification,
                subtitle: topSector == null ? dash : context.t.signalTopSector(topSector.toStringAsFixed(0)),
                value: divScore == null ? dash : '$divScore/100',
                valueColor: (divScore ?? 0) >= 60 ? const Color(0xFF00E676) : const Color(0xFFE5A93C),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SignalMicroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final Color valueColor;

  const _SignalMicroCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF16171B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF282A30),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Micro label
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF858A94),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          // Subtitle / Instrument / Sector
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          // Metric value (% or score)
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
