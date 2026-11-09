import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/allocation_math.dart';
import '../core/utils/risk_math.dart';
import '../core/utils/stock_insights.dart';
import '../models/peer_comparison.dart';
import '../repositories/listing_repository.dart';
import '../services/market_quote_service.dart';
import 'live_portfolio_provider.dart';

class RiskInfo {
  final double? beta;
  final String sector;
  final double? pe;
  const RiskInfo(this.beta, this.sector, [this.pe]);
}

/// Beta and sector for these symbols. A beta older than the freshness limit counts as missing.
Future<Map<String, RiskInfo>> _loadRiskInfo(List<String> symbols) async {
  final client = Supabase.instance.client;
  final betas = <String, double?>{};
  final pes = <String, double?>{};
  for (var i = 0; i < symbols.length; i += 200) {
    final part = symbols.sublist(i, i + 200 > symbols.length ? symbols.length : i + 200);
    final fundamentals = await client.from('ScreenerFundamentals').select('Instrument,PE').inFilter('Instrument', part);
    for (final r in fundamentals) {
      pes[r['Instrument'].toString().toUpperCase()] = numOrNull(r['PE']);
    }
    try {
      final rows = await client.from('TechnicalIndicators').select('Instrument,Beta1Y,BetaAsOf').inFilter('Instrument', part);
      for (final r in rows) {
        final asOf = DateTime.tryParse(r['BetaAsOf']?.toString() ?? '');
        betas[r['Instrument'].toString().toUpperCase()] =
            StockInsights.isRecent(asOf, DateTime.now()) ? numOrNull(r['Beta1Y']) : null;
      }
    } catch (_) {
      // Before migration 24 there is no beta column; every beta stays missing
    }
  }
  final sectors = await ListingRepository().sectorsFor(symbols);
  return {for (final s in symbols) s: RiskInfo(betas[s], sectors[s] ?? AllocationMath.others, pes[s])};
}

/// The portfolio as the what-if and stress sums need it.
final riskHoldingsProvider = FutureProvider.autoDispose<List<RiskHolding>>((ref) async {
  final holdings = await ref.watch(livePortfolioProvider.future);
  final priced = holdings.where((h) => !h.isPriceUnavailable && h.currentValue > 0).toList();
  if (priced.isEmpty) return const [];
  final symbols = priced.map((h) => h.portfolio.instrument.trim().toUpperCase()).toSet().toList()..sort();
  final info = await _loadRiskInfo(symbols);
  return [
    for (final h in priced)
      () {
        final s = h.portfolio.instrument.trim().toUpperCase();
        return RiskHolding(s, h.currentValue, info[s]?.beta, info[s]?.sector ?? AllocationMath.others, pe: info[s]?.pe);
      }(),
  ];
});

/// Beta and sector for a stock picked in the what-if box.
final stockRiskProvider = FutureProvider.autoDispose.family<RiskInfo?, String>((ref, symbol) async {
  final s = symbol.trim().toUpperCase();
  return (await _loadRiskInfo([s]))[s];
});

class MacroData {
  final double? vix;
  final double? vixChangePct;
  final int? advances;
  final int? declines;
  final int? unchanged;
  final DateTime? breadthDate;

  const MacroData({this.vix, this.vixChangePct, this.advances, this.declines, this.unchanged, this.breadthDate});

  bool get hasBreadth => advances != null && declines != null;
  bool get isEmpty => vix == null && !hasBreadth;
}

/// India VIX from Yahoo and the latest session's breadth. Either can be missing on its own.
final macroProvider = FutureProvider<MacroData>((ref) async {
  double? vix;
  double? vixChange;
  try {
    final q = await MarketQuoteService.instance.fetchLiveQuote('^INDIAVIX');
    if (q.currentPrice > 0) {
      vix = q.currentPrice;
      vixChange = q.changePercent;
    }
  } catch (_) {}
  Map<String, dynamic>? row;
  try {
    row = await Supabase.instance.client
        .from('MarketBreadth')
        .select('trade_date,advances,declines,unchanged')
        .order('trade_date', ascending: false)
        .limit(1)
        .maybeSingle();
  } catch (_) {
    // Before migration 24 there is no MarketBreadth table
  }
  return MacroData(
    vix: vix,
    vixChangePct: vixChange,
    advances: (row?['advances'] as num?)?.toInt(),
    declines: (row?['declines'] as num?)?.toInt(),
    unchanged: (row?['unchanged'] as num?)?.toInt(),
    breadthDate: DateTime.tryParse(row?['trade_date']?.toString() ?? ''),
  );
});
