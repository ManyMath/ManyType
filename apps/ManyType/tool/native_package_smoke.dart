import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:manytype_cli/src/ffi/native_bridge.dart';

const _key = 'manytype.native-package-smoke';
const _value = 'manytype-native-package-smoke-v1';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _progress('phase=startup');

  final phase = Platform.environment['MANYTYPE_NATIVE_SMOKE_PHASE'];
  if (phase != 'write' && phase != 'read') {
    await _fail('MANYTYPE_NATIVE_SMOKE_PHASE must be write or read');
  }

  try {
    final bridge = NativeBridge();
    if (bridge.abiVersion != 1) {
      await _fail('unexpected QUIC FFI ABI ${bridge.abiVersion}');
    }
    await _progress('phase=$phase ffi_abi=1');

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

    await _progress('phase=$phase ffi_abi=1 secure_storage=ok');
    exit(0);
  } catch (error, stackTrace) {
    await _fail('$error\n$stackTrace');
  }
}

Future<void> _progress(String message) async {
  final line = 'NATIVE_PACKAGE_SMOKE $message';
  stdout.writeln(line);
  await stdout.flush();
  await _record(line);
}

Future<Never> _fail(String message) async {
  final line = 'NATIVE_PACKAGE_SMOKE failed: $message';
  stderr.writeln(line);
  await stderr.flush();
  await _record(line);
  exit(1);
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
