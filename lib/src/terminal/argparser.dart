import 'package:args/args.dart';

const listOption = 'list';

/// Sets up available commands and arguments to the terminal
ArgParser makeArgParser() {
  return ArgParser()
    ..addFlag(
      listOption,
      abbr: 'l',
      help: 'lists all files available to deletion',
      negatable: false,
    );
}
