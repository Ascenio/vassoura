import 'dart:io';

import 'package:test/test.dart';
import 'package:vassoura/src/file_with_metadata.dart';

void main() {
  group('FileWithMetadata', () {
    test('filters imports of packages', () {
      final file = FileWithMetada(
        file: File('any_file'),
        hasMainMethod: true,
        imports: [
          'dart:io',
          'package:flutter_bloc/flutter_bloc.dart',
          'dart:html',
          'package:provider/provider.dart',
          'dart:async',
        ],
      );
      expect(file.nonDartImports, [
        'package:flutter_bloc/flutter_bloc.dart',
        'package:provider/provider.dart',
      ]);
    });

    test('filters imports of current project', () {
      final file = FileWithMetada(
        file: File('any_file'),
        hasMainMethod: true,
        imports: [
          'package:vassoura/lib/src/utils.dart',
          'package:meta/meta.dart',
          'package:vassoura/lib/src/terminal/terminal.dart',
          'dart:io',
          '../../vassoura.dart',
        ],
      );
      expect(file.projectImports('vassoura'), [
        'package:vassoura/lib/src/utils.dart',
        'package:vassoura/lib/src/terminal/terminal.dart',
        '../../vassoura.dart'
      ]);
    });
  });
}
