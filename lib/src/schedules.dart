import 'package:schedules/src/extensions.dart';

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

  bool _isWithinBounds(DateTime date) {
    if (date.isEarlierDateThan(startDate)) {
      return false;
    }

    if (endDate != null && date.isLaterDateThan(endDate!)) {
      return false;
    }

    return true;
  }

  List<DateTime> findNextNOccurrences(Schedule schedule, int n,
      {DateTime? fromDate, List<DateTime> excludeDates = const []}) {
    final dates = <DateTime>[];
    DateTime currentDate = fromDate ?? DateTime.now();
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
   
    excludeDates = excludeDates
        .map((element) => DateTime(element.year, element.month, element.day))
        .toList();

    while (dates.length < n && (endDate==null|| endDate!.isAfter(currentDate))) {
      // Here is the magic: Check if our Schedule occurs on the given date
      // using the "occursOn" method.
      //
      // If the current date fits the Schedule's pattern, add it to our list.
      if (schedule.occursOn(currentDate) &&
          !excludeDates.contains(currentDate)) {
        dates.add(currentDate);
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }

  List<DateTime> findNextTillDateOccurrences(
      Schedule schedule, DateTime tillDate,
      {DateTime? fromDate, List<DateTime> excludeDates = const []}) {
    final dates = <DateTime>[];
   DateTime currentDate = fromDate ?? DateTime.now();
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
    
    excludeDates = excludeDates
        .map((element) => DateTime(element.year, element.month, element.day))
        .toList();

    while (currentDate.isBefore(tillDate)) {
      // Here is the magic: Check if our Schedule occurs on the given date
      // using the "occursOn" method.
      //
      // If the current date fits the Schedule's pattern, add it to our list.
      if (schedule.occursOn(currentDate) &&
          !excludeDates.contains(currentDate)) {
        dates.add(currentDate);
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }
}

/// Represents a schedule that occurs only once.
class Singular extends Schedule {
  const Singular({
    // renamed to be more explicit that this is a single date
    required DateTime date,
  }) : super(startDate: date);

  @override
  bool occursOn(DateTime date) => startDate.isSameDateAs(date);
}

/// Represents a schedule that occurs every _n_ days.
class Daily extends Schedule {
  const Daily({
    required super.startDate,
    required this.frequency,
    super.endDate,
  });

  /// The frequency at which this schedule occurs.
  ///
  /// For example, if this is `2`, then this schedule occurs every other day.
  final int frequency;

  @override
  bool occursOn(DateTime date) {
    if (!_isWithinBounds(date)) {
      return false;
    }

    final difference = startDate.daysApartFrom(date);
    return difference % frequency == 0;
  }
}

/// Represents a schedule that occurs every _n_ weeks on the given [weekdays].
class Weekly extends Schedule {
  const Weekly({
    required super.startDate,
    required this.frequency,
    required this.weekdays,
    super.endDate,
  });

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

    final difference = startDate.daysApartFrom(date);
    final numWeeks = difference ~/ 7;
    return numWeeks % frequency == 0;
  }
}

/// Represents a schedule that occurs every _n_ months on the given [days].
class Monthly extends Schedule {
  const Monthly({
    required super.startDate,
    super.endDate,
    required this.days,
    required this.frequency,
  });

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
}

/// Represents a schedule that occurs every _n_ years.
///
/// This schedule occurs on the same day and month as the [startDate].
class Yearly extends Schedule {
  const Yearly({
    required super.startDate,
    super.endDate,
    required this.frequency,
  });

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
}
