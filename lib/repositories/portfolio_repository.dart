import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/symbol_utils.dart';
import '../models/portfolio.dart';

class PortfolioRepository {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<Portfolio>> getPortfolio() async {
    final user = client.auth.currentUser;

    // Strict multi-tenancy: Unauthenticated queries must NEVER leak data
    if (user == null) {
      debugPrint("PortfolioRepository: No authenticated user session. Returning empty holdings.");
      return const [];
    }

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
      debugPrint("Error fetching user portfolio: $e");
      return const [];
    }
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
    if (user == null) {
      throw Exception("User must be authenticated to add portfolio holdings.");
    }

    final totalInvested = qty * avgPrice;

    final Map<String, dynamic> payload = {
      'user_id': user.id,
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
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception("User must be authenticated to update portfolio holdings.");
    }

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

    // Strict ownership verification: id AND user_id must match
    await client
        .from('Portfolio')
        .update(updates)
        .eq('id', id)
        .eq('user_id', user.id);
  }

  Future<void> deleteHolding(String id) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception("User must be authenticated to delete portfolio holdings.");
    }

    // Strict ownership verification: id AND user_id must match
    await client
        .from('Portfolio')
        .delete()
        .eq('id', id)
        .eq('user_id', user.id);
  }
}
