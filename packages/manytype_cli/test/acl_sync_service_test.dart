import 'dart:io';
import 'dart:typed_data';

import 'package:manytype_cli/src/acl_sync_service.dart';
import 'package:manytype_cli/src/ffi/native_bridge.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/coordinator.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:test/test.dart';

import 'support/phase17_test_helpers.dart';

void main() {
  group('AclSyncService', () {
    test('spaceMakeShareable invokes the coordinator RPC', () {
      late String method;
      late SpaceMakeShareableRequest request;
      final service = AclSyncService(
        invoker: (handleId, nextMethod, payload) {
          method = nextMethod;
          request = SpaceMakeShareableRequest.fromBuffer(payload);
          return Uint8List(0);
        },
      );

      service.spaceMakeShareable(handleId: 7, spaceId: 'space-1');

      expect(method, '/coordinator.Coordinator/SpaceMakeShareable');
      expect(request.spaceId, 'space-1');
    });

    test('addRecord returns the server-confirmed RawRecordWithId', () async {
      final localRecord = await buildAclRecord(
        prevId: 'root-cid',
        aclData: AclData(),
        identityPrivateKey: Uint8List.fromList(List<int>.filled(32, 3)),
      );
      late AclAddRecordRequest request;
      final service = AclSyncService(
        invoker: (handleId, method, payload) {
          request = AclAddRecordRequest.fromBuffer(payload);
          return AclAddRecordResponse(
            recordId: 'server-cid',
            payload: request.payload,
          ).writeToBuffer();
        },
      );

      final result = service.addRecord(
        handleId: 11,
        spaceId: 'space-1',
        record: RawRecord.fromBuffer(localRecord.payload),
      );

      expect(request.spaceId, 'space-1');
      expect(result.id, 'server-cid');
      expect(result.payload, request.payload);
    });

    test('getRecords decodes ordered RawRecordWithId values', () {
      final first = RawRecordWithId(id: 'cid-1', payload: [1, 2, 3]);
      final second = RawRecordWithId(id: 'cid-2', payload: [4, 5, 6]);
      final service = AclSyncService(
        invoker: (handleId, method, payload) => AclGetRecordsResponse(
          records: [
            first.writeToBuffer(),
            second.writeToBuffer(),
          ],
        ).writeToBuffer(),
      );

      final records =
          service.getRecords(handleId: 1, spaceId: 'space-1', aclHead: 'cid-1');

      expect(records.map((record) => record.id), ['cid-1', 'cid-2']);
    });
  });

  group('AclSyncService round trip', () {
    late NativeBridge bridge;
    late Phase17SpaceFixture fixture;
    late AclSyncService service;
    late int handleId;

    setUp(() async {
      bridge = NativeBridge();
      final networkConfigPath = await writeLocalNetworkConfig(
        Directory.systemTemp.createTempSync('manytype_phase17_local_cfg_'),
      );
      fixture =
          await createPhase17Fixture(networkConfigPath: networkConfigPath);
      await seedPhase17Fixture(fixture);
      handleId = bridge.connect(
        fixture.config.serverAddress,
        fixture.identity.seed,
        fixture.identity.accountSeed,
      );
      service = AclSyncService(invoker: bridge.invoke);
    });

    tearDown(() async {
      bridge.freeHandle(handleId);
      await fixture.dispose();
    });

    test(
      'SpaceMakeShareable flips status and invite submission is readable via AclGetRecords',
      () async {
        service.spaceMakeShareable(
          handleId: handleId,
          spaceId: fixture.identity.spaceId,
        );

        final statusBytes = bridge.invoke(
          handleId,
          '/coordinator.Coordinator/SpaceStatusCheck',
          SpaceStatusCheckRequest(spaceId: fixture.identity.spaceId)
              .writeToBuffer(),
        );
        final status = SpaceStatusCheckResponse.fromBuffer(statusBytes);
        expect(status.payload.isShared, isTrue);

        final inviteKeyPair = await ed25519KeyPairFromSeed(
          Uint8List.fromList(List<int>.generate(32, (index) => index + 51)),
        );
        final inviteRecord = await buildAclRecord(
          prevId: fixture.aclRootId,
          aclData: AclData(
            aclContent: [
              AclContentValue(
                invite: AclAccountInvite(
                  inviteKey: marshalEd25519PublicKey(inviteKeyPair.publicKey),
                  permissions: AclUserPermissions.Writer,
                ),
              ),
            ],
          ),
          identityPrivateKey: fixture.identity.accountSeed,
        );
        final inviteResponse = service.addRecord(
          handleId: handleId,
          spaceId: fixture.identity.spaceId,
          record: RawRecord.fromBuffer(inviteRecord.payload),
        );

        final records = service.getRecords(
          handleId: handleId,
          spaceId: fixture.identity.spaceId,
        );

        expect(records, hasLength(1));
        expect(records.single.id, inviteResponse.id);

        final tail = service.getRecords(
          handleId: handleId,
          spaceId: fixture.identity.spaceId,
          aclHead: inviteResponse.id,
        );
        expect(tail, isEmpty);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });
}
