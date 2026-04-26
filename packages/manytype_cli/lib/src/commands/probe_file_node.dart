import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:manytype_protocol/coordinator.dart';
import 'package:manytype_protocol/filesync.dart';

import '../config.dart';
import '../ffi/native_bridge.dart';
import '../identity.dart';
import '../network_config.dart';
import '../session.dart';

/// Outcome of a single RPC attempted against the resolved file node.
class FileNodeProbeAttempt {
  const FileNodeProbeAttempt({
    required this.method,
    required this.success,
    this.error,
  });

  final String method;
  final bool success;
  final String? error;
}

/// Result of resolving and probing a FileAPI node via [probeFileNodeCommand].
class FileNodeProbeResult {
  const FileNodeProbeResult({
    required this.coordinatorAddress,
    required this.fileAddress,
    required this.networkId,
    required this.configurationId,
    required this.nodeCount,
    required this.readOnly,
    required this.attempts,
  });

  final String coordinatorAddress;
  final String fileAddress;
  final String networkId;
  final String configurationId;
  final int nodeCount;
  final bool readOnly;
  final List<FileNodeProbeAttempt> attempts;
}

/// Connect to a coordinator, resolve the FileAPI node, and attempt a narrow
/// set of file RPCs against it.
///
/// This is intentionally a contract/probe command, not a full upload/download
/// workflow. It verifies that FileAPI discovery works and that the CLI can
/// route file RPCs to the selected file node while recording a reusable
/// artifact for later interop phases.
Future<FileNodeProbeResult> probeFileNodeCommand(
  CliConfig config, {
  String? networkConfigPath,
  String? networkConfigContent,
  bool readOnly = false,
}) async {
  final networkConfig = await resolveNetworkConfig(
    networkConfigPath: networkConfigPath,
    networkConfigContent: networkConfigContent,
  );
  final coordinatorAddress =
      chooseBestAddress(requireCoordinatorNode(networkConfig).addresses);
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final bridge = NativeBridge();
  final capture = _FileProbeCapture.start(readOnly: readOnly);
  final attempts = <FileNodeProbeAttempt>[];

  final coordinatorHandleId =
      bridge.connect(coordinatorAddress, identity.seed, identity.accountSeed);
  capture.recordConnection(role: 'coordinator', address: coordinatorAddress);

  try {
    final requestBytes =
        Uint8List.fromList(NetworkConfigurationRequest().writeToBuffer());
    final responseBytes = bridge.invoke(
      coordinatorHandleId,
      '/coordinator.Coordinator/NetworkConfiguration',
      requestBytes,
    );
    capture.recordUnaryRpc(
      role: 'coordinator',
      method: '/coordinator.Coordinator/NetworkConfiguration',
      requestBytes: requestBytes,
      responseBytes: responseBytes,
    );
    final response = NetworkConfigurationResponse.fromBuffer(responseBytes);

    final fileAddress = chooseFileAddressFromResponse(response.nodes) ??
        chooseBestAddress(requireFileNode(networkConfig).addresses);
    capture.recordNote('probe_mode', {'read_only': readOnly});
    capture.recordNote('resolved_file_node', {
      'network_id': response.networkId,
      'configuration_id': response.configurationId,
      'file_address': fileAddress,
      'node_count': response.nodes.length,
    });

    final fileHandleId =
        bridge.connect(fileAddress, identity.seed, identity.accountSeed);
    capture.recordConnection(role: 'file-node', address: fileAddress);

    try {
      attempts.add(await _attemptProbe(
        bridge: bridge,
        capture: capture,
        handleId: fileHandleId,
        role: 'file-node',
        method: '/filesync.File/Check',
        requestBytes: Uint8List.fromList(CheckRequest().writeToBuffer()),
      ));
      attempts.add(await _attemptProbe(
        bridge: bridge,
        capture: capture,
        handleId: fileHandleId,
        role: 'file-node',
        method: '/filesync.File/BlocksCheck',
        requestBytes: Uint8List.fromList(
          BlocksCheckRequest(
            spaceId: identity.spaceId,
            cids: [
              Uint8List.fromList(const [1, 2, 3, 4])
            ],
          ).writeToBuffer(),
        ),
      ));
      attempts.add(await _attemptProbe(
        bridge: bridge,
        capture: capture,
        handleId: fileHandleId,
        role: 'file-node',
        method: '/filesync.File/BlockGet',
        requestBytes: Uint8List.fromList(
          BlockGetRequest(
            spaceId: identity.spaceId,
            cid: Uint8List.fromList(const [1, 2, 3, 4]),
            wait: false,
          ).writeToBuffer(),
        ),
      ));
      if (!readOnly) {
        attempts.add(await _attemptProbe(
          bridge: bridge,
          capture: capture,
          handleId: fileHandleId,
          role: 'file-node',
          method: '/filesync.File/BlockPush',
          requestBytes: Uint8List.fromList(
            BlockPushRequest(
              spaceId: identity.spaceId,
              fileId: 'phase21-contract-freeze-probe',
              cid: Uint8List.fromList(const [1, 2, 3, 4]),
              data: Uint8List.fromList('phase-21-probe'.codeUnits),
            ).writeToBuffer(),
          ),
        ));
      }
    } finally {
      bridge.freeHandle(fileHandleId);
    }

    return FileNodeProbeResult(
      coordinatorAddress: coordinatorAddress,
      fileAddress: fileAddress,
      networkId: response.networkId,
      configurationId: response.configurationId,
      nodeCount: response.nodes.length,
      readOnly: readOnly,
      attempts: attempts,
    );
  } finally {
    bridge.freeHandle(coordinatorHandleId);
    await capture.flush();
  }
}

/// Library-facing facade over FileAPI node probing, for consumers that hold
/// a [ManytypeSession] instead of driving the CLI directly. Exposed as
/// `session.probeFileNode`.
class ProbeFileNodeFacade {
  const ProbeFileNodeFacade(this._session);

  final ManytypeSession _session;

  Future<FileNodeProbeResult> probe({
    String? networkConfigPath,
    String? networkConfigContent,
    bool readOnly = false,
  }) {
    return probeFileNodeCommand(
      _session.config,
      networkConfigPath: networkConfigPath,
      networkConfigContent: networkConfigContent,
      readOnly: readOnly,
    );
  }
}

Future<FileNodeProbeAttempt> _attemptProbe({
  required NativeBridge bridge,
  required _FileProbeCapture capture,
  required int handleId,
  required String role,
  required String method,
  required Uint8List requestBytes,
}) async {
  try {
    final responseBytes = bridge.invoke(handleId, method, requestBytes);
    capture.recordUnaryRpc(
      role: role,
      method: method,
      requestBytes: requestBytes,
      responseBytes: responseBytes,
    );
    return FileNodeProbeAttempt(method: method, success: true);
  } catch (error) {
    capture.recordRpcError(
      role: role,
      method: method,
      requestBytes: requestBytes,
      error: error.toString(),
    );
    return FileNodeProbeAttempt(
      method: method,
      success: false,
      error: error.toString(),
    );
  }
}

class _FileProbeCapture {
  _FileProbeCapture._({required this.path, required bool readOnly})
      : _payload = {
          'captured_at': DateTime.now().toUtc().toIso8601String(),
          'read_only': readOnly,
          'events': <Map<String, Object?>>[],
        };

  final String? path;
  final Map<String, Object?> _payload;

  static _FileProbeCapture start({required bool readOnly}) {
    return _FileProbeCapture._(
      path: Platform.environment['MANYTYPE_FILE_CAPTURE_PATH'] ??
          Platform.environment['MANYTYPE_SYNC_CAPTURE_PATH'],
      readOnly: readOnly,
    );
  }

  bool get _enabled => path != null && path!.isNotEmpty;

  List<Map<String, Object?>> get _events =>
      _payload['events']! as List<Map<String, Object?>>;

  void recordConnection({required String role, required String address}) {
    recordNote('connection', {'role': role, 'address': address});
  }

  void recordUnaryRpc({
    required String role,
    required String method,
    required Uint8List requestBytes,
    required Uint8List responseBytes,
  }) {
    if (!_enabled) return;
    _events.add({
      'type': 'unary_rpc',
      'role': role,
      'method': method,
      'request_len': requestBytes.length,
      'response_len': responseBytes.length,
      'request_base64': base64Encode(requestBytes),
      'response_base64': base64Encode(responseBytes),
    });
  }

  void recordRpcError({
    required String role,
    required String method,
    required Uint8List requestBytes,
    required String error,
  }) {
    if (!_enabled) return;
    _events.add({
      'type': 'rpc_error',
      'role': role,
      'method': method,
      'request_len': requestBytes.length,
      'request_base64': base64Encode(requestBytes),
      'error': error,
    });
  }

  void recordNote(String type, Map<String, Object?> details) {
    if (!_enabled) return;
    _events.add({'type': type, ...details});
  }

  Future<void> flush() async {
    if (!_enabled) return;
    final file = File(path!);
    await file.parent.create(recursive: true);
    await file.writeAsString(
      '${const JsonEncoder.withIndent('  ').convert(_payload)}\n',
    );
  }
}
