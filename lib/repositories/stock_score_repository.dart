import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/symbol_utils.dart';
import '../models/stock_score.dart';

class StockScoreRepository {
  final SupabaseClient client = Supabase.instance.client;

  /// Everything the dashboard reads. Leaves out score_breakdown, which is over 3/4 of the data
  /// (about 6 MB for the universe) and would be fetched on every 2-minute refresh.
  static const dashboardColumns = 'Instrument,company_name,BusinessQuality,FinancialStrength,Growth,Valuation,'
      'Technical,Risk,OverallScore,Recommendation,Confidence,LastUpdated,DebtNotAssessed,'
      'ProvisionalCreditPending,ProvisionalBrokerMTF';

  /// Supabase returns at most 1,000 rows per request, so the ~2,600-stock universe
  /// is read page by page. Instrument is the tie-breaker so pages never overlap or skip.
  static Future<List<StockScore>> fetchAllScores(SupabaseClient client, {String columns = '*'}) async {
    const pageSize = 1000;
    final all = <StockScore>[];
    for (var from = 0;; from += pageSize) {
      final page = await client
          .from("StockScores")
          .select(columns)
          .order("OverallScore", ascending: false, nullsFirst: false)
          .order("Instrument", ascending: true)
          .range(from, from + pageSize - 1);
      all.addAll(page.map<StockScore>((json) => StockScore.fromJson(json)));
      if (page.length < pageSize) break;
    }
    return all;
  }

  Future<List<StockScore>> getScores() => fetchAllScores(client);

  Future<List<StockScore>> getDashboardScores() => fetchAllScores(client, columns: dashboardColumns);
Future<StockScore?> getScore(
  String instrument,
) async {
  final response = await client
      .from("StockScores")
      .select()
      .eq("Instrument", instrument)
      .maybeSingle();

  if (response == null) {
    return null;
  }

  return StockScore.fromJson(response);
}
  Future<StockScore?> getByInstrument(
    String instrument,
  ) async {
    final normalized = SymbolUtils.normalize(instrument);

    try {
      // 1. Exact match on clean Instrument
      final exact = await client
          .from("StockScores")
          .select()
          .eq("Instrument", normalized)
          .limit(1);

      if (exact.isNotEmpty) {
        return StockScore.fromJson(exact.first);
      }

      // 2. Case-insensitive fallback
      final ilikeMatch = await client
          .from("StockScores")
          .select()
          .ilike("Instrument", normalized)
          .limit(1);

      if (ilikeMatch.isNotEmpty) {
        return StockScore.fromJson(ilikeMatch.first);
      }
    } catch (e) {
      debugPrint("StockScores query error for $normalized: $e");
    }

    // Return null if not yet calculated in database.
    // The UI / Service will trigger on-demand backend quantitative onboarding.
    return null;
  }
}