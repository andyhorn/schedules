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
    });

    group(Daily, () {
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
    });

    group(Weekly, () {
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
    });

    group(Monthly, () {
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
    });

    group(Yearly, () {
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
    });
  });

  group('findNextNOccurrences', () {
    test('''given n required occurences if the end date happens 
      before the n'th occurence the method returns a lower number 
      of occurences within the start-date and end-date constraint''', () {
      Schedule schedule = Weekly(
          endDate: DateTime.parse('2024-09-21 00:00:00.000Z'),
          startDate: DateTime.parse('2024-05-20 00:00:00.000Z'),
          frequency: 1,
          weekdays: [2]);

      List<DateTime> listDates = schedule.findNextNOccurrences( 33, fromDate: schedule.startDate);

      expect(listDates.length, 18);
      expect(listDates.last, DateTime.parse('2024-09-17 00:00:00.000'));
    });
  });
}
