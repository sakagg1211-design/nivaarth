import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/stock_score.dart';

class StockScoreRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<StockScore>> getScores() async {
    final response = await client
        .from("StockScores")
        .select()
        .order("OverallScore", ascending: false);

    print("Stock Scores : ${response.length}");

    return response
        .map<StockScore>(
          (json) => StockScore.fromJson(json),
        )
        .toList();
  }

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
}