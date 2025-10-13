part of 'schedule_base.dart';

/// Represents a schedule that occurs every _n_ years.
///
/// This schedule occurs on the same day and month as the [startDate].
///
/// Throws an [ArgumentError] if:
/// - [frequency] is less than 1
class Yearly extends Schedule {
  Yearly({
    required super.startDate,
    super.endDate,
    required this.frequency,
  }) {
    if (frequency < 1) {
      throw ArgumentError.value(
        frequency,
        'frequency',
        'Frequency must be greater than or equal to 1',
      );
    }
  }

  Yearly.timed({
    required super.startDate,
    super.endDate,
    required this.frequency,
    required Iterable<TimeOfDay> timesOfDay,
  }) : super(timingMode: Timed(timesOfDay: timesOfDay)) {
    if (frequency < 1) {
      throw ArgumentError.value(
        frequency,
        'frequency',
        'Frequency must be greater than or equal to 1',
      );
    }
  }

  /// The frequency at which this schedule occurs.
  ///
  /// For example, if this is `2`, then this schedule occurs every other year.
  final int frequency;

  @override
  bool occursOn(DateTime date) {
    if (!_isWithinBounds(date)) {
      return false;
    }

    if (date.day != startDate.day || date.month != startDate.month) {
      return false;
    }

    return (startDate.year - date.year).abs() % frequency == 0;
  }

  @override
  Iterable<DateTime> getNextNOccurrences(
    int n, {
    DateTime? from,
    Iterable<DateTime>? exclude,
  }) sync* {
    var currentDate = _clampToBounds(from).startOfDay();
    currentDate = _getNextValidDay(from ?? startDate);

    final isLeapYear = currentDate.month == 2 && currentDate.day == 29;

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
      if (isBeyondEndDate(currentDate)) {
        return;
      }

      if (!isExcluded(currentDate)) {
        // Generate timed occurrences for this date
        for (final occurrence in _generateTimedOccurrences(currentDate)) {
          yield occurrence;
          occurrencesFound++;

          if (occurrencesFound == n) {
            return;
          }
        }
      }

      if (isLeapYear) {
        // Use math to find the next leap year that also satisfies the
        // frequency requirement.
        final lcm = getLCM([frequency, 4]);

        if (lcm == 0) {
          break;
        }

        currentDate = currentDate.addYears(lcm, overflow: false);
      } else {
        currentDate = currentDate.addYears(frequency, overflow: false);
      }
    }
  }

  @override
  Iterable<DateTime> getOccurrencesUntil(
    DateTime end, {
    DateTime? from,
    Iterable<DateTime>? exclude,
  }) sync* {
    var currentDate = _clampToBounds(from).startOfDay();
    currentDate = _getNextValidDay(from ?? startDate);

    final isLeapYear = currentDate.month == 2 && currentDate.day == 29;

    bool isBeyondEndDates(DateTime date) {
      if (date.isLaterDateThan(end)) {
        return true;
      }

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

    while (true) {
      if (isBeyondEndDates(currentDate)) {
        return;
      }

      if (!isExcluded(currentDate)) {
        // Generate timed occurrences for this date
        for (final occurrence in _generateTimedOccurrences(currentDate)) {
          yield occurrence;
        }
      }

      if (isLeapYear) {
        final lcm = getLCM([frequency, 4]);

        if (lcm == 0) {
          return;
        }

        currentDate = currentDate.addYears(lcm, overflow: false);
      } else {
        currentDate = currentDate.addYears(frequency, overflow: false);
      }
    }
  }

  DateTime _getNextValidDay(DateTime from) {
    final offset = (startDate.year - from.year).abs() % frequency;
    final year = offset == 0 ? from.year : from.year + (frequency - offset);

    return DateTime(year, startDate.month, startDate.day);
  }
}
