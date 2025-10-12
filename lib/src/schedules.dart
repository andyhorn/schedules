import "package:schedules/src/math.dart";

import "extensions.dart";

/// A schedule represents a set of dates that an event occurs on.
/// This is used to determine if an event occurs on a given date.
///
/// For example, a schedule could represent an event that occurs every Monday and Wednesday.
/// Or, a schedule could represent an event that occurs every 2 months on the 10th.
sealed class Schedule {
  const Schedule({
    required this.startDate,
    this.endDate,
  });

  /// The date that this schedule begins on.
  ///
  /// Note that this is not necessarily the first date that this schedule occurs.
  final DateTime startDate;

  /// The date that this schedule ends on.
  ///
  /// If this is `null`, then this schedule has no end date.
  final DateTime? endDate;

  /// Determine if this schedule includes the given [date].
  bool occursOn(DateTime date);

  /// Returns an iterable of the next [n] occurrences for this schedule.
  Iterable<DateTime> getNextNOccurrences(int n, {DateTime? from});

  /// Returns an iterable of the occurrences for this schedule until the given [end] date.
  Iterable<DateTime> getOccurrencesUntil(DateTime end, {DateTime? from});

  /// Returns a list of the next [n] dates for this schedule.
  List<DateTime> findNextNOccurrences(
    int n, {
    DateTime? fromDate,
    List<DateTime> excludeDates = const [],
  }) {
    final dates = <DateTime>[];
    var currentDate = (fromDate ?? DateTime.now()).startOfDay();

    excludeDates = excludeDates.map((date) => date.startOfDay()).toList();

    while (dates.length < n &&
        (endDate == null || endDate!.isAfter(currentDate))) {
      // Here is the magic: Check if our Schedule occurs on the given date
      // using the "occursOn" method.
      //
      // If the current date fits the Schedule's pattern, add it to our list.
      if (occursOn(currentDate) && !excludeDates.contains(currentDate)) {
        dates.add(currentDate);
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }

  /// Returns a list of dates active on the current schedule through [tillDate].
  List<DateTime> findNextTillDateOccurrences(
    DateTime tillDate, {
    DateTime? fromDate,
    List<DateTime> excludeDates = const [],
  }) {
    final dates = <DateTime>[];
    var currentDate = (fromDate ?? DateTime.now()).startOfDay();

    excludeDates = excludeDates.map((date) => date.startOfDay()).toList();

    while (currentDate.isBefore(tillDate)) {
      // Here is the magic: Check if our Schedule occurs on the given date
      // using the "occursOn" method.
      //
      // If the current date fits the Schedule's pattern, add it to our list.
      if (occursOn(currentDate) && !excludeDates.contains(currentDate)) {
        dates.add(currentDate);
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }

  bool _isWithinBounds(DateTime date) {
    if (date.isEarlierDateThan(startDate)) {
      return false;
    }

    if (endDate != null && date.isLaterDateThan(endDate!)) {
      return false;
    }

    return true;
  }

  DateTime _clampToBounds(DateTime? date) {
    if (date == null) return startDate;

    if (date.isEarlierDateThan(startDate)) {
      return startDate;
    }

    if (endDate case final endDate?) {
      if (date.isLaterDateThan(endDate)) {
        return endDate;
      }
    }

    return date;
  }
}

/// Represents a schedule that occurs only once.
class Singular extends Schedule {
  const Singular({
    // renamed to be more explicit that this is a single date
    required DateTime date,
  }) : super(startDate: date, endDate: date);

  @override
  bool occursOn(DateTime date) => startDate.isSameDateAs(date);

  @override
  Iterable<DateTime> getNextNOccurrences(int n, {DateTime? from}) {
    if (from != null && from.isLaterDateThan(startDate)) {
      return const <DateTime>[];
    }

    return [startDate];
  }

  @override
  Iterable<DateTime> getOccurrencesUntil(DateTime end, {DateTime? from}) {
    final date = from ?? startDate;
    final isAfterStartDate = date.isLaterDateThan(startDate);
    final isAfterEndDate = date.isLaterDateThan(end);

    if (isAfterStartDate || isAfterEndDate) {
      return const [];
    }

    return [date.startOfDay()];
  }
}

/// Represents a schedule that occurs every _n_ days.
///
/// Throws an [AssertionError] if the frequency is less than 1.
class Daily extends Schedule {
  Daily({
    required super.startDate,
    required this.frequency,
    super.endDate,
  }) {
    if (frequency < 1) {
      throw AssertionError('Frequency must be greater than or equal to 1');
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
  Iterable<DateTime> getNextNOccurrences(int n, {DateTime? from}) sync* {
    var currentDate = _clampToBounds(from).startOfDay();
    currentDate = _getFirstValidDate(currentDate).startOfDay();

    // Generate the next n occurrences
    for (var i = 0; i < n; i++) {
      if (endDate case final endDate?) {
        if (currentDate.isLaterDateThan(endDate)) {
          break;
        }
      }

      yield currentDate;

      currentDate = currentDate.add(Duration(days: frequency));
    }
  }

  @override
  Iterable<DateTime> getOccurrencesUntil(DateTime end, {DateTime? from}) sync* {
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

    while (true) {
      if (isBeyondEndDates(currentDate)) {
        return;
      }

      yield currentDate;
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

/// Represents a schedule that occurs every _n_ weeks on the given [weekdays].
///
/// Throws an [AssertionError] if the frequency is less than 1.
class Weekly extends Schedule {
  Weekly({
    required super.startDate,
    required this.frequency,
    required this.weekdays,
    super.endDate,
  }) {
    if (frequency < 1) {
      throw AssertionError('Frequency must be greater than or equal to 1');
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
  Iterable<DateTime> getNextNOccurrences(int n, {DateTime? from}) sync* {
    final sortedWeekdays = weekdays.toList()..sort();

    var currentWeek = _clampToBounds(from).startOfDay();
    currentWeek = _getFirstValidWeek(currentWeek).startOfDay();

    final firstValidDay = _getFirstValidDay(currentWeek, sortedWeekdays);

    var occurrencesFound = 0;
    while (occurrencesFound < n) {
      for (final weekday in weekdays) {
        final date = currentWeek.withWeekday(weekday);
        final isBeforeFirstValidDay = date.isEarlierDateThan(firstValidDay);

        if (isBeforeFirstValidDay) {
          continue;
        }

        if (endDate case final endDate?) {
          if (date.isLaterDateThan(endDate)) {
            return;
          }
        }

        yield date;
        occurrencesFound++;

        if (occurrencesFound == n) {
          return;
        }
      }

      currentWeek = currentWeek.add(Duration(days: frequency * 7));
    }
  }

  @override
  Iterable<DateTime> getOccurrencesUntil(DateTime end, {DateTime? from}) sync* {
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

    while (true) {
      for (final weekday in sortedWeekdays) {
        final date = currentWeek.withWeekday(weekday);

        if (isBeforeFirstValidDate(date)) {
          continue;
        }

        if (isBeyondEndDates(date)) {
          return;
        }

        yield date;
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

/// Represents a schedule that occurs every _n_ months on the given [days].
///
/// Throws an [AssertionError] if the frequency is less than 1.
class Monthly extends Schedule {
  Monthly({
    required super.startDate,
    super.endDate,
    required this.days,
    required this.frequency,
  }) {
    if (frequency < 1) {
      throw AssertionError('Frequency must be greater than or equal to 1');
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

  @override
  Iterable<DateTime> getNextNOccurrences(int n, {DateTime? from}) sync* {
    final sortedDays = days.toList()..sort();
    final firstValidDay = _getFirstValidDate(_clampToBounds(from));

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

        if (endDate case final endDate?) {
          if (date.isLaterDateThan(endDate)) {
            // No more valid dates can be found
            return;
          }
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
  Iterable<DateTime> getOccurrencesUntil(DateTime end, {DateTime? from}) sync* {
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

    while (true) {
      final lastDayOfMonth = currentMonth.endOfMonth().day;

      for (final day in sortedDays) {
        final isBeyondLastDay = day > lastDayOfMonth;

        if (isBeyondLastDay) {
          continue;
        }

        final date = currentMonth.withDay(day);

        if (isBeforeFirstValidDate(date)) {
          continue;
        }

        if (isBeyondEndDates(date)) {
          return;
        }

        yield date;
      }

      currentMonth = currentMonth.addMonths(frequency, overflow: false);
    }
  }
}

/// Represents a schedule that occurs every _n_ years.
///
/// This schedule occurs on the same day and month as the [startDate].
///
/// Throws an [AssertionError] if the frequency is less than 1.
class Yearly extends Schedule {
  Yearly({
    required super.startDate,
    super.endDate,
    required this.frequency,
  }) {
    if (frequency < 1) {
      throw AssertionError('Frequency must be greater than or equal to 1');
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
  Iterable<DateTime> getNextNOccurrences(int n, {DateTime? from}) sync* {
    var currentDate = _clampToBounds(from).startOfDay();
    currentDate = _getNextValidDay(from ?? startDate);

    final isLeapYear = currentDate.month == 2 && currentDate.day == 29;

    for (var i = 0; i < n; i++) {
      if (endDate case final endDate?) {
        if (currentDate.isLaterDateThan(endDate)) {
          break;
        }
      }

      yield currentDate;

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
  Iterable<DateTime> getOccurrencesUntil(DateTime end, {DateTime? from}) sync* {
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

    while (true) {
      if (isBeyondEndDates(currentDate)) {
        return;
      }

      yield currentDate;

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
