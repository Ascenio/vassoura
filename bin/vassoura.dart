import 'package:vassoura/vassoura.dart';

Future<void> main(List<String> arguments) async {
  final terminal = makeTerminal();
  await terminal(arguments);
}
