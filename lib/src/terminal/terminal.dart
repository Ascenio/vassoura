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
        final project = await getProjectName(Directory.current);
        print('Scanning $project..');
      } on ProjectNameNotFound {
        print('Please run this command from your project\'s root');
        exitCode = 1;
        return;
      }
      final files = await filesToDelete(Directory.current);
      print('It seems like these files have no use: ${Colors.blue}');
      _colorful(() {
        files.forEach(print);
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
