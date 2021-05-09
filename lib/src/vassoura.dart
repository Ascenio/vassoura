import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path/path.dart';

import 'exceptions/project_name_not_found.dart';
import 'file_with_metadata.dart';
import 'transformers/file_with_metadata_stream_transformer.dart';
import 'utils.dart';

/// Scans the project tree from its root searching for `.dart` files
Stream<File> getDartFiles(Directory directory) {
  return directory
      .list(recursive: true)
      .where((file) => file is File)
      .where((file) => lookupMimeType(file.path) == 'text/x-dart')
      .cast<File>();
}

/// Reads a dart file and returns its imports
Future<List<String>> mapFileToImports(File file) async {
  return file
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .where((line) => line.startsWith(RegExp(r"\s*import '.*';")))
      .fold<List<String>>([], (lines, currentLine) => [...lines, currentLine]);
}

/// Removes leading and trailing unnecessary data
///
/// So this
/// ```dart
/// import 'foo.dart';
/// ```
/// Becomes `foo.dart`
List<String> cleanupImports(List<String> imports) {
  return imports.map((import) {
    final regex = RegExp(r"\s*import '(.*)';");
    final matches = regex.allMatches(import);
    return matches.first.group(1)!;
  }).toList();
}

/// Scans a file looking for a `main` method
Future<bool> fileHasMain(File file) async {
  final program = await file.readAsString();
  final hasMain = programHasMain(program);
  return hasMain;
}

/// Scans for files which you *should* delete
Stream<FileWithMetada> filesToDelete(Directory directory) {
  return getDartFiles(directory)
      .transform(FileWithMetadataStreamTransformer())
      .where((file) => !file.hasMainMethod);
}

/// Gets the current project name from `pubspec.yaml`
Future<String> getProjectName(Directory directory) async {
  final file = await directory
      .list()
      .where((file) => file is File)
      .where((file) => basename(file.path) == 'pubspec.yaml')
      .cast<File?>()
      .firstWhere((file) => file != null, orElse: () => null);
  if (file == null) {
    throw ProjectNameNotFound("File pubspec.yaml doesn't exist");
  }
  final projectName = await file
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .where((line) => line.startsWith('name:'))
      .map((line) {
    final simpleNameRegex = RegExp(r'name:\s*(\w+)');
    if (simpleNameRegex.hasMatch(line)) {
      return simpleNameRegex.firstMatch(line)!.group(1);
    }
    final nameWithSingleQuotesRegex = RegExp(r"name:\s*'(\w+)'");
    if (nameWithSingleQuotesRegex.hasMatch(line)) {
      return nameWithSingleQuotesRegex.firstMatch(line)!.group(1);
    }
    final nameWithDoubleQuotesRegex = RegExp(r'name:\s*"(\w+)"');
    return nameWithDoubleQuotesRegex.firstMatch(line)!.group(1);
  }).firstWhere((name) => name != null, orElse: () => null);
  if (projectName == null) {
    throw ProjectNameNotFound(
        "pubspec.yaml file doesn't have a name attribute");
  }
  return projectName;
}

/// Gets references to all files imported by [file].
Future<List<File>> mapFileToItsDependencies(
  FileWithMetada file,
  Directory rootDirectory,
) async {
  final projectName = await getProjectName(rootDirectory);
  final imports = file.projectImports(projectName);
  return imports.map((import) {
    if (isAnAbsoluteImport(import)) {
      final absolutePath =
          '${rootDirectory.path}/${import.replaceFirst('package:$projectName/', 'lib/')}';
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

/// Receives a list of files along with its dependencies
/// and returns a [Map] from a [File] to its dependents
///
/// So if the input is something as `A -> B`, meaning A **imports** B,
/// then the output would be `B -> A`, meaning B is **imported by** A
Map<FileWithMetada, List<File>> buildDependecyGraph(
  List<MapEntry<FileWithMetada, List<File>>> sourcesAndImports,
) {
  // because Dart doesn't support File equality by path
  final pathToFileWithMetadataMap = sourcesAndImports
      .fold<Map<String, FileWithMetada>>({}, (cache, sourceAndImport) {
    final file = sourceAndImport.key;
    final path = file.file.path;
    cache[path] = file;
    return cache;
  });

  final graphOfFilesWithDependents = sourcesAndImports
      .fold<Map<FileWithMetada, List<File>>>({}, (graph, sourcesAndImports) {
    final file = sourcesAndImports.key;
    final dependencies = sourcesAndImports.value;
    for (final dependency in dependencies) {
      final path = dependency.path;
      final fileWithMetadata = pathToFileWithMetadataMap[path];
      if (fileWithMetadata != null) {
        graph.putIfAbsent(fileWithMetadata, () => []);
        graph[fileWithMetadata]!.add(file.file);
      }
    }
    return graph;
  });
  final filesWithoutDependents = sourcesAndImports.where((sourceAndImport) =>
      !graphOfFilesWithDependents.containsKey(sourceAndImport.key));
  final graph = {...graphOfFilesWithDependents}
    ..addEntries(filesWithoutDependents);
  return graph;
}

/// Returns only files which aren't imported anywhere
List<FileWithMetada> onlyFilesWithoutDependents(
  Map<FileWithMetada, List<File>> graph,
) {
  return graph.entries
      .where((sourceAndDependents) => sourceAndDependents.value.isEmpty)
      .map((sourceAndDependents) => sourceAndDependents.key)
      .toList();
}
