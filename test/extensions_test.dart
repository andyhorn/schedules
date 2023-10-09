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

    group('#getMonthsApartFrom', () {
      test('is 0 for the same date', () {
        expect(
          DateTime(2023, 01, 01).getMonthsApartFrom(DateTime(2023, 01, 01)),
          equals(0),
        );
      });

      test('is 1 for one month apart', () {
        expect(
          DateTime(2023, 01, 01).getMonthsApartFrom(DateTime(2023, 02, 01)),
          equals(1),
        );
      });

      test(
          'is correct count for months in different years, but less than 1 year apart',
          () {
        expect(
          DateTime(2023, 11, 01).getMonthsApartFrom(DateTime(2024, 02, 01)),
          equals(3),
        );
      });

      test('is correct count for months in the same year', () {
        expect(
          DateTime(2023, 11, 01).getMonthsApartFrom(DateTime(2023, 02, 01)),
          equals(9),
        );
      });

      test('is correct count for multiple years apart', () {
        expect(
          DateTime(2023, 11, 01).getMonthsApartFrom(DateTime(2025, 02, 01)),
          equals(15),
        );
      });
    });
  });
}
