import '../../models/trade.dart';
import 'holding_math.dart';

/// A reviewed bonus or split (public."CorporateActions", migration 20).
class CorporateAction {
  final String id;
  final String instrument;
  final DateTime exDate;
  final String kind; // bonus, split, split+bonus
  /// Shares after the event per share before (1:1 bonus 2, 1:5 split 5, 7:5 bonus 2.4)
  final double multiplier;

  const CorporateAction({
    required this.id,
    required this.instrument,
    required this.exDate,
    required this.kind,
    required this.multiplier,
  });

  factory CorporateAction.fromJson(Map<String, dynamic> j) => CorporateAction(
        id: j['id'].toString(),
        instrument: j['Instrument'].toString().toUpperCase(),
        exDate: DateTime.parse(j['ex_date'].toString()),
        kind: j['kind'].toString(),
        multiplier: (j['qty_multiplier'] as num).toDouble(),
      );

  String get label => switch (kind) {
        'split' => 'split',
        'split+bonus' => 'split + bonus',
        _ => 'bonus',
      };
}

/// What one event would do to a holding, for the confirm popup.
class PendingAdjustment {
  final CorporateAction action;
  final double sharesBefore; // held the day before the ex-date
  final int extraShares;
  final bool fractionDropped; // e.g. 7:5 bonus on 3 shares: the broker pays cash for the part
  final HoldingSummary now;
  final HoldingSummary after;

  const PendingAdjustment({
    required this.action,
    required this.sharesBefore,
    required this.extraShares,
    required this.fractionDropped,
    required this.now,
    required this.after,
  });
}

class CorporateActionMath {
  const CorporateActionMath._();

  /// Events of one stock that would add shares to its holding and have not been applied or
  /// declined. Shares held at the ex-date come from trades dated before it, so an OPENING trade
  /// (dated when trades started, after the event) is never counted twice.
  static List<PendingAdjustment> pending(
    List<Trade> trades,
    List<CorporateAction> actions, {
    required Set<String> appliedIds,
    required Set<String> declinedIds,
  }) {
    final out = <PendingAdjustment>[];
    var current = [...trades];
    final ordered = [...actions]..sort((a, b) => a.exDate.compareTo(b.exDate));
    for (final a in ordered) {
      if (appliedIds.contains(a.id) || declinedIds.contains(a.id)) continue;
      final before = current.where((t) => t.tradeDate.isBefore(a.exDate)).toList();
      final held = HoldingMath.summarize(before).qty;
      if (held <= 0) continue;
      final exact = held * (a.multiplier - 1);
      final extra = (exact + 1e-9).floor();
      if (extra <= 0) continue;
      final now = HoldingMath.summarize(current);
      final bonusTrade = Trade(
        id: 'ca-${a.id}',
        instrument: a.instrument,
        side: TradeSide.buy,
        qty: extra.toDouble(),
        price: 0,
        tradeDate: a.exDate,
        source: 'CORP_ACT',
      );
      final next = [...current, bonusTrade];
      out.add(PendingAdjustment(
        action: a,
        sharesBefore: held,
        extraShares: extra,
        fractionDropped: (exact - extra).abs() > 1e-9,
        now: now,
        after: HoldingMath.summarize(next),
      ));
      current = next; // a later event on the same stock counts these shares
    }
    return out;
  }
}
