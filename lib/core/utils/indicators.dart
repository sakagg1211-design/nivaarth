/// Technical indicators computed from daily closing prices (oldest first).
/// Each returns null when there are not enough closes, never an estimate.
class Indicators {
  const Indicators._();

  /// Simple moving average of the last [period] closes.
  static double? sma(List<double> closes, int period) {
    if (period <= 0 || closes.length < period) return null;
    final window = closes.sublist(closes.length - period);
    return window.reduce((a, b) => a + b) / period;
  }

  /// Exponential moving average, seeded with the SMA of the first [period] closes.
  static double? ema(List<double> closes, int period) {
    if (period <= 0 || closes.length < period) return null;
    final k = 2 / (period + 1);
    var value = closes.sublist(0, period).reduce((a, b) => a + b) / period;
    for (var i = period; i < closes.length; i++) {
      value = closes[i] * k + value * (1 - k);
    }
    return value;
  }

  /// Wilder's RSI over [period] days (needs period + 1 closes).
  static double? rsi(List<double> closes, {int period = 14}) {
    if (closes.length < period + 1) return null;
    var gain = 0.0;
    var loss = 0.0;
    for (var i = 1; i <= period; i++) {
      final d = closes[i] - closes[i - 1];
      if (d >= 0) {
        gain += d;
      } else {
        loss -= d;
      }
    }
    var avgGain = gain / period;
    var avgLoss = loss / period;
    for (var i = period + 1; i < closes.length; i++) {
      final d = closes[i] - closes[i - 1];
      avgGain = (avgGain * (period - 1) + (d > 0 ? d : 0)) / period;
      avgLoss = (avgLoss * (period - 1) + (d < 0 ? -d : 0)) / period;
    }
    if (avgLoss == 0) return 100;
    final rs = avgGain / avgLoss;
    return 100 - 100 / (1 + rs);
  }
}
