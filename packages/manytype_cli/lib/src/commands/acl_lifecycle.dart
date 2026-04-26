import 'dart:typed_data';

import 'package:manytype_cli/src/acl_sync_service.dart';
import 'package:manytype_cli/src/ffi/native_bridge.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/network_config.dart';
import 'package:manytype_cli/src/operator_flow_support.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/manytype_protocol.dart';

import '../session.dart';

const String kAclLifecycleBackendLabel = 'self-hosted-official';
const List<String> kAclLifecycleBackendRequirements = <String>[
  'requires a reachable self-hosted official Any-Sync coordinator from --network-config',
  'creates an ephemeral owner space and seeds it live before ACL writes',
];

/// Report produced by [aclLifecycleCommand]: an owner space seeded live,
/// invited/joined/accepted through a full ACL record round-trip, and the
/// resulting decoded ACL state for the joiner. `toJson()` matches the
/// `--json` CLI output shape.
class AclLifecycleReport {
  const AclLifecycleReport({
    required this.capturedAt,
    this.networkConfigPath,
    this.networkConfigContent,
    required this.coordinatorAddress,
    required this.spaceId,
    required this.aclRootId,
    required this.inviteRecordId,
    required this.joinRecordId,
    required this.acceptRecordId,
    required this.recordIdsAfterAccept,
    required this.tailAfterJoinIds,
    required this.joinerIdentityHex,
    required this.joinerPermission,
    required this.joinerStatus,
  });

  final DateTime capturedAt;
  final String? networkConfigPath;
  final String? networkConfigContent;
  final String coordinatorAddress;
  final String spaceId;
  final String aclRootId;
  final String inviteRecordId;
  final String joinRecordId;
  final String acceptRecordId;
  final List<String> recordIdsAfterAccept;
  final List<String> tailAfterJoinIds;
  final String joinerIdentityHex;
  final String? joinerPermission;
  final String? joinerStatus;

  Map<String, Object?> toJson() => {
        'captured_at': capturedAt.toIso8601String(),
        'command': 'acl-lifecycle',
        'backend_label': kAclLifecycleBackendLabel,
        'backend_requirements': kAclLifecycleBackendRequirements,
        'network_config_path': networkConfigPath,
        'coordinator_address': coordinatorAddress,
        'space_id': spaceId,
        'acl_root_id': aclRootId,
        'invite_record_id': inviteRecordId,
        'join_record_id': joinRecordId,
        'accept_record_id': acceptRecordId,
        'record_ids_after_accept': recordIdsAfterAccept,
        'tail_after_join_ids': tailAfterJoinIds,
        'joiner_identity_hex': joinerIdentityHex,
        'joiner_permission': joinerPermission,
        'joiner_status': joinerStatus,
      };
}

Future<AclLifecycleReport> aclLifecycleCommand({
  String? networkConfigPath,
  String? networkConfigContent,
}) async {
  final networkConfig = await resolveNetworkConfig(
    networkConfigPath: networkConfigPath,
    networkConfigContent: networkConfigContent,
  );
  final coordinatorAddress =
      chooseBestAddress(requireCoordinatorNode(networkConfig).addresses);
  final ownerFixture = await createEphemeralSpaceFixture(
    networkConfigPath: networkConfigPath,
    networkConfigContent: networkConfigContent,
    text: 'acl-lifecycle-seed',
  );
  final joinerIdentity = await Identity.fromMnemonic(generateMnemonic());
  final ownerBridge = NativeBridge();
  final joinerBridge = NativeBridge();
  int? ownerHandle;
  int? joinerHandle;

  try {
    await seedEphemeralSpaceFixture(ownerFixture);
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
        Uint8List.fromList(List<int>.generate(32, (index) => index + 131));
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
    if (recordsAfterAccept.length != 4) {
      throw StateError(
        'Expected 4 ACL records after accept, got ${recordsAfterAccept.length}',
      );
    }
    if (recordsAfterAccept.first.id != ownerFixture.aclRootId) {
      throw StateError(
        'Expected ACL root ${ownerFixture.aclRootId}, got ${recordsAfterAccept.first.id}',
      );
    }

    final tailAfterJoin = ownerService.getRecords(
      handleId: ownerHandle,
      spaceId: ownerFixture.identity.spaceId,
      aclHead: joinResponse.id,
    );
    if (!tailAfterJoin.any((record) => record.id == acceptResponse.id)) {
      throw StateError('AclGetRecords tail did not include the accept record');
    }

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
    final joinerHex = toHex(joinerIdentity.accountKeyPair.publicKey);
    final permission = acceptedState.getPermission(joinerHex);
    final status = acceptedState.getStatus(joinerHex);
    if (permission != AclUserPermissions.Writer ||
        status != AclAccountStatus.active) {
      throw StateError(
        'Decoded ACL state mismatch: permission=$permission status=$status',
      );
    }

    return AclLifecycleReport(
      capturedAt: DateTime.now().toUtc(),
      networkConfigPath: networkConfigPath,
      networkConfigContent: networkConfigContent,
      coordinatorAddress: coordinatorAddress,
      spaceId: ownerFixture.identity.spaceId,
      aclRootId: ownerFixture.aclRootId,
      inviteRecordId: inviteResponse.id,
      joinRecordId: joinResponse.id,
      acceptRecordId: acceptResponse.id,
      recordIdsAfterAccept:
          recordsAfterAccept.map((record) => record.id).toList(),
      tailAfterJoinIds: tailAfterJoin.map((record) => record.id).toList(),
      joinerIdentityHex: joinerHex,
      joinerPermission: permission?.name,
      joinerStatus: status?.name,
    );
  } finally {
    if (ownerHandle != null) {
      ownerBridge.freeHandle(ownerHandle);
    }
    if (joinerHandle != null) {
      joinerBridge.freeHandle(joinerHandle);
    }
    await ownerFixture.dispose();
  }
}

/// Library-facing facade over the ACL invite/join/accept diagnostic
/// round-trip, for consumers that hold a [ManytypeSession] instead of
/// driving the CLI directly. Exposed as `session.aclLifecycle`.
///
/// Like [AccountsFacade]/`ProbeNetworkFacade`, this doesn't touch
/// [ManytypeSession.db]/[ManytypeSession.config]: it seeds its own
/// ephemeral owner/joiner spaces against the coordinator named in
/// `networkConfigPath`: but it's grouped under the session for a
/// consistent `session.<domain>.<verb>(...)` call shape.
class AclLifecycleFacade {
  const AclLifecycleFacade(this._session);

  // ignore: unused_field
  final ManytypeSession _session;

  Future<AclLifecycleReport> run({
    String? networkConfigPath,
    String? networkConfigContent,
  }) {
    return aclLifecycleCommand(
      networkConfigPath: networkConfigPath,
      networkConfigContent: networkConfigContent,
    );
  }
}
