import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/live_market_quote.dart';
import '../services/market_quote_service.dart';

final liveQuoteProvider = FutureProvider.family<LiveMarketQuote, String>((ref, symbol) async {
  return MarketQuoteService.instance.fetchLiveQuote(symbol);
});

class ChartQuery {
  final String symbol;
  final String range;

  const ChartQuery(this.symbol, this.range);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartQuery && symbol == other.symbol && range == other.range;

  @override
  int get hashCode => Object.hash(symbol, range);
}

final stockChartProvider = FutureProvider.family<List<double>, ChartQuery>((ref, query) async {
  return MarketQuoteService.instance.fetchChartPoints(query.symbol, query.range);
});

/// One year of daily closes and the 52-week range (null when Yahoo could not be reached)
final dailyHistoryProvider = FutureProvider.family<DailyHistory?, String>((ref, symbol) async {
  return MarketQuoteService.instance.fetchDailyHistory(symbol);
});
