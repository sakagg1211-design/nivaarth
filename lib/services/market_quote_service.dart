import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/utils/symbol_utils.dart';
import '../models/live_market_quote.dart';

class MarketQuoteService {
  MarketQuoteService._();
  static final MarketQuoteService instance = MarketQuoteService._();

  final Map<String, LiveMarketQuote> _quoteCache = {};
  final Map<String, DateTime> _cacheTime = {};
  final Map<String, List<double>> _chartPointsCache = {};
  final Duration _cacheTtl = const Duration(seconds: 45);

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
    final url = Uri.parse('https://query1.finance.yahoo.com/v8/finance/chart/$querySymbol?range=1d&interval=1d');

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
        final bseUrl = Uri.parse('https://query1.finance.yahoo.com/v8/finance/chart/$bseSymbol?range=1d&interval=1d');
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

    // 3. Fallback to cached value or estimated baseline
    if (_quoteCache.containsKey(clean)) {
      return _quoteCache[clean]!;
    }

    final fallbackPrice = SymbolUtils.getEstimatedPrice(clean);
    final fallbackQuote = LiveMarketQuote(
      symbol: clean,
      currentPrice: fallbackPrice,
      previousClose: fallbackPrice,
      change: 0.0,
      changePercent: 0.0,
      dayHigh: fallbackPrice,
      dayLow: fallbackPrice,
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

    final nseSymbol = clean.endsWith('.NS') || clean.endsWith('.BO') ? clean : '$clean.NS';

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

    final url = Uri.parse('https://query1.finance.yahoo.com/v8/finance/chart/$nseSymbol?range=$yRange&interval=$yInterval');

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
}
