import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/listing_info.dart';

/// Small SME / Z / T2T chips; the meaning shows on long press or hover.
class ListingBadges extends StatelessWidget {
  final ListingInfo? info;
  final bool dense;
  const ListingBadges({super.key, required this.info, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final badges = info?.badges ?? const <ListingBadge>[];
    if (badges.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 5,
      runSpacing: 4,
      children: [
        for (final b in badges)
          Tooltip(
            message: b.meaning,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: dense ? 5 : 7, vertical: dense ? 1 : 2),
              decoration: BoxDecoration(
                color: _color(b).withValues(alpha: .14),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _color(b).withValues(alpha: .35)),
              ),
              child: Text(
                b.label,
                style: TextStyle(color: _color(b), fontSize: dense ? 9 : 10.5, fontWeight: FontWeight.w800),
              ),
            ),
          ),
      ],
    );
  }

  static Color _color(ListingBadge b) =>
      b.level == ListingBadgeLevel.warn ? const Color(0xFFFF5252) : const Color(0xFFFFB74D);
}

/// "Fundamentals: 30 Oct 2026 tak · aakhri results: Sep 2026 quarter", plus what each badge means
class ListingInfoStrip extends StatelessWidget {
  final ListingInfo? info;
  const ListingInfoStrip({super.key, required this.info});

  static String? fundamentalsLine(ListingInfo? info) {
    final asOf = info?.fundamentalsAsOf;
    if (asOf == null) return null;
    final q = info!.lastQuarter;
    return 'Fundamentals: ${DateFormat('d MMM yyyy').format(asOf)} tak'
        '${q == null ? '' : ' · aakhri results: ${DateFormat('MMM yyyy').format(q)} quarter'}';
  }

  @override
  Widget build(BuildContext context) {
    final line = fundamentalsLine(info);
    final badges = info?.badges ?? const <ListingBadge>[];
    if (line == null && badges.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (badges.isNotEmpty) ...[
          ListingBadges(info: info),
          const SizedBox(height: 4),
          Text(badges.map((b) => '${b.label}: ${b.meaning}').join('\n'),
              style: const TextStyle(color: Color(0xFF8E929B), fontSize: 11)),
          const SizedBox(height: 6),
        ],
        if (line != null) Text(line, style: const TextStyle(color: Color(0xFF858A94), fontSize: 11)),
      ],
    );
  }
}
