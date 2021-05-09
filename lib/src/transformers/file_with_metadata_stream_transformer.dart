import 'dart:io';

import '../file_with_metadata.dart';
import '../../vassoura.dart';
import 'async_stream_transformer.dart';

/// Reads a file, providing its metadata
class FileWithMetadataStreamTransformer
    extends AsyncStreamTransformer<File, FileWithMetada> {
  FileWithMetadataStreamTransformer() : super(_fileWithMetadataMapper);

  static Future<FileWithMetada> _fileWithMetadataMapper(File file) async {
    final futures = await Future.wait([
      fileHasMain(file),
      mapFileToImports(file).then(cleanupImports),
    ]);
    return FileWithMetada(
      file: file,
      hasMainMethod: futures[0] as bool,
      imports: futures[1] as List<String>,
    );
  }
}
