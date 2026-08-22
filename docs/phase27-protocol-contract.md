# Phase 27: Object Synchronization Protocol Contract

This document describes the Anytype object synchronization protocol used by ManyType.

## 1. Overview

Anytype synchronizes objects between devices and servers. Objects belong to
spaces and are represented as trees of changes, using conflict-free replicated
data types (CRDTs) to merge changes from different peers.

The `SpaceSync` service exchanges object changes between peers.

## 2. Key Concepts

### 2.1. Spaces

A **Space** is a logical container for a collection of objects. Each space is identified by a unique `spaceId`. Before any object synchronization can occur, a client must join and authenticate with a space.

### 2.2. Objects

An **Object** is a discrete unit of data within a space, such as a page, a file, or a contact. Each object is identified by a unique `objectId`.

Objects are mutable and their state is defined by a sequence of changes. The underlying data structure for an object is a "tree" of these changes.

### 2.3. Object Types

There are three main types of objects that can be synchronized:

-   `Tree`: The most common object type, representing structured data like pages, which are composed of blocks.
-   `Acl`: An Access Control List, which defines permissions for the space.
-   `KeyValue`: A simple key-value store.

This document focuses on the synchronization of `Tree` objects.

### 2.4. Tree and Changes

A `Tree` represents the state and history of an object. It is a directed acyclic graph (DAG) of **Changes**.

-   **RootChange**: The first change in a tree's history, establishing its identity and initial state.
-   **TreeChange**: A subsequent change that modifies the object's state. Each `TreeChange` points to one or more previous changes (`treeHeadIds`), forming the DAG.

Changes are wrapped in a `RawTreeChange` which includes a signature, and then a `RawTreeChangeWithId` which includes a Content Identifier (CID). This structure ensures the integrity and verifiability of each change.

## 3. Synchronization Process

The synchronization process is orchestrated by the `SpaceSync` service.

1.  **Head Sync**: The client and server first perform a `HeadSync` to efficiently compare the state of all objects in the space. They exchange the heads (latest change IDs) of their object trees. If the heads differ for an object, it indicates that the object is out of sync.

2.  **Object Sync**: For each out-of-sync object, the client and server use the `ObjectSyncStream` to exchange the missing changes. This is done via `ObjectSyncMessage` messages.

### 3.1. `SpaceSync` Service

The core of the synchronization protocol is the `SpaceSync` service, defined in `proto/any_sync/spacesync.proto`.

```protobuf
service SpaceSync {
    // Compares all objects and their hashes in a space
    rpc HeadSync(HeadSyncRequest) returns (HeadSyncResponse);

    // Exchanges object changes between peers
    rpc ObjectSyncStream(stream ObjectSyncMessage) returns (stream ObjectSyncMessage);

    // ... other methods
}
```

### 3.2. `ObjectSyncMessage`

This is the main message used for exchanging object data.

`proto/any_sync/spacesync.proto`:
```protobuf
message ObjectSyncMessage {
    string spaceId = 1;
    string requestId = 2;
    string replyId = 3;
    bytes payload = 4;
    string objectId = 5;
    ObjectType objectType = 6;
}
```

The `payload` of an `ObjectSyncMessage` for a `Tree` object is a `TreeSyncMessage`.

## 4. Message Formats

### 4.1. `TreeSyncMessage`

This message contains the actual changes for a tree object.

`proto/any_sync/treechange.proto`:
```protobuf
message TreeSyncMessage {
    TreeSyncContentValue content = 1;
    RawTreeChangeWithId rootChange = 2;
}

message TreeSyncContentValue {
    oneof value {
        TreeHeadUpdate headUpdate = 1;
        TreeFullSyncRequest fullSyncRequest = 2;
        TreeFullSyncResponse fullSyncResponse = 3;
        TreeErrorResponse errorResponse = 4;
    }
}

message TreeHeadUpdate {
    repeated string heads = 1;
    repeated RawTreeChangeWithId changes = 2;
    repeated string snapshotPath = 3;
}
```

A `TreeHeadUpdate` contains the new head IDs for the tree and the `RawTreeChangeWithId` objects that lead to them.

### 4.2. `RawTreeChangeWithId` and `TreeChange`

This is the fundamental, verifiable unit of change.

`proto/any_sync/treechange.proto`:
```protobuf
message RawTreeChangeWithId {
    bytes rawChange = 1;
    string id = 2; // cid
}

message RawTreeChange {
    bytes payload = 1; // marshalled TreeChange
    bytes signature = 2;
}

message TreeChange {
    repeated string treeHeadIds = 1;
    string aclHeadId = 2;
    string snapshotBaseId = 3;
    bytes changesData = 4; // The actual content change
    string readKeyId = 5;
    int64 timestamp = 6;
    bytes identity = 7;
    bool isSnapshot = 8;
    string dataType = 9;
}
```

### 4.3. Content of `changesData`

The `changesData` field within a `TreeChange` contains the actual modification payload. The structure of this data is specific to the object's type. For most user-created objects like pages, this payload is defined by the protobuf messages in `proto/any_block/models.proto`.

For example, a change might contain a new `Block` to be added to a page, or an update to an existing block's content.

`proto/any_block/models.proto`:
```protobuf
message Block {
    string id = 1;
    google.protobuf.Struct fields = 2;
    // ... many other fields and content types

    oneof content {
        Content.Text text = 14;
        Content.File file = 15;
        // ... etc
    }
}

message Object {
    message ChangePayload {
        SmartBlockType smartBlockType = 1;
        string key = 2;
        bytes data = 3;
    }
}
```
The specific details of how `changesData` is structured for different operations are complex and depend on the `changeType` of the tree's `RootChange`.

## Test Vector Artifact

The `test_vectors/phase27-object-truth.json` artifact captures the exact sequence of RPCs during a successful object synchronization flow between the official Anytype client and the test coordinator/sync-node.

The sequence of RPCs observed is:
1. `/coordinator.Coordinator/NetworkConfiguration`: The client connects to the coordinator to obtain the current network topology.
2. `/coordinator.Coordinator/SpaceStatusCheck`: The client checks if the target space exists and its status.
3. `/coordinator.Coordinator/SpaceSign`: The client requests the coordinator to sign a space receipt, granting access.
4. `/spacesync.SpaceSync/SpacePush`: The client pushes the space payload (including its initial ACL) to the sync node.
5. `/spacesync.SpaceSync/HeadSync`: The client compares the state of all objects in the space with the node using head hashes.
6. `/spacesync.SpaceSync/ObjectSyncStream`: For out-of-sync objects (like the newly created page in the capture), the client opens a stream and sends `ObjectSyncMessage` containing `TreeSyncMessage` payload with `TreeHeadUpdate` to sync the tree changes.
7. `/spacesync.SpaceSync/StoreDiff`: The client checks the state of the key-value store in the space.
8. `/spacesync.SpaceSync/StoreElements`: The client exchanges elements (like bootstrap entries) with the sync node.

Each RPC plays a critical role in establishing trust (Coordinator RPCs), preparing the space container (`SpacePush`, `HeadSync`), and finally synchronizing the actual CRDT object changes (`ObjectSyncStream`).

## Protocol Definitions (Vendored)

### any_block/models.proto

```protobuf
message Block {
    string id = 1;
    google.protobuf.Struct fields = 2;
    Restrictions restrictions = 3;
    repeated string childrenIds = 4;
    string backgroundColor = 5;
    Align align = 6;
    VerticalAlign verticalAlign = 7;

    oneof content {
        Content.Smartblock smartblock = 11;
        Content.Text text = 14;
        Content.File file = 15;
        // ...
    }
}

message Object {
    message ChangePayload {
        SmartBlockType smartBlockType = 1;
        string key = 2;
        bytes data = 3;
    }
}
```

### any_sync/spacesync.proto

```protobuf
service SpaceSync {
    rpc HeadSync(HeadSyncRequest) returns (HeadSyncResponse);
    rpc StoreDiff(StoreDiffRequest) returns (StoreDiffResponse);
    rpc StoreElements(stream StoreKeyValue) returns (stream StoreKeyValue);
    rpc SpacePush(SpacePushRequest) returns (SpacePushResponse);
    rpc SpacePull(SpacePullRequest) returns (SpacePullResponse);
    rpc ObjectSyncStream(stream ObjectSyncMessage) returns (stream ObjectSyncMessage);
    // ...
}

message ObjectSyncMessage {
    string spaceId = 1;
    string requestId = 2;
    string replyId = 3;
    bytes payload = 4;
    string objectId = 5;
    ObjectType objectType = 6;
}
```

### any_sync/treechange.proto

```protobuf
message TreeSyncMessage {
    TreeSyncContentValue content = 1;
    RawTreeChangeWithId rootChange = 2;
}

message TreeSyncContentValue {
    oneof value {
        TreeHeadUpdate headUpdate = 1;
        TreeFullSyncRequest fullSyncRequest = 2;
        TreeFullSyncResponse fullSyncResponse = 3;
        TreeErrorResponse errorResponse = 4;
    }
}

message TreeHeadUpdate {
    repeated string heads = 1;
    repeated RawTreeChangeWithId changes = 2;
    repeated string snapshotPath = 3;
}

message TreeChange {
    repeated string treeHeadIds = 1;
    string aclHeadId = 2;
    string snapshotBaseId = 3;
    bytes changesData = 4;
    string readKeyId = 5;
    int64 timestamp = 6;
    bytes identity = 7;
    bool isSnapshot = 8;
    string dataType = 9;
}
```