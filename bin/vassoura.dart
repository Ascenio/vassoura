import 'dart:io';

import 'package:vassoura/vassoura.dart';

void main(List<String> arguments) async {
  final files = getDartFiles(Directory.current);
  await for (final file in files) {
    final hasMain = await fileHasMain(file);
    final imports = await mapFileToImports(file);
    if (hasMain) {
      print('[MAIN] $file -> $imports');
      continue;
    }
    print('$file -> ${cleanupImports(imports)}');
  }
}
