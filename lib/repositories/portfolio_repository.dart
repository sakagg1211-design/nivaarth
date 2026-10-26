import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/symbol_utils.dart';
import '../models/portfolio.dart';

class PortfolioRepository {
  final SupabaseClient client = Supabase.instance.client;

  // ETFs are not in ScreenerFundamentals. Same exact-match list and suffixes
  // as KNOWN_ETFS / ETF_SUFFIXES in backend/ai_scoring_service.py.
  static const Set<String> _knownEtfs = {
    'NIFTYBEES', 'TATSILV', 'MIDSMALL', 'MON100', 'MOM100',
  };

  static bool _isListedEtf(String sym) =>
      _knownEtfs.contains(sym) ||
      sym.endsWith('BEES') ||
      sym.endsWith('IETF') ||
      sym.endsWith('ETF');

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

    final cleanSym = instrument.trim().toUpperCase();

    // 1. Duplicate check: prevent duplicate holdings for same user
    final existing = await client
        .from('Portfolio')
        .select('id')
        .eq('user_id', user.id)
        .eq('Instrument', cleanSym)
        .limit(1)  // older duplicate rows would make maybeSingle() throw
        .maybeSingle();

    if (existing != null) {
      throw Exception('Ye stock pehle se portfolio mein hai. Usko Edit karke quantity badlo.');
    }

    // 2. Universe check: verify symbol is a genuine NSE listed stock or ETF
    final valid = _isListedEtf(cleanSym) ? true : await client
        .from('ScreenerFundamentals')
        .select('Instrument')
        .eq('Instrument', cleanSym)
        .limit(1)
        .maybeSingle();

    if (valid == null) {
      throw Exception('Ye symbol NSE list mein nahi mila. Search se stock chuno.');
    }

    final totalInvested = qty * avgPrice;

    final Map<String, dynamic> payload = {
      'user_id': user.id,
      'Instrument': cleanSym,
      'Company_name': companyName.trim(),
      'YahooSymbol': SymbolUtils.getYahooSymbol(cleanSym),
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
    // Task 2.6: Only save fundamental parameters (Qty, Avg Price, Total Invested).
    // Current Val & Net P&L are derived dynamically at runtime to prevent stale DB state.
    final Map<String, dynamic> updates = {
      'Qty': qty,
      'Avg Price': avgPrice,
      'Total Invested': totalInvested,
    };

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
