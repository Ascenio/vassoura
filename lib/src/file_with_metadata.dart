import 'dart:io';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

class FileWithMetada {
  final File file;
  final bool hasMainMethod;
  final List<String> imports;

  const FileWithMetada({
    @required this.file,
    @required this.hasMainMethod,
    @required this.imports,
  });

  @override
  String toString() {
    return '${file.path} -> { hasMainMethod: $hasMainMethod, imports: $imports }';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return o is FileWithMetada &&
        o.file == file &&
        o.hasMainMethod == hasMainMethod &&
        listEquals(o.imports, imports);
  }

  @override
  int get hashCode => file.hashCode ^ hasMainMethod.hashCode ^ imports.hashCode;
}
