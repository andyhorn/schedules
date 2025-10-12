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
      });
    });

    group(Daily, () {
      test('throws an error if frequency is 0', () {
        expect(() => Daily(startDate: DateTime(2023, 01, 01), frequency: 0),
            throwsA(isA<AssertionError>()));
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
            throwsA(isA<AssertionError>()));
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
            throwsA(isA<AssertionError>()));
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
      });
    });

    group(Yearly, () {
      test('throws an error if frequency is less than 1', () {
        expect(
            () => Yearly(
                  startDate: DateTime(2023, 01, 01),
                  frequency: 0,
                ),
            throwsA(isA<AssertionError>()));
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
          schedule.findNextNOccurrences(33, fromDate: schedule.startDate);

      expect(listDates.length, 18);
      expect(listDates.last, DateTime.parse('2024-09-17 00:00:00.000'));
    });
  });

  group('getNextNOccurrences', () {
    group('Weekly', () {
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
    });

    group('Monthly', () {
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
    });

    group('Yearly', () {
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
    });
  });
}
