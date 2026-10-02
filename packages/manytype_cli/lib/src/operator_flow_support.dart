import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:manytype_cli/src/acl_codec.dart';
import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/sync.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/private_files.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:path/path.dart' as p;

class EphemeralSpaceFixture {
  EphemeralSpaceFixture({
    required this.homeDir,
    required this.db,
    required this.config,
    required this.identity,
    this.networkConfigPath,
    this.networkConfigContent,
    required this.aclRootId,
  });

  final Directory homeDir;
  final ManytypeDatabase db;
  final CliConfig config;
  final Identity identity;
  final String? networkConfigPath;
  final String? networkConfigContent;
  final String aclRootId;

  Future<void> dispose() async {
    await db.close();
    if (homeDir.existsSync()) {
      homeDir.deleteSync(recursive: true);
    }
  }
}

class ConsensusFlowState {
  const ConsensusFlowState({
    required this.mnemonic,
    required this.serverAddress,
    required this.spaceId,
    required this.rootId,
    required this.firstRecordId,
  });

  final String mnemonic;
  final String serverAddress;
  final String spaceId;
  final String rootId;
  final String firstRecordId;

  Map<String, Object?> toJson() => {
        'mnemonic': mnemonic,
        'server_address': serverAddress,
        'space_id': spaceId,
        'root_id': rootId,
        'first_record_id': firstRecordId,
      };

  static ConsensusFlowState fromJson(Map<String, Object?> json) {
    return ConsensusFlowState(
      mnemonic: requireJsonString(json, 'mnemonic'),
      serverAddress: requireJsonString(json, 'server_address'),
      spaceId: requireJsonString(json, 'space_id'),
      rootId: requireJsonString(json, 'root_id'),
      firstRecordId: requireJsonString(json, 'first_record_id'),
    );
  }
}

class SpacePullFlowState {
  const SpacePullFlowState({
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

  static SpacePullFlowState fromJson(Map<String, Object?> json) {
    return SpacePullFlowState(
      mnemonic: requireJsonString(json, 'mnemonic'),
      serverAddress: requireJsonString(json, 'server_address'),
      spaceId: requireJsonString(json, 'space_id'),
      aclRootId: requireJsonString(json, 'acl_root_id'),
      inviteRecordId: requireJsonString(json, 'invite_record_id'),
    );
  }
}

Future<EphemeralSpaceFixture> createEphemeralSpaceFixture({
  String? networkConfigPath,
  String? networkConfigContent,
  String serverAddress = '127.0.0.1:33020',
  String text = 'operator-flow-seed',
}) async {
  final homeDir = Directory.systemTemp.createTempSync('manytype_operator_');
  final manytypeDir = Directory(p.join(homeDir.path, '.manytype'));
  await manytypeDir.create(recursive: true);

  final config = CliConfig(
    mnemonic: generateMnemonic(),
    serverAddress: serverAddress,
  );
  final db = ManytypeDatabase(p.join(manytypeDir.path, 'store.db'));
  await runSilently(() => createCommand(text, db, config));
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final aclRootId = await findAclRootId(db, identity.spaceId);

  return EphemeralSpaceFixture(
    homeDir: homeDir,
    db: db,
    config: config,
    identity: identity,
    networkConfigPath: networkConfigPath,
    networkConfigContent: networkConfigContent,
    aclRootId: aclRootId,
  );
}

Future<void> seedEphemeralSpaceFixture(EphemeralSpaceFixture fixture) {
  return runSilently(
    () => seedLiveSpaceForSync(
      fixture.db,
      fixture.config,
      networkConfigPath: fixture.networkConfigPath,
      networkConfigContent: fixture.networkConfigContent,
    ),
  );
}

Future<String> findAclRootId(ManytypeDatabase db, String spaceId) async {
  final objects = await db.getObjectsBySpace(spaceId);
  for (final object in objects) {
    final changes = await db.getChangesForObject(object.id);
    if (changes.isEmpty) continue;
    final aclRoot = tryDecodeAclRootFromRawRecordBytes(
      Uint8List.fromList(changes.first.rawBytes),
    );
    if (aclRoot != null && aclRoot.spaceId == spaceId) {
      return object.id;
    }
  }
  throw StateError('Space bootstrap is missing an ACL root for $spaceId');
}

Future<T> runSilently<T>(Future<T> Function() fn) {
  return runZoned(
    fn,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {},
    ),
  );
}

Future<Map<String, Object?>> readJsonFile(String path) async {
  final decoded = jsonDecode(await File(path).readAsString());
  if (decoded is! Map<String, Object?>) {
    throw StateError('Expected JSON object in $path');
  }
  return decoded;
}

/// Writes [json] with owner-only permissions: continuation state carries the
/// account mnemonic.
Future<void> writeJsonFile(String path, Map<String, Object?> json) {
  return writePrivateFileAtomically(
    path,
    const JsonEncoder.withIndent('  ').convert(json),
  );
}

String requireJsonString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw StateError('Missing "$key" in JSON payload');
  }
  return value;
}

String toHex(List<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

Uint8List marshalEd25519PublicKey(Uint8List publicKey) => Uint8List.fromList(
      Key(
        type: KeyType.Ed25519Public,
        data: publicKey,
      ).writeToBuffer(),
    );

VerifiedAclRecord synthesizeAclRootRecord({
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

AclData buildOracleRequestAcceptAclData({
  required Uint8List accountPublicKey,
  required String requestRecordId,
  required AclUserPermissions permissions,
  Uint8List? encryptedReadKey,
}) {
  return AclData(
    aclContent: [
      AclContentValue(
        requestAccept: AclAccountRequestAccept(
          identity: marshalEd25519PublicKey(accountPublicKey),
          requestRecordId: requestRecordId,
          encryptedReadKey:
              encryptedReadKey ?? Uint8List.fromList(const [1, 18, 7, 42]),
          permissions: permissions,
        ),
      ),
    ],
  );
}
