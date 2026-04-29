// Debug capture env vars are a dart:io feature with no browser equivalent;
// disabled on web (see D020, sync_capture_stub.dart).
String? readDebugCaptureEnv(String name) => null;
