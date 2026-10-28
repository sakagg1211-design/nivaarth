import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/symbol_utils.dart';
import '../models/stock_score.dart';
import 'stock_score_repository.dart';

class StockRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<StockScore>> getScores() => StockScoreRepository.fetchAllScores(client);

  Future<List<StockScore>> searchStocks(String query) async {
    // Characters that would break the PostgREST or() filter are dropped
    final cleanQ = query.trim().replaceAll(RegExp(r'[^A-Za-z0-9 &.\-]'), '');
    if (cleanQ.isEmpty) return const [];
    // Old tickers resolve to their current symbol (ZOMATO -> ETERNAL)
    final querySym = SymbolUtils.normalize(cleanQ);

    final List<StockScore> results = [];
    final Set<String> seenSymbols = {};

    try {
      // 1. Search StockScores by Instrument OR company_name (plus the renamed symbol)
      final response = await client
          .from('StockScores')
          .select()
          .or('Instrument.ilike.%$cleanQ%,company_name.ilike.%$cleanQ%,Instrument.eq.$querySym')
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

    return rankByRelevance(results, cleanQ);
  }

  /// Exact ticker first, then ticker prefix, then company-name prefix / word prefix, then the
  /// rest; ties keep their original (score) order. Without this, a short ticker such as BEL
  /// is pushed out of the top suggestions by BELRISE, ABELLON and similar matches.
  static List<StockScore> rankByRelevance(List<StockScore> items, String query) {
    final q = query.trim().toUpperCase();
    final qSym = SymbolUtils.normalize(q);

    int rank(StockScore s) {
      final sym = SymbolUtils.normalize(s.instrument);
      final name = s.companyName.toUpperCase();
      if (sym == qSym || sym == q) return 0;
      if (sym.startsWith(q)) return 1;
      if (name.startsWith(q)) return 2;
      if (name.split(RegExp(r'\s+')).any((w) => w.startsWith(q))) return 3;
      return 4;
    }

    final indexed = items.asMap().entries.toList()
      ..sort((a, b) {
        final byRank = rank(a.value).compareTo(rank(b.value));
        return byRank != 0 ? byRank : a.key.compareTo(b.key);
      });
    return indexed.map((e) => e.value).toList();
  }
}