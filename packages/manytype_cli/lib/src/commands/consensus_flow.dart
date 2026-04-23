import 'dart:typed_data';

import 'package:manytype_cli/src/acl_sync_service.dart';
import 'package:manytype_cli/src/consensus_service.dart';
import 'package:manytype_cli/src/ffi/native_bridge.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/operator_flow_support.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/manytype_protocol.dart';

import '../session.dart';

const String kConsensusBackendLabel = 'manytype_server';
const List<String> kConsensusBackendRequirements = <String>[
  'requires a reachable manytype_server coordinator and consensus surface via --server',
  'continuation requires the state JSON written by consensus-bootstrap',
];

/// Report produced by [consensusBootstrapCommand]. `toJson()` matches the
/// `--json` CLI output shape.
class ConsensusBootstrapReport {
  const ConsensusBootstrapReport({
    required this.capturedAt,
    required this.serverAddress,
    required this.logId,
    required this.spaceId,
    required this.rootId,
    required this.firstRecordId,
    required this.recordIdsAfterFirst,
    required this.tailAfterRootIds,
    this.statePath,
  });

  final DateTime capturedAt;
  final String serverAddress;
  final String logId;
  final String spaceId;
  final String rootId;
  final String firstRecordId;
  final List<String> recordIdsAfterFirst;
  final List<String> tailAfterRootIds;
  final String? statePath;

  Map<String, Object?> toJson() => {
        'captured_at': capturedAt.toIso8601String(),
        'command': 'consensus-bootstrap',
        'backend_label': kConsensusBackendLabel,
        'backend_requirements': kConsensusBackendRequirements,
        'server_address': serverAddress,
        'log_id': logId,
        'space_id': spaceId,
        'root_id': rootId,
        'first_record_id': firstRecordId,
        'record_ids_after_first': recordIdsAfterFirst,
        'tail_after_root_ids': tailAfterRootIds,
        'state_path': statePath,
      };
}

/// Report produced by [consensusContinueCommand]. `toJson()` matches the
/// `--json` CLI output shape.
class ConsensusContinueReport {
  const ConsensusContinueReport({
    required this.capturedAt,
    required this.serverAddress,
    required this.stateIn,
    required this.logId,
    required this.spaceId,
    required this.rootId,
    required this.firstRecordId,
    required this.secondRecordId,
    required this.recordIdsBeforeContinue,
    required this.recordIdsAfterContinue,
    required this.tailAfterFirstIds,
  });

  final DateTime capturedAt;
  final String serverAddress;
  final String stateIn;
  final String logId;
  final String spaceId;
  final String rootId;
  final String firstRecordId;
  final String secondRecordId;
  final List<String> recordIdsBeforeContinue;
  final List<String> recordIdsAfterContinue;
  final List<String> tailAfterFirstIds;

  Map<String, Object?> toJson() => {
        'captured_at': capturedAt.toIso8601String(),
        'command': 'consensus-continue',
        'backend_label': kConsensusBackendLabel,
        'backend_requirements': kConsensusBackendRequirements,
        'server_address': serverAddress,
        'state_in': stateIn,
        'log_id': logId,
        'space_id': spaceId,
        'root_id': rootId,
        'first_record_id': firstRecordId,
        'second_record_id': secondRecordId,
        'record_ids_before_continue': recordIdsBeforeContinue,
        'record_ids_after_continue': recordIdsAfterContinue,
        'tail_after_first_ids': tailAfterFirstIds,
      };
}

Future<ConsensusBootstrapReport> consensusBootstrapCommand({
  required String serverAddress,
  String? stateOut,
}) async {
  final mnemonic = generateMnemonic();
  final identity = await Identity.fromMnemonic(mnemonic);
  final bridge = NativeBridge();
  final handleId =
      bridge.connect(serverAddress, identity.seed, identity.accountSeed);

  try {
    final consensus = ConsensusService(invoker: bridge.invoke);
    final acl = AclSyncService(invoker: bridge.invoke);
    final root = await buildAclRoot(
      spaceId: identity.spaceId,
      masterKeySeed: identity.accountSeed,
      identityPrivateKey: identity.seed,
      readKey:
          Uint8List.fromList(List<int>.generate(32, (index) => index + 11)),
    );
    consensus.logAdd(handleId: handleId, logId: identity.spaceId, record: root);

    final firstRecord = await buildAclRecord(
      prevId: root.id,
      aclData: AclData(
        aclContent: [
          AclContentValue(
            invite: AclAccountInvite(
              inviteKey: marshalEd25519PublicKey(
                Uint8List.fromList(List<int>.filled(32, 9)),
              ),
              permissions: AclUserPermissions.Reader,
            ),
          ),
        ],
      ),
      identityPrivateKey: identity.seed,
    );
    final firstResponse = consensus.recordAdd(
      handleId: handleId,
      logId: identity.spaceId,
      record: RawRecord.fromBuffer(firstRecord.payload),
    );

    final recordsAfterFirst = acl.getRecords(
      handleId: handleId,
      spaceId: identity.spaceId,
    );
    final tailAfterRoot = acl.getRecords(
      handleId: handleId,
      spaceId: identity.spaceId,
      aclHead: root.id,
    );
    if (recordsAfterFirst.length != 2 ||
        recordsAfterFirst.first.id != root.id ||
        recordsAfterFirst.last.id != firstResponse.id) {
      throw StateError(
        'Later ACL read did not reflect the first consensus record',
      );
    }
    if (tailAfterRoot.length != 1 ||
        tailAfterRoot.single.id != firstResponse.id) {
      throw StateError(
        'Tail ACL read after root did not match the first record',
      );
    }

    if (stateOut != null && stateOut.isNotEmpty) {
      await writeJsonFile(
        stateOut,
        ConsensusFlowState(
          mnemonic: mnemonic,
          serverAddress: serverAddress,
          spaceId: identity.spaceId,
          rootId: root.id,
          firstRecordId: firstResponse.id,
        ).toJson(),
      );
    }

    return ConsensusBootstrapReport(
      capturedAt: DateTime.now().toUtc(),
      serverAddress: serverAddress,
      logId: identity.spaceId,
      spaceId: identity.spaceId,
      rootId: root.id,
      firstRecordId: firstResponse.id,
      recordIdsAfterFirst:
          recordsAfterFirst.map((record) => record.id).toList(),
      tailAfterRootIds: tailAfterRoot.map((record) => record.id).toList(),
      statePath: stateOut,
    );
  } finally {
    bridge.freeHandle(handleId);
  }
}

Future<ConsensusContinueReport> consensusContinueCommand({
  String? serverOverride,
  required String stateIn,
}) async {
  final state = ConsensusFlowState.fromJson(await readJsonFile(stateIn));
  final serverAddress = serverOverride ?? state.serverAddress;
  final identity = await Identity.fromMnemonic(state.mnemonic);
  final bridge = NativeBridge();
  final handleId =
      bridge.connect(serverAddress, identity.seed, identity.accountSeed);

  try {
    final consensus = ConsensusService(invoker: bridge.invoke);
    final acl = AclSyncService(invoker: bridge.invoke);

    final recordsBefore = acl.getRecords(
      handleId: handleId,
      spaceId: state.spaceId,
    );
    if (recordsBefore.map((record) => record.id).join(',') !=
        [state.rootId, state.firstRecordId].join(',')) {
      throw StateError(
        'Consensus reread before continue did not match persisted state',
      );
    }

    final secondRecord = await buildAclRecord(
      prevId: state.firstRecordId,
      aclData: AclData(
        aclContent: [
          AclContentValue(
            invite: AclAccountInvite(
              inviteKey: marshalEd25519PublicKey(
                Uint8List.fromList(List<int>.filled(32, 19)),
              ),
              permissions: AclUserPermissions.Writer,
            ),
          ),
        ],
      ),
      identityPrivateKey: identity.seed,
    );
    final secondResponse = consensus.recordAdd(
      handleId: handleId,
      logId: state.spaceId,
      record: RawRecord.fromBuffer(secondRecord.payload),
    );
    final recordsAfter = acl.getRecords(
      handleId: handleId,
      spaceId: state.spaceId,
    );
    final tailAfterFirst = acl.getRecords(
      handleId: handleId,
      spaceId: state.spaceId,
      aclHead: state.firstRecordId,
    );
    if (recordsAfter.length != 3 ||
        recordsAfter.last.id != secondResponse.id ||
        tailAfterFirst.length != 1 ||
        tailAfterFirst.single.id != secondResponse.id) {
      throw StateError('Consensus continuation did not match later ACL reads');
    }

    return ConsensusContinueReport(
      capturedAt: DateTime.now().toUtc(),
      serverAddress: serverAddress,
      stateIn: stateIn,
      logId: state.spaceId,
      spaceId: state.spaceId,
      rootId: state.rootId,
      firstRecordId: state.firstRecordId,
      secondRecordId: secondResponse.id,
      recordIdsBeforeContinue: recordsBefore.map((record) => record.id).toList(),
      recordIdsAfterContinue: recordsAfter.map((record) => record.id).toList(),
      tailAfterFirstIds: tailAfterFirst.map((record) => record.id).toList(),
    );
  } finally {
    bridge.freeHandle(handleId);
  }
}

/// Library-facing facade over the consensus bootstrap/continue diagnostic
/// flow, for consumers that hold a [ManytypeSession] instead of driving the
/// CLI directly. Exposed as `session.consensus`.
///
/// Like [AclLifecycleFacade], this doesn't touch [ManytypeSession.db]/
/// [ManytypeSession.config]: each call connects with its own ephemeral or
/// state-file-derived identity: but it's grouped under the session for a
/// consistent `session.<domain>.<verb>(...)` call shape.
class ConsensusFlowFacade {
  const ConsensusFlowFacade(this._session);

  // ignore: unused_field
  final ManytypeSession _session;

  Future<ConsensusBootstrapReport> bootstrap({
    required String serverAddress,
    String? stateOut,
  }) {
    return consensusBootstrapCommand(
      serverAddress: serverAddress,
      stateOut: stateOut,
    );
  }

  Future<ConsensusContinueReport> continueFlow({
    String? serverOverride,
    required String stateIn,
  }) {
    return consensusContinueCommand(
      serverOverride: serverOverride,
      stateIn: stateIn,
    );
  }
}
