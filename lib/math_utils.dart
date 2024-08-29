import 'dart:math';

/// Utility class for generating math questions of various types.
class MathUtils {
  static final Random _random = Random();

  /// Generates a simple equation with an integer or fractional solution.
  static Map<String, dynamic> generateSimpleEquation({bool allowNegative = false, bool allowFractions = false}) {
    final int a = _random.nextInt(9) + 1;
    final int b = _random.nextInt(20) - 10;
    final int c = _random.nextInt(20) - 10;
    final int x = _random.nextInt(10) - (allowNegative ? 5 : 0);

    if (allowFractions && _random.nextBool()) {
      // Generate a fractional answer
      final int numerator = c - b;
      final int denominator = a;  // Avoid division by zero
      return {
        'question': '$a x + $b = $c',
        'answer': '$numerator/$denominator',
      };
    } else {
      // Generate an integer answer
      final int correctAnswer = a * x + b;
      return {
        'question': '$a x + $b = $correctAnswer',
        'answer': x.toString(),
      };
    }
  }
}
