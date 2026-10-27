import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/symbol_utils.dart';
import '../models/stock_score.dart';

class StockRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<StockScore>> getScores() async {
    final response = await client
        .from('StockScores')
        .select()
        .order('OverallScore', ascending: false, nullsFirst: false);

    return response
        .map<StockScore>((e) => StockScore.fromJson(e))
        .toList();
  }

  Future<List<StockScore>> searchStocks(String query) async {
    final cleanQ = query.trim();
    if (cleanQ.isEmpty) return const [];

    final List<StockScore> results = [];
    final Set<String> seenSymbols = {};

    try {
      // 1. Search StockScores by Instrument OR company_name
      final response = await client
          .from('StockScores')
          .select()
          .or('Instrument.ilike.%$cleanQ%,company_name.ilike.%$cleanQ%')
          .order('OverallScore', ascending: false, nullsFirst: false);

      for (final e in response) {
        final score = StockScore.fromJson(e);
        final norm = SymbolUtils.normalize(score.instrument);
        if (!seenSymbols.contains(norm)) {
          seenSymbols.add(norm);
          results.add(score);
        }
      }
    } catch (e) {
      debugPrint('StockScores search error: $e');
    }

    // 2. Query Supabase 'listedstocks' master table
    try {
      dynamic listedResponse;
      try {
        listedResponse = await client
            .from('listedstocks')
            .select()
            .or('symbol.ilike.%$cleanQ%,company_name.ilike.%$cleanQ%')
            .limit(30);
      } catch (_) {
        try {
          listedResponse = await client
              .from('listedstocks')
              .select()
              .ilike('symbol', '%$cleanQ%')
              .limit(30);
        } catch (_) {}
      }

      if (listedResponse != null) {
        for (final row in listedResponse) {
          final rawSym = (row['symbol'] ?? row['Ticker Symbols'] ?? row['ticker'] ?? row['Ticker'] ?? '').toString();
          final rawName = (row['company_name'] ?? row['Name'] ?? row['name'] ?? row['Company Name'] ?? '').toString();

          if (rawSym.trim().isEmpty) continue;

          final sym = SymbolUtils.normalize(rawSym);
          if (!seenSymbols.contains(sym)) {
            seenSymbols.add(sym);

            // Clean '(XNSE:...)' or '(XBOM:...)' from Name
            final cleanName = rawName
                .replaceAll(RegExp(r'\(XNSE:[^)]+\)'), '')
                .replaceAll(RegExp(r'\(XBOM:[^)]+\)'), '')
                .trim();

            final displayName = cleanName.isNotEmpty
                ? cleanName
                : SymbolUtils.getDisplayName(sym);

            // Not yet in StockScores - marked 0 so UI will trigger authentic on-demand onboarding
            results.add(
              StockScore(
                instrument: sym,
                companyName: displayName,
                businessQuality: 0,
                financialStrength: 0,
                growth: 0,
                valuation: 0,
                technical: 0,
                risk: 0,
                overallScore: 0,
                recommendation: 'PENDING',
                confidence: 0,
                lastUpdated: null,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('listedstocks query error: $e');
    }

    // 3. Augment from Market Universe Catalog
    final matches = SymbolUtils.searchUniverse(cleanQ);
    for (final m in matches) {
      final sym = m.key;
      final compName = m.value;
      if (!seenSymbols.contains(sym)) {
        seenSymbols.add(sym);
        results.add(
          StockScore(
            instrument: sym,
            companyName: compName,
            businessQuality: 0,
            financialStrength: 0,
            growth: 0,
            valuation: 0,
            technical: 0,
            risk: 0,
            overallScore: 0,
            recommendation: 'PENDING',
            confidence: 0,
            lastUpdated: null,
          ),
        );
      }
    }

    return results;
  }
}