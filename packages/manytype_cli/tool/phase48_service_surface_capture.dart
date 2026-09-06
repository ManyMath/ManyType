import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:manytype_cli/src/acl_codec.dart';
import 'package:manytype_cli/src/acl_sync_service.dart';
import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/sync.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/consensus_service.dart';
import 'package:manytype_cli/src/ffi/native_bridge.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/network_config.dart';
import 'package:manytype_cli/src/space_pull_bootstrap.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> argv) async {
  final parser = ArgParser()
    ..addOption('action', mandatory: true)
    ..addOption('network-config')
    ..addOption('server-address', defaultsTo: '127.0.0.1:33020')
    ..addOption('state-in')
    ..addOption('state-out');
  final results = parser.parse(argv);

  final action = results['action'] as String;
  final networkConfigPath = results['network-config'] as String?;
  final serverAddress = results['server-address'] as String;
  final stateIn = results['state-in'] as String?;
  final stateOut = results['state-out'] as String?;

  final output = switch (action) {
    'oracle-acl' => await _runOracleAclCapture(
        networkConfigPath:
            _requireOption('--network-config', networkConfigPath),
      ),
    'local-consensus-bootstrap' => await _runLocalConsensusBootstrap(
        serverAddress: serverAddress,
        stateOut: _requireOption('--state-out', stateOut),
      ),
    'local-consensus-continue' => await _runLocalConsensusContinue(
        serverAddress: serverAddress,
        stateIn: _requireOption('--state-in', stateIn),
      ),
    'local-space-pull-bootstrap' => await _runLocalSpacePullBootstrap(
        networkConfigPath:
            _requireOption('--network-config', networkConfigPath),
        serverAddress: serverAddress,
        stateOut: _requireOption('--state-out', stateOut),
      ),
    'local-space-pull-refetch' => await _runLocalSpacePullRefetch(
        stateIn: _requireOption('--state-in', stateIn),
      ),
    _ => throw StateError('Unsupported --action: $action'),
  };

  stdout.writeln(const JsonEncoder.withIndent('  ').convert(output));
}

Future<Map<String, Object?>> _runOracleAclCapture({
  required String networkConfigPath,
}) async {
  final networkConfig = await loadNetworkConfig(networkConfigPath);
  final coordinatorAddress =
      chooseBestAddress(requireCoordinatorNode(networkConfig).addresses);
  final coordinatorPeerId =
      expectedPeerIdForAddress(coordinatorAddress, config: networkConfig);
  final ownerFixture = await _createSpaceFixture(
    networkConfigPath: networkConfigPath,
    text: 'phase48-oracle-acl-seed',
  );
  final joinerIdentity = await Identity.fromMnemonic(generateMnemonic());
  final ownerBridge = NativeBridge();
  final joinerBridge = NativeBridge();
  int? ownerHandle;
  int? joinerHandle;

  try {
    await _seedSpaceFixture(ownerFixture);
    ownerHandle = ownerBridge.connect(
      coordinatorAddress,
      ownerFixture.identity.seed,
      ownerFixture.identity.accountSeed,
      expectedPeerId: coordinatorPeerId,
    );
    joinerHandle = joinerBridge.connect(
      coordinatorAddress,
      joinerIdentity.seed,
      joinerIdentity.accountSeed,
      expectedPeerId: coordinatorPeerId,
    );

    final ownerService = AclSyncService(invoker: ownerBridge.invoke);
    final joinerService = AclSyncService(invoker: joinerBridge.invoke);
    ownerService.spaceMakeShareable(
      handleId: ownerHandle,
      spaceId: ownerFixture.identity.spaceId,
    );

    final inviteSeed =
        Uint8List.fromList(List<int>.generate(32, (index) => index + 131));
    final inviteKeyPair = await ed25519KeyPairFromSeed(inviteSeed);
    final inviteRecord = await buildAclRecord(
      prevId: ownerFixture.aclRootId,
      aclData: AclData(
        aclContent: [
          AclContentValue(
            invite: AclAccountInvite(
              inviteKey: _marshalEd25519PublicKey(inviteKeyPair.publicKey),
              permissions: AclUserPermissions.Writer,
            ),
          ),
        ],
      ),
      identityPrivateKey: ownerFixture.identity.accountSeed,
    );
    final inviteResponse = ownerService.addRecord(
      handleId: ownerHandle,
      spaceId: ownerFixture.identity.spaceId,
      record: RawRecord.fromBuffer(inviteRecord.payload),
    );

    final inviteSignature = await ed25519Sign(
      inviteSeed,
      joinerIdentity.accountKeyPair.publicKey,
    );
    final joinRecord = await buildAclRecord(
      prevId: inviteResponse.id,
      aclData: AclData(
        aclContent: [
          AclContentValue(
            requestJoin: AclAccountRequestJoin(
              inviteIdentity: _marshalEd25519PublicKey(
                joinerIdentity.accountKeyPair.publicKey,
              ),
              inviteRecordId: inviteResponse.id,
              inviteIdentitySignature: inviteSignature,
              metadata: Uint8List(0),
            ),
          ),
        ],
      ),
      identityPrivateKey: joinerIdentity.accountSeed,
    );
    final joinResponse = joinerService.addRecord(
      handleId: joinerHandle,
      spaceId: ownerFixture.identity.spaceId,
      record: RawRecord.fromBuffer(joinRecord.payload),
    );

    final acceptRecord = await buildAclRecord(
      prevId: joinResponse.id,
      aclData: _buildOracleRequestAcceptAclData(
        accountPublicKey: joinerIdentity.accountKeyPair.publicKey,
        requestRecordId: joinResponse.id,
        permissions: AclUserPermissions.Writer,
      ),
      identityPrivateKey: ownerFixture.identity.accountSeed,
    );
    final acceptResponse = ownerService.addRecord(
      handleId: ownerHandle,
      spaceId: ownerFixture.identity.spaceId,
      record: RawRecord.fromBuffer(acceptRecord.payload),
    );

    final recordsAfterAccept = ownerService.getRecords(
      handleId: ownerHandle,
      spaceId: ownerFixture.identity.spaceId,
    );
    if (recordsAfterAccept.length != 4) {
      throw StateError(
        'Expected 4 ACL records after accept, got ${recordsAfterAccept.length}',
      );
    }
    if (recordsAfterAccept.first.id != ownerFixture.aclRootId) {
      throw StateError(
        'Expected ACL root ${ownerFixture.aclRootId}, got ${recordsAfterAccept.first.id}',
      );
    }

    final tailAfterJoin = ownerService.getRecords(
      handleId: ownerHandle,
      spaceId: ownerFixture.identity.spaceId,
      aclHead: joinResponse.id,
    );
    if (!tailAfterJoin.any((record) => record.id == acceptResponse.id)) {
      throw StateError('AclGetRecords tail did not include the accept record');
    }

    final acceptedState = AclState()
      ..applyRoot(
        _synthesizeAclRootRecord(
          aclRootId: ownerFixture.aclRootId,
          ownerPublicKey: ownerFixture.identity.accountKeyPair.publicKey,
        ),
      );
    for (final record in recordsAfterAccept.skip(1)) {
      acceptedState.applyRecord(await verifyAndDecodeAclRecord(record));
    }
    final joinerHex = _toHex(joinerIdentity.accountKeyPair.publicKey);
    final permission = acceptedState.getPermission(joinerHex);
    final status = acceptedState.getStatus(joinerHex);
    if (permission != AclUserPermissions.Writer ||
        status != AclAccountStatus.active) {
      throw StateError(
        'Decoded ACL state mismatch: permission=$permission status=$status',
      );
    }

    return {
      'action': 'oracle-acl',
      'network_config_path': networkConfigPath,
      'coordinator_address': coordinatorAddress,
      'space_id': ownerFixture.identity.spaceId,
      'acl_root_id': ownerFixture.aclRootId,
      'invite_record_id': inviteResponse.id,
      'join_record_id': joinResponse.id,
      'accept_record_id': acceptResponse.id,
      'record_ids_after_accept':
          recordsAfterAccept.map((record) => record.id).toList(),
      'tail_after_join_ids': tailAfterJoin.map((record) => record.id).toList(),
      'joiner_identity_hex': joinerHex,
      'joiner_permission': permission?.name,
      'joiner_status': status?.name,
    };
  } finally {
    if (ownerHandle != null) {
      ownerBridge.freeHandle(ownerHandle);
    }
    if (joinerHandle != null) {
      joinerBridge.freeHandle(joinerHandle);
    }
    await ownerFixture.dispose();
  }
}

Future<Map<String, Object?>> _runLocalConsensusBootstrap({
  required String serverAddress,
  required String stateOut,
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
              inviteKey: _marshalEd25519PublicKey(
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
          'Later ACL read did not reflect the first consensus record');
    }
    if (tailAfterRoot.length != 1 ||
        tailAfterRoot.single.id != firstResponse.id) {
      throw StateError(
          'Tail ACL read after root did not match the first record');
    }

    await _writeJsonFile(
      stateOut,
      _LocalConsensusState(
        mnemonic: mnemonic,
        spaceId: identity.spaceId,
        rootId: root.id,
        firstRecordId: firstResponse.id,
      ).toJson(),
    );

    return {
      'action': 'local-consensus-bootstrap',
      'server_address': serverAddress,
      'space_id': identity.spaceId,
      'root_id': root.id,
      'first_record_id': firstResponse.id,
      'record_ids_after_first':
          recordsAfterFirst.map((record) => record.id).toList(),
      'tail_after_root_ids': tailAfterRoot.map((record) => record.id).toList(),
      'state_path': stateOut,
    };
  } finally {
    bridge.freeHandle(handleId);
  }
}

Future<Map<String, Object?>> _runLocalConsensusContinue({
  required String serverAddress,
  required String stateIn,
}) async {
  final state = _LocalConsensusState.fromJson(await _readJsonFile(stateIn));
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
    if (recordsBefore.map((record) => record.id).toList().join(',') !=
        [state.rootId, state.firstRecordId].join(',')) {
      throw StateError(
          'Consensus reread before continue did not match persisted state');
    }

    final secondRecord = await buildAclRecord(
      prevId: state.firstRecordId,
      aclData: AclData(
        aclContent: [
          AclContentValue(
            invite: AclAccountInvite(
              inviteKey: _marshalEd25519PublicKey(
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

    return {
      'action': 'local-consensus-continue',
      'server_address': serverAddress,
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
  } finally {
    bridge.freeHandle(handleId);
  }
}

Future<Map<String, Object?>> _runLocalSpacePullBootstrap({
  required String networkConfigPath,
  required String serverAddress,
  required String stateOut,
}) async {
  final fixture = await _createSpaceFixture(
    networkConfigPath: networkConfigPath,
    serverAddress: serverAddress,
    text: 'phase48-space-pull-seed',
  );
  final bridge = NativeBridge();
  int? handleId;

  try {
    await _seedSpaceFixture(fixture);
    handleId = bridge.connect(
      serverAddress,
      fixture.identity.seed,
      fixture.identity.accountSeed,
    );
    final acl = AclSyncService(invoker: bridge.invoke);
    final bootstrap = SpacePullBootstrap(invoker: bridge.invoke);

    acl.spaceMakeShareable(
      handleId: handleId,
      spaceId: fixture.identity.spaceId,
    );
    final inviteRecord = await buildAclRecord(
      prevId: fixture.aclRootId,
      aclData: AclData(
        aclContent: [
          AclContentValue(
            invite: AclAccountInvite(
              inviteKey: _marshalEd25519PublicKey(
                Uint8List.fromList(List<int>.filled(32, 29)),
              ),
              permissions: AclUserPermissions.Reader,
            ),
          ),
        ],
      ),
      identityPrivateKey: fixture.identity.accountSeed,
    );
    final inviteResponse = acl.addRecord(
      handleId: handleId,
      spaceId: fixture.identity.spaceId,
      record: RawRecord.fromBuffer(inviteRecord.payload),
    );

    final result = bootstrap.fetch(
      handleId: handleId,
      spaceId: fixture.identity.spaceId,
    );
    final payload = result.payload;
    final aclRecordIds = result.aclRecords.map((record) => record.id).toList();
    if (!payload.hasSpaceHeader() ||
        payload.spaceHeader.id != fixture.identity.spaceId ||
        payload.aclPayloadId != fixture.aclRootId ||
        result.aclRecords.length != 1 ||
        result.aclRecords.single.id != inviteResponse.id) {
      throw StateError(
        'Initial SpacePull fetch did not match expected continuity: '
        '${jsonEncode({
              'expected_space_id': fixture.identity.spaceId,
              'expected_acl_root_id': fixture.aclRootId,
              'expected_invite_record_id': inviteResponse.id,
              'has_space_header': payload.hasSpaceHeader(),
              'actual_space_header_id':
                  payload.hasSpaceHeader() ? payload.spaceHeader.id : null,
              'actual_acl_payload_id': payload.aclPayloadId,
              'actual_acl_record_ids': aclRecordIds,
            })}',
      );
    }

    await _writeJsonFile(
      stateOut,
      _LocalSpacePullState(
        mnemonic: fixture.config.mnemonic,
        serverAddress: serverAddress,
        spaceId: fixture.identity.spaceId,
        aclRootId: fixture.aclRootId,
        inviteRecordId: inviteResponse.id,
      ).toJson(),
    );

    return {
      'action': 'local-space-pull-bootstrap',
      'network_config_path': networkConfigPath,
      'server_address': serverAddress,
      'space_id': fixture.identity.spaceId,
      'acl_root_id': fixture.aclRootId,
      'invite_record_id': inviteResponse.id,
      'space_header_id': payload.spaceHeader.id,
      'acl_payload_id': payload.aclPayloadId,
      'acl_record_ids': aclRecordIds,
      'state_path': stateOut,
    };
  } finally {
    if (handleId != null) {
      bridge.freeHandle(handleId);
    }
    await fixture.dispose();
  }
}

Future<Map<String, Object?>> _runLocalSpacePullRefetch({
  required String stateIn,
}) async {
  final state = _LocalSpacePullState.fromJson(await _readJsonFile(stateIn));
  final identity = await Identity.fromMnemonic(state.mnemonic);
  final bridge = NativeBridge();
  final handleId =
      bridge.connect(state.serverAddress, identity.seed, identity.accountSeed);

  try {
    final bootstrap = SpacePullBootstrap(invoker: bridge.invoke);
    final result = bootstrap.fetch(handleId: handleId, spaceId: state.spaceId);
    final payload = result.payload;
    final aclRecordIds = result.aclRecords.map((record) => record.id).toList();
    if (!payload.hasSpaceHeader() ||
        payload.spaceHeader.id != state.spaceId ||
        payload.aclPayloadId != state.aclRootId ||
        result.aclRecords.length != 1 ||
        result.aclRecords.single.id != state.inviteRecordId) {
      throw StateError(
        'Restarted SpacePull fetch did not match expected continuity: '
        '${jsonEncode({
              'expected_space_id': state.spaceId,
              'expected_acl_root_id': state.aclRootId,
              'expected_invite_record_id': state.inviteRecordId,
              'has_space_header': payload.hasSpaceHeader(),
              'actual_space_header_id':
                  payload.hasSpaceHeader() ? payload.spaceHeader.id : null,
              'actual_acl_payload_id': payload.aclPayloadId,
              'actual_acl_record_ids': aclRecordIds,
            })}',
      );
    }

    return {
      'action': 'local-space-pull-refetch',
      'server_address': state.serverAddress,
      'space_id': state.spaceId,
      'acl_root_id': state.aclRootId,
      'invite_record_id': state.inviteRecordId,
      'space_header_id': payload.spaceHeader.id,
      'acl_payload_id': payload.aclPayloadId,
      'acl_record_ids': aclRecordIds,
    };
  } finally {
    bridge.freeHandle(handleId);
  }
}

class _SpaceFixture {
  _SpaceFixture({
    required this.homeDir,
    required this.db,
    required this.config,
    required this.identity,
    required this.networkConfigPath,
    required this.aclRootId,
  });

  final Directory homeDir;
  final ManytypeDatabase db;
  final CliConfig config;
  final Identity identity;
  final String networkConfigPath;
  final String aclRootId;

  Future<void> dispose() async {
    await db.close();
    if (homeDir.existsSync()) {
      homeDir.deleteSync(recursive: true);
    }
  }
}

class _LocalConsensusState {
  const _LocalConsensusState({
    required this.mnemonic,
    required this.spaceId,
    required this.rootId,
    required this.firstRecordId,
  });

  final String mnemonic;
  final String spaceId;
  final String rootId;
  final String firstRecordId;

  Map<String, Object?> toJson() => {
        'mnemonic': mnemonic,
        'space_id': spaceId,
        'root_id': rootId,
        'first_record_id': firstRecordId,
      };

  static _LocalConsensusState fromJson(Map<String, Object?> json) {
    return _LocalConsensusState(
      mnemonic: _requireJsonString(json, 'mnemonic'),
      spaceId: _requireJsonString(json, 'space_id'),
      rootId: _requireJsonString(json, 'root_id'),
      firstRecordId: _requireJsonString(json, 'first_record_id'),
    );
  }
}

class _LocalSpacePullState {
  const _LocalSpacePullState({
    required this.mnemonic,
    required this.serverAddress,
    required this.spaceId,
    required this.aclRootId,
    required this.inviteRecordId,
  });

  final String mnemonic;
  final String serverAddress;
  final String spaceId;
  final String aclRootId;
  final String inviteRecordId;

  Map<String, Object?> toJson() => {
        'mnemonic': mnemonic,
        'server_address': serverAddress,
        'space_id': spaceId,
        'acl_root_id': aclRootId,
        'invite_record_id': inviteRecordId,
      };

  static _LocalSpacePullState fromJson(Map<String, Object?> json) {
    return _LocalSpacePullState(
      mnemonic: _requireJsonString(json, 'mnemonic'),
      serverAddress: _requireJsonString(json, 'server_address'),
      spaceId: _requireJsonString(json, 'space_id'),
      aclRootId: _requireJsonString(json, 'acl_root_id'),
      inviteRecordId: _requireJsonString(json, 'invite_record_id'),
    );
  }
}

Future<_SpaceFixture> _createSpaceFixture({
  required String networkConfigPath,
  String serverAddress = '127.0.0.1:33020',
  String text = 'phase48-seed',
}) async {
  final homeDir = Directory.systemTemp.createTempSync('manytype_phase48_');
  final manytypeDir = Directory(p.join(homeDir.path, '.manytype'));
  await manytypeDir.create(recursive: true);

  final config = CliConfig(
    mnemonic: generateMnemonic(),
    serverAddress: serverAddress,
  );
  final db = ManytypeDatabase(p.join(manytypeDir.path, 'store.db'));
  await _runSilently(() => createCommand(text, db, config));
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final aclRootId = await _findAclRootId(db, identity.spaceId);

  return _SpaceFixture(
    homeDir: homeDir,
    db: db,
    config: config,
    identity: identity,
    networkConfigPath: networkConfigPath,
    aclRootId: aclRootId,
  );
}

Future<void> _seedSpaceFixture(_SpaceFixture fixture) {
  return _runSilently(
    () => seedLiveSpaceForSync(
      fixture.db,
      fixture.config,
      networkConfigPath: fixture.networkConfigPath,
    ),
  );
}

Future<T> _runSilently<T>(Future<T> Function() fn) {
  return runZoned(
    fn,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {},
    ),
  );
}

Future<String> _findAclRootId(ManytypeDatabase db, String spaceId) async {
  final objects = await db.getObjectsBySpace(spaceId);
  for (final object in objects) {
    final changes = await db.getChangesForObject(object.id);
    if (changes.isEmpty) continue;
    final aclRoot = tryDecodeAclRootFromRawRecordBytes(
        Uint8List.fromList(changes.first.rawBytes));
    if (aclRoot != null && aclRoot.spaceId == spaceId) {
      return object.id;
    }
  }
  throw StateError('Space bootstrap is missing an ACL root for $spaceId');
}

Future<Map<String, Object?>> _readJsonFile(String path) async {
  final decoded = jsonDecode(await File(path).readAsString());
  if (decoded is! Map<String, Object?>) {
    throw StateError('Expected JSON object in $path');
  }
  return decoded;
}

Future<void> _writeJsonFile(String path, Map<String, Object?> json) {
  return File(path).writeAsString(
    const JsonEncoder.withIndent('  ').convert(json),
  );
}

String _requireOption(String flag, String? value) {
  if (value == null || value.isEmpty) {
    throw StateError('$flag is required');
  }
  return value;
}

String _requireJsonString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw StateError('Missing "$key" in state JSON');
  }
  return value;
}

String _toHex(List<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

Uint8List _marshalEd25519PublicKey(Uint8List publicKey) => Uint8List.fromList(
      Key(
        type: KeyType.Ed25519Public,
        data: publicKey,
      ).writeToBuffer(),
    );

VerifiedAclRecord _synthesizeAclRootRecord({
  required String aclRootId,
  required Uint8List ownerPublicKey,
}) {
  return VerifiedAclRecord(
    id: aclRootId,
    prevId: '',
    identity: ownerPublicKey,
    timestamp: 0,
  );
}

AclData _buildOracleRequestAcceptAclData({
  required Uint8List accountPublicKey,
  required String requestRecordId,
  required AclUserPermissions permissions,
  Uint8List? encryptedReadKey,
}) {
  return AclData(
    aclContent: [
      AclContentValue(
        requestAccept: AclAccountRequestAccept(
          identity: _marshalEd25519PublicKey(accountPublicKey),
          requestRecordId: requestRecordId,
          encryptedReadKey:
              encryptedReadKey ?? Uint8List.fromList(const [1, 18, 7, 42]),
          permissions: permissions,
        ),
      ),
    ],
  );
}
