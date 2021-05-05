import 'package:args/args.dart';

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
