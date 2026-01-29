import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:manytype_cli/src/acl_sync_service.dart';
import 'package:manytype_cli/src/acl_codec.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/ffi/native_bridge.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/network_config.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/coordinator.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/filesync.dart' as filesync;
import 'package:manytype_protocol/manytype_protocol.dart';

class InviteGenOutput {
  InviteGenOutput({
    required this.inviteFileCid,
    required this.inviteFileKeyBase58,
    required this.inviteBlockBytes,
    required this.inviteKeyPublicProtoBytes,
    required this.encryptedReadKeyBytes,
    required this.inviteUrl,
  });

  final String inviteFileCid;
  final String inviteFileKeyBase58;
  final Uint8List inviteBlockBytes;
  final Uint8List inviteKeyPublicProtoBytes;
  final Uint8List encryptedReadKeyBytes;
  final String inviteUrl;

  static InviteGenOutput fromJson(Map<String, Object?> json) {
    Uint8List decodeBytes(String key) {
      final raw = json[key];
      if (raw is! String || raw.isEmpty) {
        throw StateError('invite json missing "$key"');
      }
      return Uint8List.fromList(base64.decode(raw));
    }

    String decodeString(String key) {
      final raw = json[key];
      if (raw is! String || raw.isEmpty) {
        throw StateError('invite json missing "$key"');
      }
      return raw;
    }

    return InviteGenOutput(
      inviteFileCid: decodeString('invite_file_cid'),
      inviteFileKeyBase58: decodeString('invite_file_key_base58'),
      inviteBlockBytes: decodeBytes('invite_block_base64'),
      inviteKeyPublicProtoBytes: decodeBytes('invite_key_public_proto_base64'),
      encryptedReadKeyBytes: decodeBytes('encrypted_read_key_base64'),
      inviteUrl: decodeString('invite_url'),
    );
  }
}

Future<String> _findAclRootId(ManytypeDatabase db, String spaceId) async {
  final objects = await db.getObjectsBySpace(spaceId);
  for (final object in objects) {
    final changes = await db.getChangesForObject(object.id);
    if (changes.isEmpty) continue;
    final aclRoot =
        tryDecodeAclRootFromRawRecordBytes(Uint8List.fromList(changes.first.rawBytes));
    if (aclRoot != null && aclRoot.spaceId == spaceId) {
      return object.id;
    }
  }
  throw StateError('Space bootstrap is missing an ACL root');
}

Future<void> main(List<String> argv) async {
  final parser = ArgParser()
    ..addOption('network-config', mandatory: true)
    ..addOption('invite-json', mandatory: true)
    ..addOption('permissions',
        defaultsTo: 'writer', help: 'writer (default) or reader');

  final results = parser.parse(argv);
  final networkConfigPath = results['network-config'] as String;
  final inviteJsonPath = results['invite-json'] as String;
  final permissionsRaw = (results['permissions'] as String).toLowerCase().trim();

  final permissions = switch (permissionsRaw) {
    'reader' => AclUserPermissions.Reader,
    'writer' => AclUserPermissions.Writer,
    _ => throw StateError('--permissions must be writer or reader'),
  };

  final inviteJson = jsonDecode(await File(inviteJsonPath).readAsString());
  if (inviteJson is! Map<String, Object?>) {
    throw StateError('invite json must be an object: $inviteJsonPath');
  }
  final invite = InviteGenOutput.fromJson(inviteJson);

  final config = await CliConfig.load();
  final identity = await Identity.fromMnemonic(config.mnemonic);
  final spaceId = identity.spaceId;
  final db = ManytypeDatabase(CliConfig.dbPath);
  final aclRootId = await _findAclRootId(db, spaceId);
  await db.close();

  final networkConfig = await loadNetworkConfig(networkConfigPath);
  final coordinatorAddress =
      chooseBestAddress(requireCoordinatorNode(networkConfig).addresses);
  final fileAddress = chooseBestAddress(requireFileNode(networkConfig).addresses);

  final bridge = NativeBridge();
  final coordinatorHandle =
      bridge.connect(coordinatorAddress, identity.seed, identity.accountSeed);

  var uploadedViaCoordinator = false;
  try {
    final aclService = AclSyncService(invoker: bridge.invoke);
    aclService.spaceMakeShareable(handleId: coordinatorHandle, spaceId: spaceId);

    final inviteRecord = await buildAclRecord(
      prevId: aclRootId,
      aclData: AclData(
        aclContent: [
          AclContentValue(
            invite: AclAccountInvite(
              inviteKey: invite.inviteKeyPublicProtoBytes,
              inviteType: AclInviteType.AnyoneCanJoin,
              permissions: permissions,
              encryptedReadKey: invite.encryptedReadKeyBytes,
            ),
          ),
        ],
      ),
      identityPrivateKey: identity.accountSeed,
    );

    aclService.addRecord(
      handleId: coordinatorHandle,
      spaceId: spaceId,
      record: RawRecord.fromBuffer(inviteRecord.payload),
    );

    try {
      final upload = AclUploadInviteRequest(
        cid: cidToBytes(invite.inviteFileCid),
        data: invite.inviteBlockBytes,
      );
      bridge.invoke(
        coordinatorHandle,
        '/coordinator.Coordinator/AclUploadInvite',
        Uint8List.fromList(upload.writeToBuffer()),
      );
      uploadedViaCoordinator = true;
    } catch (_) {
      // Some deployments (or older servers) may not implement AclUploadInvite.
      // Fall back to direct file-node push below.
      uploadedViaCoordinator = false;
    }
  } finally {
    bridge.freeHandle(coordinatorHandle);
  }

  if (uploadedViaCoordinator) {
    final output = <String, Object?>{
      'space_id': spaceId,
      'acl_root_id': aclRootId,
      'invite_file_cid': invite.inviteFileCid,
      'invite_url': invite.inviteUrl,
      'invite_file_key_base58': invite.inviteFileKeyBase58,
      'network_config': networkConfigPath,
      'coordinator_address': coordinatorAddress,
      'file_address': fileAddress,
      'invite_upload': 'coordinator',
    };

    stdout.writeln(const JsonEncoder.withIndent('  ').convert(output));
    return;
  }

  final fileHandle = bridge.connect(fileAddress, identity.seed, identity.accountSeed);
  try {
    final cidBytes = cidToBytes(invite.inviteFileCid);
    final checkRequest = filesync.BlocksCheckRequest(
      spaceId: spaceId,
      cids: [cidBytes],
    );
    final checkBytes = bridge.invoke(
      fileHandle,
      '/filesync.File/BlocksCheck',
      Uint8List.fromList(checkRequest.writeToBuffer()),
    );
    final check = filesync.BlocksCheckResponse.fromBuffer(checkBytes);
    final exists = check.blocksAvailability.any(
      (entry) =>
          _byteListsEqual(entry.cid, cidBytes) &&
          entry.status != filesync.AvailabilityStatus.NotExists,
    );

    if (!exists) {
      final push = filesync.BlockPushRequest(
        spaceId: spaceId,
        fileId: 'phase31-invite',
        cid: cidBytes,
        data: invite.inviteBlockBytes,
      );
      bridge.invoke(
        fileHandle,
        '/filesync.File/BlockPush',
        Uint8List.fromList(push.writeToBuffer()),
      );
    }
  } finally {
    bridge.freeHandle(fileHandle);
  }

  final output = <String, Object?>{
    'space_id': spaceId,
    'acl_root_id': aclRootId,
    'invite_file_cid': invite.inviteFileCid,
    'invite_url': invite.inviteUrl,
    'invite_file_key_base58': invite.inviteFileKeyBase58,
    'network_config': networkConfigPath,
    'coordinator_address': coordinatorAddress,
    'file_address': fileAddress,
    'invite_upload': 'file-node',
  };

  stdout.writeln(const JsonEncoder.withIndent('  ').convert(output));
}

bool _byteListsEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
