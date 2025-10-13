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

          expect(occurrences, [DateTime(2023, 01, 01)]);
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
          expect(
              schedule.occursOn(
                  DateTime(2023, 1, 1).add(const Duration(days: 1000))),
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

      group('Daily.timed', () {
        group('constructor', () {
          test('creates timed daily schedule with single time', () {
            final schedule = Daily.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 1,
              timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
            );

            expect(schedule.isTimed, isTrue);
            expect(schedule.timingMode, isA<Timed>());
            expect(schedule.occursAt(TimeOfDay(hour: 9, minute: 30)), isTrue);
            expect(schedule.occursAt(TimeOfDay(hour: 10, minute: 30)), isFalse);
          });

          test('creates timed daily schedule with multiple times', () {
            final schedule = Daily.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 1,
              timesOfDay: [
                TimeOfDay(hour: 9, minute: 30),
                TimeOfDay(hour: 14, minute: 0),
                TimeOfDay(hour: 18, minute: 45),
              ],
            );

            expect(schedule.isTimed, isTrue);
            expect(schedule.occursAt(TimeOfDay(hour: 9, minute: 30)), isTrue);
            expect(schedule.occursAt(TimeOfDay(hour: 14, minute: 0)), isTrue);
            expect(schedule.occursAt(TimeOfDay(hour: 18, minute: 45)), isTrue);
            expect(schedule.occursAt(TimeOfDay(hour: 12, minute: 0)), isFalse);
          });

          test('throws ArgumentError for empty timesOfDay', () {
            expect(
              () => Daily.timed(
                startDate: DateTime(2023, 1, 1),
                frequency: 1,
                timesOfDay: [],
              ),
              throwsA(isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('Times of day list cannot be empty'),
              )),
            );
          });

          test('throws ArgumentError for invalid frequency', () {
            expect(
              () => Daily.timed(
                startDate: DateTime(2023, 1, 1),
                frequency: 0,
                timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
              ),
              throwsA(isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('Frequency must be greater than or equal to 1'),
              )),
            );
          });
        });

        group('#occursAt', () {
          test('returns true for scheduled times', () {
            final schedule = Daily.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 1,
              timesOfDay: [
                TimeOfDay(hour: 9, minute: 30),
                TimeOfDay(hour: 14, minute: 0),
              ],
            );

            expect(schedule.occursAt(TimeOfDay(hour: 9, minute: 30)), isTrue);
            expect(schedule.occursAt(TimeOfDay(hour: 14, minute: 0)), isTrue);
          });

          test('returns false for non-scheduled times', () {
            final schedule = Daily.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 1,
              timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
            );

            expect(schedule.occursAt(TimeOfDay(hour: 10, minute: 30)), isFalse);
            expect(schedule.occursAt(TimeOfDay(hour: 9, minute: 31)), isFalse);
          });
        });

        group('#occursOn', () {
          test('returns true for dates that match the schedule pattern', () {
            final schedule = Daily.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 2,
              timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
            );

            expect(schedule.occursOn(DateTime(2023, 1, 1)), isTrue);
            expect(schedule.occursOn(DateTime(2023, 1, 3)), isTrue);
            expect(schedule.occursOn(DateTime(2023, 1, 5)), isTrue);
          });

          test('returns false for dates that do not match the schedule pattern',
              () {
            final schedule = Daily.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 2,
              timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
            );

            expect(schedule.occursOn(DateTime(2023, 1, 2)), isFalse);
            expect(schedule.occursOn(DateTime(2023, 1, 4)), isFalse);
          });
        });

        group('#getNextNOccurrences', () {
          test('returns occurrences with correct times for single time', () {
            final schedule = Daily.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 1,
              timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
            );

            final occurrences = schedule.getNextNOccurrences(3).toList();

            expect(occurrences, hasLength(3));
            expect(occurrences[0], equals(DateTime(2023, 1, 1, 9, 30)));
            expect(occurrences[1], equals(DateTime(2023, 1, 2, 9, 30)));
            expect(occurrences[2], equals(DateTime(2023, 1, 3, 9, 30)));
          });

          test('returns occurrences with correct times for multiple times', () {
            final schedule = Daily.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 1,
              timesOfDay: [
                TimeOfDay(hour: 9, minute: 30),
                TimeOfDay(hour: 14, minute: 0),
              ],
            );

            final occurrences = schedule.getNextNOccurrences(4).toList();

            expect(occurrences, hasLength(4));
            expect(occurrences[0], equals(DateTime(2023, 1, 1, 9, 30)));
            expect(occurrences[1], equals(DateTime(2023, 1, 1, 14, 0)));
            expect(occurrences[2], equals(DateTime(2023, 1, 2, 9, 30)));
            expect(occurrences[3], equals(DateTime(2023, 1, 2, 14, 0)));
          });

          test('respects frequency parameter', () {
            final schedule = Daily.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 2,
              timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
            );

            final occurrences = schedule.getNextNOccurrences(3).toList();

            expect(occurrences, hasLength(3));
            expect(occurrences[0], equals(DateTime(2023, 1, 1, 9, 30)));
            expect(occurrences[1], equals(DateTime(2023, 1, 3, 9, 30)));
            expect(occurrences[2], equals(DateTime(2023, 1, 5, 9, 30)));
          });

          test('respects from parameter', () {
            final schedule = Daily.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 1,
              timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
            );

            final occurrences = schedule
                .getNextNOccurrences(2, from: DateTime(2023, 1, 3))
                .toList();

            expect(occurrences, hasLength(2));
            expect(occurrences[0], equals(DateTime(2023, 1, 3, 9, 30)));
            expect(occurrences[1], equals(DateTime(2023, 1, 4, 9, 30)));
          });

          test('excludes specified dates', () {
            final schedule = Daily.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 1,
              timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
            );

            final occurrences = schedule.getNextNOccurrences(
              3,
              exclude: [DateTime(2023, 1, 2)],
            ).toList();

            expect(occurrences, hasLength(3));
            expect(occurrences[0], equals(DateTime(2023, 1, 1, 9, 30)));
            expect(occurrences[1], equals(DateTime(2023, 1, 3, 9, 30)));
            expect(occurrences[2], equals(DateTime(2023, 1, 4, 9, 30)));
          });
        });

        group('#getOccurrencesUntil', () {
          test('returns occurrences with correct times until end date', () {
            final schedule = Daily.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 1,
              timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
            );

            final occurrences =
                schedule.getOccurrencesUntil(DateTime(2023, 1, 3)).toList();

            expect(occurrences, hasLength(3));
            expect(occurrences[0], equals(DateTime(2023, 1, 1, 9, 30)));
            expect(occurrences[1], equals(DateTime(2023, 1, 2, 9, 30)));
            expect(occurrences[2], equals(DateTime(2023, 1, 3, 9, 30)));
          });

          test('returns occurrences with multiple times until end date', () {
            final schedule = Daily.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 1,
              timesOfDay: [
                TimeOfDay(hour: 9, minute: 30),
                TimeOfDay(hour: 14, minute: 0),
              ],
            );

            final occurrences =
                schedule.getOccurrencesUntil(DateTime(2023, 1, 2)).toList();

            expect(occurrences, hasLength(4));
            expect(occurrences[0], equals(DateTime(2023, 1, 1, 9, 30)));
            expect(occurrences[1], equals(DateTime(2023, 1, 1, 14, 0)));
            expect(occurrences[2], equals(DateTime(2023, 1, 2, 9, 30)));
            expect(occurrences[3], equals(DateTime(2023, 1, 2, 14, 0)));
          });
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

      group('Weekly.timed', () {
        group('constructor', () {
          test('creates timed weekly schedule', () {
            final schedule = Weekly.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 1,
              weekdays: [DateTime.monday, DateTime.wednesday],
              timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
            );

            expect(schedule.isTimed, isTrue);
            expect(schedule.timingMode, isA<Timed>());
            expect(schedule.occursAt(TimeOfDay(hour: 9, minute: 30)), isTrue);
          });

          test('throws ArgumentError for empty timesOfDay', () {
            expect(
              () => Weekly.timed(
                startDate: DateTime(2023, 1, 1),
                frequency: 1,
                weekdays: [DateTime.monday],
                timesOfDay: [],
              ),
              throwsA(isA<ArgumentError>().having(
                (e) => e.message,
                'message',
                contains('Times of day list cannot be empty'),
              )),
            );
          });
        });

        group('#occursOn', () {
          test('returns true for correct weekdays', () {
            final schedule = Weekly.timed(
              startDate: DateTime(2023, 1, 1), // Sunday
              frequency: 1,
              weekdays: [DateTime.monday, DateTime.wednesday],
              timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
            );

            expect(schedule.occursOn(DateTime(2023, 1, 2)), isTrue); // Monday
            expect(
                schedule.occursOn(DateTime(2023, 1, 4)), isTrue); // Wednesday
            expect(schedule.occursOn(DateTime(2023, 1, 3)), isFalse); // Tuesday
          });
        });

        group('#getNextNOccurrences', () {
          test('returns occurrences with correct times for weekly schedule',
              () {
            final schedule = Weekly.timed(
              startDate: DateTime(2023, 1, 1), // Sunday
              frequency: 1,
              weekdays: [DateTime.monday, DateTime.wednesday],
              timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
            );

            final occurrences = schedule.getNextNOccurrences(4).toList();

            expect(occurrences, hasLength(4));
            expect(
                occurrences[0], equals(DateTime(2023, 1, 2, 9, 30))); // Monday
            expect(occurrences[1],
                equals(DateTime(2023, 1, 4, 9, 30))); // Wednesday
            expect(occurrences[2],
                equals(DateTime(2023, 1, 9, 9, 30))); // Next Monday
            expect(occurrences[3],
                equals(DateTime(2023, 1, 11, 9, 30))); // Next Wednesday
          });
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

      group('Monthly.timed', () {
        group('constructor', () {
          test('creates timed monthly schedule', () {
            final schedule = Monthly.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 1,
              days: [1, 15],
              timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
            );

            expect(schedule.isTimed, isTrue);
            expect(schedule.timingMode, isA<Timed>());
            expect(schedule.occursAt(TimeOfDay(hour: 9, minute: 30)), isTrue);
          });
        });

        group('#occursOn', () {
          test('returns true for correct days of month', () {
            final schedule = Monthly.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 1,
              days: [1, 15],
              timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
            );

            expect(schedule.occursOn(DateTime(2023, 1, 1)), isTrue);
            expect(schedule.occursOn(DateTime(2023, 1, 15)), isTrue);
            expect(schedule.occursOn(DateTime(2023, 2, 1)), isTrue);
            expect(schedule.occursOn(DateTime(2023, 2, 15)), isTrue);
            expect(schedule.occursOn(DateTime(2023, 1, 10)), isFalse);
          });
        });

        group('#getNextNOccurrences', () {
          test('returns occurrences with correct times for monthly schedule',
              () {
            final schedule = Monthly.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 1,
              days: [1, 15],
              timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
            );

            final occurrences = schedule.getNextNOccurrences(4).toList();

            expect(occurrences, hasLength(4));
            expect(occurrences[0], equals(DateTime(2023, 1, 1, 9, 30)));
            expect(occurrences[1], equals(DateTime(2023, 1, 15, 9, 30)));
            expect(occurrences[2], equals(DateTime(2023, 2, 1, 9, 30)));
            expect(occurrences[3], equals(DateTime(2023, 2, 15, 9, 30)));
          });
        });
      });
    });

    group(MonthlyWeekday, () {
      test('throws an error if frequency is less than 1', () {
        expect(
            () => MonthlyWeekday(
                  startDate: DateTime(2023, 01, 01),
                  weekday: DateTime.monday,
                  weekOfMonth: 1,
                  frequency: 0,
                ),
            throwsA(isA<ArgumentError>()));
      });

      test('throws error for invalid weekday values', () {
        expect(
            () => MonthlyWeekday(
                  startDate: DateTime(2023, 1, 1),
                  weekday: 0, // Invalid weekday
                  weekOfMonth: 1,
                  frequency: 1,
                ),
            throwsA(isA<ArgumentError>()));

        expect(
            () => MonthlyWeekday(
                  startDate: DateTime(2023, 1, 1),
                  weekday: 8, // Invalid weekday
                  weekOfMonth: 1,
                  frequency: 1,
                ),
            throwsA(isA<ArgumentError>()));
      });

      test('throws error for invalid weekOfMonth values', () {
        expect(
            () => MonthlyWeekday(
                  startDate: DateTime(2023, 1, 1),
                  weekday: DateTime.monday,
                  weekOfMonth: 0, // Invalid weekOfMonth
                  frequency: 1,
                ),
            throwsA(isA<ArgumentError>()));

        expect(
            () => MonthlyWeekday(
                  startDate: DateTime(2023, 1, 1),
                  weekday: DateTime.monday,
                  weekOfMonth: 6, // Invalid weekOfMonth
                  frequency: 1,
                ),
            throwsA(isA<ArgumentError>()));
      });

      test('accepts valid values including -1 for last occurrence', () {
        expect(
            () => MonthlyWeekday(
                  startDate: DateTime(2023, 1, 1),
                  weekday: DateTime.monday,
                  weekOfMonth: -1, // Last occurrence
                  frequency: 1,
                ),
            returnsNormally);

        expect(
            () => MonthlyWeekday(
                  startDate: DateTime(2023, 1, 1),
                  weekday: DateTime.friday,
                  weekOfMonth: 5, // Fifth occurrence
                  frequency: 2,
                ),
            returnsNormally);
      });

      group('#occursOn', () {
        test('is false on the start date if it is not the correct weekday', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01), // Sunday
            weekday: DateTime.monday,
            weekOfMonth: 1,
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2023, 01, 01)), isFalse);
        });

        test('is true on the start date if it matches the pattern', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 02), // Monday
            weekday: DateTime.monday,
            weekOfMonth: 1,
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2023, 01, 02)), isTrue);
        });

        test('correctly identifies first Monday of each month', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01),
            weekday: DateTime.monday,
            weekOfMonth: 1,
            frequency: 1,
          );

          // January 2023: First Monday is Jan 2
          expect(schedule.occursOn(DateTime(2023, 01, 02)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 01, 09)),
              isFalse); // Second Monday
          expect(schedule.occursOn(DateTime(2023, 01, 16)),
              isFalse); // Third Monday

          // February 2023: First Monday is Feb 6
          expect(schedule.occursOn(DateTime(2023, 02, 06)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 02, 13)),
              isFalse); // Second Monday
        });

        test('correctly identifies second Friday of each month', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01),
            weekday: DateTime.friday,
            weekOfMonth: 2,
            frequency: 1,
          );

          // January 2023: First Friday is Jan 6, second is Jan 13
          expect(schedule.occursOn(DateTime(2023, 01, 06)),
              isFalse); // First Friday
          expect(schedule.occursOn(DateTime(2023, 01, 13)),
              isTrue); // Second Friday
          expect(schedule.occursOn(DateTime(2023, 01, 20)),
              isFalse); // Third Friday

          // February 2023: First Friday is Feb 3, second is Feb 10
          expect(schedule.occursOn(DateTime(2023, 02, 03)),
              isFalse); // First Friday
          expect(schedule.occursOn(DateTime(2023, 02, 10)),
              isTrue); // Second Friday
        });

        test('correctly identifies last Friday of each month', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01),
            weekday: DateTime.friday,
            weekOfMonth: -1, // Last occurrence
            frequency: 1,
          );

          // January 2023: Last Friday is Jan 27
          expect(schedule.occursOn(DateTime(2023, 01, 27)), isTrue);
          expect(
              schedule.occursOn(DateTime(2023, 01, 20)), isFalse); // Not last
          expect(
              schedule.occursOn(DateTime(2023, 01, 13)), isFalse); // Not last

          // February 2023: Last Friday is Feb 24
          expect(schedule.occursOn(DateTime(2023, 02, 24)), isTrue);
          expect(
              schedule.occursOn(DateTime(2023, 02, 17)), isFalse); // Not last
        });

        test('correctly identifies fifth Friday when it exists', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01),
            weekday: DateTime.friday,
            weekOfMonth: 5,
            frequency: 1,
          );

          // March 2023: Has 5 Fridays (3, 10, 17, 24, 31)
          expect(schedule.occursOn(DateTime(2023, 03, 31)),
              isTrue); // Fifth Friday
          expect(schedule.occursOn(DateTime(2023, 03, 24)),
              isFalse); // Fourth Friday

          // April 2023: Only has 4 Fridays, so no fifth Friday
          expect(schedule.occursOn(DateTime(2023, 04, 28)),
              isFalse); // Last Friday in April
        });

        test('respects frequency parameter', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01),
            weekday: DateTime.monday,
            weekOfMonth: 1,
            frequency: 2, // Every 2 months
          );

          // January 2023: Should occur (month 0)
          expect(schedule.occursOn(DateTime(2023, 01, 02)), isTrue);

          // February 2023: Should not occur (month 1)
          expect(schedule.occursOn(DateTime(2023, 02, 06)), isFalse);

          // March 2023: Should occur (month 2)
          expect(schedule.occursOn(DateTime(2023, 03, 06)), isTrue);

          // April 2023: Should not occur (month 3)
          expect(schedule.occursOn(DateTime(2023, 04, 03)), isFalse);
        });

        test('is false before the start date', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01),
            weekday: DateTime.monday,
            weekOfMonth: 1,
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2022, 12, 05)), isFalse);
          expect(schedule.occursOn(DateTime(2022, 12, 31)), isFalse);
        });

        test('is false after the end date', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01),
            endDate: DateTime(2023, 03, 31),
            weekday: DateTime.monday,
            weekOfMonth: 1,
            frequency: 1,
          );

          expect(schedule.occursOn(DateTime(2023, 04, 03)), isFalse);
          expect(schedule.occursOn(DateTime(2023, 12, 04)), isFalse);
        });

        test('is false on wrong weekday', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01),
            weekday: DateTime.monday,
            weekOfMonth: 1,
            frequency: 1,
          );

          // First Tuesday of January 2023
          expect(schedule.occursOn(DateTime(2023, 01, 03)), isFalse);
          // First Wednesday of January 2023
          expect(schedule.occursOn(DateTime(2023, 01, 04)), isFalse);
        });
      });

      group('#getNextNOccurrences', () {
        test('returns correct first Monday occurrences', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01),
            weekday: DateTime.monday,
            weekOfMonth: 1,
            frequency: 1,
          );

          final occurrences = schedule.getNextNOccurrences(3).toList();

          expect(occurrences.length, equals(3));
          expect(occurrences[0],
              equals(DateTime(2023, 01, 02))); // First Monday of Jan
          expect(occurrences[1],
              equals(DateTime(2023, 02, 06))); // First Monday of Feb
          expect(occurrences[2],
              equals(DateTime(2023, 03, 06))); // First Monday of Mar
        });

        test('returns correct last Friday occurrences', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01),
            weekday: DateTime.friday,
            weekOfMonth: -1, // Last occurrence
            frequency: 1,
          );

          final occurrences = schedule.getNextNOccurrences(3).toList();

          expect(occurrences.length, equals(3));
          expect(occurrences[0],
              equals(DateTime(2023, 01, 27))); // Last Friday of Jan
          expect(occurrences[1],
              equals(DateTime(2023, 02, 24))); // Last Friday of Feb
          expect(occurrences[2],
              equals(DateTime(2023, 03, 31))); // Last Friday of Mar
        });

        test('respects frequency parameter', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01),
            weekday: DateTime.monday,
            weekOfMonth: 1,
            frequency: 2, // Every 2 months
          );

          final occurrences = schedule.getNextNOccurrences(3).toList();

          expect(occurrences.length, equals(3));
          expect(occurrences[0], equals(DateTime(2023, 01, 02))); // January
          expect(occurrences[1],
              equals(DateTime(2023, 03, 06))); // March (skipped Feb)
          expect(occurrences[2],
              equals(DateTime(2023, 05, 01))); // May (skipped Apr)
        });

        test('handles from parameter correctly', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01),
            weekday: DateTime.monday,
            weekOfMonth: 1,
            frequency: 1,
          );

          final occurrences = schedule
              .getNextNOccurrences(2, from: DateTime(2023, 03, 01))
              .toList();

          expect(occurrences.length, equals(2));
          expect(occurrences[0],
              equals(DateTime(2023, 03, 06))); // First Monday of Mar
          expect(occurrences[1],
              equals(DateTime(2023, 04, 03))); // First Monday of Apr
        });

        test('excludes specified dates', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01),
            weekday: DateTime.monday,
            weekOfMonth: 1,
            frequency: 1,
          );

          final exclude = [DateTime(2023, 02, 06)]; // First Monday of February
          final occurrences =
              schedule.getNextNOccurrences(3, exclude: exclude).toList();

          expect(occurrences.length, equals(3));
          expect(occurrences[0],
              equals(DateTime(2023, 01, 02))); // First Monday of Jan
          expect(
              occurrences[1],
              equals(DateTime(
                  2023, 03, 06))); // First Monday of Mar (Feb excluded)
          expect(occurrences[2],
              equals(DateTime(2023, 04, 03))); // First Monday of Apr
        });

        test('handles start date that is not the first day of month', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 15), // Start mid-month
            weekday: DateTime.monday,
            weekOfMonth: 1,
            frequency: 1,
          );

          final occurrences = schedule.getNextNOccurrences(2).toList();
          expect(occurrences.length, equals(2));
          expect(occurrences[0],
              equals(DateTime(2023, 02, 06))); // First Monday of Feb
          expect(occurrences[1],
              equals(DateTime(2023, 03, 06))); // First Monday of Mar
        });
      });

      group('#getOccurrencesUntil', () {
        test('returns all occurrences within date range', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01),
            weekday: DateTime.monday,
            weekOfMonth: 1,
            frequency: 1,
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2023, 04, 01)).toList();

          expect(occurrences.length, equals(3));
          expect(occurrences[0],
              equals(DateTime(2023, 01, 02))); // First Monday of Jan
          expect(occurrences[1],
              equals(DateTime(2023, 02, 06))); // First Monday of Feb
          expect(occurrences[2],
              equals(DateTime(2023, 03, 06))); // First Monday of Mar
        });

        test('returns empty list when end date is before start date', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01),
            weekday: DateTime.monday,
            weekOfMonth: 1,
            frequency: 1,
          );

          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2022, 12, 31)).toList();
          expect(occurrences, isEmpty);
        });

        test('respects from parameter', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01),
            weekday: DateTime.monday,
            weekOfMonth: 1,
            frequency: 1,
          );

          final occurrences = schedule
              .getOccurrencesUntil(
                DateTime(2023, 04, 01),
                from: DateTime(2023, 02, 01),
              )
              .toList();

          expect(occurrences.length, equals(2));
          expect(occurrences[0],
              equals(DateTime(2023, 02, 06))); // First Monday of Feb
          expect(occurrences[1],
              equals(DateTime(2023, 03, 06))); // First Monday of Mar
        });

        test('excludes specified dates', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01),
            weekday: DateTime.monday,
            weekOfMonth: 1,
            frequency: 1,
          );

          final exclude = [DateTime(2023, 02, 06)]; // First Monday of February
          final occurrences = schedule
              .getOccurrencesUntil(
                DateTime(2023, 04, 01),
                exclude: exclude,
              )
              .toList();

          expect(occurrences.length, equals(2));
          expect(occurrences[0],
              equals(DateTime(2023, 01, 02))); // First Monday of Jan
          expect(
              occurrences[1],
              equals(DateTime(
                  2023, 03, 06))); // First Monday of Mar (Feb excluded)
        });

        test('handles months with different numbers of weekdays', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2023, 01, 01),
            weekday: DateTime.friday,
            weekOfMonth: 5, // Fifth Friday
            frequency: 1,
          );

          // March 2023 has 5 Fridays, April 2023 has 4 Fridays
          final marchOccurrences =
              schedule.getOccurrencesUntil(DateTime(2023, 04, 01)).toList();
          expect(marchOccurrences.length, equals(1));
          expect(marchOccurrences[0],
              equals(DateTime(2023, 03, 31))); // Fifth Friday of March

          final aprilOccurrences =
              schedule.getOccurrencesUntil(DateTime(2023, 05, 01)).toList();
          expect(aprilOccurrences.length,
              equals(1)); // Still only March occurrence
        });

        test('handles leap year February correctly', () {
          final schedule = MonthlyWeekday(
            startDate: DateTime(2024, 01, 01), // 2024 is a leap year
            weekday: DateTime.thursday,
            weekOfMonth: 5, // Fifth Thursday
            frequency: 1,
          );

          // February 2024 has 5 Thursdays due to leap year
          final occurrences =
              schedule.getOccurrencesUntil(DateTime(2024, 03, 01)).toList();
          expect(occurrences.length, equals(1));
          expect(
              occurrences[0],
              equals(
                  DateTime(2024, 02, 29))); // Fifth Thursday of February 2024
        });
      });

      group('MonthlyWeekday.timed', () {
        group('constructor', () {
          test('creates timed monthly weekday schedule', () {
            final schedule = MonthlyWeekday.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 1,
              weekday: DateTime.monday,
              weekOfMonth: 1,
              timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
            );

            expect(schedule.isTimed, isTrue);
            expect(schedule.timingMode, isA<Timed>());
            expect(schedule.occursAt(TimeOfDay(hour: 9, minute: 30)), isTrue);
          });
        });

        group('#occursOn', () {
          test('returns true for correct weekday of month', () {
            final schedule = MonthlyWeekday.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 1,
              weekday: DateTime.monday,
              weekOfMonth: 1,
              timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
            );

            // First Monday of January 2023 is January 2
            expect(schedule.occursOn(DateTime(2023, 1, 2)), isTrue);
            expect(schedule.occursOn(DateTime(2023, 2, 6)),
                isTrue); // First Monday of February
            expect(schedule.occursOn(DateTime(2023, 1, 9)),
                isFalse); // Second Monday
          });
        });

        group('#getNextNOccurrences', () {
          test(
              'returns occurrences with correct times for monthly weekday schedule',
              () {
            final schedule = MonthlyWeekday.timed(
              startDate: DateTime(2023, 1, 1),
              frequency: 1,
              weekday: DateTime.monday,
              weekOfMonth: 1,
              timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
            );

            final occurrences = schedule.getNextNOccurrences(3).toList();

            expect(occurrences, hasLength(3));
            expect(occurrences[0],
                equals(DateTime(2023, 1, 2, 9, 30))); // First Monday of January
            expect(
                occurrences[1],
                equals(
                    DateTime(2023, 2, 6, 9, 30))); // First Monday of February
            expect(occurrences[2],
                equals(DateTime(2023, 3, 6, 9, 30))); // First Monday of March
          });
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

    group('Yearly.timed', () {
      group('constructor', () {
        test('creates timed yearly schedule', () {
          final schedule = Yearly.timed(
            startDate: DateTime(2023, 1, 1),
            frequency: 1,
            timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
          );

          expect(schedule.isTimed, isTrue);
          expect(schedule.timingMode, isA<Timed>());
          expect(schedule.occursAt(TimeOfDay(hour: 9, minute: 30)), isTrue);
        });
      });

      group('#occursOn', () {
        test('returns true for same day and month', () {
          final schedule = Yearly.timed(
            startDate: DateTime(2023, 1, 1),
            frequency: 1,
            timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
          );

          expect(schedule.occursOn(DateTime(2023, 1, 1)), isTrue);
          expect(schedule.occursOn(DateTime(2024, 1, 1)), isTrue);
          expect(schedule.occursOn(DateTime(2023, 1, 2)), isFalse);
          expect(schedule.occursOn(DateTime(2023, 2, 1)), isFalse);
        });
      });

      group('#getNextNOccurrences', () {
        test('returns occurrences with correct times for yearly schedule', () {
          final schedule = Yearly.timed(
            startDate: DateTime(2023, 1, 1),
            frequency: 1,
            timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
          );

          final occurrences = schedule.getNextNOccurrences(3).toList();

          expect(occurrences, hasLength(3));
          expect(occurrences[0], equals(DateTime(2023, 1, 1, 9, 30)));
          expect(occurrences[1], equals(DateTime(2024, 1, 1, 9, 30)));
          expect(occurrences[2], equals(DateTime(2025, 1, 1, 9, 30)));
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
      expect(
          payments.length,
          equals(
              13)); // 12 months + 1 (end date is included because it matches the schedule pattern)
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
      expect(
          occurrences.length,
          equals(
              10)); // Jan, Mar, May, Jul: each has 1st and 15th, Jan/Mar/May have 31st, Jul only 1st (end date). So: Jan(3), Mar(3), May(3), Jul(1) = 10.
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
      expect(
          occurrences.length,
          equals(
              9)); // There are 9 Tuesdays/Fridays between 2023-01-15 and 2023-02-15 inclusive
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

  group('Timed Schedules', () {
    group('Timed Schedule Edge Cases', () {
      test('handles multiple times per day correctly', () {
        final schedule = Daily.timed(
          startDate: DateTime(2023, 1, 1),
          frequency: 1,
          timesOfDay: [
            TimeOfDay(hour: 8, minute: 0),
            TimeOfDay(hour: 12, minute: 0),
            TimeOfDay(hour: 18, minute: 0),
          ],
        );

        final occurrences = schedule.getNextNOccurrences(6).toList();

        expect(occurrences, hasLength(6));
        expect(occurrences[0], equals(DateTime(2023, 1, 1, 8, 0)));
        expect(occurrences[1], equals(DateTime(2023, 1, 1, 12, 0)));
        expect(occurrences[2], equals(DateTime(2023, 1, 1, 18, 0)));
        expect(occurrences[3], equals(DateTime(2023, 1, 2, 8, 0)));
        expect(occurrences[4], equals(DateTime(2023, 1, 2, 12, 0)));
        expect(occurrences[5], equals(DateTime(2023, 1, 2, 18, 0)));
      });

      test('handles times with seconds and milliseconds', () {
        final schedule = Daily.timed(
          startDate: DateTime(2023, 1, 1),
          frequency: 1,
          timesOfDay: [
            TimeOfDay(hour: 9, minute: 30, second: 45, millisecond: 123),
          ],
        );

        final occurrences = schedule.getNextNOccurrences(2).toList();

        expect(occurrences, hasLength(2));
        expect(occurrences[0], equals(DateTime(2023, 1, 1, 9, 30, 45, 123)));
        expect(occurrences[1], equals(DateTime(2023, 1, 2, 9, 30, 45, 123)));
      });

      test('handles end date constraint for timed schedules', () {
        final schedule = Daily.timed(
          startDate: DateTime(2023, 1, 1),
          frequency: 1,
          timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
          endDate: DateTime(2023, 1, 2),
        );

        final occurrences =
            schedule.getOccurrencesUntil(DateTime(2023, 1, 5)).toList();

        expect(occurrences, hasLength(2));
        expect(occurrences[0], equals(DateTime(2023, 1, 1, 9, 30)));
        expect(occurrences[1], equals(DateTime(2023, 1, 2, 9, 30)));
      });

      test('handles exclusion of specific times', () {
        final schedule = Daily.timed(
          startDate: DateTime(2023, 1, 1),
          frequency: 1,
          timesOfDay: [TimeOfDay(hour: 9, minute: 30)],
        );

        final occurrences = schedule.getNextNOccurrences(
          3,
          exclude: [DateTime(2023, 1, 2, 9, 30)],
        ).toList();

        expect(occurrences, hasLength(3));
        expect(occurrences[0], equals(DateTime(2023, 1, 1, 9, 30)));
        expect(occurrences[1], equals(DateTime(2023, 1, 3, 9, 30)));
        expect(occurrences[2], equals(DateTime(2023, 1, 4, 9, 30)));
      });
    });
  });
}
