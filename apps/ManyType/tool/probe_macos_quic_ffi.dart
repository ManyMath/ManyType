import 'dart:io';

import 'package:anytype/anytype.dart';

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

  final configuredPath = Platform.environment['MANYTYPE_QUIC_FFI_PATH'];
  if (configuredPath != null && configuredPath.isNotEmpty) {
    stderr.writeln(
      'unset MANYTYPE_QUIC_FFI_PATH before probing the app bundle: '
      'it would load $configuredPath instead',
    );
    exitCode = 64;
    return;
  }

  // The path the SDK loader opens first: <exe dir>/../Frameworks/...
  final frameworkBinary = [
    executable.parent.parent.path,
    'Frameworks',
    'anytype_flutter.framework',
    'anytype_flutter',
  ].join(Platform.pathSeparator);
  if (!File(frameworkBinary).existsSync()) {
    stderr.writeln(
      'anytype_flutter framework binary not found: $frameworkBinary; '
      'refusing to probe a build that could load a different library',
    );
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
