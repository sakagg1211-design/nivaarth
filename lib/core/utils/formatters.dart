import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currency =
      NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _currency0 =
      NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String currency(num value) {
    return _currency.format(value);
  }

  static String currency0(num value) {
    return _currency0.format(value);
  }

  static String percent(num value) {
    return "${value.toStringAsFixed(2)}%";
  }
}