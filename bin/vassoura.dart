import 'dart:io';

import 'package:vassoura/vassoura.dart';
import 'package:mime/mime.dart';

void main(List<String> arguments) async {
  final files = getDartFiles(Directory.current);
  await for (final file in files) {
    final mime = lookupMimeType(file.path);
    final imports = await mapFileToImports(file);
    print('$file -> $mime');
    print('$file -> $imports');
    print('$file -> ${cleanupImports(imports)}');
  }
}
