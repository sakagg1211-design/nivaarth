import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/stock_news.dart';

Map<String, dynamic> h(int id, String at) =>
    {'id': id, 'title': 'Headline $id', 'source': 'Mint', 'url': 'https://x/$id', 'published_at': at};

void main() {
  test('fromJson parses session, after_close, recent and converts to local time', () {
    final n = StockNews.fromJson({
      'symbol': 'TCS',
      'session_date': '2026-11-20',
      'live': false,
      'move': {'stock_pct': -4.2, 'nifty_pct': -0.8, 'sector': 'Technology', 'sector_pct': -3.6, 'kind': 'sector'},
      'summary': {'en': 'About US spending', 'hi': 'US kharche ke baare mein'},
      'session_headlines': [h(1, '2026-11-20T05:50:00+00:00')],
      'after_close': [h(2, '2026-11-20T13:30:00+00:00')],
      'recent': [h(3, '2026-11-17T05:00:00+00:00')],
    });
    expect(n.sessionDate, DateTime(2026, 11, 20));
    expect(n.live, isFalse);
    expect(n.move.kind, 'sector');
    expect(n.move.sectorPct, -3.6);
    expect(n.summaryHi, 'US kharche ke baare mein');
    expect(n.session.single.publishedAt, DateTime.utc(2026, 11, 20, 5, 50).toLocal());
    expect(n.session.single.publishedAt.isUtc, isFalse);
    expect(n.afterClose.single.id, 2);
    expect(n.recent.single.title, 'Headline 3');
  });

  test('null summary and missing sector are allowed', () {
    final n = StockNews.fromJson({
      'session_date': '2026-11-20',
      'live': true,
      'move': {'stock_pct': null, 'nifty_pct': null, 'sector': null, 'sector_pct': null, 'kind': null},
      'summary': null,
      'session_headlines': [],
      'after_close': [],
      'recent': [],
    });
    expect(n.summaryEn, isNull);
    expect(n.move.stockPct, isNull);
    expect(n.isEmpty, isTrue);
  });

  test('holdings news parses counts and top rows', () {
    final n = HoldingsNews.fromJson({
      'session_date': '2026-11-20',
      'live': true,
      'counts': {'TCS': 2, 'INFY': 1},
      'top': [
        {'symbol': 'TCS', 'stock_pct': -4.0, 'rupee_move': -400.0, 'count': 2, 'title': 'TCS slips', 'source': 'Mint',
         'published_at': '2026-11-20T05:50:00+00:00'}
      ],
    });
    expect(n.counts['TCS'], 2);
    expect(n.top.single.rupeeMove, -400.0);
    expect(n.top.single.publishedAt.isUtc, isFalse);
  });
}
