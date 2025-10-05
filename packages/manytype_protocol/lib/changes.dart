/// Sub-library for Change proto types from any_block/changes.proto.
///
/// Contains Change, ChangeNoSnapshot, StoreChange, and related block
/// operation types (BlockCreate, BlockUpdate, BlockRemove, etc.).
library manytype_protocol.changes;

export 'src/generated/any_block/changes.pb.dart';
export 'src/generated/any_block/changes.pbenum.dart';
