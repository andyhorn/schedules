import 'package:schedules/src/schedules/clock_time.dart';

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

  /// Returns `true` if this date is earlier than or the same as the given [date].
  ///
  /// This considers only the date, not the time.
  bool isEarlierOrSameDateAs(DateTime date) =>
      startOfDay().isBefore(date.startOfDay()) ||
      startOfDay() == date.startOfDay();

  /// Returns `true` if this date is later than or the same as the given [date].
  ///
  /// This considers only the date, not the time.
  bool isLaterOrSameDateAs(DateTime date) =>
      startOfDay().isAfter(date.startOfDay()) ||
      startOfDay() == date.startOfDay();

  /// Calculates the number of days (signed) between this date and the given [date],
  /// ignoring the time.
  ///
  /// A positive value means this date is later than the given date,
  /// a negative value means this date is earlier than the given date,
  /// and zero means they are the same date.
  int daysApartFrom(DateTime date) =>
      startOfDay().difference(date.startOfDay()).inDays;

  /// Calculates the number of months (signed) between this date and the given [date].
  ///
  /// A positive value means this date is later than the given date,
  /// a negative value means this date is earlier than the given date,
  /// and zero means they are in the same month and year.
  int monthsApartFrom(DateTime date) {
    final a = startOfDay();
    final b = date.startOfDay();

    // if a is later, sign is positive; if a is earlier, sign is negative
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

  /// Returns a new [DateTime] representing the start of the day (midnight)
  /// for this date (removes the time component).
  DateTime startOfDay() => DateTime(year, month, day);

  /// Returns a new [DateTime] representing the last day of the month.
  DateTime endOfMonth() => DateTime(year, month + 1, 0);

  /// Returns a new [DateTime] representing the start of the month.
  DateTime startOfMonth() => DateTime(year, month, 1);

  /// Returns a new [DateTime] by adding the given number of [months] to this date.
  DateTime addMonths(int months, {bool overflow = true}) {
    final newDate = DateTime(year, month + months, day);

    if (overflow) {
      return newDate;
    }

    // Handle month overflow (e.g., adding 1 month to Jan 31 should result in Feb 28/29)
    if (newDate.month != ((month + months - 1) % 12) + 1) {
      return DateTime(newDate.year, newDate.month, 0);
    }

    return newDate;
  }

  /// Returns a new [DateTime] by adding the given number of [years] to this date.
  DateTime addYears(int years, {bool overflow = true}) {
    final newDate = DateTime(year + years, month, day);

    if (overflow) {
      return newDate;
    }

    // Handle month overflow (e.g., adding 1 year to Feb 29 on a leap year should result in Feb 28)
    if (newDate.month != month) {
      return DateTime(newDate.year, newDate.month, 0);
    }

    return newDate;
  }

  /// Returns a new [DateTime] with the same year and month as this date,
  /// but with the given [day].
  DateTime withDay(int day) {
    if (day < 1 || day > 31) {
      throw ArgumentError.value(day, 'day', 'Day must be between 1 and 31');
    }

    final newDate = DateTime(year, month, day);

    if (newDate.month != month) {
      throw ArgumentError.value(day, 'day', 'Invalid day for the month');
    }

    return newDate;
  }

  /// Returns a new [DateTime] with the same year and day as this date,
  /// but with the given [weekday].
  DateTime withWeekday(int weekday) {
    final currentWeekday = this.weekday;
    final daysDifference = weekday - currentWeekday;

    return add(Duration(days: daysDifference));
  }

  /// Returns a new [ClockTime] representing the time of day for this date.
  ClockTime toClockTime() => ClockTime.fromDateTime(this);

  /// Returns a new [DateTime] with the same year, month, and day as this date,
  /// but with the given [clockTime].
  DateTime withClockTime(ClockTime clockTime) => DateTime(
        year,
        month,
        day,
        clockTime.hour,
        clockTime.minute,
        clockTime.second,
        clockTime.millisecond,
      );
}
