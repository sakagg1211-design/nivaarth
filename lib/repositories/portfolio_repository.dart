import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/portfolio.dart';

class PortfolioRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<Portfolio>> getPortfolio() async {
    final response = await client
        .from("Portfolio")
        .select()
        .order("Instrument");

    debugPrint("Rows: ${response.length}");

    if (response.isNotEmpty) {
      debugPrint(response.first.toString());
    }

    final list = response
    .map<Portfolio>((json) => Portfolio.fromJson(json))
    .toList();

debugPrint("Model CurrentValue: ${list.first.currentValue}");
debugPrint("Model NetPL: ${list.first.netPL}");

return list;
  }
}
