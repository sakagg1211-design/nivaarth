// News for "Aaj kyun hila", as sent by the backend (/news/stock/{symbol} and /news/holdings).

double? _d(Object? v) => v is num ? v.toDouble() : null;
DateTime _local(Object? v) => DateTime.parse(v.toString()).toLocal();

class NewsHeadline {
  final int id;
  final String title;
  final String source;
  final String url;
  final DateTime publishedAt;

  const NewsHeadline({required this.id, required this.title, required this.source, required this.url, required this.publishedAt});

  factory NewsHeadline.fromJson(Map<String, dynamic> j) => NewsHeadline(
        id: (j['id'] as num).toInt(),
        title: j['title'].toString(),
        source: (j['source'] ?? '').toString(),
        url: (j['url'] ?? '').toString(),
        publishedAt: _local(j['published_at']),
      );
}

class MoveSplit {
  final double? stockPct, niftyPct, sectorPct;
  final String? sector, kind;

  const MoveSplit({this.stockPct, this.niftyPct, this.sectorPct, this.sector, this.kind});

  factory MoveSplit.fromJson(Map<String, dynamic>? j) => j == null
      ? const MoveSplit()
      : MoveSplit(
          stockPct: _d(j['stock_pct']),
          niftyPct: _d(j['nifty_pct']),
          sectorPct: _d(j['sector_pct']),
          sector: j['sector'] as String?,
          kind: j['kind'] as String?,
        );
}

List<NewsHeadline> _list(Object? v) =>
    [for (final x in (v as List? ?? const [])) NewsHeadline.fromJson((x as Map).cast<String, dynamic>())];

class StockNews {
  final DateTime sessionDate;
  final bool live;
  final MoveSplit move;
  final String? summaryEn, summaryHi;
  final List<NewsHeadline> session, afterClose, recent;

  const StockNews({
    required this.sessionDate,
    required this.live,
    required this.move,
    this.summaryEn,
    this.summaryHi,
    this.session = const [],
    this.afterClose = const [],
    this.recent = const [],
  });

  bool get isEmpty => session.isEmpty && afterClose.isEmpty && recent.isEmpty;

  factory StockNews.fromJson(Map<String, dynamic> j) {
    final s = j['summary'] as Map?;
    return StockNews(
      sessionDate: DateTime.parse(j['session_date'].toString()),
      live: j['live'] == true,
      move: MoveSplit.fromJson((j['move'] as Map?)?.cast<String, dynamic>()),
      summaryEn: s?['en'] as String?,
      summaryHi: s?['hi'] as String?,
      session: _list(j['session_headlines']),
      afterClose: _list(j['after_close']),
      recent: _list(j['recent']),
    );
  }
}

class HoldingNewsItem {
  final String symbol;
  final double? stockPct, rupeeMove;
  final int count;
  final String title, source;
  final DateTime publishedAt;

  const HoldingNewsItem({
    required this.symbol,
    this.stockPct,
    this.rupeeMove,
    required this.count,
    required this.title,
    required this.source,
    required this.publishedAt,
  });

  factory HoldingNewsItem.fromJson(Map<String, dynamic> j) => HoldingNewsItem(
        symbol: j['symbol'].toString(),
        stockPct: _d(j['stock_pct']),
        rupeeMove: _d(j['rupee_move']),
        count: (j['count'] as num? ?? 0).toInt(),
        title: j['title'].toString(),
        source: (j['source'] ?? '').toString(),
        publishedAt: _local(j['published_at']),
      );
}

class HoldingsNews {
  final DateTime sessionDate;
  final bool live;
  final Map<String, int> counts;
  final List<HoldingNewsItem> top;

  const HoldingsNews({required this.sessionDate, required this.live, this.counts = const {}, this.top = const []});

  factory HoldingsNews.fromJson(Map<String, dynamic> j) => HoldingsNews(
        sessionDate: DateTime.parse(j['session_date'].toString()),
        live: j['live'] == true,
        counts: {for (final e in ((j['counts'] as Map?) ?? const {}).entries) e.key.toString(): (e.value as num).toInt()},
        top: [for (final x in (j['top'] as List? ?? const [])) HoldingNewsItem.fromJson((x as Map).cast<String, dynamic>())],
      );
}
