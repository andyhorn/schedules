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
      startOfDay().difference(date.startOfDay()).inDays.abs();

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

  DateTime startOfDay() => DateTime(year, month, day);
}
