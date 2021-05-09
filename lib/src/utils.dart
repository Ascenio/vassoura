/// Verifies if a given source code contains a `main` method
bool programHasMain(String program) {
  final regex = RegExp(r'(void\s+)?main\s*\(');
  return regex.hasMatch(program);
}

/// Verifies if a given import is of absolute type
bool isAnAbsoluteImport(String importPath) {
  return importPath.startsWith('package:');
}
