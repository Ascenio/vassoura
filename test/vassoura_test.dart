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

  group('maps a file', () {
    test('to its imports', () async {
      final file = File('test/fixtures/file_with_imports.dart');
      final imports = await mapFileToImports(file);
      expect(imports, {
        "import 'dart:io';",
        "import 'package:vassoura/src/vassoura.dart';",
        "import 'package:test/test.dart';",
      });
    });

    test('to its parts', () async {
      final file = File('test/fixtures/parts_example/printer.dart');
      final parts = await mapFileToImports(file, 'part');
      expect(parts, {
        "part 'helper_file.g.dart';",
      });
    });
  });

  group('cleans up', () {
    test('imports', () {
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

    test('parts', () {
      final imports = cleanupImports([
        "part 'counter.g.dart';",
        "part 'union.freezed.dart';",
        "part 'table.moor.dart';",
      ], 'part');
      expect(imports, [
        'counter.g.dart',
        'union.freezed.dart',
        'table.moor.dart',
      ]);
    });
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
      parts: ['some_generated_file.g.dart'],
    );
    final dependencies =
        await mapFileToItsDependencies(fileWithMetadata, Directory.current);
    expect(
      dependencies.map(fileToPath),
      [
        File('lib/src/exceptions/project_name_not_found.dart'),
        File('lib/src/file_with_metadata.dart'),
        File('test/some_generated_file.g.dart'),
      ].map(fileToPath),
    );
  });

  group('builds dependency graph', () {
    test('adds files with corresponding dependents', () {
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

    test('accounts for files without dependents', () {
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
        MapEntry(fileA, [fileB.file]),
        MapEntry(fileB, [fileA.file]),
        MapEntry(fileC, []),
      ];
      final graph = buildDependecyGraph(sourcesAndImports);
      expect(graph, {
        fileA: [fileB.file],
        fileB: [fileA.file],
        fileC: [],
      });
    });
  });

  test('filter graph by files which have dependents', () {
    final fileWithoutDependents = FileWithMetada(
        file: File('file_b.dart'), imports: [], hasMainMethod: false);
    final anotherFileWithoutDependents = FileWithMetada(
        file: File('file_d.dart'), imports: [], hasMainMethod: false);
    final graph = <FileWithMetada, List<File>>{
      FileWithMetada(
          file: File('file_a.dart'), imports: [], hasMainMethod: false): [
        File('file_b.dart'),
        File('file_c.dart'),
      ],
      fileWithoutDependents: [],
      FileWithMetada(
          file: File('file_c.dart'), imports: [], hasMainMethod: false): [
        File('file_b.dart'),
        File('file_c.dart'),
      ],
      anotherFileWithoutDependents: [],
    };
    final result = onlyFilesWithoutDependents(graph);
    expect(result, [fileWithoutDependents, anotherFileWithoutDependents]);
  });
}

String fileToPath(File file) {
  return file.absolute.path;
}
