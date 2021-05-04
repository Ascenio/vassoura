import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path/path.dart';

import '../vassoura.dart';
import 'exceptions/project_name_not_found.dart';
import 'file_with_metadata.dart';
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

Future<String> getProjectName(Directory directory) async {
  final file = await directory
      .list()
      .where((file) => file is File)
      .where((file) => basename(file.path) == 'pubspec.yaml')
      .cast<File>()
      .firstWhere((name) => name != null, orElse: () => null);
  if (file == null) {
    throw ProjectNameNotFound("File pubspec.yaml doesn't exist");
  }
  final projectName = file
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .where((line) => line.startsWith('name:'))
      .map((line) {
    final simpleNameRegex = RegExp(r'name:\s*(\w+)');
    if (simpleNameRegex.hasMatch(line)) {
      return simpleNameRegex.firstMatch(line).group(1);
    }
    final nameWithSingleQuotesRegex = RegExp(r"name:\s*'(\w+)'");
    if (nameWithSingleQuotesRegex.hasMatch(line)) {
      return nameWithSingleQuotesRegex.firstMatch(line).group(1);
    }
    final nameWithDoubleQuotesRegex = RegExp(r'name:\s*"(\w+)"');
    return nameWithDoubleQuotesRegex.firstMatch(line).group(1);
  }).firstWhere((name) => name != null, orElse: () => null);
  if (projectName == null) {
    throw ProjectNameNotFound(
        "pubspec.yaml file doesn't have a name attribute");
  }
  return projectName;
}

Future<List<File>> mapFileToItsDependencies(
  FileWithMetada file,
  Directory rootDirectory,
) async {
  final projectName = await getProjectName(rootDirectory);
  final imports = file.projectImports(projectName);
  return imports.map((import) {
    if (isAnAbsoluteImport(import)) {
      final absolutePath =
          '${rootDirectory.path}/${import.replaceFirst('package:$projectName/', '')}';
      final importFile = File(absolutePath);
      return importFile;
    }
    var relativePath = import;
    var directory = file.file.parent;
    while (relativePath.startsWith('../')) {
      relativePath = relativePath.replaceFirst('../', '');
      directory = directory.parent;
    }
    final importFile = File('${directory.path}/$relativePath');
    return importFile;
  }).toList();
}
