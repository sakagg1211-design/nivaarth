/// One bar of a price chart. [time] holds India wall-clock time, so it formats the same on every device.
class ChartPoint {
  final DateTime time;
  final double close;
  final int volume;
  const ChartPoint(this.time, this.close, this.volume);

  /// Pairs Yahoo's parallel lists, skipping bars without a close (Yahoo sends nulls for empty bars).
  static List<ChartPoint> fromYahoo(List<dynamic>? timestamps, List<dynamic>? closes, List<dynamic>? volumes) {
    if (timestamps == null || closes == null) return const [];
    final out = <ChartPoint>[];
    final n = timestamps.length < closes.length ? timestamps.length : closes.length;
    for (var i = 0; i < n; i++) {
      final t = timestamps[i];
      final c = closes[i];
      if (t is! num || c is! num) continue;
      final v = volumes != null && i < volumes.length ? volumes[i] : null;
      out.add(ChartPoint(
        DateTime.fromMillisecondsSinceEpoch(t.toInt() * 1000, isUtc: true).add(const Duration(hours: 5, minutes: 30)),
        c.toDouble(),
        v is num ? v.toInt() : 0,
      ));
    }
    return out;
  }
}
