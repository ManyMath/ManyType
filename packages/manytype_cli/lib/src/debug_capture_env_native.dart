import 'dart:io';

/// Reads an opt-in debug-capture env var (e.g.
/// `MANYTYPE_FILE_TRANSFER_CAPTURE_PATH`). Native/vm only: see
/// [sync_capture_native.dart]'s `readSyncCapturePath` for the sync-specific
/// precedent this generalizes (D020).
String? readDebugCaptureEnv(String name) => Platform.environment[name];
