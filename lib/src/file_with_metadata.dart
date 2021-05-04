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

  /// Returns every import, except the ones starting with `dart:foo`, e.g.: `dart:io`
  List<String> get nonDartImports =>
      imports.whereNot((import) => import.startsWith('dart:')).toList();

  /// Returns only imports of the current project, which can be either
  /// relative or absolute
  List<String> projectImports(String projectName) {
    return nonDartImports.where((import) {
      if (import.startsWith('package:')) {
        return import.startsWith('package:$projectName');
      }
      return true;
    }).toList();
  }

  @override
  String toString() {
    return file.path;
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
