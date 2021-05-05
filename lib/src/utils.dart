bool programHasMain(String program) {
  final regex = RegExp(r'(void)? main\s*\(');
  return regex.hasMatch(program);
}

bool isAnAbsoluteImport(String importPath) {
  return importPath.startsWith('package:');
}
