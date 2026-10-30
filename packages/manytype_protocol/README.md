# manytype_protocol

Protobuf message types for the Any-Sync wire protocol and the Anytype block
model, generated with `protoc-gen-dart` for the
[anytype](https://pub.dev/packages/anytype) SDK.

Some message names repeat across protocols, so the types are split into
libraries:

| Library | Source schemas |
| --- | --- |
| `manytype_protocol.dart` | ACL records, tree changes, handshake, crypto |
| `spacesync.dart` | Space sync: head sync, object sync streams |
| `coordinator.dart` | Coordinator: space signing, network configuration |
| `consensus.dart` | Consensus log records |
| `filesync.dart` | File block push and fetch |
| `models.dart` | Anytype block model: blocks, relations, snapshots |
| `changes.dart` | Anytype object changes |
| `events.dart` | Anytype events used to decode block updates |

The schemas come from Any-Sync v0.9.9 and anytype-heart commit `cfb7ec9`,
with local adaptations to `changes.proto`, `events.proto` and the Any-Sync
`file.proto`. The ManyType repository
records the exact upstream source and hash of each schema in
`proto/PROVENANCE.json` and regenerates this code with pinned tools.

This is an independent package, not made or endorsed by Anytype or the Any
Association.

## License

This package is not under a single license:

- Types generated from Anytype-heart schemas (`models.dart`, `changes.dart`,
  `events.dart`) are subject to the Any Source Available License 1.0, which
  permits use only for Non-Commercial Use or for Commercial Use in Allowed
  Networks (https://networks.any.coop).
- Types generated from Any-Sync schemas are under the MIT License of the Any
  Association.
- First-party code is MIT licensed.

[LICENSE](LICENSE) describes which files carry which terms, and
[licenses/](licenses) holds the upstream license texts.
