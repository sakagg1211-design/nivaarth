import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/account_value.dart';
import 'package:mobile/core/utils/today_facts.dart';
import 'package:mobile/l10n/app_localizations.dart';

import 'no_advice_wording_test.dart' show bannedPhrases, bannedHinglish;

final en = lookupAppLocalizations(const Locale('en'));
final hi = lookupAppLocalizations(const Locale('en', 'IN'));

FactHolding hold(String s, {double value = 1000, double pct = 0, double price = 100, double? volume, bool stale = false, String sector = 'Energy'}) =>
    FactHolding(symbol: s, value: value, todayPct: pct, price: price, volume: volume, stale: stale, sector: sector);

List<Fact> run({
  List<FactHolding> holdings = const [],
  double? niftyPct,
  Map<String, FactSignal> signals = const {},
  List<FactAlert> alerts = const [],
  List<ValuePoint> history = const [],
  double? todayValue,
  int limit = 20,
}) =>
    todayFacts(
      FactInputs(holdings: holdings, niftyPct: niftyPct, signals: signals, alerts: alerts, history: history, todayValue: todayValue),
      limit: limit,
    );

Iterable<FactKind> kinds(List<Fact> f) => f.map((x) => x.kind);

List<ValuePoint> days(List<double> values, {List<double>? invested, int assumed = 0}) => [
      for (var i = 0; i < values.length; i++)
        ValuePoint(DateTime(2026, 1, 1).add(Duration(days: i)), values[i], invested?[i] ?? 1000, assumed: i < assumed),
    ];

// Ten equal holdings so no single stock is heavy unless a test says so
List<FactHolding> spread([List<FactHolding> extra = const []]) =>
    [for (var i = 0; i < 10; i++) hold('S$i', sector: 'Sec$i'), ...extra];

void main() {
  test('topDrag: the holding that took most off the portfolio today', () {
    final f = run(holdings: spread([hold('TCS', value: 1000, pct: -5, sector: 'Tech')]));
    final d = f.firstWhere((x) => x.kind == FactKind.topDrag);
    expect(d.symbol, 'TCS');
    expect(d.weight, greaterThan(60));
  });

  test('topLift when the biggest mover is up', () {
    expect(kinds(run(holdings: spread([hold('POLYCAB', pct: 4, sector: 'Ind')]))), contains(FactKind.topLift));
  });

  test('no mover fact under 0.10% of the portfolio', () {
    expect(kinds(run(holdings: spread([hold('X', value: 10, pct: 1, sector: 'Z')]))), isNot(contains(FactKind.topLift)));
  });

  test('vsNifty at a gap of 0.50 points or more only', () {
    final h = spread([hold('A', pct: -2, sector: 'Q')]);
    expect(kinds(run(holdings: h, niftyPct: 0.4)), contains(FactKind.vsNifty));
    expect(kinds(run(holdings: spread(), niftyPct: 0.3)), isNot(contains(FactKind.vsNifty)));
  });

  test('52-week low and high', () {
    final f = run(holdings: spread([hold('L', price: 100.4, sector: 'Q'), hold('H', price: 199.5, sector: 'R')]), signals: {
      'L': const FactSignal(high52: 300, low52: 100),
      'H': const FactSignal(high52: 200, low52: 50),
    });
    expect(f.firstWhere((x) => x.kind == FactKind.low52).weight, 65);
    expect(f.firstWhere((x) => x.kind == FactKind.high52).weight, 55);
  });

  test('a split day (move over 40%) gives no 52-week or volume fact from old units', () {
    final f = run(holdings: spread([hold('BIG', value: 10000, pct: -20, sector: 'B'), hold('SP', price: 50, pct: -50, volume: 900, sector: 'Q')]),
        signals: {'SP': const FactSignal(high52: 300, low52: 90, avgVolume20: 100)});
    expect(kinds(f), isNot(contains(FactKind.low52)));
    expect(kinds(f), isNot(contains(FactKind.volumeSpike)));
  });

  test('a split day move (over 40%) is not reported as a drag or counted against Nifty', () {
    // 1:2 split: 1000 -> 500 against an unadjusted previous close reads as -50%, but nothing was lost
    final f = run(holdings: spread([hold('SP', value: 2000, pct: -50, sector: 'Q'), hold('TCS', value: 1000, pct: -3, sector: 'T')]), niftyPct: 0);
    expect(f.where((x) => x.kind == FactKind.topDrag).single.symbol, 'TCS');
    expect(kinds(f), isNot(contains(FactKind.vsNifty)));
  });

  test('volume spike at three times the usual volume', () {
    final f = run(holdings: spread([hold('V', volume: 3000, sector: 'Q')]), signals: {'V': const FactSignal(avgVolume20: 1000)});
    expect(f.firstWhere((x) => x.kind == FactKind.volumeSpike).weight, 45);
    expect(kinds(run(holdings: spread([hold('V', volume: 2900, sector: 'Q')]), signals: {'V': const FactSignal(avgVolume20: 1000)})),
        isNot(contains(FactKind.volumeSpike)));
  });

  test('near an alert within 2 percent', () {
    expect(kinds(run(holdings: spread([hold('R', price: 98.5, sector: 'Q')]), alerts: const [FactAlert('R', 100)])), contains(FactKind.nearAlert));
    expect(kinds(run(holdings: spread([hold('R', price: 97, sector: 'Q')]), alerts: const [FactAlert('R', 100)])), isNot(contains(FactKind.nearAlert)));
  });

  test('score moved 5 or more in a week', () {
    final f = run(holdings: spread([hold('D', sector: 'Q'), hold('U', sector: 'R')]), signals: {
      'D': const FactSignal(scoreNow: 31, scoreWeekAgo: 41),
      'U': const FactSignal(scoreNow: 70, scoreWeekAgo: 64),
    });
    expect(f.firstWhere((x) => x.kind == FactKind.scoreDown).weight, 55);
    expect(f.firstWhere((x) => x.kind == FactKind.scoreUp).weight, 40);
  });

  test('heavy stock above 15 percent and heavy sector above 30 percent, funds and Others left out', () {
    // a stock with no known sector is still a heavy stock; Others and ETF only stay out of the sector check
    final f = run(holdings: [hold('BIG', value: 2000, sector: 'Fin'), hold('B2', value: 1100, sector: 'Fin'), hold('C', value: 3000, sector: 'ETF'), hold('D', value: 4000, sector: 'Others')]);
    expect(f.where((x) => x.kind == FactKind.heavyStock).map((x) => x.symbol), ['D', 'BIG']);
    expect(f.where((x) => x.kind == FactKind.heavySector).map((x) => x.values['sector']), ['Fin']);
  });

  test('stale prices', () {
    expect(kinds(run(holdings: spread([hold('O', stale: true, sector: 'Q')]))), contains(FactKind.stalePrice));
  });

  test('year high needs 20 real days and today at or above the best of them', () {
    final h = days([for (var i = 0; i < 25; i++) 1000.0 + i]);
    expect(kinds(run(holdings: spread(), history: h, todayValue: 1030)), contains(FactKind.yearHigh));
    expect(kinds(run(holdings: spread(), history: days([for (var i = 0; i < 25; i++) 1000.0 + i], assumed: 10), todayValue: 1030)),
        isNot(contains(FactKind.yearHigh)));
  });

  test('up streak of four market days', () {
    expect(kinds(run(holdings: spread(), history: days([100, 101, 102, 103, 104]))), contains(FactKind.upStreak));
  });

  test('money added does not count as a streak day', () {
    // the 101 rise on day 4 is exactly the 101 put in, so the market added nothing that day
    final h = days([100, 101, 102, 203, 204], invested: [1000, 1000, 1000, 1101, 1101]);
    expect(kinds(run(holdings: spread(), history: h)), isNot(contains(FactKind.upStreak)));
  });

  test('limit keeps the top 3 by weight', () {
    final f = run(
      holdings: spread([hold('L', price: 100, sector: 'Q'), hold('D', sector: 'R'), hold('O', stale: true, sector: 'T')]),
      signals: {'L': const FactSignal(high52: 300, low52: 100), 'D': const FactSignal(scoreNow: 30, scoreWeekAgo: 40)},
      limit: 3,
    );
    expect(f.length, 3);
    expect(f.first.kind, FactKind.low52);
    expect(f.map((x) => x.weight).toList(), [...f.map((x) => x.weight)]..sort((a, b) => b.compareTo(a)));
  });

  test('one fact per stock keeps the list varied', () {
    final f = run(holdings: spread([hold('L', price: 100, volume: 5000, sector: 'Q')]), signals: {'L': const FactSignal(high52: 300, low52: 100, avgVolume20: 1000)});
    expect(f.where((x) => x.symbol == 'L').length, 1);
  });

  test('one holding with no signals still gives what applies', () {
    final f = run(holdings: [hold('ONLY', value: 500, pct: 2)]);
    // one fact per stock: the strongest one about ONLY is kept
    expect(f.where((x) => x.symbol == 'ONLY').single.kind, FactKind.topLift);
    expect(kinds(f), contains(FactKind.heavySector)); // Energy is 100% of it
  });

  test('no input gives an empty list', () {
    expect(run(), isEmpty);
  });

  test('text has no advice words and keeps the numbers in both languages', () {
    final all = run(
      holdings: spread([
        hold('A', pct: -5, price: 100, volume: 5000, sector: 'Q'),
        hold('B', price: 199.5, sector: 'R'),
        hold('C', price: 98.5, sector: 'T'),
        hold('D', stale: true, value: 3000, sector: 'U'),
      ]),
      niftyPct: 1,
      signals: {'A': const FactSignal(high52: 300, low52: 100, avgVolume20: 1000), 'B': const FactSignal(high52: 200, low52: 50, scoreNow: 30, scoreWeekAgo: 40)},
      alerts: const [FactAlert('C', 100)],
      history: days([100, 101, 102, 103, 104]),
    );
    expect(all, isNotEmpty);
    for (final f in all) {
      for (final t in [en, hi]) {
        final s = factText(f, t).toLowerCase();
        for (final b in [...bannedPhrases, ...bannedHinglish]) {
          expect(s.contains(b), isFalse, reason: '$s has "$b"');
        }
      }
      final digits = RegExp(r'\d');
      expect(digits.hasMatch(factText(f, en)), digits.hasMatch(factText(f, hi)));
    }
  });
}
