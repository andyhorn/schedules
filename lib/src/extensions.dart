extension DateTimeExtensions on DateTime {
  /// Returns `true` if this date is earlier than the given [date].
  ///
  /// This considers only the date, not the time.
  bool isEarlierDateThan(DateTime date) => _dayOnly().isBefore(date._dayOnly());

  /// Returns `true` if this date is later than the given [date].
  ///
  /// This considers only the date, not the time.
  bool isLaterDateThan(DateTime date) => _dayOnly().isAfter(date._dayOnly());

  /// Returns `true` if this date is the same as the given [date].
  ///
  /// This considers only the date, not the time.
  bool isSameDateAs(DateTime date) => _dayOnly() == date._dayOnly();

  /// Calculates the number of days between this date and the given [date],
  /// ignoring the time.
  int daysApartFrom(DateTime date) =>
      _dayOnly().difference(date._dayOnly()).inDays.abs();

  /// Calculates the number of months between this date and the given [date].
  int monthsApartFrom(DateTime date) {
    final dayOfMonthAdjustment = date.day >= day ? 0 : -1;

    if (date.year == year) {
      final months = (date.month - month).abs();
      return months + dayOfMonthAdjustment;
    }

    final yearDiff = (date.year - year).abs();

    if (yearDiff == 1) {
      final months = (12 - month) + date.month;
      return months + dayOfMonthAdjustment;
    }

    final yearDiffInMonths = (yearDiff - 1) * 12;
    final months = (12 - month) + date.month + yearDiffInMonths;
    return months + dayOfMonthAdjustment;
  }

  DateTime _dayOnly() => DateTime(year, month, day);
}
