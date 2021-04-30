import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';

Stream<File> getDartFiles(Directory directory) {
  return directory
      .list(recursive: true)
      .where((file) => file is File)
      .where((file) => lookupMimeType(file.path) == 'text/x-dart')
      .cast<File>();
}

Future<List<String>> mapFileToImports(File file) async {
  return file
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .where((line) => line.startsWith(RegExp(r"\s*import '.*';")))
      .fold<List<String>>([], (lines, currentLine) => [...lines, currentLine]);
}
