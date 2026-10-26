class WatchlistItem {
  final String instrument;
  final String companyName;
  final int? score;
  final double addedPrice;
  final double latestPrice;
  final double dayChangePercent;
  final String volume;
  final double returnPercent;
  final String trackedDate;
  final String technicalTag;
  final String keyTakeaway;

  const WatchlistItem({
    required this.instrument,
    required this.companyName,
    this.score,
    required this.addedPrice,
    required this.latestPrice,
    required this.dayChangePercent,
    required this.volume,
    required this.returnPercent,
    required this.trackedDate,
    required this.technicalTag,
    required this.keyTakeaway,
  });

  Map<String, dynamic> toJson() {
    return {
      'instrument': instrument,
      'company_name': companyName,
      'score': score,
      'added_price': addedPrice,
      'latest_price': latestPrice,
      'day_change_percent': dayChangePercent,
      'volume': volume,
      'return_percent': returnPercent,
      'tracked_date': trackedDate,
      'technical_tag': technicalTag,
      'key_takeaway': keyTakeaway,
    };
  }

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      instrument: json['instrument']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      score: (json['score'] as num?)?.toInt(),
      addedPrice: (json['added_price'] as num?)?.toDouble() ?? 0.0,
      latestPrice: (json['latest_price'] as num?)?.toDouble() ?? 0.0,
      dayChangePercent: (json['day_change_percent'] as num?)?.toDouble() ?? 0.0,
      volume: json['volume']?.toString() ?? '—',
      returnPercent: (json['return_percent'] as num?)?.toDouble() ?? 0.0,
      trackedDate: json['tracked_date']?.toString() ?? '',
      technicalTag: json['technical_tag']?.toString() ?? 'MONITORED',
      keyTakeaway: json['key_takeaway']?.toString() ?? 'Active monitored watchlist asset',
    );
  }
}
