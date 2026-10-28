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

  /// Yahoo chart endpoint. Browsers block direct Yahoo calls (no CORS headers),
  /// so the web build uses the same-origin proxy in beta-web/_worker.js.
  Uri _yahooChartUri(String symbol, String range, String interval) {
    final path = '${Uri.encodeComponent(symbol)}?range=$range&interval=$interval';
    return kIsWeb
        ? Uri.base.resolve('/api/yahoo/chart/$path')
        : Uri.parse('https://query1.finance.yahoo.com/v8/finance/chart/$path');
  }

  /// Returns true if Indian markets are currently closed (before 9:15 AM, after 4:30 PM IST, or weekends)
  bool isMarketClosedIST() {
    final nowIst = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    // Saturday (6) or Sunday (7)
    if (nowIst.weekday >= 6) return true;

    final minutes = nowIst.hour * 60 + nowIst.minute;
    const marketOpen = 9 * 60 + 15; // 09:15 AM
    const marketCloseSettled = 16 * 60 + 30; // 04:30 PM (16:30)

    return minutes < marketOpen || minutes >= marketCloseSettled;
  }

  /// Fetches real-time live market price from Yahoo Finance
  Future<LiveMarketQuote> fetchLiveQuote(String rawSymbol) async {
    final clean = SymbolUtils.normalize(rawSymbol);
    final isClosed = isMarketClosedIST();

    // 1. Check valid cache (if market is closed, cache never expires until market opens)
    if (_quoteCache.containsKey(clean)) {
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

    // 2. Query Yahoo symbol (supports stocks and indices like ^NSEI, ^BSESN)
    final querySymbol = SymbolUtils.getYahooSymbol(clean);
    final url = _yahooChartUri(querySymbol, '1d', '1d');

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
          final quote = LiveMarketQuote.fromYahooMeta(clean, meta as Map<String, dynamic>);
          _quoteCache[clean] = quote;
          _cacheTime[clean] = DateTime.now();
          return quote;
        }
      }
    } catch (_) {
      // Retry with BSE symbol if NSE fails
      try {
        final bseSymbol = '$clean.BO';
        final bseUrl = _yahooChartUri(bseSymbol, '1d', '1d');
        final bseResponse = await http.get(
          bseUrl,
          headers: {'User-Agent': 'Mozilla/5.0'},
        ).timeout(const Duration(seconds: 4));

        if (bseResponse.statusCode == 200) {
          final data = jsonDecode(bseResponse.body);
          final result = data['chart']?['result']?[0];
          final meta = result?['meta'];
          if (meta != null && meta['regularMarketPrice'] != null) {
            final quote = LiveMarketQuote.fromYahooMeta(clean, meta as Map<String, dynamic>);
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

          final quote = LiveMarketQuote(
            symbol: clean,
            currentPrice: dbPrice,
            previousClose: dbPrev,
            change: dbPrice - dbPrev,
            changePercent: dbPrev > 0 ? ((dbPrice - dbPrev) / dbPrev) * 100 : 0.0,
            dayHigh: dbHigh,
            dayLow: dbLow,
            volume: dbVol,
            timestamp: DateTime.now(),
          );
          _quoteCache[clean] = quote;
          _cacheTime[clean] = DateTime.now();
          return quote;
        }
      }
    } catch (_) {}

    // 4. Last cached quote, else 0.0 ("no price"); the UI shows that as unavailable,
    // never a made-up number
    if (_quoteCache.containsKey(clean)) {
      return _quoteCache[clean]!;
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
