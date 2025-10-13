import 'dart:math' as math;

class PrimeFactor {
  final int factor;
  final int exponent;

  const PrimeFactor({
    required this.factor,
    required this.exponent,
  });
}

int getLCM(List<int> numbers) {
  if (numbers.isEmpty) return 1;
  if (numbers.length == 1) return numbers.first.abs();

  // If any number is 0, LCM is 0
  if (numbers.any((n) => n == 0)) return 0;

  // Get prime factors for all numbers
  final allPrimeFactors = numbers.map(getPrimeFactors).toList();

  // Create a map to store the maximum exponent for each prime factor
  final maxExponents = <int, int>{};

  // For each number's prime factors, update the maximum exponent
  for (final primeFactors in allPrimeFactors) {
    for (final pf in primeFactors) {
      maxExponents[pf.factor] =
          math.max(maxExponents[pf.factor] ?? 0, pf.exponent);
    }
  }

  // Calculate LCM by multiplying each prime factor raised to its max exponent
  return maxExponents.entries.fold(
      1, (result, entry) => result * math.pow(entry.key, entry.value).toInt());
}

List<PrimeFactor> getPrimeFactors(int number) {
  if (number == 0) return [];

  final factors = <int>[];
  var n = number.abs();

  while (n % 2 == 0) {
    factors.add(2);
    n ~/= 2;
  }

  var divisor = 3;
  while (divisor * divisor <= n) {
    while (n % divisor == 0) {
      factors.add(divisor);
      n ~/= divisor;
    }

    divisor += 2;
  }

  if (n > 2) {
    factors.add(n);
  }

  final factorFrequencyMap = <int, int>{};

  for (final factor in factors) {
    factorFrequencyMap[factor] = (factorFrequencyMap[factor] ?? 0) + 1;
  }

  return factorFrequencyMap.entries
      .map((entry) => PrimeFactor(factor: entry.key, exponent: entry.value))
      .toList();
}
