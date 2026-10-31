import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:anytype/anytype.dart';

const _key = 'manytype.native-package-smoke';
const _value = 'manytype-native-package-smoke-v1';

// Android apps cannot set environment variables, so the phase can also come
// from --dart-define=MANYTYPE_NATIVE_SMOKE_PHASE=write|read.
const _definedPhase = String.fromEnvironment('MANYTYPE_NATIVE_SMOKE_PHASE');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _progress('phase=startup');

  final environmentPhase = Platform.environment['MANYTYPE_NATIVE_SMOKE_PHASE'];
  final phase = environmentPhase != null && environmentPhase.isNotEmpty
      ? environmentPhase
      : (_definedPhase.isEmpty ? null : _definedPhase);
  if (phase != 'write' && phase != 'read') {
    await _fail('MANYTYPE_NATIVE_SMOKE_PHASE must be write or read');
  }

  try {
    final bridge = NativeBridge();
    if (bridge.abiVersion != 2) {
      await _fail('unexpected QUIC FFI ABI ${bridge.abiVersion}');
    }
    await _progress('phase=$phase ffi_abi=2');

    // Desktop plugin registration completes as the Flutter view is attached.
    await Future<void>.delayed(const Duration(milliseconds: 500));

    const storage = FlutterSecureStorage();
    if (phase == 'write') {
      await storage.delete(key: _key).timeout(const Duration(seconds: 10));
      await storage
          .write(key: _key, value: _value)
          .timeout(const Duration(seconds: 10));
      final stored = await storage
          .read(key: _key)
          .timeout(const Duration(seconds: 10));
      if (stored != _value) {
        await _fail('secure storage did not return the value just written');
      }
    } else {
      final stored = await storage
          .read(key: _key)
          .timeout(const Duration(seconds: 10));
      if (stored != _value) {
        await _fail('secure storage did not persist across app launches');
      }
      await storage.delete(key: _key).timeout(const Duration(seconds: 10));
    }

    // Android persists secure storage asynchronously; exiting at once can lose
    // the write before the read phase launches. Wait before reporting success.
    if (Platform.isAndroid) {
      await Future<void>.delayed(const Duration(seconds: 3));
    }
    await _progress('phase=$phase ffi_abi=2 secure_storage=ok');
    exit(0);
  } catch (error, stackTrace) {
    await _fail('$error\n$stackTrace');
  }
}

Future<void> _progress(String message) async {
  final line = 'NATIVE_PACKAGE_SMOKE $message';
  await _record(line);
  await _echo(stdout, line);
  debugPrint(line);
}

Future<Never> _fail(String message) async {
  final line = 'NATIVE_PACKAGE_SMOKE failed: $message';
  await _record(line);
  await _echo(stderr, line);
  debugPrint(line);
  exit(1);
}

Future<void> _echo(IOSink sink, String line) async {
  try {
    sink.writeln(line);
    await sink.flush();
  } catch (_) {
    // GUI-subsystem Windows builds have no valid stdout/stderr handle.
  }
}

Future<void> _record(String line) async {
  final resultPath = Platform.environment['MANYTYPE_NATIVE_SMOKE_RESULT'];
  if (resultPath == null || resultPath.isEmpty) {
    return;
  }
  try {
    final result = File(resultPath);
    await result.parent.create(recursive: true);
    await result.writeAsString('$line\n', mode: FileMode.append, flush: true);
  } catch (_) {
    // Stdout/stderr still report the original failure when the marker path is
    // unavailable. The harness treats a missing marker as a failed smoke.
  }
}
