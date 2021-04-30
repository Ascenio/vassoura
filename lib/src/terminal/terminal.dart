import 'dart:io';

import 'package:args/args.dart';
import 'package:meta/meta.dart';

import '../../vassoura.dart';

class Terminal {
  final ArgParser parser;

  Terminal({@required this.parser});

  Future<void> call(List<String> arguments) async {
    if (arguments.isEmpty) {
      print(
        'Vassoura: removes files not referenced in the project\n'
        'Usage: vas <command>\n\n'
        'Available commands:\n'
        '${parser.usage}',
      );
    } else {
      final result = parser.parse(arguments);
      if (result.options.contains(listOption)) {
        final files = filesToDelete(Directory.current);
        await for (final file in files) {
          print(file);
        }
      }
    }
  }
}

const listOption = 'list';

ArgParser makeArgParser() {
  return ArgParser()
    ..addFlag(
      listOption,
      abbr: 'l',
      help: 'lists all files available to deletion',
      negatable: false,
    );
}

Terminal makeTerminal() {
  final parser = makeArgParser();
  return Terminal(parser: parser);
}
