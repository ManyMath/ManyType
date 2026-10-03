@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/sync_service.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('manytype_store_heads_');
    AccountRegistry.testBaseDirOverride = tempDir.path;
    CliConfig.testConfigDirOverride = tempDir.path;
  });

  tearDown(() async {
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    await tempDir.delete(recursive: true);
  });

  test('reads official 8-byte and manytype_server decimal heads numerically',
      () {
    const official = 0x0006406a80fffe01;
    const local = 1760000000000001;
    final response = _field(1, [
      ..._field(2, [
        ..._field(1, utf8.encode('official')),
        ..._field(2, [
          for (var shift = 56; shift >= 0; shift -= 8)
            (official >> shift) & 0xff,
        ]),
      ]),
      ..._field(2, [
        ..._field(1, utf8.encode('local')),
        ..._field(2, utf8.encode(local.toString().padLeft(20, '0'))),
      ]),
      ..._field(2, [
        ..._field(1, utf8.encode('other')),
        ..._field(2, utf8.encode('bafyreiunknown')),
      ]),
    ]);

    final heads = decodeStoreDiffHeads(response);

    expect(heads, {'official': official, 'local': local, 'other': null});
    expect(heads['official']! < heads['local']!, isTrue);
  });
}

List<int> _field(int fieldNumber, List<int> bytes) {
  assert(bytes.length < 0x80);
  return [(fieldNumber << 3) | 2, bytes.length, ...bytes];
}
