import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/symbol_utils.dart';
import '../models/portfolio.dart';

class PortfolioRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<Portfolio>> getPortfolio() async {
    final user = client.auth.currentUser;

    if (user != null) {
      try {
        final userResponse = await client
            .from("Portfolio")
            .select()
            .eq("user_id", user.id)
            .order("Instrument");

        return userResponse
            .map<Portfolio>((json) => Portfolio.fromJson(json))
            .toList();
      } catch (e) {
        debugPrint("Notice: user_id portfolio query: $e");
      }
    }

    final response = await client
        .from("Portfolio")
        .select()
        .order("Instrument");

    debugPrint("Rows: ${response.length}");

    return response
        .map<Portfolio>((json) => Portfolio.fromJson(json))
        .toList();
  }

  Future<void> addHolding({
    required String instrument,
    required String companyName,
    required int qty,
    required double avgPrice,
    String sector = 'General',
    String industry = 'Diversified',
  }) async {
    final user = client.auth.currentUser;
    final totalInvested = qty * avgPrice;

    final Map<String, dynamic> payload = {
      if (user != null) 'user_id': user.id,
      'Instrument': instrument.trim().toUpperCase(),
      'Company_name': companyName.trim(),
      'YahooSymbol': SymbolUtils.getYahooSymbol(instrument),
      'Qty': qty,
      'Avg Price': avgPrice,
      'Total Invested': totalInvested,
      'Sector': sector,
      'Industry': industry,
      'Status': 'ACTIVE',
      'Investment_thesis': 'Added manually via portfolio manager.',
    };

    await client.from('Portfolio').insert(payload);
  }

  Future<void> updateHolding({
    required String id,
    required int qty,
    required double avgPrice,
    double? currentPrice,
  }) async {
    final totalInvested = qty * avgPrice;
    final Map<String, dynamic> updates = {
      'Qty': qty,
      'Avg Price': avgPrice,
      'Total Invested': totalInvested,
    };

    if (currentPrice != null && currentPrice > 0) {
      final currentVal = qty * currentPrice;
      updates['Current Val'] = currentVal;
      updates['Net P&L'] = currentVal - totalInvested;
    }

    await client.from('Portfolio').update(updates).eq('id', id);
  }

  Future<void> deleteHolding(String id) async {
    await client.from('Portfolio').delete().eq('id', id);
  }
}
