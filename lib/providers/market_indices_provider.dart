import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/live_market_quote.dart';
import '../models/price.dart';
import '../services/market_quote_service.dart';
import 'price_provider.dart';

class MarketIndexItem {
  final String name;
  final double value;
  final double pointChange;
  final double changePercent;
  final double dayHigh;
  final double dayLow;
  final bool isLive;

  const MarketIndexItem({
    required this.name,
    required this.value,
    required this.pointChange,
    required this.changePercent,
    required this.dayHigh,
    required this.dayLow,
    required this.isLive,
  });
}

class MarketIndicesState {
  final MarketIndexItem nifty;
  final MarketIndexItem sensex;

  const MarketIndicesState({
    required this.nifty,
    required this.sensex,
  });
}

final marketIndicesProvider = FutureProvider<MarketIndicesState>((ref) async {
  LiveMarketQuote? niftyQuote;
  LiveMarketQuote? sensexQuote;

  try {
    final results = await Future.wait([
      MarketQuoteService.instance.fetchLiveQuote('^NSEI'),
      MarketQuoteService.instance.fetchLiveQuote('^BSESN'),
    ]);
    if (results[0].currentPrice > 5000) niftyQuote = results[0];
    if (results[1].currentPrice > 10000) sensexQuote = results[1];
  } catch (_) {}

  // DB Prices Fallback
  Price? dbNifty;
  Price? dbSensex;
  try {
    final prices = await ref.watch(pricesProvider.future);
    for (final p in prices) {
      final sym = p.instrument.trim().toUpperCase();
      if ((sym == 'NIFTY 50' || sym == '^NSEI' || sym == 'NIFTY' || sym == 'NIFTY50') ||
          (sym.contains('NIFTY') && !sym.contains('BEES') && !sym.contains('ETF') && p.currentPrice > 5000)) {
        dbNifty = p;
      }
      if (sym == 'SENSEX' || sym == '^BSESN' || sym == 'BSE SENSEX' || (sym.contains('SENSEX') && p.currentPrice > 10000)) {
        dbSensex = p;
      }
    }
  } catch (_) {}

  // 1. Resolve NIFTY 50
  final MarketIndexItem niftyItem;
  if (niftyQuote != null && niftyQuote.currentPrice > 5000) {
    niftyItem = MarketIndexItem(
      name: 'NIFTY 50',
      value: niftyQuote.currentPrice,
      pointChange: niftyQuote.change,
      changePercent: niftyQuote.changePercent,
      dayHigh: niftyQuote.dayHigh > 0 ? niftyQuote.dayHigh : niftyQuote.currentPrice,
      dayLow: niftyQuote.dayLow > 0 ? niftyQuote.dayLow : niftyQuote.currentPrice,
      isLive: true,
    );
  } else if (dbNifty != null && dbNifty.currentPrice > 5000) {
    final hasPrev = dbNifty.previousClose > 0;
    final prev = hasPrev ? dbNifty.previousClose : dbNifty.currentPrice;
    final delta = hasPrev ? (dbNifty.currentPrice - prev) : 0.0;
    final pct = (hasPrev && prev > 0) ? (delta / prev) * 100 : 0.0;
    niftyItem = MarketIndexItem(
      name: 'NIFTY 50',
      value: dbNifty.currentPrice,
      pointChange: delta,
      changePercent: pct,
      dayHigh: dbNifty.dayHigh > 0 ? dbNifty.dayHigh : dbNifty.currentPrice,
      dayLow: dbNifty.dayLow > 0 ? dbNifty.dayLow : dbNifty.currentPrice,
      isLive: hasPrev,
    );
  } else {
    niftyItem = const MarketIndexItem(
      name: 'NIFTY 50',
      value: 22520.45,
      pointChange: 288.65,
      changePercent: 1.30,
      dayHigh: 22580.75,
      dayLow: 22294.75,
      isLive: false,
    );
  }

  // 2. Resolve SENSEX
  final MarketIndexItem sensexItem;
  if (sensexQuote != null && sensexQuote.currentPrice > 10000) {
    sensexItem = MarketIndexItem(
      name: 'SENSEX',
      value: sensexQuote.currentPrice,
      pointChange: sensexQuote.change,
      changePercent: sensexQuote.changePercent,
      dayHigh: sensexQuote.dayHigh > 0 ? sensexQuote.dayHigh : sensexQuote.currentPrice,
      dayLow: sensexQuote.dayLow > 0 ? sensexQuote.dayLow : sensexQuote.currentPrice,
      isLive: true,
    );
  } else if (dbSensex != null && dbSensex.currentPrice > 10000) {
    final hasPrev = dbSensex.previousClose > 0;
    final prev = hasPrev ? dbSensex.previousClose : dbSensex.currentPrice;
    final delta = hasPrev ? (dbSensex.currentPrice - prev) : 0.0;
    final pct = (hasPrev && prev > 0) ? (delta / prev) * 100 : 0.0;
    sensexItem = MarketIndexItem(
      name: 'SENSEX',
      value: dbSensex.currentPrice,
      pointChange: delta,
      changePercent: pct,
      dayHigh: dbSensex.dayHigh > 0 ? dbSensex.dayHigh : dbSensex.currentPrice,
      dayLow: dbSensex.dayLow > 0 ? dbSensex.dayLow : dbSensex.currentPrice,
      isLive: hasPrev,
    );
  } else {
    sensexItem = const MarketIndexItem(
      name: 'SENSEX',
      value: 72472.33,
      pointChange: 879.09,
      changePercent: 1.23,
      dayHigh: 72669.20,
      dayLow: 71739.49,
      isLive: false,
    );
  }

  return MarketIndicesState(
    nifty: niftyItem,
    sensex: sensexItem,
  );
});
