// Regression tests for bugs reported against the deprecated list-generating
// methods, which previously walked day-by-day and could loop forever when a
// schedule could not produce the requested number of occurrences.
//
// The deprecated methods are exactly what these tests cover.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:schedules/schedules.dart';
import 'package:test/test.dart';

void main() {
  group('known bugs', () {
    test(
      'findNextNOccurrences terminates when the end date arrives before '
      'the requested number of occurrences (Weekly, n: 33)',
      () {
        final schedule = Weekly(
          endDate: DateTime.parse('2024-09-21 00:00:00.000Z'),
          startDate: DateTime.parse('2024-05-20 00:00:00.000Z'),
          frequency: 1,
          weekdays: [DateTime.tuesday],
        );

        final dates = schedule.findNextNOccurrences(
          33,
          fromDate: schedule.startDate,
        );

        expect(dates, hasLength(18));
        expect(dates.last, DateTime.parse('2024-09-17 00:00:00.000'));
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test(
      'findNextNOccurrences terminates when a schedule without an end date '
      'cannot produce n occurrences (Singular, n: 2)',
      () {
        final schedule = Singular(date: DateTime(2024, 6, 15));

        final dates = schedule.findNextNOccurrences(
          2,
          fromDate: DateTime(2024, 6),
        );

        expect(dates, equals([DateTime(2024, 6, 15)]));
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );
  });
}
