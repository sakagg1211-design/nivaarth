import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/allocation_math.dart';
import 'live_portfolio_provider.dart';

class PortfolioAllocation {
  final List<AllocationSlice> byCap;
  final List<AllocationSlice> bySector;
  const PortfolioAllocation(this.byCap, this.bySector);
}

/// Market caps and sectors change slowly; prices refresh every 2 minutes. Kept apart so a price
/// refresh does not repeat these queries. A failed load is never kept.
class _ReferenceData {
  final String key;
  final DateTime loadedAt;
  final double largeCut;
  final double midCut;
  final Map<String, double?> marketCap;
  final Map<String, Map<String, dynamic>> taxonomy;
  const _ReferenceData(this.key, this.loadedAt, this.largeCut, this.midCut, this.marketCap, this.taxonomy);
}

_ReferenceData? _reference;

Future<_ReferenceData?> _loadReference(List<String> symbols) async {
  final key = symbols.join(',');
  final kept = _reference;
  if (kept != null && kept.key == key && DateTime.now().difference(kept.loadedAt).inHours < 6) {
    return kept;
  }
  final client = Supabase.instance.client;

  // Enough rows to still reach rank 250 after partly-paid lines are skipped
  final top = await client
      .from('ScreenerFundamentals')
      .select('Instrument,MarketCapCr')
      .not('MarketCapCr', 'is', null)
      .order('MarketCapCr', ascending: false)
      .limit(270);
  final cuts = AllocationMath.cutOffs(
    top.map((r) => (symbol: r['Instrument'].toString(), cap: (r['MarketCapCr'] as num).toDouble())),
  );
  if (cuts == null) return null;

  final mcap = <String, double?>{};
  final tax = <String, Map<String, dynamic>>{};
  for (var i = 0; i < symbols.length; i += 200) {
    final part = symbols.sublist(i, i + 200 > symbols.length ? symbols.length : i + 200);
    final scr = await client.from('ScreenerFundamentals').select('Instrument,MarketCapCr').inFilter('Instrument', part);
    for (final r in scr) {
      mcap[r['Instrument'].toString().toUpperCase()] = (r['MarketCapCr'] as num?)?.toDouble();
    }
    final t = await client.from('StockTaxonomy').select('Instrument,isin,category,peer_sector').inFilter('Instrument', part);
    for (final r in t) {
      tax[r['Instrument'].toString().toUpperCase()] = Map<String, dynamic>.from(r as Map);
    }
  }
  return _reference = _ReferenceData(key, DateTime.now(), cuts.large, cuts.mid, mcap, tax);
}

/// How the portfolio's current value splits by market-cap tier and by sector.
final allocationProvider = FutureProvider<PortfolioAllocation?>((ref) async {
  final holdings = await ref.watch(livePortfolioProvider.future);
  final priced = holdings.where((h) => !h.isPriceUnavailable && h.currentValue > 0).toList();
  if (priced.isEmpty) return null;
  final symbols = priced.map((h) => h.portfolio.instrument.trim().toUpperCase()).toSet().toList()..sort();
  final data = await _loadReference(symbols);
  if (data == null) return null;

  final byCap = <({String group, double value})>[];
  final bySector = <({String group, double value})>[];
  for (final h in priced) {
    final s = h.portfolio.instrument.trim().toUpperCase();
    final tax = data.taxonomy[s];
    final isEtf = AllocationMath.isFund(tax?['isin']?.toString(), tax?['category']?.toString(), s);
    byCap.add((group: AllocationMath.capTier(data.marketCap[s], data.largeCut, data.midCut, isEtf: isEtf), value: h.currentValue));
    final sector = isEtf ? AllocationMath.etf : (tax?['peer_sector']?.toString() ?? AllocationMath.others);
    bySector.add((group: sector, value: h.currentValue));
  }
  return PortfolioAllocation(AllocationMath.slices(byCap), AllocationMath.slices(bySector, maxSlices: 8));
});
