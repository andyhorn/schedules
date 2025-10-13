part of 'schedule_base.dart';

/// Represents a schedule that occurs only once.
class Singular extends Schedule {
  const Singular({
    // renamed to be more explicit that this is a single date
    required DateTime date,
  }) : super(startDate: date, endDate: date);

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
