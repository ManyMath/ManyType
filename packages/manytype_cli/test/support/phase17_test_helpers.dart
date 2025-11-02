import 'dart:io';
import 'dart:typed_data';

import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/commands/sync.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_core/manytype_core.dart'
    show VerifiedAclRecord, generateMnemonic;
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:path/path.dart' as p;

class Phase17SpaceFixture {
  Phase17SpaceFixture({
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

Future<Phase17SpaceFixture> createPhase17Fixture({
  required String networkConfigPath,
  String serverAddress = '127.0.0.1:33020',
  String text = 'phase17-seed',
}) async {
  final homeDir = Directory.systemTemp.createTempSync('manytype_phase17_');
  final manytypeDir = Directory(p.join(homeDir.path, '.manytype'));
  await manytypeDir.create(recursive: true);

  final config = CliConfig(
    mnemonic: generateMnemonic(),
    serverAddress: serverAddress,
  );
  final db = ManytypeDatabase(p.join(manytypeDir.path, 'store.db'));
  await createCommand(text, db, config);
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final aclRootId = await findAclRootId(db, identity.spaceId);

  return Phase17SpaceFixture(
    homeDir: homeDir,
    db: db,
    config: config,
    identity: identity,
    networkConfigPath: networkConfigPath,
    aclRootId: aclRootId,
  );
}

Future<void> seedPhase17Fixture(Phase17SpaceFixture fixture) {
  return seedLiveSpaceForSync(
    fixture.db,
    fixture.config,
    networkConfigPath: fixture.networkConfigPath,
  );
}

Future<String> writeLocalNetworkConfig(
  Directory dir, {
  String address = '127.0.0.1:33020',
}) async {
  final path = p.join(dir.path, 'local-network.yml');
  await File(path).writeAsString('''
id: local-phase17
networkId: manytype-dev
nodes:
  - peerId: local
    addresses:
      - quic://$address
    types:
      - coordinator
      - tree
      - consensus
''');
  return path;
}

Future<String> findAclRootId(ManytypeDatabase db, String spaceId) async {
  final objects = await db.getObjectsBySpace(spaceId);
  for (final object in objects) {
    final changes = await db.getChangesForObject(object.id);
    if (changes.isEmpty) continue;
    try {
      final rawRecord =
          RawRecord.fromBuffer(Uint8List.fromList(changes.first.rawBytes));
      final aclRoot = AclRoot.fromBuffer(rawRecord.payload);
      if (aclRoot.spaceId == spaceId) {
        return object.id;
      }
    } catch (_) {
      // Ignore non-ACL root objects.
    }
  }
  throw StateError('Space bootstrap is missing an ACL root for $spaceId');
}

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

AclData buildOracleAccountRemoveAclData({
  required List<Uint8List> removedAccountPublicKeys,
  required List<Uint8List> activeAccountPublicKeys,
  List<Uint8List> activeInvitePublicKeys = const [],
  Uint8List? metadataPublicKey,
  Uint8List? encryptedMetadataPrivateKey,
  Uint8List? encryptedOldReadKey,
}) {
  final metadataKey = metadataPublicKey ??
      (activeAccountPublicKeys.isNotEmpty
          ? activeAccountPublicKeys.first
          : throw ArgumentError('activeAccountPublicKeys cannot be empty'));

  return AclData(
    aclContent: [
      AclContentValue(
        accountRemove: AclAccountRemove(
          identities: removedAccountPublicKeys
              .map(marshalEd25519PublicKey)
              .toList(growable: false),
          readKeyChange: AclReadKeyChange(
            accountKeys: activeAccountPublicKeys
                .map(
                  (publicKey) => AclEncryptedReadKey(
                    identity: marshalEd25519PublicKey(publicKey),
                    encryptedReadKey:
                        Uint8List.fromList(const [2, 9, 26, 81, 3]),
                  ),
                )
                .toList(growable: false),
            metadataPubKey: marshalEd25519PublicKey(metadataKey),
            encryptedMetadataPrivKey: encryptedMetadataPrivateKey ??
                Uint8List.fromList(const [3, 14, 15, 92]),
            encryptedOldReadKey:
                encryptedOldReadKey ?? Uint8List.fromList(const [4, 65, 35]),
            inviteKeys: activeInvitePublicKeys
                .map(
                  (publicKey) => AclEncryptedReadKey(
                    identity: marshalEd25519PublicKey(publicKey),
                    encryptedReadKey:
                        Uint8List.fromList(const [5, 35, 89, 144]),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ),
    ],
  );
}
