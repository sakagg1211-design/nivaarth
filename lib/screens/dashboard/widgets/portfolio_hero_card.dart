import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/formatters.dart';
import '../../../providers/privacy_provider.dart';

class PortfolioHeroCard extends ConsumerWidget {
  final double currentValue;
  final double investedValue;
  final double netPnL;
  final double returnPercent;
  final double todayPnL;
  final double todayReturnPercent;
  final int holdings;
  final double aiConfidence;
  final bool isMarketOpen;
  final int unpricedHoldings;
  final int staleHoldings;
  final DateTime? pricesAsOf;

  const PortfolioHeroCard({
    super.key,
    required this.currentValue,
    required this.investedValue,
    required this.netPnL,
    required this.returnPercent,
    this.todayPnL = 0.0,
    this.todayReturnPercent = 0.0,
    required this.holdings,
    required this.aiConfidence,
    this.isMarketOpen = false,
    this.unpricedHoldings = 0,
    this.staleHoldings = 0,
    this.pricesAsOf,
  });

  String? get _asOfLabel {
    final t = pricesAsOf?.toLocal();
    if (t == null) return null;
    final now = DateTime.now();
    final sameDay = t.year == now.year && t.month == now.month && t.day == now.day;
    final time = DateFormat('h:mm a').format(t);
    return sameDay
        ? 'Prices as of $time'
        : 'Prices as of ${DateFormat('d MMM').format(t)}, $time';
  }

  String? get _priceNote {
    if (unpricedHoldings > 0) {
      return '$unpricedHoldings stock ka price nahi mila — total mein shaamil nahi';
    }
    if (staleHoldings > 0) {
      return '$staleHoldings stock ka live price nahi mila — pichhla saved price dikh raha hai';
    }
    return null;
  }

  bool get isProfit => netPnL >= 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacy = ref.watch(privacyModeProvider);
    final tone = isProfit ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    final pnlBadgeBg = isProfit
        ? const Color(0x1F00E676)
        : const Color(0x26FF5252);

    final isDayUp = todayPnL >= 0;
    final dayTone = isDayUp ? const Color(0xFF00E676) : const Color(0xFFFF5252);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF16171B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF282A30),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subheader label
          const Text(
            'PORTFOLIO VALUE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8E929B),
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          // Big ₹ Valuation
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              isPrivacy ? '₹ ••••••' : Formatters.currency0(currentValue),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                height: 1.1,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Total P&L Badge + "Total P&L" text
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: pnlBadgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      size: 14,
                      color: tone,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPrivacy
                          ? '•••••• (••••)'
                          : '${Formatters.currency0(netPnL, signed: true)} (${Formatters.percent(returnPercent, signed: true)})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: tone,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Total P&L',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8E929B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Divider subtle line
          Container(
            height: 1,
            width: double.infinity,
            color: const Color(0xFF23252B),
          ),

          const SizedBox(height: 12),

          // Today row: "Today" on left, "₹X,XXX  +X.XX%" on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8E929B),
                ),
              ),
              Text(
                isPrivacy
                    ? '••••••'
                    : '${isDayUp ? '+' : '-'}${Formatters.currency0(todayPnL.abs())}  ${isDayUp ? '+' : ''}${todayReturnPercent.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: dayTone,
                ),
              ),
            ],
          ),

          if (_asOfLabel != null) ...[
            const SizedBox(height: 8),
            Text(
              _asOfLabel!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B6F78),
              ),
            ),
          ],

          if (_priceNote != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: Color(0xFFFFB74D),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _priceNote!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFFB74D),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}