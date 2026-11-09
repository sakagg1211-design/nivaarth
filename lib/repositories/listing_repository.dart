import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/allocation_math.dart';
import '../models/listing_info.dart';

/// Listing details for badges and the fundamentals date. Both tables are readable by the app.
class ListingRepository {
  final SupabaseClient client = Supabase.instance.client;

  /// Each symbol's group: ETF for funds, else its Yahoo sector, else Others. The dashboard split and
  /// the what-if page both read this, so they cannot disagree.
  Future<Map<String, String>> sectorsFor(List<String> symbols) async {
    final tax = <String, Map<String, dynamic>>{};
    for (var i = 0; i < symbols.length; i += 200) {
      final part = symbols.sublist(i, i + 200 > symbols.length ? symbols.length : i + 200);
      final rows = await client.from('StockTaxonomy').select('Instrument,isin,category,peer_sector').inFilter('Instrument', part);
      for (final r in rows) {
        tax[r['Instrument'].toString().toUpperCase()] = Map<String, dynamic>.from(r as Map);
      }
    }
    return {
      for (final s in symbols)
        s: AllocationMath.isFund(tax[s]?['isin']?.toString(), tax[s]?['category']?.toString(), s)
            ? AllocationMath.etf
            : (tax[s]?['peer_sector']?.toString() ?? AllocationMath.others),
    };
  }

  Future<Map<String, ListingInfo>> forStocks(Iterable<String> instruments) async {
    final list = instruments.map((s) => s.trim().toUpperCase()).where((s) => s.isNotEmpty).toSet().toList();
    if (list.isEmpty) return const {};
    final tax = <String, Map<String, dynamic>>{};
    final scr = <String, Map<String, dynamic>>{};
    for (var i = 0; i < list.length; i += 200) {
      final part = list.sublist(i, i + 200 > list.length ? list.length : i + 200);
      List<dynamic> rows;
      try {
        rows = await client.from('StockTaxonomy').select('Instrument,is_sme,current_series').inFilter('Instrument', part);
      } catch (_) {
        // Before migration 20 there is no current_series column
        rows = await client.from('StockTaxonomy').select('Instrument,is_sme').inFilter('Instrument', part);
      }
      for (final r in rows) {
        tax[r['Instrument'].toString().toUpperCase()] = Map<String, dynamic>.from(r as Map);
      }
      final s = await client
          .from('ScreenerFundamentals')
          .select('Instrument,as_of,QuarterResultDate')
          .inFilter('Instrument', part);
      for (final r in s) {
        scr[r['Instrument'].toString().toUpperCase()] = Map<String, dynamic>.from(r as Map);
      }
    }
    return {for (final sym in list) sym: ListingInfo.fromRows(sym, tax[sym], scr[sym])};
  }
}
