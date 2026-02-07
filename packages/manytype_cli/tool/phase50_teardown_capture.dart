import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/coordinator_service.dart';
import 'package:manytype_cli/src/ffi/native_bridge.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/network_config.dart';
import 'package:manytype_protocol/coordinator.dart';

Future<void> main(List<String> argv) async {
  final parser = ArgParser()
    ..addOption('action', mandatory: true)
    ..addOption('surface', mandatory: true)
    ..addOption('network-config')
    ..addOption('server-address', defaultsTo: '127.0.0.1:33020')
    ..addOption('space-id')
    ..addOption('wait-seconds', defaultsTo: '8')
    ..addOption('deletion-duration-minutes', defaultsTo: '0');
  final args = parser.parse(argv);

  final action = args['action'] as String;
  final surface = args['surface'] as String;
  final networkConfigPath = args['network-config'] as String?;
  final serverAddress = args['server-address'] as String;
  final requestedSpaceId = args['space-id'] as String?;
  final waitSeconds = int.parse(args['wait-seconds'] as String);
  final deletionDurationMinutes =
      int.parse(args['deletion-duration-minutes'] as String);

  if (action != 'space-delete' && action != 'account-delete') {
    throw StateError('Unsupported --action: $action');
  }

  final config = await CliConfig.load();
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final coordinatorAddress = await _resolveCoordinatorAddress(
    networkConfigPath: networkConfigPath,
    serverAddress: serverAddress,
  );
  final observedSpaceId = requestedSpaceId ?? identity.spaceId;

  final firstCapture = await _capture(
    action: action,
    surface: surface,
    identity: identity,
    coordinatorAddress: coordinatorAddress,
    networkConfigPath: networkConfigPath,
    observedSpaceId: observedSpaceId,
    deletionDurationMinutes: deletionDurationMinutes,
    executeDelete: true,
  );

  await Future<void>.delayed(Duration(seconds: waitSeconds));

  final secondCapture = await _capture(
    action: action,
    surface: surface,
    identity: identity,
    coordinatorAddress: coordinatorAddress,
    networkConfigPath: networkConfigPath,
    observedSpaceId: observedSpaceId,
    deletionDurationMinutes: deletionDurationMinutes,
    executeDelete: false,
  );

  stdout.writeln(
    const JsonEncoder.withIndent('  ').convert({
      'captured_at': DateTime.now().toUtc().toIso8601String(),
      'action': action,
      'surface': surface,
      'network_config_path': networkConfigPath,
      'coordinator_address': coordinatorAddress,
      'space_id': observedSpaceId,
      'wait_seconds': waitSeconds,
      'deletion_duration_minutes': deletionDurationMinutes,
      'initial': firstCapture,
      'after_reconnect': secondCapture,
    }),
  );
}

Future<Map<String, Object?>> _capture({
  required String action,
  required String surface,
  required Identity identity,
  required String coordinatorAddress,
  required String? networkConfigPath,
  required String observedSpaceId,
  required int deletionDurationMinutes,
  required bool executeDelete,
}) async {
  final bridge = NativeBridge();
  final handleId =
      bridge.connect(coordinatorAddress, identity.seed, identity.accountSeed);
  final coordinator = CoordinatorService(invoker: bridge.invoke);

  try {
    final networkConfiguration =
        coordinator.networkConfigurationForHandle(handleId);
    final networkId = networkConfiguration.networkId;

    final preStatus = _captureMap(
        () => coordinator.spaceStatusCheck(
              handleId: handleId,
              spaceId: observedSpaceId,
            ),
        _spaceStatusToJson);
    final preDeletionLog = _captureMap(
      () => coordinator.deletionLog(handleId: handleId),
      _deletionLogToJson,
    );

    Map<String, Object?>? requestDetails;
    Map<String, Object?>? responseDetails;

    if (executeDelete) {
      if (action == 'space-delete') {
        final prepared = await coordinator.prepareSpaceDelete(
          spaceId: observedSpaceId,
          identity: identity,
          networkId: networkId,
          deletionDurationMinutes: deletionDurationMinutes,
        );
        requestDetails = {
          'peer_id': prepared.peerId,
          'payload_id': prepared.payloadId,
          'payload_size_bytes': prepared.request.deletionPayload.length,
          'deletion_duration_minutes':
              prepared.request.deletionDuration.toInt(),
        };
        responseDetails = _captureMap(
          () => coordinator.sendSpaceDelete(
            handleId: handleId,
            request: prepared.request,
          ),
          (response) => {
            'to_be_deleted_timestamp': response.toBeDeletedTimestamp.toInt(),
          },
        );
      } else {
        final prepared = await coordinator.prepareAccountDelete(
          identity: identity,
          networkId: networkId,
        );
        requestDetails = {
          'peer_id': prepared.peerId,
          'payload_id': prepared.payloadId,
          'payload_size_bytes': prepared.request.deletionPayload.length,
        };
        responseDetails = _captureMap(
          () => coordinator.sendAccountDelete(
            handleId: handleId,
            request: prepared.request,
          ),
          (response) => {
            'to_be_deleted_timestamp': response.toBeDeletedTimestamp.toInt(),
          },
        );
      }
    }

    final postStatus = _captureMap(
        () => coordinator.spaceStatusCheck(
              handleId: handleId,
              spaceId: observedSpaceId,
            ),
        _spaceStatusToJson);
    final postDeletionLog = _captureMap(
      () => coordinator.deletionLog(handleId: handleId),
      _deletionLogToJson,
    );

    return {
      'surface': surface,
      'network_id': networkId,
      'network_configuration_id': networkConfiguration.configurationId,
      'request': requestDetails,
      'response': responseDetails,
      'pre_status': preStatus,
      'pre_deletion_log': preDeletionLog,
      'post_status': postStatus,
      'post_deletion_log': postDeletionLog,
    };
  } finally {
    bridge.freeHandle(handleId);
  }
}

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

Map<String, Object?> _deletionLogToJson(List<DeletionLogRecord> records) => {
      'count': records.length,
      'records': records
          .map(
            (record) => {
              'id': record.id,
              'space_id': record.spaceId,
              'status': record.status.name,
              'timestamp': record.timestamp.toInt(),
              'file_group': record.fileGroup,
            },
          )
          .toList(growable: false),
    };

Map<String, Object?> _captureMap<T>(
  T Function() fn,
  Map<String, Object?> Function(T value) toJson,
) {
  try {
    return {
      'ok': true,
      'value': toJson(fn()),
    };
  } catch (error) {
    return {
      'ok': false,
      'error': error.toString(),
    };
  }
}

Future<String> _resolveCoordinatorAddress({
  required String? networkConfigPath,
  required String serverAddress,
}) async {
  if (networkConfigPath == null || networkConfigPath.isEmpty) {
    return serverAddress;
  }
  final config = await loadNetworkConfig(networkConfigPath);
  return chooseBestAddress(requireCoordinatorNode(config).addresses);
}
