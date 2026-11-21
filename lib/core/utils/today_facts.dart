import '../../l10n/app_localizations.dart';
import 'account_value.dart';
import 'formatters.dart';

/// "Aaj ki baatein": the facts about today's portfolio that matter most, ranked by weight.
/// Facts state what happened; none tells the investor what to do.
enum FactKind { topDrag, topLift, vsNifty, high52, low52, volumeSpike, nearAlert, heavyStock, heavySector, scoreDown, scoreUp, stalePrice, yearHigh, upStreak }

class Fact {
  final FactKind kind;
  final double weight;
  final double magnitude;
  final String? symbol;
  final Map<String, Object> values;
  const Fact(this.kind, this.weight, {this.magnitude = 0, this.symbol, this.values = const {}});
}

class FactHolding {
  final String symbol;
  final double value;
  final double todayPct;
  final double price;
  final double? volume;
  final bool stale;
  final String sector;
  const FactHolding({
    required this.symbol,
    required this.value,
    required this.todayPct,
    required this.price,
    this.volume,
    this.stale = false,
    this.sector = 'Others',
  });
}

class FactSignal {
  final double? high52;
  final double? low52;
  final double? avgVolume20;
  final int? scoreNow;
  final int? scoreWeekAgo;
  const FactSignal({this.high52, this.low52, this.avgVolume20, this.scoreNow, this.scoreWeekAgo});
}

class FactAlert {
  final String symbol;
  final double target;
  const FactAlert(this.symbol, this.target);
}

class FactInputs {
  final List<FactHolding> holdings;
  final double? niftyPct;
  final Map<String, FactSignal> signals;
  final List<FactAlert> alerts;
  final List<ValuePoint> history;
  final double? todayValue;
  const FactInputs({
    this.holdings = const [],
    this.niftyPct,
    this.signals = const {},
    this.alerts = const [],
    this.history = const [],
    this.todayValue,
  });
}

const _funds = {'ETF'};
const _others = 'Others';

List<Fact> todayFacts(FactInputs i, {int limit = 3}) {
  final out = <Fact>[];
  final total = i.holdings.fold<double>(0, (a, h) => a + h.value);
  if (total > 0) {
    double pl(FactHolding h) => h.value * h.todayPct / (100 + h.todayPct);

    // A move over 40% is a split or bonus read against the unadjusted previous close, not a real gain or loss
    final real = i.holdings.where((h) => h.todayPct.abs() <= 40).toList();
    final realTotal = real.fold<double>(0, (a, h) => a + h.value);

    // Who moved the portfolio most today
    final movers = real..sort((a, b) => pl(b).abs().compareTo(pl(a).abs()));
    final top = movers.firstOrNull;
    final share = top == null ? 0.0 : pl(top).abs() / total;
    if (top != null && share >= 0.001) {
      out.add(Fact(pl(top) < 0 ? FactKind.topDrag : FactKind.topLift, 60 + 100 * share,
          magnitude: share, symbol: top.symbol, values: {'pct': pl(top) / total * 100}));
    }

    // Today against Nifty
    final todayPl = real.fold<double>(0, (a, h) => a + pl(h));
    final portfolioPct = realTotal - todayPl > 0 ? todayPl / (realTotal - todayPl) * 100 : 0.0;
    if (i.niftyPct != null && (portfolioPct - i.niftyPct!).abs() >= 0.5) {
      out.add(Fact(FactKind.vsNifty, 50, magnitude: (portfolioPct - i.niftyPct!).abs(),
          values: {'pct': portfolioPct, 'niftyPct': i.niftyPct!}));
    }

    for (final h in i.holdings) {
      final s = i.signals[h.symbol];
      // On a split's ex-date the 52-week range and average volume are still in pre-split units;
      // the score does not use the day's price move, so its facts stay
      final p = h.todayPct.abs() > 40 ? null : s;
      if (p?.low52 != null && h.price <= 1.005 * p!.low52!) {
        out.add(Fact(FactKind.low52, 65, symbol: h.symbol, values: {'price': h.price}));
      } else if (p?.high52 != null && h.price >= 0.995 * p!.high52!) {
        out.add(Fact(FactKind.high52, 55, symbol: h.symbol, values: {'price': h.price}));
      }
      if (p?.avgVolume20 != null && p!.avgVolume20! > 0 && h.volume != null && h.volume! >= 3 * p.avgVolume20!) {
        out.add(Fact(FactKind.volumeSpike, 45, magnitude: h.volume! / p.avgVolume20!, symbol: h.symbol,
            values: {'ratio': h.volume! / p.avgVolume20!}));
      }
      if (s?.scoreNow != null && s?.scoreWeekAgo != null && (s!.scoreNow! - s.scoreWeekAgo!).abs() >= 5) {
        final down = s.scoreNow! < s.scoreWeekAgo!;
        out.add(Fact(down ? FactKind.scoreDown : FactKind.scoreUp, down ? 55 : 40,
            magnitude: (s.scoreNow! - s.scoreWeekAgo!).abs().toDouble(), symbol: h.symbol,
            values: {'from': s.scoreWeekAgo!, 'to': s.scoreNow!}));
      }
      final pctOf = h.value / total * 100;
      if (pctOf > 15 && !_funds.contains(h.sector)) {
        out.add(Fact(FactKind.heavyStock, 35, magnitude: pctOf, symbol: h.symbol, values: {'pct': pctOf}));
      }
    }

    for (final a in i.alerts) {
      final h = i.holdings.where((x) => x.symbol == a.symbol).firstOrNull;
      if (h == null || a.target <= 0) continue;
      final gap = (h.price - a.target).abs() / a.target * 100;
      if (gap <= 2) {
        out.add(Fact(FactKind.nearAlert, 50, magnitude: 2 - gap, symbol: a.symbol, values: {'gap': gap, 'target': a.target}));
      }
    }

    final bySector = <String, double>{};
    for (final h in i.holdings) {
      if (_funds.contains(h.sector) || h.sector == _others) continue;
      bySector[h.sector] = (bySector[h.sector] ?? 0) + h.value;
    }
    bySector.forEach((sector, v) {
      final pct = v / total * 100;
      if (pct > 30) out.add(Fact(FactKind.heavySector, 35, magnitude: pct, values: {'sector': sector, 'pct': pct}));
    });

    final stale = i.holdings.where((h) => h.stale).length;
    if (stale > 0) out.add(Fact(FactKind.stalePrice, 30, magnitude: stale.toDouble(), values: {'count': stale}));
  }

  // Personal records from the account value history
  final real = i.history.where((p) => !p.assumed).toList();
  if (real.length >= 20 && i.todayValue != null && i.todayValue! >= real.map((p) => p.value).reduce((a, b) => a > b ? a : b)) {
    out.add(const Fact(FactKind.yearHigh, 45));
  }
  var streak = 0;
  for (var k = i.history.length - 1; k > 0; k--) {
    final a = i.history[k - 1], b = i.history[k];
    if ((b.value - a.value) - (b.invested - a.invested) > 0) {
      streak++;
    } else {
      break;
    }
  }
  if (streak >= 4) out.add(Fact(FactKind.upStreak, 35, magnitude: streak.toDouble(), values: {'days': streak}));

  out.sort((a, b) => b.weight != a.weight ? b.weight.compareTo(a.weight) : b.magnitude.compareTo(a.magnitude));
  // One fact per stock keeps the list varied
  final seen = <String>{};
  final varied = [for (final f in out) if (f.symbol == null || seen.add(f.symbol!)) f];
  return varied.take(limit).toList();
}

String factText(Fact f, AppLocalizations t) {
  String pct(Object v) => Formatters.percent(v as num, signed: true);
  String plain(Object v) => '${(v as num).toStringAsFixed(1)}%';
  final s = f.symbol ?? '';
  final v = f.values;
  return switch (f.kind) {
    FactKind.topDrag => t.factTopDrag(s, pct(v['pct']!)),
    FactKind.topLift => t.factTopLift(s, pct(v['pct']!)),
    FactKind.vsNifty => t.factVsNifty(pct(v['pct']!), pct(v['niftyPct']!)),
    FactKind.high52 => t.factHigh52(s, Formatters.currency(v['price'] as num)),
    FactKind.low52 => t.factLow52(s, Formatters.currency(v['price'] as num)),
    FactKind.volumeSpike => t.factVolumeSpike(s, (v['ratio'] as num).toStringAsFixed(1)),
    FactKind.nearAlert => t.factNearAlert(s, plain(v['gap']!), Formatters.currency(v['target'] as num)),
    FactKind.heavyStock => t.factHeavyStock(s, plain(v['pct']!)),
    FactKind.heavySector => t.factHeavySector(v['sector'].toString(), plain(v['pct']!)),
    FactKind.scoreDown => t.factScoreDown(s, '${v['from']}', '${v['to']}'),
    FactKind.scoreUp => t.factScoreUp(s, '${v['from']}', '${v['to']}'),
    FactKind.stalePrice => t.factStalePrice(v['count'] as int),
    FactKind.yearHigh => t.factYearHigh,
    FactKind.upStreak => t.factUpStreak('${v['days']}'),
  };
}
