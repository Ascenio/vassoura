import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:vassoura/src/file_with_metadata.dart';
import 'package:vassoura/vassoura.dart';

import 'transformers/file_with_metadata_stream_transformer.dart';

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

List<String> cleanupImports(List<String> imports) {
  return imports.map((import) {
    final regex = RegExp(r"\s*import '(.*)';");
    final matches = regex.allMatches(import);
    return matches.first.group(1);
  }).toList();
}

Future<bool> fileHasMain(File file) async {
  final program = await file.readAsString();
  final hasMain = programHasMain(program);
  return hasMain;
}

Stream<FileWithMetada> filesToDelete(Directory directory) {
  return getDartFiles(directory)
      .transform(FileWithMetadataStreamTransformer())
      .where((file) => !file.hasMainMethod);
}
