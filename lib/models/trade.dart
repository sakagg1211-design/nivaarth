enum TradeSide { buy, sell }

/// One buy or sell from public."Trades" (migration 16). Trades are the source of truth;
/// the Portfolio row is rebuilt from them by the add_trade / update_trade / delete_trade RPCs.
class Trade {
  final String id;
  final String instrument;
  final TradeSide side;
  final double qty;
  final double price;
  final DateTime tradeDate;
  final double charges;
  final String brokerName;
  final String source; // MANUAL, OPENING or IMPORT
  final String? note;
  final DateTime? createdAt;

  const Trade({
    required this.id,
    required this.instrument,
    required this.side,
    required this.qty,
    required this.price,
    required this.tradeDate,
    this.charges = 0,
    this.brokerName = 'Manual',
    this.source = 'MANUAL',
    this.note,
    this.createdAt,
  });

  bool get isOpening => source == 'OPENING';

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['id']?.toString() ?? '',
      instrument: json['Instrument']?.toString() ?? '',
      side: json['side']?.toString().toUpperCase() == 'SELL' ? TradeSide.sell : TradeSide.buy,
      qty: (json['qty'] as num?)?.toDouble() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      tradeDate: DateTime.tryParse(json['trade_date']?.toString() ?? '') ?? DateTime(1970),
      charges: (json['charges'] as num?)?.toDouble() ?? 0,
      brokerName: json['broker_name']?.toString() ?? 'Manual',
      source: json['source']?.toString() ?? 'MANUAL',
      note: json['note']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
