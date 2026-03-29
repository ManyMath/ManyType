import 'dart:io';

String? readSyncCapturePath() => Platform.environment['MANYTYPE_SYNC_CAPTURE_PATH'];

Future<void> writeSyncCaptureFile(String path, String contents) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString(contents);
}
