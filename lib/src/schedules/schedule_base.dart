import 'package:schedules/src/schedules/clock_time.dart';
import 'package:schedules/src/utils/utils.dart';

part 'singular.dart';
part 'daily.dart';
part 'weekly.dart';
part 'monthly.dart';
part 'monthly_weekday.dart';
part 'yearly.dart';

/// Determines whether a schedule occurs at a specific time of day
/// or not.
sealed class ScheduleTimingMode {
  const ScheduleTimingMode();
}

/// A timing mode for schedules that occur on whole dates, without a
/// specific time of day.
final class UnTimed extends ScheduleTimingMode {
  /// Creates an un-timed timing mode.
  const UnTimed();
}

/// A timing mode for schedules that occur at one or more specific
/// [clockTimes] on each date.
final class Timed extends ScheduleTimingMode {
  /// Creates a timed timing mode occurring at the given [clockTimes].
  Timed({
    required Iterable<ClockTime> clockTimes,
  }) : clockTimes = List.unmodifiable(clockTimes);

  /// The times of day that the schedule occurs at.
  final List<ClockTime> clockTimes;
}

/// A schedule represents a set of dates that an event occurs on.
/// This is used to determine if an event occurs on a given date.
///
/// For example, a schedule could represent an event that occurs every
/// Monday and Wednesday.
/// Or, a schedule could represent an event that occurs every 2 months on
/// the 10th.
sealed class Schedule {
  Schedule({
    required this.startDate,
    this.endDate,
    this.timingMode = const UnTimed(),
  }) {
    if (endDate case final endDate?) {
      if (endDate.isEarlierDateThan(startDate)) {
        throw ArgumentError.value(
          endDate,
          'endDate',
          'End date must be on or after start date',
        );
      }
    }

    if (timingMode case Timed(:final clockTimes)) {
      if (clockTimes.isEmpty) {
        throw ArgumentError.value(
          clockTimes,
          'clockTimes',
          'Clock times list cannot be empty',
        );
      }
    }
  }

  /// The date that this schedule begins on.
  ///
  /// Note that this is not necessarily the first date that this schedule
  /// occurs.
  final DateTime startDate;

  /// The date that this schedule ends on.
  ///
  /// If this is `null`, then this schedule has no end date.
  final DateTime? endDate;

  /// The timing mode of this schedule.
  final ScheduleTimingMode timingMode;

  /// Whether this schedule is timed.
  bool get isTimed => timingMode is Timed;

  /// Determine if this schedule includes the given [date].
  bool occursOn(DateTime date);

  /// Determine if this schedule occurs at the given [clockTime].
  bool occursAt(ClockTime clockTime) {
    if (timingMode case Timed(:final clockTimes)) {
      return clockTimes.any((scheduledTime) => scheduledTime == clockTime);
    }

    return true;
  }

  /// Generates timed occurrences for a given date.
  /// Returns an iterable of DateTime instances with the scheduled times
  /// for the given date.
  Iterable<DateTime> _generateTimedOccurrences(DateTime date) {
    if (timingMode case Timed(:final clockTimes)) {
      return clockTimes.map((clockTime) => date.withClockTime(clockTime));
    }

    return [date];
  }

  /// Returns an iterable of the next [n] occurrences for this schedule.
  Iterable<DateTime> getNextNOccurrences(
    int n, {
    DateTime? from,
    Iterable<DateTime>? exclude,
  });

  /// Returns an iterable of the occurrences for this schedule until the
  /// given [end] date.
  Iterable<DateTime> getOccurrencesUntil(
    DateTime end, {
    DateTime? from,
    Iterable<DateTime>? exclude,
  });

  /// Returns a list of the next [n] dates for this schedule.
  // Kept through 2.0.0 to give existing callers a migration window; it now
  // delegates to getNextNOccurrences so it can no longer loop forever.
  // ignore: remove_deprecations_in_breaking_versions
  @Deprecated(
    'Use [getNextNOccurrences] instead, which returns an Iterable.'
    ' This method will be removed in a future version.',
  )
  List<DateTime> findNextNOccurrences(
    int n, {
    DateTime? fromDate,
    List<DateTime> excludeDates = const [],
  }) {
    return getNextNOccurrences(
      n,
      from: (fromDate ?? DateTime.now()).startOfDay(),
      exclude: excludeDates,
    ).toList();
  }

  /// Returns a list of dates active on the current schedule through
  /// [tillDate].
  // Kept through 2.0.0 to give existing callers a migration window; it now
  // delegates to getOccurrencesUntil so it can no longer loop forever.
  // ignore: remove_deprecations_in_breaking_versions
  @Deprecated(
    'Use [getOccurrencesUntil] instead, which returns an Iterable.'
    ' This method will be removed in a future version.',
  )
  List<DateTime> findNextTillDateOccurrences(
    DateTime tillDate, {
    DateTime? fromDate,
    List<DateTime> excludeDates = const [],
  }) {
    return getOccurrencesUntil(
      tillDate,
      from: (fromDate ?? DateTime.now()).startOfDay(),
      exclude: excludeDates,
    ).where((date) => date.isBefore(tillDate)).toList();
  }

  bool _isExcluded(DateTime date, Iterable<DateTime>? exclude) {
    return exclude?.any(date.isSameDateAs) ?? false;
  }

  bool _isBeyondEnd(DateTime date, [DateTime? until]) {
    if (endDate case final endDate?) {
      if (date.isLaterDateThan(endDate)) {
        return true;
      }
    }

    if (until != null && date.isLaterDateThan(until)) {
      return true;
    }

    return false;
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

  /// Clamps [date] to be no earlier than [startDate]. Dates beyond
  /// [endDate] are left as-is so the end-date guards produce empty results.
  DateTime _clampToBounds(DateTime? date) {
    if (date == null) return startDate;

    if (date.isEarlierDateThan(startDate)) {
      return startDate;
    }

    return date;
  }
}
