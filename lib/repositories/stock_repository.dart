import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/stock_score.dart';

class StockRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<StockScore>> getScores() async {
    final response = await client
        .from('StockScores')
        .select()
        .order('OverallScore', ascending: false);

    return response
        .map<StockScore>((e) => StockScore.fromJson(e))
        .toList();
  }

  Future<List<StockScore>> searchStocks(String query) async {
    final response = await client
        .from('StockScores')
        .select()
        .ilike('Instrument', '%$query%')
        .order('OverallScore', ascending: false);

    return response
        .map<StockScore>((e) => StockScore.fromJson(e))
        .toList();
  }
}