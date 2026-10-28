/// NSE cash session, Mon-Fri 09:15-15:30 IST (exchange holidays are not known here).
bool isMarketOpenIst(DateTime nowUtc) {
  final ist = nowUtc.toUtc().add(const Duration(hours: 5, minutes: 30));
  if (ist.weekday == DateTime.saturday || ist.weekday == DateTime.sunday) return false;
  final minutes = ist.hour * 60 + ist.minute;
  return minutes >= 9 * 60 + 15 && minutes <= 15 * 60 + 30;
}
