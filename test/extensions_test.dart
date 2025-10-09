import 'package:schedules/src/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('DateTimeExtensions', () {
    group('#isEarlierDateThan', () {
      test('is true for earlier dates', () {
        expect(
          DateTime(2023, 01, 01).isEarlierDateThan(DateTime(2023, 01, 02)),
          isTrue,
        );
      });

      test('is false for same date', () {
        expect(
          DateTime(2023, 01, 01).isEarlierDateThan(DateTime(2023, 01, 01)),
          isFalse,
        );
      });

      test('is false for later dates', () {
        expect(
          DateTime(2023, 01, 02).isEarlierDateThan(DateTime(2023, 01, 01)),
          isFalse,
        );
      });

      test('disregards times', () {
        expect(
          DateTime(2023, 01, 01, 12, 30, 45).isEarlierDateThan(
            DateTime(2023, 01, 01, 12, 45, 00),
          ),
          isFalse,
        );
      });
    });

    group('#isLaterDateThan', () {
      test('is false for earlier date', () {
        expect(
          DateTime(2023, 01, 01).isLaterDateThan(DateTime(2023, 01, 02)),
          isFalse,
        );
      });

      test('is false for same date', () {
        expect(
          DateTime(2023, 01, 01).isLaterDateThan(DateTime(2023, 01, 01)),
          isFalse,
        );
      });

      test('is true for later date', () {
        expect(
          DateTime(2023, 01, 02).isLaterDateThan(DateTime(2023, 01, 01)),
          isTrue,
        );
      });

      test('disregards times', () {
        expect(
          DateTime(2023, 01, 01, 12, 30, 45).isLaterDateThan(
            DateTime(2023, 01, 01, 12, 15, 00),
          ),
          isFalse,
        );
      });
    });

    group('#isSameDateAs', () {
      test('is false for earlier date', () {
        expect(
          DateTime(2023, 01, 01).isSameDateAs(DateTime(2023, 01, 02)),
          isFalse,
        );
      });

      test('is true for same date', () {
        expect(
          DateTime(2023, 01, 01).isSameDateAs(DateTime(2023, 01, 01)),
          isTrue,
        );
      });

      test('is false for later date', () {
        expect(
          DateTime(2023, 01, 02).isSameDateAs(DateTime(2023, 01, 01)),
          isFalse,
        );
      });

      test('is true for same date even if times are different', () {
        expect(
          DateTime(2023, 01, 01, 12, 00, 00).isSameDateAs(
            DateTime(2023, 01, 01, 13, 00, 00),
          ),
          isTrue,
        );
      });
    });

    group('#daysApartFrom', () {
      test('is 0 for the same date', () {
        expect(
          DateTime(2023, 01, 01).daysApartFrom(DateTime(2023, 01, 01)),
          equals(0),
        );
      });

      test('is -1 for one day before', () {
        expect(
          DateTime(2023, 01, 01).daysApartFrom(DateTime(2023, 01, 02)),
          equals(-1),
        );
      });

      test('is 1 for one day after', () {
        expect(
          DateTime(2023, 01, 02).daysApartFrom(DateTime(2023, 01, 01)),
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
          DateTime(2023, 01, 01).daysApartFrom(DateTime(2022, 01, 01)),
          equals(365),
        );
      });

      test('is -365 for exactly one year behind', () {
        expect(
          DateTime(2022, 01, 01).daysApartFrom(DateTime(2023, 01, 01)),
          equals(-365),
        );
      });

      test('disregards times', () {
        expect(
          DateTime(2023, 01, 01, 12, 30, 45).daysApartFrom(
            DateTime(2023, 01, 02, 12, 15, 00),
          ),
          equals(-1),
        );
      });
    });

    group('#getMonthsApartFrom', () {
      test('is 0 for the same date', () {
        expect(
          DateTime(2023, 01, 01).monthsApartFrom(DateTime(2023, 01, 01)),
          equals(0),
        );
      });

      test('is -1 for one month before', () {
        expect(
          DateTime(2023, 01, 01).monthsApartFrom(DateTime(2023, 02, 01)),
          equals(-1),
        );
      });

      test('is 1 for one month after', () {
        expect(
          DateTime(2023, 02, 01).monthsApartFrom(DateTime(2023, 01, 01)),
          equals(1),
        );
      });

      test('is 10 for 10 months ahead in a different year', () {
        expect(
          DateTime(2023, 07, 01).monthsApartFrom(DateTime(2022, 09, 01)),
          equals(10),
        );
      });

      test('is -10 for 10 months behind in a different year', () {
        expect(
          DateTime(2022, 09, 01).monthsApartFrom(DateTime(2023, 07, 01)),
          equals(-10),
        );
      });

      test('is 12 for exactly one year ahead', () {
        expect(
          DateTime(2023, 01, 01).monthsApartFrom(DateTime(2022, 01, 01)),
          equals(12),
        );
      });

      test('is -12 for exactly one year behind', () {
        expect(
          DateTime(2022, 01, 01).monthsApartFrom(DateTime(2023, 01, 01)),
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
        // Dart's DateTime will roll over to March 3rd (since Feb 31 doesn't exist)
        expect(result.year, equals(2023));
        expect(result.month, equals(3));
        expect(result.day, equals(3));
      });

      test(
          'handles end-of-month with overflow=false (adjusts to last day of month)',
          () {
        final date = DateTime(2023, 1, 31);
        final result = date.addMonths(1, false);
        // Should be Feb 28 (2023 is not a leap year)
        expect(result.year, equals(2023));
        expect(result.month, equals(2));
        expect(result.day, equals(28));
      });

      test('handles end-of-month with overflow=false in leap year', () {
        final date = DateTime(2024, 1, 31);
        final result = date.addMonths(1, false);
        // Should be Feb 29 (2024 is a leap year)
        expect(result.year, equals(2024));
        expect(result.month, equals(2));
        expect(result.day, equals(29));
      });

      test('handles negative months with overflow=false', () {
        final date = DateTime(2023, 3, 31);
        final result = date.addMonths(-1, false);
        // Should be Feb 28 (2023 is not a leap year)
        expect(result.year, equals(2023));
        expect(result.month, equals(2));
        expect(result.day, equals(28));
      });

      test('handles negative months with overflow=false in leap year', () {
        final date = DateTime(2024, 3, 31);
        final result = date.addMonths(-1, false);
        // Should be Feb 29 (2024 is a leap year)
        expect(result.year, equals(2024));
        expect(result.month, equals(2));
        expect(result.day, equals(29));
      });

      test('handles adding 12 months (one year) with overflow=false', () {
        final date = DateTime(2023, 2, 28);
        final result = date.addMonths(12, false);
        expect(result.year, equals(2024));
        expect(result.month, equals(2));
        expect(result.day, equals(28));
      });

      test(
          'handles adding months resulting in a month with fewer days (overflow=false)',
          () {
        final date = DateTime(2023, 5, 31);
        final result = date.addMonths(1, false);
        // June has 30 days
        expect(result.year, equals(2023));
        expect(result.month, equals(6));
        expect(result.day, equals(30));
      });

      test(
          'handles adding months resulting in a month with more days (overflow=false)',
          () {
        final date = DateTime(2023, 4, 30);
        final result = date.addMonths(1, false);
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
        final result = date.addMonths(0, false);
        expect(result, equals(date));
      });
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
      final result = date.addYears(1, false);
      // 2021 is not a leap year, so should be Feb 28
      expect(result.year, equals(2021));
      expect(result.month, equals(2));
      expect(result.day, equals(28));
    });

    test('handles leap year overflow=false (Feb 29 to Feb 29)', () {
      final date = DateTime(2020, 2, 29);
      final result = date.addYears(4, false);
      // 2024 is a leap year, so should be Feb 29
      expect(result.year, equals(2024));
      expect(result.month, equals(2));
      expect(result.day, equals(29));
    });

    test('handles overflow=true for leap year (Feb 29 to Mar 1)', () {
      final date = DateTime(2020, 2, 29);
      final result = date.addYears(1, true);
      // 2021 is not a leap year, so should be Mar 1
      expect(result.year, equals(2021));
      expect(result.month, equals(3));
      expect(result.day, equals(1));
    });

    test('handles negative years with overflow=false', () {
      final date = DateTime(2024, 2, 29);
      final result = date.addYears(-1, false);
      // 2023 is not a leap year, so should be Feb 28
      expect(result.year, equals(2023));
      expect(result.month, equals(2));
      expect(result.day, equals(28));
    });

    test('handles adding zero years with overflow=false', () {
      final date = DateTime(2023, 7, 31);
      final result = date.addYears(0, false);
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
      expect(() => DateTime(2023, 2).withDay(29),
          throwsArgumentError); // Feb has 28 days in 2023
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
      expect(result, equals(date.add(Duration(days: 2))));
    });

    test('returns previous weekday if weekday is before current', () {
      final date = DateTime(2023, 5, 10); // Wednesday
      final result = date.withWeekday(DateTime.monday);
      expect(result, equals(date.add(Duration(days: -2))));
    });
  });
}
