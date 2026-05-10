import 'package:test/test.dart';
import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:manytype_protocol/spacesync.dart' as spacesync;
import 'package:manytype_protocol/coordinator.dart' as coordinator;
import 'package:manytype_protocol/consensus.dart' as consensus;
import 'package:manytype_protocol/filesync.dart' as filesync;
import 'package:manytype_protocol/models.dart' as models;

void main() {
  group('any_sync generated types', () {
    test('can instantiate HeadSyncRequest from spacesync', () {
      final msg = spacesync.HeadSyncRequest();
      expect(msg, isNotNull);
      expect(msg.spaceId, isEmpty);
    });

    test('can instantiate SpaceSignRequest from coordinator', () {
      final msg = coordinator.SpaceSignRequest();
      expect(msg, isNotNull);
    });

    test('can instantiate LogAddRequest from consensus', () {
      final msg = consensus.LogAddRequest();
      expect(msg, isNotNull);
    });

    test('can instantiate AclRoot from aclrecord', () {
      final msg = AclRoot();
      expect(msg, isNotNull);
      expect(msg.spaceId, isEmpty);
    });

    test('can instantiate RootChange from treechange', () {
      final msg = RootChange();
      expect(msg, isNotNull);
    });

    test('can instantiate BlockPushRequest from filesync', () {
      final msg = filesync.BlockPushRequest();
      expect(msg, isNotNull);
    });

    test('can instantiate Credentials from handshake', () {
      final msg = Credentials();
      expect(msg, isNotNull);
    });
  });

  group('any_block generated types', () {
    test('can instantiate SmartBlockSnapshotBase from models', () {
      final msg = models.SmartBlockSnapshotBase();
      expect(msg, isNotNull);
      expect(msg.blocks, isEmpty);
    });

    test('can instantiate Block from models', () {
      final msg = models.Block();
      expect(msg, isNotNull);
      expect(msg.id, isEmpty);
    });

    test('can instantiate Relation from models', () {
      final msg = models.Relation();
      expect(msg, isNotNull);
    });
  });

  group('proto roundtrip', () {
    test('HeadSyncRequest serializes and deserializes', () {
      final original = spacesync.HeadSyncRequest()..spaceId = 'test-space-123';
      final bytes = original.writeToBuffer();
      final decoded = spacesync.HeadSyncRequest.fromBuffer(bytes);
      expect(decoded.spaceId, equals('test-space-123'));
    });

    test('AclRoot serializes and deserializes', () {
      final original = AclRoot()..spaceId = 'space-abc';
      final bytes = original.writeToBuffer();
      final decoded = AclRoot.fromBuffer(bytes);
      expect(decoded.spaceId, equals('space-abc'));
    });
  });
}
