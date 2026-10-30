// Archive gate helper: the library MANYTYPE_QUIC_FFI_PATH names must load
// through the SDK, and on Linux be the only QUIC bridge mapped into the
// process. Copied into a fresh consumer by scripts/check_sdk_archives.sh.
import 'dart:io';

import 'package:anytype/anytype.dart';

void main() {
  final expected = File(
    Platform.environment['MANYTYPE_QUIC_FFI_PATH']!,
  ).resolveSymbolicLinksSync();
  final abi = NativeBridge().abiVersion;
  if (!Platform.isLinux) {
    stdout.writeln('Loaded $expected (ABI $abi)');
    return;
  }
  final mapped = File('/proc/self/maps')
      .readAsLinesSync()
      .where((line) => line.contains('manytype_quic_ffi'))
      .map((line) => line.split(RegExp(r'\s+')).last)
      .toSet();
  if (mapped.length != 1 || mapped.single != expected) {
    throw StateError('unexpected bridge mappings: $mapped');
  }
  stdout.writeln('Loaded $expected (ABI $abi)');
}
