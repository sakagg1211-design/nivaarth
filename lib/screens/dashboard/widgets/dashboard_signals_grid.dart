import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/symbol_utils.dart';
import '../../../models/dashboard_summary.dart';
import '../../../models/live_portfolio.dart';

class DashboardSignalsGrid extends StatelessWidget {
  final DashboardSummary summary;
  final List<LivePortfolio> holdings;

  const DashboardSignalsGrid({
    super.key,
    required this.summary,
    this.holdings = const [],
  });

  @override
  Widget build(BuildContext context) {
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

    // 4. Diversification Score & Distinct Sector Count
    final Set<String> distinctSectors = {};
    for (final h in holdings) {
      final s = SymbolUtils.getSector(
        h.portfolio.instrument,
        dbSector: h.portfolio.sector,
      );
      distinctSectors.add(s);
    }
    final int sectorCount = distinctSectors.length;

    // Comprehensive Diversification Score out of 100
    // Ideal diversification for 30+ holdings is 8-15 sectors
    int computedDivScore;
    if (sectorCount >= 10) {
      computedDivScore = 88;
    } else if (sectorCount >= 7) {
      computedDivScore = 75;
    } else if (sectorCount >= 4) {
      computedDivScore = 60;
    } else {
      computedDivScore = 40;
    }

    return Column(
      children: [
        // Row 1: BIGGEST WINNER | WEAKEST
        Row(
          children: [
            Expanded(
              child: _SignalMicroCard(
                title: 'BIGGEST WINNER',
                subtitle: winnerSym.isEmpty ? dash : winnerSym,
                value: winnerSym.isEmpty ? dash : Formatters.percent(winnerPct, signed: true),
                valueColor: winnerPct >= 0 ? const Color(0xFF00E676) : const Color(0xFFFF5252),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SignalMicroCard(
                title: 'WEAKEST',
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
                title: 'STRONGEST HOLDING',
                subtitle: hasStrong ? strongSym : 'Not assessed',
                value: hasStrong ? '$strongScore/100' : dash,
                valueColor: const Color(0xFFE5A93C),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SignalMicroCard(
                title: 'DIVERSIFICATION',
                subtitle: sectorCount == 0 ? 'No holdings' : '$sectorCount sectors',
                value: sectorCount == 0 ? dash : '$computedDivScore/100',
                valueColor: const Color(0xFF00E676),
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
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF757A85),
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
