// Weekday NSE holidays still ahead; same dates as NSE_TRADING_HOLIDAYS in backend/market_hours.py.
// shortcut: 2027 has only Republic Day until NSE publishes its list in December.
const _nseHolidays = {'2026-11-10', '2026-11-24', '2026-12-25', '2027-01-26'};

DateTime _ist(DateTime nowUtc) => nowUtc.toUtc().add(const Duration(hours: 5, minutes: 30));

bool _tradingDay(DateTime ist) {
  if (ist.weekday == DateTime.saturday || ist.weekday == DateTime.sunday) return false;
  final day = '${ist.year}-${ist.month.toString().padLeft(2, '0')}-${ist.day.toString().padLeft(2, '0')}';
  return !_nseHolidays.contains(day);
}

/// NSE cash session: Mon-Fri 09:15-15:30 IST, except exchange holidays.
bool isMarketOpenIst(DateTime nowUtc) {
  final ist = _ist(nowUtc);
  final minutes = ist.hour * 60 + ist.minute;
  return _tradingDay(ist) && minutes >= 9 * 60 + 15 && minutes <= 15 * 60 + 30;
}

/// Whether "today" has a session yet: a trading day from 09:15 IST, open or already closed.
/// On weekends, holidays and before the open, the latest numbers belong to an earlier day.
bool sessionStartedTodayIst(DateTime nowUtc) {
  final ist = _ist(nowUtc);
  return _tradingDay(ist) && ist.hour * 60 + ist.minute >= 9 * 60 + 15;
}
