@TestOn('vm') // FFI live-server ACL admission against the docker oracle stack
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
    'oracle accepts first owner AclAccountInvite without space limit reached',
    () async {
      final repoRoot = findRepoRoot();
      final networkConfigPath = '$repoRoot/docker/any-sync/etc/client.yml';
      final networkConfig = await loadNetworkConfig(networkConfigPath);
      final coordinatorAddress =
          chooseBestAddress(requireCoordinatorNode(networkConfig).addresses);
      final ownerFixture =
          await createPhase17Fixture(networkConfigPath: networkConfigPath);
      await seedPhase17Fixture(ownerFixture);

      final ownerBridge = NativeBridge();
      int? ownerHandle;

      try {
        ownerHandle = ownerBridge.connect(
          coordinatorAddress,
          ownerFixture.identity.seed,
          ownerFixture.identity.accountSeed,
        );
        final ownerService = AclSyncService(invoker: ownerBridge.invoke);
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

        expect(inviteResponse.id, isNotEmpty);
        expect(inviteResponse.id, isNot(inviteRecord.id));
      } finally {
        if (ownerHandle != null) ownerBridge.freeHandle(ownerHandle);
        await ownerFixture.dispose();
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test(
    'oracle accepts AclAccountRequestJoin from a joiner after invite',
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
            Uint8List.fromList(List<int>.generate(32, (index) => index + 91));
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
                      joinerIdentity.accountKeyPair.publicKey),
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

        expect(inviteResponse.id, isNotEmpty);
        expect(inviteResponse.id, isNot(inviteRecord.id));
        expect(joinResponse.id, isNotEmpty);
        expect(joinResponse.id, isNot(joinRecord.id));
      } finally {
        if (ownerHandle != null) ownerBridge.freeHandle(ownerHandle);
        if (joinerHandle != null) joinerBridge.freeHandle(joinerHandle);
        await ownerFixture.dispose();
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
