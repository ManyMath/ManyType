import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:manytype_protocol/consensus.dart';

import '../crdt/cid.dart';
import '../crypto/aes_gcm.dart';
import '../crypto/ed25519.dart';
import 'acl_record.dart';

/// Build a signed AclRoot record with real Ed25519 signing and AES-GCM encryption.
///
/// This creates the first record in an ACL chain. The [masterKeySeed] signs
/// the identity public key, while [identityPrivateKey] signs the ACL record.
/// The [readKey] is encrypted with AES-GCM using the master key seed as the
/// symmetric key.
///
/// Returns a [RawRecordWithId] where:
///   - payload = marshalled RawRecord bytes
///   - id = CID computed from payload (starts with "bafy")
Future<RawRecordWithId> buildAclRoot({
  required String spaceId,
  required Uint8List masterKeySeed,
  required Uint8List identityPrivateKey,
  required Uint8List readKey,
}) async {
  // 1. Derive keypairs for the account/master key and the identity key.
  final masterKeyPair = await ed25519KeyPairFromSeed(masterKeySeed);
  final identityKeyPair = await ed25519KeyPairFromSeed(identityPrivateKey);

  // 2. Encrypt readKey with AES-GCM using masterKeySeed as symmetric key (per D-12: real encryption)
  final encryptedReadKey = await aesGcmEncrypt(masterKeySeed, readKey);

  // 3. Sign the identity public key with the master key to produce identitySignature
  final identitySignature =
      await ed25519Sign(masterKeySeed, identityKeyPair.publicKey);

  // 4. Create AclRoot proto
  final now = DateTime.now().millisecondsSinceEpoch;
  final aclRoot = AclRoot(
    identity: identityKeyPair.publicKey,
    masterKey: masterKeyPair.publicKey,
    spaceId: spaceId,
    encryptedReadKey: encryptedReadKey,
    timestamp: Int64(now),
    identitySignature: identitySignature,
  );

  // 5. Marshal AclRoot to get data bytes
  final aclRootBytes = aclRoot.writeToBuffer();

  // 6. Create Record proto (prevId empty for root)
  final record = Record(
    prevId: '',
    identity: identityKeyPair.publicKey,
    data: aclRootBytes,
    timestamp: Int64(now),
  );

  // 7. Marshal Record to get payload bytes
  final recordBytes = record.writeToBuffer();

  // 8. Sign the Record payload with the identity key.
  final signature = await ed25519Sign(identityPrivateKey, recordBytes);

  // 9. Create RawRecord with payload and signature
  final rawRecord = RawRecord(
    payload: recordBytes,
    signature: signature,
  );

  // 10. Marshal RawRecord to get the final bytes
  final rawRecordBytes = rawRecord.writeToBuffer();

  // 11. Compute CID from marshalled RawRecord bytes (per Pitfall 4)
  final cid = await computeCid(Uint8List.fromList(rawRecordBytes));

  // 12. Return RawRecordWithId
  return RawRecordWithId(
    payload: rawRecordBytes,
    id: cid,
  );
}

/// Build a signed ACL record for subsequent operations (invite, join, permission change, etc).
///
/// The [prevId] must be the CID of the previous record in the chain.
/// The [aclData] contains the ACL operations to apply.
/// The [identityPrivateKey] is the 32-byte Ed25519 seed of the signer.
Future<RawRecordWithId> buildAclRecord({
  required String prevId,
  required AclData aclData,
  required Uint8List identityPrivateKey,
}) async {
  // 1. Derive keypair from seed
  final keyPair = await ed25519KeyPairFromSeed(identityPrivateKey);

  // 2. Marshal AclData to bytes
  final aclDataBytes = aclData.writeToBuffer();

  // 3. Create Record proto with prevId linking to chain
  final now = DateTime.now().millisecondsSinceEpoch;
  final record = Record(
    prevId: prevId,
    identity: keyPair.publicKey,
    data: aclDataBytes,
    timestamp: Int64(now),
  );

  // 4. Marshal Record
  final recordBytes = record.writeToBuffer();

  // 5. Sign with Ed25519 (per D-12: real signing)
  final signature = await ed25519Sign(identityPrivateKey, recordBytes);

  // 6. Create RawRecord
  final rawRecord = RawRecord(
    payload: recordBytes,
    signature: signature,
  );

  // 7. Marshal RawRecord
  final rawRecordBytes = rawRecord.writeToBuffer();

  // 8. Compute CID from marshalled RawRecord bytes (per Pitfall 4)
  final cid = await computeCid(Uint8List.fromList(rawRecordBytes));

  // 9. Return RawRecordWithId
  return RawRecordWithId(
    payload: rawRecordBytes,
    id: cid,
  );
}

/// Verify and decode an ACL record from its RawRecordWithId representation.
///
/// Verifies:
/// 1. CID matches (computeCid(payload) == id)
/// 2. Ed25519 signature is valid
///
/// Returns a [VerifiedAclRecord] with decoded fields.
Future<VerifiedAclRecord> verifyAndDecodeAclRecord(
    RawRecordWithId rawWithId) async {
  // 1. Verify CID
  final computedCid =
      await computeCid(Uint8List.fromList(rawWithId.payload));
  if (computedCid != rawWithId.id) {
    throw StateError(
        'CID mismatch: computed=$computedCid, expected=${rawWithId.id}');
  }

  // 2. Decode RawRecord
  final rawRecord = RawRecord.fromBuffer(rawWithId.payload);

  // 3. Decode inner Record
  final record = Record.fromBuffer(rawRecord.payload);

  // 4. Verify Ed25519 signature
  final valid = await ed25519Verify(
    Uint8List.fromList(record.identity),
    Uint8List.fromList(rawRecord.payload),
    Uint8List.fromList(rawRecord.signature),
  );
  if (!valid) {
    throw StateError('Invalid Ed25519 signature on ACL record ${rawWithId.id}');
  }

  // 5. Decode data as AclRoot (if root) or AclData (if non-root)
  final isRoot = record.prevId.isEmpty;
  AclRoot? aclRoot;
  AclData? aclData;

  if (isRoot) {
    aclRoot = AclRoot.fromBuffer(record.data);
  } else {
    aclData = AclData.fromBuffer(record.data);
  }

  return VerifiedAclRecord(
    id: rawWithId.id,
    prevId: record.prevId,
    identity: Uint8List.fromList(record.identity),
    aclRoot: aclRoot,
    aclData: aclData,
    timestamp: record.timestamp.toInt(),
  );
}
