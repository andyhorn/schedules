extension DateTimeExtensions on DateTime {
  /// Returns `true` if this date is earlier than the given [date].
  ///
  /// This considers only the date, not the time.
  bool isEarlierDateThan(DateTime date) =>
      year < date.year || month < date.month || day < date.day;

  /// Returns `true` if this date is later than the given [date].
  ///
  /// This considers only the date, not the time.
  bool isLaterDateThan(DateTime date) =>
      year > date.year || month > date.month || day > date.day;

  /// Returns `true` if this date is the same as the given [date].
  ///
  /// This considers only the date, not the time.
  bool isSameDateAs(DateTime date) =>
      year == date.year && month == date.month && day == date.day;

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
