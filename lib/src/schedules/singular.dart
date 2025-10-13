part of 'schedule_base.dart';

/// Represents a schedule that occurs only once.
class Singular extends Schedule {
  Singular._internal({
    required super.startDate,
    super.timingMode,
  });

  /// Creates a singular schedule that occurs on the given [date].
  factory Singular({
    required DateTime date,
  }) {
    return Singular._internal(
      startDate: date,
    );
  }

  /// Creates a singular schedule that occurs on the given date at the given time.
  factory Singular.timed({
    required DateTime date,
    required TimeOfDay timeOfDay,
  }) {
    return Singular._internal(
      startDate: date,
      timingMode: Timed(timesOfDay: [timeOfDay]),
    );
  }

  @override
  bool occursOn(DateTime date) => startDate.isSameDateAs(date);

  @override
  Iterable<DateTime> getNextNOccurrences(
    int n, {
    DateTime? from,
    Iterable<DateTime>? exclude,
  }) {
    final isAfterStartDate = from != null && from.isLaterDateThan(startDate);
    final isExcluded = exclude?.any(startDate.isSameDateAs) ?? false;

    if (isAfterStartDate || isExcluded) {
      return const [];
    }

    return [startDate.startOfDay()];
  }

  @override
  Iterable<DateTime> getOccurrencesUntil(
    DateTime end, {
    DateTime? from,
    Iterable<DateTime>? exclude,
  }) {
    final date = from ?? startDate;
    final isAfterStartDate = date.isLaterDateThan(startDate);
    final isAfterEndDate = date.isLaterDateThan(end);
    final isExcluded = exclude?.any(date.isSameDateAs) ?? false;

    if (isAfterStartDate || isAfterEndDate || isExcluded) {
      return const [];
    }

    return [startDate.startOfDay()];
  }
}
