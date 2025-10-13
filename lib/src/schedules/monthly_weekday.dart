part of 'schedule_base.dart';

/// Represents a schedule that occurs every _n_ months on the given [weekday] and [weekOfMonth].
///
/// Throws an [ArgumentError] if:
/// - [frequency] is less than 1
/// - [weekday] is not between 1 and 7, inclusive
/// - [weekOfMonth] is not between 1 and 5, inclusive, or -1 for the last occurrence of month
///
/// This schedule occurs on the first Monday of every month.
/// ```
/// MonthlyWeekday(
///   startDate: DateTime(2023, 01, 01), // January 1st, 2023
///   weekday: DateTime.monday, // Monday
///   weekOfMonth: 1, // First occurrence of the month
///   frequency: 1, // Every month
/// )
/// ```
///
/// This schedule occurs on the last Friday of every month.
/// ```
/// MonthlyWeekday(
///   startDate: DateTime(2023, 01, 01), // January 1st, 2023
///   weekday: DateTime.friday,
///   weekOfMonth: -1, // Last occurrence of the month
///   frequency: 1, // Every month
/// )
/// ```
///
/// This schedule occurs on the first Monday of every quarter.
/// ```
/// MonthlyWeekday(
///   startDate: DateTime(2023, 01, 01),
///   weekday: DateTime.monday,
///   weekOfMonth: 1,
///   frequency: 3, // Every 3 months
/// )
/// ```
class MonthlyWeekday extends Schedule {
  MonthlyWeekday({
    required super.startDate,
    super.endDate,
    required this.frequency,
    required this.weekday,
    required this.weekOfMonth,
  }) {
    if (frequency < 1) {
      throw ArgumentError.value(
        frequency,
        'frequency',
        'Frequency must be greater than or equal to 1',
      );
    }

    if (weekday < 1 || weekday > 7) {
      throw ArgumentError.value(
        weekday,
        'weekday',
        'Weekday must be between 1 and 7',
      );
    }

    if (weekOfMonth != -1 && (weekOfMonth < 1 || weekOfMonth > 5)) {
      throw ArgumentError.value(
        weekOfMonth,
        'weekOfMonth',
        'Week of month must be between 1 and 5, or -1 for last week of month',
      );
    }
  }

  final int frequency;
  final int weekday;
  final int weekOfMonth;

  @override
  Iterable<DateTime> getNextNOccurrences(
    int n, {
    DateTime? from,
    Iterable<DateTime>? exclude,
  }) sync* {
    var currentMonth = (from ?? startDate).startOfMonth();

    bool isBeforeStartDates(DateTime date) {
      if (date.isEarlierDateThan(startDate)) {
        return true;
      }

      if (from case final from?) {
        if (date.isEarlierDateThan(from)) {
          return true;
        }
      }

      return false;
    }

    bool isBeyondEndDate(DateTime date) {
      if (endDate case final endDate?) {
        if (date.isLaterDateThan(endDate)) {
          return true;
        }
      }

      return false;
    }

    bool isExcluded(DateTime date) {
      return exclude?.any(date.isSameDateAs) ?? false;
    }

    var occurrencesFound = 0;
    while (occurrencesFound < n) {
      final occurrence = _getOccurrence(currentMonth);

      if (occurrence case final occurrence?) {
        if (isBeyondEndDate(occurrence)) {
          return;
        }

        final isValidDate =
            !isBeforeStartDates(occurrence) && !isExcluded(occurrence);

        if (isValidDate) {
          yield occurrence;
          occurrencesFound++;
        }
      }

      currentMonth = DateTime(
        currentMonth.year,
        currentMonth.month + frequency,
        1,
      );
    }
  }

  @override
  Iterable<DateTime> getOccurrencesUntil(
    DateTime end, {
    DateTime? from,
    Iterable<DateTime>? exclude,
  }) sync* {
    var currentMonth = (from ?? startDate).startOfMonth();

    bool isBeforeStartDates(DateTime date) {
      if (date.isEarlierDateThan(startDate)) {
        return true;
      }

      if (from case final from?) {
        if (date.isEarlierDateThan(from)) {
          return true;
        }
      }

      return false;
    }

    bool isBeyondEndDates(DateTime date) {
      if (endDate case final endDate?) {
        if (date.isLaterDateThan(endDate)) {
          return true;
        }
      }

      if (date.isLaterDateThan(end)) {
        return true;
      }

      return false;
    }

    bool isExcluded(DateTime date) {
      return exclude?.any(date.isSameDateAs) ?? false;
    }

    while (true) {
      final occurrence = _getOccurrence(currentMonth);

      if (occurrence case final occurrence?) {
        if (isBeyondEndDates(occurrence)) {
          return;
        }

        final isValidDate =
            !isBeforeStartDates(occurrence) && !isExcluded(occurrence);

        if (isValidDate) {
          yield occurrence;
        }
      }

      currentMonth = DateTime(
        currentMonth.year,
        currentMonth.month + frequency,
        1,
      );
    }
  }

  @override
  bool occursOn(DateTime date) {
    if (date.isEarlierDateThan(startDate)) {
      return false;
    }

    if (endDate case final endDate?) {
      if (date.isLaterDateThan(endDate)) {
        return false;
      }
    }

    if (date.weekday != weekday) {
      return false;
    }

    final distance = date.startOfMonth().monthsApartFrom(startDate);

    if (distance % frequency != 0) {
      return false;
    }

    final occurrence = _getOccurrence(date.startOfMonth());
    return occurrence?.isSameDateAs(date) ?? false;
  }

  DateTime? _getOccurrence(DateTime month) {
    final int occurrence;

    if (weekOfMonth == -1) {
      // Find the last occurrence of this weekday in the month
      final lastDayOfMonth = month.endOfMonth();
      final daysBack = _getDistance(
        a: lastDayOfMonth.weekday,
        b: weekday,
      );

      occurrence = lastDayOfMonth.day - daysBack;
    } else {
      final firstOfMonth = month.startOfMonth();
      final occurrenceIndex = (weekOfMonth - 1) * 7;
      final daysToFirstOccurrence = _getDistance(
        a: weekday,
        b: firstOfMonth.weekday,
      );

      occurrence = 1 + daysToFirstOccurrence + occurrenceIndex;
    }

    if (occurrence > month.endOfMonth().day) {
      return null;
    }

    return month.withDay(occurrence);
  }

  int _getDistance({
    required int a,
    required int b,
  }) {
    return (a - b + 7) % 7;
  }
}
