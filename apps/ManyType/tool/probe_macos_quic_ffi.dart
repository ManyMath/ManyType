import 'dart:io';

import 'package:manytype_cli/src/ffi/native_bridge.dart';

const expectedAbiVersion = 2;

void main(List<String> arguments) {
  if (arguments.length != 1) {
    stderr.writeln(
      'usage: dart run tool/probe_macos_quic_ffi.dart '
      '<ManyType.app/Contents/MacOS/manytype>',
    );
    exitCode = 64;
    return;
  }

  final executable = File(arguments.single).absolute;
  if (!executable.existsSync()) {
    stderr.writeln('app executable not found: ${executable.path}');
    exitCode = 66;
    return;
  }

  final bridge = NativeBridge.forExecutablePath(executable.path);
  final actualAbiVersion = bridge.abiVersion;
  if (actualAbiVersion != expectedAbiVersion) {
    stderr.writeln(
      'unexpected ManyType QUIC FFI ABI: '
      '$actualAbiVersion (expected $expectedAbiVersion)',
    );
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'ManyType QUIC FFI ABI $actualAbiVersion loaded from the app bundle',
  );
}
