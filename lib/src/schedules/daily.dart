part of 'schedule_base.dart';

/// Represents a schedule that occurs every _n_ days.
///
/// Throws an [ArgumentError] if:
/// - [frequency] is less than 1
class Daily extends Schedule {
  Daily({
    required super.startDate,
    required this.frequency,
    super.endDate,
  }) {
    if (frequency < 1) {
      throw ArgumentError.value(
        frequency,
        'frequency',
        'Frequency must be greater than or equal to 1',
      );
    }
  }

  /// Creates a daily schedule that occurs at the given [timesOfDay].
  ///
  /// Throws an [ArgumentError] if:
  /// - [timesOfDay] is empty
  Daily.timed({
    required super.startDate,
    required this.frequency,
    required Iterable<TimeOfDay> timesOfDay,
    super.endDate,
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
  /// For example, if this is `2`, then this schedule occurs every other day.
  final int frequency;

  @override
  bool occursOn(DateTime date) {
    if (!_isWithinBounds(date)) {
      return false;
    }

    final difference = startDate.daysApartFrom(date).abs();
    return difference % frequency == 0;
  }

  @override
  Iterable<DateTime> getNextNOccurrences(
    int n, {
    DateTime? from,
    Iterable<DateTime>? exclude,
  }) sync* {
    var currentDate = _clampToBounds(from).startOfDay();
    currentDate = _getFirstValidDate(currentDate).startOfDay();

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

    // Generate the next n occurrences
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

      currentDate = currentDate.add(Duration(days: frequency));
    }
  }

  @override
  Iterable<DateTime> getOccurrencesUntil(
    DateTime end, {
    DateTime? from,
    Iterable<DateTime>? exclude,
  }) sync* {
    var currentDate = (from ?? startDate).startOfDay();
    currentDate = _getFirstValidDate(currentDate).startOfDay();

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
      if (isBeyondEndDates(currentDate)) {
        return;
      }

      if (!isExcluded(currentDate)) {
        // Generate timed occurrences for this date
        for (final occurrence in _generateTimedOccurrences(currentDate)) {
          yield occurrence;
        }
      }

      currentDate = currentDate.add(Duration(days: frequency));
    }
  }

  DateTime _getFirstValidDate(DateTime from) {
    final offset = startDate.daysApartFrom(from).abs() % frequency;

    if (offset != 0) {
      return from.add(Duration(days: frequency - offset));
    }

    return from;
  }
}
