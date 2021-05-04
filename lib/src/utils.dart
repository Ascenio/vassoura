import 'dart:io';

bool programHasMain(String program) {
  final regex = RegExp(r'(void)? main\s*\(');
  return regex.hasMatch(program);
}

bool isAnAbsoluteImport(String importPath) {
  return importPath.startsWith('package:');
}

Future<bool> filesAreEqual(File first, File second) {
  return FileSystemEntity.identical(first.path, second.path);
}
