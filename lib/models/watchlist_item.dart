class WatchlistItem {
  final String instrument;
  final String companyName;
  final int score;
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
    required this.score,
    required this.addedPrice,
    required this.latestPrice,
    required this.dayChangePercent,
    required this.volume,
    required this.returnPercent,
    required this.trackedDate,
    required this.technicalTag,
    required this.keyTakeaway,
  });
}
