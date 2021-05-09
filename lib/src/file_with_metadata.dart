import 'dart:io';

import 'package:collection/collection.dart';

/// Represents a dart file and its associated information
class FileWithMetada {
  /// The actual file
  final File file;

  /// Presence of a `main` method
  final bool hasMainMethod;

  /// Already cleaned imports of the file.
  /// e.g.: `foo.dart`
  final List<String> imports;

  /// Already cleaned parts of the file.
  /// e.g.: `foo.g.dart`
  final List<String> parts;

  const FileWithMetada({
    required this.file,
    required this.hasMainMethod,
    this.imports = const [],
    this.parts = const [],
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

  /// Needed for printing/debugging
  @override
  String toString() {
    return file.path;
  }

  /// Neeeded for equality checking
  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return o is FileWithMetada &&
        o.file == file &&
        o.hasMainMethod == hasMainMethod &&
        listEquals(o.imports, imports);
  }

  /// Neeeded for equality checking
  @override
  int get hashCode => file.hashCode ^ hasMainMethod.hashCode ^ imports.hashCode;
}
