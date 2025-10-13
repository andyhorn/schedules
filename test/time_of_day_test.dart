import 'package:schedules/schedules.dart';
import 'package:test/test.dart';

void main() {
  group('TimeOfDay', () {
    group('constructor', () {
      test('creates valid TimeOfDay with all parameters', () {
        final timeOfDay = TimeOfDay(
          hour: 14,
          minute: 30,
          second: 45,
          millisecond: 123,
        );

        expect(timeOfDay.hour, equals(14));
        expect(timeOfDay.minute, equals(30));
        expect(timeOfDay.second, equals(45));
        expect(timeOfDay.millisecond, equals(123));
      });

      test('creates valid TimeOfDay with default values', () {
        final timeOfDay = TimeOfDay(hour: 9, minute: 15);

        expect(timeOfDay.hour, equals(9));
        expect(timeOfDay.minute, equals(15));
        expect(timeOfDay.second, equals(0));
        expect(timeOfDay.millisecond, equals(0));
      });

      test('creates valid TimeOfDay with only hour and minute', () {
        final timeOfDay = TimeOfDay(hour: 23, minute: 59);

        expect(timeOfDay.hour, equals(23));
        expect(timeOfDay.minute, equals(59));
        expect(timeOfDay.second, equals(0));
        expect(timeOfDay.millisecond, equals(0));
      });
    });

    group('constructor validation', () {
      group('hour validation', () {
        test('throws ArgumentError for negative hour', () {
          expect(
            () => TimeOfDay(hour: -1, minute: 0),
            throwsA(isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Hour must be between 0 and 23'),
            )),
          );
        });

        test('throws ArgumentError for hour greater than 23', () {
          expect(
            () => TimeOfDay(hour: 24, minute: 0),
            throwsA(isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Hour must be between 0 and 23'),
            )),
          );
        });

        test('accepts valid hour values', () {
          for (int hour = 0; hour <= 23; hour++) {
            expect(
              () => TimeOfDay(hour: hour, minute: 0),
              returnsNormally,
              reason: 'Hour $hour should be valid',
            );
          }
        });
      });

      group('minute validation', () {
        test('throws ArgumentError for negative minute', () {
          expect(
            () => TimeOfDay(hour: 12, minute: -1),
            throwsA(isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Minute must be between 0 and 59'),
            )),
          );
        });

        test('throws ArgumentError for minute greater than 59', () {
          expect(
            () => TimeOfDay(hour: 12, minute: 60),
            throwsA(isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Minute must be between 0 and 59'),
            )),
          );
        });

        test('accepts valid minute values', () {
          for (int minute = 0; minute <= 59; minute++) {
            expect(
              () => TimeOfDay(hour: 12, minute: minute),
              returnsNormally,
              reason: 'Minute $minute should be valid',
            );
          }
        });
      });

      group('second validation', () {
        test('throws ArgumentError for negative second', () {
          expect(
            () => TimeOfDay(hour: 12, minute: 30, second: -1),
            throwsA(isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Second must be between 0 and 59'),
            )),
          );
        });

        test('throws ArgumentError for second greater than 59', () {
          expect(
            () => TimeOfDay(hour: 12, minute: 30, second: 60),
            throwsA(isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Second must be between 0 and 59'),
            )),
          );
        });

        test('accepts valid second values', () {
          for (int second = 0; second <= 59; second++) {
            expect(
              () => TimeOfDay(hour: 12, minute: 30, second: second),
              returnsNormally,
              reason: 'Second $second should be valid',
            );
          }
        });
      });

      group('millisecond validation', () {
        test('throws ArgumentError for negative millisecond', () {
          expect(
            () => TimeOfDay(hour: 12, minute: 30, second: 45, millisecond: -1),
            throwsA(isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Millisecond must be between 0 and 999'),
            )),
          );
        });

        test('throws ArgumentError for millisecond greater than 999', () {
          expect(
            () =>
                TimeOfDay(hour: 12, minute: 30, second: 45, millisecond: 1000),
            throwsA(isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('Millisecond must be between 0 and 999'),
            )),
          );
        });

        test('accepts valid millisecond values', () {
          for (int millisecond = 0; millisecond <= 999; millisecond += 100) {
            expect(
              () => TimeOfDay(
                  hour: 12, minute: 30, second: 45, millisecond: millisecond),
              returnsNormally,
              reason: 'Millisecond $millisecond should be valid',
            );
          }
        });
      });
    });

    group('fromDateTime constructor', () {
      test('creates TimeOfDay from DateTime with all components', () {
        final dateTime = DateTime(2023, 6, 15, 14, 30, 45, 123);
        final timeOfDay = TimeOfDay.fromDateTime(dateTime);

        expect(timeOfDay.hour, equals(14));
        expect(timeOfDay.minute, equals(30));
        expect(timeOfDay.second, equals(45));
        expect(timeOfDay.millisecond, equals(123));
      });

      test('creates TimeOfDay from DateTime with zero components', () {
        final dateTime = DateTime(2023, 6, 15, 0, 0, 0, 0);
        final timeOfDay = TimeOfDay.fromDateTime(dateTime);

        expect(timeOfDay.hour, equals(0));
        expect(timeOfDay.minute, equals(0));
        expect(timeOfDay.second, equals(0));
        expect(timeOfDay.millisecond, equals(0));
      });

      test('creates TimeOfDay from DateTime with maximum values', () {
        final dateTime = DateTime(2023, 6, 15, 23, 59, 59, 999);
        final timeOfDay = TimeOfDay.fromDateTime(dateTime);

        expect(timeOfDay.hour, equals(23));
        expect(timeOfDay.minute, equals(59));
        expect(timeOfDay.second, equals(59));
        expect(timeOfDay.millisecond, equals(999));
      });

      test('creates TimeOfDay from DateTime at midnight', () {
        final dateTime = DateTime(2023, 6, 15, 0, 0, 0, 0);
        final timeOfDay = TimeOfDay.fromDateTime(dateTime);

        expect(timeOfDay.hour, equals(0));
        expect(timeOfDay.minute, equals(0));
        expect(timeOfDay.second, equals(0));
        expect(timeOfDay.millisecond, equals(0));
      });

      test('creates TimeOfDay from DateTime at noon', () {
        final dateTime = DateTime(2023, 6, 15, 12, 0, 0, 0);
        final timeOfDay = TimeOfDay.fromDateTime(dateTime);

        expect(timeOfDay.hour, equals(12));
        expect(timeOfDay.minute, equals(0));
        expect(timeOfDay.second, equals(0));
        expect(timeOfDay.millisecond, equals(0));
      });
    });

    group('equality operator', () {
      test('returns true for identical TimeOfDay objects', () {
        final time1 =
            TimeOfDay(hour: 14, minute: 30, second: 45, millisecond: 123);
        final time2 =
            TimeOfDay(hour: 14, minute: 30, second: 45, millisecond: 123);

        expect(time1, equals(time2));
        expect(time1 == time2, isTrue);
      });

      test('returns false for different hour', () {
        final time1 =
            TimeOfDay(hour: 14, minute: 30, second: 45, millisecond: 123);
        final time2 =
            TimeOfDay(hour: 15, minute: 30, second: 45, millisecond: 123);

        expect(time1, isNot(equals(time2)));
        expect(time1 == time2, isFalse);
      });

      test('returns false for different minute', () {
        final time1 =
            TimeOfDay(hour: 14, minute: 30, second: 45, millisecond: 123);
        final time2 =
            TimeOfDay(hour: 14, minute: 31, second: 45, millisecond: 123);

        expect(time1, isNot(equals(time2)));
        expect(time1 == time2, isFalse);
      });

      test('returns false for different second', () {
        final time1 =
            TimeOfDay(hour: 14, minute: 30, second: 45, millisecond: 123);
        final time2 =
            TimeOfDay(hour: 14, minute: 30, second: 46, millisecond: 123);

        expect(time1, isNot(equals(time2)));
        expect(time1 == time2, isFalse);
      });

      test('returns false for different millisecond', () {
        final time1 =
            TimeOfDay(hour: 14, minute: 30, second: 45, millisecond: 123);
        final time2 =
            TimeOfDay(hour: 14, minute: 30, second: 45, millisecond: 124);

        expect(time1, isNot(equals(time2)));
        expect(time1 == time2, isFalse);
      });
    });

    group('hashCode', () {
      test('returns same hashCode for identical TimeOfDay objects', () {
        final time1 =
            TimeOfDay(hour: 14, minute: 30, second: 45, millisecond: 123);
        final time2 =
            TimeOfDay(hour: 14, minute: 30, second: 45, millisecond: 123);

        expect(time1.hashCode, equals(time2.hashCode));
      });

      test('returns different hashCode for different TimeOfDay objects', () {
        final time1 =
            TimeOfDay(hour: 14, minute: 30, second: 45, millisecond: 123);
        final time2 =
            TimeOfDay(hour: 15, minute: 30, second: 45, millisecond: 123);

        expect(time1.hashCode, isNot(equals(time2.hashCode)));
      });

      test('hashCode is consistent across multiple calls', () {
        final time =
            TimeOfDay(hour: 14, minute: 30, second: 45, millisecond: 123);
        final hashCode1 = time.hashCode;
        final hashCode2 = time.hashCode;

        expect(hashCode1, equals(hashCode2));
      });
    });

    group('edge cases', () {
      test('handles midnight correctly', () {
        final timeOfDay =
            TimeOfDay(hour: 0, minute: 0, second: 0, millisecond: 0);

        expect(timeOfDay.hour, equals(0));
        expect(timeOfDay.minute, equals(0));
        expect(timeOfDay.second, equals(0));
        expect(timeOfDay.millisecond, equals(0));
      });

      test('handles one second before midnight correctly', () {
        final timeOfDay =
            TimeOfDay(hour: 23, minute: 59, second: 59, millisecond: 999);

        expect(timeOfDay.hour, equals(23));
        expect(timeOfDay.minute, equals(59));
        expect(timeOfDay.second, equals(59));
        expect(timeOfDay.millisecond, equals(999));
      });

      test('handles noon correctly', () {
        final timeOfDay =
            TimeOfDay(hour: 12, minute: 0, second: 0, millisecond: 0);

        expect(timeOfDay.hour, equals(12));
        expect(timeOfDay.minute, equals(0));
        expect(timeOfDay.second, equals(0));
        expect(timeOfDay.millisecond, equals(0));
      });

      test('handles one minute before noon correctly', () {
        final timeOfDay =
            TimeOfDay(hour: 11, minute: 59, second: 59, millisecond: 999);

        expect(timeOfDay.hour, equals(11));
        expect(timeOfDay.minute, equals(59));
        expect(timeOfDay.second, equals(59));
        expect(timeOfDay.millisecond, equals(999));
      });
    });

    group('boundary values', () {
      test('accepts minimum valid values', () {
        final timeOfDay =
            TimeOfDay(hour: 0, minute: 0, second: 0, millisecond: 0);

        expect(timeOfDay.hour, equals(0));
        expect(timeOfDay.minute, equals(0));
        expect(timeOfDay.second, equals(0));
        expect(timeOfDay.millisecond, equals(0));
      });

      test('accepts maximum valid values', () {
        final timeOfDay =
            TimeOfDay(hour: 23, minute: 59, second: 59, millisecond: 999);

        expect(timeOfDay.hour, equals(23));
        expect(timeOfDay.minute, equals(59));
        expect(timeOfDay.second, equals(59));
        expect(timeOfDay.millisecond, equals(999));
      });

      test('rejects values just below minimum', () {
        expect(() => TimeOfDay(hour: -1, minute: 0), throwsArgumentError);
        expect(() => TimeOfDay(hour: 0, minute: -1), throwsArgumentError);
        expect(() => TimeOfDay(hour: 0, minute: 0, second: -1),
            throwsArgumentError);
        expect(() => TimeOfDay(hour: 0, minute: 0, second: 0, millisecond: -1),
            throwsArgumentError);
      });

      test('rejects values just above maximum', () {
        expect(() => TimeOfDay(hour: 24, minute: 0), throwsArgumentError);
        expect(() => TimeOfDay(hour: 0, minute: 60), throwsArgumentError);
        expect(() => TimeOfDay(hour: 0, minute: 0, second: 60),
            throwsArgumentError);
        expect(
            () => TimeOfDay(hour: 0, minute: 0, second: 0, millisecond: 1000),
            throwsArgumentError);
      });
    });
  });
}
