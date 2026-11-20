import '../../l10n/app_localizations.dart';
import '../../models/watchlist_item.dart';

/// The watchlist line about a stock, worded in the chosen language at display time.
/// Items saved before kinds existed keep their stored English text.
String takeawayText(WatchlistItem i, AppLocalizations t) {
  final a = i.takeawayArgs ?? const {};
  String s(String k) => '${a[k] ?? '—'}';
  return switch (i.takeawayKind) {
    'pending' => a['reason'] == null ? t.takeawayPending : t.takeawayPendingWhy(s('reason')),
    'review' => t.takeawayReview,
    'special' => t.takeawaySpecial(s('sector')),
    'pillars' => t.takeawayPillars(s('score'), s('pillars')),
    'score' => t.takeawayScore(s('score'), s('sector')),
    'none' => t.takeawayNoScore(s('sector')),
    _ => i.keyTakeaway,
  };
}
