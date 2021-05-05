import 'dart:io';

import 'package:vassoura/src/exceptions/project_name_not_found.dart';
import 'package:vassoura/src/file_with_metadata.dart';
import 'package:vassoura/src/vassoura.dart';
import 'package:test/test.dart';
import 'package:vassoura/vassoura.dart';

void main() {
  group('lists files recursively', () {
    test('with a given directory', () async {
      final files =
          getDartFiles(Directory('test/fixtures/folder_with_recursive_files'))
              .map<String>((file) => file.path);
      expect(
        files,
        emitsInAnyOrder([
          'test/fixtures/folder_with_recursive_files/hello.dart',
          'test/fixtures/folder_with_recursive_files/some_folder/another_hello.dart',
          //emitsDone
        ]),
      );
    });
  });

  test('maps a file to its imports', () async {
    final file = File('test/fixtures/file_with_imports.dart');
    final imports = await mapFileToImports(file);
    expect(imports, {
      "import 'dart:io';",
      "import 'package:vassoura/src/vassoura.dart';",
      "import 'package:test/test.dart';",
    });
  });

  test('cleans up imports', () {
    final imports = cleanupImports([
      "import 'dart:io';",
      "import 'package:vassoura/src/vassoura.dart';",
      "import 'package:test/test.dart';",
    ]);
    expect(imports, [
      'dart:io',
      'package:vassoura/src/vassoura.dart',
      'package:test/test.dart',
    ]);
  });

  test('removes files with main method', () async {
    final files = [
      File('test/fixtures/hello.dart'),
      File('test/fixtures/some_folder/another_hello.dart'),
    ];
    final futures = files.map(fileHasMain);
    final hasMain = await Future.wait(futures);

    expect(hasMain[0], isTrue);
    expect(hasMain[1], isFalse);
  });

  group('find project name from pubspec.yaml', () {
    group('works when file is valid', () {
      const pubspecsFolder = 'test/fixtures/pubspecs';
      test('when the name have no quotes', () async {
        final directory = Directory('$pubspecsFolder/name_without_quotes');
        final projectName = await getProjectName(directory);
        expect(projectName, 'vassoura');
      });

      test('when the name have single quotes', () async {
        final directory = Directory('$pubspecsFolder/name_with_single_quotes');
        final projectName = await getProjectName(directory);
        expect(projectName, 'vassoura');
      });

      test('when the name have double quotes', () async {
        final directory = Directory('$pubspecsFolder/name_with_double_quotes');
        final projectName = await getProjectName(directory);
        expect(projectName, 'vassoura');
      });
    });

    group('throws an error', () {
      test("when there's no pubspec.yaml", () async {
        final projectName = getProjectName(Directory.current.parent);
        expect(() => projectName, throwsA(isA<ProjectNameNotFound>()));
      });

      test("when there's no name section in pubspec.yaml", () async {
        final projectName = getProjectName(Directory('test/fixtures'));
        expect(() => projectName, throwsA(isA<ProjectNameNotFound>()));
      });
    });
  });

  test('maps files to its dependencies', () async {
    final file = File('test/vassoura_test.dart');
    final fileWithMetadata = FileWithMetada(
      file: file,
      hasMainMethod: true,
      imports: [
        'dart:io',
        'package:test/test.dart',
        'package:vassoura/src/exceptions/project_name_not_found.dart',
        'package:vassoura/src/file_with_metadata.dart',
      ],
    );
    final dependencies =
        await mapFileToItsDependencies(fileWithMetadata, Directory.current);
    expect(
      dependencies.map(fileToPath),
      [
        File('lib/src/exceptions/project_name_not_found.dart').absolute,
        File('lib/src/file_with_metadata.dart').absolute,
      ].map(fileToPath),
    );
  });

  test('builds dependency graph correctly', () {
    final fileA = FileWithMetada(
      file: File('file_a.dart'),
      hasMainMethod: false,
      imports: [],
    );
    final fileB = FileWithMetada(
      file: File('file_b.dart'),
      hasMainMethod: false,
      imports: [],
    );
    final fileC = FileWithMetada(
      file: File('file_c.dart'),
      hasMainMethod: false,
      imports: [],
    );
    final sourcesAndImports = <MapEntry<FileWithMetada, List<File>>>[
      MapEntry(fileA, [
        fileB.file,
        fileC.file,
      ]),
      MapEntry(fileB, [
        fileA.file,
        fileC.file,
      ]),
      MapEntry(fileC, [
        fileA.file,
      ]),
    ];
    final graph = buildDependecyGraph(sourcesAndImports);
    expect(graph, {
      fileA: [fileB.file, fileC.file],
      fileB: [fileA.file],
      fileC: [fileA.file, fileB.file],
    });
  });
}

String fileToPath(File file) {
  return file.path;
}
