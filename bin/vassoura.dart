import 'dart:io';

import 'package:vassoura/vassoura.dart';

void main(List<String> arguments) async {
  final files = filesToDelete(Directory.current);
  await for (final file in files) {
    print(file);
  }
}
