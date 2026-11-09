import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/symbol_utils.dart';
import '../models/portfolio.dart';
import '../core/utils/error_messages.dart';

/// Reads the per-stock Portfolio summary. Holdings change only through trades
/// (TradeRepository / migration 16), never by editing Qty or Avg here.
class PortfolioRepository {
  final SupabaseClient client = Supabase.instance.client;

  // Fully sold holdings stay in the table with Status CLOSED. Live rows hold
  // 'Active', 'ACTIVE' and 'CORE', so test for CLOSED, not for ACTIVE.
  static bool isClosed(Portfolio p) => p.status.toUpperCase() == 'CLOSED';

  /// Holdings often store no name, or just the ticker; StockTaxonomy has the real one.
  static bool missingName(Map<String, dynamic> row) {
    final name = (row['Company_name'] ?? '').toString().trim().toUpperCase();
    return name.isEmpty || name == row['Instrument'].toString().trim().toUpperCase();
  }

  static List<Map<String, dynamic>> withCompanyNames(List<Map<String, dynamic>> rows, Map<String, String> names) => [
        for (final r in rows)
          missingName(r) && names[r['Instrument'].toString().trim().toUpperCase()] != null
              ? {...r, 'Company_name': names[r['Instrument'].toString().trim().toUpperCase()]}
              : r,
      ];

  // Company names are public and do not change, so each is fetched once.
  static final Map<String, String> _knownNames = {};

  Future<Map<String, String>> _companyNames(List<Map<String, dynamic>> rows) async {
    final wanted = rows
        .where(missingName)
        .map((r) => r['Instrument'].toString().trim().toUpperCase())
        .where((s) => !_knownNames.containsKey(s))
        .toSet()
        .toList();
    try {
      for (var i = 0; i < wanted.length; i += 200) {
        final found = await client
            .from('StockTaxonomy')
            .select('Instrument,company_name')
            .inFilter('Instrument', wanted.sublist(i, i + 200 > wanted.length ? wanted.length : i + 200));
        for (final r in found) {
          final name = r['company_name']?.toString().trim() ?? '';
          if (name.isNotEmpty) _knownNames[r['Instrument'].toString().toUpperCase()] = name;
        }
      }
    } catch (e) {
      debugPrint('Company names unavailable: $e'); // the app falls back to its own list
    }
    return _knownNames;
  }

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

      return withCompanyNames(userResponse, await _companyNames(userResponse))
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
    final out = <String>{for (final s in list) if (SymbolUtils.isEtf(s)) s};
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
    if (SymbolUtils.isEtf(sym)) return; // ETFs are not in ScreenerFundamentals
    final valid = await client
        .from('ScreenerFundamentals')
        .select('Instrument')
        .eq('Instrument', sym)
        .limit(1)
        .maybeSingle();
    if (valid == null) {
      throw TextError((t) => t.errSymbolNotListed);
    }
  }
}
