import 'dart:typed_data';

import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:manytype_cli/src/commands/file_transfer.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/filesync.dart' as filesync;
import 'package:test/test.dart';

void main() {
  group('file transfer helpers', () {
    test(
        'upload skips BlockPush when BlocksCheck reports the blob exists in space',
        () async {
      final payload = Uint8List.fromList('hello anytype'.codeUnits);
      final cid = await computeCid(payload);
      final cidBytes = cidToBytes(cid);
      final methods = <String>[];

      final result = await uploadBlobToFileNode(
        fileHandleId: 1,
        invoke: (handleId, method, requestBytes) {
          methods.add(method);
          expect(handleId, 1);
          if (method == '/filesync.File/BlocksCheck') {
            return filesync.BlocksCheckResponse(
              blocksAvailability: [
                filesync.BlockAvailability(
                  cid: cidBytes,
                  status: filesync.AvailabilityStatus.ExistsInSpace,
                ),
              ],
            ).writeToBuffer();
          }
          fail('unexpected RPC: $method');
        },
        spaceId: 'space-a',
        fileId: 'file-1',
        bytes: payload,
      );

      expect(result.cid, cid);
      expect(result.uploaded, isFalse);
      expect(methods, ['/filesync.File/BlocksCheck']);
    });

    test('upload binds when BlocksCheck reports the blob exists outside space',
        () async {
      final payload = Uint8List.fromList('hello anytype'.codeUnits);
      final cid = await computeCid(payload);
      final cidBytes = cidToBytes(cid);
      final methods = <String>[];

      final result = await uploadBlobToFileNode(
        fileHandleId: 2,
        invoke: (handleId, method, requestBytes) {
          methods.add(method);
          expect(handleId, 2);
          switch (method) {
            case '/filesync.File/BlocksCheck':
              return filesync.BlocksCheckResponse(
                blocksAvailability: [
                  filesync.BlockAvailability(
                    cid: cidBytes,
                    status: filesync.AvailabilityStatus.Exists,
                  ),
                ],
              ).writeToBuffer();
            case '/filesync.File/BlocksBind':
              final request =
                  filesync.BlocksBindRequest.fromBuffer(requestBytes);
              expect(request.spaceId, 'space-a');
              expect(request.fileId, 'file-1');
              expect(request.cids, [cidBytes]);
              return filesync.Ok().writeToBuffer();
            default:
              fail('unexpected RPC: $method');
          }
        },
        spaceId: 'space-a',
        fileId: 'file-1',
        bytes: payload,
      );

      expect(result.cid, cid);
      expect(result.uploaded, isFalse);
      expect(methods, [
        '/filesync.File/BlocksCheck',
        '/filesync.File/BlocksBind',
      ]);
    });

    test('upload pushes exactly one missing block', () async {
      final payload = Uint8List.fromList('hello anytype'.codeUnits);
      final cid = await computeCid(payload);
      final cidBytes = cidToBytes(cid);
      final methods = <String>[];

      final result = await uploadBlobToFileNode(
        fileHandleId: 7,
        invoke: (handleId, method, requestBytes) {
          methods.add(method);
          switch (method) {
            case '/filesync.File/BlocksCheck':
              return filesync.BlocksCheckResponse(
                blocksAvailability: [
                  filesync.BlockAvailability(
                    cid: cidBytes,
                    status: filesync.AvailabilityStatus.NotExists,
                  ),
                ],
              ).writeToBuffer();
            case '/filesync.File/BlockPush':
              final request =
                  filesync.BlockPushRequest.fromBuffer(requestBytes);
              expect(request.fileId, 'file-1');
              expect(request.spaceId, 'space-a');
              expect(request.cid, cidBytes);
              expect(request.data, payload);
              return filesync.Ok().writeToBuffer();
            default:
              fail('unexpected RPC: $method');
          }
        },
        spaceId: 'space-a',
        fileId: 'file-1',
        bytes: payload,
      );

      expect(result.cid, cid);
      expect(result.uploaded, isTrue);
      expect(methods, [
        '/filesync.File/BlocksCheck',
        '/filesync.File/BlockPush',
      ]);
    });

    test('open caches first download and reuses cache on reopen', () async {
      final db = ManytypeDatabase.forTesting(await openDatabaseForTesting());
      addTearDown(db.close);

      final payload = Uint8List.fromList('hello anytype'.codeUnits);
      final cid = await computeCid(payload);
      var blockGetCalls = 0;

      final first = await openBlobFromFileNode(
        db: db,
        fileHandleId: 11,
        invoke: (handleId, method, requestBytes) {
          expect(handleId, 11);
          expect(method, '/filesync.File/BlockGet');
          blockGetCalls++;
          final request = filesync.BlockGetRequest.fromBuffer(requestBytes);
          expect(request.spaceId, 'space-a');
          expect(request.cid, cidToBytes(cid));
          return filesync.BlockGetResponse(
            cid: request.cid,
            data: payload,
          ).writeToBuffer();
        },
        spaceId: 'space-a',
        fileId: 'file-1',
        cid: cid,
      );

      final second = await openBlobFromFileNode(
        db: db,
        spaceId: 'space-a',
        fileId: 'file-1',
        cid: cid,
      );

      expect(first.fromCache, isFalse);
      expect(first.bytes, payload);
      expect(second.fromCache, isTrue);
      expect(second.bytes, payload);
      expect(blockGetCalls, 1);
      expect(
        await db.getCachedBlob(
          spaceId: 'space-a',
          fileId: 'file-1',
          cid: cid,
        ),
        isNotNull,
      );
    });
  });
}
