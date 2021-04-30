import 'dart:io';

import 'package:test/test.dart';
import 'package:vassoura/src/file_with_metadata.dart';
import 'package:vassoura/src/transformers/file_with_metadata_stream_transformer.dart';

void main() {
  group('FileWithMetadataStreamTransformer', () {
    test('returns metadata correctly', () {
      final expected = [
        FileWithMetada(
          file: File('test/fixtures/hello.dart'),
          hasMainMethod: true,
          imports: [],
        ),
        FileWithMetada(
          file: File('test/fixtures/some_folder/another_hello.dart'),
          hasMainMethod: false,
          imports: ['dart:math'],
        ),
      ];
      final stream = Stream.fromIterable(
              expected.map((fileWithMetada) => fileWithMetada.file))
          .transform(FileWithMetadataStreamTransformer());
      expect(stream, emitsInAnyOrder(expected));
    });
  });
}
