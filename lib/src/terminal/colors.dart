/// Represents ANSI colors or metacharacters
class Color {
  /// Actual color/metacharacter
  final String code;

  const Color._(this.code);

  /// Needed for printing
  @override
  String toString() => code;
}

/// Available colors
abstract class Colors {
  /// Blue
  static const blue = Color._('\u001b[34m');

  /// Resets the terminal to its default's color. Generally white
  static const reset = Color._('\u001b[0m');
}
