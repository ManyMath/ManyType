import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:manytype_cli/src/acl_sync_service.dart';
import 'package:manytype_cli/src/ffi/native_bridge.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/operator_flow_support.dart';
import 'package:manytype_cli/src/space_pull_bootstrap.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/manytype_protocol.dart';

const String kSpacePullBackendLabel = 'manytype_server';
const List<String> kSpacePullBackendRequirements = <String>[
  'requires a reachable manytype_server tree/coordinator surface',
  'bootstrap uses --network-config to seed a fresh ephemeral space before the fetch',
  'refetch requires the state JSON written by space-pull-bootstrap',
];

Future<int> spacePullBootstrapCommand({
  required String networkConfigPath,
  required String serverAddress,
  String? stateOut,
  bool jsonOutput = false,
}) async {
  final fixture = await createEphemeralSpaceFixture(
    networkConfigPath: networkConfigPath,
    serverAddress: serverAddress,
    text: 'space-pull-bootstrap-seed',
  );
  final bridge = NativeBridge();
  int? handleId;

  try {
    await seedEphemeralSpaceFixture(fixture);
    handleId = bridge.connect(
      serverAddress,
      fixture.identity.seed,
      fixture.identity.accountSeed,
    );
    final acl = AclSyncService(invoker: bridge.invoke);
    final bootstrap = SpacePullBootstrap(invoker: bridge.invoke);

    acl.spaceMakeShareable(
      handleId: handleId,
      spaceId: fixture.identity.spaceId,
    );
    final inviteRecord = await buildAclRecord(
      prevId: fixture.aclRootId,
      aclData: AclData(
        aclContent: [
          AclContentValue(
            invite: AclAccountInvite(
              inviteKey: marshalEd25519PublicKey(
                Uint8List.fromList(List<int>.filled(32, 29)),
              ),
              permissions: AclUserPermissions.Reader,
            ),
          ),
        ],
      ),
      identityPrivateKey: fixture.identity.accountSeed,
    );
    final inviteResponse = acl.addRecord(
      handleId: handleId,
      spaceId: fixture.identity.spaceId,
      record: RawRecord.fromBuffer(inviteRecord.payload),
    );

    final result = bootstrap.fetch(
      handleId: handleId,
      spaceId: fixture.identity.spaceId,
    );
    final payload = result.payload;
    final aclRecordIds = result.aclRecords.map((record) => record.id).toList();
    if (!payload.hasSpaceHeader() ||
        payload.spaceHeader.id != fixture.identity.spaceId ||
        payload.aclPayloadId != fixture.aclRootId ||
        result.aclRecords.length != 1 ||
        result.aclRecords.single.id != inviteResponse.id) {
      throw StateError(
        'Initial SpacePull fetch did not match expected continuity: '
        '${jsonEncode({
              'expected_space_id': fixture.identity.spaceId,
              'expected_acl_root_id': fixture.aclRootId,
              'expected_invite_record_id': inviteResponse.id,
              'has_space_header': payload.hasSpaceHeader(),
              'actual_space_header_id':
                  payload.hasSpaceHeader() ? payload.spaceHeader.id : null,
              'actual_acl_payload_id': payload.aclPayloadId,
              'actual_acl_record_ids': aclRecordIds,
            })}',
      );
    }

    if (stateOut != null && stateOut.isNotEmpty) {
      await writeJsonFile(
        stateOut,
        SpacePullFlowState(
          mnemonic: fixture.config.mnemonic,
          serverAddress: serverAddress,
          spaceId: fixture.identity.spaceId,
          aclRootId: fixture.aclRootId,
          inviteRecordId: inviteResponse.id,
        ).toJson(),
      );
    }

    final report = <String, Object?>{
      'captured_at': DateTime.now().toUtc().toIso8601String(),
      'command': 'space-pull-bootstrap',
      'backend_label': kSpacePullBackendLabel,
      'backend_requirements': kSpacePullBackendRequirements,
      'network_config_path': networkConfigPath,
      'server_address': serverAddress,
      'space_id': fixture.identity.spaceId,
      'acl_root_id': fixture.aclRootId,
      'invite_record_id': inviteResponse.id,
      'space_header_id': payload.spaceHeader.id,
      'acl_payload_id': payload.aclPayloadId,
      'acl_record_ids': aclRecordIds,
      'state_path': stateOut,
    };

    if (jsonOutput) {
      stdout.writeln(const JsonEncoder.withIndent('  ').convert(report));
    } else {
      stdout.writeln('Command: space-pull-bootstrap');
      stdout.writeln('Backend: $kSpacePullBackendLabel');
      stdout.writeln('Space: ${fixture.identity.spaceId}');
      stdout.writeln('ACL root: ${fixture.aclRootId}');
      stdout.writeln('Invite record: ${inviteResponse.id}');
      if (stateOut != null && stateOut.isNotEmpty) {
        stdout.writeln('State: $stateOut');
      }
    }

    return 0;
  } finally {
    if (handleId != null) {
      bridge.freeHandle(handleId);
    }
    await fixture.dispose();
  }
}

Future<int> spacePullRefetchCommand({
  String? serverOverride,
  required String stateIn,
  bool jsonOutput = false,
}) async {
  final state = SpacePullFlowState.fromJson(await readJsonFile(stateIn));
  final serverAddress = serverOverride ?? state.serverAddress;
  final identity = await Identity.fromMnemonic(state.mnemonic);
  final bridge = NativeBridge();
  final handleId =
      bridge.connect(serverAddress, identity.seed, identity.accountSeed);

  try {
    final bootstrap = SpacePullBootstrap(invoker: bridge.invoke);
    final result = bootstrap.fetch(handleId: handleId, spaceId: state.spaceId);
    final payload = result.payload;
    final aclRecordIds = result.aclRecords.map((record) => record.id).toList();
    if (!payload.hasSpaceHeader() ||
        payload.spaceHeader.id != state.spaceId ||
        payload.aclPayloadId != state.aclRootId ||
        result.aclRecords.length != 1 ||
        result.aclRecords.single.id != state.inviteRecordId) {
      throw StateError(
        'Restarted SpacePull fetch did not match expected continuity: '
        '${jsonEncode({
              'expected_space_id': state.spaceId,
              'expected_acl_root_id': state.aclRootId,
              'expected_invite_record_id': state.inviteRecordId,
              'has_space_header': payload.hasSpaceHeader(),
              'actual_space_header_id':
                  payload.hasSpaceHeader() ? payload.spaceHeader.id : null,
              'actual_acl_payload_id': payload.aclPayloadId,
              'actual_acl_record_ids': aclRecordIds,
            })}',
      );
    }

    final report = <String, Object?>{
      'captured_at': DateTime.now().toUtc().toIso8601String(),
      'command': 'space-pull-refetch',
      'backend_label': kSpacePullBackendLabel,
      'backend_requirements': kSpacePullBackendRequirements,
      'server_address': serverAddress,
      'state_in': stateIn,
      'space_id': state.spaceId,
      'acl_root_id': state.aclRootId,
      'invite_record_id': state.inviteRecordId,
      'space_header_id': payload.spaceHeader.id,
      'acl_payload_id': payload.aclPayloadId,
      'acl_record_ids': aclRecordIds,
    };

    if (jsonOutput) {
      stdout.writeln(const JsonEncoder.withIndent('  ').convert(report));
    } else {
      stdout.writeln('Command: space-pull-refetch');
      stdout.writeln('Backend: $kSpacePullBackendLabel');
      stdout.writeln('Space: ${state.spaceId}');
      stdout.writeln('Invite record: ${state.inviteRecordId}');
    }

    return 0;
  } finally {
    bridge.freeHandle(handleId);
  }
}
