/// Protocol State Machine: Space Sync (HeadSync + ObjectSyncStream)
///
/// Documents the sync protocol between client and sync node.
/// Source: any-sync/commonspace/spacesyncproto/spacesync.proto
///
/// PROTO-01: Protocol state machine
/// PROTO-02: Protobuf message flows

import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';
import 'package:manytype_protocol/spacesync.dart';

void main() {
  group('HeadSync Flow', () {
    test('Step 1: Client sends HeadSyncRequest with its known heads', () {
      // Document: Client sends HeadSyncRequest to sync node.
      // The request contains:
      //   - spaceId: identifies which space to sync
      //   - ranges: list of HeadSyncRange entries representing the client's
      //     known state (hash ranges in a Merkle-like diff structure)
      //   - diffType: the type of diff algorithm to use
      //
      // HeadSyncRange represents a range boundary for Merkle-like diffing:
      //   - from/to: Int64 range bounds (object ID hash space)
      //   - limit: max elements to return in this range
      //   - elements: bool flag requesting element-level detail
      //
      // The sync node compares these ranges against its own state to identify
      // which objects differ.
      final request = HeadSyncRequest(
        spaceId: 'bafyspace123.abc',
        ranges: [
          HeadSyncRange(
            from: Int64(0),
            to: Int64(1000),
            elements: true, // Request element-level detail
          ),
        ],
      );
      expect(request.spaceId, isNotEmpty);
      expect(request.ranges, hasLength(1));
      expect(request.ranges.first.elements, isTrue);
    });

    test('Step 2: Sync node responds with HeadSyncResponse', () {
      // Document: Sync node compares client's ranges against its own state.
      // Returns HeadSyncResponse containing:
      //   - results: list of HeadSyncResult entries, each containing:
      //     - hash: bytes representing combined hash of elements in range
      //     - elements: HeadSyncResultElement entries with (id, head) pairs
      //     - count: number of elements in this range
      //   - diffType: echoes back the diff algorithm used
      //
      // The results tell the client which objects need to be synced.
      final response = HeadSyncResponse(
        results: [
          HeadSyncResult(
            hash: [0xab, 0xcd, 0xef], // Combined hash as bytes
            elements: [
              HeadSyncResultElement(
                id: 'obj-tree-3',
                head: 'Qmhash3', // Server has this, client doesn't
              ),
            ],
            count: 1,
          ),
        ],
      );
      expect(response.results, hasLength(1));
      expect(response.results.first.elements, hasLength(1));
      expect(
        response.results.first.elements.first.id,
        equals('obj-tree-3'),
      );
    });
  });

  group('ObjectSyncStream Flow', () {
    test('Step 1: Client sends ObjectSyncMessage to exchange data', () {
      // Document: After HeadSync identifies missing objects, client and
      // server exchange ObjectSyncMessage entries over a bidirectional stream.
      //
      // ObjectSyncMessage contains:
      //   - spaceId: the space being synced
      //   - requestId: correlation ID for request/response matching
      //   - replyId: ID of the message being replied to
      //   - payload: serialized tree sync data (TreeSyncMessage protobuf)
      //   - objectId: which object tree this message concerns
      //   - objectType: type of object (Tree, AclRoot, etc.)
      //
      // The payload typically contains TreeChange records for CRDT merging.
      final message = ObjectSyncMessage(
        spaceId: 'bafyspace123.abc',
        requestId: 'req-001',
        objectId: 'obj-tree-1',
        payload: [0x0a, 0x10, 0x20], // Serialized TreeSyncMessage
      );
      expect(message.spaceId, isNotEmpty);
      expect(message.requestId, isNotEmpty);
      expect(message.objectId, isNotEmpty);
      expect(message.payload, isNotEmpty);
    });

    test('Step 2: Server replies with ObjectSyncMessage containing changes',
        () {
      // Document: Server sends back its changes for the same object.
      // The replyId references the client's requestId for correlation.
      final reply = ObjectSyncMessage(
        spaceId: 'bafyspace123.abc',
        replyId: 'req-001', // Correlates to client's requestId
        objectId: 'obj-tree-1',
        payload: [0x0b, 0x11, 0x21], // Server's TreeSyncMessage
      );
      expect(reply.replyId, equals('req-001'));
      expect(reply.objectId, equals('obj-tree-1'));
    });

    test('Step 3: StoreDiff for key-value sync', () {
      // Document: StoreDiffRequest is used for key-value store synchronization.
      // Similar to HeadSync but for the settings/store layer rather than
      // object trees.
      final request = StoreDiffRequest(
        spaceId: 'bafyspace123.abc',
        ranges: [
          HeadSyncRange(
            from: Int64(0),
            to: Int64(100),
          ),
        ],
      );
      expect(request.spaceId, isNotEmpty);
      expect(request.ranges, hasLength(1));
    });
  });

  group('SpacePush/Pull Flow', () {
    test('SpacePushRequest creates a new space on the sync node', () {
      // Document: When a client creates a new space, it pushes the initial
      // space data to the sync node via SpacePushRequest.
      // Contains a SpacePayload with:
      //   - spaceHeader: RawSpaceHeaderWithId (signed space header + ID)
      //   - aclPayload: initial ACL record bytes (access control)
      //   - spaceSettingsPayload: initial space settings bytes
      final request = SpacePushRequest(
        payload: SpacePayload(
          spaceHeader: RawSpaceHeaderWithId(
            rawHeader: [0x0a, 0x10], // Serialized space header
            id: 'bafyspace123.abc',
          ),
        ),
      );
      expect(request.payload, isNotNull);
      expect(request.payload.spaceHeader.id, isNotEmpty);
    });

    test('SpacePullRequest retrieves space data from sync node', () {
      // Document: Client requests full space data from sync node.
      // Used when joining an existing space.
      final request = SpacePullRequest(
        id: 'bafyspace123.abc',
      );
      expect(request.id, isNotEmpty);
    });
  });

  group('Full sync sequence', () {
    test('Complete sync from client to server', () {
      // Full sequence:
      //
      // 1. Client -> SyncNode: HeadSyncRequest {
      //      spaceId,
      //      ranges: [{ from, to, elements: true }]
      //    }
      //    Purpose: Exchange Merkle-like hashes to find differences
      //
      // 2. SyncNode -> Client: HeadSyncResponse {
      //      results: [{ hash (bytes), elements: [{id, head}, ...], count }]
      //    }
      //    Purpose: Tell client which objects differ
      //
      // 3. Client -> SyncNode: ObjectSyncMessage (stream) {
      //      spaceId, requestId, objectId, payload (TreeSyncMessage)
      //    }
      //    Purpose: Send client's changes for objects the server is missing
      //
      // 4. SyncNode -> Client: ObjectSyncMessage (stream) {
      //      spaceId, replyId, objectId, payload (TreeSyncMessage)
      //    }
      //    Purpose: Send server's changes for objects the client is missing
      //
      // 5. Both sides merge received TreeChanges into their local CRDT trees
      //
      // 6. StoreDiff for key-value store sync (settings, metadata)
      //
      // 7. Stream closes when all objects are exchanged

      // Verify types compose correctly for the full flow:
      final headReq = HeadSyncRequest(spaceId: 'space-1');
      expect(headReq, isA<HeadSyncRequest>());

      final headResp = HeadSyncResponse(results: []);
      expect(headResp, isA<HeadSyncResponse>());

      final objMsg = ObjectSyncMessage(
        spaceId: 'space-1',
        requestId: 'req-1',
        objectId: 'tree-1',
      );
      expect(objMsg, isA<ObjectSyncMessage>());

      final storeDiff = StoreDiffRequest(spaceId: 'space-1');
      expect(storeDiff, isA<StoreDiffRequest>());
    });
  });
}
