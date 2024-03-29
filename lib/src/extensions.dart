extension DateTimeExtensions on DateTime {
  /// Returns `true` if this date is earlier than the given [date].
  ///
  /// This considers only the date, not the time.
  bool isEarlierDateThan(DateTime date) => zeroTime.isBefore(date.zeroTime);

  /// Returns `true` if this date is later than the given [date].
  ///
  /// This considers only the date, not the time.
  bool isLaterDateThan(DateTime date) => zeroTime.isAfter(date.zeroTime);

  /// Returns `true` if this date is the same as the given [date].
  ///
  /// This considers only the date, not the time.
  bool isSameDateAs(DateTime date) => zeroTime == date.zeroTime;

  /// Returns a new [DateTime] with the time set to `00:00:00`.
  DateTime get zeroTime => DateTime(year, month, day);

  /// Calculates the number of days between this date and the given [date],
  /// ignoring the time.
  int daysApartFrom(DateTime date) =>
      zeroTime.difference(date.zeroTime).inDays.abs();

  /// Calculates the number of months between this date and the given [date].
  int getMonthsApartFrom(DateTime date) {
    if (date.year == year) {
      return (date.month - month).abs();
    }

    final yearDiff = (date.year - year).abs();

    if (yearDiff == 1) {
      return (12 - month) + date.month;
    }

    final yearDiffInMonths = (yearDiff - 1) * 12;
    return (12 - month) + date.month + yearDiffInMonths;
  }
}
