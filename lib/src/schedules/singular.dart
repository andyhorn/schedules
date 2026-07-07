part of 'schedule_base.dart';

/// Represents a schedule that occurs only once.
class Singular extends Schedule {
  /// Creates a singular schedule that occurs on the given [date].
  factory Singular({
    required DateTime date,
  }) {
    return Singular._internal(
      startDate: date,
    );
  }
  Singular._internal({
    required super.startDate,
    super.timingMode,
  });

  /// Creates a singular schedule that occurs on the given date at the
  /// given time.
  factory Singular.timed({
    required DateTime date,
    required ClockTime clockTime,
  }) {
    return Singular._internal(
      startDate: date,
      timingMode: Timed(clockTimes: [clockTime]),
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
    if (n < 1) {
      return const [];
    }

    final isAfterStartDate = from != null && from.isLaterDateThan(startDate);

    if (isAfterStartDate || _isExcluded(startDate, exclude)) {
      return const [];
    }

    return _generateTimedOccurrences(startDate.startOfDay()).take(n).toList();
  }

  @override
  Iterable<DateTime> getOccurrencesUntil(
    DateTime end, {
    DateTime? from,
    Iterable<DateTime>? exclude,
  }) {
    final isAfterStartDate = from != null && from.isLaterDateThan(startDate);

    if (isAfterStartDate ||
        startDate.isLaterDateThan(end) ||
        _isExcluded(startDate, exclude)) {
      return const [];
    }

    return _generateTimedOccurrences(startDate.startOfDay()).toList();
  }
}
