import 'dart:io';

import 'package:mime/mime.dart';

Stream<File> getDartFiles(Directory directory) {
  return directory
      .list(recursive: true)
      .where((file) => file is File)
      .where((file) => lookupMimeType(file.path) == 'text/x-dart')
      .cast<File>();
}
