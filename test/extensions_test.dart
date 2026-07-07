import 'package:schedules/schedules.dart';
import 'package:schedules/src/utils/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('DateTimeExtensions', () {
    group('#isEarlierDateThan', () {
      test('is true for earlier dates', () {
        expect(
          DateTime(2023).isEarlierDateThan(DateTime(2023, 01, 02)),
          isTrue,
        );
      });

      test('is false for same date', () {
        expect(
          DateTime(2023).isEarlierDateThan(DateTime(2023)),
          isFalse,
        );
      });

      test('is false for later dates', () {
        expect(
          DateTime(2023, 01, 02).isEarlierDateThan(DateTime(2023)),
          isFalse,
        );
      });

      test('disregards times', () {
        expect(
          DateTime(2023, 01, 01, 12, 30, 45).isEarlierDateThan(
            DateTime(2023, 01, 01, 12, 45),
          ),
          isFalse,
        );
      });
    });

    group('#isLaterDateThan', () {
      test('is false for earlier date', () {
        expect(
          DateTime(2023).isLaterDateThan(DateTime(2023, 01, 02)),
          isFalse,
        );
      });

      test('is false for same date', () {
        expect(
          DateTime(2023).isLaterDateThan(DateTime(2023)),
          isFalse,
        );
      });

      test('is true for later date', () {
        expect(
          DateTime(2023, 01, 02).isLaterDateThan(DateTime(2023)),
          isTrue,
        );
      });

      test('disregards times', () {
        expect(
          DateTime(2023, 01, 01, 12, 30, 45).isLaterDateThan(
            DateTime(2023, 01, 01, 12, 15),
          ),
          isFalse,
        );
      });
    });

    group('#isSameDateAs', () {
      test('is false for earlier date', () {
        expect(
          DateTime(2023).isSameDateAs(DateTime(2023, 01, 02)),
          isFalse,
        );
      });

      test('is true for same date', () {
        expect(
          DateTime(2023).isSameDateAs(DateTime(2023)),
          isTrue,
        );
      });

      test('is false for later date', () {
        expect(
          DateTime(2023, 01, 02).isSameDateAs(DateTime(2023)),
          isFalse,
        );
      });

      test('is true for same date even if times are different', () {
        expect(
          DateTime(2023, 01, 01, 12).isSameDateAs(
            DateTime(2023, 01, 01, 13),
          ),
          isTrue,
        );
      });
    });

    group('#daysApartFrom', () {
      test('is 0 for the same date', () {
        expect(
          DateTime(2023).daysApartFrom(DateTime(2023)),
          equals(0),
        );
      });

      test('is -1 for one day before', () {
        expect(
          DateTime(2023).daysApartFrom(DateTime(2023, 01, 02)),
          equals(-1),
        );
      });

      test('is 1 for one day after', () {
        expect(
          DateTime(2023, 01, 02).daysApartFrom(DateTime(2023)),
          equals(1),
        );
      });

      test('is -10 for 10 days behind in a different month', () {
        expect(
          DateTime(2023, 11, 24).daysApartFrom(DateTime(2023, 12, 04)),
          equals(-10),
        );
      });

      test('is 10 for 10 days ahead in a different month', () {
        expect(
          DateTime(2023, 12, 04).daysApartFrom(DateTime(2023, 11, 24)),
          equals(10),
        );
      });

      test('is 365 for exactly one year ahead', () {
        expect(
          DateTime(2023).daysApartFrom(DateTime(2022)),
          equals(365),
        );
      });

      test('is -365 for exactly one year behind', () {
        expect(
          DateTime(2022).daysApartFrom(DateTime(2023)),
          equals(-365),
        );
      });

      test('disregards times', () {
        expect(
          DateTime(2023, 01, 01, 12, 30, 45).daysApartFrom(
            DateTime(2023, 01, 02, 12, 15),
          ),
          equals(-1),
        );
      });
    });

    group('#getMonthsApartFrom', () {
      test('is 0 for the same date', () {
        expect(
          DateTime(2023).monthsApartFrom(DateTime(2023)),
          equals(0),
        );
      });

      test('is -1 for one month before', () {
        expect(
          DateTime(2023).monthsApartFrom(DateTime(2023, 02)),
          equals(-1),
        );
      });

      test('is 1 for one month after', () {
        expect(
          DateTime(2023, 02).monthsApartFrom(DateTime(2023)),
          equals(1),
        );
      });

      test('is 10 for 10 months ahead in a different year', () {
        expect(
          DateTime(2023, 07).monthsApartFrom(DateTime(2022, 09)),
          equals(10),
        );
      });

      test('is -10 for 10 months behind in a different year', () {
        expect(
          DateTime(2022, 09).monthsApartFrom(DateTime(2023, 07)),
          equals(-10),
        );
      });

      test('is 12 for exactly one year ahead', () {
        expect(
          DateTime(2023).monthsApartFrom(DateTime(2022)),
          equals(12),
        );
      });

      test('is -12 for exactly one year behind', () {
        expect(
          DateTime(2022).monthsApartFrom(DateTime(2023)),
          equals(-12),
        );
      });

      test('is 1 for two months ahead, but earlier day', () {
        expect(
          DateTime(2023, 03, 10).monthsApartFrom(DateTime(2023, 01, 15)),
          equals(1),
        );
      });

      test('is -1 for two months behind, but later day', () {
        expect(
          DateTime(2023, 01, 15).monthsApartFrom(DateTime(2023, 03, 10)),
          equals(-1),
        );
      });

      test('is 1 for two months ahead, but earlier day in different year', () {
        expect(
          DateTime(2024, 02, 10).monthsApartFrom(DateTime(2023, 12, 15)),
          equals(1),
        );
      });

      test('is -1 for two months behind, but later day in different year', () {
        expect(
          DateTime(2023, 12, 15).monthsApartFrom(DateTime(2024, 02, 10)),
          equals(-1),
        );
      });

      test('is 0 for same month, but later day', () {
        expect(
          DateTime(2023, 03, 10).monthsApartFrom(DateTime(2023, 03, 15)),
          equals(0),
        );
      });

      test('is 0 for same month, but earlier day', () {
        expect(
          DateTime(2023, 03, 15).monthsApartFrom(DateTime(2023, 03, 10)),
          equals(0),
        );
      });

      test('is 1 for end of month to end of next month', () {
        expect(
          DateTime(2023, 03, 31).monthsApartFrom(DateTime(2023, 02, 28)),
          equals(1),
        );
      });

      test('is -1 for end of month to end of previous month', () {
        expect(
          DateTime(2023, 02, 28).monthsApartFrom(DateTime(2023, 03, 31)),
          equals(-1),
        );
      });
    });

    group('#startOfDay', () {
      test('returns midnight for a date with time', () {
        final date = DateTime(2023, 5, 10, 15, 30, 45, 123, 456);
        final start = date.startOfDay();
        expect(start.year, equals(2023));
        expect(start.month, equals(5));
        expect(start.day, equals(10));
        expect(start.hour, equals(0));
        expect(start.minute, equals(0));
        expect(start.second, equals(0));
        expect(start.millisecond, equals(0));
        expect(start.microsecond, equals(0));
      });

      test('returns same date if already at midnight', () {
        final date = DateTime(2023, 5, 10);
        final start = date.startOfDay();
        expect(start, equals(date));
      });
    });

    group('#startOfMonth', () {
      test('returns the first day of the month', () {
        final date = DateTime(2023, 7, 10);
        final start = date.startOfMonth();
        expect(start.year, equals(2023));
        expect(start.month, equals(7));
        expect(start.day, equals(1));
      });
    });

    group('#endOfMonth', () {
      test('returns last day of a 31-day month', () {
        final date = DateTime(2023, 7, 10);
        final end = date.endOfMonth();
        expect(end.year, equals(2023));
        expect(end.month, equals(7));
        expect(end.day, equals(31));
      });

      test('returns last day of a 30-day month', () {
        final date = DateTime(2023, 6, 15);
        final end = date.endOfMonth();
        expect(end.year, equals(2023));
        expect(end.month, equals(6));
        expect(end.day, equals(30));
      });

      test('returns last day of February in a non-leap year', () {
        final date = DateTime(2023, 2, 10);
        final end = date.endOfMonth();
        expect(end.year, equals(2023));
        expect(end.month, equals(2));
        expect(end.day, equals(28));
      });

      test('returns last day of February in a leap year', () {
        final date = DateTime(2024, 2, 10);
        final end = date.endOfMonth();
        expect(end.year, equals(2024));
        expect(end.month, equals(2));
        expect(end.day, equals(29));
      });
    });

    group('#addMonths', () {
      test('adds months within the same year', () {
        final date = DateTime(2023, 1, 15);
        final result = date.addMonths(2);
        expect(result.year, equals(2023));
        expect(result.month, equals(3));
        expect(result.day, equals(15));
      });

      test('adds months across years', () {
        final date = DateTime(2023, 11, 10);
        final result = date.addMonths(3);
        expect(result.year, equals(2024));
        expect(result.month, equals(2));
        expect(result.day, equals(10));
      });

      test('subtracts months', () {
        final date = DateTime(2023, 3, 10);
        final result = date.addMonths(-2);
        expect(result.year, equals(2023));
        expect(result.month, equals(1));
        expect(result.day, equals(10));
      });

      test('handles end-of-month overflow (default: overflow=true)', () {
        final date = DateTime(2023, 1, 31);
        final result = date.addMonths(1);
        // Dart's DateTime will roll over to March 3rd (since Feb 31
        // does not exist)
        expect(result.year, equals(2023));
        expect(result.month, equals(3));
        expect(result.day, equals(3));
      });

      test(
          'handles end-of-month with overflow=false '
          '(adjusts to last day of month)', () {
        final date = DateTime(2023, 1, 31);
        final result = date.addMonths(1, overflow: false);
        // Should be Feb 28 (2023 is not a leap year)
        expect(result.year, equals(2023));
        expect(result.month, equals(2));
        expect(result.day, equals(28));
      });

      test('handles end-of-month with overflow=false in leap year', () {
        final date = DateTime(2024, 1, 31);
        final result = date.addMonths(1, overflow: false);
        // Should be Feb 29 (2024 is a leap year)
        expect(result.year, equals(2024));
        expect(result.month, equals(2));
        expect(result.day, equals(29));
      });

      test('handles negative months with overflow=false', () {
        final date = DateTime(2023, 3, 31);
        final result = date.addMonths(-1, overflow: false);
        // Should be Feb 28 (2023 is not a leap year)
        expect(result.year, equals(2023));
        expect(result.month, equals(2));
        expect(result.day, equals(28));
      });

      test('handles negative months with overflow=false in leap year', () {
        final date = DateTime(2024, 3, 31);
        final result = date.addMonths(-1, overflow: false);
        // Should be Feb 29 (2024 is a leap year)
        expect(result.year, equals(2024));
        expect(result.month, equals(2));
        expect(result.day, equals(29));
      });

      test('handles adding 12 months (one year) with overflow=false', () {
        final date = DateTime(2023, 2, 28);
        final result = date.addMonths(12, overflow: false);
        expect(result.year, equals(2024));
        expect(result.month, equals(2));
        expect(result.day, equals(28));
      });

      test(
          'handles adding months resulting in a month with fewer days '
          '(overflow=false)', () {
        final date = DateTime(2023, 5, 31);
        final result = date.addMonths(1, overflow: false);
        // June has 30 days
        expect(result.year, equals(2023));
        expect(result.month, equals(6));
        expect(result.day, equals(30));
      });

      test(
          'handles adding months resulting in a month with more days '
          '(overflow=false)', () {
        final date = DateTime(2023, 4, 30);
        final result = date.addMonths(1, overflow: false);
        // May has 31 days, should be May 30
        expect(result.year, equals(2023));
        expect(result.month, equals(5));
        expect(result.day, equals(30));
      });

      test('handles adding zero months', () {
        final date = DateTime(2023, 7, 15);
        final result = date.addMonths(0);
        expect(result, equals(date));
      });

      test('handles adding zero months with overflow=false', () {
        final date = DateTime(2023, 7, 31);
        final result = date.addMonths(0, overflow: false);
        expect(result, equals(date));
      });
    });

    group('#addYears', () {
      test('adds years', () {
        final date = DateTime(2020, 2, 29);
        final result = date.addYears(1);
        // 2021 is not a leap year, so Feb 29 becomes Mar 1
        expect(result.year, equals(2021));
        expect(result.month, equals(3));
        expect(result.day, equals(1));
      });

      test('subtracts years', () {
        final date = DateTime(2023, 5, 10);
        final result = date.addYears(-2);
        expect(result.year, equals(2021));
        expect(result.month, equals(5));
        expect(result.day, equals(10));
      });

      test('handles leap year overflow=false (Feb 29 to Feb 28)', () {
        final date = DateTime(2020, 2, 29);
        final result = date.addYears(1, overflow: false);
        // 2021 is not a leap year, so should be Feb 28
        expect(result.year, equals(2021));
        expect(result.month, equals(2));
        expect(result.day, equals(28));
      });

      test('handles leap year overflow=false (Feb 29 to Feb 29)', () {
        final date = DateTime(2020, 2, 29);
        final result = date.addYears(4, overflow: false);
        // 2024 is a leap year, so should be Feb 29
        expect(result.year, equals(2024));
        expect(result.month, equals(2));
        expect(result.day, equals(29));
      });

      test('handles overflow=true for leap year (Feb 29 to Mar 1)', () {
        final date = DateTime(2020, 2, 29);
        final result = date.addYears(1);
        // 2021 is not a leap year, so should be Mar 1
        expect(result.year, equals(2021));
        expect(result.month, equals(3));
        expect(result.day, equals(1));
      });

      test('handles negative years with overflow=false', () {
        final date = DateTime(2024, 2, 29);
        final result = date.addYears(-1, overflow: false);
        // 2023 is not a leap year, so should be Feb 28
        expect(result.year, equals(2023));
        expect(result.month, equals(2));
        expect(result.day, equals(28));
      });

      test('handles adding zero years with overflow=false', () {
        final date = DateTime(2023, 7, 31);
        final result = date.addYears(0, overflow: false);
        expect(result, equals(date));
      });
    });

    group('#withDay', () {
      test('returns date with new day', () {
        final date = DateTime(2023, 5);
        final result = date.withDay(20);
        expect(result.year, equals(2023));
        expect(result.month, equals(5));
        expect(result.day, equals(20));
      });

      test('throws ArgumentError for invalid day', () {
        expect(() => DateTime(2023, 5).withDay(0), throwsArgumentError);
        expect(() => DateTime(2023, 5).withDay(32), throwsArgumentError);
        expect(
          () => DateTime(2023, 2).withDay(29),
          throwsArgumentError,
        ); // Feb has 28 days in 2023
      });
    });

    group('#withWeekday', () {
      test('returns same date if weekday is the same', () {
        final date = DateTime(2023, 5, 10); // Wednesday
        final result = date.withWeekday(DateTime.wednesday);
        expect(result, equals(date));
      });

      test('returns next weekday if weekday is after current', () {
        final date = DateTime(2023, 5, 10); // Wednesday
        final result = date.withWeekday(DateTime.friday);
        expect(result, equals(date.add(const Duration(days: 2))));
      });

      test('returns previous weekday if weekday is before current', () {
        final date = DateTime(2023, 5, 10); // Wednesday
        final result = date.withWeekday(DateTime.monday);
        expect(result, equals(date.add(const Duration(days: -2))));
      });
    });

    group('#toClockTime', () {
      test('converts DateTime with all time components to ClockTime', () {
        final dateTime = DateTime(2023, 6, 15, 14, 30, 45, 123);
        final clockTime = dateTime.toClockTime();

        expect(clockTime.hour, equals(14));
        expect(clockTime.minute, equals(30));
        expect(clockTime.second, equals(45));
        expect(clockTime.millisecond, equals(123));
      });

      test('converts DateTime at midnight to ClockTime', () {
        final dateTime = DateTime(2023, 6, 15);
        final clockTime = dateTime.toClockTime();

        expect(clockTime.hour, equals(0));
        expect(clockTime.minute, equals(0));
        expect(clockTime.second, equals(0));
        expect(clockTime.millisecond, equals(0));
      });

      test('converts DateTime at noon to ClockTime', () {
        final dateTime = DateTime(2023, 6, 15, 12);
        final clockTime = dateTime.toClockTime();

        expect(clockTime.hour, equals(12));
        expect(clockTime.minute, equals(0));
        expect(clockTime.second, equals(0));
        expect(clockTime.millisecond, equals(0));
      });

      test('converts DateTime at one second before midnight to ClockTime', () {
        final dateTime = DateTime(2023, 6, 15, 23, 59, 59, 999);
        final clockTime = dateTime.toClockTime();

        expect(clockTime.hour, equals(23));
        expect(clockTime.minute, equals(59));
        expect(clockTime.second, equals(59));
        expect(clockTime.millisecond, equals(999));
      });

      test('converts DateTime with only hour and minute to ClockTime', () {
        final dateTime = DateTime(2023, 6, 15, 9, 30);
        final clockTime = dateTime.toClockTime();

        expect(clockTime.hour, equals(9));
        expect(clockTime.minute, equals(30));
        expect(clockTime.second, equals(0));
        expect(clockTime.millisecond, equals(0));
      });

      test('converts DateTime with hour, minute, and second to ClockTime', () {
        final dateTime = DateTime(2023, 6, 15, 16, 45, 30);
        final clockTime = dateTime.toClockTime();

        expect(clockTime.hour, equals(16));
        expect(clockTime.minute, equals(45));
        expect(clockTime.second, equals(30));
        expect(clockTime.millisecond, equals(0));
      });

      test('handles leap year date correctly', () {
        final dateTime = DateTime(2024, 2, 29, 12, 30, 45, 123);
        final clockTime = dateTime.toClockTime();

        expect(clockTime.hour, equals(12));
        expect(clockTime.minute, equals(30));
        expect(clockTime.second, equals(45));
        expect(clockTime.millisecond, equals(123));
      });

      test('handles year boundary correctly', () {
        final dateTime = DateTime(2023, 12, 31, 23, 59, 59, 999);
        final clockTime = dateTime.toClockTime();

        expect(clockTime.hour, equals(23));
        expect(clockTime.minute, equals(59));
        expect(clockTime.second, equals(59));
        expect(clockTime.millisecond, equals(999));
      });
    });

    group('#withClockTime', () {
      test('creates DateTime with specified ClockTime', () {
        final date = DateTime(2023, 6, 15);
        final clockTime =
            ClockTime(hour: 14, minute: 30, second: 45, millisecond: 123);
        final result = date.withClockTime(clockTime);

        expect(result.year, equals(2023));
        expect(result.month, equals(6));
        expect(result.day, equals(15));
        expect(result.hour, equals(14));
        expect(result.minute, equals(30));
        expect(result.second, equals(45));
        expect(result.millisecond, equals(123));
      });

      test('creates DateTime at midnight with ClockTime', () {
        final date = DateTime(2023, 6, 15);
        final clockTime = ClockTime(hour: 0, minute: 0);
        final result = date.withClockTime(clockTime);

        expect(result.year, equals(2023));
        expect(result.month, equals(6));
        expect(result.day, equals(15));
        expect(result.hour, equals(0));
        expect(result.minute, equals(0));
        expect(result.second, equals(0));
        expect(result.millisecond, equals(0));
      });

      test('creates DateTime at noon with ClockTime', () {
        final date = DateTime(2023, 6, 15);
        final clockTime = ClockTime(hour: 12, minute: 0);
        final result = date.withClockTime(clockTime);

        expect(result.year, equals(2023));
        expect(result.month, equals(6));
        expect(result.day, equals(15));
        expect(result.hour, equals(12));
        expect(result.minute, equals(0));
        expect(result.second, equals(0));
        expect(result.millisecond, equals(0));
      });

      test('creates DateTime at one second before midnight with ClockTime', () {
        final date = DateTime(2023, 6, 15);
        final clockTime =
            ClockTime(hour: 23, minute: 59, second: 59, millisecond: 999);
        final result = date.withClockTime(clockTime);

        expect(result.year, equals(2023));
        expect(result.month, equals(6));
        expect(result.day, equals(15));
        expect(result.hour, equals(23));
        expect(result.minute, equals(59));
        expect(result.second, equals(59));
        expect(result.millisecond, equals(999));
      });

      test('overwrites existing time components', () {
        final date = DateTime(2023, 6, 15, 10, 20, 30, 400);
        final clockTime =
            ClockTime(hour: 15, minute: 45, second: 12, millisecond: 789);
        final result = date.withClockTime(clockTime);

        expect(result.year, equals(2023));
        expect(result.month, equals(6));
        expect(result.day, equals(15));
        expect(result.hour, equals(15));
        expect(result.minute, equals(45));
        expect(result.second, equals(12));
        expect(result.millisecond, equals(789));
      });

      test('preserves original DateTime when creating new one', () {
        final originalDate = DateTime(2023, 6, 15, 10, 20, 30, 400);
        final clockTime =
            ClockTime(hour: 15, minute: 45, second: 12, millisecond: 789);
        final result = originalDate.withClockTime(clockTime);

        // Original should remain unchanged
        expect(originalDate.year, equals(2023));
        expect(originalDate.month, equals(6));
        expect(originalDate.day, equals(15));
        expect(originalDate.hour, equals(10));
        expect(originalDate.minute, equals(20));
        expect(originalDate.second, equals(30));
        expect(originalDate.millisecond, equals(400));

        // Result should have new time
        expect(result.hour, equals(15));
        expect(result.minute, equals(45));
        expect(result.second, equals(12));
        expect(result.millisecond, equals(789));
      });

      test('handles leap year date correctly', () {
        final date = DateTime(2024, 2, 29);
        final clockTime =
            ClockTime(hour: 12, minute: 30, second: 45, millisecond: 123);
        final result = date.withClockTime(clockTime);

        expect(result.year, equals(2024));
        expect(result.month, equals(2));
        expect(result.day, equals(29));
        expect(result.hour, equals(12));
        expect(result.minute, equals(30));
        expect(result.second, equals(45));
        expect(result.millisecond, equals(123));
      });

      test('handles year boundary correctly', () {
        final date = DateTime(2023, 12, 31);
        final clockTime =
            ClockTime(hour: 23, minute: 59, second: 59, millisecond: 999);
        final result = date.withClockTime(clockTime);

        expect(result.year, equals(2023));
        expect(result.month, equals(12));
        expect(result.day, equals(31));
        expect(result.hour, equals(23));
        expect(result.minute, equals(59));
        expect(result.second, equals(59));
        expect(result.millisecond, equals(999));
      });

      test('handles ClockTime with default values', () {
        final date = DateTime(2023, 6, 15);
        final clockTime = ClockTime(hour: 9, minute: 15);
        final result = date.withClockTime(clockTime);

        expect(result.year, equals(2023));
        expect(result.month, equals(6));
        expect(result.day, equals(15));
        expect(result.hour, equals(9));
        expect(result.minute, equals(15));
        expect(result.second, equals(0));
        expect(result.millisecond, equals(0));
      });

      test('round-trip conversion preserves time', () {
        final originalDateTime = DateTime(2023, 6, 15, 14, 30, 45, 123);
        final clockTime = originalDateTime.toClockTime();
        final result = originalDateTime.withClockTime(clockTime);

        expect(result, equals(originalDateTime));
      });

      test('round-trip conversion with different date preserves time', () {
        final originalDateTime = DateTime(2023, 6, 15, 14, 30, 45, 123);
        final differentDate = DateTime(2024, 12, 25);
        final clockTime = originalDateTime.toClockTime();
        final result = differentDate.withClockTime(clockTime);

        expect(result.year, equals(2024));
        expect(result.month, equals(12));
        expect(result.day, equals(25));
        expect(result.hour, equals(14));
        expect(result.minute, equals(30));
        expect(result.second, equals(45));
        expect(result.millisecond, equals(123));
      });
    });
  });
}
