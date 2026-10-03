@TestOn('vm')
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/commands/file_transfer.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/filesync.dart' as filesync;
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late ManytypeDatabase db;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('manytype_blob_verify_');
    AccountRegistry.testBaseDirOverride = tempDir.path;
    CliConfig.testConfigDirOverride = tempDir.path;
    db = ManytypeDatabase.forTesting(await openDatabaseForTesting());
  });

  tearDown(() async {
    await db.close();
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    await tempDir.delete(recursive: true);
  });

  Future<OpenedBlobResult> open(String cid, List<int> served) {
    return openBlobFromFileNode(
      db: db,
      fileHandleId: 1,
      invoke: (handleId, method, requestBytes) => filesync.BlockGetResponse(
        cid: cidToBytes(cid),
        data: served,
      ).writeToBuffer(),
      spaceId: 'space-a',
      fileId: 'file-1',
      cid: cid,
    );
  }

  test('rejects and does not cache BlockGet data that does not match the CID',
      () async {
    final cid = await computeCid(Uint8List.fromList('expected'.codeUnits));

    await expectLater(
      open(cid, 'tampered'.codeUnits),
      throwsA(isA<StateError>()),
    );
    expect(
      await db.getCachedBlob(spaceId: 'space-a', fileId: 'file-1', cid: cid),
      isNull,
    );
  });

  test('accepts blocks addressed with a non-dag-cbor codec', () async {
    final payload = Uint8List.fromList('raw block'.codeUnits);
    final dagCborCid = cidToBytes(await computeCid(payload));
    final rawCid = 'b${_base32Lower([0x01, 0x55, ...dagCborCid.skip(2)])}';

    final opened = await open(rawCid, payload);

    expect(opened.bytes, payload);
  });
}

String _base32Lower(List<int> bytes) {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz234567';
  final buffer = StringBuffer();
  var value = 0;
  var bits = 0;
  for (final byte in bytes) {
    value = (value << 8) | byte;
    bits += 8;
    while (bits >= 5) {
      bits -= 5;
      buffer.write(alphabet[(value >> bits) & 0x1f]);
    }
  }
  if (bits > 0) buffer.write(alphabet[(value << (5 - bits)) & 0x1f]);
  return buffer.toString();
}
