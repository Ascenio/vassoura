bool programHasMain(String program) {
  final regex = RegExp(r'(void)? main\s*\(');
  return regex.hasMatch(program);
}
