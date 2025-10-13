import 'package:schedules/src/utils/utils.dart';

part 'singular.dart';
part 'daily.dart';
part 'weekly.dart';
part 'monthly.dart';
part 'yearly.dart';

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
  Iterable<DateTime> getNextNOccurrences(
    int n, {
    DateTime? from,
    Iterable<DateTime>? exclude,
  });

  /// Returns an iterable of the occurrences for this schedule until the given [end] date.
  Iterable<DateTime> getOccurrencesUntil(
    DateTime end, {
    DateTime? from,
    Iterable<DateTime>? exclude,
  });

  /// Returns a list of the next [n] dates for this schedule.
  @Deprecated(
    'Use [getNextNOccurrences] instead, which returns an Iterable.'
    ' This method will be removed in a future version.',
  )
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
  @Deprecated(
    'Use [getOccurrencesUntil] instead, which returns an Iterable.'
    ' This method will be removed in a future version.',
  )
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
