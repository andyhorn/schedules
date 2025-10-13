part of 'schedule_base.dart';

/// Represents a schedule that occurs every _n_ weeks on the given [weekdays].
///
/// Throws an [ArgumentError] if:
/// - [frequency] is less than 1
/// - [weekdays] is empty
/// - any weekday in [weekdays] is not between 1 and 7 (inclusive)
class Weekly extends Schedule {
  Weekly({
    required super.startDate,
    required this.frequency,
    required this.weekdays,
    super.endDate,
  }) {
    if (frequency < 1) {
      throw ArgumentError.value(
        frequency,
        'frequency',
        'Frequency must be greater than or equal to 1',
      );
    }

    if (weekdays.isEmpty) {
      throw ArgumentError.value(
        weekdays,
        'weekdays',
        'Weekdays list cannot be empty',
      );
    }

    if (weekdays.any((weekday) => weekday < 1 || weekday > 7)) {
      throw ArgumentError.value(
        weekdays,
        'weekdays',
        'Weekday must be between 1 and 7',
      );
    }
  }
  Weekly.timed({
    required super.startDate,
    required this.frequency,
    required this.weekdays,
    super.endDate,
    required Iterable<TimeOfDay> timesOfDay,
  }) : super(timingMode: Timed(timesOfDay: timesOfDay)) {
    if (frequency < 1) {
      throw ArgumentError.value(
        frequency,
        'frequency',
        'Frequency must be greater than or equal to 1',
      );
    }

    if (weekdays.isEmpty) {
      throw ArgumentError.value(
        weekdays,
        'weekdays',
        'Weekdays list cannot be empty',
      );
    }

    if (weekdays.any((weekday) => weekday < 1 || weekday > 7)) {
      throw ArgumentError.value(
        weekdays,
        'weekdays',
        'Weekday must be between 1 and 7',
      );
    }
  }

  /// The frequency at which this schedule occurs.
  ///
  /// For example, if this is `2`, then this schedule occurs every other week.
  final int frequency;

  /// The weekdays that this schedule occurs on.
  ///
  /// This is a list of integers, where each integer represents a weekday.
  ///
  /// For example, if this is `[DateTime.monday, DateTime.wednesday]`, then this schedule occurs on Mondays and Wednesdays.
  final List<int> weekdays;

  @override
  bool occursOn(DateTime date) {
    if (!_isWithinBounds(date) || !weekdays.contains(date.weekday)) {
      return false;
    }

    final difference = startDate.daysApartFrom(date).abs();
    final numWeeks = difference ~/ 7;
    return numWeeks % frequency == 0;
  }

  @override
  Iterable<DateTime> getNextNOccurrences(
    int n, {
    DateTime? from,
    Iterable<DateTime>? exclude,
  }) sync* {
    final sortedWeekdays = weekdays.toList()..sort();

    var currentWeek = _clampToBounds(from).startOfDay();
    currentWeek = _getFirstValidWeek(currentWeek).startOfDay();

    final firstValidDay = _getFirstValidDay(currentWeek, sortedWeekdays);

    bool isBeyondEndDate(DateTime date) {
      if (endDate case final endDate?) {
        if (date.isLaterDateThan(endDate)) {
          return true;
        }
      }

      return false;
    }

    bool isBeforeFirstValidDay(DateTime date) {
      return date.isEarlierDateThan(firstValidDay);
    }

    bool isExcluded(DateTime date) {
      return exclude?.any(date.isSameDateAs) ?? false;
    }

    var occurrencesFound = 0;
    while (occurrencesFound < n) {
      for (final weekday in weekdays) {
        final date = currentWeek.withWeekday(weekday);

        if (isBeyondEndDate(date)) {
          return;
        }

        if (isBeforeFirstValidDay(date)) {
          continue;
        }

        if (isExcluded(date)) {
          continue;
        }

        // Generate timed occurrences for this date
        for (final occurrence in _generateTimedOccurrences(date)) {
          yield occurrence;
          occurrencesFound++;

          if (occurrencesFound == n) {
            return;
          }
        }
      }

      currentWeek = currentWeek.add(Duration(days: frequency * 7));
    }
  }

  @override
  Iterable<DateTime> getOccurrencesUntil(
    DateTime end, {
    DateTime? from,
    Iterable<DateTime>? exclude,
  }) sync* {
    final sortedWeekdays = weekdays.toList()..sort();

    var currentWeek = _clampToBounds(from).startOfDay();
    currentWeek = _getFirstValidWeek(currentWeek).startOfDay();

    final firstValidDay = _getFirstValidDay(currentWeek, sortedWeekdays);

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

    bool isBeforeFirstValidDate(DateTime date) {
      return date.isEarlierDateThan(firstValidDay);
    }

    bool isExcluded(DateTime date) {
      return exclude?.any(date.isSameDateAs) ?? false;
    }

    while (true) {
      for (final weekday in sortedWeekdays) {
        final date = currentWeek.withWeekday(weekday);

        if (isBeyondEndDates(date)) {
          return;
        }

        if (isBeforeFirstValidDate(date)) {
          continue;
        }

        if (isExcluded(date)) {
          continue;
        }

        // Generate timed occurrences for this date
        for (final occurrence in _generateTimedOccurrences(date)) {
          yield occurrence;
        }
      }

      currentWeek = currentWeek.add(Duration(days: frequency * 7));
    }
  }

  DateTime _getFirstValidWeek(DateTime from) {
    final offsetDays = startDate.daysApartFrom(from).abs();
    final offsetWeeks = (offsetDays ~/ 7) % frequency;
    final totalWeeks = offsetDays ~/ 7;

    if (offsetWeeks != 0) {
      final duration = (totalWeeks + (frequency - offsetWeeks)) * 7;
      from = startDate.add(Duration(days: duration));
    }

    return from;
  }

  DateTime _getFirstValidDay(DateTime date, List<int> sortedWeekdays) {
    if (!weekdays.contains(date.weekday)) {
      final index = sortedWeekdays.indexWhere((day) => day > date.weekday);

      if (index != -1) {
        // Move to the next valid day in the current week
        return date.add(Duration(days: sortedWeekdays[index] - date.weekday));
      }

      // Move to the first valid day in the next valid week
      final nextWeekday = sortedWeekdays.first;
      final daysUntilNextWeek = 7 - date.weekday;

      return date.add(Duration(days: daysUntilNextWeek + nextWeekday));
    }

    return date;
  }
}
