class Color {
  final String code;

  const Color._(this.code);

  @override
  String toString() => code;
}

abstract class Colors {
  static const blue = Color._('\u001b[34m');
  static const reset = Color._('\u001b[0m');
}
