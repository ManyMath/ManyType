import 'dart:convert';
import 'dart:typed_data';

import 'package:manytype_cli/src/acl_sync_service.dart';
import 'package:manytype_cli/src/ffi/native_bridge.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/operator_flow_support.dart';
import 'package:manytype_cli/src/space_pull_bootstrap.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/manytype_protocol.dart';

import '../session.dart';

const String kSpacePullBackendLabel = 'manytype_server';
const List<String> kSpacePullBackendRequirements = <String>[
  'requires a reachable manytype_server tree/coordinator surface',
  'bootstrap uses --network-config to seed a fresh ephemeral space before the fetch',
  'refetch requires the state JSON written by space-pull-bootstrap',
];

/// Report produced by [spacePullBootstrapCommand]. `toJson()` matches the
/// `--json` CLI output shape.
class SpacePullBootstrapReport {
  const SpacePullBootstrapReport({
    required this.capturedAt,
    required this.networkConfigPath,
    required this.serverAddress,
    required this.spaceId,
    required this.aclRootId,
    required this.inviteRecordId,
    required this.spaceHeaderId,
    required this.aclPayloadId,
    required this.aclRecordIds,
    this.statePath,
  });

  final DateTime capturedAt;
  final String networkConfigPath;
  final String serverAddress;
  final String spaceId;
  final String aclRootId;
  final String inviteRecordId;
  final String spaceHeaderId;
  final String aclPayloadId;
  final List<String> aclRecordIds;
  final String? statePath;

  Map<String, Object?> toJson() => {
        'captured_at': capturedAt.toIso8601String(),
        'command': 'space-pull-bootstrap',
        'backend_label': kSpacePullBackendLabel,
        'backend_requirements': kSpacePullBackendRequirements,
        'network_config_path': networkConfigPath,
        'server_address': serverAddress,
        'space_id': spaceId,
        'acl_root_id': aclRootId,
        'invite_record_id': inviteRecordId,
        'space_header_id': spaceHeaderId,
        'acl_payload_id': aclPayloadId,
        'acl_record_ids': aclRecordIds,
        'state_path': statePath,
      };
}

/// Report produced by [spacePullRefetchCommand]. `toJson()` matches the
/// `--json` CLI output shape.
class SpacePullRefetchReport {
  const SpacePullRefetchReport({
    required this.capturedAt,
    required this.serverAddress,
    required this.stateIn,
    required this.spaceId,
    required this.aclRootId,
    required this.inviteRecordId,
    required this.spaceHeaderId,
    required this.aclPayloadId,
    required this.aclRecordIds,
  });

  final DateTime capturedAt;
  final String serverAddress;
  final String stateIn;
  final String spaceId;
  final String aclRootId;
  final String inviteRecordId;
  final String spaceHeaderId;
  final String aclPayloadId;
  final List<String> aclRecordIds;

  Map<String, Object?> toJson() => {
        'captured_at': capturedAt.toIso8601String(),
        'command': 'space-pull-refetch',
        'backend_label': kSpacePullBackendLabel,
        'backend_requirements': kSpacePullBackendRequirements,
        'server_address': serverAddress,
        'state_in': stateIn,
        'space_id': spaceId,
        'acl_root_id': aclRootId,
        'invite_record_id': inviteRecordId,
        'space_header_id': spaceHeaderId,
        'acl_payload_id': aclPayloadId,
        'acl_record_ids': aclRecordIds,
      };
}

Future<SpacePullBootstrapReport> spacePullBootstrapCommand({
  required String networkConfigPath,
  required String serverAddress,
  String? stateOut,
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

    return SpacePullBootstrapReport(
      capturedAt: DateTime.now().toUtc(),
      networkConfigPath: networkConfigPath,
      serverAddress: serverAddress,
      spaceId: fixture.identity.spaceId,
      aclRootId: fixture.aclRootId,
      inviteRecordId: inviteResponse.id,
      spaceHeaderId: payload.spaceHeader.id,
      aclPayloadId: payload.aclPayloadId,
      aclRecordIds: aclRecordIds,
      statePath: stateOut,
    );
  } finally {
    if (handleId != null) {
      bridge.freeHandle(handleId);
    }
    await fixture.dispose();
  }
}

Future<SpacePullRefetchReport> spacePullRefetchCommand({
  String? serverOverride,
  required String stateIn,
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

    return SpacePullRefetchReport(
      capturedAt: DateTime.now().toUtc(),
      serverAddress: serverAddress,
      stateIn: stateIn,
      spaceId: state.spaceId,
      aclRootId: state.aclRootId,
      inviteRecordId: state.inviteRecordId,
      spaceHeaderId: payload.spaceHeader.id,
      aclPayloadId: payload.aclPayloadId,
      aclRecordIds: aclRecordIds,
    );
  } finally {
    bridge.freeHandle(handleId);
  }
}

/// Library-facing facade over the space-pull bootstrap/refetch diagnostic
/// flow, for consumers that hold a [ManytypeSession] instead of driving the
/// CLI directly. Exposed as `session.spacePull`.
///
/// Like [ConsensusFlowFacade], this doesn't touch [ManytypeSession.db]/
/// [ManytypeSession.config]: each call connects with its own ephemeral or
/// state-file-derived identity: but it's grouped under the session for a
/// consistent `session.<domain>.<verb>(...)` call shape.
class SpacePullFlowFacade {
  const SpacePullFlowFacade(this._session);

  // ignore: unused_field
  final ManytypeSession _session;

  Future<SpacePullBootstrapReport> bootstrap({
    required String networkConfigPath,
    required String serverAddress,
    String? stateOut,
  }) {
    return spacePullBootstrapCommand(
      networkConfigPath: networkConfigPath,
      serverAddress: serverAddress,
      stateOut: stateOut,
    );
  }

  Future<SpacePullRefetchReport> refetch({
    String? serverOverride,
    required String stateIn,
  }) {
    return spacePullRefetchCommand(
      serverOverride: serverOverride,
      stateIn: stateIn,
    );
  }
}
