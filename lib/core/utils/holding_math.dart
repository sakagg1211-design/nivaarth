import '../../models/trade.dart';

/// Qty, cost and realized P&L of one holding. The database rebuilds the saved figures with
/// recalc_holding_for() (backend/migrations/16_trades.sql); this mirrors it for the
/// "naya avg ye hoga" preview before a trade is saved. Keep the two in step.
class HoldingSummary {
  final double qty;
  final double totalInvested;

  /// Average buy price. After a full exit it keeps the last average (Closed positions view).
  final double avgPrice;
  final double realizedPl;

  const HoldingSummary({
    this.qty = 0,
    this.totalInvested = 0,
    this.avgPrice = 0,
    this.realizedPl = 0,
  });

  static const empty = HoldingSummary();

  bool get isClosed => qty == 0;
}

class OversellException implements Exception {
  final double held;
  final double selling;
  const OversellException(this.held, this.selling);

  @override
  String toString() =>
      'Itne shares nahi hain: ${plain(held)} hain, ${plain(selling)} bech rahe ho.';

  static String plain(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
}

class HoldingMath {
  const HoldingMath._();

  /// Buy: Total Invested += qty x price, Avg = Total Invested / Qty.
  /// Sell: Avg unchanged, Qty and Total Invested fall pro rata,
  /// realized P&L += (price - avg) x qty. Charges never enter the average.
  static HoldingSummary apply(
    HoldingSummary start,
    TradeSide side,
    double qty,
    double price,
  ) {
    if (side == TradeSide.buy) {
      final invested = start.totalInvested + qty * price;
      final newQty = start.qty + qty;
      return HoldingSummary(
        qty: newQty,
        totalInvested: invested,
        avgPrice: invested / newQty,
        realizedPl: start.realizedPl,
      );
    }
    if (qty > start.qty) throw OversellException(start.qty, qty);
    final newQty = start.qty - qty;
    return HoldingSummary(
      qty: newQty,
      totalInvested: newQty == 0 ? 0 : start.totalInvested * newQty / start.qty,
      avgPrice: start.avgPrice,
      realizedPl: start.realizedPl + (price - start.avgPrice) * qty,
    );
  }

  static List<Trade> _ordered(List<Trade> trades) => [...trades]..sort((a, b) {
      final byDate = a.tradeDate.compareTo(b.tradeDate);
      if (byDate != 0) return byDate;
      final ca = a.createdAt, cb = b.createdAt;
      if (ca == null || cb == null) return 0;
      return ca.compareTo(cb);
    });

  /// All of a stock's trades, in trade-date order (then entry order), as the database does.
  static HoldingSummary summarize(List<Trade> trades) {
    var s = HoldingSummary.empty;
    for (final t in _ordered(trades)) {
      s = apply(s, t.side, t.qty, t.price);
    }
    return s;
  }

  /// Realized P&L of each sell (average cost at that moment), by trade id. Trades of several
  /// stocks may be mixed; each stock is replayed on its own.
  static Map<String, double> sellPl(List<Trade> trades) {
    final byStock = <String, List<Trade>>{};
    for (final t in trades) {
      byStock.putIfAbsent(t.instrument, () => []).add(t);
    }
    final result = <String, double>{};
    for (final list in byStock.values) {
      var s = HoldingSummary.empty;
      for (final t in _ordered(list)) {
        final before = s.realizedPl;
        try {
          s = apply(s, t.side, t.qty, t.price);
        } on OversellException {
          break; // the database never stores this; stop rather than show wrong numbers
        }
        if (t.side == TradeSide.sell) result[t.id] = s.realizedPl - before;
      }
    }
    return result;
  }

  /// Finished rounds, oldest first: each runs from the first buy at zero shares until the
  /// holding is back to zero. A round still open (shares left) is not included.
  static List<TradeRound> completedRounds(List<Trade> trades) {
    final rounds = <TradeRound>[];
    var s = HoldingSummary.empty;
    DateTime? start;
    double plAtStart = 0;
    double boughtQty = 0, boughtValue = 0, soldQty = 0, soldValue = 0;
    for (final t in _ordered(trades)) {
      if (s.qty == 0) {
        start = t.tradeDate;
        plAtStart = s.realizedPl;
        boughtQty = boughtValue = soldQty = soldValue = 0;
      }
      s = apply(s, t.side, t.qty, t.price);
      if (t.side == TradeSide.buy) {
        boughtQty += t.qty;
        boughtValue += t.qty * t.price;
      } else {
        soldQty += t.qty;
        soldValue += t.qty * t.price;
      }
      if (t.side == TradeSide.sell && s.qty == 0) {
        rounds.add(TradeRound(
          firstBuy: start!,
          lastSell: t.tradeDate,
          qtyBought: boughtQty,
          avgBuy: boughtValue / boughtQty,
          qtySold: soldQty,
          avgSell: soldValue / soldQty,
          realizedPl: s.realizedPl - plAtStart,
        ));
      }
    }
    return rounds;
  }
}

/// One finished buy-to-zero cycle of a stock, for "pichhli baar aapne ye kitne me liya tha".
/// Averages are plain weighted averages of the buys and of the sells in the round.
class TradeRound {
  final DateTime firstBuy;
  final DateTime lastSell;
  final double qtyBought;
  final double avgBuy;
  final double qtySold;
  final double avgSell;
  final double realizedPl;

  const TradeRound({
    required this.firstBuy,
    required this.lastSell,
    required this.qtyBought,
    required this.avgBuy,
    required this.qtySold,
    required this.avgSell,
    required this.realizedPl,
  });

  int get daysHeld => lastSell.difference(firstBuy).inDays;
}
