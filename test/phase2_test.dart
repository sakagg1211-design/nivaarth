import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/import/xlsx_rows.dart';
import 'package:mobile/core/import/zerodha_tradebook.dart';
import 'package:mobile/core/utils/corporate_action_math.dart';
import 'package:mobile/models/listing_info.dart';
import 'package:mobile/models/trade.dart';
import 'package:mobile/widgets/listing_badges.dart';

Trade buy(double qty, double price, DateTime d, {String source = 'MANUAL'}) => Trade(
      id: '$qty-$price-$d',
      instrument: 'KEI',
      side: TradeSide.buy,
      qty: qty,
      price: price,
      tradeDate: d,
      source: source,
    );

CorporateAction ca(String id, DateTime ex, double m, {String kind = 'bonus'}) =>
    CorporateAction(id: id, instrument: 'KEI', exDate: ex, kind: kind, multiplier: m);

void main() {
  group('bonus / split', () {
    test('1:1 bonus doubles the shares, halves the average, keeps the invested amount', () {
      final p = CorporateActionMath.pending(
        [buy(10, 4200, DateTime(2026, 9, 1))],
        [ca('KEI:2026-10-12:bonus', DateTime(2026, 10, 12), 2)],
        appliedIds: {},
        declinedIds: {},
      ).single;
      expect(p.extraShares, 10);
      expect(p.after.qty, 20);
      expect(p.after.avgPrice, 2100);
      expect(p.after.totalInvested, 42000);
      expect(p.fractionDropped, isFalse);
    });

    test('shares bought on or after the ex-date, and the OPENING trade dated later, do not count', () {
      final p = CorporateActionMath.pending(
        [buy(10, 4200, DateTime(2026, 9, 1)), buy(5, 2000, DateTime(2026, 10, 12))],
        [ca('a', DateTime(2026, 10, 12), 2)],
        appliedIds: {},
        declinedIds: {},
      ).single;
      expect(p.extraShares, 10);
      expect(CorporateActionMath.pending([buy(48, 100, DateTime(2026, 11, 3), source: 'OPENING')],
          [ca('b', DateTime(2026, 10, 12), 2)], appliedIds: {}, declinedIds: {}), isEmpty);
    });

    test('7:5 bonus on 3 shares adds 4 and notes the dropped fraction', () {
      final p = CorporateActionMath.pending([buy(3, 120, DateTime(2026, 1, 1))],
          [ca('c', DateTime(2026, 3, 2), 2.4)], appliedIds: {}, declinedIds: {}).single;
      expect(p.extraShares, 4);
      expect(p.fractionDropped, isTrue);
    });

    test('applied or declined events are not asked again; two events stack', () {
      final events = [ca('s', DateTime(2026, 2, 6), 5, kind: 'split'), ca('b', DateTime(2026, 6, 1), 2)];
      final both = CorporateActionMath.pending([buy(2, 1000, DateTime(2026, 1, 1))], events,
          appliedIds: {}, declinedIds: {});
      expect(both.map((p) => p.extraShares), [8, 10]); // 2 -> 10 -> 20
      expect(CorporateActionMath.pending([buy(2, 1000, DateTime(2026, 1, 1))], events,
              appliedIds: {'s'}, declinedIds: {'b'}),
          isEmpty);
    });
  });

  group('listing badges', () {
    test('series and SME flag give the badges', () {
      expect(const ListingInfo(instrument: 'X', currentSeries: 'BZ').badges.map((b) => b.label), ['Z']);
      expect(const ListingInfo(instrument: 'X', currentSeries: 'BE').badges.map((b) => b.label), ['T2T']);
      expect(const ListingInfo(instrument: 'X', currentSeries: 'SM').badges.map((b) => b.label), ['SME']);
      expect(const ListingInfo(instrument: 'X', isSme: true).badges.map((b) => b.label), ['SME']);
      expect(const ListingInfo(instrument: 'X', currentSeries: 'EQ').badges, isEmpty);
    });

    test('fundamentals line names the export day and the last quarter', () {
      final info = ListingInfo(
          instrument: 'TCS', fundamentalsAsOf: DateTime(2026, 10, 30), lastQuarter: DateTime(2026, 9, 30));
      expect(ListingInfoStrip.fundamentalsLine(info), 'Fundamentals: 30 Oct 2026 tak · aakhri results: Sep 2026 quarter');
      expect(ListingInfoStrip.fundamentalsLine(const ListingInfo(instrument: 'X')), isNull);
    });
  });

  test('Excel tradebook: title rows skipped, spaced headers, date cells and dd-mm-yyyy text', () {
    final book = Excel.createExcel();
    final sheet = book[book.getDefaultSheet()!];
    sheet.appendRow([TextCellValue('Tradebook for Equity')]);
    sheet.appendRow([TextCellValue('Client ID: XX0000')]);
    sheet.appendRow([
      for (final h in ['Symbol', 'ISIN', 'Trade Date', 'Exchange', 'Segment', 'Trade Type', 'Quantity', 'Price', 'Trade ID'])
        TextCellValue(h)
    ]);
    sheet.appendRow([TextCellValue('KEI'), TextCellValue('INE878B01027'), DateCellValue(year: 2026, month: 1, day: 5),
      TextCellValue('NSE'), TextCellValue('EQ'), TextCellValue('buy'), DoubleCellValue(10), DoubleCellValue(4000), TextCellValue('T1')]);
    sheet.appendRow([TextCellValue('KEI'), TextCellValue('INE878B01027'), TextCellValue('05-02-2026'),
      TextCellValue('NSE'), TextCellValue('EQ'), TextCellValue('sell'), DoubleCellValue(4), DoubleCellValue(4500), TextCellValue('T2')]);
    final bytes = Uint8List.fromList(book.encode()!);
    final parsed = ZerodhaTradebook.parseTable(xlsxRows(bytes));
    expect(parsed.trades.length, 2);
    expect(parsed.trades[0].date, DateTime(2026, 1, 5));
    expect(parsed.trades[1].date, DateTime(2026, 2, 5));
    expect(parsed.trades[1].side, TradeSide.sell);
    expect(parsed.trades[0].key, 'NSE:T1');
  });
}
