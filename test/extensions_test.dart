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
  });
}
