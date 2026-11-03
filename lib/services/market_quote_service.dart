import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/symbol_utils.dart';
import '../models/live_market_quote.dart';

/// One year of daily data for an index or stock: the 52-week range and the closes that the
/// technical indicators are computed from.
class DailyHistory {
  final double? high52;
  final double? low52;
  final List<double> closes; // oldest first

  const DailyHistory({required this.high52, required this.low52, required this.closes});
}

class MarketQuoteService {
  MarketQuoteService._();
  static final MarketQuoteService instance = MarketQuoteService._();

  final Map<String, LiveMarketQuote> _quoteCache = {};
  final Map<String, DateTime> _cacheTime = {};
  final Map<String, List<double>> _chartPointsCache = {};
  final Duration _cacheTtl = const Duration(seconds: 45);
  /// NSE bhavcopy previous close and its trading day, from LatestPrices (migration 19)
  final Map<String, (double, DateTime)> _officialPrev = {};
  static const int _batchSize = 8;
  /// Stocks whose NSE previous close was looked up (found or not), so a single quote for a
  /// searched stock asks LatestPrices once, not on every refresh
  final Set<String> _officialLooked = {};
  DateTime? _lookedDay;

  /// Yahoo chart endpoint. Browsers block direct Yahoo calls (no CORS headers),
  /// so the web build uses the same-origin proxy in beta-web/_worker.js.
  Uri _yahooChartUri(String symbol, String range, String interval) {
    final path = '${Uri.encodeComponent(symbol)}?range=$range&interval=$interval';
    return kIsWeb
        ? Uri.base.resolve('/api/yahoo/chart/$path')
        : Uri.parse('https://query1.finance.yahoo.com/v8/finance/chart/$path');
  }

  /// Cache rule, not a "market open" check (that is core/utils/market_hours.dart): quotes are
  /// treated as settled from 4:30 PM IST, an hour after the close, and until 9:15 AM / weekends.
  bool isMarketClosedIST() {
    final nowIst = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    // Saturday (6) or Sunday (7)
    if (nowIst.weekday >= 6) return true;

    final minutes = nowIst.hour * 60 + nowIst.minute;
    const marketOpen = 9 * 60 + 15; // 09:15 AM
    const marketCloseSettled = 16 * 60 + 30; // 04:30 PM (16:30)

    return minutes < marketOpen || minutes >= marketCloseSettled;
  }

  /// Loads the NSE previous close (PreviousClose + PrevCloseDate) for these stocks from
  /// LatestPrices. Before migration 19 the date column is missing; then nothing is loaded and
  /// Yahoo's previous close stays.
  Future<void> loadOfficialPrevCloses(Iterable<String> symbols) async {
    final list = symbols.map(SymbolUtils.normalize).where((s) => s.isNotEmpty).toSet().toList();
    if (list.isEmpty) return;
    _resetLookupsIfNewDay();
    try {
      final rows = await Supabase.instance.client
          .from('LatestPrices')
          .select('Instrument,PreviousClose,PrevCloseDate')
          .inFilter('Instrument', list);
      _officialLooked.addAll(list);
      for (final r in rows) {
        final prev = (r['PreviousClose'] as num?)?.toDouble();
        final date = DateTime.tryParse(r['PrevCloseDate']?.toString() ?? '');
        final sym = SymbolUtils.normalize(r['Instrument']?.toString() ?? '');
        if (prev != null && prev > 0 && date != null && sym.isNotEmpty) {
          _officialPrev[sym] = (prev, DateTime(date.year, date.month, date.day));
        }
      }
    } catch (_) {}
  }

  /// A new IST day has a new previous close: look every stock up again
  void _resetLookupsIfNewDay() {
    final today = LiveMarketQuote.istDate(DateTime.now());
    if (_lookedDay != today) {
      _officialLooked.clear();
      _lookedDay = today;
    }
  }

  LiveMarketQuote _withOfficial(LiveMarketQuote q) {
    final o = _officialPrev[q.symbol];
    return o == null ? q : q.withOfficialPreviousClose(o.$1, o.$2);
  }

  /// Quotes for many stocks: NSE previous closes loaded first, then Yahoo in batches of 8
  /// (all at once made some requests time out), and one more try for those that failed.
  /// [force] skips the 45-second cache, as a pull-to-refresh should.
  Future<Map<String, LiveMarketQuote>> fetchMany(Iterable<String> symbols, {bool force = false}) async {
    final list = symbols.map(SymbolUtils.normalize).where((s) => s.isNotEmpty).toSet().toList();
    final out = <String, LiveMarketQuote>{};
    if (list.isEmpty) return out;
    await loadOfficialPrevCloses(list);
    Future<void> run(List<String> syms, bool skipCache) async {
      for (var i = 0; i < syms.length; i += _batchSize) {
        final batch = syms.sublist(i, i + _batchSize > syms.length ? syms.length : i + _batchSize);
        final quotes = await Future.wait(batch.map((s) => fetchLiveQuote(s, force: skipCache)));
        for (var j = 0; j < batch.length; j++) {
          out[batch[j]] = quotes[j];
        }
      }
    }

    await run(list, force);
    final failed = list.where((s) => !(out[s]?.isFresh ?? false)).toList();
    if (failed.isNotEmpty && !isMarketClosedIST()) await run(failed, true);
    return out;
  }

  /// Fetches real-time live market price from Yahoo Finance
  Future<LiveMarketQuote> fetchLiveQuote(String rawSymbol, {bool force = false}) async {
    final clean = SymbolUtils.normalize(rawSymbol);
    final isClosed = isMarketClosedIST();

    // 1. Check valid cache (if market is closed, cache never expires until market opens)
    if (!force && _quoteCache.containsKey(clean)) {
      if (isClosed) {
        return _quoteCache[clean]!;
      }
      if (_cacheTime.containsKey(clean)) {
        final age = DateTime.now().difference(_cacheTime[clean]!);
        if (age < _cacheTtl) {
          return _quoteCache[clean]!;
        }
      }
    }

    // NSE previous close for a stock opened on its own (search, stock page): looked up once a day
    _resetLookupsIfNewDay();
    if (!_officialLooked.contains(clean) && !clean.startsWith('^')) {
      await loadOfficialPrevCloses([clean]);
    }

    // 2. Query Yahoo symbol (supports stocks and indices like ^NSEI, ^BSESN)
    final querySymbol = SymbolUtils.getYahooSymbol(clean);
    // 5 daily candles: the previous close is taken from them (see LiveMarketQuote.previousSessionClose)
    final url = _yahooChartUri(querySymbol, '5d', '1d');

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['chart']?['result']?[0];
        final meta = result?['meta'];

        if (meta != null && meta['regularMarketPrice'] != null) {
          final quote = _withOfficial(LiveMarketQuote.fromYahooMeta(
            clean,
            meta as Map<String, dynamic>,
            timestamps: result?['timestamp'] as List?,
            closes: result?['indicators']?['quote']?[0]?['close'] as List?,
          ));
          _quoteCache[clean] = quote;
          _cacheTime[clean] = DateTime.now();
          return quote;
        }
      }
    } catch (_) {
      // Retry with BSE symbol if NSE fails
      try {
        final bseSymbol = '$clean.BO';
        final bseUrl = _yahooChartUri(bseSymbol, '5d', '1d');
        final bseResponse = await http.get(
          bseUrl,
          headers: {'User-Agent': 'Mozilla/5.0'},
        ).timeout(const Duration(seconds: 4));

        if (bseResponse.statusCode == 200) {
          final data = jsonDecode(bseResponse.body);
          final result = data['chart']?['result']?[0];
          final meta = result?['meta'];
          if (meta != null && meta['regularMarketPrice'] != null) {
            final quote = _withOfficial(LiveMarketQuote.fromYahooMeta(
            clean,
            meta as Map<String, dynamic>,
            timestamps: result?['timestamp'] as List?,
            closes: result?['indicators']?['quote']?[0]?['close'] as List?,
          ));
            _quoteCache[clean] = quote;
            _cacheTime[clean] = DateTime.now();
            return quote;
          }
        }
      } catch (_) {}
    }

    // 3. Fallback to Supabase LatestPrices database record
    try {
      final res = await Supabase.instance.client
          .from('LatestPrices')
          .select()
          .eq('Instrument', clean)
          .maybeSingle();

      if (res != null && res['CurrentPrice'] != null) {
        final dbPrice = (res['CurrentPrice'] as num).toDouble();
        if (dbPrice > 0) {
          final dbPrev = (res['PreviousClose'] as num?)?.toDouble() ?? dbPrice;
          final dbHigh = (res['DayHigh'] as num?)?.toDouble() ?? dbPrice;
          final dbLow = (res['DayLow'] as num?)?.toDouble() ?? dbPrice;
          final dbVol = (res['Volume'] as num?)?.toInt() ?? 0;
          final dbTime = DateTime.tryParse(res['LastUpdated']?.toString() ?? '');
          final dbPrevDate = DateTime.tryParse(res['PrevCloseDate']?.toString() ?? '');

          final quote = LiveMarketQuote(
            symbol: clean,
            currentPrice: dbPrice,
            previousClose: dbPrev,
            change: dbPrice - dbPrev,
            changePercent: dbPrev > 0 ? ((dbPrice - dbPrev) / dbPrev) * 100 : 0.0,
            dayHigh: dbHigh,
            dayLow: dbLow,
            volume: dbVol,
            // When the database price was set, not now: a fallback must not look fresh
            timestamp: dbTime ?? DateTime.now(),
            previousCloseDate: dbPrevDate,
            fetchedAt: DateTime.now(),
            source: 'database',
          );
          // Not cached: the next refresh tries Yahoo again
          return quote;
        }
      }
    } catch (_) {}

    // 4. Last cached quote, else 0.0 ("no price"); the UI shows that as unavailable,
    // never a made-up number
    if (_quoteCache.containsKey(clean)) {
      return _quoteCache[clean]!.asCached();
    }

    final fallbackQuote = LiveMarketQuote(
      symbol: clean,
      currentPrice: 0.0,
      previousClose: 0.0,
      change: 0.0,
      changePercent: 0.0,
      dayHigh: 0.0,
      dayLow: 0.0,
      volume: 0,
      timestamp: DateTime.now(),
      source: 'none',
    );

    return fallbackQuote;
  }

  /// Fetches historical price points for charting
  Future<List<double>> fetchChartPoints(String rawSymbol, String range) async {
    final clean = SymbolUtils.normalize(rawSymbol);
    final cacheKey = '$clean:${range.toUpperCase()}';

    if (_chartPointsCache.containsKey(cacheKey) && isMarketClosedIST()) {
      return _chartPointsCache[cacheKey]!;
    }

    final nseSymbol = SymbolUtils.getYahooSymbol(clean);

    String yRange;
    String yInterval;

    switch (range.toUpperCase()) {
      case '1D':
        yRange = '1d';
        yInterval = '5m';
        break;
      case '1W':
        yRange = '5d';
        yInterval = '15m';
        break;
      case '1M':
        yRange = '1mo';
        yInterval = '1d';
        break;
      case '3M':
        yRange = '3mo';
        yInterval = '1d';
        break;
      case '1Y':
        yRange = '1y';
        yInterval = '1wk';
        break;
      case 'ALL':
        yRange = '5y';
        yInterval = '1mo';
        break;
      default:
        yRange = '1mo';
        yInterval = '1d';
    }

    final url = _yahooChartUri(nseSymbol, yRange, yInterval);

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'Mozilla/5.0'},
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['chart']?['result']?[0];
        final quotes = result?['indicators']?['quote']?[0];
        final closeList = quotes?['close'] as List?;

        if (closeList != null && closeList.isNotEmpty) {
          final validPoints = <double>[];
          for (final c in closeList) {
            if (c != null && c is num) {
              validPoints.add(c.toDouble());
            }
          }
          if (validPoints.length >= 2) {
            _chartPointsCache[cacheKey] = validPoints;
            return validPoints;
          }
        }
      }
    } catch (_) {}

    if (_chartPointsCache.containsKey(cacheKey)) {
      return _chartPointsCache[cacheKey]!;
    }

    return const [];
  }

  /// One year of daily candles from Yahoo. The 52-week range is Yahoo's own figure when given,
  /// else the year's highest high / lowest low. Null when nothing could be fetched.
  Future<DailyHistory?> fetchDailyHistory(String rawSymbol) async {
    final symbol = SymbolUtils.getYahooSymbol(SymbolUtils.normalize(rawSymbol));
    try {
      final response = await http
          .get(_yahooChartUri(symbol, '1y', '1d'), headers: {'User-Agent': 'Mozilla/5.0'})
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final result = jsonDecode(response.body)['chart']?['result']?[0];
      final meta = result?['meta'] as Map?;
      final quote = result?['indicators']?['quote']?[0] as Map?;
      List<double> nums(dynamic list) =>
          (list as List? ?? const []).whereType<num>().map((v) => v.toDouble()).toList();
      final closes = nums(quote?['close']);
      final highs = nums(quote?['high']);
      final lows = nums(quote?['low']);
      if (closes.isEmpty) return null;
      final metaHigh = (meta?['fiftyTwoWeekHigh'] as num?)?.toDouble();
      final metaLow = (meta?['fiftyTwoWeekLow'] as num?)?.toDouble();
      return DailyHistory(
        high52: metaHigh ?? (highs.isEmpty ? null : highs.reduce((a, b) => a > b ? a : b)),
        low52: metaLow ?? (lows.isEmpty ? null : lows.reduce((a, b) => a < b ? a : b)),
        closes: closes,
      );
    } catch (_) {
      return null;
    }
  }
}
