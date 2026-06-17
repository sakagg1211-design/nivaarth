import '../models/stock_score.dart';
import '../services/supabase_service.dart';

class StockRepository {
  Future<List<StockScore>> getScores() async {

    final response = await SupabaseService.client
        .from("StockScores")
        .select()
        .order("OverallScore", ascending: false);

    return response
        .map<StockScore>((e) => StockScore.fromJson(e))
        .toList();
  }
}