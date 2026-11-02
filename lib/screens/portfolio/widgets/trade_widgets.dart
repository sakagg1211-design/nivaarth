import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/holding_math.dart';
import '../../../models/trade.dart';

/// Tappable trade-date row; opens a date picker limited to today or earlier.
class TradeDateField extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const TradeDateField({super.key, required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: date.isAfter(now) ? now : date,
          firstDate: DateTime(2000),
          lastDate: now,
          helpText: 'Trade ki date',
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2024),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF282A30)),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_rounded, color: Color(0xFF8E929B), size: 18),
            const SizedBox(width: 10),
            const Text('Trade date', style: TextStyle(color: Color(0xFF8E929B), fontSize: 13)),
            const Spacer(),
            Text(
              DateFormat('d MMM yyyy').format(date),
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Abhi" vs "Trade ke baad" box: Qty, average and Total Invested before and after one trade,
/// plus realized P&L for a sell. The saved figures come from the database; this is a preview.
class TradePreview extends StatelessWidget {
  final HoldingSummary start;
  final TradeSide side;
  final int? qty;
  final double? price;

  const TradePreview({
    super.key,
    required this.start,
    required this.side,
    required this.qty,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    HoldingSummary? after;
    String? error;
    final q = qty, p = price;
    if (q != null && q > 0 && p != null && p > 0) {
      try {
        after = HoldingMath.apply(start, side, q.toDouble(), p);
      } on OversellException catch (e) {
        error = e.toString();
      }
    }

    String holding(HoldingSummary s) => s.isClosed
        ? '0 shares (poora bik jayega)'
        : '${_qty(s.qty)} @ ${Formatters.currency(s.avgPrice)}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF121316),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF23252B)),
      ),
      child: Column(
        children: [
          _row('Abhi', holding(start)),
          if (after != null) ...[
            const SizedBox(height: 6),
            _row('Trade ke baad', holding(after), strong: true),
            const SizedBox(height: 6),
            _row('Total Invested', Formatters.currency(after.totalInvested)),
            if (side == TradeSide.sell) ...[
              const SizedBox(height: 6),
              _row(
                'Is sell ka realized P&L',
                Formatters.currency(after.realizedPl - start.realizedPl, signed: true),
                color: after.realizedPl >= start.realizedPl
                    ? const Color(0xFF00E676)
                    : const Color(0xFFFF5252),
              ),
            ],
          ],
          if (error != null) ...[
            const SizedBox(height: 6),
            Text(error, style: const TextStyle(color: Color(0xFFFF5252), fontSize: 12)),
          ],
        ],
      ),
    );
  }

  static String _qty(double v) =>
      v == v.roundToDouble() ? '${v.toStringAsFixed(0)} shares' : '$v shares';

  Widget _row(String label, String value, {bool strong = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8E929B), fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: strong ? 13 : 12,
            fontWeight: strong ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
