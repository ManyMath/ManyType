@TestOn(
    'vm') // connects to a live consensus node via NativeBridge (FFI): no web transport
@Tags(['round_trip'])
library;

import 'dart:typed_data';

import 'package:manytype_cli/src/consensus_service.dart';
import 'package:manytype_cli/src/ffi/native_bridge.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:test/test.dart';

import 'support/phase17_test_helpers.dart';

void main() {
  late NativeBridge bridge;
  late Identity identity;
  late ConsensusService service;
  late int handleId;

  setUp(() async {
    bridge = NativeBridge();
    identity = await Identity.fromMnemonic(generateMnemonic());
    handleId =
        bridge.connect('127.0.0.1:33020', identity.seed, identity.accountSeed);
    service = ConsensusService(invoker: bridge.invoke);
  });

  tearDown(() {
    bridge.freeHandle(handleId);
  });

  test('logAdd accepts an ACL root over ffi_invoke', () async {
    final root = await buildAclRoot(
      spaceId: identity.spaceId,
      masterKeySeed: identity.accountSeed,
      identityPrivateKey: identity.seed,
      readKey: Uint8List.fromList(List<int>.generate(32, (index) => index + 1)),
    );

    final response = service.logAdd(
      handleId: handleId,
      logId: identity.spaceId,
      record: root,
    );

    expect(response, isA<Ok>());
  }, timeout: const Timeout(Duration(minutes: 1)));

  test('recordAdd returns a server-confirmed id that must be reused', () async {
    final root = await buildAclRoot(
      spaceId: identity.spaceId,
      masterKeySeed: identity.accountSeed,
      identityPrivateKey: identity.seed,
      readKey:
          Uint8List.fromList(List<int>.generate(32, (index) => index + 11)),
    );
    service.logAdd(
      handleId: handleId,
      logId: identity.spaceId,
      record: root,
    );

    final inviteKeyPair = await ed25519KeyPairFromSeed(
      Uint8List.fromList(List<int>.generate(32, (index) => index + 51)),
    );
    final firstRecord = await buildAclRecord(
      prevId: root.id,
      aclData: AclData(
        aclContent: [
          AclContentValue(
            invite: AclAccountInvite(
              inviteKey: marshalEd25519PublicKey(inviteKeyPair.publicKey),
              permissions: AclUserPermissions.Writer,
            ),
          ),
        ],
      ),
      identityPrivateKey: identity.seed,
    );

    final firstResponse = service.recordAdd(
      handleId: handleId,
      logId: identity.spaceId,
      record: RawRecord.fromBuffer(firstRecord.payload),
    );
    expect(firstResponse.id, isNotEmpty);

    final secondInviteKeyPair = await ed25519KeyPairFromSeed(
      Uint8List.fromList(List<int>.generate(32, (index) => index + 91)),
    );
    final secondRecord = await buildAclRecord(
      prevId: firstResponse.id,
      aclData: AclData(
        aclContent: [
          AclContentValue(
            invite: AclAccountInvite(
              inviteKey: marshalEd25519PublicKey(secondInviteKeyPair.publicKey),
              permissions: AclUserPermissions.Reader,
            ),
          ),
        ],
      ),
      identityPrivateKey: identity.seed,
    );

    final secondResponse = service.recordAdd(
      handleId: handleId,
      logId: identity.spaceId,
      record: RawRecord.fromBuffer(secondRecord.payload),
    );
    expect(secondResponse.id, isNotEmpty);
    expect(secondResponse.id, isNot(firstRecord.id));
  }, timeout: const Timeout(Duration(minutes: 1)));
}
