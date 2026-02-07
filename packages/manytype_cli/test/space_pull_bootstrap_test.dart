@Tags(['round_trip'])
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:manytype_cli/src/acl_sync_service.dart';
import 'package:manytype_cli/src/ffi/native_bridge.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/network_config.dart';
import 'package:manytype_cli/src/space_pull_bootstrap.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:manytype_protocol/spacesync.dart';
import 'package:test/test.dart';

import 'support/phase17_test_helpers.dart';

void main() {
  group('SpacePullBootstrap', () {
    test('normalizes acl records from the response', () {
      final record = RawRecordWithId(id: 'cid-1', payload: [1, 2, 3]);
      final bootstrap = SpacePullBootstrap(
        invoker: (handleId, method, payload) => SpacePullResponse(
          payload: SpacePayload(aclPayloadId: 'root-cid'),
          aclRecords: [
            AclRecord(
              id: 'cid-1',
              aclPayload: record.writeToBuffer(),
            ),
          ],
        ).writeToBuffer(),
      );

      final result = bootstrap.fetch(handleId: 3, spaceId: 'space-1');

      expect(result.payload.aclPayloadId, 'root-cid');
      expect(result.aclRecords.single.id, 'cid-1');
      expect(result.aclRecords.single.payload, [1, 2, 3]);
    });

    test('falls back to the outer acl record id for raw-record payloads', () {
      final rawRecord = RawRecord(payload: [1, 2, 3], signature: [4, 5, 6]);
      final bootstrap = SpacePullBootstrap(
        invoker: (handleId, method, payload) => SpacePullResponse(
          payload: SpacePayload(aclPayloadId: 'root-cid'),
          aclRecords: [
            AclRecord(
              id: 'cid-outer',
              aclPayload: rawRecord.writeToBuffer(),
            ),
          ],
        ).writeToBuffer(),
      );

      final result = bootstrap.fetch(handleId: 3, spaceId: 'space-1');

      expect(result.aclRecords.single.id, 'cid-outer');
      expect(
        result.aclRecords.single.payload,
        rawRecord.writeToBuffer(),
      );
    });
  });

  group('SpacePullBootstrap round trip', () {
    late NativeBridge bridge;
    late SpacePullBootstrap bootstrap;
    late AclSyncService service;
    late Phase17SpaceFixture localFixture;
    late int localHandleId;

    setUp(() async {
      bridge = NativeBridge();
      final networkConfigPath = await writeLocalNetworkConfig(
        Directory.systemTemp.createTempSync('manytype_phase17_bootstrap_cfg_'),
      );
      localFixture =
          await createPhase17Fixture(networkConfigPath: networkConfigPath);
      await seedPhase17Fixture(localFixture);
      localHandleId = bridge.connect(
        localFixture.config.serverAddress,
        localFixture.identity.seed,
        localFixture.identity.accountSeed,
      );
      bootstrap = SpacePullBootstrap(invoker: bridge.invoke);
      service = AclSyncService(invoker: bridge.invoke);
    });

    tearDown(() async {
      bridge.freeHandle(localHandleId);
      await localFixture.dispose();
    });

    test(
        'SpacePull fetches decoded payload and acl records from the local server',
        () async {
      service.spaceMakeShareable(
        handleId: localHandleId,
        spaceId: localFixture.identity.spaceId,
      );
      final inviteRecord = await buildAclRecord(
        prevId: localFixture.aclRootId,
        aclData: AclData(
          aclContent: [
            AclContentValue(
              invite: AclAccountInvite(
                inviteKey: marshalEd25519PublicKey(
                    Uint8List.fromList(List<int>.filled(32, 9))),
                permissions: AclUserPermissions.Reader,
              ),
            ),
          ],
        ),
        identityPrivateKey: localFixture.identity.accountSeed,
      );
      final inviteResponse = service.addRecord(
        handleId: localHandleId,
        spaceId: localFixture.identity.spaceId,
        record: RawRecord.fromBuffer(inviteRecord.payload),
      );

      final result = bootstrap.fetch(
        handleId: localHandleId,
        spaceId: localFixture.identity.spaceId,
      );

      expect(result.payload.spaceHeader.id, localFixture.identity.spaceId);
      expect(result.payload.aclPayloadId, localFixture.aclRootId);
      expect(result.aclRecords, hasLength(1));
      expect(result.aclRecords.single.id, inviteResponse.id);
    }, timeout: const Timeout(Duration(minutes: 2)));
  });

  test('oracle accepts an AclRequestJoin record through AclSyncService',
      () async {
    final repoRoot = Directory.current.path;
    final networkConfigPath = '$repoRoot/docker/any-sync/etc/client.yml';
    final networkConfig = await loadNetworkConfig(networkConfigPath);
    final coordinatorAddress =
        chooseBestAddress(requireCoordinatorNode(networkConfig).addresses);
    final ownerFixture =
        await createPhase17Fixture(networkConfigPath: networkConfigPath);
    await seedPhase17Fixture(ownerFixture);
    final joinerIdentity = await Identity.fromMnemonic(generateMnemonic());

    final ownerBridge = NativeBridge();
    final joinerBridge = NativeBridge();
    int? ownerHandle;
    int? joinerHandle;

    try {
      ownerHandle = ownerBridge.connect(
        coordinatorAddress,
        ownerFixture.identity.seed,
        ownerFixture.identity.accountSeed,
      );
      joinerHandle = joinerBridge.connect(
        coordinatorAddress,
        joinerIdentity.seed,
        joinerIdentity.accountSeed,
      );

      final ownerService = AclSyncService(invoker: ownerBridge.invoke);
      final joinerService = AclSyncService(invoker: joinerBridge.invoke);
      ownerService.spaceMakeShareable(
        handleId: ownerHandle,
        spaceId: ownerFixture.identity.spaceId,
      );

      final inviteSeed =
          Uint8List.fromList(List<int>.generate(32, (index) => index + 71));
      final inviteKeyPair = await ed25519KeyPairFromSeed(inviteSeed);
      final inviteRecord = await buildAclRecord(
        prevId: ownerFixture.aclRootId,
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
        identityPrivateKey: ownerFixture.identity.accountSeed,
      );
      final inviteResponse = ownerService.addRecord(
        handleId: ownerHandle,
        spaceId: ownerFixture.identity.spaceId,
        record: RawRecord.fromBuffer(inviteRecord.payload),
      );

      final inviteSignature = await ed25519Sign(
        inviteSeed,
        joinerIdentity.accountKeyPair.publicKey,
      );
      final joinRecord = await buildAclRecord(
        prevId: inviteResponse.id,
        aclData: AclData(
          aclContent: [
            AclContentValue(
              requestJoin: AclAccountRequestJoin(
                inviteIdentity: marshalEd25519PublicKey(
                  joinerIdentity.accountKeyPair.publicKey,
                ),
                inviteRecordId: inviteResponse.id,
                inviteIdentitySignature: inviteSignature,
                metadata: Uint8List(0),
              ),
            ),
          ],
        ),
        identityPrivateKey: joinerIdentity.accountSeed,
      );
      final joinResponse = joinerService.addRecord(
        handleId: joinerHandle,
        spaceId: ownerFixture.identity.spaceId,
        record: RawRecord.fromBuffer(joinRecord.payload),
      );

      expect(joinResponse.id, isNotEmpty);
      expect(joinResponse.id, isNot(joinRecord.id));
    } finally {
      if (ownerHandle != null) {
        ownerBridge.freeHandle(ownerHandle);
      }
      if (joinerHandle != null) {
        joinerBridge.freeHandle(joinerHandle);
      }
      await ownerFixture.dispose();
    }
  },
      // Oracle join proof: passes after the deterministic non-zero
      // SpaceHeader.timestamp fix in identity.dart.
      timeout: const Timeout(Duration(minutes: 3)));
}
