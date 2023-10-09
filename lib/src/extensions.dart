extension DateTimeExtensions on DateTime {
  bool isEarlierDateThan(DateTime date) =>
      year < date.year || month < date.month || day < date.day;

  bool isLaterDateThan(DateTime date) =>
      year > date.year || month > date.month || day > date.day;

  bool isSameDateAs(DateTime date) =>
      year == date.year && month == date.month && day == date.day;

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
