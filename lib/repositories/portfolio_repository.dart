import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/portfolio.dart';

/// Reads the per-stock Portfolio summary. Holdings change only through trades
/// (TradeRepository / migration 16), never by editing Qty or Avg here.
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

  // Fully sold holdings stay in the table with Status CLOSED. Live rows hold
  // 'Active', 'ACTIVE' and 'CORE', so test for CLOSED, not for ACTIVE.
  static bool isClosed(Portfolio p) => p.status.toUpperCase() == 'CLOSED';

  /// Open holdings only.
  Future<List<Portfolio>> getPortfolio() async {
    final all = await _getAll();
    return all.where((p) => !isClosed(p)).toList();
  }

  /// Fully sold holdings, for the Closed positions section.
  Future<List<Portfolio>> getClosedPositions() async {
    final all = await _getAll();
    return all.where(isClosed).toList();
  }

  Future<List<Portfolio>> _getAll() async {
    final user = client.auth.currentUser;

    // Strict multi-tenancy: Unauthenticated queries must NEVER leak data
    if (user == null) {
      debugPrint("PortfolioRepository: No authenticated user session. Returning empty holdings.");
      return const [];
    }

    // A failed read is rethrown, not turned into an empty list: an empty list shows
    // "No Portfolio Holdings Yet", which reads as lost data. The screens show
    // "Portfolio unavailable · Try Again" for an error.
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
      rethrow;
    }
  }

  /// Which of these symbols are in Nivaarth's stock list (one query, for an import preview)
  Future<Set<String>> listedAmong(Iterable<String> symbols) async {
    final list = symbols.map((s) => s.trim().toUpperCase()).where((s) => s.isNotEmpty).toSet().toList();
    final out = <String>{for (final s in list) if (_isListedEtf(s)) s};
    for (var i = 0; i < list.length; i += 200) {
      final rows = await client
          .from('ScreenerFundamentals')
          .select('Instrument')
          .inFilter('Instrument', list.sublist(i, i + 200 > list.length ? list.length : i + 200));
      out.addAll(rows.map((r) => r['Instrument'].toString().toUpperCase()));
    }
    return out;
  }

  /// Throws unless [sym] is a listed NSE stock (ScreenerFundamentals) or a known ETF.
  Future<void> checkListed(String sym) async {
    if (_isListedEtf(sym)) return;
    final valid = await client
        .from('ScreenerFundamentals')
        .select('Instrument')
        .eq('Instrument', sym)
        .limit(1)
        .maybeSingle();
    if (valid == null) {
      throw Exception('Ye symbol NSE list mein nahi mila. Search se stock chuno.');
    }
  }
}
