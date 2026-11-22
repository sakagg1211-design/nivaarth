import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/health_math.dart';

Color get _muted => AppColors.textSecondary;

/// What sets NV Health: each holding's NV Score and its weight, lowest score first.
/// Weights are percentages only, so Privacy Mode has nothing to hide.
Future<void> showHealthBreakdown(BuildContext context, List<HoldingScore> scores) {
  final rows = healthRows(scores);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * .8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ctx.t.healthSheetTitle, style: TextStyle(color: AppColors.ink, fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(ctx.t.healthExplain, style: TextStyle(color: _muted, fontSize: 12)),
              const SizedBox(height: 12),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final r in rows)
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 44),
                        child: Row(
                          children: [
                            Expanded(child: Text(r.symbol, style: TextStyle(color: AppColors.ink, fontSize: 13, fontWeight: FontWeight.w600))),
                            SizedBox(
                              width: 56,
                              child: Text(r.score == null ? '—' : '${r.score}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(color: AppColors.ink, fontSize: 13, fontWeight: FontWeight.w700)),
                            ),
                            SizedBox(
                              width: 96,
                              child: Text(r.score == null ? ctx.t.healthNotCounted : '${r.weightPct.toStringAsFixed(1)}%',
                                  textAlign: TextAlign.right, style: TextStyle(color: _muted, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
