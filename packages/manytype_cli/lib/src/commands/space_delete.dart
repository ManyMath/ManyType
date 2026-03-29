import 'dart:async';
import 'dart:convert';

import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/coordinator_service.dart';
import 'package:manytype_cli/src/ffi/native_bridge.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/network_config.dart';
import 'package:manytype_protocol/coordinator.dart';

const String kAcceptedSpaceDeleteTruthSurface = 'self-hosted-official';
const String kAcceptedSpaceDeleteProofMode = 'coordinator-status-reread';
const List<String> kAcceptedSpaceDeletePreconditions = <String>[
  'bounded owner space already seeded live on the self-hosted official stack',
  'the requested space must match the current Manytype owner space',
  'the coordinator status proof is based on status reread, not object-tree disappearance',
];
const List<String> kAcceptedSpaceDeleteObservations = <String>[
  'SpaceStatusCheck starts at SpaceStatusCreated',
  'the delete request returns a positive to_be_deleted_timestamp',
  'SpaceStatusCheck transitions to SpaceStatusPendingDeletion immediately after the request',
  'a fresh reconnect rereads SpaceStatusDeleted',
];

class SpaceDeleteAssessment {
  const SpaceDeleteAssessment({
    required this.outcome,
    required this.supported,
    required this.observedSurfaceLabel,
    required this.reason,
  });

  final String outcome;
  final bool supported;
  final String observedSurfaceLabel;
  final String reason;

  Map<String, Object?> toJson() => {
        'outcome': outcome,
        'supported': supported,
        'observed_surface_label': observedSurfaceLabel,
        'reason': reason,
      };
}

SpaceDeleteAssessment assessSpaceDeleteContract({
  required bool ownerSpaceMatches,
  required String? preStatus,
  required String? prePermissions,
  required bool responseOk,
  required String? responseError,
  required String? postStatus,
  required String? reconnectStatus,
}) {
  if (!ownerSpaceMatches) {
    return const SpaceDeleteAssessment(
      outcome: 'precondition-failed',
      supported: false,
      observedSurfaceLabel: 'precondition-failed',
      reason:
          'Bounded SpaceDelete only supports deleting the current Manytype owner space.',
    );
  }
  if (prePermissions != 'SpacePermissionsOwner') {
    return SpaceDeleteAssessment(
      outcome: 'precondition-failed',
      supported: false,
      observedSurfaceLabel: 'precondition-failed',
      reason:
          'Bounded SpaceDelete requires owner permissions, observed ${prePermissions ?? 'unknown'}.',
    );
  }
  if (preStatus != 'SpaceStatusCreated') {
    return SpaceDeleteAssessment(
      outcome: 'precondition-failed',
      supported: false,
      observedSurfaceLabel: 'precondition-failed',
      reason:
          'Bounded SpaceDelete requires a live created space before deletion, observed ${preStatus ?? 'unknown'}.',
    );
  }
  if (!responseOk) {
    return SpaceDeleteAssessment(
      outcome: 'unsupported-surface-or-scenario',
      supported: false,
      observedSurfaceLabel: 'unsupported-surface-or-scenario',
      reason:
          'SpaceDelete RPC did not complete successfully on the observed surface: ${responseError ?? 'unknown error'}.',
    );
  }
  if (postStatus == 'SpaceStatusPendingDeletion' &&
      reconnectStatus == 'SpaceStatusDeleted') {
    return const SpaceDeleteAssessment(
      outcome: 'supported-and-verified',
      supported: true,
      observedSurfaceLabel: 'accepted-space-delete-surface',
      reason:
          'Observed the accepted Created -> PendingDeletion -> Deleted contract through reconnect-backed coordinator status reread.',
    );
  }
  if (postStatus == 'SpaceStatusCreated' &&
      reconnectStatus == 'SpaceStatusCreated') {
    return const SpaceDeleteAssessment(
      outcome: 'unsupported-surface-or-scenario',
      supported: false,
      observedSurfaceLabel: 'stub-no-op-surface',
      reason:
          'The delete request returned, but status stayed Created before and after reconnect. This matches the unsupported stub/no-op surface rather than the accepted contract.',
    );
  }
  return SpaceDeleteAssessment(
    outcome: 'unsupported-surface-or-scenario',
    supported: false,
    observedSurfaceLabel: 'unsupported-surface-or-scenario',
    reason:
        'The accepted contract requires Created -> PendingDeletion -> Deleted via reconnect-backed coordinator status reread; observed '
        '${preStatus ?? 'unknown'} -> ${postStatus ?? 'unknown'} -> ${reconnectStatus ?? 'unknown'}.',
  );
}

Future<int> spaceDeleteCommand({
  required CliConfig config,
  required String networkConfigPath,
  String? requestedSpaceId,
  int waitSeconds = 6,
  int deletionDurationMinutes = 0,
  bool jsonOutput = false,
}) async {
  if (waitSeconds < 0) {
    throw StateError('--wait-seconds must be a non-negative integer');
  }
  if (deletionDurationMinutes < 0) {
    throw StateError(
      '--deletion-duration-minutes must be a non-negative integer',
    );
  }

  final identity = await Identity.fromMnemonic(config.mnemonic);
  final spaceId = requestedSpaceId ?? identity.spaceId;
  final networkConfig = await loadNetworkConfig(networkConfigPath);
  final coordinatorAddress =
      chooseBestAddress(requireCoordinatorNode(networkConfig).addresses);

  final initialCapture = await _captureInitialDelete(
    identity: identity,
    coordinatorAddress: coordinatorAddress,
    spaceId: spaceId,
    deletionDurationMinutes: deletionDurationMinutes,
    ownerSpaceMatches: spaceId == identity.spaceId,
  );

  if (waitSeconds > 0) {
    await Future<void>.delayed(Duration(seconds: waitSeconds));
  }

  final reconnectCapture = await _captureReconnectStatus(
    identity: identity,
    coordinatorAddress: coordinatorAddress,
    spaceId: spaceId,
  );

  final assessment = assessSpaceDeleteContract(
    ownerSpaceMatches: spaceId == identity.spaceId,
    preStatus: _statusName(initialCapture.preStatus),
    prePermissions: _permissionName(initialCapture.preStatus),
    responseOk: initialCapture.response.ok,
    responseError: initialCapture.response.error,
    postStatus: _statusName(initialCapture.postStatus),
    reconnectStatus: _statusName(reconnectCapture.status),
  );

  final report = <String, Object?>{
    'captured_at': DateTime.now().toUtc().toIso8601String(),
    'command': 'space-delete',
    'accepted_contract': {
      'truth_surface': kAcceptedSpaceDeleteTruthSurface,
      'proof_mode': kAcceptedSpaceDeleteProofMode,
      'supported_preconditions': kAcceptedSpaceDeletePreconditions,
      'required_observations': kAcceptedSpaceDeleteObservations,
    },
    'assessment': assessment.toJson(),
    'network_config_path': networkConfigPath,
    'coordinator_address': coordinatorAddress,
    'space_id': spaceId,
    'wait_seconds': waitSeconds,
    'deletion_duration_minutes': deletionDurationMinutes,
    'initial': initialCapture.toJson(),
    'after_reconnect': reconnectCapture.toJson(),
  };

  if (jsonOutput) {
    print(const JsonEncoder.withIndent('  ').convert(report));
  } else {
    _printHumanReport(report, assessment);
  }

  return assessment.supported ? 0 : 2;
}

class _InitialDeleteCapture {
  const _InitialDeleteCapture({
    required this.networkId,
    required this.networkConfigurationId,
    required this.request,
    required this.response,
    required this.preStatus,
    required this.postStatus,
  });

  final String networkId;
  final String networkConfigurationId;
  final Map<String, Object?>? request;
  final _CapturedResult<SpaceDeleteResponse> response;
  final _CapturedResult<SpaceStatusPayload> preStatus;
  final _CapturedResult<SpaceStatusPayload> postStatus;

  Map<String, Object?> toJson() => {
        'network_id': networkId,
        'network_configuration_id': networkConfigurationId,
        'request': request,
        'response': response.toJson(_spaceDeleteResponseToJson),
        'pre_status': preStatus.toJson(_spaceStatusToJson),
        'post_status': postStatus.toJson(_spaceStatusToJson),
      };
}

class _ReconnectCapture {
  const _ReconnectCapture({
    required this.networkId,
    required this.networkConfigurationId,
    required this.status,
  });

  final String networkId;
  final String networkConfigurationId;
  final _CapturedResult<SpaceStatusPayload> status;

  Map<String, Object?> toJson() => {
        'network_id': networkId,
        'network_configuration_id': networkConfigurationId,
        'status': status.toJson(_spaceStatusToJson),
      };
}

Future<_InitialDeleteCapture> _captureInitialDelete({
  required Identity identity,
  required String coordinatorAddress,
  required String spaceId,
  required int deletionDurationMinutes,
  required bool ownerSpaceMatches,
}) async {
  final bridge = NativeBridge();
  final handleId =
      bridge.connect(coordinatorAddress, identity.seed, identity.accountSeed);
  final coordinator = CoordinatorService(invoker: bridge.invoke);

  try {
    final networkConfiguration =
        coordinator.networkConfigurationForHandle(handleId);
    final preStatus = _capture(
      () => coordinator.spaceStatusCheck(
        handleId: handleId,
        spaceId: spaceId,
      ),
    );

    Map<String, Object?>? request;
    _CapturedResult<SpaceDeleteResponse> response;

    final canSendRequest =
        ownerSpaceMatches && _statusName(preStatus) == 'SpaceStatusCreated';
    if (canSendRequest) {
      final prepared = await coordinator.prepareSpaceDelete(
        spaceId: spaceId,
        identity: identity,
        networkId: networkConfiguration.networkId,
        deletionDurationMinutes: deletionDurationMinutes,
      );
      request = {
        'peer_id': prepared.peerId,
        'payload_id': prepared.payloadId,
        'payload_size_bytes': prepared.request.deletionPayload.length,
        'deletion_duration_minutes': prepared.request.deletionDuration.toInt(),
      };
      response = _capture(
        () => coordinator.sendSpaceDelete(
          handleId: handleId,
          request: prepared.request,
        ),
      );
    } else {
      response = _CapturedResult.failure(
        'SpaceDelete request skipped because bounded preconditions were not met.',
      );
    }

    final postStatus = _capture(
      () => coordinator.spaceStatusCheck(
        handleId: handleId,
        spaceId: spaceId,
      ),
    );

    return _InitialDeleteCapture(
      networkId: networkConfiguration.networkId,
      networkConfigurationId: networkConfiguration.configurationId,
      request: request,
      response: response,
      preStatus: preStatus,
      postStatus: postStatus,
    );
  } finally {
    bridge.freeHandle(handleId);
  }
}

Future<_ReconnectCapture> _captureReconnectStatus({
  required Identity identity,
  required String coordinatorAddress,
  required String spaceId,
}) async {
  final bridge = NativeBridge();
  final handleId =
      bridge.connect(coordinatorAddress, identity.seed, identity.accountSeed);
  final coordinator = CoordinatorService(invoker: bridge.invoke);

  try {
    final networkConfiguration =
        coordinator.networkConfigurationForHandle(handleId);
    final status = _capture(
      () => coordinator.spaceStatusCheck(
        handleId: handleId,
        spaceId: spaceId,
      ),
    );
    return _ReconnectCapture(
      networkId: networkConfiguration.networkId,
      networkConfigurationId: networkConfiguration.configurationId,
      status: status,
    );
  } finally {
    bridge.freeHandle(handleId);
  }
}

class _CapturedResult<T> {
  const _CapturedResult._({
    required this.value,
    required this.error,
  });

  const _CapturedResult.success(T this.value) : error = null;

  const _CapturedResult.failure(String this.error) : value = null;

  final T? value;
  final String? error;

  bool get ok => error == null;

  Map<String, Object?> toJson(
    Map<String, Object?> Function(T value) serializer,
  ) {
    if (ok && value != null) {
      return {
        'ok': true,
        'value': serializer(value as T),
      };
    }
    return {
      'ok': false,
      'error': error,
    };
  }
}

_CapturedResult<T> _capture<T>(T Function() fn) {
  try {
    return _CapturedResult.success(fn());
  } catch (error) {
    return _CapturedResult.failure(error.toString());
  }
}

String? _statusName(_CapturedResult<SpaceStatusPayload> result) {
  final value = result.value;
  if (result.ok && value != null) {
    return value.status.name;
  }
  return null;
}

String? _permissionName(_CapturedResult<SpaceStatusPayload> result) {
  final value = result.value;
  if (result.ok && value != null) {
    return value.permissions.name;
  }
  return null;
}

Map<String, Object?> _spaceDeleteResponseToJson(SpaceDeleteResponse response) =>
    {
      'to_be_deleted_timestamp': response.toBeDeletedTimestamp.toInt(),
    };

Map<String, Object?> _spaceStatusToJson(SpaceStatusPayload payload) => {
      'status': payload.status.name,
      'deletion_timestamp': payload.deletionTimestamp.toInt(),
      'permissions': payload.permissions.name,
      'is_shared': payload.isShared,
      'limits': payload.hasLimits()
          ? {
              'read_members': payload.limits.readMembers,
              'write_members': payload.limits.writeMembers,
            }
          : null,
    };

void _printHumanReport(
  Map<String, Object?> report,
  SpaceDeleteAssessment assessment,
) {
  final initial = report['initial'] as Map<String, Object?>;
  final reconnect = report['after_reconnect'] as Map<String, Object?>;
  final initialPre =
      _statusLabel(initial['pre_status'] as Map<String, Object?>);
  final initialPost =
      _statusLabel(initial['post_status'] as Map<String, Object?>);
  final reconnectStatus =
      _statusLabel(reconnect['status'] as Map<String, Object?>);

  print('Command: space-delete');
  print('Space: ${report['space_id']}');
  print('Accepted truth surface: $kAcceptedSpaceDeleteTruthSurface');
  print('Proof mode: $kAcceptedSpaceDeleteProofMode');
  print(
      'Observed status path: $initialPre -> $initialPost -> $reconnectStatus');
  print('Outcome: ${assessment.outcome}');
  print('Reason: ${assessment.reason}');
}

String _statusLabel(Map<String, Object?> statusResult) {
  if (statusResult['ok'] != true) {
    return 'error';
  }
  final value = statusResult['value'];
  if (value is Map<String, Object?>) {
    return value['status'] as String? ?? 'unknown';
  }
  if (value is Map) {
    return value['status']?.toString() ?? 'unknown';
  }
  return 'unknown';
}
