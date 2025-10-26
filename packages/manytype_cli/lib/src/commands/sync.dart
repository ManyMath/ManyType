import 'dart:convert';
import 'dart:typed_data';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/coordinator.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:manytype_protocol/spacesync.dart';

import '../config.dart';
import '../identity.dart';
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
Future<void> syncCommand(ManytypeDatabase db, CliConfig config) async {
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final spaceId = identity.spaceId;
  final bridge = NativeBridge();

  print('Connecting to ${config.serverAddress}...');

  // Step 1: Connect via FFI (QUIC + handshake)
  final handleId = bridge.connect(config.serverAddress, identity.seed);
  print('Connected (handle: $handleId)');

  try {
    // Step 2: NetworkConfiguration RPC (per D-12 - must be first)
    final netConfigRequest = NetworkConfigurationRequest();
    final netConfigResponse = bridge.invoke(
      handleId,
      '/coordinator.Coordinator/NetworkConfiguration',
      netConfigRequest.writeToBuffer(),
    );
    final netConfig =
        NetworkConfigurationResponse.fromBuffer(netConfigResponse);
    print('Network: ${netConfig.networkId}, nodes: ${netConfig.nodes.length}');

    // Step 3: SpaceSign (obtain receipt for SpacePush)
    final spaceSignResponseBytes = bridge.invoke(
      handleId,
      '/coordinator.Coordinator/SpaceSign',
      SpaceSignRequest(
        spaceId: spaceId,
        header: identity.spaceHeader.rawHeader,
      ).writeToBuffer(),
    );
    final spaceSignResponse = SpaceSignResponse.fromBuffer(spaceSignResponseBytes);
    final receiptBytes = spaceSignResponse.receipt.writeToBuffer();

    // Step 4: SpacePush (ensure server knows about our space)
    final localObjects = await db.getObjectsBySpace(spaceId);
    if (localObjects.isNotEmpty) {
      // First object in space is the ACL root (per create command convention).
      // Get its raw bytes for the space payload.
      final aclChanges = await db.getChangesForObject(localObjects.first.id);
      final spacePayload = SpacePayload(
        spaceHeader: identity.spaceHeader,
        aclPayload: aclChanges.isNotEmpty
            ? Uint8List.fromList(aclChanges.first.rawBytes)
            : Uint8List(0),
        aclPayloadId: localObjects.first.id,
      );
      final pushRequest = SpacePushRequest(
        payload: spacePayload,
        credential: receiptBytes,
      );
      bridge.invoke(
        handleId,
        '/spacesync.SpaceSync/SpacePush',
        pushRequest.writeToBuffer(),
      );
      print('Pushed space header');
    }

    // Step 5: HeadSync to get server heads (per D-13 - diff-based)
    final headSyncRequest = HeadSyncRequest(spaceId: spaceId);
    final headSyncResponseBytes = bridge.invoke(
      handleId,
      '/spacesync.SpaceSync/HeadSync',
      headSyncRequest.writeToBuffer(),
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

    // Push: objects local has that server lacks or has different heads
    int pushed = 0;
    for (final entry in localHeads.entries) {
      final objectId = entry.key;
      final localHeadSet = entry.value.toSet();
      final serverHeadSet = serverHeads[objectId] ?? <String>{};

      if (localHeadSet.difference(serverHeadSet).isNotEmpty) {
        // Server is missing some heads -- push all changes for this object
        final changes = await db.getChangesForObject(objectId);
        final changesData = _encodeChangesForFfi(changes);
        bridge.syncObject(handleId, spaceId, objectId, changesData);
        pushed++;
        print('  Pushed: $objectId (${changes.length} changes)');
      }
    }

    // Pull: objects server has that local lacks or has different heads
    int pulled = 0;
    for (final entry in serverHeads.entries) {
      final objectId = entry.key;
      final serverHeadSet = entry.value;
      final localHeadSet = (localHeads[objectId] ?? <String>[]).toSet();

      if (serverHeadSet.difference(localHeadSet).isNotEmpty) {
        // Local is missing some heads -- pull via ObjectSyncStream.
        // Sending empty changes acts as a pull request.
        final responseData =
            bridge.syncObject(handleId, spaceId, objectId, Uint8List(0));

        if (responseData.isNotEmpty) {
          await _storePulledChanges(db, spaceId, objectId, responseData);
          pulled++;
          print('  Pulled: $objectId');
        }
      }
    }

    final (pushedStoreValues, pulledStoreValues) =
        await _syncStoreValues(db, bridge, handleId, spaceId);

    print(
      'Sync complete: pushed $pushed, pulled $pulled objects, '
      'pushed $pushedStoreValues, pulled $pulledStoreValues store values',
    );
  } finally {
    bridge.freeHandle(handleId);
  }
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
  String spaceId,
) async {
  final localEntries = await db.getStoreEntriesBySpace(spaceId);
  final localHeads = <String, String>{
    for (final entry in localEntries) entry.keyPeerId: _storeHeadFromValue(entry.value),
  };

  final storeDiffResponseBytes = bridge.invoke(
    handleId,
    '/spacesync.SpaceSync/StoreDiff',
    StoreDiffRequest(spaceId: spaceId).writeToBuffer(),
  );
  final storeDiffResponse = StoreDiffResponse.fromBuffer(storeDiffResponseBytes);
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
    return (0, 0);
  }

  messages.add(StoreKeyValue());
  final responseData = bridge.syncStore(
    handleId,
    _encodeMessagesForFfi(messages.map((message) => Uint8List.fromList(message.writeToBuffer()))),
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
    return timestamp < 0 ? '00000000000000000000' : timestamp.toString().padLeft(20, '0');
  } catch (_) {
    return '';
  }
}
