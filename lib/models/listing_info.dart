/// How a stock is listed today and how old its fundamentals are: StockTaxonomy (is_sme,
/// current_series from migration 20) and ScreenerFundamentals (as_of, QuarterResultDate).
class ListingInfo {
  final String instrument;
  final bool isSme;
  /// Series in the latest NSE bhavcopy: EQ, BE (trade-for-trade), BZ (Z: listing rules not
  /// complied with), SM / ST (SME). Null until migration 20 and the first evening job after it.
  final String? currentSeries;
  final DateTime? fundamentalsAsOf;
  final DateTime? lastQuarter;

  const ListingInfo({
    required this.instrument,
    this.isSme = false,
    this.currentSeries,
    this.fundamentalsAsOf,
    this.lastQuarter,
  });

  String get _series => (currentSeries ?? '').toUpperCase();

  bool get sme => isSme || _series == 'SM' || _series == 'ST';
  bool get zGroup => _series == 'BZ';
  bool get tradeForTrade => _series == 'BE';

  /// Short badges, most serious first
  List<ListingBadge> get badges => [
        if (zGroup) const ListingBadge('Z', 'Listing rules ka paalan nahi (NSE Z / BZ series)', ListingBadgeLevel.warn),
        if (tradeForTrade) const ListingBadge('T2T', 'Trade-for-trade: intraday nahi, har trade delivery me', ListingBadgeLevel.caution),
        if (sme) const ListingBadge('SME', 'SME platform: kam liquidity, bada lot size', ListingBadgeLevel.caution),
      ];

  static ListingInfo fromRows(String instrument, Map<String, dynamic>? tax, Map<String, dynamic>? scr) {
    DateTime? d(Object? v) => v == null ? null : DateTime.tryParse(v.toString());
    return ListingInfo(
      instrument: instrument,
      isSme: tax?['is_sme'] == true,
      currentSeries: tax?['current_series']?.toString(),
      fundamentalsAsOf: d(scr?['as_of']),
      lastQuarter: d(scr?['QuarterResultDate']),
    );
  }
}

enum ListingBadgeLevel { warn, caution }

class ListingBadge {
  final String label;
  final String meaning;
  final ListingBadgeLevel level;
  const ListingBadge(this.label, this.meaning, this.level);
}
