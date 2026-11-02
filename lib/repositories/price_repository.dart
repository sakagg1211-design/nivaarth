import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/price.dart';

class PriceRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<Price>> getPrices() async {
    final response = await client
        .from("LatestPrices")
        .select()
        .order("Instrument");

    return response
        .map<Price>((json) => Price.fromJson(json))
        .toList();
  }

  /// Only these stocks. Reading all of LatestPrices (3,500+ rows) stops at Supabase's
  /// 1,000-row cap, so stocks late in the alphabet went missing.
  Future<List<Price>> getPricesFor(List<String> instruments) async {
    if (instruments.isEmpty) return const [];
    final response = await client
        .from("LatestPrices")
        .select()
        .inFilter("Instrument", instruments);

    return response
        .map<Price>((json) => Price.fromJson(json))
        .toList();
  }

  Future<Price?> getPrice(String instrument) async {
    final response = await client
        .from("LatestPrices")
        .select()
        .eq("Instrument", instrument)
        .maybeSingle();

    if (response == null) return null;

    return Price.fromJson(response);
  }
}