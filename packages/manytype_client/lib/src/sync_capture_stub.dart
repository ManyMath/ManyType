// MANYTYPE_SYNC_CAPTURE_PATH debug capture is an opt-in dart:io filesystem
// feature with no browser equivalent; disabled on web (see D020).
String? readSyncCapturePath() => null;

Future<void> writeSyncCaptureFile(String path, String contents) async {}
