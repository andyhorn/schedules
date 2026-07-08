## 2.0.0

As well as the breaking changes below, I should have bumped to 2.0.0 when I added the `MonthlyWeekday` schedule, as this broke any exhaustive pattern matching. My apologies.

Breaking changes:

- Rename `TimeOfDay` to `ClockTime` to help avoid collisions with Material's `TimeOfDay`.
- The internal `DateTime` helper extensions are no longer exported from `package:schedules/schedules.dart`; only `toClockTime` and `withClockTime` remain public.
- `Timed.clockTimes` is now a `List<ClockTime>` (an unmodifiable copy of the values passed in).
- `Weekly.weekdays` and `Monthly.days` are now unmodifiable copies of the lists passed to the constructors.

Bug fixes:

- `Singular.timed` occurrences now include the scheduled clock time instead of midnight.
- `Singular.getOccurrencesUntil` now checks the `end` and `exclude` bounds against the occurrence instead of the `from` date.
- `Singular.getNextNOccurrences` returns an empty iterable when `n < 1`.
- `Daily.getOccurrencesUntil` no longer yields occurrences before the schedule's start date when `from` is earlier than `startDate`.
- `Weekly.getNextNOccurrences` yields occurrences in chronological order (and no longer drops occurrences) when `weekdays` is not sorted.
- `Yearly` generators no longer yield occurrences earlier than the `from` date or the schedule's start date.
- `Yearly` schedules starting on February 29 now skip non-leap century years (e.g. 2100) instead of drifting to February 28.
- The deprecated `findNextNOccurrences` and `findNextTillDateOccurrences` methods now delegate to the iterable-based generators and can no longer loop forever when a schedule cannot produce the requested occurrences. For timed schedules they now return timed occurrences.
- `ClockTime.hashCode` no longer collides for permuted field values, and `ClockTime` now has a useful `toString`.

## 1.3.0
- Add support for timed events
  - Add a new `TimeOfDay` class
  - Add a new `occursAt(TimeOfDay)` method on all schedules
  - All schedules have a new `.timed` constructor that takes one or more `TimeOfDay` objects
  - List generation methods take times of day into account, when appropriate

## 1.2.0
- Add a new `MonthlyWeekday` schedule to represent events that occur on the _n_th weekday every _x_ months.

## 1.1.0

- Add new versions of list-generating methods using math-based Iterable generators for improved performance
- Mark previous brute-force list-generating methods deprecated

## 1.0.0

- Begin stable build versioning
- Add two new methods for generating lists of dates that occur on a given schedule (thank you @v.paragallo.ict)

## 0.0.5

- Fix bugs in the date comparisons by properly ignoring the time component
- Add a `daysApartFrom` extension to clean up the `difference` calculation

## 0.0.4

- Revise description for simplicity

## 0.0.3

- Add a release workflow file
- Add test and analyze workflow for CI
- Add an example
- Improve description

## 0.0.2

- Fix typos and grammar in README

## 0.0.1 - Initial Version (2023-10-08)

- Schedule sealed base class with subclasses for different schedule types:
  * Singular: A single occurrence
  * Daily: Repeats every _n_ days
  * Weekly: Repeats every _n_ weeks on the given weekdays (Su - Sa)
  * Monthly: Repeats every _n_ months on the given day(s) of the month
  * Yearly: Repeats every _n_ years on the specified date
- Optional `endDate` parameter to constrain the schedule