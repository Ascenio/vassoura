import 'dart:io';

import 'package:args/args.dart';
import 'package:meta/meta.dart';

import '../exceptions/project_name_not_found.dart';
import '../../vassoura.dart';

class Terminal {
  final ArgParser parser;

  Terminal({@required this.parser});

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
      final projectName = await getProjectName(Directory.current);
      print('Project: $projectName');
      final sourcesAndImports =
          await filesToDelete(Directory.current).asyncMap((file) async {
        final dependencies =
            await mapFileToItsDependencies(file, Directory.current);
        final dependenciesString =
            dependencies.map((file) => file.path).toList();
        print('File: $file');
        print('Dependencies: $dependenciesString');
        return MapEntry(file, dependencies);
      }).toList();
      final graph = buildDependecyGraph(sourcesAndImports);
      print('> $graph');
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
