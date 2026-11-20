import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/screens/notifications/notifications_page.dart';

final en = lookupAppLocalizations(const Locale('en'));
final hi = lookupAppLocalizations(const Locale('en', 'IN'));

void main() {
  test('one stock is singular', () {
    expect(en.closedCount(1), '1 stock fully sold');
    expect(en.portfolioTracked(1), '1 holding under active tracking.');
    expect(en.heroUnpriced(1), contains('1 stock '));
    expect(en.factStalePrice(1), '1 holding shows an old price.');
    expect(en.advQueries(1), '1 Query');
  });

  test('zero and two are plural', () {
    expect(en.closedCount(0), '0 stocks fully sold');
    expect(en.closedCount(2), '2 stocks fully sold');
    expect(en.factStalePrice(2), '2 holdings show an old price.');
  });

  test('two counts in one message each pick their own form', () {
    expect(en.importDone(1, 1), '1 trade imported (1 stock).');
    expect(en.importDone(3, 2), '3 trades imported (2 stocks).');
    expect(en.tradesCountDays(1, 1), '1 trade · 1 day');
  });

  test('Hinglish keeps its own wording and the number', () {
    expect(hi.closedCount(1), contains('1'));
    expect(hi.closedCount(1).contains('{'), isFalse);
  });

  test('notification filters show Hinglish names but keep their internal values', () {
    expect(NotificationsPage.filterLabel('All', hi), 'Sab');
    expect(NotificationsPage.filterLabel('Risks', hi), 'Risk');
    expect(NotificationsPage.filterLabel('System', en), 'System');
    expect(NotificationsPage.filters, ['All', 'Risks', 'Scores', 'System']);
  });
}
