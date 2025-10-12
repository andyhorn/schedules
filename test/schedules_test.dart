import 'package:schedules/schedules.dart';
import 'package:test/test.dart';

void main() {
  group(Schedule, () {
    group(Singular, () {
      group('#occursOn', () {
        test('is true on the correct date', () {
          final schedule = Singular(date: DateTime(2023, 01, 01, 12, 30, 45));
          expect(schedule.occursOn(DateTime(2023, 01, 01, 12, 45, 30)), isTrue);
        });

        test('is true with differing times', () {
          final schedule = Singular(date: DateTime(2023, 01, 01, 12, 30, 45));
          expect(schedule.occursOn(DateTime(2023, 01, 01, 12, 45, 00)), isTrue);
        });

        test('is false for incorrect date', () {
          final schedule = Singular(date: DateTime(2023, 01, 01));
          expect(schedule.occursOn(DateTime(2023, 01, 02)), isFalse);
        });
      });

      group('#getOccurrencesUntil', () {
        test('returns the single occurrence if within range', () {
          final schedule = Singular(date: DateTime(2023, 01, 01));
          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2023, 01, 10)).toList();

          expect(occurrences, [DateTime(2023, 01, 01)]);
        });

        test('returns empty if end date is before start date', () {
          final schedule = Singular(date: DateTime(2023, 01, 01));
          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2022, 12, 31)).toList();

          expect(occurrences, isEmpty);
        });

        test('returns empty if from date is after start date', () {
          final schedule = Singular(date: DateTime(2023, 01, 01));
          final occurrences = schedule
              .getOccurrencesUntil(DateTime(2023, 01, 10),
                  from: DateTime(2023, 01, 02))
              .toList();

          expect(occurrences, isEmpty);
        });

        test('returns the single occurrence if from date is before start date',
            () {
          final schedule = Singular(date: DateTime(2023, 01, 01));
          final occurrences = schedule
              .getOccurrencesUntil(DateTime(2023, 01, 10),
                  from: DateTime(2022, 12, 31))
              .toList();

          expect(occurrences, [DateTime(2022, 12, 31)]);
        });

        test('returns empty if from date is after end date', () {
          final schedule = Singular(date: DateTime(2023, 01, 01));
          final occurrences = schedule
              .getOccurrencesUntil(DateTime(2023, 01, 10),
                  from: DateTime(2023, 01, 15))
              .toList();

          expect(occurrences, isEmpty);
        });

        test('returns empty if the occurrence is excluded', () {
          final schedule = Singular(date: DateTime(2023, 01, 01));
          final occurrences = schedule.getOccurrencesUntil(
              DateTime(2023, 01, 10),
              exclude: [DateTime(2023, 01, 01)]).toList();

          expect(occurrences, isEmpty);
        });

        test('returns the occurrence if it is not excluded', () {
          final schedule = Singular(date: DateTime(2023, 01, 01));
          final occurrences = schedule.getOccurrencesUntil(
              DateTime(2023, 01, 10),
              exclude: [DateTime(2023, 01, 02)]).toList();

          expect(occurrences, [DateTime(2023, 01, 01)]);
        });
      });

      group('#getNextNOccurrences', () {
        test('returns the single occurrence if in range', () {
          final schedule = Singular(date: DateTime(2023, 01, 01));
          final occurrences = schedule.getNextNOccurrences(3).toList();

          expect(occurrences, [DateTime(2023, 01, 01)]);
        });

        test('returns empty if date is after start date', () {
          final schedule = Singular(date: DateTime(2023, 01, 01));
          final occurrences = schedule
              .getNextNOccurrences(1, from: DateTime(2023, 01, 02))
              .toList();

          expect(occurrences, isEmpty);
        });

        test('returns empty if the occurrence is excluded', () {
          final schedule = Singular(date: DateTime(2023, 01, 01));
          final occurrences = schedule.getNextNOccurrences(1,
              exclude: [DateTime(2023, 01, 01)]).toList();

          expect(occurrences, isEmpty);
        });

        test('returns the occurrence if it is not excluded', () {
          final schedule = Singular(date: DateTime(2023, 01, 01));
          final occurrences = schedule.getNextNOccurrences(1,
              exclude: [DateTime(2023, 01, 02)]).toList();

          expect(occurrences, [DateTime(2023, 01, 01)]);
        });
      });
    });

    group(Daily, () {
      test('throws an error if frequency is 0', () {
        expect(() => Daily(startDate: DateTime(2023, 01, 01), frequency: 0),
            throwsA(isA<ArgumentError>()));
      });

      group('#occursOn', () {
        test('is true on the start date', () {
          final schedule = Daily(
            startDate: DateTime(2023, 01, 01, 12, 30, 45),
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2023, 01, 01, 12, 45, 30)), isTrue);
        });

        test('is true on the pattern', () {
          final schedule = Daily(
            startDate: DateTime(2023, 01, 01, 8, 15, 45),
            frequency: 3,
          );

          expect(schedule.occursOn(DateTime(2023, 01, 04, 3, 19, 7)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 01, 07, 8, 12, 45)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 01, 10, 20, 19, 19)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 02, 03, 13, 13, 13)), isTrue);
        });

        test('is false before the start date', () {
          final schedule = Daily(
            startDate: DateTime(2023, 01, 01),
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2022, 12, 31)), isFalse);
        });

        test('is false after the end date', () {
          final schedule = Daily(
            startDate: DateTime(2023, 01, 01),
            endDate: DateTime(2023, 01, 10),
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2023, 01, 11)), isFalse);
        });

        test('handles end-of-month transitions correctly', () {
          final schedule = Daily(
            startDate: DateTime(2023, 1, 31),
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2023, 1, 31)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 2, 1)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 2, 28)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 3, 1)), isTrue);
        });

        test('handles month transitions with large frequency', () {
          final schedule = Daily(
            startDate: DateTime(2023, 1, 1),
            frequency: 30, // Every 30 days
          );

          expect(schedule.occursOn(DateTime(2023, 1, 1)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 1, 31)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 3, 2)), isTrue);
        });

        test('handles year transitions correctly', () {
          final schedule = Daily(
            startDate: DateTime(2023, 12, 31),
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2023, 12, 31)), isTrue);
          expect(schedule.occursOn(DateTime(2024, 1, 1)), isTrue);
          expect(schedule.occursOn(DateTime(2024, 1, 2)), isTrue);
        });

        test('handles very large frequency', () {
          final schedule = Daily(
            startDate: DateTime(2023, 1, 1),
            frequency: 1000, // Every 1000 days
          );

          expect(schedule.occursOn(DateTime(2023, 1, 1)), isTrue);
          expect(schedule.occursOn(DateTime(2025, 9, 27)),
              isTrue); // Exactly 1000 days later
          expect(schedule.occursOn(DateTime(2023, 1, 2)), isFalse);
          expect(schedule.occursOn(DateTime(2023, 1, 1001)),
              isTrue); // 1000 days later
        });
      });

      group('#getOccurrencesUntil', () {
        test('returns correct occurrences until end date', () {
          final schedule =
              Daily(startDate: DateTime(2023, 01, 01), frequency: 2);
          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2023, 01, 10)).toList();

          expect(occurrences, [
            DateTime(2023, 01, 01),
            DateTime(2023, 01, 03),
            DateTime(2023, 01, 05),
            DateTime(2023, 01, 07),
            DateTime(2023, 01, 09),
          ]);
        });

        test('respects endDate constraint', () {
          final schedule = Daily(
            startDate: DateTime(2023, 01, 01),
            endDate: DateTime(2023, 01, 05),
            frequency: 1,
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2023, 01, 10)).toList();

          expect(occurrences, [
            DateTime(2023, 01, 01),
            DateTime(2023, 01, 02),
            DateTime(2023, 01, 03),
            DateTime(2023, 01, 04),
            DateTime(2023, 01, 05),
          ]);
        });

        test('returns correct occurrences when starting mid-pattern', () {
          final schedule =
              Daily(startDate: DateTime(2023, 01, 01), frequency: 3);
          final occurrences = schedule
              .getOccurrencesUntil(DateTime(2023, 01, 15),
                  from: DateTime(2023, 01, 02))
              .toList();

          expect(occurrences, [
            DateTime(2023, 01, 04),
            DateTime(2023, 01, 07),
            DateTime(2023, 01, 10),
            DateTime(2023, 01, 13),
          ]);
        });

        test('returns empty if end date is before start date', () {
          final schedule =
              Daily(startDate: DateTime(2023, 01, 01), frequency: 1);
          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2022, 12, 31)).toList();

          expect(occurrences, isEmpty);
        });

        test('returns empty if from date is after end date', () {
          final schedule =
              Daily(startDate: DateTime(2023, 01, 01), frequency: 1);
          final occurrences = schedule
              .getOccurrencesUntil(DateTime(2023, 01, 05),
                  from: DateTime(2023, 01, 10))
              .toList();

          expect(occurrences, isEmpty);
        });

        test('returns empty if from date is after schedule end date', () {
          final schedule = Daily(
              startDate: DateTime(2023, 01, 01),
              frequency: 1,
              endDate: DateTime(2023, 01, 05));
          final occurrences = schedule
              .getOccurrencesUntil(DateTime(2023, 01, 15),
                  from: DateTime(2023, 01, 06))
              .toList();

          expect(occurrences, isEmpty);
        });

        test('excludes specified dates from results', () {
          final schedule =
              Daily(startDate: DateTime(2023, 01, 01), frequency: 2);
          final occurrences = schedule.getOccurrencesUntil(
              DateTime(2023, 01, 10),
              exclude: [DateTime(2023, 01, 03)]).toList();

          expect(occurrences, [
            DateTime(2023, 01, 01),
            DateTime(2023, 01, 05), // 03 is excluded
            DateTime(2023, 01, 07),
            DateTime(2023, 01, 09),
          ]);
        });

        test('excludes multiple specified dates from results', () {
          final schedule =
              Daily(startDate: DateTime(2023, 01, 01), frequency: 1);
          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2023, 01, 08), exclude: [
            DateTime(2023, 01, 02),
            DateTime(2023, 01, 04),
            DateTime(2023, 01, 06),
          ]).toList();

          expect(occurrences, [
            DateTime(2023, 01, 01),
            DateTime(2023, 01, 03), // 02, 04, 06 are excluded
            DateTime(2023, 01, 05),
            DateTime(2023, 01, 07),
            DateTime(2023, 01, 08),
          ]);
        });
      });

      group('#getNextNOccurrences', () {
        test('returns correct next occurrences', () {
          final schedule =
              Daily(startDate: DateTime(2023, 01, 01), frequency: 2);
          final occurrences = schedule.getNextNOccurrences(3).toList();

          expect(occurrences, [
            DateTime(2023, 01, 01),
            DateTime(2023, 01, 03),
            DateTime(2023, 01, 05),
          ]);
        });

        test('respects endDate', () {
          final schedule = Daily(
            startDate: DateTime(2023, 01, 01),
            endDate: DateTime(2023, 01, 04),
            frequency: 1,
          );

          final occurrences = schedule.getNextNOccurrences(5).toList();

          expect(occurrences, [
            DateTime(2023, 01, 01),
            DateTime(2023, 01, 02),
            DateTime(2023, 01, 03),
            DateTime(2023, 01, 04),
          ]);
        });

        test('returns correct occurrences when starting mid-pattern', () {
          final schedule =
              Daily(startDate: DateTime(2023, 01, 01), frequency: 3);
          final occurrences = schedule
              .getNextNOccurrences(3, from: DateTime(2023, 01, 02))
              .toList();

          expect(occurrences, [
            DateTime(2023, 01, 04),
            DateTime(2023, 01, 07),
            DateTime(2023, 01, 10),
          ]);
        });

        test('excludes specified dates from results', () {
          final schedule =
              Daily(startDate: DateTime(2023, 01, 01), frequency: 2);
          final occurrences = schedule.getNextNOccurrences(5,
              exclude: [DateTime(2023, 01, 03)]).toList();

          expect(occurrences, [
            DateTime(2023, 01, 01),
            DateTime(2023, 01, 05), // 03 is excluded
            DateTime(2023, 01, 07),
            DateTime(2023, 01, 09),
            DateTime(2023, 01, 11),
          ]);
        });

        test('excludes multiple specified dates from results', () {
          final schedule =
              Daily(startDate: DateTime(2023, 01, 01), frequency: 1);
          final occurrences = schedule.getNextNOccurrences(3, exclude: [
            DateTime(2023, 01, 02),
            DateTime(2023, 01, 04),
          ]).toList();

          expect(occurrences, [
            DateTime(2023, 01, 01),
            DateTime(2023, 01, 03), // 02 and 04 are excluded
            DateTime(2023, 01, 05),
          ]);
        });
      });
    });

    group(Weekly, () {
      test('throws an error if frequency is less than 1', () {
        expect(
            () => Weekly(
                  startDate: DateTime(2023, 01, 01),
                  frequency: 0,
                  weekdays: [DateTime.monday],
                ),
            throwsA(isA<ArgumentError>()));
      });

      test('throws error for empty weekdays list', () {
        expect(
            () => Weekly(
                  startDate: DateTime(2023, 1, 1),
                  frequency: 1,
                  weekdays: [], // Empty list
                ),
            throwsA(isA<ArgumentError>()));
      });

      test('throws error for invalid weekday values', () {
        expect(
            () => Weekly(
                  startDate: DateTime(2023, 1, 1),
                  frequency: 1,
                  weekdays: [0, 8], // Invalid weekdays (0 and 8)
                ),
            throwsA(isA<ArgumentError>()));
      });

      test('throws error for negative weekday values', () {
        expect(
            () => Weekly(
                  startDate: DateTime(2023, 1, 1),
                  frequency: 1,
                  weekdays: [-1, 3], // Negative weekday
                ),
            throwsA(isA<ArgumentError>()));
      });

      test('accepts valid weekday values', () {
        expect(
            () => Weekly(
                  startDate: DateTime(2023, 1, 1),
                  frequency: 1,
                  weekdays: [1, 2, 3, 4, 5, 6, 7], // All valid weekdays
                ),
            returnsNormally);
      });

      group('#occursOn', () {
        test('is false on the start date if it is not the correct weekday', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01), // Sunday
            frequency: 1,
            weekdays: [DateTime.monday],
          );

          expect(schedule.occursOn(DateTime(2023, 01, 01)), isFalse);
        });

        test('is true after the start date on the correct weekday', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01, 12, 30, 45),
            frequency: 1,
            weekdays: [DateTime.monday],
          );

          expect(schedule.occursOn(DateTime(2023, 01, 02, 12, 45, 30)), isTrue);
        });

        test('is true on the correct weekdays', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01, 12, 34, 56),
            frequency: 3,
            weekdays: [DateTime.monday, DateTime.friday],
          );

          expect(schedule.occursOn(DateTime(2023, 01, 06, 07, 08, 09)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 01, 23, 23, 23, 23)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 01, 27, 19, 19, 19)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 02, 13, 13, 13, 13)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 06, 19, 19, 19, 19)), isTrue);
        });

        test('is false on incorrect weekdays', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01),
            frequency: 3,
            weekdays: [DateTime.monday],
          );

          expect(schedule.occursOn(DateTime(2023, 01, 09)), isFalse);
          expect(schedule.occursOn(DateTime(2023, 01, 16)), isFalse);
          expect(schedule.occursOn(DateTime(2023, 01, 30)), isFalse);
        });

        test('is false before the start date', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01),
            frequency: 1,
            weekdays: [DateTime.monday],
          );

          expect(schedule.occursOn(DateTime(2022, 12, 26)), isFalse);
        });

        test('is false after the end date', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01),
            endDate: DateTime(2023, 01, 31),
            frequency: 1,
            weekdays: [DateTime.monday],
          );

          expect(schedule.occursOn(DateTime(2023, 02, 06)), isFalse);
        });

        test('handles very large frequency', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 1, 1),
            frequency: 52, // Every 52 weeks (1 year)
            weekdays: [DateTime.sunday],
          );

          expect(schedule.occursOn(DateTime(2023, 1, 1)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 12, 31)),
              isTrue); // Exactly 52 weeks later
          expect(schedule.occursOn(DateTime(2023, 1, 8)), isFalse);
          expect(schedule.occursOn(DateTime(2024, 12, 29)),
              isTrue); // Another 52 weeks later
        });
      });

      group('#getOccurrencesUntil', () {
        test('returns correct occurrences until end date', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01), // Sunday
            frequency: 1,
            weekdays: [DateTime.monday, DateTime.friday],
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2023, 01, 20)).toList();

          expect(occurrences, [
            DateTime(2023, 01, 02), // Monday
            DateTime(2023, 01, 06), // Friday
            DateTime(2023, 01, 09), // Monday
            DateTime(2023, 01, 13), // Friday
            DateTime(2023, 01, 16), // Monday
            DateTime(
                2023, 01, 20), // Friday (included because it's the end date)
          ]);
        });

        test('respects endDate constraint', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01),
            endDate: DateTime(2023, 01, 10),
            frequency: 1,
            weekdays: [DateTime.monday],
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2023, 01, 20)).toList();

          expect(occurrences, [
            DateTime(2023, 01, 02),
            DateTime(2023, 01, 09),
          ]);
        });

        test('returns correct occurrences when starting mid-pattern', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01), // Sunday
            frequency: 1,
            weekdays: [DateTime.monday, DateTime.friday],
          );

          final occurrences = schedule
              .getOccurrencesUntil(DateTime(2023, 01, 20),
                  from: DateTime(2023, 01, 03))
              .toList();

          expect(occurrences, [
            DateTime(2023, 01, 06), // Friday
            DateTime(2023, 01, 09), // Monday
            DateTime(2023, 01, 13), // Friday
            DateTime(2023, 01, 16), // Monday
            DateTime(
                2023, 01, 20), // Friday (included because it's the end date)
          ]);
        });

        test('handles frequency correctly', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01), // Sunday
            frequency: 2,
            weekdays: [DateTime.monday],
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2023, 01, 30)).toList();

          expect(occurrences, [
            DateTime(2023, 01, 09), // Monday week 2
            DateTime(2023, 01, 23), // Monday week 4
          ]);
        });

        test('returns empty if end date is before start date', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01),
            frequency: 1,
            weekdays: [DateTime.monday],
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2022, 12, 31)).toList();

          expect(occurrences, isEmpty);
        });

        test('returns empty if from date is after schedule end date', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01),
            endDate: DateTime(2023, 01, 05),
            frequency: 1,
            weekdays: [DateTime.monday],
          );

          final occurrences = schedule
              .getOccurrencesUntil(DateTime(2023, 01, 20),
                  from: DateTime(2023, 01, 06))
              .toList();

          expect(occurrences, isEmpty);
        });

        test('excludes specified dates from results', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01), // Sunday
            frequency: 1,
            weekdays: [DateTime.monday, DateTime.friday],
          );

          final occurrences = schedule.getOccurrencesUntil(
              DateTime(2023, 01, 20),
              exclude: [DateTime(2023, 01, 09)]).toList();

          expect(occurrences, [
            DateTime(2023, 01, 02),
            DateTime(2023, 01, 06),
            DateTime(2023, 01, 13), // 09 is excluded
            DateTime(2023, 01, 16),
            DateTime(2023, 01, 20),
          ]);
        });

        test('excludes multiple specified dates from results', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01), // Sunday
            frequency: 1,
            weekdays: [DateTime.monday, DateTime.friday],
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2023, 01, 20), exclude: [
            DateTime(2023, 01, 06),
            DateTime(2023, 01, 13),
          ]).toList();

          expect(occurrences, [
            DateTime(2023, 01, 02),
            DateTime(2023, 01, 09), // 06 and 13 are excluded
            DateTime(2023, 01, 16),
            DateTime(2023, 01, 20),
          ]);
        });
      });

      group('#getNextNOccurrences', () {
        test('returns correct occurrences', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01), // Sunday
            frequency: 1,
            weekdays: [DateTime.monday, DateTime.friday],
          );

          final occurrences = schedule.getNextNOccurrences(4).toList();

          expect(occurrences, [
            DateTime(2023, 01, 02),
            DateTime(2023, 01, 06),
            DateTime(2023, 01, 09),
            DateTime(2023, 01, 13),
          ]);
        });

        test('respects endDate', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01),
            endDate: DateTime(2023, 01, 10),
            frequency: 1,
            weekdays: [DateTime.monday],
          );

          final occurrences = schedule.getNextNOccurrences(5).toList();

          expect(occurrences, [
            DateTime(2023, 01, 02),
            DateTime(2023, 01, 09),
          ]);
        });

        test('returns correct occurrences when starting mid-pattern', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01), // Sunday
            frequency: 1,
            weekdays: [DateTime.monday, DateTime.friday],
          );

          final occurrences = schedule
              .getNextNOccurrences(4, from: DateTime(2023, 01, 03))
              .toList();

          expect(occurrences, [
            DateTime(2023, 01, 06),
            DateTime(2023, 01, 09),
            DateTime(2023, 01, 13),
            DateTime(2023, 01, 16),
          ]);
        });

        test('excludes specified dates from results', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01), // Sunday
            frequency: 1,
            weekdays: [DateTime.monday, DateTime.friday],
          );

          final occurrences = schedule.getNextNOccurrences(5,
              exclude: [DateTime(2023, 01, 09)]).toList();

          expect(occurrences, [
            DateTime(2023, 01, 02),
            DateTime(2023, 01, 06),
            DateTime(2023, 01, 13), // 09 is excluded
            DateTime(2023, 01, 16),
            DateTime(2023, 01, 20),
          ]);
        });

        test('excludes multiple specified dates from results', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01), // Sunday
            frequency: 1,
            weekdays: [DateTime.monday, DateTime.friday],
          );

          final occurrences = schedule.getNextNOccurrences(6, exclude: [
            DateTime(2023, 01, 06),
            DateTime(2023, 01, 13),
          ]).toList();

          expect(occurrences, [
            DateTime(2023, 01, 02),
            DateTime(2023, 01, 09), // 06 and 13 are excluded
            DateTime(2023, 01, 16),
            DateTime(2023, 01, 20),
            DateTime(2023, 01, 23),
            DateTime(2023, 01, 27),
          ]);
        });
      });
    });

    group(Monthly, () {
      test('throws an error if frequency is less than 1', () {
        expect(
            () => Monthly(
                  startDate: DateTime(2023, 01, 01),
                  days: [1],
                  frequency: 0,
                ),
            throwsA(isA<ArgumentError>()));
      });

      test('throws error for empty days list', () {
        expect(
            () => Monthly(
                  startDate: DateTime(2023, 1, 1),
                  days: [], // Empty list
                  frequency: 1,
                ),
            throwsA(isA<ArgumentError>()));
      });

      test('throws error for invalid day values', () {
        expect(
            () => Monthly(
                  startDate: DateTime(2023, 1, 1),
                  days: [0, 32], // Invalid days (0 and 32)
                  frequency: 1,
                ),
            throwsA(isA<ArgumentError>()));
      });

      test('throws error for negative day values', () {
        expect(
            () => Monthly(
                  startDate: DateTime(2023, 1, 1),
                  days: [-1, 15], // Negative day
                  frequency: 1,
                ),
            throwsA(isA<ArgumentError>()));
      });

      test('accepts valid day values', () {
        expect(
            () => Monthly(
                  startDate: DateTime(2023, 1, 1),
                  days: [1, 15, 31], // Valid days
                  frequency: 1,
                ),
            returnsNormally);
      });

      group('#occursOn', () {
        test('is false on the start date if it is not a selected date', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            days: [2],
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2023, 01, 01)), isFalse);
        });

        test('is true on the start date if it is a selected date', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 02, 03, 04, 05),
            days: [2],
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2023, 01, 02, 05, 04, 03)), isTrue);
        });

        test('is true on a correct date', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01, 02, 03, 04),
            days: [1, 15],
            frequency: 2,
          );

          expect(schedule.occursOn(DateTime(2023, 01, 15, 15, 15, 15)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 03, 01, 01, 01, 01)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 03, 15, 15, 15, 15)), isTrue);
          expect(schedule.occursOn(DateTime(2024, 03, 15, 15, 15, 15)), isTrue);
        });

        test('is false on an incorrect date', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            days: [1, 15],
            frequency: 2,
          );

          expect(schedule.occursOn(DateTime(2023, 02, 01)), isFalse);
          expect(schedule.occursOn(DateTime(2023, 02, 15)), isFalse);
          expect(schedule.occursOn(DateTime(2023, 02, 16)), isFalse);
          expect(schedule.occursOn(DateTime(2023, 03, 02)), isFalse);
        });

        test('is false before the start date', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            days: [1],
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2022, 12, 01)), isFalse);
        });

        test('is false after the end date', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            endDate: DateTime(2023, 02, 28),
            days: [1],
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2023, 03, 01)), isFalse);
        });

        test('handles very large frequency', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 1, 1),
            days: [1],
            frequency: 12, // Every 12 months (1 year)
          );

          expect(schedule.occursOn(DateTime(2023, 1, 1)), isTrue);
          expect(schedule.occursOn(DateTime(2024, 1, 1)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 2, 1)), isFalse);
        });
      });

      group('#getOccurrencesUntil', () {
        test('returns correct occurrences until end date', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            days: [1, 15],
            frequency: 1,
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2023, 03, 20)).toList();

          expect(occurrences, [
            DateTime(2023, 01, 01),
            DateTime(2023, 01, 15),
            DateTime(2023, 02, 01),
            DateTime(2023, 02, 15),
            DateTime(2023, 03, 01),
            DateTime(2023, 03, 15),
          ]);
        });

        test('respects endDate constraint', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            endDate: DateTime(2023, 02, 10),
            days: [1, 15],
            frequency: 1,
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2023, 03, 20)).toList();

          expect(occurrences, [
            DateTime(2023, 01, 01),
            DateTime(2023, 01, 15),
            DateTime(2023, 02, 01),
          ]);
        });

        test('returns correct occurrences when starting mid-pattern', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            days: [1, 15],
            frequency: 1,
          );

          final occurrences = schedule
              .getOccurrencesUntil(DateTime(2023, 03, 20),
                  from: DateTime(2023, 01, 16))
              .toList();

          expect(occurrences, [
            DateTime(2023, 02, 01),
            DateTime(2023, 02, 15),
            DateTime(2023, 03, 01),
            DateTime(2023, 03, 15),
          ]);
        });

        test('handles frequency correctly', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            days: [1],
            frequency: 2,
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2023, 07, 20)).toList();

          expect(occurrences, [
            DateTime(2023, 01, 01),
            DateTime(2023, 03, 01),
            DateTime(2023, 05, 01),
            DateTime(2023, 07, 01),
          ]);
        });

        test('skips invalid days in short months', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            days: [31],
            frequency: 1,
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2023, 05, 20)).toList();

          expect(occurrences, [
            DateTime(2023, 01, 31),
            DateTime(2023, 03, 31),
          ]);
        });

        test('returns empty if end date is before start date', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            days: [1],
            frequency: 1,
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2022, 12, 31)).toList();

          expect(occurrences, isEmpty);
        });

        test('returns empty if from date is after schedule end date', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            endDate: DateTime(2023, 01, 05),
            days: [1],
            frequency: 1,
          );

          final occurrences = schedule
              .getOccurrencesUntil(DateTime(2023, 03, 20),
                  from: DateTime(2023, 01, 06))
              .toList();

          expect(occurrences, isEmpty);
        });

        test('excludes specified dates from results', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            days: [1, 15],
            frequency: 1,
          );

          final occurrences = schedule.getOccurrencesUntil(
              DateTime(2023, 03, 20),
              exclude: [DateTime(2023, 01, 15)]).toList();

          expect(occurrences, [
            DateTime(2023, 01, 01),
            DateTime(2023, 02, 01), // 01/15 is excluded
            DateTime(2023, 02, 15),
            DateTime(2023, 03, 01),
            DateTime(2023, 03, 15),
          ]);
        });

        test('excludes multiple specified dates from results', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            days: [1, 15],
            frequency: 1,
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2023, 04, 20), exclude: [
            DateTime(2023, 01, 15),
            DateTime(2023, 02, 01),
          ]).toList();

          expect(occurrences, [
            DateTime(2023, 01, 01),
            DateTime(2023, 02, 15), // 01/15 and 02/01 are excluded
            DateTime(2023, 03, 01),
            DateTime(2023, 03, 15),
            DateTime(2023, 04, 01),
            DateTime(2023, 04, 15),
          ]);
        });
      });

      group('#getNextNOccurrences', () {
        test('returns correct days', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            days: [1, 15],
            frequency: 1,
          );

          final occurrences = schedule.getNextNOccurrences(4).toList();

          expect(occurrences, [
            DateTime(2023, 01, 01),
            DateTime(2023, 01, 15),
            DateTime(2023, 02, 01),
            DateTime(2023, 02, 15),
          ]);
        });

        test('respects endDate', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            endDate: DateTime(2023, 03, 10),
            days: [1, 15],
            frequency: 1,
          );

          final occurrences = schedule.getNextNOccurrences(6).toList();

          expect(occurrences, [
            DateTime(2023, 01, 01),
            DateTime(2023, 01, 15),
            DateTime(2023, 02, 01),
            DateTime(2023, 02, 15),
            DateTime(2023, 03, 01),
          ]);
        });

        test('returns correct occurrences when starting mid-pattern', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            days: [1, 15],
            frequency: 1,
          );

          final occurrences = schedule
              .getNextNOccurrences(4, from: DateTime(2023, 01, 16))
              .toList();

          expect(occurrences, [
            DateTime(2023, 02, 01),
            DateTime(2023, 02, 15),
            DateTime(2023, 03, 01),
            DateTime(2023, 03, 15),
          ]);
        });

        test('skips invalid days in short months', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            days: [31],
            frequency: 1,
          );

          final occurrences = schedule.getNextNOccurrences(3).toList();

          expect(occurrences, [
            DateTime(2023, 01, 31),
            DateTime(2023, 03, 31),
            DateTime(2023, 05, 31),
          ]);
        });

        test('handles starting at the end of a month', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            days: [31],
            frequency: 1,
          );

          final occurrences = schedule
              .getNextNOccurrences(3, from: DateTime(2023, 01, 31))
              .toList();

          expect(occurrences, [
            DateTime(2023, 01, 31),
            DateTime(2023, 03, 31),
            DateTime(2023, 05, 31),
          ]);
        });

        test('handles starting at the end of a month with frequency 2', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            days: [31],
            frequency: 2,
          );

          final occurrences = schedule
              .getNextNOccurrences(3, from: DateTime(2023, 01, 31))
              .toList();

          expect(occurrences, [
            DateTime(2023, 01, 31),
            DateTime(2023, 03, 31),
            DateTime(2023, 05, 31),
          ]);
        });

        test('excludes specified dates from results', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            days: [1, 15],
            frequency: 1,
          );

          final occurrences = schedule.getNextNOccurrences(5,
              exclude: [DateTime(2023, 01, 15)]).toList();

          expect(occurrences, [
            DateTime(2023, 01, 01),
            DateTime(2023, 02, 01), // 01/15 is excluded
            DateTime(2023, 02, 15),
            DateTime(2023, 03, 01),
            DateTime(2023, 03, 15),
          ]);
        });

        test('excludes multiple specified dates from results', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            days: [1, 15],
            frequency: 1,
          );

          final occurrences = schedule.getNextNOccurrences(6, exclude: [
            DateTime(2023, 01, 15),
            DateTime(2023, 02, 01),
          ]).toList();

          expect(occurrences, [
            DateTime(2023, 01, 01),
            DateTime(2023, 02, 15), // 01/15 and 02/01 are excluded
            DateTime(2023, 03, 01),
            DateTime(2023, 03, 15),
            DateTime(2023, 04, 01),
            DateTime(2023, 04, 15),
          ]);
        });
      });
    });

    group(Yearly, () {
      test('throws an error if frequency is less than 1', () {
        expect(
            () => Yearly(
                  startDate: DateTime(2023, 01, 01),
                  frequency: 0,
                ),
            throwsA(isA<ArgumentError>()));
      });

      group('#occursOn', () {
        test('is true on the start date', () {
          final schedule = Yearly(
            startDate: DateTime(2023, 01, 01, 12, 30, 30),
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2023, 01, 01, 13, 13, 13)), isTrue);
        });

        test('is true on a correct date', () {
          final schedule = Yearly(
            startDate: DateTime(2023, 01, 01, 12, 30, 30),
            frequency: 2,
          );

          expect(schedule.occursOn(DateTime(2025, 01, 01, 02, 03, 04)), isTrue);
          expect(schedule.occursOn(DateTime(2027, 01, 01, 04, 05, 06)), isTrue);
          expect(schedule.occursOn(DateTime(2029, 01, 01, 06, 07, 08)), isTrue);
        });

        test('is false on an incorrect date', () {
          final schedule = Yearly(
            startDate: DateTime(2023, 01, 01),
            frequency: 2,
          );

          expect(schedule.occursOn(DateTime(2024, 01, 01)), isFalse);
          expect(schedule.occursOn(DateTime(2026, 01, 01)), isFalse);
          expect(schedule.occursOn(DateTime(2028, 01, 01)), isFalse);
          expect(schedule.occursOn(DateTime(2030, 01, 01)), isFalse);
        });

        test('is false before the start date', () {
          final schedule = Yearly(
            startDate: DateTime(2023, 01, 01),
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2022, 01, 01)), isFalse);
        });

        test('is false after the end date', () {
          final schedule = Yearly(
            startDate: DateTime(2023, 01, 01),
            endDate: DateTime(2025, 01, 01),
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2026, 01, 01)), isFalse);
        });

        test('handles very large frequency', () {
          final schedule = Yearly(
            startDate: DateTime(2023, 1, 1),
            frequency: 10, // Every 10 years
          );

          expect(schedule.occursOn(DateTime(2023, 1, 1)), isTrue);
          expect(schedule.occursOn(DateTime(2033, 1, 1)), isTrue);
          expect(schedule.occursOn(DateTime(2024, 1, 1)), isFalse);
        });
      });

      group('#getOccurrencesUntil', () {
        test('returns correct occurrences until end date', () {
          final schedule = Yearly(
            startDate: DateTime(2020, 01, 01),
            frequency: 1,
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2023, 01, 01)).toList();

          expect(occurrences, [
            DateTime(2020, 01, 01),
            DateTime(2021, 01, 01),
            DateTime(2022, 01, 01),
            DateTime(2023, 01, 01), // Included because it's the end date
          ]);
        });

        test('respects endDate constraint', () {
          final schedule = Yearly(
            startDate: DateTime(2020, 01, 01),
            endDate: DateTime(2022, 01, 01),
            frequency: 1,
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2025, 01, 01)).toList();

          expect(occurrences, [
            DateTime(2020, 01, 01),
            DateTime(2021, 01, 01),
            DateTime(2022, 01, 01),
          ]);
        });

        test('returns correct occurrences when starting mid-pattern', () {
          final schedule = Yearly(
            startDate: DateTime(2020, 01, 01),
            frequency: 2,
          );

          final occurrences = schedule
              .getOccurrencesUntil(DateTime(2026, 01, 01),
                  from: DateTime(2021, 06, 15))
              .toList();

          expect(occurrences, [
            DateTime(2022, 01, 01),
            DateTime(2024, 01, 01),
            DateTime(2026, 01, 01), // Included because it's the end date
          ]);
        });

        test('handles frequency correctly', () {
          final schedule = Yearly(
            startDate: DateTime(2020, 01, 01),
            frequency: 2,
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2028, 01, 01)).toList();

          expect(occurrences, [
            DateTime(2020, 01, 01),
            DateTime(2022, 01, 01),
            DateTime(2024, 01, 01),
            DateTime(2026, 01, 01),
            DateTime(2028, 01, 01), // Included because it's the end date
          ]);
        });

        test('handles leap years correctly', () {
          final schedule = Yearly(
            startDate: DateTime(2020, 02, 29),
            frequency: 1,
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2032, 02, 29)).toList();

          expect(occurrences, [
            DateTime(2020, 02, 29),
            DateTime(2024, 02, 29),
            DateTime(2028, 02, 29),
            DateTime(2032, 02, 29), // Included because it's the end date
          ]);
        });

        test('handles leap years correctly with frequency other than 1', () {
          final schedule = Yearly(
            startDate: DateTime(2020, 02, 29),
            frequency: 2,
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2032, 02, 29)).toList();

          expect(occurrences, [
            DateTime(2020, 02, 29),
            DateTime(2024, 02, 29),
            DateTime(2028, 02, 29),
            DateTime(2032, 02, 29), // Included because it's the end date
          ]);
        });

        test('handles leap years correctly with odd frequency', () {
          final schedule = Yearly(
            startDate: DateTime(2020, 02, 29),
            frequency: 3,
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2056, 02, 29)).toList();

          expect(occurrences, [
            DateTime(2020, 02, 29),
            DateTime(2032, 02, 29),
            DateTime(2044, 02, 29),
            DateTime(2056, 02, 29), // Included because it's the end date
          ]);
        });

        test('returns empty if end date is before start date', () {
          final schedule = Yearly(
            startDate: DateTime(2023, 01, 01),
            frequency: 1,
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2022, 12, 31)).toList();

          expect(occurrences, isEmpty);
        });

        test('excludes specified dates from results', () {
          final schedule = Yearly(
            startDate: DateTime(2020, 01, 01),
            frequency: 1,
          );

          final occurrences = schedule.getOccurrencesUntil(
              DateTime(2025, 01, 01),
              exclude: [DateTime(2021, 01, 01)]).toList();

          expect(occurrences, [
            DateTime(2020, 01, 01),
            DateTime(2022, 01, 01), // 2021 is excluded
            DateTime(2023, 01, 01),
            DateTime(2024, 01, 01),
            DateTime(2025, 01, 01),
          ]);
        });

        test('excludes multiple specified dates from results', () {
          final schedule = Yearly(
            startDate: DateTime(2020, 01, 01),
            frequency: 1,
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2026, 01, 01), exclude: [
            DateTime(2021, 01, 01),
            DateTime(2023, 01, 01),
          ]).toList();

          expect(occurrences, [
            DateTime(2020, 01, 01),
            DateTime(2022, 01, 01), // 2021 and 2023 are excluded
            DateTime(2024, 01, 01),
            DateTime(2025, 01, 01),
            DateTime(2026, 01, 01),
          ]);
        });
      });

      group('#getNextNOccurrences', () {
        test('returns correct dates', () {
          final schedule = Yearly(
            startDate: DateTime(2020, 01, 01),
            frequency: 1,
          );

          final occurrences = schedule.getNextNOccurrences(3).toList();

          expect(occurrences, [
            DateTime(2020, 01, 01),
            DateTime(2021, 01, 01),
            DateTime(2022, 01, 01),
          ]);
        });

        test('returns correct dates with frequency', () {
          final schedule = Yearly(
            startDate: DateTime(2020, 01, 01),
            frequency: 2,
          );

          final occurrences = schedule.getNextNOccurrences(3).toList();

          expect(occurrences, [
            DateTime(2020, 01, 01),
            DateTime(2022, 01, 01),
            DateTime(2024, 01, 01),
          ]);
        });

        test('respects endDate', () {
          final schedule = Yearly(
            startDate: DateTime(2020, 01, 01),
            endDate: DateTime(2024, 01, 01),
            frequency: 2,
          );

          final occurrences = schedule.getNextNOccurrences(5).toList();

          expect(occurrences, [
            DateTime(2020, 01, 01),
            DateTime(2022, 01, 01),
            DateTime(2024, 01, 01),
          ]);
        });

        test('returns correct occurrences when starting mid-pattern', () {
          final schedule = Yearly(
            startDate: DateTime(2020, 01, 01),
            frequency: 2,
          );

          final occurrences = schedule
              .getNextNOccurrences(3, from: DateTime(2021, 06, 15))
              .toList();

          expect(occurrences, [
            DateTime(2022, 01, 01),
            DateTime(2024, 01, 01),
            DateTime(2026, 01, 01),
          ]);
        });

        test('handles leap years correctly', () {
          final schedule = Yearly(
            startDate: DateTime(2020, 02, 29),
            frequency: 1,
          );

          final occurrences = schedule.getNextNOccurrences(4).toList();

          expect(occurrences, [
            DateTime(2020, 02, 29),
            DateTime(2024, 02, 29),
            DateTime(2028, 02, 29),
            DateTime(2032, 02, 29),
          ]);
        });

        test('handles leap years correctly with frequency other than 1', () {
          final schedule = Yearly(
            startDate: DateTime(2020, 02, 29),
            frequency: 2,
          );

          final occurrences = schedule.getNextNOccurrences(4).toList();

          expect(occurrences, [
            DateTime(2020, 02, 29),
            DateTime(2024, 02, 29),
            DateTime(2028, 02, 29),
            DateTime(2032, 02, 29),
          ]);
        });

        test('handles leap years correctly with odd frequency', () {
          final schedule = Yearly(
            startDate: DateTime(2020, 02, 29),
            frequency: 3,
          );

          final occurrences = schedule.getNextNOccurrences(4).toList();

          expect(occurrences, [
            DateTime(2020, 02, 29),
            DateTime(2032, 02, 29),
            DateTime(2044, 02, 29),
            DateTime(2056, 02, 29),
          ]);
        });

        test('excludes specified dates from results', () {
          final schedule = Yearly(
            startDate: DateTime(2020, 01, 01),
            frequency: 1,
          );

          final occurrences = schedule.getNextNOccurrences(4,
              exclude: [DateTime(2021, 01, 01)]).toList();

          expect(occurrences, [
            DateTime(2020, 01, 01),
            DateTime(2022, 01, 01), // 2021 is excluded
            DateTime(2023, 01, 01),
            DateTime(2024, 01, 01),
          ]);
        });

        test('excludes multiple specified dates from results', () {
          final schedule = Yearly(
            startDate: DateTime(2020, 01, 01),
            frequency: 1,
          );

          final occurrences = schedule.getNextNOccurrences(5, exclude: [
            DateTime(2021, 01, 01),
            DateTime(2023, 01, 01),
          ]).toList();

          expect(occurrences, [
            DateTime(2020, 01, 01),
            DateTime(2022, 01, 01), // 2021 and 2023 are excluded
            DateTime(2024, 01, 01),
            DateTime(2025, 01, 01),
            DateTime(2026, 01, 01),
          ]);
        });
      });
    });
  });

  group('findNextNOccurrences', () {
    test('''given n required occurrences if the end date happens 
      before the n'th occurrence the method returns a lower number 
      of occurrences within the start-date and end-date constraint''', () {
      Schedule schedule = Weekly(
          endDate: DateTime.parse('2024-09-21 00:00:00.000Z'),
          startDate: DateTime.parse('2024-05-20 00:00:00.000Z'),
          frequency: 1,
          weekdays: [2]);

      List<DateTime> listDates =
          // ignore: deprecated_member_use_from_same_package
          schedule.findNextNOccurrences(33, fromDate: schedule.startDate);

      expect(listDates.length, 18);
      expect(listDates.last, DateTime.parse('2024-09-17 00:00:00.000'));
    });
  });

  group('Performance Tests', () {
    test('handles large number of occurrences efficiently', () {
      final schedule = Daily(startDate: DateTime(2023, 1, 1), frequency: 1);
      final stopwatch = Stopwatch()..start();

      final occurrences = schedule.getNextNOccurrences(1000).toList();

      stopwatch.stop();
      expect(occurrences.length, equals(1000));
      expect(occurrences.last,
          equals(DateTime(2023, 1, 1).add(Duration(days: 999))));
      expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be fast
    });

    test('handles large frequency efficiently', () {
      final schedule = Daily(startDate: DateTime(2023, 1, 1), frequency: 1000);
      final stopwatch = Stopwatch()..start();

      final occurrences = schedule.getNextNOccurrences(10).toList();

      stopwatch.stop();
      expect(occurrences.length, equals(10));
      expect(occurrences[1],
          equals(DateTime(2023, 1, 1).add(Duration(days: 1000))));
      expect(stopwatch.elapsedMilliseconds, lessThan(50)); // Should be fast
    });

    test('handles large date ranges efficiently', () {
      final schedule = Daily(
        startDate: DateTime(2023, 1, 1),
        frequency: 1,
        endDate: DateTime(2025, 1, 1),
      );

      final stopwatch = Stopwatch()..start();
      final occurrences =
          schedule.getOccurrencesUntil(DateTime(2025, 1, 1)).toList();
      stopwatch.stop();

      expect(occurrences.length,
          equals(732)); // 2 years + 1 day (including end date)
      expect(stopwatch.elapsedMilliseconds, lessThan(200)); // Should be fast
    });
  });

  group('Real-World Scenario Tests', () {
    test('bi-weekly payroll schedule', () {
      // Every other Friday starting from Jan 6, 2023
      final schedule = Weekly(
        startDate: DateTime(2023, 1, 6), // First Friday
        frequency: 2,
        weekdays: [DateTime.friday],
      );

      final paydays = schedule.getNextNOccurrences(6).toList();
      expect(paydays[0], equals(DateTime(2023, 1, 6)));
      expect(paydays[1], equals(DateTime(2023, 1, 20)));
      expect(paydays[2], equals(DateTime(2023, 2, 3)));
      expect(paydays[3], equals(DateTime(2023, 2, 17)));
      expect(paydays[4], equals(DateTime(2023, 3, 3)));
      expect(paydays[5], equals(DateTime(2023, 3, 17)));
    });

    test('quarterly report schedule', () {
      // Every 3 months on the 15th
      final schedule = Monthly(
        startDate: DateTime(2023, 1, 15),
        days: [15],
        frequency: 3,
      );

      final reports =
          schedule.getOccurrencesUntil(DateTime(2024, 1, 1)).toList();
      expect(reports.length, equals(4)); // Q1, Q2, Q3, Q4
      expect(reports[0], equals(DateTime(2023, 1, 15)));
      expect(reports[1], equals(DateTime(2023, 4, 15)));
      expect(reports[2], equals(DateTime(2023, 7, 15)));
      expect(reports[3], equals(DateTime(2023, 10, 15)));
    });

    test('daily standup meeting schedule', () {
      // Every weekday (Monday to Friday)
      final schedule = Weekly(
        startDate: DateTime(2023, 1, 2), // First Monday
        frequency: 1,
        weekdays: [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
        ],
      );

      final meetings = schedule.getNextNOccurrences(10).toList();
      expect(meetings.length, equals(10));
      expect(meetings[0], equals(DateTime(2023, 1, 2))); // Monday
      expect(meetings[1], equals(DateTime(2023, 1, 3))); // Tuesday
      expect(meetings[2], equals(DateTime(2023, 1, 4))); // Wednesday
      expect(meetings[3], equals(DateTime(2023, 1, 5))); // Thursday
      expect(meetings[4], equals(DateTime(2023, 1, 6))); // Friday
      expect(meetings[5], equals(DateTime(2023, 1, 9))); // Next Monday
    });

    test('monthly rent payment schedule', () {
      // First day of every month
      final schedule = Monthly(
        startDate: DateTime(2023, 1, 1),
        days: [1],
        frequency: 1,
      );

      final payments =
          schedule.getOccurrencesUntil(DateTime(2024, 1, 1)).toList();
      expect(payments.length, equals(13)); // 12 months + 1 (including end date)
      expect(payments[0], equals(DateTime(2023, 1, 1)));
      expect(payments[11], equals(DateTime(2023, 12, 1)));
    });

    test('annual subscription renewal', () {
      // Every year on the same date
      final schedule = Yearly(
        startDate: DateTime(2023, 3, 15),
        frequency: 1,
      );

      final renewals = schedule.getNextNOccurrences(5).toList();
      expect(renewals.length, equals(5));
      expect(renewals[0], equals(DateTime(2023, 3, 15)));
      expect(renewals[1], equals(DateTime(2024, 3, 15)));
      expect(renewals[2], equals(DateTime(2025, 3, 15)));
      expect(renewals[3], equals(DateTime(2026, 3, 15)));
      expect(renewals[4], equals(DateTime(2027, 3, 15)));
    });

    test('complex monthly schedule with multiple days', () {
      // Every 2 months on the 1st, 15th, and last day
      final schedule = Monthly(
        startDate: DateTime(2023, 1, 1),
        days: [1, 15, 31], // Including last day
        frequency: 2,
      );

      final occurrences =
          schedule.getOccurrencesUntil(DateTime(2023, 7, 1)).toList();
      expect(occurrences.length,
          equals(10)); // 3 months * 3 days + 1 (including end date)
      expect(occurrences[0], equals(DateTime(2023, 1, 1)));
      expect(occurrences[1], equals(DateTime(2023, 1, 15)));
      expect(occurrences[2], equals(DateTime(2023, 1, 31)));
      expect(occurrences[3], equals(DateTime(2023, 3, 1)));
      expect(occurrences[4], equals(DateTime(2023, 3, 15)));
      expect(occurrences[5], equals(DateTime(2023, 3, 31)));
      expect(occurrences[6], equals(DateTime(2023, 5, 1)));
      expect(occurrences[7], equals(DateTime(2023, 5, 15)));
      expect(occurrences[8], equals(DateTime(2023, 5, 31)));
      expect(occurrences[9], equals(DateTime(2023, 7, 1))); // End date
    });

    test('weekly schedule across month boundaries', () {
      // Every Tuesday and Friday, starting mid-month
      final schedule = Weekly(
        startDate: DateTime(2023, 1, 15), // Mid-month start
        frequency: 1,
        weekdays: [DateTime.tuesday, DateTime.friday],
      );

      final occurrences =
          schedule.getOccurrencesUntil(DateTime(2023, 2, 15)).toList();
      expect(occurrences.length,
          equals(9)); // There are 9 Tuesdays/Fridays between 2023-01-15 and 2023-02-15 inclusive
      expect(occurrences[0], equals(DateTime(2023, 1, 17))); // First Tuesday
      expect(occurrences[1], equals(DateTime(2023, 1, 20))); // First Friday
      expect(occurrences[2], equals(DateTime(2023, 1, 24))); // Second Tuesday
      expect(occurrences[3], equals(DateTime(2023, 1, 27))); // Second Friday
      expect(occurrences[4], equals(DateTime(2023, 1, 31))); // Third Tuesday
      expect(occurrences[5], equals(DateTime(2023, 2, 3))); // Third Friday
      expect(occurrences[6], equals(DateTime(2023, 2, 7))); // Fourth Tuesday
      expect(occurrences[7], equals(DateTime(2023, 2, 10))); // Fourth Friday
      expect(occurrences[8],
          equals(DateTime(2023, 2, 14))); // Fifth Tuesday (end date)
    });
  });
}
