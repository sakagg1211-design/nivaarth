import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/stock_insights.dart';
import '../models/peer_comparison.dart';

/// Facts behind the badges. The EMA figures are optional: until migration 22 the app cannot read
/// them, and an old row must not claim today's trend.
final stockFactsProvider = FutureProvider.autoDispose.family<StockFacts?, String>((ref, symbol) async {
  final client = Supabase.instance.client;
  final sym = symbol.trim().toUpperCase();
  final rows = await Future.wait<Map<String, dynamic>?>([
    client.from('ScreenerFundamentals').select('DebtToEquity,ROCE,ProfitGrowth5Y,Pledged,PAT12M').eq('Instrument', sym).maybeSingle(),
    client.from('StockTaxonomy').select('category,peer_industry').eq('Instrument', sym).maybeSingle(),
    // Optional: a failure here only drops the EMA badge
    client
        .from('TechnicalIndicators')
        .select('EMA50,EMA200,AsOfDate')
        .eq('Instrument', sym)
        .maybeSingle()
        .then<Map<String, dynamic>?>((r) => r, onError: (_) => null),
  ]);
  final s = rows[0];
  if (s == null) return null;
  final tax = rows[1];
  final t = rows[2];
  final recent = StockInsights.isRecent(DateTime.tryParse(t?['AsOfDate']?.toString() ?? ''), DateTime.now());
  return StockFacts(
    insurer: StockInsights.isInsurer(tax?['category']?.toString(), tax?['peer_industry']?.toString()),
    debtToEquity: numOrNull(s['DebtToEquity']),
    roce: numOrNull(s['ROCE']),
    profitGrowth5Y: numOrNull(s['ProfitGrowth5Y']),
    pledged: numOrNull(s['Pledged']),
    pat12m: numOrNull(s['PAT12M']),
    ema50: recent ? numOrNull(t?['EMA50']) : null,
    ema200: recent ? numOrNull(t?['EMA200']) : null,
  );
});

/// The stock and every other company in its Yahoo industry.
final peerComparisonProvider = FutureProvider.autoDispose.family<PeerData?, String>((ref, symbol) async {
  final client = Supabase.instance.client;
  final sym = symbol.trim().toUpperCase();
  final me = await client.from('StockTaxonomy').select('peer_industry').eq('Instrument', sym).maybeSingle();
  final industry = me?['peer_industry']?.toString();
  if (industry == null || industry.isEmpty) return null;
  final tax = await client.from('StockTaxonomy').select('Instrument').eq('peer_industry', industry).limit(1000);
  final names = tax.map((r) => r['Instrument'].toString()).toList();
  final rows = <Map<String, dynamic>>[];
  for (var i = 0; i < names.length; i += 200) {
    final part = names.sublist(i, i + 200 > names.length ? names.length : i + 200);
    final got = await client
        .from('ScreenerFundamentals')
        .select('Instrument,Company,MarketCapCr,PE,PriceToBook,ROCE,ROE,ROA,DebtToEquity,SalesGrowth5Y,ProfitGrowth5Y')
        .inFilter('Instrument', part);
    rows.addAll(got);
  }
  return PeerData.fromRows(industry, sym, rows);
});
