import 'dart:io';

import 'package:args/args.dart';

import '../../vassoura.dart';
import '../exceptions/project_name_not_found.dart';
import 'argparser.dart';
import 'colors.dart';

/// Interacts with the user and contains most CLI related logic
class Terminal {
  /// Terminal configurations
  final ArgParser parser;

  Terminal._({required this.parser});

  /// Starts the whole thing
  Future<void> call(List<String> arguments) async {
    final result = parser.parse(arguments);
    if (arguments.isEmpty) {
      print(
        'Vassoura: removes files not referenced in the project\n'
        'Usage: vas <command>\n\n'
        'Available commands:\n'
        '${parser.usage}',
      );
    } else if (result[listOption] as bool) {
      try {
        await getProjectName(Directory.current);
      } on ProjectNameNotFound {
        print('Please run this command from your project\'s root');
        exitCode = 1;
        return;
      }
      final sourcesAndImports =
          await filesToDelete(Directory.current).asyncMap((file) async {
        final dependencies =
            await mapFileToItsDependencies(file, Directory.current);
        return MapEntry(file, dependencies);
      }).toList();
      final graph = buildDependecyGraph(sourcesAndImports);
      final graphOfFilesWithoutDependents = onlyFilesWithoutDependents(graph);
      print('It seems like these files have no use: ${Colors.blue}');
      _colorful(() {
        graphOfFilesWithoutDependents.forEach(print);
      }, color: Colors.blue);
    }
  }

  /// Creates a scope for colorful printing
  void _colorful(void Function() function, {Color color = Colors.reset}) {
    _setColor(color);
    function();
    _setColor(Colors.reset);
  }

  /// Sets up color for following prints
  void _setColor(Color color) {
    stdout.write(color);
  }
}

/// Default terminal factory
Terminal makeTerminal() {
  final parser = makeArgParser();
  return Terminal._(parser: parser);
}
