part of 'schedule_base.dart';

/// Represents a schedule that occurs every _n_ years.
///
/// Throws an [ArgumentError] if:
/// - [frequency] is less than 1
/// - [endDate] is before [startDate]
class Yearly extends Schedule {
  /// Creates a yearly schedule that occurs every [frequency] years on the
  /// same day and month as the [startDate].
  factory Yearly({
    required DateTime startDate,
    required int frequency,
    DateTime? endDate,
  }) {
    return Yearly._internal(
      startDate: startDate,
      frequency: frequency,
      endDate: endDate,
    );
  }
  Yearly._internal({
    required super.startDate,
    required this.frequency,
    super.endDate,
    super.timingMode,
  }) {
    if (frequency < 1) {
      throw ArgumentError.value(
        frequency,
        'frequency',
        'Frequency must be greater than or equal to 1',
      );
    }
  }

  /// Creates a yearly schedule that occurs every [frequency] years on the
  /// same day and month as the [startDate] at the given [clockTimes].
  factory Yearly.timed({
    required DateTime startDate,
    required int frequency,
    required Iterable<ClockTime> clockTimes,
    DateTime? endDate,
  }) {
    return Yearly._internal(
      startDate: startDate,
      frequency: frequency,
      endDate: endDate,
      timingMode: Timed(clockTimes: clockTimes),
    );
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
    var currentDate = _getNextValidDay(_clampToBounds(from));

    var occurrencesFound = 0;
    while (occurrencesFound < n) {
      if (_isBeyondEnd(currentDate)) {
        return;
      }

      if (!_isExcluded(currentDate, exclude)) {
        // Generate timed occurrences for this date
        for (final occurrence in _generateTimedOccurrences(currentDate)) {
          yield occurrence;
          occurrencesFound++;

          if (occurrencesFound == n) {
            return;
          }
        }
      }

      currentDate = _getNextValidDay(DateTime(currentDate.year + 1));
    }
  }

  @override
  Iterable<DateTime> getOccurrencesUntil(
    DateTime end, {
    DateTime? from,
    Iterable<DateTime>? exclude,
  }) sync* {
    var currentDate = _getNextValidDay(_clampToBounds(from));

    while (true) {
      if (_isBeyondEnd(currentDate, end)) {
        return;
      }

      if (!_isExcluded(currentDate, exclude)) {
        // Generate timed occurrences for this date
        for (final occurrence in _generateTimedOccurrences(currentDate)) {
          yield occurrence;
        }
      }

      currentDate = _getNextValidDay(DateTime(currentDate.year + 1));
    }
  }

  /// Finds the first anniversary of [startDate] on or after [from] that
  /// satisfies the year [frequency] and actually exists (a Feb 29
  /// anniversary only occurs in leap years).
  DateTime _getNextValidDay(DateTime from) {
    final offset = (from.year - startDate.year) % frequency;
    var year = offset == 0 ? from.year : from.year + frequency - offset;

    while (true) {
      final candidate = DateTime(year, startDate.month, startDate.day);
      final exists =
          candidate.month == startDate.month && candidate.day == startDate.day;

      if (exists && !candidate.isEarlierDateThan(from)) {
        return candidate;
      }

      year += frequency;
    }
  }
}
