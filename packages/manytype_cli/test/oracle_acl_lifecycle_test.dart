@TestOn('vm') // FFI live-server ACL lifecycle against the docker oracle stack
@Tags(['round_trip'])
library;

import 'dart:typed_data';

import 'package:manytype_cli/src/acl_sync_service.dart';
import 'package:manytype_cli/src/ffi/native_bridge.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/network_config.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:test/test.dart';

import 'support/repo_root.dart';

import 'support/phase17_test_helpers.dart';

void main() {
  test(
    'oracle completes invite, join, accept, and member removal with intact ACL chain',
    () async {
      final repoRoot = findRepoRoot();
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
            Uint8List.fromList(List<int>.generate(32, (index) => index + 111));
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

        final acceptRecord = await buildAclRecord(
          prevId: joinResponse.id,
          aclData: buildOracleRequestAcceptAclData(
            accountPublicKey: joinerIdentity.accountKeyPair.publicKey,
            requestRecordId: joinResponse.id,
            permissions: AclUserPermissions.Writer,
          ),
          identityPrivateKey: ownerFixture.identity.accountSeed,
        );
        final acceptResponse = ownerService.addRecord(
          handleId: ownerHandle,
          spaceId: ownerFixture.identity.spaceId,
          record: RawRecord.fromBuffer(acceptRecord.payload),
        );

        final recordsAfterAccept = ownerService.getRecords(
          handleId: ownerHandle,
          spaceId: ownerFixture.identity.spaceId,
        );
        expect(recordsAfterAccept, hasLength(4));
        await _expectPersistedChain(
          ownerFixture.aclRootId,
          recordsAfterAccept,
        );

        final acceptedState = AclState()
          ..applyRoot(
            synthesizeAclRootRecord(
              aclRootId: ownerFixture.aclRootId,
              ownerPublicKey: ownerFixture.identity.accountKeyPair.publicKey,
            ),
          );
        for (final record in recordsAfterAccept.skip(1)) {
          acceptedState.applyRecord(await verifyAndDecodeAclRecord(record));
        }
        final joinerHex = _toHex(joinerIdentity.accountKeyPair.publicKey);
        expect(
          acceptedState.getPermission(joinerHex),
          equals(AclUserPermissions.Writer),
        );
        expect(
          acceptedState.getStatus(joinerHex),
          equals(AclAccountStatus.active),
        );

        final removeRecord = await buildAclRecord(
          prevId: acceptResponse.id,
          aclData: buildOracleAccountRemoveAclData(
            removedAccountPublicKeys: [joinerIdentity.accountKeyPair.publicKey],
            activeAccountPublicKeys: [
              ownerFixture.identity.accountKeyPair.publicKey
            ],
          ),
          identityPrivateKey: ownerFixture.identity.accountSeed,
        );
        final removeResponse = ownerService.addRecord(
          handleId: ownerHandle,
          spaceId: ownerFixture.identity.spaceId,
          record: RawRecord.fromBuffer(removeRecord.payload),
        );
        expect(removeResponse.id, isNotEmpty);

        final recordsAfterRemove = ownerService.getRecords(
          handleId: ownerHandle,
          spaceId: ownerFixture.identity.spaceId,
        );
        expect(recordsAfterRemove, hasLength(5));
        await _expectPersistedChain(
          ownerFixture.aclRootId,
          recordsAfterRemove,
        );

        final removedState = AclState()
          ..applyRoot(
            synthesizeAclRootRecord(
              aclRootId: ownerFixture.aclRootId,
              ownerPublicKey: ownerFixture.identity.accountKeyPair.publicKey,
            ),
          );
        for (final record in recordsAfterRemove.skip(1)) {
          removedState.applyRecord(await verifyAndDecodeAclRecord(record));
        }
        expect(removedState.getPermission(joinerHex), isNull);
        expect(
          removedState.getStatus(joinerHex),
          equals(AclAccountStatus.removed),
        );
      } finally {
        if (ownerHandle != null) ownerBridge.freeHandle(ownerHandle);
        if (joinerHandle != null) joinerBridge.freeHandle(joinerHandle);
        await ownerFixture.dispose();
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

Future<void> _expectPersistedChain(
  String rootId,
  List<RawRecordWithId> records,
) async {
  expect(records, isNotEmpty);
  expect(records.first.id, rootId);

  var prevId = rootId;
  for (final record in records.skip(1)) {
    final verified = await verifyAndDecodeAclRecord(record);
    expect(verified.prevId, prevId);
    prevId = record.id;
  }
}

String _toHex(List<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
