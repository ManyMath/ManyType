import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/coordinator.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:manytype_protocol/spacesync.dart';

import '../config.dart';
import '../identity.dart';
import '../network_config.dart';
import '../store/database.dart';
import '../ffi/native_bridge.dart';

/// Sync local objects with the remote Rust server.
///
/// Performs the full protocol flow:
/// 1. Connect via FFI (QUIC + credential handshake)
/// 2. NetworkConfiguration RPC to coordinator (per D-12: must be first)
/// 3. SpacePush to ensure server knows our space
/// 4. HeadSync to get server's object heads
/// 5. Diff-based push/pull (per D-13)
Future<void> syncCommand(
  ManytypeDatabase db,
  CliConfig config, {
  String? networkConfigPath,
}) async {
  final officialInteropMode = networkConfigPath != null;
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final spaceId = identity.spaceId;
  final capture = _SessionCapture.start(
    officialInteropMode: officialInteropMode,
    spaceId: spaceId,
    coordinatorAddress: networkConfigPath == null
        ? config.serverAddress
        : chooseBestAddress(
            requireCoordinatorNode(await loadNetworkConfig(networkConfigPath))
                .addresses,
          ),
    networkConfigPath: networkConfigPath,
  );
  final bridge = NativeBridge();
  int? coordinatorHandleId;
  int? syncHandleId;
  String? syncAddress;

  final coordinatorAddress = capture.coordinatorAddress;

  print('Connecting to coordinator at $coordinatorAddress...');
  coordinatorHandleId =
      bridge.connect(coordinatorAddress, identity.seed, identity.accountSeed);
  print('Connected to coordinator (handle: $coordinatorHandleId)');
  capture.recordConnection(role: 'coordinator', address: coordinatorAddress);

  try {
    // Step 2: NetworkConfiguration RPC (per D-12 - must be first)
    final netConfigRequest = NetworkConfigurationRequest();
    final netConfigRequestBytes =
        Uint8List.fromList(netConfigRequest.writeToBuffer());
    final netConfigResponse = bridge.invoke(
      coordinatorHandleId,
      '/coordinator.Coordinator/NetworkConfiguration',
      netConfigRequestBytes,
    );
    capture.recordUnaryRpc(
      role: 'coordinator',
      method: '/coordinator.Coordinator/NetworkConfiguration',
      requestBytes: netConfigRequestBytes,
      responseBytes: netConfigResponse,
    );
    final netConfig =
        NetworkConfigurationResponse.fromBuffer(netConfigResponse);
    print('Network: ${netConfig.networkId}, nodes: ${netConfig.nodes.length}');

    syncAddress = networkConfigPath == null
        ? config.serverAddress
        : chooseTreeAddressFromResponse(netConfig.nodes);
    if (syncAddress == null) {
      throw StateError(
          'Coordinator response did not include a tree node address');
    }

    // Step 3: SpaceSign (obtain receipt for SpacePush)
    final spaceSignResponseBytes = bridge.invoke(
      coordinatorHandleId,
      '/coordinator.Coordinator/SpaceSign',
      SpaceSignRequest(
        spaceId: spaceId,
        header: identity.spaceHeader.rawHeader,
      ).writeToBuffer(),
    );
    capture.recordUnaryRpc(
      role: 'coordinator',
      method: '/coordinator.Coordinator/SpaceSign',
      requestBytes: Uint8List.fromList(
        SpaceSignRequest(
          spaceId: spaceId,
          header: identity.spaceHeader.rawHeader,
        ).writeToBuffer(),
      ),
      responseBytes: spaceSignResponseBytes,
    );
    final spaceSignResponse =
        SpaceSignResponse.fromBuffer(spaceSignResponseBytes);
    final receiptBytes = spaceSignResponse.receipt.writeToBuffer();

    if (networkConfigPath == null) {
      syncHandleId = coordinatorHandleId;
    } else {
      print('Connecting to sync node at $syncAddress...');
      syncHandleId =
          bridge.connect(syncAddress, identity.seed, identity.accountSeed);
      print('Connected to sync node (handle: $syncHandleId)');
      capture.recordConnection(role: 'sync-node', address: syncAddress);
    }

    // Step 4: SpacePush (ensure server knows about our space)
    final bootstrap = await _loadSpaceBootstrap(db, spaceId);
    if (bootstrap != null) {
      final spacePayload = SpacePayload(
        spaceHeader: identity.spaceHeader,
        aclPayload: Uint8List.fromList(bootstrap.aclPayload),
        aclPayloadId: bootstrap.aclPayloadId,
        spaceSettingsPayload:
            Uint8List.fromList(bootstrap.spaceSettingsPayload),
        spaceSettingsPayloadId: bootstrap.spaceSettingsPayloadId,
      );
      final pushRequest = SpacePushRequest(
        payload: spacePayload,
        credential: receiptBytes,
      );
      final pushRequestBytes = Uint8List.fromList(pushRequest.writeToBuffer());
      bridge.invoke(
        syncHandleId,
        '/spacesync.SpaceSync/SpacePush',
        pushRequestBytes,
      );
      capture.recordUnaryRpc(
        role: 'sync-node',
        method: '/spacesync.SpaceSync/SpacePush',
        requestBytes: pushRequestBytes,
        responseBytes: Uint8List(0),
      );
      print('Pushed space header');
    }

    // Step 5: HeadSync to get server heads (per D-13 - diff-based)
    final headSyncRequest = HeadSyncRequest(
      spaceId: spaceId,
      diffType: DiffType.V3,
      ranges: [_fullHeadSyncRange(elements: true)],
    );
    final headSyncRequestBytes =
        Uint8List.fromList(headSyncRequest.writeToBuffer());
    final headSyncResponseBytes = bridge.invoke(
      syncHandleId,
      '/spacesync.SpaceSync/HeadSync',
      headSyncRequestBytes,
    );
    capture.recordUnaryRpc(
      role: 'sync-node',
      method: '/spacesync.SpaceSync/HeadSync',
      requestBytes: headSyncRequestBytes,
      responseBytes: headSyncResponseBytes,
    );
    final headSyncResponse = HeadSyncResponse.fromBuffer(headSyncResponseBytes);

    // Parse server heads into map: objectId -> Set<headCid>
    final serverHeads = <String, Set<String>>{};
    for (final result in headSyncResponse.results) {
      for (final elem in result.elements) {
        serverHeads.putIfAbsent(elem.id, () => <String>{}).add(elem.head);
      }
    }
    print('Server has ${serverHeads.length} objects');

    // Step 6: Compare local vs server heads
    final localHeads = await db.getSpaceHeads(spaceId);

    int pushed = 0;
    int pulled = 0;
    if (officialInteropMode) {
      final localOnlyObjectCount = localHeads.entries.where((entry) {
        final serverHeadSet = serverHeads[entry.key] ?? <String>{};
        return entry.value.toSet().difference(serverHeadSet).isNotEmpty;
      }).length;
      final remoteOnlyObjectCount = serverHeads.entries.where((entry) {
        final localHeadSet = (localHeads[entry.key] ?? <String>[]).toSet();
        return entry.value.difference(localHeadSet).isNotEmpty;
      }).length;

      if (localOnlyObjectCount > 0 || remoteOnlyObjectCount > 0) {
        print(
          'Skipping object-tree sync against official Any-sync nodes: '
          'direct client upload/download of tree objects is not supported by '
          'the peer-mesh protocol yet '
          '(local diffs: $localOnlyObjectCount, remote diffs: $remoteOnlyObjectCount)',
        );
        capture.recordNote(
          'official-object-sync-skipped',
          {
            'local_diff_count': localOnlyObjectCount,
            'remote_diff_count': remoteOnlyObjectCount,
          },
        );
      }
    } else {
      // Push: objects local has that server lacks or has different heads.
      for (final entry in localHeads.entries) {
        final objectId = entry.key;
        final localHeadSet = entry.value.toSet();
        final serverHeadSet = serverHeads[objectId] ?? <String>{};

        if (localHeadSet.difference(serverHeadSet).isNotEmpty) {
          final changes = await db.getChangesForObject(objectId);
          final changesData = _encodeChangesForFfi(changes);
          bridge.syncObject(syncHandleId, spaceId, objectId, changesData);
          pushed++;
          print('  Pushed: $objectId (${changes.length} changes)');
        }
      }

      // Pull: objects server has that local lacks or has different heads.
      for (final entry in serverHeads.entries) {
        final objectId = entry.key;
        final serverHeadSet = entry.value;
        final localHeadSet = (localHeads[objectId] ?? <String>[]).toSet();

        if (serverHeadSet.difference(localHeadSet).isNotEmpty) {
          final responseData =
              bridge.syncObject(syncHandleId, spaceId, objectId, Uint8List(0));

          if (responseData.isNotEmpty) {
            await _storePulledChanges(db, spaceId, objectId, responseData);
            pulled++;
            print('  Pulled: $objectId');
          }
        }
      }
    }

    await _ensureBootstrapStoreEntry(db, identity, spaceId);
    final (pushedStoreValues, pulledStoreValues) = await _syncStoreValues(
      db,
      bridge,
      syncHandleId,
      spaceId,
      capture: capture,
    );

    print(
      'Sync complete: pushed $pushed, pulled $pulled objects, '
      'pushed $pushedStoreValues, pulled $pulledStoreValues store values',
    );
    capture.recordNote(
      'sync-complete',
      {
        'pushed_objects': pushed,
        'pulled_objects': pulled,
        'pushed_store_values': pushedStoreValues,
        'pulled_store_values': pulledStoreValues,
      },
    );
  } catch (error) {
    capture.recordError(error.toString());
    rethrow;
  } finally {
    if (syncHandleId != null) {
      bridge.freeHandle(syncHandleId);
    }
    if (coordinatorHandleId != null && coordinatorHandleId != syncHandleId) {
      bridge.freeHandle(coordinatorHandleId);
    }
    await capture.flush();
  }
}

Future<_SpaceBootstrap?> _loadSpaceBootstrap(
  ManytypeDatabase db,
  String spaceId,
) async {
  final objects = await db.getObjectsBySpace(spaceId);
  String? aclPayloadId;
  Uint8List? aclPayload;
  String? settingsPayloadId;
  Uint8List? settingsPayload;

  for (final object in objects) {
    final changes = await db.getChangesForObject(object.id);
    if (changes.isEmpty) continue;
    final rawBytes = Uint8List.fromList(changes.first.rawBytes);

    try {
      final rawRecord = RawRecord.fromBuffer(rawBytes);
      final aclRoot = AclRoot.fromBuffer(rawRecord.payload);
      if (aclRoot.spaceId == spaceId) {
        aclPayloadId = object.id;
        aclPayload = rawBytes;
        continue;
      }
    } catch (_) {
      // Not an ACL root.
    }

    try {
      final rawTree = RawTreeChange.fromBuffer(rawBytes);
      final rootChange = RootChange.fromBuffer(rawTree.payload);
      if (rootChange.spaceId == spaceId &&
          rootChange.changeType == 'any-sync.space') {
        settingsPayloadId = object.id;
        settingsPayload = rawBytes;
      }
    } catch (_) {
      // Not a settings root.
    }
  }

  if (aclPayloadId == null ||
      aclPayload == null ||
      settingsPayloadId == null ||
      settingsPayload == null) {
    return null;
  }

  return _SpaceBootstrap(
    aclPayloadId: aclPayloadId,
    aclPayload: aclPayload,
    spaceSettingsPayloadId: settingsPayloadId,
    spaceSettingsPayload: settingsPayload,
  );
}

/// Encode changes as length-prefixed byte array for FFI boundary.
///
/// Format: [u32 LE len1][bytes1][u32 LE len2][bytes2]...
Uint8List _encodeChangesForFfi(List<Change> changes) {
  final buffer = BytesBuilder();
  for (final change in changes) {
    final raw = change.rawBytes;
    final lenBytes = ByteData(4)..setUint32(0, raw.length, Endian.little);
    buffer.add(lenBytes.buffer.asUint8List());
    buffer.add(raw);
  }
  return buffer.toBytes();
}

Uint8List _encodeMessagesForFfi(Iterable<Uint8List> messages) {
  final buffer = BytesBuilder();
  for (final message in messages) {
    final lenBytes = ByteData(4)..setUint32(0, message.length, Endian.little);
    buffer.add(lenBytes.buffer.asUint8List());
    buffer.add(message);
  }
  return buffer.toBytes();
}

/// Store pulled changes from the server into the local database.
Future<void> _storePulledChanges(
  ManytypeDatabase db,
  String spaceId,
  String objectId,
  Uint8List data,
) async {
  // Ensure object exists in local store
  await db.insertObject(objectId, spaceId);

  // Parse response data: length-prefixed changes [u32 LE len][bytes]...
  // For v1 we store the raw response as a single change if we cannot decode
  // individual changes.
  if (data.length >= 4) {
    final bd = ByteData.sublistView(data);
    int offset = 0;
    while (offset + 4 <= data.length) {
      final len = bd.getUint32(offset, Endian.little);
      offset += 4;
      if (offset + len > data.length) break;
      final changeBytes = data.sublist(offset, offset + len);
      offset += len;
      final changeId = await computeCid(Uint8List.fromList(changeBytes));
      await db.insertChange(
        changeId,
        objectId,
        changeBytes,
        jsonEncode(_extractParentHeads(changeBytes)),
      );
    }
  }
}

Future<(int, int)> _syncStoreValues(
  ManytypeDatabase db,
  NativeBridge bridge,
  int handleId,
  String spaceId, {
  _SessionCapture? capture,
}) async {
  final localEntries = await db.getStoreEntriesBySpace(spaceId);
  final localHeads = <String, String>{
    for (final entry in localEntries)
      entry.keyPeerId: _storeHeadFromValue(entry.value),
  };

  final storeDiffRequestBytes = Uint8List.fromList(
    StoreDiffRequest(
      spaceId: spaceId,
      ranges: [_fullHeadSyncRange(elements: true)],
    ).writeToBuffer(),
  );
  final storeDiffResponseBytes = bridge.invoke(
    handleId,
    '/spacesync.SpaceSync/StoreDiff',
    storeDiffRequestBytes,
  );
  capture?.recordUnaryRpc(
    role: 'sync-node',
    method: '/spacesync.SpaceSync/StoreDiff',
    requestBytes: storeDiffRequestBytes,
    responseBytes: storeDiffResponseBytes,
  );
  final storeDiffResponse =
      StoreDiffResponse.fromBuffer(storeDiffResponseBytes);
  final serverHeads = <String, String>{};
  for (final result in storeDiffResponse.results) {
    for (final element in result.elements) {
      serverHeads[element.id] = element.head;
    }
  }

  final messages = <StoreKeyValue>[StoreKeyValue(spaceId: spaceId)];
  final requestedKeys = <String>{};
  int pushed = 0;

  for (final entry in localEntries) {
    final localHead = localHeads[entry.keyPeerId]!;
    final serverHead = serverHeads[entry.keyPeerId];
    if (serverHead == null || localHead.compareTo(serverHead) > 0) {
      messages.add(
        StoreKeyValue(
          keyPeerId: entry.keyPeerId,
          value: entry.value,
          identitySignature: entry.identitySignature,
          peerSignature: entry.peerSignature,
          spaceId: entry.spaceId,
        ),
      );
      pushed++;
    }
  }

  for (final entry in serverHeads.entries) {
    final localHead = localHeads[entry.key];
    if (localHead == null || entry.value.compareTo(localHead) > 0) {
      messages.add(StoreKeyValue(keyPeerId: entry.key, spaceId: spaceId));
      requestedKeys.add(entry.key);
    }
  }

  if (messages.length == 1) {
    capture?.recordNote(
      'store-elements-skipped',
      {'reason': 'no local or remote store diffs'},
    );
    return (0, 0);
  }

  final storeElementRequestMessages = messages
      .map((message) => Uint8List.fromList(message.writeToBuffer()))
      .toList(growable: false);
  final storeElementWireMessages = [
    ...storeElementRequestMessages,
    Uint8List.fromList(StoreKeyValue().writeToBuffer()),
  ];
  final responseData = bridge.syncStore(
    handleId,
    _encodeMessagesForFfi(storeElementWireMessages),
  );
  capture?.recordStreamRpc(
    role: 'sync-node',
    method: '/spacesync.SpaceSync/StoreElements',
    requestMessages: storeElementWireMessages,
    responseMessages: _decodeLengthPrefixedMessages(responseData).toList(),
  );

  int pulled = 0;
  for (final messageBytes in _decodeLengthPrefixedMessages(responseData)) {
    final message = StoreKeyValue.fromBuffer(messageBytes);
    if (message.keyPeerId.isEmpty) {
      break;
    }
    await db.upsertStoreEntry(
      keyPeerId: message.keyPeerId,
      spaceId: message.spaceId.isNotEmpty ? message.spaceId : spaceId,
      valueBytes: message.value,
      identitySignatureBytes: message.identitySignature,
      peerSignatureBytes: message.peerSignature,
    );
    if (requestedKeys.contains(message.keyPeerId)) {
      pulled++;
    }
  }

  return (pushed, pulled);
}

Future<void> _ensureBootstrapStoreEntry(
  ManytypeDatabase db,
  Identity identity,
  String spaceId,
) async {
  if ((await db.getStoreEntriesBySpace(spaceId)).isNotEmpty) {
    return;
  }

  String? aclHeadId;
  final objects = await db.getObjectsBySpace(spaceId);
  for (final object in objects) {
    final changes = await db.getChangesForObject(object.id);
    if (changes.isEmpty) continue;
    try {
      final rawRecord = RawRecord.fromBuffer(changes.first.rawBytes);
      final aclRoot = AclRoot.fromBuffer(rawRecord.payload);
      if (aclRoot.spaceId == spaceId) {
        aclHeadId = object.id;
        break;
      }
    } catch (_) {
      // Not an ACL root.
    }
  }

  if (aclHeadId == null) {
    return;
  }

  const logicalKey = 'manytype.bootstrap';
  final keyPeerId = '$logicalKey.$spaceId';
  final inner = StoreKeyInner(
    peer: _marshalEd25519PublicKey(identity.keyPair.publicKey),
    identity: _marshalEd25519PublicKey(identity.accountKeyPair.publicKey),
    value: Uint8List.fromList(utf8.encode('manytype/bootstrap-store-entry')),
    timestampMicro: Int64(DateTime.now().microsecondsSinceEpoch),
    aclHeadId: aclHeadId,
    key: logicalKey,
  );
  final innerBytes = Uint8List.fromList(inner.writeToBuffer());

  await db.upsertStoreEntry(
    keyPeerId: keyPeerId,
    spaceId: spaceId,
    valueBytes: innerBytes,
    identitySignatureBytes: await ed25519Sign(identity.accountSeed, innerBytes),
    peerSignatureBytes: await ed25519Sign(identity.seed, innerBytes),
  );
}

Iterable<Uint8List> _decodeLengthPrefixedMessages(Uint8List data) sync* {
  if (data.length < 4) return;

  final bd = ByteData.sublistView(data);
  int offset = 0;
  while (offset + 4 <= data.length) {
    final len = bd.getUint32(offset, Endian.little);
    offset += 4;
    if (offset + len > data.length) {
      break;
    }
    yield data.sublist(offset, offset + len);
    offset += len;
  }
}

List<String> _extractParentHeads(List<int> rawChangeBytes) {
  try {
    final rawTreeChange = RawTreeChange.fromBuffer(rawChangeBytes);
    final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
    return treeChange.treeHeadIds;
  } catch (_) {
    return const [];
  }
}

String _storeHeadFromValue(Uint8List valueBytes) {
  try {
    final inner = StoreKeyInner.fromBuffer(valueBytes);
    final timestamp = inner.timestampMicro.toInt();
    return timestamp < 0
        ? '00000000000000000000'
        : timestamp.toString().padLeft(20, '0');
  } catch (_) {
    return '';
  }
}

Uint8List _marshalEd25519PublicKey(Uint8List publicKey) => Uint8List.fromList(
      Key(
        type: KeyType.Ed25519Public,
        data: publicKey,
      ).writeToBuffer(),
    );

class _SpaceBootstrap {
  const _SpaceBootstrap({
    required this.aclPayloadId,
    required this.aclPayload,
    required this.spaceSettingsPayloadId,
    required this.spaceSettingsPayload,
  });

  final String aclPayloadId;
  final Uint8List aclPayload;
  final String spaceSettingsPayloadId;
  final Uint8List spaceSettingsPayload;
}

class _SessionCapture {
  _SessionCapture._({
    required this.path,
    required this.coordinatorAddress,
    required bool officialInteropMode,
    required String spaceId,
    required String? networkConfigPath,
  }) : _payload = {
          'captured_at': DateTime.now().toUtc().toIso8601String(),
          'official_interop_mode': officialInteropMode,
          'space_id': spaceId,
          'coordinator_address': coordinatorAddress,
          'network_config_path': networkConfigPath,
          'events': <Map<String, Object?>>[],
        };

  final String? path;
  final String coordinatorAddress;
  final Map<String, Object?> _payload;

  static _SessionCapture start({
    required bool officialInteropMode,
    required String spaceId,
    required String coordinatorAddress,
    required String? networkConfigPath,
  }) {
    return _SessionCapture._(
      path: Platform.environment['MANYTYPE_SYNC_CAPTURE_PATH'],
      coordinatorAddress: coordinatorAddress,
      officialInteropMode: officialInteropMode,
      spaceId: spaceId,
      networkConfigPath: networkConfigPath,
    );
  }

  bool get _enabled => path != null && path!.isNotEmpty;

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

  void recordStreamRpc({
    required String role,
    required String method,
    required List<Uint8List> requestMessages,
    required List<Uint8List> responseMessages,
  }) {
    if (!_enabled) return;
    _events.add({
      'type': 'stream_rpc',
      'role': role,
      'method': method,
      'request_messages': requestMessages
          .map((message) => {
                'len': message.length,
                'base64': base64Encode(message),
              })
          .toList(growable: false),
      'response_messages': responseMessages
          .map((message) => {
                'len': message.length,
                'base64': base64Encode(message),
              })
          .toList(growable: false),
    });
  }

  void recordNote(String type, Map<String, Object?> details) {
    if (!_enabled) return;
    _events.add({'type': type, ...details});
  }

  void recordError(String error) {
    recordNote('error', {'message': error});
  }

  List<Map<String, Object?>> get _events =>
      _payload['events']! as List<Map<String, Object?>>;

  Future<void> flush() async {
    if (!_enabled) return;
    final file = File(path!);
    await file.parent.create(recursive: true);
    final encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString('${encoder.convert(_payload)}\n');
  }
}

HeadSyncRange _fullHeadSyncRange({required bool elements}) => HeadSyncRange(
      from: Int64.ZERO,
      to: Int64.parseHex('ffffffffffffffff'),
      elements: elements,
    );
