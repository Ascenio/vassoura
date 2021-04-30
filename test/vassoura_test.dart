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
}
