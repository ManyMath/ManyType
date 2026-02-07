import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:manytype_cli/src/acl_sync_service.dart';
import 'package:manytype_cli/src/consensus_service.dart';
import 'package:manytype_cli/src/ffi/native_bridge.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/operator_flow_support.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/manytype_protocol.dart';

const String kConsensusBackendLabel = 'manytype_server';
const List<String> kConsensusBackendRequirements = <String>[
  'requires a reachable manytype_server coordinator and consensus surface via --server',
  'continuation requires the state JSON written by consensus-bootstrap',
];

Future<int> consensusBootstrapCommand({
  required String serverAddress,
  String? stateOut,
  bool jsonOutput = false,
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

    final report = <String, Object?>{
      'captured_at': DateTime.now().toUtc().toIso8601String(),
      'command': 'consensus-bootstrap',
      'backend_label': kConsensusBackendLabel,
      'backend_requirements': kConsensusBackendRequirements,
      'server_address': serverAddress,
      'log_id': identity.spaceId,
      'space_id': identity.spaceId,
      'root_id': root.id,
      'first_record_id': firstResponse.id,
      'record_ids_after_first':
          recordsAfterFirst.map((record) => record.id).toList(),
      'tail_after_root_ids': tailAfterRoot.map((record) => record.id).toList(),
      'state_path': stateOut,
    };

    if (jsonOutput) {
      stdout.writeln(const JsonEncoder.withIndent('  ').convert(report));
    } else {
      stdout.writeln('Command: consensus-bootstrap');
      stdout.writeln('Backend: $kConsensusBackendLabel');
      stdout.writeln('Log: ${identity.spaceId}');
      stdout.writeln('Root: ${root.id}');
      stdout.writeln('First record: ${firstResponse.id}');
      if (stateOut != null && stateOut.isNotEmpty) {
        stdout.writeln('State: $stateOut');
      }
    }

    return 0;
  } finally {
    bridge.freeHandle(handleId);
  }
}

Future<int> consensusContinueCommand({
  String? serverOverride,
  required String stateIn,
  bool jsonOutput = false,
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

    final report = <String, Object?>{
      'captured_at': DateTime.now().toUtc().toIso8601String(),
      'command': 'consensus-continue',
      'backend_label': kConsensusBackendLabel,
      'backend_requirements': kConsensusBackendRequirements,
      'server_address': serverAddress,
      'state_in': stateIn,
      'log_id': state.spaceId,
      'space_id': state.spaceId,
      'root_id': state.rootId,
      'first_record_id': state.firstRecordId,
      'second_record_id': secondResponse.id,
      'record_ids_before_continue':
          recordsBefore.map((record) => record.id).toList(),
      'record_ids_after_continue':
          recordsAfter.map((record) => record.id).toList(),
      'tail_after_first_ids':
          tailAfterFirst.map((record) => record.id).toList(),
    };

    if (jsonOutput) {
      stdout.writeln(const JsonEncoder.withIndent('  ').convert(report));
    } else {
      stdout.writeln('Command: consensus-continue');
      stdout.writeln('Backend: $kConsensusBackendLabel');
      stdout.writeln('Log: ${state.spaceId}');
      stdout.writeln('Second record: ${secondResponse.id}');
    }

    return 0;
  } finally {
    bridge.freeHandle(handleId);
  }
}
