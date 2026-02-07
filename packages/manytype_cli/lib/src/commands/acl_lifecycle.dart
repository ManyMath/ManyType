import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:manytype_cli/src/acl_sync_service.dart';
import 'package:manytype_cli/src/ffi/native_bridge.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/network_config.dart';
import 'package:manytype_cli/src/operator_flow_support.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/manytype_protocol.dart';

const String kAclLifecycleBackendLabel = 'self-hosted-official';
const List<String> kAclLifecycleBackendRequirements = <String>[
  'requires a reachable self-hosted official Any-Sync coordinator from --network-config',
  'creates an ephemeral owner space and seeds it live before ACL writes',
];

Future<int> aclLifecycleCommand({
  required String networkConfigPath,
  bool jsonOutput = false,
}) async {
  final networkConfig = await loadNetworkConfig(networkConfigPath);
  final coordinatorAddress =
      chooseBestAddress(requireCoordinatorNode(networkConfig).addresses);
  final ownerFixture = await createEphemeralSpaceFixture(
    networkConfigPath: networkConfigPath,
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

    final report = <String, Object?>{
      'captured_at': DateTime.now().toUtc().toIso8601String(),
      'command': 'acl-lifecycle',
      'backend_label': kAclLifecycleBackendLabel,
      'backend_requirements': kAclLifecycleBackendRequirements,
      'network_config_path': networkConfigPath,
      'coordinator_address': coordinatorAddress,
      'space_id': ownerFixture.identity.spaceId,
      'acl_root_id': ownerFixture.aclRootId,
      'invite_record_id': inviteResponse.id,
      'join_record_id': joinResponse.id,
      'accept_record_id': acceptResponse.id,
      'record_ids_after_accept':
          recordsAfterAccept.map((record) => record.id).toList(),
      'tail_after_join_ids': tailAfterJoin.map((record) => record.id).toList(),
      'joiner_identity_hex': joinerHex,
      'joiner_permission': permission?.name,
      'joiner_status': status?.name,
    };

    if (jsonOutput) {
      stdout.writeln(const JsonEncoder.withIndent('  ').convert(report));
    } else {
      stdout.writeln('Command: acl-lifecycle');
      stdout.writeln('Backend: $kAclLifecycleBackendLabel');
      stdout.writeln('Space: ${ownerFixture.identity.spaceId}');
      stdout.writeln('ACL root: ${ownerFixture.aclRootId}');
      stdout.writeln('Invite record: ${inviteResponse.id}');
      stdout.writeln('Join record: ${joinResponse.id}');
      stdout.writeln('Accept record: ${acceptResponse.id}');
      stdout.writeln('Joiner permission: ${permission?.name}');
      stdout.writeln('Joiner status: ${status?.name}');
    }

    return 0;
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
