import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_cli/src/identity.dart';
import 'package:manytype_cli/src/peer_id.dart';
import 'package:manytype_protocol/manytype_protocol.dart' show Key, KeyType;
import 'package:manytype_protocol/spacesync.dart';
import 'package:test/test.dart';

void main() {
  // Known BIP-39 test vector mnemonic
  const testMnemonic =
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
  const highBitReplicationMnemonic =
      'guilt universe cup credit night tissue pencil window brother ecology marriage over';

  group('Identity', () {
    test('derives 32-byte account and identity seeds from mnemonic', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      expect(identity.accountSeed.length, 32);
      expect(identity.seed.length, 32);
    });

    test('derives 32-byte peerId from mnemonic', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      expect(identity.peerId.length, 32);
    });

    test('derives libp2p peer ID string from mnemonic', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      final peerId = encodeLibp2pPeerId(identity.keyPair.publicKey);
      expect(peerId, matches(RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$')));
      expect(peerId.length, greaterThan(40));
    });

    test('recognises libp2p peer IDs and rejects placeholders', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      expect(
        isLibp2pPeerId(encodeLibp2pPeerId(identity.keyPair.publicKey)),
        isTrue,
      );
      expect(
        isLibp2pPeerId('QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N'),
        isTrue,
      );
      for (final placeholder in [
        '',
        'local',
        'coordinator',
        'tree-peer',
        '12D3KooW',
      ]) {
        expect(isLibp2pPeerId(placeholder), isFalse, reason: placeholder);
      }
    });

    test('derivation is deterministic', () async {
      final identity1 = await Identity.fromMnemonic(testMnemonic);
      final identity2 = await Identity.fromMnemonic(testMnemonic);
      expect(identity1.accountSeed, identity2.accountSeed);
      expect(identity1.peerId, identity2.peerId);
      expect(identity1.seed, identity2.seed);
      expect(identity1.spaceId, identity2.spaceId);
    });

    test('account and identity keys are distinct', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      expect(identity.accountSeed, isNot(equals(identity.seed)));
      expect(identity.accountKeyPair.publicKey,
          isNot(equals(identity.keyPair.publicKey)));
    });

    test('spaceId is derived from raw space header CID and replication key',
        () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      expect(identity.spaceId, matches(RegExp(r'^bafy[a-z2-7]+\.[0-9a-z]+$')));
      expect(identity.spaceHeader.id, identity.spaceId);
      expect(identity.spaceHeader.rawHeader, isNotEmpty);
    });

    test('spaceId uses unsigned base36 replication keys', () async {
      final identity = await Identity.fromMnemonic(highBitReplicationMnemonic);
      expect(identity.spaceId, matches(RegExp(r'^bafy[a-z2-7]+\.[0-9a-z]+$')));
      expect(identity.spaceId, isNot(contains('.-')));
    });

    test('keyPair has matching private and public keys', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      expect(identity.keyPair.privateKey.length, 32);
      expect(identity.keyPair.publicKey.length, 32);
      // privateKey should be the seed
      expect(identity.keyPair.privateKey, identity.seed);
    });

    test('space header is signed by the account key', () async {
      final identity = await Identity.fromMnemonic(testMnemonic);
      final rawHeader =
          RawSpaceHeader.fromBuffer(identity.spaceHeader.rawHeader);
      final header = SpaceHeader.fromBuffer(rawHeader.spaceHeader);

      final expectedIdentityKey = Key(
        type: KeyType.Ed25519Public,
        data: identity.accountKeyPair.publicKey,
      );
      expect(header.identity, expectedIdentityKey.writeToBuffer());
      final valid = await ed25519Verify(
        identity.accountKeyPair.publicKey,
        Uint8List.fromList(rawHeader.spaceHeader),
        Uint8List.fromList(rawHeader.signature),
      );
      expect(valid, isTrue);
    });

    test('space header timestamp is non-zero and deterministic', () async {
      final identity1 = await Identity.fromMnemonic(testMnemonic);
      final identity2 = await Identity.fromMnemonic(testMnemonic);
      final header1 =
          RawSpaceHeader.fromBuffer(identity1.spaceHeader.rawHeader);
      final header2 =
          RawSpaceHeader.fromBuffer(identity2.spaceHeader.rawHeader);
      final spaceHeader1 = SpaceHeader.fromBuffer(header1.spaceHeader);
      final spaceHeader2 = SpaceHeader.fromBuffer(header2.spaceHeader);

      expect(spaceHeader1.timestamp, isNot(Int64.ZERO));
      expect(spaceHeader1.timestamp, spaceHeader2.timestamp);
    });
  });
}
