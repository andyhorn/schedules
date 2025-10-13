part of 'schedule_base.dart';

/// Represents a schedule that occurs every _n_ months on the given [days].
///
/// Throws an [ArgumentError] if:
/// - [frequency] is less than 1
/// - [days] is empty
/// - any day in [days] is not between 1 and 31 (inclusive)
class Monthly extends Schedule {
  Monthly({
    required super.startDate,
    super.endDate,
    required this.days,
    required this.frequency,
  }) {
    if (frequency < 1) {
      throw ArgumentError.value(
        frequency,
        'frequency',
        'Frequency must be greater than or equal to 1',
      );
    }

    if (days.isEmpty) {
      throw ArgumentError.value(days, 'days', 'Days list cannot be empty');
    }

    if (days.any((day) => day < 1 || day > 31)) {
      throw ArgumentError.value(days, 'days', 'Day must be between 1 and 31');
    }
  }

  /// The days of the month that this schedule occurs on.
  ///
  /// This is a list of integers, where each integer represents a day of the month.
  ///
  /// For example, if this is `[1, 15]`, then this schedule occurs on the 1st and 15th of every month.
  final List<int> days;

  /// The frequency at which this schedule occurs.
  ///
  /// For example, if this is `2`, then this schedule occurs every other month.
  final int frequency;

  @override
  bool occursOn(DateTime date) {
    if (!_isWithinBounds(date) || !days.contains(date.day)) {
      return false;
    }

    final difference = startDate.monthsApartFrom(date);
    return difference % frequency == 0;
  }

  @override
  Iterable<DateTime> getNextNOccurrences(
    int n, {
    DateTime? from,
    Iterable<DateTime>? exclude,
  }) sync* {
    final sortedDays = days.toList()..sort();
    final firstValidDay = _getFirstValidDate(_clampToBounds(from));

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

    var currentMonth = firstValidDay.startOfMonth();
    var occurrencesFound = 0;
    while (occurrencesFound < n) {
      final lastDayOfMonth = currentMonth.endOfMonth().day;

      for (final day in sortedDays) {
        final isBeyondLastDay = day > lastDayOfMonth;

        if (isBeyondLastDay) {
          continue;
        }

        final date = currentMonth.withDay(day);
        final isBeforeFirstValidDay = date.isEarlierDateThan(firstValidDay);

        if (isBeforeFirstValidDay) {
          continue;
        }

        if (isBeyondEndDate(date)) {
          return;
        }

        if (isExcluded(date)) {
          continue;
        }

        yield date;
        occurrencesFound++;

        if (occurrencesFound == n) {
          return;
        }
      }

      // Move to the next valid month based on frequency
      currentMonth = currentMonth.addMonths(frequency, overflow: false);
    }
  }

  @override
  Iterable<DateTime> getOccurrencesUntil(
    DateTime end, {
    DateTime? from,
    Iterable<DateTime>? exclude,
  }) sync* {
    final sortedDays = days.toList()..sort();
    final firstValidDay = _getFirstValidDate(_clampToBounds(from));

    var currentMonth = firstValidDay.startOfMonth();

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
      final lastDayOfMonth = currentMonth.endOfMonth().day;

      for (final day in sortedDays) {
        final isBeyondLastDay = day > lastDayOfMonth;

        if (isBeyondLastDay) {
          continue;
        }

        final date = currentMonth.withDay(day);

        if (isBeyondEndDates(date)) {
          return;
        }

        if (isBeforeFirstValidDate(date)) {
          continue;
        }

        if (isExcluded(date)) {
          continue;
        }

        yield date;
      }

      currentMonth = currentMonth.addMonths(frequency, overflow: false);
    }
  }

  DateTime _getFirstValidDate(DateTime from) {
    from = _clampToBounds(from);

    final monthsApart = startDate.monthsApartFrom(from).abs();
    final offset = monthsApart % frequency;

    if (offset != 0) {
      from = DateTime(from.year, from.month + (frequency - offset), 1);
    }

    final sortedDays = days.toList()..sort();
    final index = sortedDays.indexWhere((day) => day >= from.day);

    if (index != -1) {
      from = DateTime(from.year, from.month, sortedDays[index]);
    } else {
      // Find the first valid day in the next valid month according to the frequency
      // and the first sorted day. For example, if the frequency is 1 and the first sorted day is
      // 31, then find the next month with 31 days.
      do {
        from = DateTime(from.year, from.month + frequency, sortedDays.first);
      } while (from.day != sortedDays.first);
    }

    return from;
  }
}
