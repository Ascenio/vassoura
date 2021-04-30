import 'dart:convert';
import 'dart:io';

import 'package:vassoura/src/vassoura.dart' as vassoura;
import 'package:mime/mime.dart';

void main(List<String> arguments) async {
  final files = vassoura.getDartFiles(Directory.current);
  await for (final file in files) {
    final mime = lookupMimeType(file.path);
    print('$file -> $mime');
  }
}
