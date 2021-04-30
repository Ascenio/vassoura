import 'dart:io';

import 'package:vassoura/src/vassoura.dart';
import 'package:test/test.dart';

void main() {
  group('lists files recursively', () {
    test('with a given directory', () async {
      final files = getDartFiles(Directory('test/fixtures'))
          .map<String>((event) => event.path);
      expect(
        files,
        emitsInAnyOrder([
          'test/fixtures/hello.dart',
          'test/fixtures/some_folder/another_hello.dart',
          emitsDone
        ]),
      );
    });
  });

  test('maps a file to its imports', () async {
    final file = File('test/vassoura_test.dart');
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
}
