/// A user's price alert for one stock (table PriceAlerts, migration 21).
class PriceAlert {
  static const above = 'ABOVE';
  static const below = 'BELOW';

  /// Every alerted stock joins the 5-minute price refresh, so one user's list stays bounded.
  static const maxActive = 50;

  final String id;
  final String instrument;
  final String direction;
  final double targetPrice;

  const PriceAlert({
    required this.id,
    required this.instrument,
    required this.direction,
    required this.targetPrice,
  });

  bool get isAbove => direction == above;

  bool matches(String otherDirection, double target) =>
      direction == otherDirection && (targetPrice - target).abs() < 0.005;

  factory PriceAlert.fromJson(Map<String, dynamic> json) => PriceAlert(
        id: json['id'].toString(),
        instrument: json['Instrument'].toString(),
        direction: json['direction'].toString(),
        targetPrice: (json['target_price'] as num).toDouble(),
      );

  /// Why this target cannot be saved, or null when it is fine. An alert already met at the
  /// current price would fire at once, so it is refused. [currentPrice] <= 0 means no price is known.
  static String? validate(String direction, double? target, double currentPrice) {
    if (target == null || target <= 0) return 'Sahi bhaav daalo';
    if (currentPrice > 0) {
      if (direction == above && target <= currentPrice) {
        return 'Bhaav abhi ke bhaav se upar hona chahiye';
      }
      if (direction == below && target >= currentPrice) {
        return 'Bhaav abhi ke bhaav se neeche hona chahiye';
      }
    }
    return null;
  }
}
