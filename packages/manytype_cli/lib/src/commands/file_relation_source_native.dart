import 'dart:io';
import 'dart:typed_data';

Future<Uint8List> readFileRelationSourceBytes(String path) async {
  final sourceFile = File(path);
  if (!await sourceFile.exists()) {
    throw StateError('Source file not found: $path');
  }
  return sourceFile.readAsBytes();
}
