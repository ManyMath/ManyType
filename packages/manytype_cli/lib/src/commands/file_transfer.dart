import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/coordinator.dart';
import 'package:manytype_protocol/filesync.dart' as filesync;

import '../config.dart';
import '../ffi/native_bridge.dart';
import '../identity.dart';
import '../network_config.dart';
import '../session.dart';
import '../store/database.dart';
import 'sync.dart' show seedLiveSpaceForSync;

typedef FileUnaryInvoker = Uint8List Function(
  int handleId,
  String method,
  Uint8List payload,
);

class UploadedBlobResult {
  const UploadedBlobResult({
    required this.cid,
    required this.uploaded,
  });

  final String cid;
  final bool uploaded;
}

class OpenedBlobResult {
  const OpenedBlobResult({
    required this.bytes,
    required this.fromCache,
  });

  final Uint8List bytes;
  final bool fromCache;
}

class OpenedFileResult {
  const OpenedFileResult({
    required this.outputPath,
    required this.cid,
    required this.fromCache,
  });

  final String outputPath;
  final String cid;
  final bool fromCache;
}

Future<UploadedBlobResult> uploadBlobWithNetworkConfig(
  ManytypeDatabase db,
  CliConfig config, {
  String? networkConfigPath,
  String? networkConfigContent,
  required Identity identity,
  required String fileId,
  required Uint8List bytes,
}) async {
  final capture = _FileTransferCapture.start();
  final bridge = NativeBridge();
  await seedLiveSpaceForSync(
    db,
    config,
    networkConfigPath: networkConfigPath,
    networkConfigContent: networkConfigContent,
  );
  final fileHandleId = await _connectToFileNode(
    bridge: bridge,
    config: config,
    networkConfigPath: networkConfigPath,
    networkConfigContent: networkConfigContent,
    identity: identity,
    capture: capture,
  );

  try {
    return await uploadBlobToFileNode(
      fileHandleId: fileHandleId,
      invoke: bridge.invoke,
      spaceId: identity.spaceId,
      fileId: fileId,
      bytes: bytes,
      capture: capture,
    );
  } finally {
    bridge.freeHandle(fileHandleId);
    await capture.flush();
  }
}

Future<UploadedBlobResult> fileUploadCommand(
  ManytypeDatabase db,
  CliConfig config, {
  required String networkConfigPath,
  required String fileId,
  required String sourcePath,
}) async {
  final sourceFile = File(sourcePath);
  if (!await sourceFile.exists()) {
    throw StateError('Source file not found: $sourcePath');
  }

  final identity = await Identity.fromMnemonic(config.mnemonic);
  final bytes = await sourceFile.readAsBytes();
  return uploadBlobWithNetworkConfig(
    db,
    config,
    networkConfigPath: networkConfigPath,
    identity: identity,
    fileId: fileId,
    bytes: bytes,
  );
}

Future<OpenedFileResult> fileOpenCommand(
  ManytypeDatabase db,
  CliConfig config, {
  String? networkConfigPath,
  String? networkConfigContent,
  required String fileId,
  String? cid,
  String? outputPath,
}) async {
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final resolvedCid =
      cid ?? await _resolveStoredCid(db, identity.spaceId, fileId);
  if (resolvedCid == null || resolvedCid.isEmpty) {
    throw StateError(
      'No CID available for $fileId. Pass --cid or sync attachment metadata first.',
    );
  }

  final result = await openBlobWithNetworkConfig(
    db,
    config,
    networkConfigPath: networkConfigPath,
    networkConfigContent: networkConfigContent,
    identity: identity,
    fileId: fileId,
    cid: resolvedCid,
  );
  final destinationPath =
      outputPath ?? CliConfig.downloadPath(fileId, resolvedCid);
  final outputFile = File(destinationPath);
  await outputFile.parent.create(recursive: true);
  await outputFile.writeAsBytes(result.bytes, flush: true);
  return OpenedFileResult(
    outputPath: outputFile.path,
    cid: resolvedCid,
    fromCache: result.fromCache,
  );
}

/// Opens a blob by CID, connecting to the file node only on a cache miss.
///
/// Used by both [fileOpenCommand] (which additionally resolves a CID from
/// stored attachment refs and writes the bytes to a path) and
/// [FileTransferFacade.open] (which takes bytes as-is, for callers with no
/// filesystem).
Future<OpenedBlobResult> openBlobWithNetworkConfig(
  ManytypeDatabase db,
  CliConfig config, {
  String? networkConfigPath,
  String? networkConfigContent,
  required Identity identity,
  required String fileId,
  required String cid,
}) async {
  final capture = _FileTransferCapture.start();
  final cached = await db.getCachedBlob(
    spaceId: identity.spaceId,
    fileId: fileId,
    cid: cid,
  );

  NativeBridge? bridge;
  int? fileHandleId;
  try {
    if (cached == null) {
      await seedLiveSpaceForSync(
        db,
        config,
        networkConfigPath: networkConfigPath,
        networkConfigContent: networkConfigContent,
      );
      bridge = NativeBridge();
      fileHandleId = await _connectToFileNode(
        bridge: bridge,
        config: config,
        networkConfigPath: networkConfigPath,
        networkConfigContent: networkConfigContent,
        identity: identity,
        capture: capture,
      );
    }

    return await openBlobFromFileNode(
      db: db,
      fileHandleId: fileHandleId,
      invoke: bridge?.invoke,
      spaceId: identity.spaceId,
      fileId: fileId,
      cid: cid,
      capture: capture,
    );
  } finally {
    if (fileHandleId != null && bridge != null) {
      bridge.freeHandle(fileHandleId);
    }
    await capture.flush();
  }
}

/// Library-facing facade over file upload/download, for consumers that
/// hold a [ManytypeSession] instead of driving the CLI directly. Bytes in,
/// bytes out: no filesystem path assumed, so it also works on web.
class FileTransferFacade {
  const FileTransferFacade(this._session);

  final ManytypeSession _session;

  Future<UploadedBlobResult> upload({
    String? networkConfigPath,
    String? networkConfigContent,
    required String fileId,
    required Uint8List bytes,
  }) {
    return uploadBlobWithNetworkConfig(
      _session.db,
      _session.config,
      networkConfigPath: networkConfigPath,
      networkConfigContent: networkConfigContent,
      identity: _session.identity,
      fileId: fileId,
      bytes: bytes,
    );
  }

  Future<OpenedBlobResult> open({
    String? networkConfigPath,
    String? networkConfigContent,
    required String fileId,
    String? cid,
  }) async {
    final resolvedCid = cid ??
        await _resolveStoredCid(_session.db, _session.identity.spaceId, fileId);
    if (resolvedCid == null || resolvedCid.isEmpty) {
      throw StateError(
        'No CID available for $fileId. Pass an explicit cid or sync attachment '
        'metadata first.',
      );
    }
    return openBlobWithNetworkConfig(
      _session.db,
      _session.config,
      networkConfigPath: networkConfigPath,
      networkConfigContent: networkConfigContent,
      identity: _session.identity,
      fileId: fileId,
      cid: resolvedCid,
    );
  }
}

Future<UploadedBlobResult> uploadBlobToFileNode({
  required int fileHandleId,
  required FileUnaryInvoker invoke,
  required String spaceId,
  required String fileId,
  required Uint8List bytes,
  _FileTransferCapture? capture,
}) async {
  final cid = await computeCid(bytes);
  final cidBytes = cidToBytes(cid);
  final checkRequest = filesync.BlocksCheckRequest(
    spaceId: spaceId,
    cids: [cidBytes],
  );
  final checkRequestBytes = Uint8List.fromList(checkRequest.writeToBuffer());
  final checkResponseBytes = invoke(
    fileHandleId,
    '/filesync.File/BlocksCheck',
    checkRequestBytes,
  );
  capture?.recordUnaryRpc(
    role: 'file-node',
    method: '/filesync.File/BlocksCheck',
    requestBytes: checkRequestBytes,
    responseBytes: checkResponseBytes,
  );
  final checkResponse =
      filesync.BlocksCheckResponse.fromBuffer(checkResponseBytes);
  final availability = checkResponse.blocksAvailability
      .where((entry) => _byteListsEqual(entry.cid, cidBytes))
      .map((entry) => entry.status)
      .firstWhere(
        (_) => true,
        orElse: () => filesync.AvailabilityStatus.NotExists,
      );

  var uploaded = false;
  switch (availability) {
    case filesync.AvailabilityStatus.NotExists:
      final pushRequest = filesync.BlockPushRequest(
        spaceId: spaceId,
        fileId: fileId,
        cid: cidBytes,
        data: bytes,
      );
      final pushRequestBytes = Uint8List.fromList(pushRequest.writeToBuffer());
      final pushResponseBytes = invoke(
        fileHandleId,
        '/filesync.File/BlockPush',
        pushRequestBytes,
      );
      capture?.recordUnaryRpc(
        role: 'file-node',
        method: '/filesync.File/BlockPush',
        requestBytes: pushRequestBytes,
        responseBytes: pushResponseBytes,
      );
      uploaded = true;
      break;
    case filesync.AvailabilityStatus.Exists:
      final bindRequest = filesync.BlocksBindRequest(
        spaceId: spaceId,
        fileId: fileId,
        cids: [cidBytes],
      );
      final bindRequestBytes = Uint8List.fromList(bindRequest.writeToBuffer());
      final bindResponseBytes = invoke(
        fileHandleId,
        '/filesync.File/BlocksBind',
        bindRequestBytes,
      );
      capture?.recordUnaryRpc(
        role: 'file-node',
        method: '/filesync.File/BlocksBind',
        requestBytes: bindRequestBytes,
        responseBytes: bindResponseBytes,
      );
      break;
    case filesync.AvailabilityStatus.ExistsInSpace:
      break;
  }

  capture?.recordNote(
    'upload_result',
    {
      'file_id': fileId,
      'cid': cid,
      'uploaded': uploaded,
      'availability': availability.name,
    },
  );
  return UploadedBlobResult(cid: cid, uploaded: uploaded);
}

Future<OpenedBlobResult> openBlobFromFileNode({
  required ManytypeDatabase db,
  required String spaceId,
  required String fileId,
  required String cid,
  int? fileHandleId,
  FileUnaryInvoker? invoke,
  _FileTransferCapture? capture,
}) async {
  final cached = await db.getCachedBlob(
    spaceId: spaceId,
    fileId: fileId,
    cid: cid,
  );
  if (cached != null) {
    capture?.recordNote(
      'cache_hit',
      {'file_id': fileId, 'cid': cid, 'bytes': cached.bytes.length},
    );
    return OpenedBlobResult(bytes: cached.bytes, fromCache: true);
  }

  if (fileHandleId == null || invoke == null) {
    throw StateError('A file-node connection is required for cache misses');
  }

  capture?.recordNote('cache_miss', {'file_id': fileId, 'cid': cid});
  final request = filesync.BlockGetRequest(
    spaceId: spaceId,
    cid: cidToBytes(cid),
    wait: false,
  );
  final requestBytes = Uint8List.fromList(request.writeToBuffer());
  final responseBytes =
      invoke(fileHandleId, '/filesync.File/BlockGet', requestBytes);
  capture?.recordUnaryRpc(
    role: 'file-node',
    method: '/filesync.File/BlockGet',
    requestBytes: requestBytes,
    responseBytes: responseBytes,
  );
  final response = filesync.BlockGetResponse.fromBuffer(responseBytes);
  final blobBytes = Uint8List.fromList(response.data);
  await db.cacheBlob(
    spaceId: spaceId,
    fileId: fileId,
    cid: cid,
    bytes: blobBytes,
  );
  return OpenedBlobResult(bytes: blobBytes, fromCache: false);
}

Future<int> _connectToFileNode({
  required NativeBridge bridge,
  required CliConfig config,
  String? networkConfigPath,
  String? networkConfigContent,
  required Identity identity,
  required _FileTransferCapture capture,
}) async {
  final networkConfig = await resolveNetworkConfig(
    networkConfigPath: networkConfigPath,
    networkConfigContent: networkConfigContent,
  );
  final coordinatorAddress =
      chooseBestAddress(requireCoordinatorNode(networkConfig).addresses);
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
    capture.recordNote(
      'resolved_file_node',
      {
        'network_id': response.networkId,
        'configuration_id': response.configurationId,
        'file_address': fileAddress,
      },
    );

    final fileHandleId =
        bridge.connect(fileAddress, identity.seed, identity.accountSeed);
    capture.recordConnection(role: 'file-node', address: fileAddress);
    return fileHandleId;
  } finally {
    bridge.freeHandle(coordinatorHandleId);
  }
}

Future<String?> _resolveStoredCid(
  ManytypeDatabase db,
  String spaceId,
  String fileId,
) async {
  final refs = await db.getAttachmentRefsByFileId(spaceId, fileId);
  final cids = refs
      .map((entry) => entry.cid)
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList(growable: false);
  if (cids.isEmpty) {
    return null;
  }
  if (cids.length > 1) {
    throw StateError('Multiple CIDs known for $fileId. Pass --cid explicitly.');
  }
  return cids.single;
}

bool _byteListsEqual(List<int> left, List<int> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) {
      return false;
    }
  }
  return true;
}

class _FileTransferCapture {
  _FileTransferCapture._({
    required this.path,
    required Map<String, Object?> payload,
  }) : _payload = payload;

  final String? path;
  final Map<String, Object?> _payload;

  static _FileTransferCapture start() {
    final path = Platform.environment['MANYTYPE_FILE_TRANSFER_CAPTURE_PATH'] ??
        Platform.environment['MANYTYPE_FILE_CAPTURE_PATH'];
    final payload = <String, Object?>{
      'captured_at': DateTime.now().toUtc().toIso8601String(),
      'events': <Map<String, Object?>>[],
    };
    if (path != null && path.isNotEmpty) {
      final existing = File(path);
      if (existing.existsSync()) {
        try {
          final decoded = jsonDecode(existing.readAsStringSync());
          if (decoded is Map<String, Object?>) {
            payload
              ..clear()
              ..addAll(decoded);
            final events = decoded['events'];
            if (events is List) {
              payload['events'] = events
                  .whereType<Map>()
                  .map(
                    (event) => event.map(
                      (key, value) => MapEntry(key.toString(), value),
                    ),
                  )
                  .toList();
            } else {
              payload['events'] = <Map<String, Object?>>[];
            }
          }
        } catch (_) {
          payload
            ..clear()
            ..addAll({
              'captured_at': DateTime.now().toUtc().toIso8601String(),
              'events': <Map<String, Object?>>[],
            });
        }
      }
    }
    return _FileTransferCapture._(
      path: path,
      payload: payload,
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
