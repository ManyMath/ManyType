import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:manytype_protocol/coordinator.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:manytype_protocol/spacesync.dart';

import '../config.dart';
import '../identity.dart';
import '../network_config.dart';
import '../store/database.dart';
import '../ffi/native_bridge.dart';
import '../head_sync_client.dart';

typedef SyncUnaryInvoker = Uint8List Function(
  int handleId,
  String method,
  Uint8List payload,
);

typedef SyncUnaryRecorder = void Function({
  required String role,
  required String method,
  required Uint8List requestBytes,
  required Uint8List responseBytes,
});

class SyncDiscoveryResult {
  const SyncDiscoveryResult({
    required this.networkConfig,
    required this.syncAddress,
    required this.fileAddress,
    required this.spaceStatus,
  });

  final NetworkConfigurationResponse networkConfig;
  final String syncAddress;
  final String? fileAddress;
  final SpaceStatusPayload spaceStatus;
}

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
    // Step 2: NetworkConfiguration + SpaceStatusCheck preflight
    final discovery = discoverSyncTargetsForSync(
      invoke: bridge.invoke,
      coordinatorHandleId: coordinatorHandleId,
      spaceId: spaceId,
      officialInteropMode: officialInteropMode,
      localServerAddress: config.serverAddress,
      recordUnaryRpc: ({
        required role,
        required method,
        required requestBytes,
        required responseBytes,
      }) {
        capture.recordUnaryRpc(
          role: role,
          method: method,
          requestBytes: requestBytes,
          responseBytes: responseBytes,
        );
      },
    );
    final netConfig = discovery.networkConfig;
    print('Network: ${netConfig.networkId}, nodes: ${netConfig.nodes.length}');
    syncAddress = discovery.syncAddress;

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

    // Step 5: HeadSync to get server heads (Phase 16 iterative V2/V3 narrowing)
    final headSyncClient = HeadSyncClient(
      invoker: (handleId, method, payload) {
        final response = bridge.invoke(handleId, method, payload);
        capture.recordUnaryRpc(
          role: 'sync-node',
          method: method,
          requestBytes: payload,
          responseBytes: response,
        );
        return response;
      },
    );
    final serverHeads = headSyncClient.fetchServerHeads(syncHandleId, spaceId);
    print('Server has ${serverHeads.length} objects: ${serverHeads.keys.join(", ")}');

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
      capture.recordNote(
        'official-object-diff-summary',
        {
          'local_diff_count': localOnlyObjectCount,
          'remote_diff_count': remoteOnlyObjectCount,
          if (discovery.fileAddress != null)
            'file_address': discovery.fileAddress,
        },
      );
    }

    // Push: objects local has that server lacks or has different heads.
    for (final entry in localHeads.entries) {
      final objectId = entry.key;
      final localHeadSet = entry.value.toSet();
      final serverHeadSet = serverHeads[objectId] ?? <String>{};

      print('Comparing $objectId: local=$localHeadSet server=$serverHeadSet');

      if (localHeadSet.difference(serverHeadSet).isNotEmpty) {
        final changes = await db.getChangesForObject(objectId);

        // HACK: Only push objects that have more than 1 change (i.e. the Note object)
        // to avoid pushing ACL/Settings with ObjectType::Tree.
        if (changes.length < 2) continue;

        final treeSyncMsg = _buildTreeSyncMessage(objectId, changes, isNewToServer: serverHeadSet.isEmpty);
        final payload = Uint8List.fromList(treeSyncMsg.writeToBuffer());

        final responseData =
            bridge.syncObject(syncHandleId, spaceId, objectId, payload);
        capture.recordStreamRpc(
          role: 'sync-node',
          method: '/spacesync.SpaceSync/ObjectSyncStream',
          requestMessages: [payload],
          responseMessages: _decodeMessagesFromFfi(responseData),
        );
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
        final requestMsg = TreeSyncMessage(
          content: TreeSyncContentValue(
            fullSyncRequest: TreeFullSyncRequest(
              heads: localHeadSet.toList(),
              changes: [],
            ),
          ),
        );
        final pullPayload = Uint8List.fromList(requestMsg.writeToBuffer());

        final responseData =
            bridge.syncObject(syncHandleId, spaceId, objectId, pullPayload);

        if (responseData.isNotEmpty) {
          capture.recordStreamRpc(
            role: 'sync-node',
            method: '/spacesync.SpaceSync/ObjectSyncStream',
            requestMessages: [pullPayload],
            responseMessages: _decodeMessagesFromFfi(responseData),
          );
          await storePulledChanges(db, spaceId, objectId, responseData);
          pulled++;
          print('  Pulled: $objectId');
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
    if (coordinatorHandleId != syncHandleId) {
      bridge.freeHandle(coordinatorHandleId);
    }
    await capture.flush();
  }
}

SyncDiscoveryResult discoverSyncTargetsForSync({
  required SyncUnaryInvoker invoke,
  required int coordinatorHandleId,
  required String spaceId,
  required bool officialInteropMode,
  required String localServerAddress,
  SyncUnaryRecorder? recordUnaryRpc,
}) {
  final netConfigRequest = NetworkConfigurationRequest();
  final netConfigRequestBytes =
      Uint8List.fromList(netConfigRequest.writeToBuffer());
  final netConfigResponseBytes = invoke(
    coordinatorHandleId,
    '/coordinator.Coordinator/NetworkConfiguration',
    netConfigRequestBytes,
  );
  recordUnaryRpc?.call(
    role: 'coordinator',
    method: '/coordinator.Coordinator/NetworkConfiguration',
    requestBytes: netConfigRequestBytes,
    responseBytes: netConfigResponseBytes,
  );
  final netConfig =
      NetworkConfigurationResponse.fromBuffer(netConfigResponseBytes);

  final syncAddress = officialInteropMode
      ? chooseTreeAddressFromResponse(netConfig.nodes)
      : localServerAddress;
  final fileAddress = officialInteropMode
      ? chooseFileAddressFromResponse(netConfig.nodes)
      : null;
  if (syncAddress == null) {
    throw StateError(
      'Coordinator response did not include a tree node address',
    );
  }

  final preflightRequest = SpaceStatusCheckRequest(spaceId: spaceId);
  final preflightRequestBytes =
      Uint8List.fromList(preflightRequest.writeToBuffer());
  final preflightResponseBytes = invoke(
    coordinatorHandleId,
    '/coordinator.Coordinator/SpaceStatusCheck',
    preflightRequestBytes,
  );
  recordUnaryRpc?.call(
    role: 'coordinator',
    method: '/coordinator.Coordinator/SpaceStatusCheck',
    requestBytes: preflightRequestBytes,
    responseBytes: preflightResponseBytes,
  );
  final preflight = SpaceStatusCheckResponse.fromBuffer(preflightResponseBytes);
  final payload = preflight.payload;
  if (payload.status != SpaceStatus.SpaceStatusCreated) {
    throw StateError(
      'Space $spaceId is not live: ${_spaceStatusName(payload.status)}',
    );
  }

  return SyncDiscoveryResult(
    networkConfig: netConfig,
    syncAddress: syncAddress,
    fileAddress: fileAddress,
    spaceStatus: payload,
  );
}

Future<void> seedLiveSpaceForSync(
  ManytypeDatabase db,
  CliConfig config, {
  required String networkConfigPath,
}) async {
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final bridge = NativeBridge();
  final coordinatorAddress = chooseBestAddress(
    requireCoordinatorNode(await loadNetworkConfig(networkConfigPath))
        .addresses,
  );
  int? coordinatorHandleId;
  int? syncHandleId;

  try {
    coordinatorHandleId =
        bridge.connect(coordinatorAddress, identity.seed, identity.accountSeed);
    final netConfigBytes = bridge.invoke(
      coordinatorHandleId,
      '/coordinator.Coordinator/NetworkConfiguration',
      Uint8List.fromList(NetworkConfigurationRequest().writeToBuffer()),
    );
    final netConfig = NetworkConfigurationResponse.fromBuffer(netConfigBytes);
    final syncAddress = chooseTreeAddressFromResponse(netConfig.nodes);
    if (syncAddress == null) {
      throw StateError(
        'Coordinator response did not include a tree node address',
      );
    }

    final signRequest = SpaceSignRequest(
      spaceId: identity.spaceId,
      header: identity.spaceHeader.rawHeader,
    );
    final signResponse = SpaceSignResponse.fromBuffer(
      bridge.invoke(
        coordinatorHandleId,
        '/coordinator.Coordinator/SpaceSign',
        Uint8List.fromList(signRequest.writeToBuffer()),
      ),
    );

    syncHandleId =
        bridge.connect(syncAddress, identity.seed, identity.accountSeed);
    final bootstrap = await _loadSpaceBootstrap(db, identity.spaceId);
    if (bootstrap == null) {
      throw StateError('Local space bootstrap data is missing');
    }

    final payload = SpacePayload(
      spaceHeader: identity.spaceHeader,
      aclPayload: Uint8List.fromList(bootstrap.aclPayload),
      aclPayloadId: bootstrap.aclPayloadId,
      spaceSettingsPayload: Uint8List.fromList(bootstrap.spaceSettingsPayload),
      spaceSettingsPayloadId: bootstrap.spaceSettingsPayloadId,
    );
    final pushRequest = SpacePushRequest(
      payload: payload,
      credential: signResponse.receipt.writeToBuffer(),
    );
    bridge.invoke(
      syncHandleId,
      '/spacesync.SpaceSync/SpacePush',
      Uint8List.fromList(pushRequest.writeToBuffer()),
    );
  } finally {
    if (syncHandleId != null) {
      bridge.freeHandle(syncHandleId);
    }
    if (coordinatorHandleId != null) {
      bridge.freeHandle(coordinatorHandleId);
    }
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
///
/// Accepts either:
/// - length-prefixed ObjectSyncMessages from the FFI pull path, or
/// - length-prefixed raw tree changes for direct tests/helpers.
Future<void> storePulledChanges(
  ManytypeDatabase db,
  String spaceId,
  String objectId,
  Uint8List data,
) async {
  // Ensure object exists in local store
  await db.insertObject(objectId, spaceId);

  // Parse response data: length-prefixed ObjectSyncMessages [u32 LE len][bytes]...
  if (data.length >= 4) {
    final bd = ByteData.sublistView(data);
    int offset = 0;
    while (offset + 4 <= data.length) {
      final len = bd.getUint32(offset, Endian.little);
      offset += 4;
      if (offset + len > data.length) break;
      final msgBytes = data.sublist(offset, offset + len);
      offset += len;

      final stored = await _storePulledMessageBytes(
        db,
        spaceId,
        objectId,
        msgBytes,
      );
      if (stored) {
        continue;
      }

      await _storeRawPulledChange(
        db,
        spaceId,
        objectId,
        msgBytes,
      );
    }
  }
}

Future<bool> _storePulledMessageBytes(
  ManytypeDatabase db,
  String spaceId,
  String objectId,
  Uint8List msgBytes,
) async {
  try {
    final msg = ObjectSyncMessage.fromBuffer(msgBytes);
    final looksLikeObjectSyncMessage = msg.hasPayload() ||
        (msg.hasObjectId() &&
            (msg.hasSpaceId() || msg.hasRequestId() || msg.hasReplyId()));
    if (!looksLikeObjectSyncMessage) {
      return false;
    }
    if (msg.payload.isEmpty) {
      return true;
    }

    final treeMsg = TreeSyncMessage.fromBuffer(msg.payload);
    final changes = <RawTreeChangeWithId>[];
    if (treeMsg.hasRootChange()) {
      changes.add(treeMsg.rootChange);
    }
    if (treeMsg.hasContent()) {
      if (treeMsg.content.hasHeadUpdate()) {
        changes.addAll(treeMsg.content.headUpdate.changes);
      }
      if (treeMsg.content.hasFullSyncResponse()) {
        changes.addAll(treeMsg.content.fullSyncResponse.changes);
      }
    }

    for (final raw in changes) {
      final changeBytes = Uint8List.fromList(raw.rawChange);
      await _storeRawPulledChange(
        db,
        spaceId,
        objectId,
        changeBytes,
        changeId: raw.id,
      );
    }
    return true;
  } catch (_) {
    return false;
  }
}

Future<void> _storeRawPulledChange(
  ManytypeDatabase db,
  String spaceId,
  String objectId,
  Uint8List changeBytes, {
  String? changeId,
}) async {
  final resolvedChangeId = changeId ?? await computeCid(changeBytes);
  await db.insertChange(
    resolvedChangeId,
    objectId,
    changeBytes,
    jsonEncode(_extractParentHeads(changeBytes)),
  );

  for (final ref in extractAttachmentRefsFromRawChangeBytes(changeBytes)) {
    await db.upsertAttachmentRef(
      spaceId: spaceId,
      objectId: objectId,
      fileId: ref.fileId,
      cid: ref.cid,
    );
  }
}

List<({String fileId, String cid})> extractAttachmentRefsFromRawChangeBytes(
  List<int> rawChangeBytes,
) {
  final refs = <({String fileId, String cid})>[];

  try {
    final rawTreeChange = RawTreeChange.fromBuffer(rawChangeBytes);
    if (rawTreeChange.payload.isEmpty) {
      return const [];
    }

    final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
    if (treeChange.changesData.isEmpty) {
      return const [];
    }

    final change = changes_proto.Change.fromBuffer(
        Uint8List.fromList(treeChange.changesData));
    final fileIds = <String>{};
    final cids = <String>{};

    if (change.hasSnapshot()) {
      final snapshot = change.snapshot;
      if (snapshot.hasData() && snapshot.data.hasFileInfo()) {
        final fileId = snapshot.data.fileInfo.fileId.trim();
        if (fileId.isNotEmpty) {
          fileIds.add(fileId);
        }
      }
      for (final fileKey in snapshot.fileKeys) {
        final cid = fileKey.hash.trim();
        if (cid.isNotEmpty) {
          cids.add(cid);
        }
      }
    }

    for (final content in change.content) {
      if (content.hasSetFileInfo()) {
        final fileId = content.setFileInfo.fileInfo.fileId.trim();
        if (fileId.isNotEmpty) {
          fileIds.add(fileId);
        }
      }
    }

    for (final fileKey in change.fileKeys) {
      final cid = fileKey.hash.trim();
      if (cid.isNotEmpty) {
        cids.add(cid);
      }
    }

    if (fileIds.isEmpty) {
      return const [];
    }

    final orderedFileIds = fileIds.toList()..sort();
    final orderedCids = cids.toList()..sort();
    if (orderedCids.isEmpty) {
      return [
        for (final fileId in orderedFileIds) (fileId: fileId, cid: ''),
      ];
    }

    for (final fileId in orderedFileIds) {
      for (final cid in orderedCids) {
        refs.add((fileId: fileId, cid: cid));
      }
    }
  } catch (_) {
    return const [];
  }

  return refs;
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

String _spaceStatusName(SpaceStatus status) => status.name;

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

List<Uint8List> _decodeMessagesFromFfi(Uint8List data) {
  final messages = <Uint8List>[];
  if (data.length >= 4) {
    final bd = ByteData.sublistView(data);
    int offset = 0;
    while (offset + 4 <= data.length) {
      final len = bd.getUint32(offset, Endian.little);
      offset += 4;
      if (offset + len > data.length) break;
      messages.add(data.sublist(offset, offset + len));
      offset += len;
    }
  }
  return messages;
}

TreeSyncMessage _buildTreeSyncMessage(String objectId, List<Change> changes, {bool isNewToServer = false}) {
  if (changes.isEmpty) {
    return TreeSyncMessage();
  }

  // Find root change (the one with no parents)
  Change? rootChange;
  final otherChanges = <Change>[];

  for (final c in changes) {
    final parents = jsonDecode(c.parentHeads) as List;
    if (parents.isEmpty) {
      rootChange = c;
    } else {
      otherChanges.add(c);
    }
  }

  final parentIds = <String>{};
  for (final c in changes) {
    parentIds.addAll(jsonDecode(c.parentHeads).cast<String>());
  }
  final heads = changes.map((c) => c.id).where((id) => !parentIds.contains(id)).toList();

  final changesList = otherChanges
      .map((c) => RawTreeChangeWithId(
            id: c.id,
            rawChange: c.rawBytes,
          ))
      .toList();

  final contentValue = TreeSyncContentValue(
    headUpdate: TreeHeadUpdate(
      heads: heads,
      changes: changesList,
    ),
  );

  return TreeSyncMessage(
    rootChange: rootChange != null
        ? RawTreeChangeWithId(
            id: rootChange.id,
            rawChange: rootChange.rawBytes,
          )
        : null,
    content: contentValue,
  );
}

HeadSyncRange _fullHeadSyncRange({required bool elements}) => HeadSyncRange(
      from: Int64.ZERO,
      to: Int64.parseHex('ffffffffffffffff'),
      elements: elements,
    );
