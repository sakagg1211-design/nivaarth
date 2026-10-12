import 'package:intl/intl.dart';

/// Formatting utility adhering strictly to Indian Numbering System
/// (e.g. ₹1,25,000 and ₹12,45,678.50)
class Formatters {
  Formatters._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _currency0 = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _number = NumberFormat.decimalPattern('en_IN');

  /// Formats value as Indian Rupee with 2 decimals (e.g. ₹1,25,000.50)
  static String currency(num value, {bool signed = false}) {
    final formatted = _currency.format(value.abs());
    if (signed && value > 0) return '+$formatted';
    if (value < 0) return '-$formatted';
    return formatted;
  }

  /// Formats value as Indian Rupee with 0 decimals (e.g. ₹1,25,000)
  static String currency0(num value, {bool signed = false}) {
    final formatted = _currency0.format(value.abs());
    if (signed && value > 0) return '+$formatted';
    if (value < 0) return '-$formatted';
    return formatted;
  }

  /// Formats raw number with Indian commas (e.g. 1,25,000)
  static String number(num value) {
    return _number.format(value);
  }

  /// Formats percentage return (e.g. +14.20% or -3.45%)
  static String percent(num value, {bool signed = false}) {
    final prefix = signed && value > 0 ? '+' : '';
    return '$prefix${value.toStringAsFixed(2)}%';
  }
}