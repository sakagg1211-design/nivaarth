import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/utils/holding_math.dart';
import 'package:mobile/models/trade.dart';

Trade _t(TradeSide side, double qty, double price, String date, {int seq = 0}) => Trade(
      id: '$date-$seq',
      instrument: 'TEST',
      side: side,
      qty: qty,
      price: price,
      tradeDate: DateTime.parse(date),
      createdAt: DateTime.parse(date).add(Duration(seconds: seq)),
    );

void main() {
  test('two buys give the weighted average', () {
    final s = HoldingMath.summarize([
      _t(TradeSide.buy, 100, 50, '2026-10-01'),
      _t(TradeSide.buy, 50, 80, '2026-10-05'),
    ]);
    expect(s.qty, 150);
    expect(s.totalInvested, 9000);
    expect(s.avgPrice, closeTo(60, 1e-9));
    expect(s.realizedPl, 0);
  });

  test('adding a buy keeps Total Invested exact, not Qty x rounded avg', () {
    // TATSILV-style case: an existing holding plus +1000 @ 17.68
    const start = HoldingSummary(qty: 6316, totalInvested: 160236.92, avgPrice: 160236.92 / 6316);
    final s = HoldingMath.apply(start, TradeSide.buy, 1000, 17.68);
    expect(s.qty, 7316);
    expect(s.totalInvested, closeTo(177916.92, 1e-6));
    // Qty x the 2-decimal average would drift by rupees
    final rounded = double.parse(s.avgPrice.toStringAsFixed(2)) * s.qty;
    expect((rounded - s.totalInvested).abs(), greaterThan(1));
  });

  test('a sell keeps the average and books realized P&L', () {
    final s = HoldingMath.summarize([
      _t(TradeSide.buy, 100, 50, '2026-10-01'),
      _t(TradeSide.buy, 100, 70, '2026-10-02'),
      _t(TradeSide.sell, 50, 90, '2026-10-03'),
    ]);
    expect(s.qty, 150);
    expect(s.avgPrice, closeTo(60, 1e-9));
    expect(s.totalInvested, closeTo(9000, 1e-9));
    expect(s.realizedPl, closeTo(1500, 1e-9));
  });

  test('selling everything closes the holding but keeps the last average', () {
    final s = HoldingMath.summarize([
      _t(TradeSide.buy, 10, 100, '2026-10-01'),
      _t(TradeSide.sell, 10, 80, '2026-10-02'),
    ]);
    expect(s.isClosed, isTrue);
    expect(s.totalInvested, 0);
    expect(s.avgPrice, 100);
    expect(s.realizedPl, closeTo(-200, 1e-9));
  });

  test('selling more than held is refused', () {
    expect(
      () => HoldingMath.summarize([
        _t(TradeSide.buy, 10, 100, '2026-10-01'),
        _t(TradeSide.sell, 11, 100, '2026-10-02'),
      ]),
      throwsA(isA<OversellException>()),
    );
  });

  test('trades run in trade-date order, not list order', () {
    // the sell is listed first but happened after the buy
    final s = HoldingMath.summarize([
      _t(TradeSide.sell, 5, 120, '2026-10-10'),
      _t(TradeSide.buy, 10, 100, '2026-10-01'),
    ]);
    expect(s.qty, 5);
    expect(s.realizedPl, closeTo(100, 1e-9));
  });

  test('same-day trades run in entry order', () {
    final s = HoldingMath.summarize([
      _t(TradeSide.sell, 10, 110, '2026-10-01', seq: 2),
      _t(TradeSide.buy, 10, 100, '2026-10-01', seq: 1),
    ]);
    expect(s.isClosed, isTrue);
    expect(s.realizedPl, closeTo(100, 1e-9));
  });

  test('a finished round: average buy, average sell, P&L and days held', () {
    final rounds = HoldingMath.completedRounds([
      _t(TradeSide.buy, 5, 7520, '2026-10-02'),
      _t(TradeSide.buy, 5, 7660, '2026-10-05'),
      _t(TradeSide.sell, 4, 7800, '2026-10-10'),
      _t(TradeSide.sell, 6, 8000, '2026-10-15'),
    ]);
    expect(rounds, hasLength(1));
    final r = rounds.single;
    expect(r.qtyBought, 10);
    expect(r.avgBuy, closeTo(7590, 1e-9));
    expect(r.avgSell, closeTo(7920, 1e-9));
    expect(r.realizedPl, closeTo(3300, 1e-9)); // (7920 - 7590) x 10
    expect(r.firstBuy, DateTime(2026, 10, 2));
    expect(r.lastSell, DateTime(2026, 10, 15));
    expect(r.daysHeld, 13);
  });

  test('two rounds are kept apart; an open round is not counted', () {
    final rounds = HoldingMath.completedRounds([
      _t(TradeSide.buy, 10, 100, '2026-01-01'),
      _t(TradeSide.sell, 10, 90, '2026-02-01'),
      _t(TradeSide.buy, 4, 200, '2026-03-01'),
      _t(TradeSide.sell, 4, 250, '2026-04-01'),
      _t(TradeSide.buy, 3, 300, '2026-05-01'),
      _t(TradeSide.sell, 1, 310, '2026-05-02'),
    ]);
    expect(rounds, hasLength(2));
    expect(rounds[0].realizedPl, closeTo(-100, 1e-9));
    expect(rounds[1].avgBuy, 200);
    expect(rounds[1].realizedPl, closeTo(200, 1e-9));
  });

  test('no finished round while shares are still held', () {
    expect(
      HoldingMath.completedRounds([
        _t(TradeSide.buy, 10, 100, '2026-01-01'),
        _t(TradeSide.sell, 5, 120, '2026-01-02'),
      ]),
      isEmpty,
    );
  });

  test('P&L of each sell, with two stocks mixed together', () {
    Trade other(TradeSide side, double qty, double price, String date) => Trade(
          id: 'O-$date',
          instrument: 'OTHER',
          side: side,
          qty: qty,
          price: price,
          tradeDate: DateTime.parse(date),
        );
    final pl = HoldingMath.sellPl([
      _t(TradeSide.buy, 10, 100, '2026-10-01'),
      other(TradeSide.buy, 2, 50, '2026-10-01'),
      _t(TradeSide.buy, 10, 200, '2026-10-02'),
      _t(TradeSide.sell, 5, 160, '2026-10-03'), // avg 150 -> +50
      other(TradeSide.sell, 2, 40, '2026-10-04'), // avg 50 -> -20
    ]);
    expect(pl, hasLength(2));
    expect(pl['2026-10-03-0'], closeTo(50, 1e-9));
    expect(pl['O-2026-10-04'], closeTo(-20, 1e-9));
  });

  test('Trade.fromJson reads a Trades row', () {
    final t = Trade.fromJson({
      'id': 'abc',
      'Instrument': 'IRCTC',
      'side': 'SELL',
      'qty': 4,
      'price': 439.15,
      'trade_date': '2026-10-30',
      'source': 'OPENING',
    });
    expect(t.side, TradeSide.sell);
    expect(t.qty, 4);
    expect(t.tradeDate, DateTime(2026, 10, 30));
    expect(t.isOpening, isTrue);
  });
}
