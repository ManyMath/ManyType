import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:libcompress/src/snappy/snappy_codec.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/changes.dart' as changes_proto;
import 'package:manytype_protocol/coordinator.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:manytype_protocol/spacesync.dart';

import 'acl_codec.dart';
import 'config.dart';
import 'identity.dart';
import 'network_config.dart';
import 'store/database.dart';
import 'ffi/native_bridge.dart';
import 'head_sync_client.dart';
import 'sync_capture.dart';

final _snappy = SnappyCodec();

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
    required this.syncAddresses,
    required this.fileAddress,
    required this.spaceStatus,
  });

  final NetworkConfigurationResponse networkConfig;
  final String syncAddress;
  final List<String> syncAddresses;
  final String? fileAddress;
  final SpaceStatusPayload spaceStatus;
}

class SyncService {
  /// Sync local objects with the remote Rust server.
  ///
  /// Performs the full protocol flow:
  /// 1. Connect via FFI (QUIC + credential handshake)
  /// 2. NetworkConfiguration RPC to coordinator (per D-12: must be first)
  /// 3. SpacePush to ensure server knows our space
  /// 4. HeadSync to get server's object heads
  /// 5. Diff-based push/pull (per D-13)
  Future<void> sync(
    ManytypeDatabase db,
    CliConfig config, {
    String? networkConfigPath,
  }) async {
    final officialInteropMode = networkConfigPath != null;
    final identity = await Identity.fromMnemonic(config.mnemonic);
    final spaceId = identity.spaceId;
    final accountPrivRaw = Uint8List(64)
      ..setRange(0, 32, identity.accountSeed)
      ..setRange(32, 64, identity.accountKeyPair.publicKey);
    final spaceKey = await deriveSpaceKey(accountPrivRaw);
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
    final syncHandleIds = <int>[];
    var syncAddresses = <String>[];

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
      print(
          'Network: ${netConfig.networkId}, nodes: ${netConfig.nodes.length}');
      syncAddresses = discovery.syncAddresses;
      if (officialInteropMode && syncAddresses.isNotEmpty) {
        print('Tree nodes: ${syncAddresses.join(", ")}');
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
        syncHandleIds.add(coordinatorHandleId);
      } else {
        if (syncAddresses.isEmpty) {
          throw StateError(
              'Coordinator response did not include a tree node address');
        }
        for (final address in syncAddresses) {
          print('Connecting to sync node at $address...');
          final handleId =
              bridge.connect(address, identity.seed, identity.accountSeed);
          syncHandleIds.add(handleId);
          print('Connected to sync node (handle: $handleId)');
          capture.recordConnection(role: 'sync-node', address: address);
        }
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
        final pushRequestBytes =
            Uint8List.fromList(pushRequest.writeToBuffer());
        for (final handleId in syncHandleIds) {
          bridge.invoke(
            handleId,
            '/spacesync.SpaceSync/SpacePush',
            pushRequestBytes,
          );
        }
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
      var serverHeads = <String, Set<String>>{};
      for (final handleId in syncHandleIds) {
        final heads = headSyncClient.fetchServerHeads(handleId, spaceId);
        for (final entry in heads.entries) {
          serverHeads
              .putIfAbsent(entry.key, () => <String>{})
              .addAll(entry.value);
        }
      }
      print(
          'Server has ${serverHeads.length} objects: ${serverHeads.keys.join(", ")}');

      // Step 6: Compare local vs server heads
      final localHeads = await db.getSpaceHeads(spaceId);

      int pushed = 0;
      int pulled = 0;
      final pushedObjectIds = <String>[];
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

          if (changes.isEmpty) {
            continue;
          }

          // Official any-sync nodes expect ObjectSyncStream payloads to be raw
          // `TreeSyncMessage` bytes (wrapped by FFI into ObjectSyncMessage).
          //
          // HeadSync V3 gives us per-object hash summaries, not authoritative
          // per-node CID ancestry. Sending only the latest local head based on
          // that hash view is unsafe: a responsible sync node can still be
          // missing an intermediate parent and silently drop the child delta.
          //
          // Keep the official envelope shape (rootChange + headUpdate), but
          // send the full non-root chain in causal order so every sync node
          // receives a replayable ancestry closure for the advertised heads.
          final payloads = <Uint8List>[
            Uint8List.fromList(
              (officialInteropMode
                      ? _buildOfficialTreeHeadUpdateMessage(
                          changes,
                        )
                      : _buildTreeSyncMessage(objectId, changes))
                  .writeToBuffer(),
            ),
          ];

          var pushSucceeded = false;
          String? lastError;
          for (var i = 0; i < syncHandleIds.length; i++) {
            final handleId = syncHandleIds[i];
            try {
              Uint8List responseData = Uint8List(0);
              for (final payload in payloads) {
                responseData =
                    bridge.syncObject(handleId, spaceId, objectId, payload);
                capture.recordStreamRpc(
                  role: 'sync-node',
                  method: '/spacesync.SpaceSync/ObjectSyncStream',
                  requestMessages: [payload],
                  responseMessages: _decodeMessagesFromFfi(responseData),
                );
              }

              // If the node returns an explicit TreeErrorResponse, try the next one.
              final responseMessages = _decodeMessagesFromFfi(responseData);
              var sawError = false;
              for (final msgBytes in responseMessages) {
                try {
                  final msg = ObjectSyncMessage.fromBuffer(msgBytes);
                  if (msg.payload.isEmpty) continue;
                  final treeMsg = TreeSyncMessage.fromBuffer(msg.payload);
                  if (treeMsg.hasContent() &&
                      treeMsg.content.hasErrorResponse() &&
                      treeMsg.content.errorResponse.errCode != 0) {
                    lastError = treeMsg.content.errorResponse.error;
                    sawError = true;
                    break;
                  }
                } catch (_) {
                  continue;
                }
              }
              if (sawError) {
                continue;
              }

              pushSucceeded = true;
              // Still fan out to the remaining sync nodes. Official any-sync
              // deployments can assign responsibility per object/tree; sending
              // only to the first reachable node can silently miss the
              // responsible peer, leaving mandatory derived trees absent and
              // joined spaces unloadable.
              continue;
            } catch (error) {
              lastError = error.toString();
              continue;
            }
          }
          if (!pushSucceeded) {
            throw StateError(
              'ObjectSyncStream push failed for $objectId${lastError != null ? ": $lastError" : ""}',
            );
          }
          pushed++;
          pushedObjectIds.add(objectId);
          print('  Pushed: $objectId (${changes.length} changes)');
        }
      }

      if (officialInteropMode) {
        final postPushHeads = <String, Set<String>>{};
        for (final handleId in syncHandleIds) {
          final heads = headSyncClient.fetchServerHeads(handleId, spaceId);
          for (final entry in heads.entries) {
            postPushHeads
                .putIfAbsent(entry.key, () => <String>{})
                .addAll(entry.value);
          }
        }
        print('After push: server has ${postPushHeads.length} objects');
        // Pull should be based on the post-push head snapshot, otherwise the
        // following pull loop can re-fetch stale heads and reorder local
        // change insertion (ManytypeDatabase.getObjectHeads currently uses
        // "last inserted change" heuristics), breaking immediate verification.
        serverHeads = postPushHeads;
        final missingAfterPush = localHeads.entries.where((entry) {
          final remote = postPushHeads[entry.key] ?? <String>{};
          return entry.value.toSet().difference(remote).isNotEmpty;
        }).length;
        capture.recordNote(
          'official-post-push-summary',
          {
            'server_object_count': postPushHeads.length,
            'still_missing_count': missingAfterPush,
          },
        );

        for (final objectId in pushedObjectIds) {
          final refreshed = await _pullObjectFromSyncNodes(
            db,
            bridge,
            syncHandleIds,
            spaceId,
            objectId,
            capture: capture,
            spaceKey: spaceKey,
          );
          if (refreshed) {
            pulled++;
            print('  Reconciled pushed object: $objectId');
          }
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

          final responseChunks = <Uint8List>[];
          for (final handleId in syncHandleIds) {
            try {
              final resp = bridge.requestObject(
                  handleId, spaceId, objectId, pullPayload);
              if (resp.isNotEmpty) {
                responseChunks.add(resp);
                capture.recordStreamRpc(
                  role: 'sync-node',
                  method: '/spacesync.SpaceSync/ObjectSyncRequestStream',
                  requestMessages: [pullPayload],
                  responseMessages: _decodeMessagesFromFfi(resp),
                );
              }
            } catch (_) {
              continue;
            }
          }

          final responseData = _mergeFfiResponseChunks(responseChunks);

          if (responseData.isNotEmpty) {
            await storePulledChanges(
              db,
              spaceId,
              objectId,
              responseData,
              spaceKey: spaceKey,
            );
            pulled++;
            print('  Pulled: $objectId');
          }
        }
      }

      await _ensureBootstrapStoreEntry(db, identity, spaceId);
      var pushedStoreValues = 0;
      var pulledStoreValues = 0;
      for (final handleId in syncHandleIds) {
        try {
          final (pushed, pulled) = await _syncStoreValues(
            db,
            bridge,
            handleId,
            spaceId,
            capture: capture,
          );
          pushedStoreValues += pushed;
          pulledStoreValues += pulled;
        } catch (error) {
          // Store sync is a best-effort enhancement for official interop; tree
          // sync is the critical path for cross-authored verification.
          capture.recordNote('store-sync-error', {'message': error.toString()});
          print('WARN: store sync failed for handle=$handleId: $error');
        }
      }

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
      for (final handleId in syncHandleIds) {
        if (handleId == coordinatorHandleId) {
          continue;
        }
        bridge.freeHandle(handleId);
      }
      bridge.freeHandle(coordinatorHandleId);
      await capture.flush();
    }
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
    final syncHandleIds = <int>[];

    try {
      coordinatorHandleId = bridge.connect(
          coordinatorAddress, identity.seed, identity.accountSeed);
      final netConfigBytes = bridge.invoke(
        coordinatorHandleId,
        '/coordinator.Coordinator/NetworkConfiguration',
        Uint8List.fromList(NetworkConfigurationRequest().writeToBuffer()),
      );
      final netConfig = NetworkConfigurationResponse.fromBuffer(netConfigBytes);
      final syncAddresses = chooseTreeAddressesFromResponse(netConfig.nodes);
      if (syncAddresses.isEmpty) {
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

      final bootstrap = await _loadSpaceBootstrap(db, identity.spaceId);
      if (bootstrap == null) {
        throw StateError('Local space bootstrap data is missing');
      }

      final payload = SpacePayload(
        spaceHeader: identity.spaceHeader,
        aclPayload: Uint8List.fromList(bootstrap.aclPayload),
        aclPayloadId: bootstrap.aclPayloadId,
        spaceSettingsPayload:
            Uint8List.fromList(bootstrap.spaceSettingsPayload),
        spaceSettingsPayloadId: bootstrap.spaceSettingsPayloadId,
      );
      final pushRequest = SpacePushRequest(
        payload: payload,
        credential: signResponse.receipt.writeToBuffer(),
      );
      final pushBytes = Uint8List.fromList(pushRequest.writeToBuffer());
      for (final address in syncAddresses) {
        final handleId =
            bridge.connect(address, identity.seed, identity.accountSeed);
        syncHandleIds.add(handleId);
        bridge.invoke(
          handleId,
          '/spacesync.SpaceSync/SpacePush',
          pushBytes,
        );
      }
    } finally {
      for (final handleId in syncHandleIds) {
        bridge.freeHandle(handleId);
      }
      if (coordinatorHandleId != null) {
        bridge.freeHandle(coordinatorHandleId);
      }
    }
  }
}

Future<bool> _pullObjectFromSyncNodes(
  ManytypeDatabase db,
  NativeBridge bridge,
  List<int> syncHandleIds,
  String spaceId,
  String objectId, {
  required _SessionCapture capture,
  Uint8List? spaceKey,
}) async {
  final localHeadSet = (await db.getObjectHeads(objectId)).toSet();
  final localChanges = await db.getChangesForObject(objectId);
  Change? rootChange;
  for (final change in localChanges) {
    final parentHeads = _decodeParentHeads(change);
    if (parentHeads.isEmpty && rootChange == null) {
      rootChange = change;
    }
  }

  final requestMsg = TreeSyncMessage(
    content: TreeSyncContentValue(
      fullSyncRequest: TreeFullSyncRequest(
        heads: localHeadSet.toList(),
        changes: const [],
        snapshotPath: _buildOfficialSnapshotPath(
          localChanges,
          rootChange,
          localHeadSet.toList(),
        ),
      ),
    ),
  );
  final pullPayload = Uint8List.fromList(requestMsg.writeToBuffer());

  final responseChunks = <Uint8List>[];
  for (final handleId in syncHandleIds) {
    try {
      final resp =
          bridge.requestObject(handleId, spaceId, objectId, pullPayload);
      if (resp.isNotEmpty) {
        responseChunks.add(resp);
        capture.recordStreamRpc(
          role: 'sync-node',
          method: '/spacesync.SpaceSync/ObjectSyncRequestStream',
          requestMessages: [pullPayload],
          responseMessages: _decodeMessagesFromFfi(resp),
        );
      }
    } catch (_) {
      continue;
    }
  }

  final responseData = _mergeFfiResponseChunks(responseChunks);

  if (responseData.isEmpty) {
    return false;
  }

  await storePulledChanges(
    db,
    spaceId,
    objectId,
    responseData,
    spaceKey: spaceKey,
  );
  return true;
}

Uint8List _mergeFfiResponseChunks(List<Uint8List> chunks) {
  if (chunks.isEmpty) {
    return Uint8List(0);
  }
  if (chunks.length == 1) {
    return chunks.single;
  }
  final builder = BytesBuilder(copy: false);
  for (final chunk in chunks) {
    builder.add(chunk);
  }
  return builder.takeBytes();
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

  final syncAddresses = officialInteropMode
      ? chooseTreeAddressesFromResponse(netConfig.nodes)
      : [localServerAddress];
  final String? syncAddress = officialInteropMode
      ? (syncAddresses.isNotEmpty ? syncAddresses.first : null)
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
    syncAddresses: syncAddresses,
    fileAddress: fileAddress,
    spaceStatus: payload,
  );
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
      final aclRoot = tryDecodeAclRootFromRawRecordBytes(rawBytes);
      if (aclRoot != null && aclRoot.spaceId == spaceId) {
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
          (rootChange.changeType == 'anytype.space' ||
              rootChange.changeType == 'any-sync.space')) {
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
  Uint8List data, {
  Uint8List? spaceKey,
}) async {
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
        spaceKey: spaceKey,
      );
      if (stored) {
        continue;
      }

      await _storeRawPulledChange(
        db,
        spaceId,
        objectId,
        msgBytes,
        spaceKey: spaceKey,
      );
    }
  }

  if (spaceKey != null && await _isSpaceSettingsObject(db, objectId, spaceId)) {
    await _applyPulledSettingsDeletes(db, objectId, spaceKey);
  }
}

Future<bool> _storePulledMessageBytes(
  ManytypeDatabase db,
  String spaceId,
  String objectId,
  Uint8List msgBytes, {
  Uint8List? spaceKey,
}) async {
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
        spaceKey: spaceKey,
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
  Uint8List? spaceKey,
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

Future<bool> _isSpaceSettingsObject(
  ManytypeDatabase db,
  String objectId,
  String spaceId,
) async {
  final changes = await db.getChangesForObject(objectId);
  for (final change in changes) {
    try {
      final rawTreeChange = RawTreeChange.fromBuffer(change.rawBytes);
      if (rawTreeChange.payload.isEmpty) {
        continue;
      }
      final rootChange = RootChange.fromBuffer(rawTreeChange.payload);
      if (rootChange.spaceId == spaceId &&
          (rootChange.changeType == 'anytype.space' ||
              rootChange.changeType == 'any-sync.space')) {
        return true;
      }
    } catch (_) {
      continue;
    }
  }
  return false;
}

Future<void> _applyPulledSettingsDeletes(
  ManytypeDatabase db,
  String settingsObjectId,
  Uint8List spaceKey,
) async {
  final treeKey = await deriveTreeKey(spaceKey, settingsObjectId);
  final changes = await db.getChangesForObject(settingsObjectId);
  for (final change in changes) {
    final deletedIds = await _extractDeletedObjectIdsFromSettingsChange(
        change.rawBytes, treeKey);
    for (final deletedId in deletedIds) {
      await db.markObjectDeleted(deletedId);
    }
  }
}

Future<List<String>> _extractDeletedObjectIdsFromSettingsChange(
  List<int> rawChangeBytes,
  Uint8List treeKey,
) async {
  try {
    final rawTreeChange = RawTreeChange.fromBuffer(rawChangeBytes);
    if (rawTreeChange.payload.isEmpty) {
      return const [];
    }

    final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
    if (treeChange.changesData.isEmpty) {
      return const [];
    }

    var payload = Uint8List.fromList(treeChange.changesData);
    if (treeChange.readKeyId.isNotEmpty) {
      payload = await aesGcmDecrypt(treeKey, payload);
    }
    if (treeChange.dataType == '1/s') {
      payload = _snappy.decompress(payload);
    }

    final settingsData = SettingsData.fromBuffer(payload);
    return settingsData.content
        .where((content) => content.hasObjectDelete())
        .map((content) => content.objectDelete.id.trim())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
  } catch (_) {
    return const [];
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
      final aclRoot = tryDecodeAclRootFromRawRecordBytes(
          Uint8List.fromList(changes.first.rawBytes));
      if (aclRoot != null && aclRoot.spaceId == spaceId) {
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
    if (rawTreeChange.payload.isEmpty) {
      return const [];
    }

    // Root changes carry a `RootChange` payload, not `TreeChange`. In Dart,
    // decoding a RootChange payload as TreeChange does not reliably throw, and
    // can incorrectly treat `aclHeadId` as a parent head, breaking root
    // detection in the edit flow.
    try {
      final root = RootChange.fromBuffer(rawTreeChange.payload);
      if (root.spaceId.isNotEmpty && root.changeType.isNotEmpty) {
        return const [];
      }
    } catch (_) {
      // ignore: fall through to TreeChange decode
    }

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
      path: readSyncCapturePath(),
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
    final encoder = JsonEncoder.withIndent('  ');
    await writeSyncCaptureFile(path!, '${encoder.convert(_payload)}\n');
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

TreeSyncMessage _buildTreeSyncMessage(
  String objectId,
  List<Change> changes,
) {
  if (changes.isEmpty) {
    return TreeSyncMessage();
  }

  final parentIds = <String>{};
  for (final c in changes) {
    parentIds.addAll(jsonDecode(c.parentHeads).cast<String>());
  }
  final heads =
      changes.map((c) => c.id).where((id) => !parentIds.contains(id)).toList();

  final changesList = changes
      .map((c) => RawTreeChangeWithId(
            id: c.id,
            rawChange: c.rawBytes,
          ))
      .toList(growable: false);

  final contentValue = TreeSyncContentValue(
    headUpdate: TreeHeadUpdate(
      heads: heads,
      changes: changesList,
    ),
  );

  return TreeSyncMessage(
    content: contentValue,
  );
}

TreeSyncMessage _buildOfficialTreeHeadUpdateMessage(
  List<Change> changes,
) {
  if (changes.isEmpty) {
    return TreeSyncMessage();
  }

  final parentIds = <String>{};
  for (final change in changes) {
    parentIds.addAll(_decodeParentHeads(change));
  }
  final heads = changes
      .map((change) => change.id)
      .where((id) => !parentIds.contains(id))
      .toList();

  if (heads.isEmpty) {
    return TreeSyncMessage();
  }

  Change? rootChange;
  for (final change in changes) {
    final parentHeads = _decodeParentHeads(change);
    if (parentHeads.isEmpty && rootChange == null) {
      rootChange = change;
    }
  }

  // Upstream any-sync's HeadUpdate apply path consumes the streamed
  // `changes` plus `snapshotPath`; it does not rebuild ancestry from
  // `rootChange` alone. Include the root in-band so new trees can materialize
  // on official nodes.
  final headChanges = changes
      .map(
        (change) => RawTreeChangeWithId(
          id: change.id,
          rawChange: change.rawBytes,
        ),
      )
      .toList(growable: false);

  final headUpdate = TreeHeadUpdate(
    heads: heads,
    changes: headChanges,
    snapshotPath: _buildOfficialSnapshotPath(changes, rootChange, heads),
  );

  return TreeSyncMessage(
    rootChange: rootChange != null
        ? RawTreeChangeWithId(
            id: rootChange.id,
            rawChange: rootChange.rawBytes,
          )
        : null,
    content: TreeSyncContentValue(headUpdate: headUpdate),
  );
}

List<String> _decodeParentHeads(Change change) =>
    (jsonDecode(change.parentHeads) as List).cast<String>();

List<String> _buildOfficialSnapshotPath(
  List<Change> changes,
  Change? rootChange,
  List<String> heads,
) {
  if (rootChange == null) {
    return const [];
  }

  final rootId = rootChange.id;
  final treeInfoById = <String, _TreeChangeInfo>{};
  for (final change in changes) {
    final info = _decodeTreeChangeInfo(change);
    if (info != null) {
      treeInfoById[change.id] = info;
    }
  }

  String? snapshotId;
  for (final head in heads) {
    final info = treeInfoById[head];
    if (info == null) {
      continue;
    }
    if (info.isSnapshot) {
      snapshotId = head;
      break;
    }
    if (info.snapshotBaseId.isNotEmpty && info.snapshotBaseId != rootId) {
      snapshotId = info.snapshotBaseId;
      break;
    }
  }

  snapshotId ??= changes.reversed
      .map((change) => (id: change.id, info: _decodeTreeChangeInfo(change)))
      .firstWhere(
        (entry) => entry.info?.isSnapshot == true,
        orElse: () => (id: rootId, info: null),
      )
      .id;

  if (snapshotId.isEmpty || snapshotId == rootId) {
    return [rootId];
  }

  final path = <String>[];
  final seen = <String>{};
  var currentId = snapshotId;
  while (currentId.isNotEmpty && seen.add(currentId)) {
    path.add(currentId);
    if (currentId == rootId) {
      break;
    }
    final nextId = treeInfoById[currentId]?.snapshotBaseId ?? '';
    if (nextId.isEmpty) {
      break;
    }
    currentId = nextId;
  }

  if (path.isEmpty || path.last != rootId) {
    path.add(rootId);
  }
  return path;
}

_TreeChangeInfo? _decodeTreeChangeInfo(Change change) {
  try {
    final rawTreeChange = RawTreeChange.fromBuffer(change.rawBytes);
    if (rawTreeChange.payload.isEmpty) {
      return null;
    }
    final treeChange = TreeChange.fromBuffer(rawTreeChange.payload);
    return _TreeChangeInfo(
      isSnapshot: treeChange.isSnapshot,
      snapshotBaseId: treeChange.snapshotBaseId,
    );
  } catch (_) {
    return null;
  }
}

class _TreeChangeInfo {
  const _TreeChangeInfo({
    required this.isSnapshot,
    required this.snapshotBaseId,
  });

  final bool isSnapshot;
  final String snapshotBaseId;
}

HeadSyncRange _fullHeadSyncRange({required bool elements}) => HeadSyncRange(
      from: Int64.ZERO,
      to: Int64.parseHex('ffffffffffffffff'),
      elements: elements,
    );
