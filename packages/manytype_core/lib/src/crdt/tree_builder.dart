import 'dart:math';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:manytype_core/src/crdt/cid.dart';
import 'package:manytype_core/src/crypto/ed25519.dart';
import 'package:manytype_protocol/manytype_protocol.dart';

/// Build a signed root change for a new ObjectTree.
///
/// The root change contains the space ID, ACL head, and identity of the
/// creator. It is signed with the identity private key and wrapped in a
/// [RawTreeChangeWithId] with a CID computed from the RawTreeChange bytes.
///
/// Per Anytype protocol: CID is computed from [RawTreeChange] bytes (not
/// the inner RootChange bytes). See Pitfall 2 in RESEARCH.md.
Future<RawTreeChangeWithId> buildRootChange({
  required String spaceId,
  required String aclHeadId,
  required Uint8List identityPrivateKey,
  String changeType = 'ct',
}) async {
  // Derive public key from seed
  final keyPair = await ed25519KeyPairFromSeed(identityPrivateKey);

  // Generate 32 random bytes for uniqueness
  final rng = Random.secure();
  final seed = Uint8List.fromList(
    List.generate(32, (_) => rng.nextInt(256)),
  );

  // Create RootChange proto
  final rootChange = RootChange(
    aclHeadId: aclHeadId,
    spaceId: spaceId,
    changeType: changeType,
    timestamp: Int64(DateTime.now().millisecondsSinceEpoch ~/ 1000),
    seed: seed,
    identity: keyPair.publicKey,
  );

  // Marshal to bytes (this is the payload)
  final payload = Uint8List.fromList(rootChange.writeToBuffer());

  // Sign payload
  final signature = await ed25519Sign(identityPrivateKey, payload);

  // Wrap in RawTreeChange
  final rawTreeChange = RawTreeChange(
    payload: payload,
    signature: signature,
  );

  // Marshal RawTreeChange to bytes
  final rawBytes = Uint8List.fromList(rawTreeChange.writeToBuffer());

  // Compute CID from RawTreeChange bytes (not RootChange bytes!)
  final cid = await computeCid(rawBytes);

  return RawTreeChangeWithId(rawChange: rawBytes, id: cid);
}

/// Build a signed tree change to add to an existing ObjectTree.
///
/// References the current heads of the tree as parents via [currentHeads],
/// and includes arbitrary [changesData] payload (typically serialized Change
/// proto bytes).
Future<RawTreeChangeWithId> buildTreeChange({
  required List<String> currentHeads,
  required String aclHeadId,
  required String snapshotBaseId,
  required Uint8List changesData,
  required Uint8List identityPrivateKey,
  String readKeyId = '',
  bool isSnapshot = false,
}) async {
  // Derive public key from seed
  final keyPair = await ed25519KeyPairFromSeed(identityPrivateKey);

  // Create TreeChange proto
  final treeChange = TreeChange(
    aclHeadId: aclHeadId,
    snapshotBaseId: snapshotBaseId,
    changesData: changesData,
    readKeyId: readKeyId,
    timestamp: Int64(DateTime.now().millisecondsSinceEpoch ~/ 1000),
    identity: keyPair.publicKey,
    isSnapshot: isSnapshot,
  );
  treeChange.treeHeadIds.addAll(currentHeads);

  // Marshal to bytes (this is the payload)
  final payload = Uint8List.fromList(treeChange.writeToBuffer());

  // Sign payload
  final signature = await ed25519Sign(identityPrivateKey, payload);

  // Wrap in RawTreeChange
  final rawTreeChange = RawTreeChange(
    payload: payload,
    signature: signature,
  );

  // Marshal RawTreeChange to bytes
  final rawBytes = Uint8List.fromList(rawTreeChange.writeToBuffer());

  // Compute CID from RawTreeChange bytes
  final cid = await computeCid(rawBytes);

  return RawTreeChangeWithId(rawChange: rawBytes, id: cid);
}
