extension DateTimeExtensions on DateTime {
  /// Returns `true` if this date is earlier than the given [date].
  ///
  /// This considers only the date, not the time.
  bool isEarlierDateThan(DateTime date) =>
      startOfDay().isBefore(date.startOfDay());

  /// Returns `true` if this date is later than the given [date].
  ///
  /// This considers only the date, not the time.
  bool isLaterDateThan(DateTime date) =>
      startOfDay().isAfter(date.startOfDay());

  /// Returns `true` if this date is the same as the given [date].
  ///
  /// This considers only the date, not the time.
  bool isSameDateAs(DateTime date) => startOfDay() == date.startOfDay();

  /// Calculates the number of days between this date and the given [date],
  /// ignoring the time.
  int daysApartFrom(DateTime date) =>
      startOfDay().difference(date.startOfDay()).inDays;

  /// Calculates the number of months between this date and the given [date].
  int monthsApartFrom(DateTime date) {
    final a = startOfDay();
    final b = date.startOfDay();

    // if b is later, sign is positive; if b is earlier, sign is negative
    final sign = a.isAfter(b) ? 1 : (a.isBefore(b) ? -1 : 0);

    // if dates are equal, return 0
    if (sign == 0) {
      return 0;
    }

    bool isEndOfMonth(DateTime date) {
      return date.day == DateTime(date.year, date.month + 1, 0).day;
    }

    final start = sign > 0 ? b : a;
    final end = sign > 0 ? a : b;

    int getOffset() {
      if (start.day == end.day) {
        return 0;
      }

      if (isEndOfMonth(start) && isEndOfMonth(end)) {
        return 0;
      }

      return start.day < end.day ? 0 : -1;
    }

    final years = end.year - start.year;
    final months = end.month - start.month;
    final offset = getOffset();
    final totalMonths = years * 12 + months + offset;

    return totalMonths * sign;
  }

  DateTime startOfDay() => DateTime(year, month, day);
}
