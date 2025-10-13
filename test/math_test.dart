import 'package:schedules/src/utils/math.dart';
import 'package:test/test.dart';

void main() {
  group('PrimeFactor', () {
    test('creates instance with correct factor and exponent', () {
      const primeFactor = PrimeFactor(factor: 2, exponent: 3);
      expect(primeFactor.factor, equals(2));
      expect(primeFactor.exponent, equals(3));
    });
  });

  group('getPrimeFactors', () {
    test('returns empty list for 1', () {
      final result = getPrimeFactors(1);
      expect(result, isEmpty);
    });

    test('returns correct factors for prime numbers', () {
      final result2 = getPrimeFactors(2);
      expect(result2, hasLength(1));
      expect(result2[0].factor, equals(2));
      expect(result2[0].exponent, equals(1));

      final result3 = getPrimeFactors(3);
      expect(result3, hasLength(1));
      expect(result3[0].factor, equals(3));
      expect(result3[0].exponent, equals(1));

      final result7 = getPrimeFactors(7);
      expect(result7, hasLength(1));
      expect(result7[0].factor, equals(7));
      expect(result7[0].exponent, equals(1));
    });

    test('returns correct factors for composite numbers', () {
      final result4 = getPrimeFactors(4);
      expect(result4, hasLength(1));
      expect(result4[0].factor, equals(2));
      expect(result4[0].exponent, equals(2));

      final result6 = getPrimeFactors(6);
      expect(result6, hasLength(2));
      final factors = result6.map((f) => f.factor).toList()..sort();
      expect(factors, equals([2, 3]));
      expect(result6.every((f) => f.exponent == 1), isTrue);

      final result8 = getPrimeFactors(8);
      expect(result8, hasLength(1));
      expect(result8[0].factor, equals(2));
      expect(result8[0].exponent, equals(3));

      final result12 = getPrimeFactors(12);
      expect(result12, hasLength(2));
      final factors12 = result12.map((f) => f.factor).toList()..sort();
      expect(factors12, equals([2, 3]));
      final factor2 = result12.firstWhere((f) => f.factor == 2);
      final factor3 = result12.firstWhere((f) => f.factor == 3);
      expect(factor2.exponent, equals(2));
      expect(factor3.exponent, equals(1));
    });

    test('returns correct factors for larger numbers', () {
      final result18 = getPrimeFactors(18);
      expect(result18, hasLength(2));
      final factors18 = result18.map((f) => f.factor).toList()..sort();
      expect(factors18, equals([2, 3]));
      final factor2 = result18.firstWhere((f) => f.factor == 2);
      final factor3 = result18.firstWhere((f) => f.factor == 3);
      expect(factor2.exponent, equals(1));
      expect(factor3.exponent, equals(2));

      final result60 = getPrimeFactors(60);
      expect(result60, hasLength(3));
      final factors60 = result60.map((f) => f.factor).toList()..sort();
      expect(factors60, equals([2, 3, 5]));
      final factor2_60 = result60.firstWhere((f) => f.factor == 2);
      final factor3_60 = result60.firstWhere((f) => f.factor == 3);
      final factor5_60 = result60.firstWhere((f) => f.factor == 5);
      expect(factor2_60.exponent, equals(2));
      expect(factor3_60.exponent, equals(1));
      expect(factor5_60.exponent, equals(1));
    });

    test('handles edge cases', () {
      final result0 = getPrimeFactors(0);
      expect(result0, isEmpty);

      final resultNegative = getPrimeFactors(-12);
      expect(resultNegative, isNotEmpty);
      expect(resultNegative.length, equals(2)); // 2^2 * 3^1
    });
  });

  group('getLCM', () {
    test('returns correct LCM for two numbers', () {
      expect(getLCM([4, 6]), equals(12));
      expect(getLCM([8, 12]), equals(24));
      expect(getLCM([15, 20]), equals(60));
    });

    test('returns correct LCM for three numbers', () {
      expect(getLCM([2, 3, 4]), equals(12));
      expect(getLCM([6, 8, 12]), equals(24));
      expect(getLCM([4, 6, 8]), equals(24));
    });

    test('returns correct LCM for more numbers', () {
      expect(getLCM([2, 3, 4, 5]), equals(60));
      expect(getLCM([4, 6, 8, 12]), equals(24));
    });

    test('returns the number itself for single number', () {
      expect(getLCM([7]), equals(7));
      expect(getLCM([12]), equals(12));
      expect(getLCM([1]), equals(1));
    });

    test('returns 1 for empty list', () {
      expect(getLCM([]), equals(1));
    });

    test('handles prime numbers', () {
      expect(getLCM([2, 3, 5]), equals(30));
      expect(getLCM([7, 11]), equals(77));
    });

    test('handles powers of same number', () {
      expect(getLCM([2, 4, 8]), equals(8));
      expect(getLCM([3, 9, 27]), equals(27));
    });

    test('handles numbers with common factors', () {
      expect(getLCM([12, 18]), equals(36));
      expect(getLCM([20, 30, 40]), equals(120));
    });

    test('handles edge cases', () {
      expect(getLCM([0, 5]), equals(0)); // LCM of 0 and any number is 0
      expect(getLCM([1, 1, 1]), equals(1));
    });
  });
}
