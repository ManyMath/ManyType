import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:manytype_protocol/consensus.dart';
import 'package:test/test.dart';

void main() {
  // Deterministic seeds for testing
  final masterKeySeed = Uint8List.fromList(List.generate(32, (i) => i + 1));
  final identitySeed = Uint8List.fromList(List.generate(32, (i) => i + 50));
  final readKey = Uint8List.fromList(List.generate(32, (i) => i + 100));
  const spaceId = 'test-space-id';

  group('ACL Builder', () {
    test('buildAclRoot creates AclRoot with CID starting with "bafy"',
        () async {
      final result = await buildAclRoot(
        spaceId: spaceId,
        masterKeySeed: masterKeySeed,
        identityPrivateKey: identitySeed,
        readKey: readKey,
      );

      expect(result.id, startsWith('bafy'));
      expect(result.payload, isNotEmpty);
    });

    test('AclRoot has encryptedReadKey that decrypts with owner key', () async {
      final result = await buildAclRoot(
        spaceId: spaceId,
        masterKeySeed: masterKeySeed,
        identityPrivateKey: identitySeed,
        readKey: readKey,
      );

      // Decode the chain: RawRecordWithId.payload -> RawRecord -> Record -> AclRoot
      final rawRecord = RawRecord.fromBuffer(result.payload);
      final record = Record.fromBuffer(rawRecord.payload);
      final aclRoot = AclRoot.fromBuffer(record.data);

      // The encryptedReadKey should decrypt back to the original readKey
      // For simplicity, the builder uses the masterKeySeed-derived key for AES encryption
      final decrypted = await aesGcmDecrypt(
          masterKeySeed, Uint8List.fromList(aclRoot.encryptedReadKey));
      expect(decrypted, equals(readKey));
    });

    test('AclRoot identitySignature verifies with masterKey', () async {
      final result = await buildAclRoot(
        spaceId: spaceId,
        masterKeySeed: masterKeySeed,
        identityPrivateKey: identitySeed,
        readKey: readKey,
      );

      final rawRecord = RawRecord.fromBuffer(result.payload);
      final record = Record.fromBuffer(rawRecord.payload);
      final aclRoot = AclRoot.fromBuffer(record.data);

      // The identitySignature is the master key signing the identity pubkey
      final masterKeyPair = await ed25519KeyPairFromSeed(masterKeySeed);
      final valid = await ed25519Verify(
        masterKeyPair.publicKey,
        Uint8List.fromList(aclRoot.identity),
        Uint8List.fromList(aclRoot.identitySignature),
      );
      expect(valid, isTrue);
    });

    test('Owner identity round-trips: build, serialize, deserialize, extract',
        () async {
      final result = await buildAclRoot(
        spaceId: spaceId,
        masterKeySeed: masterKeySeed,
        identityPrivateKey: identitySeed,
        readKey: readKey,
      );

      // Serialize the RawRecordWithId to bytes and back
      final serialized = result.writeToBuffer();
      final deserialized = RawRecordWithId.fromBuffer(serialized);

      // Decode identity from deserialized
      final rawRecord = RawRecord.fromBuffer(deserialized.payload);
      final record = Record.fromBuffer(rawRecord.payload);
      final aclRoot = AclRoot.fromBuffer(record.data);

      // Identity should match what we started with
      final masterKeyPair = await ed25519KeyPairFromSeed(masterKeySeed);
      final identityKeyPair = await ed25519KeyPairFromSeed(identitySeed);
      expect(aclRoot.masterKey, equals(masterKeyPair.publicKey));
      expect(aclRoot.identity, equals(identityKeyPair.publicKey));
    });

    test(
        'buildAclRecord with invite produces Record with prevId == AclRoot CID',
        () async {
      final root = await buildAclRoot(
        spaceId: spaceId,
        masterKeySeed: masterKeySeed,
        identityPrivateKey: identitySeed,
        readKey: readKey,
      );

      // Create an invite
      final inviteKeySeed =
          Uint8List.fromList(List.generate(32, (i) => i + 50));
      final inviteKeyPair = await ed25519KeyPairFromSeed(inviteKeySeed);

      final aclData = AclData(aclContent: [
        AclContentValue(
          invite: AclAccountInvite(
            inviteKey: inviteKeyPair.publicKey,
            permissions: AclUserPermissions.Writer,
          ),
        ),
      ]);

      final record = await buildAclRecord(
        prevId: root.id,
        aclData: aclData,
        identityPrivateKey: identitySeed,
      );

      // Decode and check prevId
      final rawRecord = RawRecord.fromBuffer(record.payload);
      final innerRecord = Record.fromBuffer(rawRecord.payload);
      expect(innerRecord.prevId, equals(root.id));
      expect(record.id, startsWith('bafy'));
    });

    test('root and record timestamps are Unix seconds', () async {
      final before = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final root = await buildAclRoot(
        spaceId: spaceId,
        masterKeySeed: masterKeySeed,
        identityPrivateKey: identitySeed,
        readKey: readKey,
      );
      final record = await buildAclRecord(
        prevId: root.id,
        aclData: AclData(),
        identityPrivateKey: identitySeed,
      );
      final after = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final verifiedRoot = await verifyAndDecodeAclRecord(root);
      final verifiedRecord = await verifyAndDecodeAclRecord(record);
      final timestamps = [
        verifiedRoot.timestamp,
        verifiedRoot.aclRoot!.timestamp.toInt(),
        verifiedRecord.timestamp,
      ];
      for (final timestamp in timestamps) {
        expect(timestamp, inInclusiveRange(before, after));
      }
    });

    test('CID verification: computeCid(rawRecordWithId.payload) == id',
        () async {
      final result = await buildAclRoot(
        spaceId: spaceId,
        masterKeySeed: masterKeySeed,
        identityPrivateKey: identitySeed,
        readKey: readKey,
      );

      // The CID should be computed from the RawRecord bytes (the payload of RawRecordWithId)
      final computedCid = await computeCid(Uint8List.fromList(result.payload));
      expect(computedCid, equals(result.id));
    });
  });

  group('ACL State', () {
    test('AclState after AclRoot has owner with Owner permission', () async {
      final root = await buildAclRoot(
        spaceId: spaceId,
        masterKeySeed: masterKeySeed,
        identityPrivateKey: identitySeed,
        readKey: readKey,
      );

      final verified = await verifyAndDecodeAclRecord(root);
      final state = AclState();
      state.applyRoot(verified);

      final ownerHex = hex.encode(verified.identity);
      expect(state.getPermission(ownerHex), equals(AclUserPermissions.Owner));
    });

    test('AclState after invite + join has new member with correct permission',
        () async {
      final root = await buildAclRoot(
        spaceId: spaceId,
        masterKeySeed: masterKeySeed,
        identityPrivateKey: identitySeed,
        readKey: readKey,
      );

      final verifiedRoot = await verifyAndDecodeAclRecord(root);
      final state = AclState();
      state.applyRoot(verifiedRoot);

      // Create invite
      final inviteKeySeed =
          Uint8List.fromList(List.generate(32, (i) => i + 50));
      final inviteKeyPair = await ed25519KeyPairFromSeed(inviteKeySeed);

      final inviteData = AclData(aclContent: [
        AclContentValue(
          invite: AclAccountInvite(
            inviteKey: inviteKeyPair.publicKey,
            permissions: AclUserPermissions.Writer,
          ),
        ),
      ]);

      final inviteRecord = await buildAclRecord(
        prevId: root.id,
        aclData: inviteData,
        identityPrivateKey: identitySeed,
      );

      final verifiedInvite = await verifyAndDecodeAclRecord(inviteRecord);
      state.applyRecord(verifiedInvite);

      // Create inviteJoin from a new identity
      final joinerSeed = Uint8List.fromList(List.generate(32, (i) => i + 200));
      final joinerKeyPair = await ed25519KeyPairFromSeed(joinerSeed);

      final joinData = AclData(aclContent: [
        AclContentValue(
          inviteJoin: AclAccountInviteJoin(
            identity: joinerKeyPair.publicKey,
            inviteRecordId: inviteRecord.id,
            permissions: AclUserPermissions.Writer,
          ),
        ),
      ]);

      final joinRecord = await buildAclRecord(
        prevId: inviteRecord.id,
        aclData: joinData,
        identityPrivateKey: identitySeed,
      );

      final verifiedJoin = await verifyAndDecodeAclRecord(joinRecord);
      state.applyRecord(verifiedJoin);

      final joinerHex = hex.encode(joinerKeyPair.publicKey);
      expect(state.getPermission(joinerHex), equals(AclUserPermissions.Writer));
      expect(state.getStatus(joinerHex), equals(AclAccountStatus.active));
    });

    test('invite join without permissions inherits the invite permissions',
        () async {
      final root = await buildAclRoot(
        spaceId: spaceId,
        masterKeySeed: masterKeySeed,
        identityPrivateKey: identitySeed,
        readKey: readKey,
      );
      final state = AclState()..applyRoot(await verifyAndDecodeAclRecord(root));

      final inviteKeyPair = await ed25519KeyPairFromSeed(
          Uint8List.fromList(List.generate(32, (i) => i + 50)));
      final inviteRecord = await buildAclRecord(
        prevId: root.id,
        aclData: AclData(aclContent: [
          AclContentValue(
            invite: AclAccountInvite(
              inviteKey: inviteKeyPair.publicKey,
              permissions: AclUserPermissions.Reader,
            ),
          ),
        ]),
        identityPrivateKey: identitySeed,
      );
      state.applyRecord(await verifyAndDecodeAclRecord(inviteRecord));

      final joinerKeyPair = await ed25519KeyPairFromSeed(
          Uint8List.fromList(List.generate(32, (i) => i + 200)));
      final joinRecord = await buildAclRecord(
        prevId: inviteRecord.id,
        aclData: AclData(aclContent: [
          AclContentValue(
            inviteJoin: AclAccountInviteJoin(
              identity: joinerKeyPair.publicKey,
              inviteRecordId: inviteRecord.id,
            ),
          ),
        ]),
        identityPrivateKey: identitySeed,
      );
      state.applyRecord(await verifyAndDecodeAclRecord(joinRecord));

      final joinerHex = hex.encode(joinerKeyPair.publicKey);
      expect(state.getPermission(joinerHex), equals(AclUserPermissions.Reader));
    });

    test('AclState decodes marshalled nested identities and tracks removal',
        () async {
      final root = await buildAclRoot(
        spaceId: spaceId,
        masterKeySeed: masterKeySeed,
        identityPrivateKey: identitySeed,
        readKey: readKey,
      );

      final verifiedRoot = await verifyAndDecodeAclRecord(root);
      final state = AclState();
      state.applyRoot(verifiedRoot);

      final inviteSeed =
          Uint8List.fromList(List<int>.generate(32, (i) => i + 90));
      final inviteKeyPair = await ed25519KeyPairFromSeed(inviteSeed);
      final inviteRecord = await buildAclRecord(
        prevId: root.id,
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
        identityPrivateKey: identitySeed,
      );
      state.applyRecord(await verifyAndDecodeAclRecord(inviteRecord));

      final joinerSeed = Uint8List.fromList(List.generate(32, (i) => i + 140));
      final joinerKeyPair = await ed25519KeyPairFromSeed(joinerSeed);
      final joinRecord = await buildAclRecord(
        prevId: inviteRecord.id,
        aclData: AclData(
          aclContent: [
            AclContentValue(
              requestJoin: AclAccountRequestJoin(
                inviteIdentity:
                    _marshalEd25519PublicKey(joinerKeyPair.publicKey),
                inviteRecordId: inviteRecord.id,
                inviteIdentitySignature: Uint8List(64),
                metadata: Uint8List(0),
              ),
            ),
          ],
        ),
        identityPrivateKey: joinerSeed,
      );
      state.applyRecord(await verifyAndDecodeAclRecord(joinRecord));

      final joinerHex = hex.encode(joinerKeyPair.publicKey);
      expect(state.getStatus(joinerHex), equals(AclAccountStatus.pending));

      final acceptRecord = await buildAclRecord(
        prevId: joinRecord.id,
        aclData: AclData(
          aclContent: [
            AclContentValue(
              requestAccept: AclAccountRequestAccept(
                identity: _marshalEd25519PublicKey(joinerKeyPair.publicKey),
                requestRecordId: joinRecord.id,
                encryptedReadKey: Uint8List.fromList(const [1, 2, 3]),
                permissions: AclUserPermissions.Writer,
              ),
            ),
          ],
        ),
        identityPrivateKey: identitySeed,
      );
      state.applyRecord(await verifyAndDecodeAclRecord(acceptRecord));

      expect(state.getPermission(joinerHex), equals(AclUserPermissions.Writer));
      expect(state.getStatus(joinerHex), equals(AclAccountStatus.active));

      final removeRecord = await buildAclRecord(
        prevId: acceptRecord.id,
        aclData: AclData(
          aclContent: [
            AclContentValue(
              accountRemove: AclAccountRemove(
                identities: [_marshalEd25519PublicKey(joinerKeyPair.publicKey)],
                readKeyChange: AclReadKeyChange(
                  accountKeys: [
                    AclEncryptedReadKey(
                      identity: _marshalEd25519PublicKey(
                        verifiedRoot.identity,
                      ),
                      encryptedReadKey: Uint8List.fromList(const [4, 5, 6]),
                    ),
                  ],
                  metadataPubKey: _marshalEd25519PublicKey(
                    verifiedRoot.identity,
                  ),
                  encryptedMetadataPrivKey: Uint8List.fromList(const [7, 8]),
                  encryptedOldReadKey: Uint8List.fromList(const [9, 10]),
                ),
              ),
            ),
          ],
        ),
        identityPrivateKey: identitySeed,
      );
      state.applyRecord(await verifyAndDecodeAclRecord(removeRecord));

      expect(state.getPermission(joinerHex), isNull);
      expect(state.getStatus(joinerHex), equals(AclAccountStatus.removed));
    });

    test('AclState rejects record with invalid prevId', () async {
      final root = await buildAclRoot(
        spaceId: spaceId,
        masterKeySeed: masterKeySeed,
        identityPrivateKey: identitySeed,
        readKey: readKey,
      );

      final verifiedRoot = await verifyAndDecodeAclRecord(root);
      final state = AclState();
      state.applyRoot(verifiedRoot);

      // Build a record with wrong prevId
      final aclData = AclData(aclContent: [
        AclContentValue(
          invite: AclAccountInvite(
            inviteKey: Uint8List(32),
            permissions: AclUserPermissions.Reader,
          ),
        ),
      ]);

      final badRecord = await buildAclRecord(
        prevId: 'bafywrongprevid',
        aclData: aclData,
        identityPrivateKey: identitySeed,
      );

      final verifiedBad = await verifyAndDecodeAclRecord(badRecord);
      expect(() => state.applyRecord(verifiedBad), throwsStateError);
    });
  });
}

Uint8List _marshalEd25519PublicKey(Uint8List publicKey) => Uint8List.fromList(
      Key(
        type: KeyType.Ed25519Public,
        data: publicKey,
      ).writeToBuffer(),
    );
