import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/price.dart';

class PriceRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<Price>> getPrices() async {
    final response = await client
        .from("LatestPrices")
        .select()
        .order("Instrument");

    print("PRICE ROWS : ${response.length}");

    if (response.isNotEmpty) {
      print(response.first);
    }

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