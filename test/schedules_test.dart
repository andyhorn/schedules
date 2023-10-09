import 'package:schedules/schedules.dart';
import 'package:test/test.dart';

void main() {
  group(Schedule, () {
    group(Singular, () {
      group('#occursOn', () {
        test('is true on the correct date', () {
          final schedule = Singular(date: DateTime(2023, 01, 01));
          expect(schedule.occursOn(DateTime(2023, 01, 01)), isTrue);
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
            startDate: DateTime(2023, 01, 01),
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2023, 01, 01)), isTrue);
        });

        test('is true on the pattern', () {
          final schedule = Daily(
            startDate: DateTime(2023, 01, 01),
            frequency: 3,
          );

          expect(schedule.occursOn(DateTime(2023, 01, 04)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 01, 07)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 01, 10)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 02, 03)), isTrue);
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
            startDate: DateTime(2023, 01, 01),
            frequency: 1,
            weekdays: [DateTime.monday],
          );

          expect(schedule.occursOn(DateTime(2023, 01, 02)), isTrue);
        });

        test('is true on the correct weekdays', () {
          final schedule = Weekly(
            startDate: DateTime(2023, 01, 01),
            frequency: 3,
            weekdays: [DateTime.monday, DateTime.friday],
          );

          expect(schedule.occursOn(DateTime(2023, 01, 06)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 01, 23)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 01, 27)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 02, 13)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 06, 19)), isTrue);
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
            startDate: DateTime(2023, 01, 02),
            days: [2],
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2023, 01, 02)), isTrue);
        });

        test('is true on a correct date', () {
          final schedule = Monthly(
            startDate: DateTime(2023, 01, 01),
            days: [1, 15],
            frequency: 2,
          );

          expect(schedule.occursOn(DateTime(2023, 01, 15)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 03, 01)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 03, 15)), isTrue);
          expect(schedule.occursOn(DateTime(2024, 03, 15)), isTrue);
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
            startDate: DateTime(2023, 01, 01),
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2023, 01, 01)), isTrue);
        });

        test('is true on a correct date', () {
          final schedule = Yearly(
            startDate: DateTime(2023, 01, 01),
            frequency: 2,
          );

          expect(schedule.occursOn(DateTime(2025, 01, 01)), isTrue);
          expect(schedule.occursOn(DateTime(2027, 01, 01)), isTrue);
          expect(schedule.occursOn(DateTime(2029, 01, 01)), isTrue);
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
}
