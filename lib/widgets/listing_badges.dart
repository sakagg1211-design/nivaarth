import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/l10n/l10n_ext.dart';
import '../l10n/app_localizations.dart';
import '../models/listing_info.dart';
import '../core/theme/app_colors.dart';

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
            message: ListingInfoStrip.meaning(b, context.t),
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
      b.level == ListingBadgeLevel.warn ? AppColors.danger : AppColors.warning;
}

/// "Fundamentals as of 30 Oct 2026 · latest results: Sep 2026 quarter" (Hinglish in Hinglish mode), plus what each badge means
class ListingInfoStrip extends StatelessWidget {
  final ListingInfo? info;
  const ListingInfoStrip({super.key, required this.info});

  /// What a badge means, in the app language (the model's own text is Hinglish only).
  static String meaning(ListingBadge b, AppLocalizations t) => switch (b.label) {
        'Z' => t.badgeZMeaning,
        'T2T' => t.badgeT2TMeaning,
        'SME' => t.badgeSmeMeaning,
        _ => b.meaning,
      };

  static String? fundamentalsLine(ListingInfo? info, AppLocalizations t) {
    final asOf = info?.fundamentalsAsOf;
    if (asOf == null) return null;
    final q = info!.lastQuarter;
    return t.fundamentalsAsOf(DateFormat('d MMM yyyy').format(asOf)) +
        (q == null ? '' : t.fundamentalsLastQuarter(DateFormat('MMM yyyy').format(q)));
  }

  @override
  Widget build(BuildContext context) {
    final line = fundamentalsLine(info, context.t);
    final badges = info?.badges ?? const <ListingBadge>[];
    if (line == null && badges.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (badges.isNotEmpty) ...[
          ListingBadges(info: info),
          const SizedBox(height: 4),
          Text(badges.map((b) => '${b.label}: ${meaning(b, context.t)}').join('\n'),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 6),
        ],
        if (line != null) Text(line, style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
      ],
    );
  }
}
