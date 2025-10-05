// This is a generated file - do not edit.
//
// Generated from any_block/models.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $0;

import 'models.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'models.pbenum.dart';

class SmartBlockSnapshotBase extends $pb.GeneratedMessage {
  factory SmartBlockSnapshotBase({
    $core.Iterable<Block>? blocks,
    $0.Struct? details,
    @$core.Deprecated('This field is deprecated.') $0.Struct? fileKeys,
    @$core.Deprecated('This field is deprecated.')
    $core.Iterable<Relation>? extraRelations,
    $core.Iterable<$core.String>? objectTypes,
    $0.Struct? collections,
    $core.Iterable<RelationLink>? relationLinks,
    $core.Iterable<$core.String>? removedCollectionKeys,
    $core.String? key,
    $fixnum.Int64? originalCreatedTimestamp,
    FileInfo? fileInfo,
  }) {
    final result = create();
    if (blocks != null) result.blocks.addAll(blocks);
    if (details != null) result.details = details;
    if (fileKeys != null) result.fileKeys = fileKeys;
    if (extraRelations != null) result.extraRelations.addAll(extraRelations);
    if (objectTypes != null) result.objectTypes.addAll(objectTypes);
    if (collections != null) result.collections = collections;
    if (relationLinks != null) result.relationLinks.addAll(relationLinks);
    if (removedCollectionKeys != null)
      result.removedCollectionKeys.addAll(removedCollectionKeys);
    if (key != null) result.key = key;
    if (originalCreatedTimestamp != null)
      result.originalCreatedTimestamp = originalCreatedTimestamp;
    if (fileInfo != null) result.fileInfo = fileInfo;
    return result;
  }

  SmartBlockSnapshotBase._();

  factory SmartBlockSnapshotBase.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SmartBlockSnapshotBase.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SmartBlockSnapshotBase',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPM<Block>(1, _omitFieldNames ? '' : 'blocks', subBuilder: Block.create)
    ..aOM<$0.Struct>(2, _omitFieldNames ? '' : 'details',
        subBuilder: $0.Struct.create)
    ..aOM<$0.Struct>(3, _omitFieldNames ? '' : 'fileKeys',
        protoName: 'fileKeys', subBuilder: $0.Struct.create)
    ..pPM<Relation>(4, _omitFieldNames ? '' : 'extraRelations',
        protoName: 'extraRelations', subBuilder: Relation.create)
    ..pPS(5, _omitFieldNames ? '' : 'objectTypes', protoName: 'objectTypes')
    ..aOM<$0.Struct>(6, _omitFieldNames ? '' : 'collections',
        subBuilder: $0.Struct.create)
    ..pPM<RelationLink>(7, _omitFieldNames ? '' : 'relationLinks',
        protoName: 'relationLinks', subBuilder: RelationLink.create)
    ..pPS(8, _omitFieldNames ? '' : 'removedCollectionKeys',
        protoName: 'removedCollectionKeys')
    ..aOS(9, _omitFieldNames ? '' : 'key')
    ..aInt64(10, _omitFieldNames ? '' : 'originalCreatedTimestamp',
        protoName: 'originalCreatedTimestamp')
    ..aOM<FileInfo>(11, _omitFieldNames ? '' : 'fileInfo',
        protoName: 'fileInfo', subBuilder: FileInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SmartBlockSnapshotBase clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SmartBlockSnapshotBase copyWith(
          void Function(SmartBlockSnapshotBase) updates) =>
      super.copyWith((message) => updates(message as SmartBlockSnapshotBase))
          as SmartBlockSnapshotBase;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SmartBlockSnapshotBase create() => SmartBlockSnapshotBase._();
  @$core.override
  SmartBlockSnapshotBase createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SmartBlockSnapshotBase getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SmartBlockSnapshotBase>(create);
  static SmartBlockSnapshotBase? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Block> get blocks => $_getList(0);

  @$pb.TagNumber(2)
  $0.Struct get details => $_getN(1);
  @$pb.TagNumber(2)
  set details($0.Struct value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDetails() => $_has(1);
  @$pb.TagNumber(2)
  void clearDetails() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Struct ensureDetails() => $_ensure(1);

  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  $0.Struct get fileKeys => $_getN(2);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  set fileKeys($0.Struct value) => $_setField(3, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  $core.bool hasFileKeys() => $_has(2);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  void clearFileKeys() => $_clearField(3);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  $0.Struct ensureFileKeys() => $_ensure(2);

  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(4)
  $pb.PbList<Relation> get extraRelations => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get objectTypes => $_getList(4);

  @$pb.TagNumber(6)
  $0.Struct get collections => $_getN(5);
  @$pb.TagNumber(6)
  set collections($0.Struct value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCollections() => $_has(5);
  @$pb.TagNumber(6)
  void clearCollections() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Struct ensureCollections() => $_ensure(5);

  @$pb.TagNumber(7)
  $pb.PbList<RelationLink> get relationLinks => $_getList(6);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get removedCollectionKeys => $_getList(7);

  @$pb.TagNumber(9)
  $core.String get key => $_getSZ(8);
  @$pb.TagNumber(9)
  set key($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasKey() => $_has(8);
  @$pb.TagNumber(9)
  void clearKey() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get originalCreatedTimestamp => $_getI64(9);
  @$pb.TagNumber(10)
  set originalCreatedTimestamp($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasOriginalCreatedTimestamp() => $_has(9);
  @$pb.TagNumber(10)
  void clearOriginalCreatedTimestamp() => $_clearField(10);

  @$pb.TagNumber(11)
  FileInfo get fileInfo => $_getN(10);
  @$pb.TagNumber(11)
  set fileInfo(FileInfo value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasFileInfo() => $_has(10);
  @$pb.TagNumber(11)
  void clearFileInfo() => $_clearField(11);
  @$pb.TagNumber(11)
  FileInfo ensureFileInfo() => $_ensure(10);
}

class Search_Result extends $pb.GeneratedMessage {
  factory Search_Result({
    $core.String? objectId,
    $0.Struct? details,
    $core.Iterable<Search_Meta>? meta,
  }) {
    final result = create();
    if (objectId != null) result.objectId = objectId;
    if (details != null) result.details = details;
    if (meta != null) result.meta.addAll(meta);
    return result;
  }

  Search_Result._();

  factory Search_Result.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Search_Result.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Search.Result',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'objectId', protoName: 'objectId')
    ..aOM<$0.Struct>(2, _omitFieldNames ? '' : 'details',
        subBuilder: $0.Struct.create)
    ..pPM<Search_Meta>(3, _omitFieldNames ? '' : 'meta',
        subBuilder: Search_Meta.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Search_Result clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Search_Result copyWith(void Function(Search_Result) updates) =>
      super.copyWith((message) => updates(message as Search_Result))
          as Search_Result;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Search_Result create() => Search_Result._();
  @$core.override
  Search_Result createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Search_Result getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Search_Result>(create);
  static Search_Result? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get objectId => $_getSZ(0);
  @$pb.TagNumber(1)
  set objectId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasObjectId() => $_has(0);
  @$pb.TagNumber(1)
  void clearObjectId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Struct get details => $_getN(1);
  @$pb.TagNumber(2)
  set details($0.Struct value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDetails() => $_has(1);
  @$pb.TagNumber(2)
  void clearDetails() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Struct ensureDetails() => $_ensure(1);

  @$pb.TagNumber(3)
  $pb.PbList<Search_Meta> get meta => $_getList(2);
}

class Search_Meta extends $pb.GeneratedMessage {
  factory Search_Meta({
    $core.String? highlight,
    $core.Iterable<Range>? highlightRanges,
    $core.String? blockId,
    $core.String? relationKey,
    $0.Struct? relationDetails,
  }) {
    final result = create();
    if (highlight != null) result.highlight = highlight;
    if (highlightRanges != null) result.highlightRanges.addAll(highlightRanges);
    if (blockId != null) result.blockId = blockId;
    if (relationKey != null) result.relationKey = relationKey;
    if (relationDetails != null) result.relationDetails = relationDetails;
    return result;
  }

  Search_Meta._();

  factory Search_Meta.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Search_Meta.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Search.Meta',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'highlight')
    ..pPM<Range>(2, _omitFieldNames ? '' : 'highlightRanges',
        protoName: 'highlightRanges', subBuilder: Range.create)
    ..aOS(3, _omitFieldNames ? '' : 'blockId', protoName: 'blockId')
    ..aOS(4, _omitFieldNames ? '' : 'relationKey', protoName: 'relationKey')
    ..aOM<$0.Struct>(5, _omitFieldNames ? '' : 'relationDetails',
        protoName: 'relationDetails', subBuilder: $0.Struct.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Search_Meta clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Search_Meta copyWith(void Function(Search_Meta) updates) =>
      super.copyWith((message) => updates(message as Search_Meta))
          as Search_Meta;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Search_Meta create() => Search_Meta._();
  @$core.override
  Search_Meta createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Search_Meta getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Search_Meta>(create);
  static Search_Meta? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get highlight => $_getSZ(0);
  @$pb.TagNumber(1)
  set highlight($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHighlight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHighlight() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<Range> get highlightRanges => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get blockId => $_getSZ(2);
  @$pb.TagNumber(3)
  set blockId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBlockId() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlockId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get relationKey => $_getSZ(3);
  @$pb.TagNumber(4)
  set relationKey($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRelationKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearRelationKey() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Struct get relationDetails => $_getN(4);
  @$pb.TagNumber(5)
  set relationDetails($0.Struct value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasRelationDetails() => $_has(4);
  @$pb.TagNumber(5)
  void clearRelationDetails() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Struct ensureRelationDetails() => $_ensure(4);
}

class Search_Message_Sort extends $pb.GeneratedMessage {
  factory Search_Message_Sort({
    Search_Message_Sort_Key? key,
    Search_Message_Sort_Type? type,
  }) {
    final result = create();
    if (key != null) result.key = key;
    if (type != null) result.type = type;
    return result;
  }

  Search_Message_Sort._();

  factory Search_Message_Sort.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Search_Message_Sort.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Search.Message.Sort',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aE<Search_Message_Sort_Key>(1, _omitFieldNames ? '' : 'key',
        enumValues: Search_Message_Sort_Key.values)
    ..aE<Search_Message_Sort_Type>(2, _omitFieldNames ? '' : 'type',
        enumValues: Search_Message_Sort_Type.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Search_Message_Sort clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Search_Message_Sort copyWith(void Function(Search_Message_Sort) updates) =>
      super.copyWith((message) => updates(message as Search_Message_Sort))
          as Search_Message_Sort;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Search_Message_Sort create() => Search_Message_Sort._();
  @$core.override
  Search_Message_Sort createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Search_Message_Sort getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Search_Message_Sort>(create);
  static Search_Message_Sort? _defaultInstance;

  @$pb.TagNumber(1)
  Search_Message_Sort_Key get key => $_getN(0);
  @$pb.TagNumber(1)
  set key(Search_Message_Sort_Key value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  Search_Message_Sort_Type get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(Search_Message_Sort_Type value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);
}

class Search_Message_Result extends $pb.GeneratedMessage {
  factory Search_Message_Result({
    $core.String? chatId,
    $core.String? messageId,
    $fixnum.Int64? score,
    $core.String? highlight,
    $core.Iterable<Range>? highlightRanges,
    ChatMessage? message,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (messageId != null) result.messageId = messageId;
    if (score != null) result.score = score;
    if (highlight != null) result.highlight = highlight;
    if (highlightRanges != null) result.highlightRanges.addAll(highlightRanges);
    if (message != null) result.message = message;
    return result;
  }

  Search_Message_Result._();

  factory Search_Message_Result.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Search_Message_Result.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Search.Message.Result',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'chatId', protoName: 'chatId')
    ..aOS(2, _omitFieldNames ? '' : 'messageId', protoName: 'messageId')
    ..aInt64(3, _omitFieldNames ? '' : 'score')
    ..aOS(4, _omitFieldNames ? '' : 'highlight')
    ..pPM<Range>(5, _omitFieldNames ? '' : 'highlightRanges',
        protoName: 'highlightRanges', subBuilder: Range.create)
    ..aOM<ChatMessage>(6, _omitFieldNames ? '' : 'message',
        subBuilder: ChatMessage.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Search_Message_Result clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Search_Message_Result copyWith(
          void Function(Search_Message_Result) updates) =>
      super.copyWith((message) => updates(message as Search_Message_Result))
          as Search_Message_Result;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Search_Message_Result create() => Search_Message_Result._();
  @$core.override
  Search_Message_Result createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Search_Message_Result getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Search_Message_Result>(create);
  static Search_Message_Result? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chatId => $_getSZ(0);
  @$pb.TagNumber(1)
  set chatId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get messageId => $_getSZ(1);
  @$pb.TagNumber(2)
  set messageId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessageId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get score => $_getI64(2);
  @$pb.TagNumber(3)
  set score($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScore() => $_has(2);
  @$pb.TagNumber(3)
  void clearScore() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get highlight => $_getSZ(3);
  @$pb.TagNumber(4)
  set highlight($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHighlight() => $_has(3);
  @$pb.TagNumber(4)
  void clearHighlight() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<Range> get highlightRanges => $_getList(4);

  @$pb.TagNumber(6)
  ChatMessage get message => $_getN(5);
  @$pb.TagNumber(6)
  set message(ChatMessage value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasMessage() => $_has(5);
  @$pb.TagNumber(6)
  void clearMessage() => $_clearField(6);
  @$pb.TagNumber(6)
  ChatMessage ensureMessage() => $_ensure(5);
}

class Search_Message extends $pb.GeneratedMessage {
  factory Search_Message() => create();

  Search_Message._();

  factory Search_Message.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Search_Message.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Search.Message',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Search_Message clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Search_Message copyWith(void Function(Search_Message) updates) =>
      super.copyWith((message) => updates(message as Search_Message))
          as Search_Message;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Search_Message create() => Search_Message._();
  @$core.override
  Search_Message createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Search_Message getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Search_Message>(create);
  static Search_Message? _defaultInstance;
}

class Search extends $pb.GeneratedMessage {
  factory Search() => create();

  Search._();

  factory Search.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Search.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Search',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Search clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Search copyWith(void Function(Search) updates) =>
      super.copyWith((message) => updates(message as Search)) as Search;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Search create() => Search._();
  @$core.override
  Search createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Search getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Search>(create);
  static Search? _defaultInstance;
}

class Block_Restrictions extends $pb.GeneratedMessage {
  factory Block_Restrictions({
    $core.bool? read,
    $core.bool? edit,
    $core.bool? remove,
    $core.bool? drag,
    $core.bool? dropOn,
  }) {
    final result = create();
    if (read != null) result.read = read;
    if (edit != null) result.edit = edit;
    if (remove != null) result.remove = remove;
    if (drag != null) result.drag = drag;
    if (dropOn != null) result.dropOn = dropOn;
    return result;
  }

  Block_Restrictions._();

  factory Block_Restrictions.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Restrictions.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Restrictions',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'read')
    ..aOB(2, _omitFieldNames ? '' : 'edit')
    ..aOB(3, _omitFieldNames ? '' : 'remove')
    ..aOB(4, _omitFieldNames ? '' : 'drag')
    ..aOB(5, _omitFieldNames ? '' : 'dropOn', protoName: 'dropOn')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Restrictions clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Restrictions copyWith(void Function(Block_Restrictions) updates) =>
      super.copyWith((message) => updates(message as Block_Restrictions))
          as Block_Restrictions;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Restrictions create() => Block_Restrictions._();
  @$core.override
  Block_Restrictions createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Restrictions getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Restrictions>(create);
  static Block_Restrictions? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get read => $_getBF(0);
  @$pb.TagNumber(1)
  set read($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRead() => $_has(0);
  @$pb.TagNumber(1)
  void clearRead() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get edit => $_getBF(1);
  @$pb.TagNumber(2)
  set edit($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEdit() => $_has(1);
  @$pb.TagNumber(2)
  void clearEdit() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get remove => $_getBF(2);
  @$pb.TagNumber(3)
  set remove($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRemove() => $_has(2);
  @$pb.TagNumber(3)
  void clearRemove() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get drag => $_getBF(3);
  @$pb.TagNumber(4)
  set drag($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDrag() => $_has(3);
  @$pb.TagNumber(4)
  void clearDrag() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get dropOn => $_getBF(4);
  @$pb.TagNumber(5)
  set dropOn($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDropOn() => $_has(4);
  @$pb.TagNumber(5)
  void clearDropOn() => $_clearField(5);
}

///
///  Layout have no visual representation, but affects on blocks, that it contains.
///  Row/Column layout blocks creates only automatically, after some of a D&D operations, for example
class Block_Content_Layout extends $pb.GeneratedMessage {
  factory Block_Content_Layout({
    Block_Content_Layout_Style? style,
  }) {
    final result = create();
    if (style != null) result.style = style;
    return result;
  }

  Block_Content_Layout._();

  factory Block_Content_Layout.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Layout.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Layout',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aE<Block_Content_Layout_Style>(1, _omitFieldNames ? '' : 'style',
        enumValues: Block_Content_Layout_Style.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Layout clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Layout copyWith(void Function(Block_Content_Layout) updates) =>
      super.copyWith((message) => updates(message as Block_Content_Layout))
          as Block_Content_Layout;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Layout create() => Block_Content_Layout._();
  @$core.override
  Block_Content_Layout createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Layout getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Layout>(create);
  static Block_Content_Layout? _defaultInstance;

  @$pb.TagNumber(1)
  Block_Content_Layout_Style get style => $_getN(0);
  @$pb.TagNumber(1)
  set style(Block_Content_Layout_Style value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStyle() => $_has(0);
  @$pb.TagNumber(1)
  void clearStyle() => $_clearField(1);
}

///
///  Link: block to link some content from an external sources.
class Block_Content_Link extends $pb.GeneratedMessage {
  factory Block_Content_Link({
    $core.String? targetBlockId,
    Block_Content_Link_Style? style,
    $0.Struct? fields,
    Block_Content_Link_IconSize? iconSize,
    Block_Content_Link_CardStyle? cardStyle,
    Block_Content_Link_Description? description,
    $core.Iterable<$core.String>? relations,
  }) {
    final result = create();
    if (targetBlockId != null) result.targetBlockId = targetBlockId;
    if (style != null) result.style = style;
    if (fields != null) result.fields = fields;
    if (iconSize != null) result.iconSize = iconSize;
    if (cardStyle != null) result.cardStyle = cardStyle;
    if (description != null) result.description = description;
    if (relations != null) result.relations.addAll(relations);
    return result;
  }

  Block_Content_Link._();

  factory Block_Content_Link.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Link.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Link',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'targetBlockId', protoName: 'targetBlockId')
    ..aE<Block_Content_Link_Style>(2, _omitFieldNames ? '' : 'style',
        enumValues: Block_Content_Link_Style.values)
    ..aOM<$0.Struct>(3, _omitFieldNames ? '' : 'fields',
        subBuilder: $0.Struct.create)
    ..aE<Block_Content_Link_IconSize>(4, _omitFieldNames ? '' : 'iconSize',
        protoName: 'iconSize', enumValues: Block_Content_Link_IconSize.values)
    ..aE<Block_Content_Link_CardStyle>(5, _omitFieldNames ? '' : 'cardStyle',
        protoName: 'cardStyle', enumValues: Block_Content_Link_CardStyle.values)
    ..aE<Block_Content_Link_Description>(
        6, _omitFieldNames ? '' : 'description',
        enumValues: Block_Content_Link_Description.values)
    ..pPS(7, _omitFieldNames ? '' : 'relations')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Link clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Link copyWith(void Function(Block_Content_Link) updates) =>
      super.copyWith((message) => updates(message as Block_Content_Link))
          as Block_Content_Link;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Link create() => Block_Content_Link._();
  @$core.override
  Block_Content_Link createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Link getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Link>(create);
  static Block_Content_Link? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get targetBlockId => $_getSZ(0);
  @$pb.TagNumber(1)
  set targetBlockId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTargetBlockId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTargetBlockId() => $_clearField(1);

  @$pb.TagNumber(2)
  Block_Content_Link_Style get style => $_getN(1);
  @$pb.TagNumber(2)
  set style(Block_Content_Link_Style value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStyle() => $_has(1);
  @$pb.TagNumber(2)
  void clearStyle() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Struct get fields => $_getN(2);
  @$pb.TagNumber(3)
  set fields($0.Struct value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasFields() => $_has(2);
  @$pb.TagNumber(3)
  void clearFields() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Struct ensureFields() => $_ensure(2);

  @$pb.TagNumber(4)
  Block_Content_Link_IconSize get iconSize => $_getN(3);
  @$pb.TagNumber(4)
  set iconSize(Block_Content_Link_IconSize value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasIconSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearIconSize() => $_clearField(4);

  @$pb.TagNumber(5)
  Block_Content_Link_CardStyle get cardStyle => $_getN(4);
  @$pb.TagNumber(5)
  set cardStyle(Block_Content_Link_CardStyle value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCardStyle() => $_has(4);
  @$pb.TagNumber(5)
  void clearCardStyle() => $_clearField(5);

  @$pb.TagNumber(6)
  Block_Content_Link_Description get description => $_getN(5);
  @$pb.TagNumber(6)
  set description(Block_Content_Link_Description value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get relations => $_getList(6);
}

///
///  Divider: block, that contains only one horizontal thin line
class Block_Content_Div extends $pb.GeneratedMessage {
  factory Block_Content_Div({
    Block_Content_Div_Style? style,
  }) {
    final result = create();
    if (style != null) result.style = style;
    return result;
  }

  Block_Content_Div._();

  factory Block_Content_Div.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Div.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Div',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aE<Block_Content_Div_Style>(1, _omitFieldNames ? '' : 'style',
        enumValues: Block_Content_Div_Style.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Div clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Div copyWith(void Function(Block_Content_Div) updates) =>
      super.copyWith((message) => updates(message as Block_Content_Div))
          as Block_Content_Div;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Div create() => Block_Content_Div._();
  @$core.override
  Block_Content_Div createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Div getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Div>(create);
  static Block_Content_Div? _defaultInstance;

  @$pb.TagNumber(1)
  Block_Content_Div_Style get style => $_getN(0);
  @$pb.TagNumber(1)
  set style(Block_Content_Div_Style value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStyle() => $_has(0);
  @$pb.TagNumber(1)
  void clearStyle() => $_clearField(1);
}

///
///  Bookmark is to keep a web-link and to preview a content.
class Block_Content_Bookmark extends $pb.GeneratedMessage {
  factory Block_Content_Bookmark({
    $core.String? url,
    $core.String? title,
    $core.String? description,
    $core.String? imageHash,
    $core.String? faviconHash,
    LinkPreview_Type? type,
    $core.String? targetObjectId,
    Block_Content_Bookmark_State? state,
  }) {
    final result = create();
    if (url != null) result.url = url;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (imageHash != null) result.imageHash = imageHash;
    if (faviconHash != null) result.faviconHash = faviconHash;
    if (type != null) result.type = type;
    if (targetObjectId != null) result.targetObjectId = targetObjectId;
    if (state != null) result.state = state;
    return result;
  }

  Block_Content_Bookmark._();

  factory Block_Content_Bookmark.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Bookmark.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Bookmark',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOS(4, _omitFieldNames ? '' : 'imageHash', protoName: 'imageHash')
    ..aOS(5, _omitFieldNames ? '' : 'faviconHash', protoName: 'faviconHash')
    ..aE<LinkPreview_Type>(6, _omitFieldNames ? '' : 'type',
        enumValues: LinkPreview_Type.values)
    ..aOS(7, _omitFieldNames ? '' : 'targetObjectId',
        protoName: 'targetObjectId')
    ..aE<Block_Content_Bookmark_State>(8, _omitFieldNames ? '' : 'state',
        enumValues: Block_Content_Bookmark_State.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Bookmark clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Bookmark copyWith(
          void Function(Block_Content_Bookmark) updates) =>
      super.copyWith((message) => updates(message as Block_Content_Bookmark))
          as Block_Content_Bookmark;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Bookmark create() => Block_Content_Bookmark._();
  @$core.override
  Block_Content_Bookmark createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Bookmark getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Bookmark>(create);
  static Block_Content_Bookmark? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  /// Deprecated. Get this data from the target object.
  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  /// Deprecated. Get this data from the target object.
  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  /// Deprecated. Get this data from the target object.
  @$pb.TagNumber(4)
  $core.String get imageHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set imageHash($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasImageHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearImageHash() => $_clearField(4);

  /// Deprecated. Get this data from the target object.
  @$pb.TagNumber(5)
  $core.String get faviconHash => $_getSZ(4);
  @$pb.TagNumber(5)
  set faviconHash($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFaviconHash() => $_has(4);
  @$pb.TagNumber(5)
  void clearFaviconHash() => $_clearField(5);

  @$pb.TagNumber(6)
  LinkPreview_Type get type => $_getN(5);
  @$pb.TagNumber(6)
  set type(LinkPreview_Type value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasType() => $_has(5);
  @$pb.TagNumber(6)
  void clearType() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get targetObjectId => $_getSZ(6);
  @$pb.TagNumber(7)
  set targetObjectId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTargetObjectId() => $_has(6);
  @$pb.TagNumber(7)
  void clearTargetObjectId() => $_clearField(7);

  @$pb.TagNumber(8)
  Block_Content_Bookmark_State get state => $_getN(7);
  @$pb.TagNumber(8)
  set state(Block_Content_Bookmark_State value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasState() => $_has(7);
  @$pb.TagNumber(8)
  void clearState() => $_clearField(8);
}

class Block_Content_Icon extends $pb.GeneratedMessage {
  factory Block_Content_Icon({
    $core.String? name,
  }) {
    final result = create();
    if (name != null) result.name = name;
    return result;
  }

  Block_Content_Icon._();

  factory Block_Content_Icon.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Icon.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Icon',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Icon clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Icon copyWith(void Function(Block_Content_Icon) updates) =>
      super.copyWith((message) => updates(message as Block_Content_Icon))
          as Block_Content_Icon;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Icon create() => Block_Content_Icon._();
  @$core.override
  Block_Content_Icon createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Icon getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Icon>(create);
  static Block_Content_Icon? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);
}

class Block_Content_FeaturedRelations extends $pb.GeneratedMessage {
  factory Block_Content_FeaturedRelations() => create();

  Block_Content_FeaturedRelations._();

  factory Block_Content_FeaturedRelations.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_FeaturedRelations.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.FeaturedRelations',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_FeaturedRelations clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_FeaturedRelations copyWith(
          void Function(Block_Content_FeaturedRelations) updates) =>
      super.copyWith(
              (message) => updates(message as Block_Content_FeaturedRelations))
          as Block_Content_FeaturedRelations;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_FeaturedRelations create() =>
      Block_Content_FeaturedRelations._();
  @$core.override
  Block_Content_FeaturedRelations createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_FeaturedRelations getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_FeaturedRelations>(
          create);
  static Block_Content_FeaturedRelations? _defaultInstance;
}

class Block_Content_Text_Marks extends $pb.GeneratedMessage {
  factory Block_Content_Text_Marks({
    $core.Iterable<Block_Content_Text_Mark>? marks,
  }) {
    final result = create();
    if (marks != null) result.marks.addAll(marks);
    return result;
  }

  Block_Content_Text_Marks._();

  factory Block_Content_Text_Marks.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Text_Marks.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Text.Marks',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPM<Block_Content_Text_Mark>(1, _omitFieldNames ? '' : 'marks',
        subBuilder: Block_Content_Text_Mark.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Text_Marks clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Text_Marks copyWith(
          void Function(Block_Content_Text_Marks) updates) =>
      super.copyWith((message) => updates(message as Block_Content_Text_Marks))
          as Block_Content_Text_Marks;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Text_Marks create() => Block_Content_Text_Marks._();
  @$core.override
  Block_Content_Text_Marks createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Text_Marks getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Text_Marks>(create);
  static Block_Content_Text_Marks? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Block_Content_Text_Mark> get marks => $_getList(0);
}

class Block_Content_Text_Mark extends $pb.GeneratedMessage {
  factory Block_Content_Text_Mark({
    Range? range,
    Block_Content_Text_Mark_Type? type,
    $core.String? param,
  }) {
    final result = create();
    if (range != null) result.range = range;
    if (type != null) result.type = type;
    if (param != null) result.param = param;
    return result;
  }

  Block_Content_Text_Mark._();

  factory Block_Content_Text_Mark.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Text_Mark.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Text.Mark',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOM<Range>(1, _omitFieldNames ? '' : 'range', subBuilder: Range.create)
    ..aE<Block_Content_Text_Mark_Type>(2, _omitFieldNames ? '' : 'type',
        enumValues: Block_Content_Text_Mark_Type.values)
    ..aOS(3, _omitFieldNames ? '' : 'param')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Text_Mark clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Text_Mark copyWith(
          void Function(Block_Content_Text_Mark) updates) =>
      super.copyWith((message) => updates(message as Block_Content_Text_Mark))
          as Block_Content_Text_Mark;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Text_Mark create() => Block_Content_Text_Mark._();
  @$core.override
  Block_Content_Text_Mark createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Text_Mark getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Text_Mark>(create);
  static Block_Content_Text_Mark? _defaultInstance;

  @$pb.TagNumber(1)
  Range get range => $_getN(0);
  @$pb.TagNumber(1)
  set range(Range value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRange() => $_has(0);
  @$pb.TagNumber(1)
  void clearRange() => $_clearField(1);
  @$pb.TagNumber(1)
  Range ensureRange() => $_ensure(0);

  @$pb.TagNumber(2)
  Block_Content_Text_Mark_Type get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(Block_Content_Text_Mark_Type value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get param => $_getSZ(2);
  @$pb.TagNumber(3)
  set param($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasParam() => $_has(2);
  @$pb.TagNumber(3)
  void clearParam() => $_clearField(3);
}

class Block_Content_Text extends $pb.GeneratedMessage {
  factory Block_Content_Text({
    $core.String? text,
    Block_Content_Text_Style? style,
    Block_Content_Text_Marks? marks,
    $core.bool? checked,
    $core.String? color,
    $core.String? iconEmoji,
    $core.String? iconImage,
  }) {
    final result = create();
    if (text != null) result.text = text;
    if (style != null) result.style = style;
    if (marks != null) result.marks = marks;
    if (checked != null) result.checked = checked;
    if (color != null) result.color = color;
    if (iconEmoji != null) result.iconEmoji = iconEmoji;
    if (iconImage != null) result.iconImage = iconImage;
    return result;
  }

  Block_Content_Text._();

  factory Block_Content_Text.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Text.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Text',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..aE<Block_Content_Text_Style>(2, _omitFieldNames ? '' : 'style',
        enumValues: Block_Content_Text_Style.values)
    ..aOM<Block_Content_Text_Marks>(3, _omitFieldNames ? '' : 'marks',
        subBuilder: Block_Content_Text_Marks.create)
    ..aOB(4, _omitFieldNames ? '' : 'checked')
    ..aOS(5, _omitFieldNames ? '' : 'color')
    ..aOS(6, _omitFieldNames ? '' : 'iconEmoji', protoName: 'iconEmoji')
    ..aOS(7, _omitFieldNames ? '' : 'iconImage', protoName: 'iconImage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Text clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Text copyWith(void Function(Block_Content_Text) updates) =>
      super.copyWith((message) => updates(message as Block_Content_Text))
          as Block_Content_Text;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Text create() => Block_Content_Text._();
  @$core.override
  Block_Content_Text createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Text getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Text>(create);
  static Block_Content_Text? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  @$pb.TagNumber(2)
  Block_Content_Text_Style get style => $_getN(1);
  @$pb.TagNumber(2)
  set style(Block_Content_Text_Style value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStyle() => $_has(1);
  @$pb.TagNumber(2)
  void clearStyle() => $_clearField(2);

  @$pb.TagNumber(3)
  Block_Content_Text_Marks get marks => $_getN(2);
  @$pb.TagNumber(3)
  set marks(Block_Content_Text_Marks value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasMarks() => $_has(2);
  @$pb.TagNumber(3)
  void clearMarks() => $_clearField(3);
  @$pb.TagNumber(3)
  Block_Content_Text_Marks ensureMarks() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.bool get checked => $_getBF(3);
  @$pb.TagNumber(4)
  set checked($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasChecked() => $_has(3);
  @$pb.TagNumber(4)
  void clearChecked() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get color => $_getSZ(4);
  @$pb.TagNumber(5)
  set color($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasColor() => $_has(4);
  @$pb.TagNumber(5)
  void clearColor() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get iconEmoji => $_getSZ(5);
  @$pb.TagNumber(6)
  set iconEmoji($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIconEmoji() => $_has(5);
  @$pb.TagNumber(6)
  void clearIconEmoji() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get iconImage => $_getSZ(6);
  @$pb.TagNumber(7)
  set iconImage($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIconImage() => $_has(6);
  @$pb.TagNumber(7)
  void clearIconImage() => $_clearField(7);
}

class Block_Content_File extends $pb.GeneratedMessage {
  factory Block_Content_File({
    $core.String? hash,
    $core.String? name,
    Block_Content_File_Type? type,
    $core.String? mime,
    $fixnum.Int64? size,
    $fixnum.Int64? addedAt,
    Block_Content_File_State? state,
    Block_Content_File_Style? style,
    $core.String? targetObjectId,
  }) {
    final result = create();
    if (hash != null) result.hash = hash;
    if (name != null) result.name = name;
    if (type != null) result.type = type;
    if (mime != null) result.mime = mime;
    if (size != null) result.size = size;
    if (addedAt != null) result.addedAt = addedAt;
    if (state != null) result.state = state;
    if (style != null) result.style = style;
    if (targetObjectId != null) result.targetObjectId = targetObjectId;
    return result;
  }

  Block_Content_File._();

  factory Block_Content_File.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_File.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.File',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hash')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aE<Block_Content_File_Type>(3, _omitFieldNames ? '' : 'type',
        enumValues: Block_Content_File_Type.values)
    ..aOS(4, _omitFieldNames ? '' : 'mime')
    ..aInt64(5, _omitFieldNames ? '' : 'size')
    ..aInt64(6, _omitFieldNames ? '' : 'addedAt', protoName: 'addedAt')
    ..aE<Block_Content_File_State>(7, _omitFieldNames ? '' : 'state',
        enumValues: Block_Content_File_State.values)
    ..aE<Block_Content_File_Style>(8, _omitFieldNames ? '' : 'style',
        enumValues: Block_Content_File_Style.values)
    ..aOS(9, _omitFieldNames ? '' : 'targetObjectId',
        protoName: 'targetObjectId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_File clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_File copyWith(void Function(Block_Content_File) updates) =>
      super.copyWith((message) => updates(message as Block_Content_File))
          as Block_Content_File;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_File create() => Block_Content_File._();
  @$core.override
  Block_Content_File createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_File getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_File>(create);
  static Block_Content_File? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  Block_Content_File_Type get type => $_getN(2);
  @$pb.TagNumber(3)
  set type(Block_Content_File_Type value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get mime => $_getSZ(3);
  @$pb.TagNumber(4)
  set mime($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMime() => $_has(3);
  @$pb.TagNumber(4)
  void clearMime() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get size => $_getI64(4);
  @$pb.TagNumber(5)
  set size($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSize() => $_has(4);
  @$pb.TagNumber(5)
  void clearSize() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get addedAt => $_getI64(5);
  @$pb.TagNumber(6)
  set addedAt($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAddedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearAddedAt() => $_clearField(6);

  @$pb.TagNumber(7)
  Block_Content_File_State get state => $_getN(6);
  @$pb.TagNumber(7)
  set state(Block_Content_File_State value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasState() => $_has(6);
  @$pb.TagNumber(7)
  void clearState() => $_clearField(7);

  @$pb.TagNumber(8)
  Block_Content_File_Style get style => $_getN(7);
  @$pb.TagNumber(8)
  set style(Block_Content_File_Style value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasStyle() => $_has(7);
  @$pb.TagNumber(8)
  void clearStyle() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get targetObjectId => $_getSZ(8);
  @$pb.TagNumber(9)
  set targetObjectId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTargetObjectId() => $_has(8);
  @$pb.TagNumber(9)
  void clearTargetObjectId() => $_clearField(9);
}

class Block_Content_Smartblock extends $pb.GeneratedMessage {
  factory Block_Content_Smartblock() => create();

  Block_Content_Smartblock._();

  factory Block_Content_Smartblock.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Smartblock.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Smartblock',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Smartblock clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Smartblock copyWith(
          void Function(Block_Content_Smartblock) updates) =>
      super.copyWith((message) => updates(message as Block_Content_Smartblock))
          as Block_Content_Smartblock;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Smartblock create() => Block_Content_Smartblock._();
  @$core.override
  Block_Content_Smartblock createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Smartblock getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Smartblock>(create);
  static Block_Content_Smartblock? _defaultInstance;
}

class Block_Content_Dataview_View extends $pb.GeneratedMessage {
  factory Block_Content_Dataview_View({
    $core.String? id,
    Block_Content_Dataview_View_Type? type,
    $core.String? name,
    $core.Iterable<Block_Content_Dataview_Sort>? sorts,
    $core.Iterable<Block_Content_Dataview_Filter>? filters,
    $core.Iterable<Block_Content_Dataview_Relation>? relations,
    $core.String? coverRelationKey,
    $core.bool? hideIcon,
    Block_Content_Dataview_View_Size? cardSize,
    $core.bool? coverFit,
    $core.String? groupRelationKey,
    $core.bool? groupBackgroundColors,
    $core.int? pageLimit,
    $core.String? defaultTemplateId,
    $core.String? defaultObjectTypeId,
    $core.String? endRelationKey,
    $core.bool? wrapContent,
    Block_Content_Dataview_View_ListSize? listSize,
    $core.bool? alternateRows,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    if (name != null) result.name = name;
    if (sorts != null) result.sorts.addAll(sorts);
    if (filters != null) result.filters.addAll(filters);
    if (relations != null) result.relations.addAll(relations);
    if (coverRelationKey != null) result.coverRelationKey = coverRelationKey;
    if (hideIcon != null) result.hideIcon = hideIcon;
    if (cardSize != null) result.cardSize = cardSize;
    if (coverFit != null) result.coverFit = coverFit;
    if (groupRelationKey != null) result.groupRelationKey = groupRelationKey;
    if (groupBackgroundColors != null)
      result.groupBackgroundColors = groupBackgroundColors;
    if (pageLimit != null) result.pageLimit = pageLimit;
    if (defaultTemplateId != null) result.defaultTemplateId = defaultTemplateId;
    if (defaultObjectTypeId != null)
      result.defaultObjectTypeId = defaultObjectTypeId;
    if (endRelationKey != null) result.endRelationKey = endRelationKey;
    if (wrapContent != null) result.wrapContent = wrapContent;
    if (listSize != null) result.listSize = listSize;
    if (alternateRows != null) result.alternateRows = alternateRows;
    return result;
  }

  Block_Content_Dataview_View._();

  factory Block_Content_Dataview_View.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Dataview_View.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Dataview.View',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<Block_Content_Dataview_View_Type>(2, _omitFieldNames ? '' : 'type',
        enumValues: Block_Content_Dataview_View_Type.values)
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..pPM<Block_Content_Dataview_Sort>(4, _omitFieldNames ? '' : 'sorts',
        subBuilder: Block_Content_Dataview_Sort.create)
    ..pPM<Block_Content_Dataview_Filter>(5, _omitFieldNames ? '' : 'filters',
        subBuilder: Block_Content_Dataview_Filter.create)
    ..pPM<Block_Content_Dataview_Relation>(
        6, _omitFieldNames ? '' : 'relations',
        subBuilder: Block_Content_Dataview_Relation.create)
    ..aOS(7, _omitFieldNames ? '' : 'coverRelationKey',
        protoName: 'coverRelationKey')
    ..aOB(8, _omitFieldNames ? '' : 'hideIcon', protoName: 'hideIcon')
    ..aE<Block_Content_Dataview_View_Size>(9, _omitFieldNames ? '' : 'cardSize',
        protoName: 'cardSize',
        enumValues: Block_Content_Dataview_View_Size.values)
    ..aOB(10, _omitFieldNames ? '' : 'coverFit', protoName: 'coverFit')
    ..aOS(11, _omitFieldNames ? '' : 'groupRelationKey',
        protoName: 'groupRelationKey')
    ..aOB(12, _omitFieldNames ? '' : 'groupBackgroundColors',
        protoName: 'groupBackgroundColors')
    ..aI(13, _omitFieldNames ? '' : 'pageLimit', protoName: 'pageLimit')
    ..aOS(14, _omitFieldNames ? '' : 'defaultTemplateId',
        protoName: 'defaultTemplateId')
    ..aOS(15, _omitFieldNames ? '' : 'defaultObjectTypeId',
        protoName: 'defaultObjectTypeId')
    ..aOS(16, _omitFieldNames ? '' : 'endRelationKey',
        protoName: 'endRelationKey')
    ..aOB(17, _omitFieldNames ? '' : 'wrapContent', protoName: 'wrapContent')
    ..aE<Block_Content_Dataview_View_ListSize>(
        18, _omitFieldNames ? '' : 'listSize',
        protoName: 'listSize',
        enumValues: Block_Content_Dataview_View_ListSize.values)
    ..aOB(19, _omitFieldNames ? '' : 'alternateRows',
        protoName: 'alternateRows')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_View clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_View copyWith(
          void Function(Block_Content_Dataview_View) updates) =>
      super.copyWith(
              (message) => updates(message as Block_Content_Dataview_View))
          as Block_Content_Dataview_View;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_View create() =>
      Block_Content_Dataview_View._();
  @$core.override
  Block_Content_Dataview_View createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_View getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Dataview_View>(create);
  static Block_Content_Dataview_View? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  Block_Content_Dataview_View_Type get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(Block_Content_Dataview_View_Type value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<Block_Content_Dataview_Sort> get sorts => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<Block_Content_Dataview_Filter> get filters => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<Block_Content_Dataview_Relation> get relations => $_getList(5);

  @$pb.TagNumber(7)
  $core.String get coverRelationKey => $_getSZ(6);
  @$pb.TagNumber(7)
  set coverRelationKey($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCoverRelationKey() => $_has(6);
  @$pb.TagNumber(7)
  void clearCoverRelationKey() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get hideIcon => $_getBF(7);
  @$pb.TagNumber(8)
  set hideIcon($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasHideIcon() => $_has(7);
  @$pb.TagNumber(8)
  void clearHideIcon() => $_clearField(8);

  @$pb.TagNumber(9)
  Block_Content_Dataview_View_Size get cardSize => $_getN(8);
  @$pb.TagNumber(9)
  set cardSize(Block_Content_Dataview_View_Size value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasCardSize() => $_has(8);
  @$pb.TagNumber(9)
  void clearCardSize() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get coverFit => $_getBF(9);
  @$pb.TagNumber(10)
  set coverFit($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCoverFit() => $_has(9);
  @$pb.TagNumber(10)
  void clearCoverFit() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get groupRelationKey => $_getSZ(10);
  @$pb.TagNumber(11)
  set groupRelationKey($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasGroupRelationKey() => $_has(10);
  @$pb.TagNumber(11)
  void clearGroupRelationKey() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get groupBackgroundColors => $_getBF(11);
  @$pb.TagNumber(12)
  set groupBackgroundColors($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasGroupBackgroundColors() => $_has(11);
  @$pb.TagNumber(12)
  void clearGroupBackgroundColors() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get pageLimit => $_getIZ(12);
  @$pb.TagNumber(13)
  set pageLimit($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasPageLimit() => $_has(12);
  @$pb.TagNumber(13)
  void clearPageLimit() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get defaultTemplateId => $_getSZ(13);
  @$pb.TagNumber(14)
  set defaultTemplateId($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasDefaultTemplateId() => $_has(13);
  @$pb.TagNumber(14)
  void clearDefaultTemplateId() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get defaultObjectTypeId => $_getSZ(14);
  @$pb.TagNumber(15)
  set defaultObjectTypeId($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasDefaultObjectTypeId() => $_has(14);
  @$pb.TagNumber(15)
  void clearDefaultObjectTypeId() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get endRelationKey => $_getSZ(15);
  @$pb.TagNumber(16)
  set endRelationKey($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasEndRelationKey() => $_has(15);
  @$pb.TagNumber(16)
  void clearEndRelationKey() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.bool get wrapContent => $_getBF(16);
  @$pb.TagNumber(17)
  set wrapContent($core.bool value) => $_setBool(16, value);
  @$pb.TagNumber(17)
  $core.bool hasWrapContent() => $_has(16);
  @$pb.TagNumber(17)
  void clearWrapContent() => $_clearField(17);

  @$pb.TagNumber(18)
  Block_Content_Dataview_View_ListSize get listSize => $_getN(17);
  @$pb.TagNumber(18)
  set listSize(Block_Content_Dataview_View_ListSize value) =>
      $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasListSize() => $_has(17);
  @$pb.TagNumber(18)
  void clearListSize() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.bool get alternateRows => $_getBF(18);
  @$pb.TagNumber(19)
  set alternateRows($core.bool value) => $_setBool(18, value);
  @$pb.TagNumber(19)
  $core.bool hasAlternateRows() => $_has(18);
  @$pb.TagNumber(19)
  void clearAlternateRows() => $_clearField(19);
}

class Block_Content_Dataview_Relation extends $pb.GeneratedMessage {
  factory Block_Content_Dataview_Relation({
    $core.String? key,
    $core.bool? isVisible,
    $core.int? width,
    $core.bool? dateIncludeTime,
    Block_Content_Dataview_Relation_TimeFormat? timeFormat,
    Block_Content_Dataview_Relation_DateFormat? dateFormat,
    Block_Content_Dataview_Relation_FormulaType? formula,
    Block_Align? align,
  }) {
    final result = create();
    if (key != null) result.key = key;
    if (isVisible != null) result.isVisible = isVisible;
    if (width != null) result.width = width;
    if (dateIncludeTime != null) result.dateIncludeTime = dateIncludeTime;
    if (timeFormat != null) result.timeFormat = timeFormat;
    if (dateFormat != null) result.dateFormat = dateFormat;
    if (formula != null) result.formula = formula;
    if (align != null) result.align = align;
    return result;
  }

  Block_Content_Dataview_Relation._();

  factory Block_Content_Dataview_Relation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Dataview_Relation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Dataview.Relation',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOB(2, _omitFieldNames ? '' : 'isVisible', protoName: 'isVisible')
    ..aI(3, _omitFieldNames ? '' : 'width')
    ..aOB(5, _omitFieldNames ? '' : 'dateIncludeTime',
        protoName: 'dateIncludeTime')
    ..aE<Block_Content_Dataview_Relation_TimeFormat>(
        6, _omitFieldNames ? '' : 'timeFormat',
        protoName: 'timeFormat',
        enumValues: Block_Content_Dataview_Relation_TimeFormat.values)
    ..aE<Block_Content_Dataview_Relation_DateFormat>(
        7, _omitFieldNames ? '' : 'dateFormat',
        protoName: 'dateFormat',
        enumValues: Block_Content_Dataview_Relation_DateFormat.values)
    ..aE<Block_Content_Dataview_Relation_FormulaType>(
        8, _omitFieldNames ? '' : 'formula',
        enumValues: Block_Content_Dataview_Relation_FormulaType.values)
    ..aE<Block_Align>(9, _omitFieldNames ? '' : 'align',
        enumValues: Block_Align.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_Relation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_Relation copyWith(
          void Function(Block_Content_Dataview_Relation) updates) =>
      super.copyWith(
              (message) => updates(message as Block_Content_Dataview_Relation))
          as Block_Content_Dataview_Relation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_Relation create() =>
      Block_Content_Dataview_Relation._();
  @$core.override
  Block_Content_Dataview_Relation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_Relation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Dataview_Relation>(
          create);
  static Block_Content_Dataview_Relation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isVisible => $_getBF(1);
  @$pb.TagNumber(2)
  set isVisible($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsVisible() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsVisible() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get width => $_getIZ(2);
  @$pb.TagNumber(3)
  set width($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWidth() => $_has(2);
  @$pb.TagNumber(3)
  void clearWidth() => $_clearField(3);

  /// bool isReadOnly = 4; // deprecated
  @$pb.TagNumber(5)
  $core.bool get dateIncludeTime => $_getBF(3);
  @$pb.TagNumber(5)
  set dateIncludeTime($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(5)
  $core.bool hasDateIncludeTime() => $_has(3);
  @$pb.TagNumber(5)
  void clearDateIncludeTime() => $_clearField(5);

  @$pb.TagNumber(6)
  Block_Content_Dataview_Relation_TimeFormat get timeFormat => $_getN(4);
  @$pb.TagNumber(6)
  set timeFormat(Block_Content_Dataview_Relation_TimeFormat value) =>
      $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasTimeFormat() => $_has(4);
  @$pb.TagNumber(6)
  void clearTimeFormat() => $_clearField(6);

  @$pb.TagNumber(7)
  Block_Content_Dataview_Relation_DateFormat get dateFormat => $_getN(5);
  @$pb.TagNumber(7)
  set dateFormat(Block_Content_Dataview_Relation_DateFormat value) =>
      $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasDateFormat() => $_has(5);
  @$pb.TagNumber(7)
  void clearDateFormat() => $_clearField(7);

  @$pb.TagNumber(8)
  Block_Content_Dataview_Relation_FormulaType get formula => $_getN(6);
  @$pb.TagNumber(8)
  set formula(Block_Content_Dataview_Relation_FormulaType value) =>
      $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasFormula() => $_has(6);
  @$pb.TagNumber(8)
  void clearFormula() => $_clearField(8);

  @$pb.TagNumber(9)
  Block_Align get align => $_getN(7);
  @$pb.TagNumber(9)
  set align(Block_Align value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasAlign() => $_has(7);
  @$pb.TagNumber(9)
  void clearAlign() => $_clearField(9);
}

class Block_Content_Dataview_Sort extends $pb.GeneratedMessage {
  factory Block_Content_Dataview_Sort({
    $core.String? relationKey,
    Block_Content_Dataview_Sort_Type? type,
    $core.Iterable<$0.Value>? customOrder,
    RelationFormat? format,
    $core.bool? includeTime,
    $core.String? id,
    Block_Content_Dataview_Sort_EmptyType? emptyPlacement,
    $core.bool? noCollate,
  }) {
    final result = create();
    if (relationKey != null) result.relationKey = relationKey;
    if (type != null) result.type = type;
    if (customOrder != null) result.customOrder.addAll(customOrder);
    if (format != null) result.format = format;
    if (includeTime != null) result.includeTime = includeTime;
    if (id != null) result.id = id;
    if (emptyPlacement != null) result.emptyPlacement = emptyPlacement;
    if (noCollate != null) result.noCollate = noCollate;
    return result;
  }

  Block_Content_Dataview_Sort._();

  factory Block_Content_Dataview_Sort.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Dataview_Sort.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Dataview.Sort',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'RelationKey', protoName: 'RelationKey')
    ..aE<Block_Content_Dataview_Sort_Type>(2, _omitFieldNames ? '' : 'type',
        enumValues: Block_Content_Dataview_Sort_Type.values)
    ..pPM<$0.Value>(3, _omitFieldNames ? '' : 'customOrder',
        protoName: 'customOrder', subBuilder: $0.Value.create)
    ..aE<RelationFormat>(4, _omitFieldNames ? '' : 'format',
        enumValues: RelationFormat.values)
    ..aOB(5, _omitFieldNames ? '' : 'includeTime', protoName: 'includeTime')
    ..aOS(6, _omitFieldNames ? '' : 'id')
    ..aE<Block_Content_Dataview_Sort_EmptyType>(
        7, _omitFieldNames ? '' : 'emptyPlacement',
        protoName: 'emptyPlacement',
        enumValues: Block_Content_Dataview_Sort_EmptyType.values)
    ..aOB(8, _omitFieldNames ? '' : 'noCollate', protoName: 'noCollate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_Sort clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_Sort copyWith(
          void Function(Block_Content_Dataview_Sort) updates) =>
      super.copyWith(
              (message) => updates(message as Block_Content_Dataview_Sort))
          as Block_Content_Dataview_Sort;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_Sort create() =>
      Block_Content_Dataview_Sort._();
  @$core.override
  Block_Content_Dataview_Sort createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_Sort getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Dataview_Sort>(create);
  static Block_Content_Dataview_Sort? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get relationKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set relationKey($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRelationKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearRelationKey() => $_clearField(1);

  @$pb.TagNumber(2)
  Block_Content_Dataview_Sort_Type get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(Block_Content_Dataview_Sort_Type value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$0.Value> get customOrder => $_getList(2);

  @$pb.TagNumber(4)
  RelationFormat get format => $_getN(3);
  @$pb.TagNumber(4)
  set format(RelationFormat value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasFormat() => $_has(3);
  @$pb.TagNumber(4)
  void clearFormat() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get includeTime => $_getBF(4);
  @$pb.TagNumber(5)
  set includeTime($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIncludeTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearIncludeTime() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get id => $_getSZ(5);
  @$pb.TagNumber(6)
  set id($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasId() => $_has(5);
  @$pb.TagNumber(6)
  void clearId() => $_clearField(6);

  @$pb.TagNumber(7)
  Block_Content_Dataview_Sort_EmptyType get emptyPlacement => $_getN(6);
  @$pb.TagNumber(7)
  set emptyPlacement(Block_Content_Dataview_Sort_EmptyType value) =>
      $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasEmptyPlacement() => $_has(6);
  @$pb.TagNumber(7)
  void clearEmptyPlacement() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get noCollate => $_getBF(7);
  @$pb.TagNumber(8)
  set noCollate($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNoCollate() => $_has(7);
  @$pb.TagNumber(8)
  void clearNoCollate() => $_clearField(8);
}

class Block_Content_Dataview_Filter extends $pb.GeneratedMessage {
  factory Block_Content_Dataview_Filter({
    Block_Content_Dataview_Filter_Operator? operator,
    $core.String? relationKey,
    Block_Content_Dataview_Filter_Condition? condition,
    $0.Value? value,
    $core.String? relationProperty,
    Block_Content_Dataview_Filter_QuickOption? quickOption,
    RelationFormat? format,
    $core.bool? includeTime,
    $core.String? id,
    $core.Iterable<Block_Content_Dataview_Filter>? nestedFilters,
  }) {
    final result = create();
    if (operator != null) result.operator = operator;
    if (relationKey != null) result.relationKey = relationKey;
    if (condition != null) result.condition = condition;
    if (value != null) result.value = value;
    if (relationProperty != null) result.relationProperty = relationProperty;
    if (quickOption != null) result.quickOption = quickOption;
    if (format != null) result.format = format;
    if (includeTime != null) result.includeTime = includeTime;
    if (id != null) result.id = id;
    if (nestedFilters != null) result.nestedFilters.addAll(nestedFilters);
    return result;
  }

  Block_Content_Dataview_Filter._();

  factory Block_Content_Dataview_Filter.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Dataview_Filter.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Dataview.Filter',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aE<Block_Content_Dataview_Filter_Operator>(
        1, _omitFieldNames ? '' : 'operator',
        enumValues: Block_Content_Dataview_Filter_Operator.values)
    ..aOS(2, _omitFieldNames ? '' : 'RelationKey', protoName: 'RelationKey')
    ..aE<Block_Content_Dataview_Filter_Condition>(
        3, _omitFieldNames ? '' : 'condition',
        enumValues: Block_Content_Dataview_Filter_Condition.values)
    ..aOM<$0.Value>(4, _omitFieldNames ? '' : 'value',
        subBuilder: $0.Value.create)
    ..aOS(5, _omitFieldNames ? '' : 'relationProperty',
        protoName: 'relationProperty')
    ..aE<Block_Content_Dataview_Filter_QuickOption>(
        6, _omitFieldNames ? '' : 'quickOption',
        protoName: 'quickOption',
        enumValues: Block_Content_Dataview_Filter_QuickOption.values)
    ..aE<RelationFormat>(7, _omitFieldNames ? '' : 'format',
        enumValues: RelationFormat.values)
    ..aOB(8, _omitFieldNames ? '' : 'includeTime', protoName: 'includeTime')
    ..aOS(9, _omitFieldNames ? '' : 'id')
    ..pPM<Block_Content_Dataview_Filter>(
        10, _omitFieldNames ? '' : 'nestedFilters',
        protoName: 'nestedFilters',
        subBuilder: Block_Content_Dataview_Filter.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_Filter clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_Filter copyWith(
          void Function(Block_Content_Dataview_Filter) updates) =>
      super.copyWith(
              (message) => updates(message as Block_Content_Dataview_Filter))
          as Block_Content_Dataview_Filter;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_Filter create() =>
      Block_Content_Dataview_Filter._();
  @$core.override
  Block_Content_Dataview_Filter createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_Filter getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Dataview_Filter>(create);
  static Block_Content_Dataview_Filter? _defaultInstance;

  @$pb.TagNumber(1)
  Block_Content_Dataview_Filter_Operator get operator => $_getN(0);
  @$pb.TagNumber(1)
  set operator(Block_Content_Dataview_Filter_Operator value) =>
      $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOperator() => $_has(0);
  @$pb.TagNumber(1)
  void clearOperator() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get relationKey => $_getSZ(1);
  @$pb.TagNumber(2)
  set relationKey($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRelationKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearRelationKey() => $_clearField(2);

  @$pb.TagNumber(3)
  Block_Content_Dataview_Filter_Condition get condition => $_getN(2);
  @$pb.TagNumber(3)
  set condition(Block_Content_Dataview_Filter_Condition value) =>
      $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCondition() => $_has(2);
  @$pb.TagNumber(3)
  void clearCondition() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Value get value => $_getN(3);
  @$pb.TagNumber(4)
  set value($0.Value value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearValue() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Value ensureValue() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.String get relationProperty => $_getSZ(4);
  @$pb.TagNumber(5)
  set relationProperty($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRelationProperty() => $_has(4);
  @$pb.TagNumber(5)
  void clearRelationProperty() => $_clearField(5);

  @$pb.TagNumber(6)
  Block_Content_Dataview_Filter_QuickOption get quickOption => $_getN(5);
  @$pb.TagNumber(6)
  set quickOption(Block_Content_Dataview_Filter_QuickOption value) =>
      $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasQuickOption() => $_has(5);
  @$pb.TagNumber(6)
  void clearQuickOption() => $_clearField(6);

  @$pb.TagNumber(7)
  RelationFormat get format => $_getN(6);
  @$pb.TagNumber(7)
  set format(RelationFormat value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasFormat() => $_has(6);
  @$pb.TagNumber(7)
  void clearFormat() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get includeTime => $_getBF(7);
  @$pb.TagNumber(8)
  set includeTime($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIncludeTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearIncludeTime() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get id => $_getSZ(8);
  @$pb.TagNumber(9)
  set id($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasId() => $_has(8);
  @$pb.TagNumber(9)
  void clearId() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<Block_Content_Dataview_Filter> get nestedFilters => $_getList(9);
}

class Block_Content_Dataview_GroupOrder extends $pb.GeneratedMessage {
  factory Block_Content_Dataview_GroupOrder({
    $core.String? viewId,
    $core.Iterable<Block_Content_Dataview_ViewGroup>? viewGroups,
  }) {
    final result = create();
    if (viewId != null) result.viewId = viewId;
    if (viewGroups != null) result.viewGroups.addAll(viewGroups);
    return result;
  }

  Block_Content_Dataview_GroupOrder._();

  factory Block_Content_Dataview_GroupOrder.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Dataview_GroupOrder.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Dataview.GroupOrder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'viewId', protoName: 'viewId')
    ..pPM<Block_Content_Dataview_ViewGroup>(
        2, _omitFieldNames ? '' : 'viewGroups',
        protoName: 'viewGroups',
        subBuilder: Block_Content_Dataview_ViewGroup.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_GroupOrder clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_GroupOrder copyWith(
          void Function(Block_Content_Dataview_GroupOrder) updates) =>
      super.copyWith((message) =>
              updates(message as Block_Content_Dataview_GroupOrder))
          as Block_Content_Dataview_GroupOrder;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_GroupOrder create() =>
      Block_Content_Dataview_GroupOrder._();
  @$core.override
  Block_Content_Dataview_GroupOrder createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_GroupOrder getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Dataview_GroupOrder>(
          create);
  static Block_Content_Dataview_GroupOrder? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get viewId => $_getSZ(0);
  @$pb.TagNumber(1)
  set viewId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasViewId() => $_has(0);
  @$pb.TagNumber(1)
  void clearViewId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<Block_Content_Dataview_ViewGroup> get viewGroups => $_getList(1);
}

class Block_Content_Dataview_ViewGroup extends $pb.GeneratedMessage {
  factory Block_Content_Dataview_ViewGroup({
    $core.String? groupId,
    $core.int? index,
    $core.bool? hidden,
    $core.String? backgroundColor,
  }) {
    final result = create();
    if (groupId != null) result.groupId = groupId;
    if (index != null) result.index = index;
    if (hidden != null) result.hidden = hidden;
    if (backgroundColor != null) result.backgroundColor = backgroundColor;
    return result;
  }

  Block_Content_Dataview_ViewGroup._();

  factory Block_Content_Dataview_ViewGroup.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Dataview_ViewGroup.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Dataview.ViewGroup',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'groupId', protoName: 'groupId')
    ..aI(2, _omitFieldNames ? '' : 'index')
    ..aOB(3, _omitFieldNames ? '' : 'hidden')
    ..aOS(4, _omitFieldNames ? '' : 'backgroundColor',
        protoName: 'backgroundColor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_ViewGroup clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_ViewGroup copyWith(
          void Function(Block_Content_Dataview_ViewGroup) updates) =>
      super.copyWith(
              (message) => updates(message as Block_Content_Dataview_ViewGroup))
          as Block_Content_Dataview_ViewGroup;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_ViewGroup create() =>
      Block_Content_Dataview_ViewGroup._();
  @$core.override
  Block_Content_Dataview_ViewGroup createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_ViewGroup getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Dataview_ViewGroup>(
          create);
  static Block_Content_Dataview_ViewGroup? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get groupId => $_getSZ(0);
  @$pb.TagNumber(1)
  set groupId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGroupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroupId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get index => $_getIZ(1);
  @$pb.TagNumber(2)
  set index($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get hidden => $_getBF(2);
  @$pb.TagNumber(3)
  set hidden($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHidden() => $_has(2);
  @$pb.TagNumber(3)
  void clearHidden() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get backgroundColor => $_getSZ(3);
  @$pb.TagNumber(4)
  set backgroundColor($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBackgroundColor() => $_has(3);
  @$pb.TagNumber(4)
  void clearBackgroundColor() => $_clearField(4);
}

class Block_Content_Dataview_ObjectOrder extends $pb.GeneratedMessage {
  factory Block_Content_Dataview_ObjectOrder({
    $core.String? viewId,
    $core.String? groupId,
    $core.Iterable<$core.String>? objectIds,
  }) {
    final result = create();
    if (viewId != null) result.viewId = viewId;
    if (groupId != null) result.groupId = groupId;
    if (objectIds != null) result.objectIds.addAll(objectIds);
    return result;
  }

  Block_Content_Dataview_ObjectOrder._();

  factory Block_Content_Dataview_ObjectOrder.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Dataview_ObjectOrder.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Dataview.ObjectOrder',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'viewId', protoName: 'viewId')
    ..aOS(2, _omitFieldNames ? '' : 'groupId', protoName: 'groupId')
    ..pPS(3, _omitFieldNames ? '' : 'objectIds', protoName: 'objectIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_ObjectOrder clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_ObjectOrder copyWith(
          void Function(Block_Content_Dataview_ObjectOrder) updates) =>
      super.copyWith((message) =>
              updates(message as Block_Content_Dataview_ObjectOrder))
          as Block_Content_Dataview_ObjectOrder;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_ObjectOrder create() =>
      Block_Content_Dataview_ObjectOrder._();
  @$core.override
  Block_Content_Dataview_ObjectOrder createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_ObjectOrder getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Dataview_ObjectOrder>(
          create);
  static Block_Content_Dataview_ObjectOrder? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get viewId => $_getSZ(0);
  @$pb.TagNumber(1)
  set viewId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasViewId() => $_has(0);
  @$pb.TagNumber(1)
  void clearViewId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get groupId => $_getSZ(1);
  @$pb.TagNumber(2)
  set groupId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroupId() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroupId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get objectIds => $_getList(2);
}

enum Block_Content_Dataview_Group_Value { status, tag, checkbox, date, notSet }

class Block_Content_Dataview_Group extends $pb.GeneratedMessage {
  factory Block_Content_Dataview_Group({
    $core.String? id,
    Block_Content_Dataview_Status? status,
    Block_Content_Dataview_Tag? tag,
    Block_Content_Dataview_Checkbox? checkbox,
    Block_Content_Dataview_Date? date,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (status != null) result.status = status;
    if (tag != null) result.tag = tag;
    if (checkbox != null) result.checkbox = checkbox;
    if (date != null) result.date = date;
    return result;
  }

  Block_Content_Dataview_Group._();

  factory Block_Content_Dataview_Group.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Dataview_Group.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Block_Content_Dataview_Group_Value>
      _Block_Content_Dataview_Group_ValueByTag = {
    2: Block_Content_Dataview_Group_Value.status,
    3: Block_Content_Dataview_Group_Value.tag,
    4: Block_Content_Dataview_Group_Value.checkbox,
    5: Block_Content_Dataview_Group_Value.date,
    0: Block_Content_Dataview_Group_Value.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Dataview.Group',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..oo(0, [2, 3, 4, 5])
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<Block_Content_Dataview_Status>(2, _omitFieldNames ? '' : 'status',
        subBuilder: Block_Content_Dataview_Status.create)
    ..aOM<Block_Content_Dataview_Tag>(3, _omitFieldNames ? '' : 'tag',
        subBuilder: Block_Content_Dataview_Tag.create)
    ..aOM<Block_Content_Dataview_Checkbox>(4, _omitFieldNames ? '' : 'checkbox',
        subBuilder: Block_Content_Dataview_Checkbox.create)
    ..aOM<Block_Content_Dataview_Date>(5, _omitFieldNames ? '' : 'date',
        subBuilder: Block_Content_Dataview_Date.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_Group clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_Group copyWith(
          void Function(Block_Content_Dataview_Group) updates) =>
      super.copyWith(
              (message) => updates(message as Block_Content_Dataview_Group))
          as Block_Content_Dataview_Group;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_Group create() =>
      Block_Content_Dataview_Group._();
  @$core.override
  Block_Content_Dataview_Group createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_Group getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Dataview_Group>(create);
  static Block_Content_Dataview_Group? _defaultInstance;

  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  Block_Content_Dataview_Group_Value whichValue() =>
      _Block_Content_Dataview_Group_ValueByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  void clearValue() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  Block_Content_Dataview_Status get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(Block_Content_Dataview_Status value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);
  @$pb.TagNumber(2)
  Block_Content_Dataview_Status ensureStatus() => $_ensure(1);

  @$pb.TagNumber(3)
  Block_Content_Dataview_Tag get tag => $_getN(2);
  @$pb.TagNumber(3)
  set tag(Block_Content_Dataview_Tag value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTag() => $_has(2);
  @$pb.TagNumber(3)
  void clearTag() => $_clearField(3);
  @$pb.TagNumber(3)
  Block_Content_Dataview_Tag ensureTag() => $_ensure(2);

  @$pb.TagNumber(4)
  Block_Content_Dataview_Checkbox get checkbox => $_getN(3);
  @$pb.TagNumber(4)
  set checkbox(Block_Content_Dataview_Checkbox value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCheckbox() => $_has(3);
  @$pb.TagNumber(4)
  void clearCheckbox() => $_clearField(4);
  @$pb.TagNumber(4)
  Block_Content_Dataview_Checkbox ensureCheckbox() => $_ensure(3);

  @$pb.TagNumber(5)
  Block_Content_Dataview_Date get date => $_getN(4);
  @$pb.TagNumber(5)
  set date(Block_Content_Dataview_Date value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearDate() => $_clearField(5);
  @$pb.TagNumber(5)
  Block_Content_Dataview_Date ensureDate() => $_ensure(4);
}

class Block_Content_Dataview_Status extends $pb.GeneratedMessage {
  factory Block_Content_Dataview_Status({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  Block_Content_Dataview_Status._();

  factory Block_Content_Dataview_Status.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Dataview_Status.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Dataview.Status',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_Status clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_Status copyWith(
          void Function(Block_Content_Dataview_Status) updates) =>
      super.copyWith(
              (message) => updates(message as Block_Content_Dataview_Status))
          as Block_Content_Dataview_Status;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_Status create() =>
      Block_Content_Dataview_Status._();
  @$core.override
  Block_Content_Dataview_Status createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_Status getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Dataview_Status>(create);
  static Block_Content_Dataview_Status? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class Block_Content_Dataview_Tag extends $pb.GeneratedMessage {
  factory Block_Content_Dataview_Tag({
    $core.Iterable<$core.String>? ids,
  }) {
    final result = create();
    if (ids != null) result.ids.addAll(ids);
    return result;
  }

  Block_Content_Dataview_Tag._();

  factory Block_Content_Dataview_Tag.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Dataview_Tag.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Dataview.Tag',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'ids')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_Tag clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_Tag copyWith(
          void Function(Block_Content_Dataview_Tag) updates) =>
      super.copyWith(
              (message) => updates(message as Block_Content_Dataview_Tag))
          as Block_Content_Dataview_Tag;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_Tag create() => Block_Content_Dataview_Tag._();
  @$core.override
  Block_Content_Dataview_Tag createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_Tag getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Dataview_Tag>(create);
  static Block_Content_Dataview_Tag? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get ids => $_getList(0);
}

class Block_Content_Dataview_Checkbox extends $pb.GeneratedMessage {
  factory Block_Content_Dataview_Checkbox({
    $core.bool? checked,
  }) {
    final result = create();
    if (checked != null) result.checked = checked;
    return result;
  }

  Block_Content_Dataview_Checkbox._();

  factory Block_Content_Dataview_Checkbox.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Dataview_Checkbox.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Dataview.Checkbox',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'checked')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_Checkbox clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_Checkbox copyWith(
          void Function(Block_Content_Dataview_Checkbox) updates) =>
      super.copyWith(
              (message) => updates(message as Block_Content_Dataview_Checkbox))
          as Block_Content_Dataview_Checkbox;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_Checkbox create() =>
      Block_Content_Dataview_Checkbox._();
  @$core.override
  Block_Content_Dataview_Checkbox createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_Checkbox getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Dataview_Checkbox>(
          create);
  static Block_Content_Dataview_Checkbox? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get checked => $_getBF(0);
  @$pb.TagNumber(1)
  set checked($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChecked() => $_has(0);
  @$pb.TagNumber(1)
  void clearChecked() => $_clearField(1);
}

class Block_Content_Dataview_Date extends $pb.GeneratedMessage {
  factory Block_Content_Dataview_Date() => create();

  Block_Content_Dataview_Date._();

  factory Block_Content_Dataview_Date.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Dataview_Date.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Dataview.Date',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_Date clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview_Date copyWith(
          void Function(Block_Content_Dataview_Date) updates) =>
      super.copyWith(
              (message) => updates(message as Block_Content_Dataview_Date))
          as Block_Content_Dataview_Date;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_Date create() =>
      Block_Content_Dataview_Date._();
  @$core.override
  Block_Content_Dataview_Date createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview_Date getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Dataview_Date>(create);
  static Block_Content_Dataview_Date? _defaultInstance;
}

class Block_Content_Dataview extends $pb.GeneratedMessage {
  factory Block_Content_Dataview({
    $core.Iterable<$core.String>? source,
    $core.Iterable<Block_Content_Dataview_View>? views,
    $core.String? activeView,
    $core.Iterable<Relation>? relations,
    $core.Iterable<RelationLink>? relationLinks,
    $core.String? targetObjectId,
    $core.Iterable<Block_Content_Dataview_GroupOrder>? groupOrders,
    $core.Iterable<Block_Content_Dataview_ObjectOrder>? objectOrders,
    $core.bool? isCollection,
  }) {
    final result = create();
    if (source != null) result.source.addAll(source);
    if (views != null) result.views.addAll(views);
    if (activeView != null) result.activeView = activeView;
    if (relations != null) result.relations.addAll(relations);
    if (relationLinks != null) result.relationLinks.addAll(relationLinks);
    if (targetObjectId != null) result.targetObjectId = targetObjectId;
    if (groupOrders != null) result.groupOrders.addAll(groupOrders);
    if (objectOrders != null) result.objectOrders.addAll(objectOrders);
    if (isCollection != null) result.isCollection = isCollection;
    return result;
  }

  Block_Content_Dataview._();

  factory Block_Content_Dataview.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Dataview.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Dataview',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'source')
    ..pPM<Block_Content_Dataview_View>(2, _omitFieldNames ? '' : 'views',
        subBuilder: Block_Content_Dataview_View.create)
    ..aOS(3, _omitFieldNames ? '' : 'activeView', protoName: 'activeView')
    ..pPM<Relation>(4, _omitFieldNames ? '' : 'relations',
        subBuilder: Relation.create)
    ..pPM<RelationLink>(5, _omitFieldNames ? '' : 'relationLinks',
        protoName: 'relationLinks', subBuilder: RelationLink.create)
    ..aOS(6, _omitFieldNames ? '' : 'TargetObjectId',
        protoName: 'TargetObjectId')
    ..pPM<Block_Content_Dataview_GroupOrder>(
        12, _omitFieldNames ? '' : 'groupOrders',
        protoName: 'groupOrders',
        subBuilder: Block_Content_Dataview_GroupOrder.create)
    ..pPM<Block_Content_Dataview_ObjectOrder>(
        13, _omitFieldNames ? '' : 'objectOrders',
        protoName: 'objectOrders',
        subBuilder: Block_Content_Dataview_ObjectOrder.create)
    ..aOB(14, _omitFieldNames ? '' : 'isCollection', protoName: 'isCollection')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Dataview copyWith(
          void Function(Block_Content_Dataview) updates) =>
      super.copyWith((message) => updates(message as Block_Content_Dataview))
          as Block_Content_Dataview;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview create() => Block_Content_Dataview._();
  @$core.override
  Block_Content_Dataview createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Dataview getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Dataview>(create);
  static Block_Content_Dataview? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get source => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<Block_Content_Dataview_View> get views => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get activeView => $_getSZ(2);
  @$pb.TagNumber(3)
  set activeView($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasActiveView() => $_has(2);
  @$pb.TagNumber(3)
  void clearActiveView() => $_clearField(3);

  /// deprecated
  @$pb.TagNumber(4)
  $pb.PbList<Relation> get relations => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<RelationLink> get relationLinks => $_getList(4);

  @$pb.TagNumber(6)
  $core.String get targetObjectId => $_getSZ(5);
  @$pb.TagNumber(6)
  set targetObjectId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTargetObjectId() => $_has(5);
  @$pb.TagNumber(6)
  void clearTargetObjectId() => $_clearField(6);

  @$pb.TagNumber(12)
  $pb.PbList<Block_Content_Dataview_GroupOrder> get groupOrders => $_getList(6);

  @$pb.TagNumber(13)
  $pb.PbList<Block_Content_Dataview_ObjectOrder> get objectOrders =>
      $_getList(7);

  @$pb.TagNumber(14)
  $core.bool get isCollection => $_getBF(8);
  @$pb.TagNumber(14)
  set isCollection($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(14)
  $core.bool hasIsCollection() => $_has(8);
  @$pb.TagNumber(14)
  void clearIsCollection() => $_clearField(14);
}

class Block_Content_Relation extends $pb.GeneratedMessage {
  factory Block_Content_Relation({
    $core.String? key,
  }) {
    final result = create();
    if (key != null) result.key = key;
    return result;
  }

  Block_Content_Relation._();

  factory Block_Content_Relation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Relation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Relation',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Relation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Relation copyWith(
          void Function(Block_Content_Relation) updates) =>
      super.copyWith((message) => updates(message as Block_Content_Relation))
          as Block_Content_Relation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Relation create() => Block_Content_Relation._();
  @$core.override
  Block_Content_Relation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Relation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Relation>(create);
  static Block_Content_Relation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);
}

class Block_Content_Latex extends $pb.GeneratedMessage {
  factory Block_Content_Latex({
    $core.String? text,
    Block_Content_Latex_Processor? processor,
  }) {
    final result = create();
    if (text != null) result.text = text;
    if (processor != null) result.processor = processor;
    return result;
  }

  Block_Content_Latex._();

  factory Block_Content_Latex.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Latex.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Latex',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..aE<Block_Content_Latex_Processor>(2, _omitFieldNames ? '' : 'processor',
        enumValues: Block_Content_Latex_Processor.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Latex clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Latex copyWith(void Function(Block_Content_Latex) updates) =>
      super.copyWith((message) => updates(message as Block_Content_Latex))
          as Block_Content_Latex;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Latex create() => Block_Content_Latex._();
  @$core.override
  Block_Content_Latex createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Latex getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Latex>(create);
  static Block_Content_Latex? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  @$pb.TagNumber(2)
  Block_Content_Latex_Processor get processor => $_getN(1);
  @$pb.TagNumber(2)
  set processor(Block_Content_Latex_Processor value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasProcessor() => $_has(1);
  @$pb.TagNumber(2)
  void clearProcessor() => $_clearField(2);
}

class Block_Content_TableOfContents extends $pb.GeneratedMessage {
  factory Block_Content_TableOfContents() => create();

  Block_Content_TableOfContents._();

  factory Block_Content_TableOfContents.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_TableOfContents.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.TableOfContents',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_TableOfContents clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_TableOfContents copyWith(
          void Function(Block_Content_TableOfContents) updates) =>
      super.copyWith(
              (message) => updates(message as Block_Content_TableOfContents))
          as Block_Content_TableOfContents;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_TableOfContents create() =>
      Block_Content_TableOfContents._();
  @$core.override
  Block_Content_TableOfContents createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_TableOfContents getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_TableOfContents>(create);
  static Block_Content_TableOfContents? _defaultInstance;
}

class Block_Content_Table extends $pb.GeneratedMessage {
  factory Block_Content_Table() => create();

  Block_Content_Table._();

  factory Block_Content_Table.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Table.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Table',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Table clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Table copyWith(void Function(Block_Content_Table) updates) =>
      super.copyWith((message) => updates(message as Block_Content_Table))
          as Block_Content_Table;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Table create() => Block_Content_Table._();
  @$core.override
  Block_Content_Table createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Table getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Table>(create);
  static Block_Content_Table? _defaultInstance;
}

class Block_Content_TableColumn extends $pb.GeneratedMessage {
  factory Block_Content_TableColumn() => create();

  Block_Content_TableColumn._();

  factory Block_Content_TableColumn.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_TableColumn.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.TableColumn',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_TableColumn clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_TableColumn copyWith(
          void Function(Block_Content_TableColumn) updates) =>
      super.copyWith((message) => updates(message as Block_Content_TableColumn))
          as Block_Content_TableColumn;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_TableColumn create() => Block_Content_TableColumn._();
  @$core.override
  Block_Content_TableColumn createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_TableColumn getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_TableColumn>(create);
  static Block_Content_TableColumn? _defaultInstance;
}

class Block_Content_TableRow extends $pb.GeneratedMessage {
  factory Block_Content_TableRow({
    $core.bool? isHeader,
  }) {
    final result = create();
    if (isHeader != null) result.isHeader = isHeader;
    return result;
  }

  Block_Content_TableRow._();

  factory Block_Content_TableRow.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_TableRow.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.TableRow',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isHeader', protoName: 'isHeader')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_TableRow clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_TableRow copyWith(
          void Function(Block_Content_TableRow) updates) =>
      super.copyWith((message) => updates(message as Block_Content_TableRow))
          as Block_Content_TableRow;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_TableRow create() => Block_Content_TableRow._();
  @$core.override
  Block_Content_TableRow createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_TableRow getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_TableRow>(create);
  static Block_Content_TableRow? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isHeader => $_getBF(0);
  @$pb.TagNumber(1)
  set isHeader($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIsHeader() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsHeader() => $_clearField(1);
}

class Block_Content_Widget extends $pb.GeneratedMessage {
  factory Block_Content_Widget({
    Block_Content_Widget_Layout? layout,
    $core.int? limit,
    $core.String? viewId,
    $core.bool? autoAdded,
  }) {
    final result = create();
    if (layout != null) result.layout = layout;
    if (limit != null) result.limit = limit;
    if (viewId != null) result.viewId = viewId;
    if (autoAdded != null) result.autoAdded = autoAdded;
    return result;
  }

  Block_Content_Widget._();

  factory Block_Content_Widget.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Widget.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Widget',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aE<Block_Content_Widget_Layout>(1, _omitFieldNames ? '' : 'layout',
        enumValues: Block_Content_Widget_Layout.values)
    ..aI(2, _omitFieldNames ? '' : 'limit')
    ..aOS(3, _omitFieldNames ? '' : 'viewId', protoName: 'viewId')
    ..aOB(4, _omitFieldNames ? '' : 'autoAdded', protoName: 'autoAdded')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Widget clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Widget copyWith(void Function(Block_Content_Widget) updates) =>
      super.copyWith((message) => updates(message as Block_Content_Widget))
          as Block_Content_Widget;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Widget create() => Block_Content_Widget._();
  @$core.override
  Block_Content_Widget createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Widget getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Widget>(create);
  static Block_Content_Widget? _defaultInstance;

  @$pb.TagNumber(1)
  Block_Content_Widget_Layout get layout => $_getN(0);
  @$pb.TagNumber(1)
  set layout(Block_Content_Widget_Layout value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasLayout() => $_has(0);
  @$pb.TagNumber(1)
  void clearLayout() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get viewId => $_getSZ(2);
  @$pb.TagNumber(3)
  set viewId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasViewId() => $_has(2);
  @$pb.TagNumber(3)
  void clearViewId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get autoAdded => $_getBF(3);
  @$pb.TagNumber(4)
  set autoAdded($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAutoAdded() => $_has(3);
  @$pb.TagNumber(4)
  void clearAutoAdded() => $_clearField(4);
}

class Block_Content_Chat extends $pb.GeneratedMessage {
  factory Block_Content_Chat() => create();

  Block_Content_Chat._();

  factory Block_Content_Chat.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content_Chat.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content.Chat',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Chat clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content_Chat copyWith(void Function(Block_Content_Chat) updates) =>
      super.copyWith((message) => updates(message as Block_Content_Chat))
          as Block_Content_Chat;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content_Chat create() => Block_Content_Chat._();
  @$core.override
  Block_Content_Chat createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content_Chat getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content_Chat>(create);
  static Block_Content_Chat? _defaultInstance;
}

class Block_Content extends $pb.GeneratedMessage {
  factory Block_Content() => create();

  Block_Content._();

  factory Block_Content.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block_Content.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block.Content',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block_Content copyWith(void Function(Block_Content) updates) =>
      super.copyWith((message) => updates(message as Block_Content))
          as Block_Content;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block_Content create() => Block_Content._();
  @$core.override
  Block_Content createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block_Content getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Block_Content>(create);
  static Block_Content? _defaultInstance;
}

enum Block_Content_ {
  smartblock,
  text,
  file,
  layout,
  div,
  bookmark,
  icon,
  link,
  dataview,
  relation,
  featuredRelations,
  latex,
  tableOfContents,
  table,
  tableColumn,
  tableRow,
  widget,
  chat,
  notSet
}

class Block extends $pb.GeneratedMessage {
  factory Block({
    $core.String? id,
    $0.Struct? fields,
    Block_Restrictions? restrictions,
    $core.Iterable<$core.String>? childrenIds,
    $core.String? backgroundColor,
    Block_Align? align,
    Block_VerticalAlign? verticalAlign,
    Block_Content_Smartblock? smartblock,
    Block_Content_Text? text,
    Block_Content_File? file,
    Block_Content_Layout? layout,
    Block_Content_Div? div,
    Block_Content_Bookmark? bookmark,
    Block_Content_Icon? icon,
    Block_Content_Link? link,
    Block_Content_Dataview? dataview,
    Block_Content_Relation? relation,
    Block_Content_FeaturedRelations? featuredRelations,
    Block_Content_Latex? latex,
    Block_Content_TableOfContents? tableOfContents,
    Block_Content_Table? table,
    Block_Content_TableColumn? tableColumn,
    Block_Content_TableRow? tableRow,
    Block_Content_Widget? widget,
    Block_Content_Chat? chat,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (fields != null) result.fields = fields;
    if (restrictions != null) result.restrictions = restrictions;
    if (childrenIds != null) result.childrenIds.addAll(childrenIds);
    if (backgroundColor != null) result.backgroundColor = backgroundColor;
    if (align != null) result.align = align;
    if (verticalAlign != null) result.verticalAlign = verticalAlign;
    if (smartblock != null) result.smartblock = smartblock;
    if (text != null) result.text = text;
    if (file != null) result.file = file;
    if (layout != null) result.layout = layout;
    if (div != null) result.div = div;
    if (bookmark != null) result.bookmark = bookmark;
    if (icon != null) result.icon = icon;
    if (link != null) result.link = link;
    if (dataview != null) result.dataview = dataview;
    if (relation != null) result.relation = relation;
    if (featuredRelations != null) result.featuredRelations = featuredRelations;
    if (latex != null) result.latex = latex;
    if (tableOfContents != null) result.tableOfContents = tableOfContents;
    if (table != null) result.table = table;
    if (tableColumn != null) result.tableColumn = tableColumn;
    if (tableRow != null) result.tableRow = tableRow;
    if (widget != null) result.widget = widget;
    if (chat != null) result.chat = chat;
    return result;
  }

  Block._();

  factory Block.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Block.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Block_Content_> _Block_Content_ByTag = {
    11: Block_Content_.smartblock,
    14: Block_Content_.text,
    15: Block_Content_.file,
    16: Block_Content_.layout,
    17: Block_Content_.div,
    18: Block_Content_.bookmark,
    19: Block_Content_.icon,
    20: Block_Content_.link,
    21: Block_Content_.dataview,
    22: Block_Content_.relation,
    23: Block_Content_.featuredRelations,
    24: Block_Content_.latex,
    25: Block_Content_.tableOfContents,
    26: Block_Content_.table,
    27: Block_Content_.tableColumn,
    28: Block_Content_.tableRow,
    29: Block_Content_.widget,
    30: Block_Content_.chat,
    0: Block_Content_.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Block',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..oo(0, [
      11,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
      21,
      22,
      23,
      24,
      25,
      26,
      27,
      28,
      29,
      30
    ])
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$0.Struct>(2, _omitFieldNames ? '' : 'fields',
        subBuilder: $0.Struct.create)
    ..aOM<Block_Restrictions>(3, _omitFieldNames ? '' : 'restrictions',
        subBuilder: Block_Restrictions.create)
    ..pPS(4, _omitFieldNames ? '' : 'childrenIds', protoName: 'childrenIds')
    ..aOS(5, _omitFieldNames ? '' : 'backgroundColor',
        protoName: 'backgroundColor')
    ..aE<Block_Align>(6, _omitFieldNames ? '' : 'align',
        enumValues: Block_Align.values)
    ..aE<Block_VerticalAlign>(7, _omitFieldNames ? '' : 'verticalAlign',
        protoName: 'verticalAlign', enumValues: Block_VerticalAlign.values)
    ..aOM<Block_Content_Smartblock>(11, _omitFieldNames ? '' : 'smartblock',
        subBuilder: Block_Content_Smartblock.create)
    ..aOM<Block_Content_Text>(14, _omitFieldNames ? '' : 'text',
        subBuilder: Block_Content_Text.create)
    ..aOM<Block_Content_File>(15, _omitFieldNames ? '' : 'file',
        subBuilder: Block_Content_File.create)
    ..aOM<Block_Content_Layout>(16, _omitFieldNames ? '' : 'layout',
        subBuilder: Block_Content_Layout.create)
    ..aOM<Block_Content_Div>(17, _omitFieldNames ? '' : 'div',
        subBuilder: Block_Content_Div.create)
    ..aOM<Block_Content_Bookmark>(18, _omitFieldNames ? '' : 'bookmark',
        subBuilder: Block_Content_Bookmark.create)
    ..aOM<Block_Content_Icon>(19, _omitFieldNames ? '' : 'icon',
        subBuilder: Block_Content_Icon.create)
    ..aOM<Block_Content_Link>(20, _omitFieldNames ? '' : 'link',
        subBuilder: Block_Content_Link.create)
    ..aOM<Block_Content_Dataview>(21, _omitFieldNames ? '' : 'dataview',
        subBuilder: Block_Content_Dataview.create)
    ..aOM<Block_Content_Relation>(22, _omitFieldNames ? '' : 'relation',
        subBuilder: Block_Content_Relation.create)
    ..aOM<Block_Content_FeaturedRelations>(
        23, _omitFieldNames ? '' : 'featuredRelations',
        protoName: 'featuredRelations',
        subBuilder: Block_Content_FeaturedRelations.create)
    ..aOM<Block_Content_Latex>(24, _omitFieldNames ? '' : 'latex',
        subBuilder: Block_Content_Latex.create)
    ..aOM<Block_Content_TableOfContents>(
        25, _omitFieldNames ? '' : 'tableOfContents',
        protoName: 'tableOfContents',
        subBuilder: Block_Content_TableOfContents.create)
    ..aOM<Block_Content_Table>(26, _omitFieldNames ? '' : 'table',
        subBuilder: Block_Content_Table.create)
    ..aOM<Block_Content_TableColumn>(27, _omitFieldNames ? '' : 'tableColumn',
        protoName: 'tableColumn', subBuilder: Block_Content_TableColumn.create)
    ..aOM<Block_Content_TableRow>(28, _omitFieldNames ? '' : 'tableRow',
        protoName: 'tableRow', subBuilder: Block_Content_TableRow.create)
    ..aOM<Block_Content_Widget>(29, _omitFieldNames ? '' : 'widget',
        subBuilder: Block_Content_Widget.create)
    ..aOM<Block_Content_Chat>(30, _omitFieldNames ? '' : 'chat',
        subBuilder: Block_Content_Chat.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block copyWith(void Function(Block) updates) =>
      super.copyWith((message) => updates(message as Block)) as Block;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block create() => Block._();
  @$core.override
  Block createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Block getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Block>(create);
  static Block? _defaultInstance;

  @$pb.TagNumber(11)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  @$pb.TagNumber(16)
  @$pb.TagNumber(17)
  @$pb.TagNumber(18)
  @$pb.TagNumber(19)
  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  @$pb.TagNumber(22)
  @$pb.TagNumber(23)
  @$pb.TagNumber(24)
  @$pb.TagNumber(25)
  @$pb.TagNumber(26)
  @$pb.TagNumber(27)
  @$pb.TagNumber(28)
  @$pb.TagNumber(29)
  @$pb.TagNumber(30)
  Block_Content_ whichContent() => _Block_Content_ByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(11)
  @$pb.TagNumber(14)
  @$pb.TagNumber(15)
  @$pb.TagNumber(16)
  @$pb.TagNumber(17)
  @$pb.TagNumber(18)
  @$pb.TagNumber(19)
  @$pb.TagNumber(20)
  @$pb.TagNumber(21)
  @$pb.TagNumber(22)
  @$pb.TagNumber(23)
  @$pb.TagNumber(24)
  @$pb.TagNumber(25)
  @$pb.TagNumber(26)
  @$pb.TagNumber(27)
  @$pb.TagNumber(28)
  @$pb.TagNumber(29)
  @$pb.TagNumber(30)
  void clearContent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Struct get fields => $_getN(1);
  @$pb.TagNumber(2)
  set fields($0.Struct value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasFields() => $_has(1);
  @$pb.TagNumber(2)
  void clearFields() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Struct ensureFields() => $_ensure(1);

  @$pb.TagNumber(3)
  Block_Restrictions get restrictions => $_getN(2);
  @$pb.TagNumber(3)
  set restrictions(Block_Restrictions value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasRestrictions() => $_has(2);
  @$pb.TagNumber(3)
  void clearRestrictions() => $_clearField(3);
  @$pb.TagNumber(3)
  Block_Restrictions ensureRestrictions() => $_ensure(2);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get childrenIds => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get backgroundColor => $_getSZ(4);
  @$pb.TagNumber(5)
  set backgroundColor($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBackgroundColor() => $_has(4);
  @$pb.TagNumber(5)
  void clearBackgroundColor() => $_clearField(5);

  @$pb.TagNumber(6)
  Block_Align get align => $_getN(5);
  @$pb.TagNumber(6)
  set align(Block_Align value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasAlign() => $_has(5);
  @$pb.TagNumber(6)
  void clearAlign() => $_clearField(6);

  @$pb.TagNumber(7)
  Block_VerticalAlign get verticalAlign => $_getN(6);
  @$pb.TagNumber(7)
  set verticalAlign(Block_VerticalAlign value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasVerticalAlign() => $_has(6);
  @$pb.TagNumber(7)
  void clearVerticalAlign() => $_clearField(7);

  @$pb.TagNumber(11)
  Block_Content_Smartblock get smartblock => $_getN(7);
  @$pb.TagNumber(11)
  set smartblock(Block_Content_Smartblock value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasSmartblock() => $_has(7);
  @$pb.TagNumber(11)
  void clearSmartblock() => $_clearField(11);
  @$pb.TagNumber(11)
  Block_Content_Smartblock ensureSmartblock() => $_ensure(7);

  @$pb.TagNumber(14)
  Block_Content_Text get text => $_getN(8);
  @$pb.TagNumber(14)
  set text(Block_Content_Text value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasText() => $_has(8);
  @$pb.TagNumber(14)
  void clearText() => $_clearField(14);
  @$pb.TagNumber(14)
  Block_Content_Text ensureText() => $_ensure(8);

  @$pb.TagNumber(15)
  Block_Content_File get file => $_getN(9);
  @$pb.TagNumber(15)
  set file(Block_Content_File value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasFile() => $_has(9);
  @$pb.TagNumber(15)
  void clearFile() => $_clearField(15);
  @$pb.TagNumber(15)
  Block_Content_File ensureFile() => $_ensure(9);

  @$pb.TagNumber(16)
  Block_Content_Layout get layout => $_getN(10);
  @$pb.TagNumber(16)
  set layout(Block_Content_Layout value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasLayout() => $_has(10);
  @$pb.TagNumber(16)
  void clearLayout() => $_clearField(16);
  @$pb.TagNumber(16)
  Block_Content_Layout ensureLayout() => $_ensure(10);

  @$pb.TagNumber(17)
  Block_Content_Div get div => $_getN(11);
  @$pb.TagNumber(17)
  set div(Block_Content_Div value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasDiv() => $_has(11);
  @$pb.TagNumber(17)
  void clearDiv() => $_clearField(17);
  @$pb.TagNumber(17)
  Block_Content_Div ensureDiv() => $_ensure(11);

  @$pb.TagNumber(18)
  Block_Content_Bookmark get bookmark => $_getN(12);
  @$pb.TagNumber(18)
  set bookmark(Block_Content_Bookmark value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasBookmark() => $_has(12);
  @$pb.TagNumber(18)
  void clearBookmark() => $_clearField(18);
  @$pb.TagNumber(18)
  Block_Content_Bookmark ensureBookmark() => $_ensure(12);

  @$pb.TagNumber(19)
  Block_Content_Icon get icon => $_getN(13);
  @$pb.TagNumber(19)
  set icon(Block_Content_Icon value) => $_setField(19, value);
  @$pb.TagNumber(19)
  $core.bool hasIcon() => $_has(13);
  @$pb.TagNumber(19)
  void clearIcon() => $_clearField(19);
  @$pb.TagNumber(19)
  Block_Content_Icon ensureIcon() => $_ensure(13);

  @$pb.TagNumber(20)
  Block_Content_Link get link => $_getN(14);
  @$pb.TagNumber(20)
  set link(Block_Content_Link value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasLink() => $_has(14);
  @$pb.TagNumber(20)
  void clearLink() => $_clearField(20);
  @$pb.TagNumber(20)
  Block_Content_Link ensureLink() => $_ensure(14);

  @$pb.TagNumber(21)
  Block_Content_Dataview get dataview => $_getN(15);
  @$pb.TagNumber(21)
  set dataview(Block_Content_Dataview value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasDataview() => $_has(15);
  @$pb.TagNumber(21)
  void clearDataview() => $_clearField(21);
  @$pb.TagNumber(21)
  Block_Content_Dataview ensureDataview() => $_ensure(15);

  @$pb.TagNumber(22)
  Block_Content_Relation get relation => $_getN(16);
  @$pb.TagNumber(22)
  set relation(Block_Content_Relation value) => $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasRelation() => $_has(16);
  @$pb.TagNumber(22)
  void clearRelation() => $_clearField(22);
  @$pb.TagNumber(22)
  Block_Content_Relation ensureRelation() => $_ensure(16);

  @$pb.TagNumber(23)
  Block_Content_FeaturedRelations get featuredRelations => $_getN(17);
  @$pb.TagNumber(23)
  set featuredRelations(Block_Content_FeaturedRelations value) =>
      $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasFeaturedRelations() => $_has(17);
  @$pb.TagNumber(23)
  void clearFeaturedRelations() => $_clearField(23);
  @$pb.TagNumber(23)
  Block_Content_FeaturedRelations ensureFeaturedRelations() => $_ensure(17);

  @$pb.TagNumber(24)
  Block_Content_Latex get latex => $_getN(18);
  @$pb.TagNumber(24)
  set latex(Block_Content_Latex value) => $_setField(24, value);
  @$pb.TagNumber(24)
  $core.bool hasLatex() => $_has(18);
  @$pb.TagNumber(24)
  void clearLatex() => $_clearField(24);
  @$pb.TagNumber(24)
  Block_Content_Latex ensureLatex() => $_ensure(18);

  @$pb.TagNumber(25)
  Block_Content_TableOfContents get tableOfContents => $_getN(19);
  @$pb.TagNumber(25)
  set tableOfContents(Block_Content_TableOfContents value) =>
      $_setField(25, value);
  @$pb.TagNumber(25)
  $core.bool hasTableOfContents() => $_has(19);
  @$pb.TagNumber(25)
  void clearTableOfContents() => $_clearField(25);
  @$pb.TagNumber(25)
  Block_Content_TableOfContents ensureTableOfContents() => $_ensure(19);

  @$pb.TagNumber(26)
  Block_Content_Table get table => $_getN(20);
  @$pb.TagNumber(26)
  set table(Block_Content_Table value) => $_setField(26, value);
  @$pb.TagNumber(26)
  $core.bool hasTable() => $_has(20);
  @$pb.TagNumber(26)
  void clearTable() => $_clearField(26);
  @$pb.TagNumber(26)
  Block_Content_Table ensureTable() => $_ensure(20);

  @$pb.TagNumber(27)
  Block_Content_TableColumn get tableColumn => $_getN(21);
  @$pb.TagNumber(27)
  set tableColumn(Block_Content_TableColumn value) => $_setField(27, value);
  @$pb.TagNumber(27)
  $core.bool hasTableColumn() => $_has(21);
  @$pb.TagNumber(27)
  void clearTableColumn() => $_clearField(27);
  @$pb.TagNumber(27)
  Block_Content_TableColumn ensureTableColumn() => $_ensure(21);

  @$pb.TagNumber(28)
  Block_Content_TableRow get tableRow => $_getN(22);
  @$pb.TagNumber(28)
  set tableRow(Block_Content_TableRow value) => $_setField(28, value);
  @$pb.TagNumber(28)
  $core.bool hasTableRow() => $_has(22);
  @$pb.TagNumber(28)
  void clearTableRow() => $_clearField(28);
  @$pb.TagNumber(28)
  Block_Content_TableRow ensureTableRow() => $_ensure(22);

  @$pb.TagNumber(29)
  Block_Content_Widget get widget => $_getN(23);
  @$pb.TagNumber(29)
  set widget(Block_Content_Widget value) => $_setField(29, value);
  @$pb.TagNumber(29)
  $core.bool hasWidget() => $_has(23);
  @$pb.TagNumber(29)
  void clearWidget() => $_clearField(29);
  @$pb.TagNumber(29)
  Block_Content_Widget ensureWidget() => $_ensure(23);

  @$pb.TagNumber(30)
  Block_Content_Chat get chat => $_getN(24);
  @$pb.TagNumber(30)
  set chat(Block_Content_Chat value) => $_setField(30, value);
  @$pb.TagNumber(30)
  $core.bool hasChat() => $_has(24);
  @$pb.TagNumber(30)
  void clearChat() => $_clearField(30);
  @$pb.TagNumber(30)
  Block_Content_Chat ensureChat() => $_ensure(24);
}

///
///  Used to decode block meta only, without the content itself
class BlockMetaOnly extends $pb.GeneratedMessage {
  factory BlockMetaOnly({
    $core.String? id,
    $0.Struct? fields,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (fields != null) result.fields = fields;
    return result;
  }

  BlockMetaOnly._();

  factory BlockMetaOnly.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BlockMetaOnly.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BlockMetaOnly',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$0.Struct>(2, _omitFieldNames ? '' : 'fields',
        subBuilder: $0.Struct.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockMetaOnly clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockMetaOnly copyWith(void Function(BlockMetaOnly) updates) =>
      super.copyWith((message) => updates(message as BlockMetaOnly))
          as BlockMetaOnly;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockMetaOnly create() => BlockMetaOnly._();
  @$core.override
  BlockMetaOnly createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BlockMetaOnly getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BlockMetaOnly>(create);
  static BlockMetaOnly? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Struct get fields => $_getN(1);
  @$pb.TagNumber(2)
  set fields($0.Struct value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasFields() => $_has(1);
  @$pb.TagNumber(2)
  void clearFields() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Struct ensureFields() => $_ensure(1);
}

///
///  General purpose structure, uses in Mark.
class Range extends $pb.GeneratedMessage {
  factory Range({
    $core.int? from,
    $core.int? to,
  }) {
    final result = create();
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    return result;
  }

  Range._();

  factory Range.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Range.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Range',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'from')
    ..aI(2, _omitFieldNames ? '' : 'to')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Range clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Range copyWith(void Function(Range) updates) =>
      super.copyWith((message) => updates(message as Range)) as Range;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Range create() => Range._();
  @$core.override
  Range createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Range getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Range>(create);
  static Range? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get from => $_getIZ(0);
  @$pb.TagNumber(1)
  set from($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFrom() => $_has(0);
  @$pb.TagNumber(1)
  void clearFrom() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get to => $_getIZ(1);
  @$pb.TagNumber(2)
  set to($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTo() => $_has(1);
  @$pb.TagNumber(2)
  void clearTo() => $_clearField(2);
}

class Account_Config extends $pb.GeneratedMessage {
  factory Account_Config({
    $core.bool? enableDataview,
    $core.bool? enableDebug,
    $core.bool? enablePrereleaseChannel,
    $core.bool? enableSpaces,
    $0.Struct? extra,
  }) {
    final result = create();
    if (enableDataview != null) result.enableDataview = enableDataview;
    if (enableDebug != null) result.enableDebug = enableDebug;
    if (enablePrereleaseChannel != null)
      result.enablePrereleaseChannel = enablePrereleaseChannel;
    if (enableSpaces != null) result.enableSpaces = enableSpaces;
    if (extra != null) result.extra = extra;
    return result;
  }

  Account_Config._();

  factory Account_Config.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Account_Config.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Account.Config',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'enableDataview',
        protoName: 'enableDataview')
    ..aOB(2, _omitFieldNames ? '' : 'enableDebug', protoName: 'enableDebug')
    ..aOB(3, _omitFieldNames ? '' : 'enablePrereleaseChannel',
        protoName: 'enablePrereleaseChannel')
    ..aOB(4, _omitFieldNames ? '' : 'enableSpaces', protoName: 'enableSpaces')
    ..aOM<$0.Struct>(100, _omitFieldNames ? '' : 'extra',
        subBuilder: $0.Struct.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Account_Config clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Account_Config copyWith(void Function(Account_Config) updates) =>
      super.copyWith((message) => updates(message as Account_Config))
          as Account_Config;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Account_Config create() => Account_Config._();
  @$core.override
  Account_Config createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Account_Config getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Account_Config>(create);
  static Account_Config? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enableDataview => $_getBF(0);
  @$pb.TagNumber(1)
  set enableDataview($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEnableDataview() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnableDataview() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get enableDebug => $_getBF(1);
  @$pb.TagNumber(2)
  set enableDebug($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEnableDebug() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnableDebug() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get enablePrereleaseChannel => $_getBF(2);
  @$pb.TagNumber(3)
  set enablePrereleaseChannel($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEnablePrereleaseChannel() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnablePrereleaseChannel() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get enableSpaces => $_getBF(3);
  @$pb.TagNumber(4)
  set enableSpaces($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEnableSpaces() => $_has(3);
  @$pb.TagNumber(4)
  void clearEnableSpaces() => $_clearField(4);

  @$pb.TagNumber(100)
  $0.Struct get extra => $_getN(4);
  @$pb.TagNumber(100)
  set extra($0.Struct value) => $_setField(100, value);
  @$pb.TagNumber(100)
  $core.bool hasExtra() => $_has(4);
  @$pb.TagNumber(100)
  void clearExtra() => $_clearField(100);
  @$pb.TagNumber(100)
  $0.Struct ensureExtra() => $_ensure(4);
}

class Account_Status extends $pb.GeneratedMessage {
  factory Account_Status({
    Account_StatusType? statusType,
    $fixnum.Int64? deletionDate,
  }) {
    final result = create();
    if (statusType != null) result.statusType = statusType;
    if (deletionDate != null) result.deletionDate = deletionDate;
    return result;
  }

  Account_Status._();

  factory Account_Status.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Account_Status.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Account.Status',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aE<Account_StatusType>(1, _omitFieldNames ? '' : 'statusType',
        protoName: 'statusType', enumValues: Account_StatusType.values)
    ..aInt64(2, _omitFieldNames ? '' : 'deletionDate',
        protoName: 'deletionDate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Account_Status clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Account_Status copyWith(void Function(Account_Status) updates) =>
      super.copyWith((message) => updates(message as Account_Status))
          as Account_Status;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Account_Status create() => Account_Status._();
  @$core.override
  Account_Status createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Account_Status getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Account_Status>(create);
  static Account_Status? _defaultInstance;

  @$pb.TagNumber(1)
  Account_StatusType get statusType => $_getN(0);
  @$pb.TagNumber(1)
  set statusType(Account_StatusType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatusType() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatusType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get deletionDate => $_getI64(1);
  @$pb.TagNumber(2)
  set deletionDate($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeletionDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeletionDate() => $_clearField(2);
}

class Account_Info extends $pb.GeneratedMessage {
  factory Account_Info({
    $core.String? homeObjectId,
    $core.String? archiveObjectId,
    $core.String? profileObjectId,
    $core.String? deviceId,
    $core.String? accountSpaceId,
    $core.String? widgetsId,
    $core.String? marketplaceWorkspaceId,
    $core.String? spaceViewId,
    $core.String? techSpaceId,
    $core.String? workspaceObjectId,
    $core.String? spaceChatId,
    $core.String? gatewayUrl,
    $core.String? localStoragePath,
    $core.String? timeZone,
    $core.String? analyticsId,
    $core.String? networkId,
    $core.String? ethereumAddress,
    $core.String? metaDataKey,
  }) {
    final result = create();
    if (homeObjectId != null) result.homeObjectId = homeObjectId;
    if (archiveObjectId != null) result.archiveObjectId = archiveObjectId;
    if (profileObjectId != null) result.profileObjectId = profileObjectId;
    if (deviceId != null) result.deviceId = deviceId;
    if (accountSpaceId != null) result.accountSpaceId = accountSpaceId;
    if (widgetsId != null) result.widgetsId = widgetsId;
    if (marketplaceWorkspaceId != null)
      result.marketplaceWorkspaceId = marketplaceWorkspaceId;
    if (spaceViewId != null) result.spaceViewId = spaceViewId;
    if (techSpaceId != null) result.techSpaceId = techSpaceId;
    if (workspaceObjectId != null) result.workspaceObjectId = workspaceObjectId;
    if (spaceChatId != null) result.spaceChatId = spaceChatId;
    if (gatewayUrl != null) result.gatewayUrl = gatewayUrl;
    if (localStoragePath != null) result.localStoragePath = localStoragePath;
    if (timeZone != null) result.timeZone = timeZone;
    if (analyticsId != null) result.analyticsId = analyticsId;
    if (networkId != null) result.networkId = networkId;
    if (ethereumAddress != null) result.ethereumAddress = ethereumAddress;
    if (metaDataKey != null) result.metaDataKey = metaDataKey;
    return result;
  }

  Account_Info._();

  factory Account_Info.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Account_Info.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Account.Info',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(2, _omitFieldNames ? '' : 'homeObjectId', protoName: 'homeObjectId')
    ..aOS(3, _omitFieldNames ? '' : 'archiveObjectId',
        protoName: 'archiveObjectId')
    ..aOS(4, _omitFieldNames ? '' : 'profileObjectId',
        protoName: 'profileObjectId')
    ..aOS(8, _omitFieldNames ? '' : 'deviceId', protoName: 'deviceId')
    ..aOS(9, _omitFieldNames ? '' : 'accountSpaceId',
        protoName: 'accountSpaceId')
    ..aOS(10, _omitFieldNames ? '' : 'widgetsId', protoName: 'widgetsId')
    ..aOS(11, _omitFieldNames ? '' : 'marketplaceWorkspaceId',
        protoName: 'marketplaceWorkspaceId')
    ..aOS(13, _omitFieldNames ? '' : 'spaceViewId', protoName: 'spaceViewId')
    ..aOS(14, _omitFieldNames ? '' : 'techSpaceId', protoName: 'techSpaceId')
    ..aOS(15, _omitFieldNames ? '' : 'workspaceObjectId',
        protoName: 'workspaceObjectId')
    ..aOS(16, _omitFieldNames ? '' : 'spaceChatId', protoName: 'spaceChatId')
    ..aOS(101, _omitFieldNames ? '' : 'gatewayUrl', protoName: 'gatewayUrl')
    ..aOS(103, _omitFieldNames ? '' : 'localStoragePath',
        protoName: 'localStoragePath')
    ..aOS(104, _omitFieldNames ? '' : 'timeZone', protoName: 'timeZone')
    ..aOS(105, _omitFieldNames ? '' : 'analyticsId', protoName: 'analyticsId')
    ..aOS(106, _omitFieldNames ? '' : 'networkId', protoName: 'networkId')
    ..aOS(107, _omitFieldNames ? '' : 'ethereumAddress',
        protoName: 'ethereumAddress')
    ..aOS(108, _omitFieldNames ? '' : 'metaDataKey', protoName: 'metaDataKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Account_Info clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Account_Info copyWith(void Function(Account_Info) updates) =>
      super.copyWith((message) => updates(message as Account_Info))
          as Account_Info;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Account_Info create() => Account_Info._();
  @$core.override
  Account_Info createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Account_Info getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Account_Info>(create);
  static Account_Info? _defaultInstance;

  @$pb.TagNumber(2)
  $core.String get homeObjectId => $_getSZ(0);
  @$pb.TagNumber(2)
  set homeObjectId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(2)
  $core.bool hasHomeObjectId() => $_has(0);
  @$pb.TagNumber(2)
  void clearHomeObjectId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get archiveObjectId => $_getSZ(1);
  @$pb.TagNumber(3)
  set archiveObjectId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(3)
  $core.bool hasArchiveObjectId() => $_has(1);
  @$pb.TagNumber(3)
  void clearArchiveObjectId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get profileObjectId => $_getSZ(2);
  @$pb.TagNumber(4)
  set profileObjectId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(4)
  $core.bool hasProfileObjectId() => $_has(2);
  @$pb.TagNumber(4)
  void clearProfileObjectId() => $_clearField(4);

  @$pb.TagNumber(8)
  $core.String get deviceId => $_getSZ(3);
  @$pb.TagNumber(8)
  set deviceId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(8)
  $core.bool hasDeviceId() => $_has(3);
  @$pb.TagNumber(8)
  void clearDeviceId() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get accountSpaceId => $_getSZ(4);
  @$pb.TagNumber(9)
  set accountSpaceId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(9)
  $core.bool hasAccountSpaceId() => $_has(4);
  @$pb.TagNumber(9)
  void clearAccountSpaceId() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get widgetsId => $_getSZ(5);
  @$pb.TagNumber(10)
  set widgetsId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(10)
  $core.bool hasWidgetsId() => $_has(5);
  @$pb.TagNumber(10)
  void clearWidgetsId() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get marketplaceWorkspaceId => $_getSZ(6);
  @$pb.TagNumber(11)
  set marketplaceWorkspaceId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(11)
  $core.bool hasMarketplaceWorkspaceId() => $_has(6);
  @$pb.TagNumber(11)
  void clearMarketplaceWorkspaceId() => $_clearField(11);

  @$pb.TagNumber(13)
  $core.String get spaceViewId => $_getSZ(7);
  @$pb.TagNumber(13)
  set spaceViewId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(13)
  $core.bool hasSpaceViewId() => $_has(7);
  @$pb.TagNumber(13)
  void clearSpaceViewId() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get techSpaceId => $_getSZ(8);
  @$pb.TagNumber(14)
  set techSpaceId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(14)
  $core.bool hasTechSpaceId() => $_has(8);
  @$pb.TagNumber(14)
  void clearTechSpaceId() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get workspaceObjectId => $_getSZ(9);
  @$pb.TagNumber(15)
  set workspaceObjectId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(15)
  $core.bool hasWorkspaceObjectId() => $_has(9);
  @$pb.TagNumber(15)
  void clearWorkspaceObjectId() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get spaceChatId => $_getSZ(10);
  @$pb.TagNumber(16)
  set spaceChatId($core.String value) => $_setString(10, value);
  @$pb.TagNumber(16)
  $core.bool hasSpaceChatId() => $_has(10);
  @$pb.TagNumber(16)
  void clearSpaceChatId() => $_clearField(16);

  @$pb.TagNumber(101)
  $core.String get gatewayUrl => $_getSZ(11);
  @$pb.TagNumber(101)
  set gatewayUrl($core.String value) => $_setString(11, value);
  @$pb.TagNumber(101)
  $core.bool hasGatewayUrl() => $_has(11);
  @$pb.TagNumber(101)
  void clearGatewayUrl() => $_clearField(101);

  @$pb.TagNumber(103)
  $core.String get localStoragePath => $_getSZ(12);
  @$pb.TagNumber(103)
  set localStoragePath($core.String value) => $_setString(12, value);
  @$pb.TagNumber(103)
  $core.bool hasLocalStoragePath() => $_has(12);
  @$pb.TagNumber(103)
  void clearLocalStoragePath() => $_clearField(103);

  @$pb.TagNumber(104)
  $core.String get timeZone => $_getSZ(13);
  @$pb.TagNumber(104)
  set timeZone($core.String value) => $_setString(13, value);
  @$pb.TagNumber(104)
  $core.bool hasTimeZone() => $_has(13);
  @$pb.TagNumber(104)
  void clearTimeZone() => $_clearField(104);

  @$pb.TagNumber(105)
  $core.String get analyticsId => $_getSZ(14);
  @$pb.TagNumber(105)
  set analyticsId($core.String value) => $_setString(14, value);
  @$pb.TagNumber(105)
  $core.bool hasAnalyticsId() => $_has(14);
  @$pb.TagNumber(105)
  void clearAnalyticsId() => $_clearField(105);

  @$pb.TagNumber(106)
  $core.String get networkId => $_getSZ(15);
  @$pb.TagNumber(106)
  set networkId($core.String value) => $_setString(15, value);
  @$pb.TagNumber(106)
  $core.bool hasNetworkId() => $_has(15);
  @$pb.TagNumber(106)
  void clearNetworkId() => $_clearField(106);

  @$pb.TagNumber(107)
  $core.String get ethereumAddress => $_getSZ(16);
  @$pb.TagNumber(107)
  set ethereumAddress($core.String value) => $_setString(16, value);
  @$pb.TagNumber(107)
  $core.bool hasEthereumAddress() => $_has(16);
  @$pb.TagNumber(107)
  void clearEthereumAddress() => $_clearField(107);

  @$pb.TagNumber(108)
  $core.String get metaDataKey => $_getSZ(17);
  @$pb.TagNumber(108)
  set metaDataKey($core.String value) => $_setString(17, value);
  @$pb.TagNumber(108)
  $core.bool hasMetaDataKey() => $_has(17);
  @$pb.TagNumber(108)
  void clearMetaDataKey() => $_clearField(108);
}

class Account_Auth_AppInfo extends $pb.GeneratedMessage {
  factory Account_Auth_AppInfo({
    $core.String? appHash,
    $core.String? appName,
    $core.String? appKey,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? expireAt,
    Account_Auth_LocalApiScope? scope,
    $core.bool? isActive,
  }) {
    final result = create();
    if (appHash != null) result.appHash = appHash;
    if (appName != null) result.appName = appName;
    if (appKey != null) result.appKey = appKey;
    if (createdAt != null) result.createdAt = createdAt;
    if (expireAt != null) result.expireAt = expireAt;
    if (scope != null) result.scope = scope;
    if (isActive != null) result.isActive = isActive;
    return result;
  }

  Account_Auth_AppInfo._();

  factory Account_Auth_AppInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Account_Auth_AppInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Account.Auth.AppInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'appHash', protoName: 'appHash')
    ..aOS(2, _omitFieldNames ? '' : 'appName', protoName: 'appName')
    ..aOS(4, _omitFieldNames ? '' : 'appKey', protoName: 'appKey')
    ..aInt64(5, _omitFieldNames ? '' : 'createdAt', protoName: 'createdAt')
    ..aInt64(6, _omitFieldNames ? '' : 'expireAt', protoName: 'expireAt')
    ..aE<Account_Auth_LocalApiScope>(7, _omitFieldNames ? '' : 'scope',
        enumValues: Account_Auth_LocalApiScope.values)
    ..aOB(8, _omitFieldNames ? '' : 'isActive', protoName: 'isActive')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Account_Auth_AppInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Account_Auth_AppInfo copyWith(void Function(Account_Auth_AppInfo) updates) =>
      super.copyWith((message) => updates(message as Account_Auth_AppInfo))
          as Account_Auth_AppInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Account_Auth_AppInfo create() => Account_Auth_AppInfo._();
  @$core.override
  Account_Auth_AppInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Account_Auth_AppInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Account_Auth_AppInfo>(create);
  static Account_Auth_AppInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get appHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set appHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAppHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearAppHash() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get appName => $_getSZ(1);
  @$pb.TagNumber(2)
  set appName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAppName() => $_has(1);
  @$pb.TagNumber(2)
  void clearAppName() => $_clearField(2);

  @$pb.TagNumber(4)
  $core.String get appKey => $_getSZ(2);
  @$pb.TagNumber(4)
  set appKey($core.String value) => $_setString(2, value);
  @$pb.TagNumber(4)
  $core.bool hasAppKey() => $_has(2);
  @$pb.TagNumber(4)
  void clearAppKey() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get createdAt => $_getI64(3);
  @$pb.TagNumber(5)
  set createdAt($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(5)
  void clearCreatedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get expireAt => $_getI64(4);
  @$pb.TagNumber(6)
  set expireAt($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(6)
  $core.bool hasExpireAt() => $_has(4);
  @$pb.TagNumber(6)
  void clearExpireAt() => $_clearField(6);

  @$pb.TagNumber(7)
  Account_Auth_LocalApiScope get scope => $_getN(5);
  @$pb.TagNumber(7)
  set scope(Account_Auth_LocalApiScope value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasScope() => $_has(5);
  @$pb.TagNumber(7)
  void clearScope() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get isActive => $_getBF(6);
  @$pb.TagNumber(8)
  set isActive($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(8)
  $core.bool hasIsActive() => $_has(6);
  @$pb.TagNumber(8)
  void clearIsActive() => $_clearField(8);
}

class Account_Auth extends $pb.GeneratedMessage {
  factory Account_Auth() => create();

  Account_Auth._();

  factory Account_Auth.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Account_Auth.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Account.Auth',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Account_Auth clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Account_Auth copyWith(void Function(Account_Auth) updates) =>
      super.copyWith((message) => updates(message as Account_Auth))
          as Account_Auth;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Account_Auth create() => Account_Auth._();
  @$core.override
  Account_Auth createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Account_Auth getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Account_Auth>(create);
  static Account_Auth? _defaultInstance;
}

/// *
///  Contains basic information about a user account
class Account extends $pb.GeneratedMessage {
  factory Account({
    $core.String? id,
    Account_Config? config,
    Account_Status? status,
    Account_Info? info,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (config != null) result.config = config;
    if (status != null) result.status = status;
    if (info != null) result.info = info;
    return result;
  }

  Account._();

  factory Account.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Account.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Account',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<Account_Config>(4, _omitFieldNames ? '' : 'config',
        subBuilder: Account_Config.create)
    ..aOM<Account_Status>(5, _omitFieldNames ? '' : 'status',
        subBuilder: Account_Status.create)
    ..aOM<Account_Info>(6, _omitFieldNames ? '' : 'info',
        subBuilder: Account_Info.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Account clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Account copyWith(void Function(Account) updates) =>
      super.copyWith((message) => updates(message as Account)) as Account;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Account create() => Account._();
  @$core.override
  Account createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Account getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Account>(create);
  static Account? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(4)
  Account_Config get config => $_getN(1);
  @$pb.TagNumber(4)
  set config(Account_Config value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasConfig() => $_has(1);
  @$pb.TagNumber(4)
  void clearConfig() => $_clearField(4);
  @$pb.TagNumber(4)
  Account_Config ensureConfig() => $_ensure(1);

  @$pb.TagNumber(5)
  Account_Status get status => $_getN(2);
  @$pb.TagNumber(5)
  set status(Account_Status value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);
  @$pb.TagNumber(5)
  Account_Status ensureStatus() => $_ensure(2);

  @$pb.TagNumber(6)
  Account_Info get info => $_getN(3);
  @$pb.TagNumber(6)
  set info(Account_Info value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasInfo() => $_has(3);
  @$pb.TagNumber(6)
  void clearInfo() => $_clearField(6);
  @$pb.TagNumber(6)
  Account_Info ensureInfo() => $_ensure(3);
}

class LinkPreview extends $pb.GeneratedMessage {
  factory LinkPreview({
    $core.String? url,
    $core.String? title,
    $core.String? description,
    $core.String? imageUrl,
    $core.String? faviconUrl,
    LinkPreview_Type? type,
  }) {
    final result = create();
    if (url != null) result.url = url;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (imageUrl != null) result.imageUrl = imageUrl;
    if (faviconUrl != null) result.faviconUrl = faviconUrl;
    if (type != null) result.type = type;
    return result;
  }

  LinkPreview._();

  factory LinkPreview.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LinkPreview.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LinkPreview',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOS(4, _omitFieldNames ? '' : 'imageUrl', protoName: 'imageUrl')
    ..aOS(5, _omitFieldNames ? '' : 'faviconUrl', protoName: 'faviconUrl')
    ..aE<LinkPreview_Type>(6, _omitFieldNames ? '' : 'type',
        enumValues: LinkPreview_Type.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkPreview clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkPreview copyWith(void Function(LinkPreview) updates) =>
      super.copyWith((message) => updates(message as LinkPreview))
          as LinkPreview;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LinkPreview create() => LinkPreview._();
  @$core.override
  LinkPreview createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LinkPreview getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LinkPreview>(create);
  static LinkPreview? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get imageUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set imageUrl($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasImageUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearImageUrl() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get faviconUrl => $_getSZ(4);
  @$pb.TagNumber(5)
  set faviconUrl($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFaviconUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearFaviconUrl() => $_clearField(5);

  @$pb.TagNumber(6)
  LinkPreview_Type get type => $_getN(5);
  @$pb.TagNumber(6)
  set type(LinkPreview_Type value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasType() => $_has(5);
  @$pb.TagNumber(6)
  void clearType() => $_clearField(6);
}

class Restrictions_DataviewRestrictions extends $pb.GeneratedMessage {
  factory Restrictions_DataviewRestrictions({
    $core.String? blockId,
    $core.Iterable<Restrictions_DataviewRestriction>? restrictions,
  }) {
    final result = create();
    if (blockId != null) result.blockId = blockId;
    if (restrictions != null) result.restrictions.addAll(restrictions);
    return result;
  }

  Restrictions_DataviewRestrictions._();

  factory Restrictions_DataviewRestrictions.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Restrictions_DataviewRestrictions.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Restrictions.DataviewRestrictions',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'blockId', protoName: 'blockId')
    ..pc<Restrictions_DataviewRestriction>(
        2, _omitFieldNames ? '' : 'restrictions', $pb.PbFieldType.KE,
        valueOf: Restrictions_DataviewRestriction.valueOf,
        enumValues: Restrictions_DataviewRestriction.values,
        defaultEnumValue: Restrictions_DataviewRestriction.DVNone)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Restrictions_DataviewRestrictions clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Restrictions_DataviewRestrictions copyWith(
          void Function(Restrictions_DataviewRestrictions) updates) =>
      super.copyWith((message) =>
              updates(message as Restrictions_DataviewRestrictions))
          as Restrictions_DataviewRestrictions;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Restrictions_DataviewRestrictions create() =>
      Restrictions_DataviewRestrictions._();
  @$core.override
  Restrictions_DataviewRestrictions createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Restrictions_DataviewRestrictions getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Restrictions_DataviewRestrictions>(
          create);
  static Restrictions_DataviewRestrictions? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get blockId => $_getSZ(0);
  @$pb.TagNumber(1)
  set blockId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockId() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<Restrictions_DataviewRestriction> get restrictions => $_getList(1);
}

class Restrictions extends $pb.GeneratedMessage {
  factory Restrictions({
    $core.Iterable<Restrictions_ObjectRestriction>? object,
    $core.Iterable<Restrictions_DataviewRestrictions>? dataview,
  }) {
    final result = create();
    if (object != null) result.object.addAll(object);
    if (dataview != null) result.dataview.addAll(dataview);
    return result;
  }

  Restrictions._();

  factory Restrictions.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Restrictions.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Restrictions',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pc<Restrictions_ObjectRestriction>(
        1, _omitFieldNames ? '' : 'object', $pb.PbFieldType.KE,
        valueOf: Restrictions_ObjectRestriction.valueOf,
        enumValues: Restrictions_ObjectRestriction.values,
        defaultEnumValue: Restrictions_ObjectRestriction.None)
    ..pPM<Restrictions_DataviewRestrictions>(
        2, _omitFieldNames ? '' : 'dataview',
        subBuilder: Restrictions_DataviewRestrictions.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Restrictions clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Restrictions copyWith(void Function(Restrictions) updates) =>
      super.copyWith((message) => updates(message as Restrictions))
          as Restrictions;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Restrictions create() => Restrictions._();
  @$core.override
  Restrictions createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Restrictions getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Restrictions>(create);
  static Restrictions? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Restrictions_ObjectRestriction> get object => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<Restrictions_DataviewRestrictions> get dataview => $_getList(1);
}

class Object_ChangePayload extends $pb.GeneratedMessage {
  factory Object_ChangePayload({
    SmartBlockType? smartBlockType,
    $core.String? key,
    $core.List<$core.int>? data,
  }) {
    final result = create();
    if (smartBlockType != null) result.smartBlockType = smartBlockType;
    if (key != null) result.key = key;
    if (data != null) result.data = data;
    return result;
  }

  Object_ChangePayload._();

  factory Object_ChangePayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Object_ChangePayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Object.ChangePayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aE<SmartBlockType>(1, _omitFieldNames ? '' : 'smartBlockType',
        protoName: 'smartBlockType', enumValues: SmartBlockType.values)
    ..aOS(2, _omitFieldNames ? '' : 'key')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Object_ChangePayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Object_ChangePayload copyWith(void Function(Object_ChangePayload) updates) =>
      super.copyWith((message) => updates(message as Object_ChangePayload))
          as Object_ChangePayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Object_ChangePayload create() => Object_ChangePayload._();
  @$core.override
  Object_ChangePayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Object_ChangePayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Object_ChangePayload>(create);
  static Object_ChangePayload? _defaultInstance;

  @$pb.TagNumber(1)
  SmartBlockType get smartBlockType => $_getN(0);
  @$pb.TagNumber(1)
  set smartBlockType(SmartBlockType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSmartBlockType() => $_has(0);
  @$pb.TagNumber(1)
  void clearSmartBlockType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get key => $_getSZ(1);
  @$pb.TagNumber(2)
  set key($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearKey() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get data => $_getN(2);
  @$pb.TagNumber(3)
  set data($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => $_clearField(3);
}

class Object extends $pb.GeneratedMessage {
  factory Object() => create();

  Object._();

  factory Object.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Object.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Object',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Object clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Object copyWith(void Function(Object) updates) =>
      super.copyWith((message) => updates(message as Object)) as Object;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Object create() => Object._();
  @$core.override
  Object createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Object getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Object>(create);
  static Object? _defaultInstance;
}

class SpaceObjectHeader extends $pb.GeneratedMessage {
  factory SpaceObjectHeader({
    $core.String? spaceID,
  }) {
    final result = create();
    if (spaceID != null) result.spaceID = spaceID;
    return result;
  }

  SpaceObjectHeader._();

  factory SpaceObjectHeader.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SpaceObjectHeader.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SpaceObjectHeader',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceID', protoName: 'spaceID')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceObjectHeader clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpaceObjectHeader copyWith(void Function(SpaceObjectHeader) updates) =>
      super.copyWith((message) => updates(message as SpaceObjectHeader))
          as SpaceObjectHeader;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpaceObjectHeader create() => SpaceObjectHeader._();
  @$core.override
  SpaceObjectHeader createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SpaceObjectHeader getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SpaceObjectHeader>(create);
  static SpaceObjectHeader? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceID => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceID($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceID() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceID() => $_clearField(1);
}

class ObjectType extends $pb.GeneratedMessage {
  factory ObjectType({
    $core.String? url,
    $core.String? name,
    $core.Iterable<RelationLink>? relationLinks,
    ObjectType_Layout? layout,
    $core.String? iconEmoji,
    $core.String? description,
    $core.bool? hidden,
    $core.Iterable<SmartBlockType>? types,
    $core.bool? isArchived,
    $core.bool? readonly,
    $core.bool? installedByDefault,
    $core.String? key,
    $fixnum.Int64? revision,
    $core.bool? restrictObjectCreation,
    $fixnum.Int64? iconColor,
    $core.String? iconName,
    $core.String? pluralName,
  }) {
    final result = create();
    if (url != null) result.url = url;
    if (name != null) result.name = name;
    if (relationLinks != null) result.relationLinks.addAll(relationLinks);
    if (layout != null) result.layout = layout;
    if (iconEmoji != null) result.iconEmoji = iconEmoji;
    if (description != null) result.description = description;
    if (hidden != null) result.hidden = hidden;
    if (types != null) result.types.addAll(types);
    if (isArchived != null) result.isArchived = isArchived;
    if (readonly != null) result.readonly = readonly;
    if (installedByDefault != null)
      result.installedByDefault = installedByDefault;
    if (key != null) result.key = key;
    if (revision != null) result.revision = revision;
    if (restrictObjectCreation != null)
      result.restrictObjectCreation = restrictObjectCreation;
    if (iconColor != null) result.iconColor = iconColor;
    if (iconName != null) result.iconName = iconName;
    if (pluralName != null) result.pluralName = pluralName;
    return result;
  }

  ObjectType._();

  factory ObjectType.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ObjectType.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ObjectType',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..pPM<RelationLink>(3, _omitFieldNames ? '' : 'relationLinks',
        protoName: 'relationLinks', subBuilder: RelationLink.create)
    ..aE<ObjectType_Layout>(4, _omitFieldNames ? '' : 'layout',
        enumValues: ObjectType_Layout.values)
    ..aOS(5, _omitFieldNames ? '' : 'iconEmoji', protoName: 'iconEmoji')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOB(7, _omitFieldNames ? '' : 'hidden')
    ..pc<SmartBlockType>(8, _omitFieldNames ? '' : 'types', $pb.PbFieldType.KE,
        valueOf: SmartBlockType.valueOf,
        enumValues: SmartBlockType.values,
        defaultEnumValue: SmartBlockType.AccountOld)
    ..aOB(9, _omitFieldNames ? '' : 'isArchived', protoName: 'isArchived')
    ..aOB(10, _omitFieldNames ? '' : 'readonly')
    ..aOB(11, _omitFieldNames ? '' : 'installedByDefault',
        protoName: 'installedByDefault')
    ..aOS(12, _omitFieldNames ? '' : 'key')
    ..aInt64(13, _omitFieldNames ? '' : 'revision')
    ..aOB(14, _omitFieldNames ? '' : 'restrictObjectCreation',
        protoName: 'restrictObjectCreation')
    ..aInt64(15, _omitFieldNames ? '' : 'iconColor', protoName: 'iconColor')
    ..aOS(16, _omitFieldNames ? '' : 'iconName', protoName: 'iconName')
    ..aOS(17, _omitFieldNames ? '' : 'pluralName', protoName: 'pluralName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ObjectType clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ObjectType copyWith(void Function(ObjectType) updates) =>
      super.copyWith((message) => updates(message as ObjectType)) as ObjectType;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ObjectType create() => ObjectType._();
  @$core.override
  ObjectType createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ObjectType getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ObjectType>(create);
  static ObjectType? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<RelationLink> get relationLinks => $_getList(2);

  @$pb.TagNumber(4)
  ObjectType_Layout get layout => $_getN(3);
  @$pb.TagNumber(4)
  set layout(ObjectType_Layout value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLayout() => $_has(3);
  @$pb.TagNumber(4)
  void clearLayout() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get iconEmoji => $_getSZ(4);
  @$pb.TagNumber(5)
  set iconEmoji($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIconEmoji() => $_has(4);
  @$pb.TagNumber(5)
  void clearIconEmoji() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get hidden => $_getBF(6);
  @$pb.TagNumber(7)
  set hidden($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasHidden() => $_has(6);
  @$pb.TagNumber(7)
  void clearHidden() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<SmartBlockType> get types => $_getList(7);

  @$pb.TagNumber(9)
  $core.bool get isArchived => $_getBF(8);
  @$pb.TagNumber(9)
  set isArchived($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasIsArchived() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsArchived() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get readonly => $_getBF(9);
  @$pb.TagNumber(10)
  set readonly($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasReadonly() => $_has(9);
  @$pb.TagNumber(10)
  void clearReadonly() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get installedByDefault => $_getBF(10);
  @$pb.TagNumber(11)
  set installedByDefault($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasInstalledByDefault() => $_has(10);
  @$pb.TagNumber(11)
  void clearInstalledByDefault() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get key => $_getSZ(11);
  @$pb.TagNumber(12)
  set key($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasKey() => $_has(11);
  @$pb.TagNumber(12)
  void clearKey() => $_clearField(12);

  @$pb.TagNumber(13)
  $fixnum.Int64 get revision => $_getI64(12);
  @$pb.TagNumber(13)
  set revision($fixnum.Int64 value) => $_setInt64(12, value);
  @$pb.TagNumber(13)
  $core.bool hasRevision() => $_has(12);
  @$pb.TagNumber(13)
  void clearRevision() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get restrictObjectCreation => $_getBF(13);
  @$pb.TagNumber(14)
  set restrictObjectCreation($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasRestrictObjectCreation() => $_has(13);
  @$pb.TagNumber(14)
  void clearRestrictObjectCreation() => $_clearField(14);

  @$pb.TagNumber(15)
  $fixnum.Int64 get iconColor => $_getI64(14);
  @$pb.TagNumber(15)
  set iconColor($fixnum.Int64 value) => $_setInt64(14, value);
  @$pb.TagNumber(15)
  $core.bool hasIconColor() => $_has(14);
  @$pb.TagNumber(15)
  void clearIconColor() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get iconName => $_getSZ(15);
  @$pb.TagNumber(16)
  set iconName($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasIconName() => $_has(15);
  @$pb.TagNumber(16)
  void clearIconName() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get pluralName => $_getSZ(16);
  @$pb.TagNumber(17)
  set pluralName($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasPluralName() => $_has(16);
  @$pb.TagNumber(17)
  void clearPluralName() => $_clearField(17);
}

class Layout extends $pb.GeneratedMessage {
  factory Layout({
    ObjectType_Layout? id,
    $core.String? name,
    $core.Iterable<Relation>? requiredRelations,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (requiredRelations != null)
      result.requiredRelations.addAll(requiredRelations);
    return result;
  }

  Layout._();

  factory Layout.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Layout.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Layout',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aE<ObjectType_Layout>(1, _omitFieldNames ? '' : 'id',
        enumValues: ObjectType_Layout.values)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..pPM<Relation>(3, _omitFieldNames ? '' : 'requiredRelations',
        protoName: 'requiredRelations', subBuilder: Relation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Layout clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Layout copyWith(void Function(Layout) updates) =>
      super.copyWith((message) => updates(message as Layout)) as Layout;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Layout create() => Layout._();
  @$core.override
  Layout createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Layout getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Layout>(create);
  static Layout? _defaultInstance;

  @$pb.TagNumber(1)
  ObjectType_Layout get id => $_getN(0);
  @$pb.TagNumber(1)
  set id(ObjectType_Layout value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<Relation> get requiredRelations => $_getList(2);
}

class RelationWithValue extends $pb.GeneratedMessage {
  factory RelationWithValue({
    Relation? relation,
    $0.Value? value,
  }) {
    final result = create();
    if (relation != null) result.relation = relation;
    if (value != null) result.value = value;
    return result;
  }

  RelationWithValue._();

  factory RelationWithValue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RelationWithValue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RelationWithValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOM<Relation>(1, _omitFieldNames ? '' : 'relation',
        subBuilder: Relation.create)
    ..aOM<$0.Value>(2, _omitFieldNames ? '' : 'value',
        subBuilder: $0.Value.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RelationWithValue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RelationWithValue copyWith(void Function(RelationWithValue) updates) =>
      super.copyWith((message) => updates(message as RelationWithValue))
          as RelationWithValue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RelationWithValue create() => RelationWithValue._();
  @$core.override
  RelationWithValue createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RelationWithValue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RelationWithValue>(create);
  static RelationWithValue? _defaultInstance;

  @$pb.TagNumber(1)
  Relation get relation => $_getN(0);
  @$pb.TagNumber(1)
  set relation(Relation value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRelation() => $_has(0);
  @$pb.TagNumber(1)
  void clearRelation() => $_clearField(1);
  @$pb.TagNumber(1)
  Relation ensureRelation() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.Value get value => $_getN(1);
  @$pb.TagNumber(2)
  set value($0.Value value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Value ensureValue() => $_ensure(1);
}

class Relation_Option extends $pb.GeneratedMessage {
  factory Relation_Option({
    $core.String? id,
    $core.String? text,
    $core.String? color,
    $core.String? relationKey,
    $core.String? orderId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (text != null) result.text = text;
    if (color != null) result.color = color;
    if (relationKey != null) result.relationKey = relationKey;
    if (orderId != null) result.orderId = orderId;
    return result;
  }

  Relation_Option._();

  factory Relation_Option.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Relation_Option.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Relation.Option',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'text')
    ..aOS(3, _omitFieldNames ? '' : 'color')
    ..aOS(5, _omitFieldNames ? '' : 'relationKey', protoName: 'relationKey')
    ..aOS(6, _omitFieldNames ? '' : 'orderId', protoName: 'orderId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Relation_Option clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Relation_Option copyWith(void Function(Relation_Option) updates) =>
      super.copyWith((message) => updates(message as Relation_Option))
          as Relation_Option;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Relation_Option create() => Relation_Option._();
  @$core.override
  Relation_Option createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Relation_Option getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Relation_Option>(create);
  static Relation_Option? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get text => $_getSZ(1);
  @$pb.TagNumber(2)
  set text($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get color => $_getSZ(2);
  @$pb.TagNumber(3)
  set color($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasColor() => $_has(2);
  @$pb.TagNumber(3)
  void clearColor() => $_clearField(3);

  /// 4 is reserved for old relation format
  @$pb.TagNumber(5)
  $core.String get relationKey => $_getSZ(3);
  @$pb.TagNumber(5)
  set relationKey($core.String value) => $_setString(3, value);
  @$pb.TagNumber(5)
  $core.bool hasRelationKey() => $_has(3);
  @$pb.TagNumber(5)
  void clearRelationKey() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get orderId => $_getSZ(4);
  @$pb.TagNumber(6)
  set orderId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(6)
  $core.bool hasOrderId() => $_has(4);
  @$pb.TagNumber(6)
  void clearOrderId() => $_clearField(6);
}

/// Relation describe the human-interpreted relation type. It may be something like "Date of creation, format=date" or "Assignee, format=objectId, objectType=person"
class Relation extends $pb.GeneratedMessage {
  factory Relation({
    $core.String? key,
    RelationFormat? format,
    $core.String? name,
    $0.Value? defaultValue,
    Relation_DataSource? dataSource,
    $core.bool? hidden,
    $core.bool? readOnly,
    $core.bool? multi,
    $core.Iterable<$core.String>? objectTypes,
    $core.Iterable<Relation_Option>? selectDict,
    $core.int? maxCount,
    $core.String? description,
    $core.bool? readOnlyRelation,
    Relation_Scope? scope,
    $core.String? creator,
    $fixnum.Int64? revision,
    $core.bool? includeTime,
    $core.String? id,
  }) {
    final result = create();
    if (key != null) result.key = key;
    if (format != null) result.format = format;
    if (name != null) result.name = name;
    if (defaultValue != null) result.defaultValue = defaultValue;
    if (dataSource != null) result.dataSource = dataSource;
    if (hidden != null) result.hidden = hidden;
    if (readOnly != null) result.readOnly = readOnly;
    if (multi != null) result.multi = multi;
    if (objectTypes != null) result.objectTypes.addAll(objectTypes);
    if (selectDict != null) result.selectDict.addAll(selectDict);
    if (maxCount != null) result.maxCount = maxCount;
    if (description != null) result.description = description;
    if (readOnlyRelation != null) result.readOnlyRelation = readOnlyRelation;
    if (scope != null) result.scope = scope;
    if (creator != null) result.creator = creator;
    if (revision != null) result.revision = revision;
    if (includeTime != null) result.includeTime = includeTime;
    if (id != null) result.id = id;
    return result;
  }

  Relation._();

  factory Relation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Relation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Relation',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aE<RelationFormat>(2, _omitFieldNames ? '' : 'format',
        enumValues: RelationFormat.values)
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOM<$0.Value>(4, _omitFieldNames ? '' : 'defaultValue',
        protoName: 'defaultValue', subBuilder: $0.Value.create)
    ..aE<Relation_DataSource>(5, _omitFieldNames ? '' : 'dataSource',
        protoName: 'dataSource', enumValues: Relation_DataSource.values)
    ..aOB(6, _omitFieldNames ? '' : 'hidden')
    ..aOB(7, _omitFieldNames ? '' : 'readOnly', protoName: 'readOnly')
    ..aOB(8, _omitFieldNames ? '' : 'multi')
    ..pPS(9, _omitFieldNames ? '' : 'objectTypes', protoName: 'objectTypes')
    ..pPM<Relation_Option>(12, _omitFieldNames ? '' : 'selectDict',
        protoName: 'selectDict', subBuilder: Relation_Option.create)
    ..aI(13, _omitFieldNames ? '' : 'maxCount', protoName: 'maxCount')
    ..aOS(14, _omitFieldNames ? '' : 'description')
    ..aOB(15, _omitFieldNames ? '' : 'readOnlyRelation',
        protoName: 'readOnlyRelation')
    ..aE<Relation_Scope>(20, _omitFieldNames ? '' : 'scope',
        enumValues: Relation_Scope.values)
    ..aOS(21, _omitFieldNames ? '' : 'creator')
    ..aInt64(22, _omitFieldNames ? '' : 'revision')
    ..aOB(23, _omitFieldNames ? '' : 'includeTime', protoName: 'includeTime')
    ..aOS(100, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Relation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Relation copyWith(void Function(Relation) updates) =>
      super.copyWith((message) => updates(message as Relation)) as Relation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Relation create() => Relation._();
  @$core.override
  Relation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Relation getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Relation>(create);
  static Relation? _defaultInstance;

  /// Key under which the value is stored in the map. Must be unique for the object type.
  /// It usually auto-generated bsonid, but also may be something human-readable in case of prebuilt types.
  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  RelationFormat get format => $_getN(1);
  @$pb.TagNumber(2)
  set format(RelationFormat value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasFormat() => $_has(1);
  @$pb.TagNumber(2)
  void clearFormat() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Value get defaultValue => $_getN(3);
  @$pb.TagNumber(4)
  set defaultValue($0.Value value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasDefaultValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearDefaultValue() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Value ensureDefaultValue() => $_ensure(3);

  @$pb.TagNumber(5)
  Relation_DataSource get dataSource => $_getN(4);
  @$pb.TagNumber(5)
  set dataSource(Relation_DataSource value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasDataSource() => $_has(4);
  @$pb.TagNumber(5)
  void clearDataSource() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get hidden => $_getBF(5);
  @$pb.TagNumber(6)
  set hidden($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHidden() => $_has(5);
  @$pb.TagNumber(6)
  void clearHidden() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get readOnly => $_getBF(6);
  @$pb.TagNumber(7)
  set readOnly($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasReadOnly() => $_has(6);
  @$pb.TagNumber(7)
  void clearReadOnly() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get multi => $_getBF(7);
  @$pb.TagNumber(8)
  set multi($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMulti() => $_has(7);
  @$pb.TagNumber(8)
  void clearMulti() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get objectTypes => $_getList(8);

  /// index 10, 11 was used in internal-only builds. Can be reused, but may break some test accounts
  @$pb.TagNumber(12)
  $pb.PbList<Relation_Option> get selectDict => $_getList(9);

  @$pb.TagNumber(13)
  $core.int get maxCount => $_getIZ(10);
  @$pb.TagNumber(13)
  set maxCount($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(13)
  $core.bool hasMaxCount() => $_has(10);
  @$pb.TagNumber(13)
  void clearMaxCount() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get description => $_getSZ(11);
  @$pb.TagNumber(14)
  set description($core.String value) => $_setString(11, value);
  @$pb.TagNumber(14)
  $core.bool hasDescription() => $_has(11);
  @$pb.TagNumber(14)
  void clearDescription() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.bool get readOnlyRelation => $_getBF(12);
  @$pb.TagNumber(15)
  set readOnlyRelation($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(15)
  $core.bool hasReadOnlyRelation() => $_has(12);
  @$pb.TagNumber(15)
  void clearReadOnlyRelation() => $_clearField(15);

  /// on-store fields, injected only locally
  @$pb.TagNumber(20)
  Relation_Scope get scope => $_getN(13);
  @$pb.TagNumber(20)
  set scope(Relation_Scope value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasScope() => $_has(13);
  @$pb.TagNumber(20)
  void clearScope() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.String get creator => $_getSZ(14);
  @$pb.TagNumber(21)
  set creator($core.String value) => $_setString(14, value);
  @$pb.TagNumber(21)
  $core.bool hasCreator() => $_has(14);
  @$pb.TagNumber(21)
  void clearCreator() => $_clearField(21);

  @$pb.TagNumber(22)
  $fixnum.Int64 get revision => $_getI64(15);
  @$pb.TagNumber(22)
  set revision($fixnum.Int64 value) => $_setInt64(15, value);
  @$pb.TagNumber(22)
  $core.bool hasRevision() => $_has(15);
  @$pb.TagNumber(22)
  void clearRevision() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.bool get includeTime => $_getBF(16);
  @$pb.TagNumber(23)
  set includeTime($core.bool value) => $_setBool(16, value);
  @$pb.TagNumber(23)
  $core.bool hasIncludeTime() => $_has(16);
  @$pb.TagNumber(23)
  void clearIncludeTime() => $_clearField(23);

  @$pb.TagNumber(100)
  $core.String get id => $_getSZ(17);
  @$pb.TagNumber(100)
  set id($core.String value) => $_setString(17, value);
  @$pb.TagNumber(100)
  $core.bool hasId() => $_has(17);
  @$pb.TagNumber(100)
  void clearId() => $_clearField(100);
}

class RelationLink extends $pb.GeneratedMessage {
  factory RelationLink({
    $core.String? key,
    RelationFormat? format,
  }) {
    final result = create();
    if (key != null) result.key = key;
    if (format != null) result.format = format;
    return result;
  }

  RelationLink._();

  factory RelationLink.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RelationLink.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RelationLink',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aE<RelationFormat>(2, _omitFieldNames ? '' : 'format',
        enumValues: RelationFormat.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RelationLink clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RelationLink copyWith(void Function(RelationLink) updates) =>
      super.copyWith((message) => updates(message as RelationLink))
          as RelationLink;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RelationLink create() => RelationLink._();
  @$core.override
  RelationLink createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RelationLink getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RelationLink>(create);
  static RelationLink? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  RelationFormat get format => $_getN(1);
  @$pb.TagNumber(2)
  set format(RelationFormat value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasFormat() => $_has(1);
  @$pb.TagNumber(2)
  void clearFormat() => $_clearField(2);
}

class Relations extends $pb.GeneratedMessage {
  factory Relations({
    $core.Iterable<Relation>? relations,
  }) {
    final result = create();
    if (relations != null) result.relations.addAll(relations);
    return result;
  }

  Relations._();

  factory Relations.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Relations.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Relations',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPM<Relation>(1, _omitFieldNames ? '' : 'relations',
        subBuilder: Relation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Relations clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Relations copyWith(void Function(Relations) updates) =>
      super.copyWith((message) => updates(message as Relations)) as Relations;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Relations create() => Relations._();
  @$core.override
  Relations createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Relations getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Relations>(create);
  static Relations? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Relation> get relations => $_getList(0);
}

class RelationOptions extends $pb.GeneratedMessage {
  factory RelationOptions({
    $core.Iterable<Relation_Option>? options,
  }) {
    final result = create();
    if (options != null) result.options.addAll(options);
    return result;
  }

  RelationOptions._();

  factory RelationOptions.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RelationOptions.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RelationOptions',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPM<Relation_Option>(1, _omitFieldNames ? '' : 'options',
        subBuilder: Relation_Option.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RelationOptions clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RelationOptions copyWith(void Function(RelationOptions) updates) =>
      super.copyWith((message) => updates(message as RelationOptions))
          as RelationOptions;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RelationOptions create() => RelationOptions._();
  @$core.override
  RelationOptions createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RelationOptions getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RelationOptions>(create);
  static RelationOptions? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Relation_Option> get options => $_getList(0);
}

class InternalFlag extends $pb.GeneratedMessage {
  factory InternalFlag({
    InternalFlag_Value? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  InternalFlag._();

  factory InternalFlag.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InternalFlag.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InternalFlag',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aE<InternalFlag_Value>(1, _omitFieldNames ? '' : 'value',
        enumValues: InternalFlag_Value.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalFlag clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InternalFlag copyWith(void Function(InternalFlag) updates) =>
      super.copyWith((message) => updates(message as InternalFlag))
          as InternalFlag;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InternalFlag create() => InternalFlag._();
  @$core.override
  InternalFlag createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InternalFlag getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InternalFlag>(create);
  static InternalFlag? _defaultInstance;

  @$pb.TagNumber(1)
  InternalFlag_Value get value => $_getN(0);
  @$pb.TagNumber(1)
  set value(InternalFlag_Value value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class ObjectView_DetailsSet extends $pb.GeneratedMessage {
  factory ObjectView_DetailsSet({
    $core.String? id,
    $0.Struct? details,
    $core.Iterable<$core.String>? subIds,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (details != null) result.details = details;
    if (subIds != null) result.subIds.addAll(subIds);
    return result;
  }

  ObjectView_DetailsSet._();

  factory ObjectView_DetailsSet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ObjectView_DetailsSet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ObjectView.DetailsSet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$0.Struct>(2, _omitFieldNames ? '' : 'details',
        subBuilder: $0.Struct.create)
    ..pPS(3, _omitFieldNames ? '' : 'subIds', protoName: 'subIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ObjectView_DetailsSet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ObjectView_DetailsSet copyWith(
          void Function(ObjectView_DetailsSet) updates) =>
      super.copyWith((message) => updates(message as ObjectView_DetailsSet))
          as ObjectView_DetailsSet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ObjectView_DetailsSet create() => ObjectView_DetailsSet._();
  @$core.override
  ObjectView_DetailsSet createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ObjectView_DetailsSet getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ObjectView_DetailsSet>(create);
  static ObjectView_DetailsSet? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Struct get details => $_getN(1);
  @$pb.TagNumber(2)
  set details($0.Struct value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDetails() => $_has(1);
  @$pb.TagNumber(2)
  void clearDetails() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Struct ensureDetails() => $_ensure(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get subIds => $_getList(2);
}

class ObjectView_RelationWithValuePerObject extends $pb.GeneratedMessage {
  factory ObjectView_RelationWithValuePerObject({
    $core.String? objectId,
    $core.Iterable<RelationWithValue>? relations,
  }) {
    final result = create();
    if (objectId != null) result.objectId = objectId;
    if (relations != null) result.relations.addAll(relations);
    return result;
  }

  ObjectView_RelationWithValuePerObject._();

  factory ObjectView_RelationWithValuePerObject.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ObjectView_RelationWithValuePerObject.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ObjectView.RelationWithValuePerObject',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'objectId', protoName: 'objectId')
    ..pPM<RelationWithValue>(2, _omitFieldNames ? '' : 'relations',
        subBuilder: RelationWithValue.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ObjectView_RelationWithValuePerObject clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ObjectView_RelationWithValuePerObject copyWith(
          void Function(ObjectView_RelationWithValuePerObject) updates) =>
      super.copyWith((message) =>
              updates(message as ObjectView_RelationWithValuePerObject))
          as ObjectView_RelationWithValuePerObject;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ObjectView_RelationWithValuePerObject create() =>
      ObjectView_RelationWithValuePerObject._();
  @$core.override
  ObjectView_RelationWithValuePerObject createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ObjectView_RelationWithValuePerObject getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          ObjectView_RelationWithValuePerObject>(create);
  static ObjectView_RelationWithValuePerObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get objectId => $_getSZ(0);
  @$pb.TagNumber(1)
  set objectId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasObjectId() => $_has(0);
  @$pb.TagNumber(1)
  void clearObjectId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<RelationWithValue> get relations => $_getList(1);
}

class ObjectView_HistorySize extends $pb.GeneratedMessage {
  factory ObjectView_HistorySize({
    $core.int? undo,
    $core.int? redo,
  }) {
    final result = create();
    if (undo != null) result.undo = undo;
    if (redo != null) result.redo = redo;
    return result;
  }

  ObjectView_HistorySize._();

  factory ObjectView_HistorySize.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ObjectView_HistorySize.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ObjectView.HistorySize',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'undo')
    ..aI(2, _omitFieldNames ? '' : 'redo')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ObjectView_HistorySize clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ObjectView_HistorySize copyWith(
          void Function(ObjectView_HistorySize) updates) =>
      super.copyWith((message) => updates(message as ObjectView_HistorySize))
          as ObjectView_HistorySize;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ObjectView_HistorySize create() => ObjectView_HistorySize._();
  @$core.override
  ObjectView_HistorySize createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ObjectView_HistorySize getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ObjectView_HistorySize>(create);
  static ObjectView_HistorySize? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get undo => $_getIZ(0);
  @$pb.TagNumber(1)
  set undo($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUndo() => $_has(0);
  @$pb.TagNumber(1)
  void clearUndo() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get redo => $_getIZ(1);
  @$pb.TagNumber(2)
  set redo($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRedo() => $_has(1);
  @$pb.TagNumber(2)
  void clearRedo() => $_clearField(2);
}

class ObjectView_BlockParticipant extends $pb.GeneratedMessage {
  factory ObjectView_BlockParticipant({
    $core.String? blockId,
    $core.String? participantId,
  }) {
    final result = create();
    if (blockId != null) result.blockId = blockId;
    if (participantId != null) result.participantId = participantId;
    return result;
  }

  ObjectView_BlockParticipant._();

  factory ObjectView_BlockParticipant.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ObjectView_BlockParticipant.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ObjectView.BlockParticipant',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'blockId', protoName: 'blockId')
    ..aOS(2, _omitFieldNames ? '' : 'participantId', protoName: 'participantId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ObjectView_BlockParticipant clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ObjectView_BlockParticipant copyWith(
          void Function(ObjectView_BlockParticipant) updates) =>
      super.copyWith(
              (message) => updates(message as ObjectView_BlockParticipant))
          as ObjectView_BlockParticipant;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ObjectView_BlockParticipant create() =>
      ObjectView_BlockParticipant._();
  @$core.override
  ObjectView_BlockParticipant createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ObjectView_BlockParticipant getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ObjectView_BlockParticipant>(create);
  static ObjectView_BlockParticipant? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get blockId => $_getSZ(0);
  @$pb.TagNumber(1)
  set blockId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockId() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get participantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set participantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasParticipantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearParticipantId() => $_clearField(2);
}

///
///  Works with a smart blocks: Page, Dashboard
///  Dashboard opened, click on a page, Rpc.Block.open, Block.ShowFullscreen(PageBlock)
class ObjectView extends $pb.GeneratedMessage {
  factory ObjectView({
    $core.String? rootId,
    $core.Iterable<Block>? blocks,
    $core.Iterable<ObjectView_DetailsSet>? details,
    SmartBlockType? type,
    $core.Iterable<Relation>? relations,
    Restrictions? restrictions,
    ObjectView_HistorySize? history,
    $core.Iterable<RelationLink>? relationLinks,
    $core.Iterable<ObjectView_BlockParticipant>? blockParticipants,
  }) {
    final result = create();
    if (rootId != null) result.rootId = rootId;
    if (blocks != null) result.blocks.addAll(blocks);
    if (details != null) result.details.addAll(details);
    if (type != null) result.type = type;
    if (relations != null) result.relations.addAll(relations);
    if (restrictions != null) result.restrictions = restrictions;
    if (history != null) result.history = history;
    if (relationLinks != null) result.relationLinks.addAll(relationLinks);
    if (blockParticipants != null)
      result.blockParticipants.addAll(blockParticipants);
    return result;
  }

  ObjectView._();

  factory ObjectView.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ObjectView.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ObjectView',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'rootId', protoName: 'rootId')
    ..pPM<Block>(2, _omitFieldNames ? '' : 'blocks', subBuilder: Block.create)
    ..pPM<ObjectView_DetailsSet>(3, _omitFieldNames ? '' : 'details',
        subBuilder: ObjectView_DetailsSet.create)
    ..aE<SmartBlockType>(4, _omitFieldNames ? '' : 'type',
        enumValues: SmartBlockType.values)
    ..pPM<Relation>(7, _omitFieldNames ? '' : 'relations',
        subBuilder: Relation.create)
    ..aOM<Restrictions>(8, _omitFieldNames ? '' : 'restrictions',
        subBuilder: Restrictions.create)
    ..aOM<ObjectView_HistorySize>(9, _omitFieldNames ? '' : 'history',
        subBuilder: ObjectView_HistorySize.create)
    ..pPM<RelationLink>(10, _omitFieldNames ? '' : 'relationLinks',
        protoName: 'relationLinks', subBuilder: RelationLink.create)
    ..pPM<ObjectView_BlockParticipant>(
        11, _omitFieldNames ? '' : 'blockParticipants',
        protoName: 'blockParticipants',
        subBuilder: ObjectView_BlockParticipant.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ObjectView clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ObjectView copyWith(void Function(ObjectView) updates) =>
      super.copyWith((message) => updates(message as ObjectView)) as ObjectView;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ObjectView create() => ObjectView._();
  @$core.override
  ObjectView createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ObjectView getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ObjectView>(create);
  static ObjectView? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get rootId => $_getSZ(0);
  @$pb.TagNumber(1)
  set rootId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRootId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRootId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<Block> get blocks => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<ObjectView_DetailsSet> get details => $_getList(2);

  @$pb.TagNumber(4)
  SmartBlockType get type => $_getN(3);
  @$pb.TagNumber(4)
  set type(SmartBlockType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => $_clearField(4);

  @$pb.TagNumber(7)
  $pb.PbList<Relation> get relations => $_getList(4);

  @$pb.TagNumber(8)
  Restrictions get restrictions => $_getN(5);
  @$pb.TagNumber(8)
  set restrictions(Restrictions value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasRestrictions() => $_has(5);
  @$pb.TagNumber(8)
  void clearRestrictions() => $_clearField(8);
  @$pb.TagNumber(8)
  Restrictions ensureRestrictions() => $_ensure(5);

  @$pb.TagNumber(9)
  ObjectView_HistorySize get history => $_getN(6);
  @$pb.TagNumber(9)
  set history(ObjectView_HistorySize value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasHistory() => $_has(6);
  @$pb.TagNumber(9)
  void clearHistory() => $_clearField(9);
  @$pb.TagNumber(9)
  ObjectView_HistorySize ensureHistory() => $_ensure(6);

  @$pb.TagNumber(10)
  $pb.PbList<RelationLink> get relationLinks => $_getList(7);

  @$pb.TagNumber(11)
  $pb.PbList<ObjectView_BlockParticipant> get blockParticipants => $_getList(8);
}

class ParticipantPermissionChange extends $pb.GeneratedMessage {
  factory ParticipantPermissionChange({
    $core.String? identity,
    ParticipantPermissions? perms,
  }) {
    final result = create();
    if (identity != null) result.identity = identity;
    if (perms != null) result.perms = perms;
    return result;
  }

  ParticipantPermissionChange._();

  factory ParticipantPermissionChange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ParticipantPermissionChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ParticipantPermissionChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'identity')
    ..aE<ParticipantPermissions>(2, _omitFieldNames ? '' : 'perms',
        enumValues: ParticipantPermissions.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantPermissionChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParticipantPermissionChange copyWith(
          void Function(ParticipantPermissionChange) updates) =>
      super.copyWith(
              (message) => updates(message as ParticipantPermissionChange))
          as ParticipantPermissionChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ParticipantPermissionChange create() =>
      ParticipantPermissionChange._();
  @$core.override
  ParticipantPermissionChange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ParticipantPermissionChange getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ParticipantPermissionChange>(create);
  static ParticipantPermissionChange? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get identity => $_getSZ(0);
  @$pb.TagNumber(1)
  set identity($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentity() => $_clearField(1);

  @$pb.TagNumber(2)
  ParticipantPermissions get perms => $_getN(1);
  @$pb.TagNumber(2)
  set perms(ParticipantPermissions value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPerms() => $_has(1);
  @$pb.TagNumber(2)
  void clearPerms() => $_clearField(2);
}

class Metadata_Payload_IdentityPayload extends $pb.GeneratedMessage {
  factory Metadata_Payload_IdentityPayload({
    $core.List<$core.int>? profileSymKey,
  }) {
    final result = create();
    if (profileSymKey != null) result.profileSymKey = profileSymKey;
    return result;
  }

  Metadata_Payload_IdentityPayload._();

  factory Metadata_Payload_IdentityPayload.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Metadata_Payload_IdentityPayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Metadata.Payload.IdentityPayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'profileSymKey', $pb.PbFieldType.OY,
        protoName: 'profileSymKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Metadata_Payload_IdentityPayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Metadata_Payload_IdentityPayload copyWith(
          void Function(Metadata_Payload_IdentityPayload) updates) =>
      super.copyWith(
              (message) => updates(message as Metadata_Payload_IdentityPayload))
          as Metadata_Payload_IdentityPayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Metadata_Payload_IdentityPayload create() =>
      Metadata_Payload_IdentityPayload._();
  @$core.override
  Metadata_Payload_IdentityPayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Metadata_Payload_IdentityPayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Metadata_Payload_IdentityPayload>(
          create);
  static Metadata_Payload_IdentityPayload? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get profileSymKey => $_getN(0);
  @$pb.TagNumber(1)
  set profileSymKey($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProfileSymKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearProfileSymKey() => $_clearField(1);
}

class Metadata_Payload extends $pb.GeneratedMessage {
  factory Metadata_Payload() => create();

  Metadata_Payload._();

  factory Metadata_Payload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Metadata_Payload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Metadata.Payload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Metadata_Payload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Metadata_Payload copyWith(void Function(Metadata_Payload) updates) =>
      super.copyWith((message) => updates(message as Metadata_Payload))
          as Metadata_Payload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Metadata_Payload create() => Metadata_Payload._();
  @$core.override
  Metadata_Payload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Metadata_Payload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Metadata_Payload>(create);
  static Metadata_Payload? _defaultInstance;
}

enum Metadata_Payload_ { identity, notSet }

class Metadata extends $pb.GeneratedMessage {
  factory Metadata({
    Metadata_Payload_IdentityPayload? identity,
  }) {
    final result = create();
    if (identity != null) result.identity = identity;
    return result;
  }

  Metadata._();

  factory Metadata.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Metadata.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Metadata_Payload_> _Metadata_Payload_ByTag =
      {1: Metadata_Payload_.identity, 0: Metadata_Payload_.notSet};
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Metadata',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..oo(0, [1])
    ..aOM<Metadata_Payload_IdentityPayload>(
        1, _omitFieldNames ? '' : 'identity',
        subBuilder: Metadata_Payload_IdentityPayload.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Metadata clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Metadata copyWith(void Function(Metadata) updates) =>
      super.copyWith((message) => updates(message as Metadata)) as Metadata;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Metadata create() => Metadata._();
  @$core.override
  Metadata createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Metadata getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Metadata>(create);
  static Metadata? _defaultInstance;

  @$pb.TagNumber(1)
  Metadata_Payload_ whichPayload() => _Metadata_Payload_ByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  void clearPayload() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Metadata_Payload_IdentityPayload get identity => $_getN(0);
  @$pb.TagNumber(1)
  set identity(Metadata_Payload_IdentityPayload value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentity() => $_clearField(1);
  @$pb.TagNumber(1)
  Metadata_Payload_IdentityPayload ensureIdentity() => $_ensure(0);
}

class Notification_Import extends $pb.GeneratedMessage {
  factory Notification_Import({
    $core.String? processId,
    Import_ErrorCode? errorCode,
    Import_Type? importType,
    $core.String? spaceId,
    $core.String? name,
    $core.String? spaceName,
  }) {
    final result = create();
    if (processId != null) result.processId = processId;
    if (errorCode != null) result.errorCode = errorCode;
    if (importType != null) result.importType = importType;
    if (spaceId != null) result.spaceId = spaceId;
    if (name != null) result.name = name;
    if (spaceName != null) result.spaceName = spaceName;
    return result;
  }

  Notification_Import._();

  factory Notification_Import.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Notification_Import.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Notification.Import',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'processId', protoName: 'processId')
    ..aE<Import_ErrorCode>(2, _omitFieldNames ? '' : 'errorCode',
        protoName: 'errorCode', enumValues: Import_ErrorCode.values)
    ..aE<Import_Type>(3, _omitFieldNames ? '' : 'importType',
        protoName: 'importType', enumValues: Import_Type.values)
    ..aOS(4, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'spaceName', protoName: 'spaceName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_Import clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_Import copyWith(void Function(Notification_Import) updates) =>
      super.copyWith((message) => updates(message as Notification_Import))
          as Notification_Import;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Notification_Import create() => Notification_Import._();
  @$core.override
  Notification_Import createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Notification_Import getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Notification_Import>(create);
  static Notification_Import? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get processId => $_getSZ(0);
  @$pb.TagNumber(1)
  set processId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProcessId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProcessId() => $_clearField(1);

  @$pb.TagNumber(2)
  Import_ErrorCode get errorCode => $_getN(1);
  @$pb.TagNumber(2)
  set errorCode(Import_ErrorCode value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorCode() => $_clearField(2);

  @$pb.TagNumber(3)
  Import_Type get importType => $_getN(2);
  @$pb.TagNumber(3)
  set importType(Import_Type value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasImportType() => $_has(2);
  @$pb.TagNumber(3)
  void clearImportType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get spaceId => $_getSZ(3);
  @$pb.TagNumber(4)
  set spaceId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSpaceId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSpaceId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get spaceName => $_getSZ(5);
  @$pb.TagNumber(6)
  set spaceName($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSpaceName() => $_has(5);
  @$pb.TagNumber(6)
  void clearSpaceName() => $_clearField(6);
}

class Notification_Export extends $pb.GeneratedMessage {
  factory Notification_Export({
    Notification_Export_Code? errorCode,
    Export_Format? exportType,
  }) {
    final result = create();
    if (errorCode != null) result.errorCode = errorCode;
    if (exportType != null) result.exportType = exportType;
    return result;
  }

  Notification_Export._();

  factory Notification_Export.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Notification_Export.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Notification.Export',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aE<Notification_Export_Code>(2, _omitFieldNames ? '' : 'errorCode',
        protoName: 'errorCode', enumValues: Notification_Export_Code.values)
    ..aE<Export_Format>(3, _omitFieldNames ? '' : 'exportType',
        protoName: 'exportType', enumValues: Export_Format.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_Export clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_Export copyWith(void Function(Notification_Export) updates) =>
      super.copyWith((message) => updates(message as Notification_Export))
          as Notification_Export;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Notification_Export create() => Notification_Export._();
  @$core.override
  Notification_Export createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Notification_Export getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Notification_Export>(create);
  static Notification_Export? _defaultInstance;

  @$pb.TagNumber(2)
  Notification_Export_Code get errorCode => $_getN(0);
  @$pb.TagNumber(2)
  set errorCode(Notification_Export_Code value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorCode() => $_has(0);
  @$pb.TagNumber(2)
  void clearErrorCode() => $_clearField(2);

  @$pb.TagNumber(3)
  Export_Format get exportType => $_getN(1);
  @$pb.TagNumber(3)
  set exportType(Export_Format value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasExportType() => $_has(1);
  @$pb.TagNumber(3)
  void clearExportType() => $_clearField(3);
}

class Notification_GalleryImport extends $pb.GeneratedMessage {
  factory Notification_GalleryImport({
    $core.String? processId,
    Import_ErrorCode? errorCode,
    $core.String? spaceId,
    $core.String? name,
    $core.String? spaceName,
  }) {
    final result = create();
    if (processId != null) result.processId = processId;
    if (errorCode != null) result.errorCode = errorCode;
    if (spaceId != null) result.spaceId = spaceId;
    if (name != null) result.name = name;
    if (spaceName != null) result.spaceName = spaceName;
    return result;
  }

  Notification_GalleryImport._();

  factory Notification_GalleryImport.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Notification_GalleryImport.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Notification.GalleryImport',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'processId', protoName: 'processId')
    ..aE<Import_ErrorCode>(2, _omitFieldNames ? '' : 'errorCode',
        protoName: 'errorCode', enumValues: Import_ErrorCode.values)
    ..aOS(3, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOS(5, _omitFieldNames ? '' : 'spaceName', protoName: 'spaceName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_GalleryImport clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_GalleryImport copyWith(
          void Function(Notification_GalleryImport) updates) =>
      super.copyWith(
              (message) => updates(message as Notification_GalleryImport))
          as Notification_GalleryImport;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Notification_GalleryImport create() => Notification_GalleryImport._();
  @$core.override
  Notification_GalleryImport createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Notification_GalleryImport getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Notification_GalleryImport>(create);
  static Notification_GalleryImport? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get processId => $_getSZ(0);
  @$pb.TagNumber(1)
  set processId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProcessId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProcessId() => $_clearField(1);

  @$pb.TagNumber(2)
  Import_ErrorCode get errorCode => $_getN(1);
  @$pb.TagNumber(2)
  set errorCode(Import_ErrorCode value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasErrorCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearErrorCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get spaceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set spaceId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSpaceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSpaceId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get spaceName => $_getSZ(4);
  @$pb.TagNumber(5)
  set spaceName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSpaceName() => $_has(4);
  @$pb.TagNumber(5)
  void clearSpaceName() => $_clearField(5);
}

class Notification_RequestToJoin extends $pb.GeneratedMessage {
  factory Notification_RequestToJoin({
    $core.String? spaceId,
    $core.String? identity,
    $core.String? identityName,
    $core.String? identityIcon,
    $core.String? spaceName,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (identity != null) result.identity = identity;
    if (identityName != null) result.identityName = identityName;
    if (identityIcon != null) result.identityIcon = identityIcon;
    if (spaceName != null) result.spaceName = spaceName;
    return result;
  }

  Notification_RequestToJoin._();

  factory Notification_RequestToJoin.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Notification_RequestToJoin.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Notification.RequestToJoin',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(2, _omitFieldNames ? '' : 'identity')
    ..aOS(3, _omitFieldNames ? '' : 'identityName', protoName: 'identityName')
    ..aOS(4, _omitFieldNames ? '' : 'identityIcon', protoName: 'identityIcon')
    ..aOS(5, _omitFieldNames ? '' : 'spaceName', protoName: 'spaceName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_RequestToJoin clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_RequestToJoin copyWith(
          void Function(Notification_RequestToJoin) updates) =>
      super.copyWith(
              (message) => updates(message as Notification_RequestToJoin))
          as Notification_RequestToJoin;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Notification_RequestToJoin create() => Notification_RequestToJoin._();
  @$core.override
  Notification_RequestToJoin createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Notification_RequestToJoin getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Notification_RequestToJoin>(create);
  static Notification_RequestToJoin? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get identity => $_getSZ(1);
  @$pb.TagNumber(2)
  set identity($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIdentity() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentity() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get identityName => $_getSZ(2);
  @$pb.TagNumber(3)
  set identityName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIdentityName() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdentityName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get identityIcon => $_getSZ(3);
  @$pb.TagNumber(4)
  set identityIcon($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIdentityIcon() => $_has(3);
  @$pb.TagNumber(4)
  void clearIdentityIcon() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get spaceName => $_getSZ(4);
  @$pb.TagNumber(5)
  set spaceName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSpaceName() => $_has(4);
  @$pb.TagNumber(5)
  void clearSpaceName() => $_clearField(5);
}

class Notification_Test extends $pb.GeneratedMessage {
  factory Notification_Test() => create();

  Notification_Test._();

  factory Notification_Test.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Notification_Test.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Notification.Test',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_Test clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_Test copyWith(void Function(Notification_Test) updates) =>
      super.copyWith((message) => updates(message as Notification_Test))
          as Notification_Test;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Notification_Test create() => Notification_Test._();
  @$core.override
  Notification_Test createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Notification_Test getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Notification_Test>(create);
  static Notification_Test? _defaultInstance;
}

class Notification_ParticipantRequestApproved extends $pb.GeneratedMessage {
  factory Notification_ParticipantRequestApproved({
    $core.String? spaceId,
    ParticipantPermissions? permissions,
    $core.String? spaceName,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (permissions != null) result.permissions = permissions;
    if (spaceName != null) result.spaceName = spaceName;
    return result;
  }

  Notification_ParticipantRequestApproved._();

  factory Notification_ParticipantRequestApproved.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Notification_ParticipantRequestApproved.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Notification.ParticipantRequestApproved',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aE<ParticipantPermissions>(2, _omitFieldNames ? '' : 'permissions',
        enumValues: ParticipantPermissions.values)
    ..aOS(5, _omitFieldNames ? '' : 'spaceName', protoName: 'spaceName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_ParticipantRequestApproved clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_ParticipantRequestApproved copyWith(
          void Function(Notification_ParticipantRequestApproved) updates) =>
      super.copyWith((message) =>
              updates(message as Notification_ParticipantRequestApproved))
          as Notification_ParticipantRequestApproved;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Notification_ParticipantRequestApproved create() =>
      Notification_ParticipantRequestApproved._();
  @$core.override
  Notification_ParticipantRequestApproved createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Notification_ParticipantRequestApproved getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          Notification_ParticipantRequestApproved>(create);
  static Notification_ParticipantRequestApproved? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  ParticipantPermissions get permissions => $_getN(1);
  @$pb.TagNumber(2)
  set permissions(ParticipantPermissions value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPermissions() => $_has(1);
  @$pb.TagNumber(2)
  void clearPermissions() => $_clearField(2);

  @$pb.TagNumber(5)
  $core.String get spaceName => $_getSZ(2);
  @$pb.TagNumber(5)
  set spaceName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(5)
  $core.bool hasSpaceName() => $_has(2);
  @$pb.TagNumber(5)
  void clearSpaceName() => $_clearField(5);
}

class Notification_RequestToLeave extends $pb.GeneratedMessage {
  factory Notification_RequestToLeave({
    $core.String? spaceId,
    $core.String? identity,
    $core.String? identityName,
    $core.String? identityIcon,
    $core.String? spaceName,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (identity != null) result.identity = identity;
    if (identityName != null) result.identityName = identityName;
    if (identityIcon != null) result.identityIcon = identityIcon;
    if (spaceName != null) result.spaceName = spaceName;
    return result;
  }

  Notification_RequestToLeave._();

  factory Notification_RequestToLeave.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Notification_RequestToLeave.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Notification.RequestToLeave',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(2, _omitFieldNames ? '' : 'identity')
    ..aOS(3, _omitFieldNames ? '' : 'identityName', protoName: 'identityName')
    ..aOS(4, _omitFieldNames ? '' : 'identityIcon', protoName: 'identityIcon')
    ..aOS(5, _omitFieldNames ? '' : 'spaceName', protoName: 'spaceName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_RequestToLeave clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_RequestToLeave copyWith(
          void Function(Notification_RequestToLeave) updates) =>
      super.copyWith(
              (message) => updates(message as Notification_RequestToLeave))
          as Notification_RequestToLeave;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Notification_RequestToLeave create() =>
      Notification_RequestToLeave._();
  @$core.override
  Notification_RequestToLeave createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Notification_RequestToLeave getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Notification_RequestToLeave>(create);
  static Notification_RequestToLeave? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get identity => $_getSZ(1);
  @$pb.TagNumber(2)
  set identity($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIdentity() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentity() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get identityName => $_getSZ(2);
  @$pb.TagNumber(3)
  set identityName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIdentityName() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdentityName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get identityIcon => $_getSZ(3);
  @$pb.TagNumber(4)
  set identityIcon($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIdentityIcon() => $_has(3);
  @$pb.TagNumber(4)
  void clearIdentityIcon() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get spaceName => $_getSZ(4);
  @$pb.TagNumber(5)
  set spaceName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSpaceName() => $_has(4);
  @$pb.TagNumber(5)
  void clearSpaceName() => $_clearField(5);
}

class Notification_ParticipantRemove extends $pb.GeneratedMessage {
  factory Notification_ParticipantRemove({
    $core.String? identity,
    $core.String? identityName,
    $core.String? identityIcon,
    $core.String? spaceId,
    $core.String? spaceName,
  }) {
    final result = create();
    if (identity != null) result.identity = identity;
    if (identityName != null) result.identityName = identityName;
    if (identityIcon != null) result.identityIcon = identityIcon;
    if (spaceId != null) result.spaceId = spaceId;
    if (spaceName != null) result.spaceName = spaceName;
    return result;
  }

  Notification_ParticipantRemove._();

  factory Notification_ParticipantRemove.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Notification_ParticipantRemove.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Notification.ParticipantRemove',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'identity')
    ..aOS(2, _omitFieldNames ? '' : 'identityName', protoName: 'identityName')
    ..aOS(3, _omitFieldNames ? '' : 'identityIcon', protoName: 'identityIcon')
    ..aOS(4, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(5, _omitFieldNames ? '' : 'spaceName', protoName: 'spaceName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_ParticipantRemove clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_ParticipantRemove copyWith(
          void Function(Notification_ParticipantRemove) updates) =>
      super.copyWith(
              (message) => updates(message as Notification_ParticipantRemove))
          as Notification_ParticipantRemove;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Notification_ParticipantRemove create() =>
      Notification_ParticipantRemove._();
  @$core.override
  Notification_ParticipantRemove createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Notification_ParticipantRemove getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Notification_ParticipantRemove>(create);
  static Notification_ParticipantRemove? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get identity => $_getSZ(0);
  @$pb.TagNumber(1)
  set identity($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get identityName => $_getSZ(1);
  @$pb.TagNumber(2)
  set identityName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIdentityName() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentityName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get identityIcon => $_getSZ(2);
  @$pb.TagNumber(3)
  set identityIcon($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIdentityIcon() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdentityIcon() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get spaceId => $_getSZ(3);
  @$pb.TagNumber(4)
  set spaceId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSpaceId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSpaceId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get spaceName => $_getSZ(4);
  @$pb.TagNumber(5)
  set spaceName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSpaceName() => $_has(4);
  @$pb.TagNumber(5)
  void clearSpaceName() => $_clearField(5);
}

class Notification_ParticipantRequestDecline extends $pb.GeneratedMessage {
  factory Notification_ParticipantRequestDecline({
    $core.String? spaceId,
    $core.String? spaceName,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (spaceName != null) result.spaceName = spaceName;
    return result;
  }

  Notification_ParticipantRequestDecline._();

  factory Notification_ParticipantRequestDecline.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Notification_ParticipantRequestDecline.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Notification.ParticipantRequestDecline',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(3, _omitFieldNames ? '' : 'spaceName', protoName: 'spaceName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_ParticipantRequestDecline clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_ParticipantRequestDecline copyWith(
          void Function(Notification_ParticipantRequestDecline) updates) =>
      super.copyWith((message) =>
              updates(message as Notification_ParticipantRequestDecline))
          as Notification_ParticipantRequestDecline;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Notification_ParticipantRequestDecline create() =>
      Notification_ParticipantRequestDecline._();
  @$core.override
  Notification_ParticipantRequestDecline createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Notification_ParticipantRequestDecline getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          Notification_ParticipantRequestDecline>(create);
  static Notification_ParticipantRequestDecline? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(3)
  $core.String get spaceName => $_getSZ(1);
  @$pb.TagNumber(3)
  set spaceName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(3)
  $core.bool hasSpaceName() => $_has(1);
  @$pb.TagNumber(3)
  void clearSpaceName() => $_clearField(3);
}

class Notification_ParticipantPermissionsChange extends $pb.GeneratedMessage {
  factory Notification_ParticipantPermissionsChange({
    $core.String? spaceId,
    ParticipantPermissions? permissions,
    $core.String? spaceName,
  }) {
    final result = create();
    if (spaceId != null) result.spaceId = spaceId;
    if (permissions != null) result.permissions = permissions;
    if (spaceName != null) result.spaceName = spaceName;
    return result;
  }

  Notification_ParticipantPermissionsChange._();

  factory Notification_ParticipantPermissionsChange.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Notification_ParticipantPermissionsChange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Notification.ParticipantPermissionsChange',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aE<ParticipantPermissions>(2, _omitFieldNames ? '' : 'permissions',
        enumValues: ParticipantPermissions.values)
    ..aOS(3, _omitFieldNames ? '' : 'spaceName', protoName: 'spaceName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_ParticipantPermissionsChange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification_ParticipantPermissionsChange copyWith(
          void Function(Notification_ParticipantPermissionsChange) updates) =>
      super.copyWith((message) =>
              updates(message as Notification_ParticipantPermissionsChange))
          as Notification_ParticipantPermissionsChange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Notification_ParticipantPermissionsChange create() =>
      Notification_ParticipantPermissionsChange._();
  @$core.override
  Notification_ParticipantPermissionsChange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Notification_ParticipantPermissionsChange getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          Notification_ParticipantPermissionsChange>(create);
  static Notification_ParticipantPermissionsChange? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get spaceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set spaceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpaceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpaceId() => $_clearField(1);

  @$pb.TagNumber(2)
  ParticipantPermissions get permissions => $_getN(1);
  @$pb.TagNumber(2)
  set permissions(ParticipantPermissions value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPermissions() => $_has(1);
  @$pb.TagNumber(2)
  void clearPermissions() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get spaceName => $_getSZ(2);
  @$pb.TagNumber(3)
  set spaceName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSpaceName() => $_has(2);
  @$pb.TagNumber(3)
  void clearSpaceName() => $_clearField(3);
}

enum Notification_Payload {
  import,
  export,
  galleryImport,
  requestToJoin,
  test,
  participantRequestApproved,
  requestToLeave,
  participantRemove,
  participantRequestDecline,
  participantPermissionsChange,
  notSet
}

class Notification extends $pb.GeneratedMessage {
  factory Notification({
    $core.String? id,
    $fixnum.Int64? createTime,
    Notification_Status? status,
    $core.bool? isLocal,
    Notification_Import? import,
    $core.String? space,
    Notification_Export? export,
    Notification_GalleryImport? galleryImport,
    Notification_RequestToJoin? requestToJoin,
    Notification_Test? test,
    Notification_ParticipantRequestApproved? participantRequestApproved,
    $core.String? aclHeadId,
    Notification_RequestToLeave? requestToLeave,
    Notification_ParticipantRemove? participantRemove,
    Notification_ParticipantRequestDecline? participantRequestDecline,
    Notification_ParticipantPermissionsChange? participantPermissionsChange,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (createTime != null) result.createTime = createTime;
    if (status != null) result.status = status;
    if (isLocal != null) result.isLocal = isLocal;
    if (import != null) result.import = import;
    if (space != null) result.space = space;
    if (export != null) result.export = export;
    if (galleryImport != null) result.galleryImport = galleryImport;
    if (requestToJoin != null) result.requestToJoin = requestToJoin;
    if (test != null) result.test = test;
    if (participantRequestApproved != null)
      result.participantRequestApproved = participantRequestApproved;
    if (aclHeadId != null) result.aclHeadId = aclHeadId;
    if (requestToLeave != null) result.requestToLeave = requestToLeave;
    if (participantRemove != null) result.participantRemove = participantRemove;
    if (participantRequestDecline != null)
      result.participantRequestDecline = participantRequestDecline;
    if (participantPermissionsChange != null)
      result.participantPermissionsChange = participantPermissionsChange;
    return result;
  }

  Notification._();

  factory Notification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Notification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Notification_Payload>
      _Notification_PayloadByTag = {
    6: Notification_Payload.import,
    8: Notification_Payload.export,
    9: Notification_Payload.galleryImport,
    10: Notification_Payload.requestToJoin,
    11: Notification_Payload.test,
    13: Notification_Payload.participantRequestApproved,
    15: Notification_Payload.requestToLeave,
    16: Notification_Payload.participantRemove,
    17: Notification_Payload.participantRequestDecline,
    18: Notification_Payload.participantPermissionsChange,
    0: Notification_Payload.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Notification',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..oo(0, [6, 8, 9, 10, 11, 13, 15, 16, 17, 18])
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'createTime', protoName: 'createTime')
    ..aE<Notification_Status>(4, _omitFieldNames ? '' : 'status',
        enumValues: Notification_Status.values)
    ..aOB(5, _omitFieldNames ? '' : 'isLocal', protoName: 'isLocal')
    ..aOM<Notification_Import>(6, _omitFieldNames ? '' : 'import',
        subBuilder: Notification_Import.create)
    ..aOS(7, _omitFieldNames ? '' : 'space')
    ..aOM<Notification_Export>(8, _omitFieldNames ? '' : 'export',
        subBuilder: Notification_Export.create)
    ..aOM<Notification_GalleryImport>(9, _omitFieldNames ? '' : 'galleryImport',
        protoName: 'galleryImport',
        subBuilder: Notification_GalleryImport.create)
    ..aOM<Notification_RequestToJoin>(
        10, _omitFieldNames ? '' : 'requestToJoin',
        protoName: 'requestToJoin',
        subBuilder: Notification_RequestToJoin.create)
    ..aOM<Notification_Test>(11, _omitFieldNames ? '' : 'test',
        subBuilder: Notification_Test.create)
    ..aOM<Notification_ParticipantRequestApproved>(
        13, _omitFieldNames ? '' : 'participantRequestApproved',
        protoName: 'participantRequestApproved',
        subBuilder: Notification_ParticipantRequestApproved.create)
    ..aOS(14, _omitFieldNames ? '' : 'aclHeadId', protoName: 'aclHeadId')
    ..aOM<Notification_RequestToLeave>(
        15, _omitFieldNames ? '' : 'requestToLeave',
        protoName: 'requestToLeave',
        subBuilder: Notification_RequestToLeave.create)
    ..aOM<Notification_ParticipantRemove>(
        16, _omitFieldNames ? '' : 'participantRemove',
        protoName: 'participantRemove',
        subBuilder: Notification_ParticipantRemove.create)
    ..aOM<Notification_ParticipantRequestDecline>(
        17, _omitFieldNames ? '' : 'participantRequestDecline',
        protoName: 'participantRequestDecline',
        subBuilder: Notification_ParticipantRequestDecline.create)
    ..aOM<Notification_ParticipantPermissionsChange>(
        18, _omitFieldNames ? '' : 'participantPermissionsChange',
        protoName: 'participantPermissionsChange',
        subBuilder: Notification_ParticipantPermissionsChange.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Notification copyWith(void Function(Notification) updates) =>
      super.copyWith((message) => updates(message as Notification))
          as Notification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Notification create() => Notification._();
  @$core.override
  Notification createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Notification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Notification>(create);
  static Notification? _defaultInstance;

  @$pb.TagNumber(6)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(13)
  @$pb.TagNumber(15)
  @$pb.TagNumber(16)
  @$pb.TagNumber(17)
  @$pb.TagNumber(18)
  Notification_Payload whichPayload() =>
      _Notification_PayloadByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(6)
  @$pb.TagNumber(8)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  @$pb.TagNumber(13)
  @$pb.TagNumber(15)
  @$pb.TagNumber(16)
  @$pb.TagNumber(17)
  @$pb.TagNumber(18)
  void clearPayload() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get createTime => $_getI64(1);
  @$pb.TagNumber(2)
  set createTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCreateTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearCreateTime() => $_clearField(2);

  @$pb.TagNumber(4)
  Notification_Status get status => $_getN(2);
  @$pb.TagNumber(4)
  set status(Notification_Status value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isLocal => $_getBF(3);
  @$pb.TagNumber(5)
  set isLocal($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(5)
  $core.bool hasIsLocal() => $_has(3);
  @$pb.TagNumber(5)
  void clearIsLocal() => $_clearField(5);

  @$pb.TagNumber(6)
  Notification_Import get import => $_getN(4);
  @$pb.TagNumber(6)
  set import(Notification_Import value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasImport() => $_has(4);
  @$pb.TagNumber(6)
  void clearImport() => $_clearField(6);
  @$pb.TagNumber(6)
  Notification_Import ensureImport() => $_ensure(4);

  @$pb.TagNumber(7)
  $core.String get space => $_getSZ(5);
  @$pb.TagNumber(7)
  set space($core.String value) => $_setString(5, value);
  @$pb.TagNumber(7)
  $core.bool hasSpace() => $_has(5);
  @$pb.TagNumber(7)
  void clearSpace() => $_clearField(7);

  @$pb.TagNumber(8)
  Notification_Export get export => $_getN(6);
  @$pb.TagNumber(8)
  set export(Notification_Export value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasExport() => $_has(6);
  @$pb.TagNumber(8)
  void clearExport() => $_clearField(8);
  @$pb.TagNumber(8)
  Notification_Export ensureExport() => $_ensure(6);

  @$pb.TagNumber(9)
  Notification_GalleryImport get galleryImport => $_getN(7);
  @$pb.TagNumber(9)
  set galleryImport(Notification_GalleryImport value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasGalleryImport() => $_has(7);
  @$pb.TagNumber(9)
  void clearGalleryImport() => $_clearField(9);
  @$pb.TagNumber(9)
  Notification_GalleryImport ensureGalleryImport() => $_ensure(7);

  @$pb.TagNumber(10)
  Notification_RequestToJoin get requestToJoin => $_getN(8);
  @$pb.TagNumber(10)
  set requestToJoin(Notification_RequestToJoin value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasRequestToJoin() => $_has(8);
  @$pb.TagNumber(10)
  void clearRequestToJoin() => $_clearField(10);
  @$pb.TagNumber(10)
  Notification_RequestToJoin ensureRequestToJoin() => $_ensure(8);

  @$pb.TagNumber(11)
  Notification_Test get test => $_getN(9);
  @$pb.TagNumber(11)
  set test(Notification_Test value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasTest() => $_has(9);
  @$pb.TagNumber(11)
  void clearTest() => $_clearField(11);
  @$pb.TagNumber(11)
  Notification_Test ensureTest() => $_ensure(9);

  @$pb.TagNumber(13)
  Notification_ParticipantRequestApproved get participantRequestApproved =>
      $_getN(10);
  @$pb.TagNumber(13)
  set participantRequestApproved(
          Notification_ParticipantRequestApproved value) =>
      $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasParticipantRequestApproved() => $_has(10);
  @$pb.TagNumber(13)
  void clearParticipantRequestApproved() => $_clearField(13);
  @$pb.TagNumber(13)
  Notification_ParticipantRequestApproved ensureParticipantRequestApproved() =>
      $_ensure(10);

  @$pb.TagNumber(14)
  $core.String get aclHeadId => $_getSZ(11);
  @$pb.TagNumber(14)
  set aclHeadId($core.String value) => $_setString(11, value);
  @$pb.TagNumber(14)
  $core.bool hasAclHeadId() => $_has(11);
  @$pb.TagNumber(14)
  void clearAclHeadId() => $_clearField(14);

  @$pb.TagNumber(15)
  Notification_RequestToLeave get requestToLeave => $_getN(12);
  @$pb.TagNumber(15)
  set requestToLeave(Notification_RequestToLeave value) =>
      $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasRequestToLeave() => $_has(12);
  @$pb.TagNumber(15)
  void clearRequestToLeave() => $_clearField(15);
  @$pb.TagNumber(15)
  Notification_RequestToLeave ensureRequestToLeave() => $_ensure(12);

  @$pb.TagNumber(16)
  Notification_ParticipantRemove get participantRemove => $_getN(13);
  @$pb.TagNumber(16)
  set participantRemove(Notification_ParticipantRemove value) =>
      $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasParticipantRemove() => $_has(13);
  @$pb.TagNumber(16)
  void clearParticipantRemove() => $_clearField(16);
  @$pb.TagNumber(16)
  Notification_ParticipantRemove ensureParticipantRemove() => $_ensure(13);

  @$pb.TagNumber(17)
  Notification_ParticipantRequestDecline get participantRequestDecline =>
      $_getN(14);
  @$pb.TagNumber(17)
  set participantRequestDecline(Notification_ParticipantRequestDecline value) =>
      $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasParticipantRequestDecline() => $_has(14);
  @$pb.TagNumber(17)
  void clearParticipantRequestDecline() => $_clearField(17);
  @$pb.TagNumber(17)
  Notification_ParticipantRequestDecline ensureParticipantRequestDecline() =>
      $_ensure(14);

  @$pb.TagNumber(18)
  Notification_ParticipantPermissionsChange get participantPermissionsChange =>
      $_getN(15);
  @$pb.TagNumber(18)
  set participantPermissionsChange(
          Notification_ParticipantPermissionsChange value) =>
      $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasParticipantPermissionsChange() => $_has(15);
  @$pb.TagNumber(18)
  void clearParticipantPermissionsChange() => $_clearField(18);
  @$pb.TagNumber(18)
  Notification_ParticipantPermissionsChange
      ensureParticipantPermissionsChange() => $_ensure(15);
}

class Export extends $pb.GeneratedMessage {
  factory Export() => create();

  Export._();

  factory Export.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Export.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Export',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Export clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Export copyWith(void Function(Export) updates) =>
      super.copyWith((message) => updates(message as Export)) as Export;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Export create() => Export._();
  @$core.override
  Export createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Export getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Export>(create);
  static Export? _defaultInstance;
}

class Import extends $pb.GeneratedMessage {
  factory Import() => create();

  Import._();

  factory Import.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Import.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Import',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Import clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Import copyWith(void Function(Import) updates) =>
      super.copyWith((message) => updates(message as Import)) as Import;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Import create() => Import._();
  @$core.override
  Import createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Import getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Import>(create);
  static Import? _defaultInstance;
}

class Invite extends $pb.GeneratedMessage {
  factory Invite({
    $core.List<$core.int>? payload,
    $core.List<$core.int>? signature,
  }) {
    final result = create();
    if (payload != null) result.payload = payload;
    if (signature != null) result.signature = signature;
    return result;
  }

  Invite._();

  factory Invite.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Invite.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Invite',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'signature', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Invite clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Invite copyWith(void Function(Invite) updates) =>
      super.copyWith((message) => updates(message as Invite)) as Invite;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Invite create() => Invite._();
  @$core.override
  Invite createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Invite getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Invite>(create);
  static Invite? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get payload => $_getN(0);
  @$pb.TagNumber(1)
  set payload($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPayload() => $_has(0);
  @$pb.TagNumber(1)
  void clearPayload() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get signature => $_getN(1);
  @$pb.TagNumber(2)
  set signature($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignature() => $_clearField(2);
}

class InvitePayload extends $pb.GeneratedMessage {
  factory InvitePayload({
    $core.String? creatorIdentity,
    $core.String? creatorName,
    $core.List<$core.int>? aclKey,
    $core.String? spaceId,
    $core.String? spaceName,
    $core.String? spaceIconCid,
    $core.Iterable<FileEncryptionKey>? spaceIconEncryptionKeys,
    InviteType? inviteType,
    $core.List<$core.int>? guestKey,
    $core.int? spaceIconOption,
    $core.int? spaceUxType,
    $core.String? creatorIconCid,
    $core.Iterable<FileEncryptionKey>? creatorIconEncryptionKeys,
    $core.int? spaceType,
  }) {
    final result = create();
    if (creatorIdentity != null) result.creatorIdentity = creatorIdentity;
    if (creatorName != null) result.creatorName = creatorName;
    if (aclKey != null) result.aclKey = aclKey;
    if (spaceId != null) result.spaceId = spaceId;
    if (spaceName != null) result.spaceName = spaceName;
    if (spaceIconCid != null) result.spaceIconCid = spaceIconCid;
    if (spaceIconEncryptionKeys != null)
      result.spaceIconEncryptionKeys.addAll(spaceIconEncryptionKeys);
    if (inviteType != null) result.inviteType = inviteType;
    if (guestKey != null) result.guestKey = guestKey;
    if (spaceIconOption != null) result.spaceIconOption = spaceIconOption;
    if (spaceUxType != null) result.spaceUxType = spaceUxType;
    if (creatorIconCid != null) result.creatorIconCid = creatorIconCid;
    if (creatorIconEncryptionKeys != null)
      result.creatorIconEncryptionKeys.addAll(creatorIconEncryptionKeys);
    if (spaceType != null) result.spaceType = spaceType;
    return result;
  }

  InvitePayload._();

  factory InvitePayload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InvitePayload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InvitePayload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'creatorIdentity',
        protoName: 'creatorIdentity')
    ..aOS(2, _omitFieldNames ? '' : 'creatorName', protoName: 'creatorName')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'aclKey', $pb.PbFieldType.OY,
        protoName: 'aclKey')
    ..aOS(4, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..aOS(5, _omitFieldNames ? '' : 'spaceName', protoName: 'spaceName')
    ..aOS(6, _omitFieldNames ? '' : 'spaceIconCid', protoName: 'spaceIconCid')
    ..pPM<FileEncryptionKey>(
        7, _omitFieldNames ? '' : 'spaceIconEncryptionKeys',
        protoName: 'spaceIconEncryptionKeys',
        subBuilder: FileEncryptionKey.create)
    ..aE<InviteType>(8, _omitFieldNames ? '' : 'inviteType',
        protoName: 'inviteType', enumValues: InviteType.values)
    ..a<$core.List<$core.int>>(
        9, _omitFieldNames ? '' : 'guestKey', $pb.PbFieldType.OY,
        protoName: 'guestKey')
    ..aI(10, _omitFieldNames ? '' : 'spaceIconOption',
        protoName: 'spaceIconOption', fieldType: $pb.PbFieldType.OU3)
    ..aI(11, _omitFieldNames ? '' : 'spaceUxType',
        protoName: 'spaceUxType', fieldType: $pb.PbFieldType.OU3)
    ..aOS(12, _omitFieldNames ? '' : 'creatorIconCid',
        protoName: 'creatorIconCid')
    ..pPM<FileEncryptionKey>(
        13, _omitFieldNames ? '' : 'creatorIconEncryptionKeys',
        protoName: 'creatorIconEncryptionKeys',
        subBuilder: FileEncryptionKey.create)
    ..aI(14, _omitFieldNames ? '' : 'spaceType',
        protoName: 'spaceType', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitePayload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InvitePayload copyWith(void Function(InvitePayload) updates) =>
      super.copyWith((message) => updates(message as InvitePayload))
          as InvitePayload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InvitePayload create() => InvitePayload._();
  @$core.override
  InvitePayload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InvitePayload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InvitePayload>(create);
  static InvitePayload? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get creatorIdentity => $_getSZ(0);
  @$pb.TagNumber(1)
  set creatorIdentity($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCreatorIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearCreatorIdentity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get creatorName => $_getSZ(1);
  @$pb.TagNumber(2)
  set creatorName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCreatorName() => $_has(1);
  @$pb.TagNumber(2)
  void clearCreatorName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get aclKey => $_getN(2);
  @$pb.TagNumber(3)
  set aclKey($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAclKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearAclKey() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get spaceId => $_getSZ(3);
  @$pb.TagNumber(4)
  set spaceId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSpaceId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSpaceId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get spaceName => $_getSZ(4);
  @$pb.TagNumber(5)
  set spaceName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSpaceName() => $_has(4);
  @$pb.TagNumber(5)
  void clearSpaceName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get spaceIconCid => $_getSZ(5);
  @$pb.TagNumber(6)
  set spaceIconCid($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSpaceIconCid() => $_has(5);
  @$pb.TagNumber(6)
  void clearSpaceIconCid() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<FileEncryptionKey> get spaceIconEncryptionKeys => $_getList(6);

  @$pb.TagNumber(8)
  InviteType get inviteType => $_getN(7);
  @$pb.TagNumber(8)
  set inviteType(InviteType value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasInviteType() => $_has(7);
  @$pb.TagNumber(8)
  void clearInviteType() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.List<$core.int> get guestKey => $_getN(8);
  @$pb.TagNumber(9)
  set guestKey($core.List<$core.int> value) => $_setBytes(8, value);
  @$pb.TagNumber(9)
  $core.bool hasGuestKey() => $_has(8);
  @$pb.TagNumber(9)
  void clearGuestKey() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get spaceIconOption => $_getIZ(9);
  @$pb.TagNumber(10)
  set spaceIconOption($core.int value) => $_setUnsignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasSpaceIconOption() => $_has(9);
  @$pb.TagNumber(10)
  void clearSpaceIconOption() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get spaceUxType => $_getIZ(10);
  @$pb.TagNumber(11)
  set spaceUxType($core.int value) => $_setUnsignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSpaceUxType() => $_has(10);
  @$pb.TagNumber(11)
  void clearSpaceUxType() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get creatorIconCid => $_getSZ(11);
  @$pb.TagNumber(12)
  set creatorIconCid($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasCreatorIconCid() => $_has(11);
  @$pb.TagNumber(12)
  void clearCreatorIconCid() => $_clearField(12);

  @$pb.TagNumber(13)
  $pb.PbList<FileEncryptionKey> get creatorIconEncryptionKeys => $_getList(12);

  @$pb.TagNumber(14)
  $core.int get spaceType => $_getIZ(13);
  @$pb.TagNumber(14)
  set spaceType($core.int value) => $_setUnsignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasSpaceType() => $_has(13);
  @$pb.TagNumber(14)
  void clearSpaceType() => $_clearField(14);
}

class IdentityProfile extends $pb.GeneratedMessage {
  factory IdentityProfile({
    $core.String? identity,
    $core.String? name,
    $core.String? iconCid,
    $core.Iterable<FileEncryptionKey>? iconEncryptionKeys,
    $core.String? description,
    $core.String? globalName,
  }) {
    final result = create();
    if (identity != null) result.identity = identity;
    if (name != null) result.name = name;
    if (iconCid != null) result.iconCid = iconCid;
    if (iconEncryptionKeys != null)
      result.iconEncryptionKeys.addAll(iconEncryptionKeys);
    if (description != null) result.description = description;
    if (globalName != null) result.globalName = globalName;
    return result;
  }

  IdentityProfile._();

  factory IdentityProfile.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IdentityProfile.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IdentityProfile',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'identity')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'iconCid', protoName: 'iconCid')
    ..pPM<FileEncryptionKey>(4, _omitFieldNames ? '' : 'iconEncryptionKeys',
        protoName: 'iconEncryptionKeys', subBuilder: FileEncryptionKey.create)
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..aOS(6, _omitFieldNames ? '' : 'globalName', protoName: 'globalName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IdentityProfile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IdentityProfile copyWith(void Function(IdentityProfile) updates) =>
      super.copyWith((message) => updates(message as IdentityProfile))
          as IdentityProfile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IdentityProfile create() => IdentityProfile._();
  @$core.override
  IdentityProfile createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IdentityProfile getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IdentityProfile>(create);
  static IdentityProfile? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get identity => $_getSZ(0);
  @$pb.TagNumber(1)
  set identity($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentity() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get iconCid => $_getSZ(2);
  @$pb.TagNumber(3)
  set iconCid($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIconCid() => $_has(2);
  @$pb.TagNumber(3)
  void clearIconCid() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<FileEncryptionKey> get iconEncryptionKeys => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get globalName => $_getSZ(5);
  @$pb.TagNumber(6)
  set globalName($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasGlobalName() => $_has(5);
  @$pb.TagNumber(6)
  void clearGlobalName() => $_clearField(6);
}

class IdentityProfileWithKey extends $pb.GeneratedMessage {
  factory IdentityProfileWithKey({
    IdentityProfile? identityProfile,
    $core.List<$core.int>? requestMetadata,
  }) {
    final result = create();
    if (identityProfile != null) result.identityProfile = identityProfile;
    if (requestMetadata != null) result.requestMetadata = requestMetadata;
    return result;
  }

  IdentityProfileWithKey._();

  factory IdentityProfileWithKey.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IdentityProfileWithKey.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IdentityProfileWithKey',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOM<IdentityProfile>(1, _omitFieldNames ? '' : 'identityProfile',
        protoName: 'identityProfile', subBuilder: IdentityProfile.create)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'requestMetadata', $pb.PbFieldType.OY,
        protoName: 'requestMetadata')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IdentityProfileWithKey clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IdentityProfileWithKey copyWith(
          void Function(IdentityProfileWithKey) updates) =>
      super.copyWith((message) => updates(message as IdentityProfileWithKey))
          as IdentityProfileWithKey;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IdentityProfileWithKey create() => IdentityProfileWithKey._();
  @$core.override
  IdentityProfileWithKey createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IdentityProfileWithKey getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IdentityProfileWithKey>(create);
  static IdentityProfileWithKey? _defaultInstance;

  @$pb.TagNumber(1)
  IdentityProfile get identityProfile => $_getN(0);
  @$pb.TagNumber(1)
  set identityProfile(IdentityProfile value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentityProfile() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentityProfile() => $_clearField(1);
  @$pb.TagNumber(1)
  IdentityProfile ensureIdentityProfile() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<$core.int> get requestMetadata => $_getN(1);
  @$pb.TagNumber(2)
  set requestMetadata($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRequestMetadata() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequestMetadata() => $_clearField(2);
}

class FileInfo extends $pb.GeneratedMessage {
  factory FileInfo({
    $core.String? fileId,
    $core.Iterable<FileEncryptionKey>? encryptionKeys,
  }) {
    final result = create();
    if (fileId != null) result.fileId = fileId;
    if (encryptionKeys != null) result.encryptionKeys.addAll(encryptionKeys);
    return result;
  }

  FileInfo._();

  factory FileInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FileInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fileId', protoName: 'fileId')
    ..pPM<FileEncryptionKey>(2, _omitFieldNames ? '' : 'encryptionKeys',
        protoName: 'encryptionKeys', subBuilder: FileEncryptionKey.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileInfo copyWith(void Function(FileInfo) updates) =>
      super.copyWith((message) => updates(message as FileInfo)) as FileInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileInfo create() => FileInfo._();
  @$core.override
  FileInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FileInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FileInfo>(create);
  static FileInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fileId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fileId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFileId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFileId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<FileEncryptionKey> get encryptionKeys => $_getList(1);
}

class FileEncryptionKey extends $pb.GeneratedMessage {
  factory FileEncryptionKey({
    $core.String? path,
    $core.String? key,
  }) {
    final result = create();
    if (path != null) result.path = path;
    if (key != null) result.key = key;
    return result;
  }

  FileEncryptionKey._();

  factory FileEncryptionKey.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FileEncryptionKey.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileEncryptionKey',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..aOS(2, _omitFieldNames ? '' : 'key')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileEncryptionKey clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileEncryptionKey copyWith(void Function(FileEncryptionKey) updates) =>
      super.copyWith((message) => updates(message as FileEncryptionKey))
          as FileEncryptionKey;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileEncryptionKey create() => FileEncryptionKey._();
  @$core.override
  FileEncryptionKey createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FileEncryptionKey getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FileEncryptionKey>(create);
  static FileEncryptionKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get key => $_getSZ(1);
  @$pb.TagNumber(2)
  set key($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearKey() => $_clearField(2);
}

class ManifestInfo extends $pb.GeneratedMessage {
  factory ManifestInfo({
    $core.String? schema,
    $core.String? id,
    $core.String? name,
    $core.String? author,
    $core.String? license,
    $core.String? title,
    $core.String? description,
    $core.Iterable<$core.String>? screenshots,
    $core.String? downloadLink,
    $core.int? fileSize,
    $core.Iterable<$core.String>? categories,
    $core.String? language,
  }) {
    final result = create();
    if (schema != null) result.schema = schema;
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (author != null) result.author = author;
    if (license != null) result.license = license;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (screenshots != null) result.screenshots.addAll(screenshots);
    if (downloadLink != null) result.downloadLink = downloadLink;
    if (fileSize != null) result.fileSize = fileSize;
    if (categories != null) result.categories.addAll(categories);
    if (language != null) result.language = language;
    return result;
  }

  ManifestInfo._();

  factory ManifestInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ManifestInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ManifestInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : '\$schema', protoName: 'schema')
    ..aOS(2, _omitFieldNames ? '' : 'id')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'author')
    ..aOS(5, _omitFieldNames ? '' : 'license')
    ..aOS(6, _omitFieldNames ? '' : 'title')
    ..aOS(7, _omitFieldNames ? '' : 'description')
    ..pPS(8, _omitFieldNames ? '' : 'screenshots')
    ..aOS(9, _omitFieldNames ? '' : 'downloadLink', protoName: 'downloadLink')
    ..aI(10, _omitFieldNames ? '' : 'fileSize', protoName: 'fileSize')
    ..pPS(11, _omitFieldNames ? '' : 'categories')
    ..aOS(12, _omitFieldNames ? '' : 'language')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ManifestInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ManifestInfo copyWith(void Function(ManifestInfo) updates) =>
      super.copyWith((message) => updates(message as ManifestInfo))
          as ManifestInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ManifestInfo create() => ManifestInfo._();
  @$core.override
  ManifestInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ManifestInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ManifestInfo>(create);
  static ManifestInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get schema => $_getSZ(0);
  @$pb.TagNumber(1)
  set schema($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSchema() => $_has(0);
  @$pb.TagNumber(1)
  void clearSchema() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get id => $_getSZ(1);
  @$pb.TagNumber(2)
  set id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get author => $_getSZ(3);
  @$pb.TagNumber(4)
  set author($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAuthor() => $_has(3);
  @$pb.TagNumber(4)
  void clearAuthor() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get license => $_getSZ(4);
  @$pb.TagNumber(5)
  set license($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLicense() => $_has(4);
  @$pb.TagNumber(5)
  void clearLicense() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get title => $_getSZ(5);
  @$pb.TagNumber(6)
  set title($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTitle() => $_has(5);
  @$pb.TagNumber(6)
  void clearTitle() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get description => $_getSZ(6);
  @$pb.TagNumber(7)
  set description($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDescription() => $_has(6);
  @$pb.TagNumber(7)
  void clearDescription() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get screenshots => $_getList(7);

  @$pb.TagNumber(9)
  $core.String get downloadLink => $_getSZ(8);
  @$pb.TagNumber(9)
  set downloadLink($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDownloadLink() => $_has(8);
  @$pb.TagNumber(9)
  void clearDownloadLink() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get fileSize => $_getIZ(9);
  @$pb.TagNumber(10)
  set fileSize($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasFileSize() => $_has(9);
  @$pb.TagNumber(10)
  void clearFileSize() => $_clearField(10);

  @$pb.TagNumber(11)
  $pb.PbList<$core.String> get categories => $_getList(10);

  @$pb.TagNumber(12)
  $core.String get language => $_getSZ(11);
  @$pb.TagNumber(12)
  set language($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasLanguage() => $_has(11);
  @$pb.TagNumber(12)
  void clearLanguage() => $_clearField(12);
}

class Membership extends $pb.GeneratedMessage {
  factory Membership({
    $core.int? tier,
    Membership_Status? status,
    $fixnum.Int64? dateStarted,
    $fixnum.Int64? dateEnds,
    $core.bool? isAutoRenew,
    Membership_PaymentMethod? paymentMethod,
    $core.String? nsName,
    NameserviceNameType? nsNameType,
    $core.String? userEmail,
    $core.bool? subscribeToNewsletter,
  }) {
    final result = create();
    if (tier != null) result.tier = tier;
    if (status != null) result.status = status;
    if (dateStarted != null) result.dateStarted = dateStarted;
    if (dateEnds != null) result.dateEnds = dateEnds;
    if (isAutoRenew != null) result.isAutoRenew = isAutoRenew;
    if (paymentMethod != null) result.paymentMethod = paymentMethod;
    if (nsName != null) result.nsName = nsName;
    if (nsNameType != null) result.nsNameType = nsNameType;
    if (userEmail != null) result.userEmail = userEmail;
    if (subscribeToNewsletter != null)
      result.subscribeToNewsletter = subscribeToNewsletter;
    return result;
  }

  Membership._();

  factory Membership.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Membership.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Membership',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'tier', fieldType: $pb.PbFieldType.OU3)
    ..aE<Membership_Status>(2, _omitFieldNames ? '' : 'status',
        enumValues: Membership_Status.values)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'dateStarted', $pb.PbFieldType.OU6,
        protoName: 'dateStarted', defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'dateEnds', $pb.PbFieldType.OU6,
        protoName: 'dateEnds', defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(5, _omitFieldNames ? '' : 'isAutoRenew', protoName: 'isAutoRenew')
    ..aE<Membership_PaymentMethod>(6, _omitFieldNames ? '' : 'paymentMethod',
        protoName: 'paymentMethod', enumValues: Membership_PaymentMethod.values)
    ..aOS(7, _omitFieldNames ? '' : 'nsName', protoName: 'nsName')
    ..aE<NameserviceNameType>(8, _omitFieldNames ? '' : 'nsNameType',
        protoName: 'nsNameType', enumValues: NameserviceNameType.values)
    ..aOS(9, _omitFieldNames ? '' : 'userEmail', protoName: 'userEmail')
    ..aOB(10, _omitFieldNames ? '' : 'subscribeToNewsletter',
        protoName: 'subscribeToNewsletter')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Membership clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Membership copyWith(void Function(Membership) updates) =>
      super.copyWith((message) => updates(message as Membership)) as Membership;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Membership create() => Membership._();
  @$core.override
  Membership createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Membership getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Membership>(create);
  static Membership? _defaultInstance;

  /// it was Tier before, changed to int32 to allow dynamic values
  @$pb.TagNumber(1)
  $core.int get tier => $_getIZ(0);
  @$pb.TagNumber(1)
  set tier($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTier() => $_has(0);
  @$pb.TagNumber(1)
  void clearTier() => $_clearField(1);

  @$pb.TagNumber(2)
  Membership_Status get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(Membership_Status value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get dateStarted => $_getI64(2);
  @$pb.TagNumber(3)
  set dateStarted($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDateStarted() => $_has(2);
  @$pb.TagNumber(3)
  void clearDateStarted() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get dateEnds => $_getI64(3);
  @$pb.TagNumber(4)
  set dateEnds($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDateEnds() => $_has(3);
  @$pb.TagNumber(4)
  void clearDateEnds() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isAutoRenew => $_getBF(4);
  @$pb.TagNumber(5)
  set isAutoRenew($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsAutoRenew() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsAutoRenew() => $_clearField(5);

  @$pb.TagNumber(6)
  Membership_PaymentMethod get paymentMethod => $_getN(5);
  @$pb.TagNumber(6)
  set paymentMethod(Membership_PaymentMethod value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasPaymentMethod() => $_has(5);
  @$pb.TagNumber(6)
  void clearPaymentMethod() => $_clearField(6);

  /// can be empty if user did not ask for any name
  @$pb.TagNumber(7)
  $core.String get nsName => $_getSZ(6);
  @$pb.TagNumber(7)
  set nsName($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNsName() => $_has(6);
  @$pb.TagNumber(7)
  void clearNsName() => $_clearField(7);

  @$pb.TagNumber(8)
  NameserviceNameType get nsNameType => $_getN(7);
  @$pb.TagNumber(8)
  set nsNameType(NameserviceNameType value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasNsNameType() => $_has(7);
  @$pb.TagNumber(8)
  void clearNsNameType() => $_clearField(8);

  /// if the email was verified by the user or set during the checkout - it will be here
  @$pb.TagNumber(9)
  $core.String get userEmail => $_getSZ(8);
  @$pb.TagNumber(9)
  set userEmail($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasUserEmail() => $_has(8);
  @$pb.TagNumber(9)
  void clearUserEmail() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get subscribeToNewsletter => $_getBF(9);
  @$pb.TagNumber(10)
  set subscribeToNewsletter($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasSubscribeToNewsletter() => $_has(9);
  @$pb.TagNumber(10)
  void clearSubscribeToNewsletter() => $_clearField(10);
}

class MembershipTierData extends $pb.GeneratedMessage {
  factory MembershipTierData({
    $core.int? id,
    $core.String? name,
    $core.String? description,
    $core.bool? isTest,
    MembershipTierData_PeriodType? periodType,
    $core.int? periodValue,
    $core.int? priceStripeUsdCents,
    $core.int? anyNamesCountIncluded,
    $core.int? anyNameMinLength,
    $core.Iterable<$core.String>? features,
    $core.String? colorStr,
    $core.String? stripeProductId,
    $core.String? stripeManageUrl,
    $core.String? iosProductId,
    $core.String? iosManageUrl,
    $core.String? androidProductId,
    $core.String? androidManageUrl,
    $core.String? offer,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (isTest != null) result.isTest = isTest;
    if (periodType != null) result.periodType = periodType;
    if (periodValue != null) result.periodValue = periodValue;
    if (priceStripeUsdCents != null)
      result.priceStripeUsdCents = priceStripeUsdCents;
    if (anyNamesCountIncluded != null)
      result.anyNamesCountIncluded = anyNamesCountIncluded;
    if (anyNameMinLength != null) result.anyNameMinLength = anyNameMinLength;
    if (features != null) result.features.addAll(features);
    if (colorStr != null) result.colorStr = colorStr;
    if (stripeProductId != null) result.stripeProductId = stripeProductId;
    if (stripeManageUrl != null) result.stripeManageUrl = stripeManageUrl;
    if (iosProductId != null) result.iosProductId = iosProductId;
    if (iosManageUrl != null) result.iosManageUrl = iosManageUrl;
    if (androidProductId != null) result.androidProductId = androidProductId;
    if (androidManageUrl != null) result.androidManageUrl = androidManageUrl;
    if (offer != null) result.offer = offer;
    return result;
  }

  MembershipTierData._();

  factory MembershipTierData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MembershipTierData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipTierData',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOB(4, _omitFieldNames ? '' : 'isTest', protoName: 'isTest')
    ..aE<MembershipTierData_PeriodType>(5, _omitFieldNames ? '' : 'periodType',
        protoName: 'periodType',
        enumValues: MembershipTierData_PeriodType.values)
    ..aI(6, _omitFieldNames ? '' : 'periodValue',
        protoName: 'periodValue', fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'priceStripeUsdCents',
        protoName: 'priceStripeUsdCents', fieldType: $pb.PbFieldType.OU3)
    ..aI(8, _omitFieldNames ? '' : 'anyNamesCountIncluded',
        protoName: 'anyNamesCountIncluded', fieldType: $pb.PbFieldType.OU3)
    ..aI(9, _omitFieldNames ? '' : 'anyNameMinLength',
        protoName: 'anyNameMinLength', fieldType: $pb.PbFieldType.OU3)
    ..pPS(10, _omitFieldNames ? '' : 'features')
    ..aOS(11, _omitFieldNames ? '' : 'colorStr', protoName: 'colorStr')
    ..aOS(12, _omitFieldNames ? '' : 'stripeProductId',
        protoName: 'stripeProductId')
    ..aOS(13, _omitFieldNames ? '' : 'stripeManageUrl',
        protoName: 'stripeManageUrl')
    ..aOS(15, _omitFieldNames ? '' : 'iosProductId', protoName: 'iosProductId')
    ..aOS(16, _omitFieldNames ? '' : 'iosManageUrl', protoName: 'iosManageUrl')
    ..aOS(17, _omitFieldNames ? '' : 'androidProductId',
        protoName: 'androidProductId')
    ..aOS(18, _omitFieldNames ? '' : 'androidManageUrl',
        protoName: 'androidManageUrl')
    ..aOS(19, _omitFieldNames ? '' : 'offer')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipTierData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipTierData copyWith(void Function(MembershipTierData) updates) =>
      super.copyWith((message) => updates(message as MembershipTierData))
          as MembershipTierData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipTierData create() => MembershipTierData._();
  @$core.override
  MembershipTierData createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MembershipTierData getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MembershipTierData>(create);
  static MembershipTierData? _defaultInstance;

  /// this is a unique Payment Node ID of the tier
  /// WARNING: tiers can be sorted differently, not according to their IDs!
  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// localazied name of the tier
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// just a short technical description
  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  /// is this tier for testing and debugging only?
  @$pb.TagNumber(4)
  $core.bool get isTest => $_getBF(3);
  @$pb.TagNumber(4)
  set isTest($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsTest() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsTest() => $_clearField(4);

  /// how long is the period of the subscription
  @$pb.TagNumber(5)
  MembershipTierData_PeriodType get periodType => $_getN(4);
  @$pb.TagNumber(5)
  set periodType(MembershipTierData_PeriodType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasPeriodType() => $_has(4);
  @$pb.TagNumber(5)
  void clearPeriodType() => $_clearField(5);

  /// i.e. "5 days" or "3 years"
  @$pb.TagNumber(6)
  $core.int get periodValue => $_getIZ(5);
  @$pb.TagNumber(6)
  set periodValue($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPeriodValue() => $_has(5);
  @$pb.TagNumber(6)
  void clearPeriodValue() => $_clearField(6);

  /// this one is a price we use ONLY on Stripe platform
  @$pb.TagNumber(7)
  $core.int get priceStripeUsdCents => $_getIZ(6);
  @$pb.TagNumber(7)
  set priceStripeUsdCents($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPriceStripeUsdCents() => $_has(6);
  @$pb.TagNumber(7)
  void clearPriceStripeUsdCents() => $_clearField(7);

  /// number of ANY NS names that this tier includes
  /// also in the "features" list (see below)
  @$pb.TagNumber(8)
  $core.int get anyNamesCountIncluded => $_getIZ(7);
  @$pb.TagNumber(8)
  set anyNamesCountIncluded($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAnyNamesCountIncluded() => $_has(7);
  @$pb.TagNumber(8)
  void clearAnyNamesCountIncluded() => $_clearField(8);

  /// somename.any - is of len 8
  @$pb.TagNumber(9)
  $core.int get anyNameMinLength => $_getIZ(8);
  @$pb.TagNumber(9)
  set anyNameMinLength($core.int value) => $_setUnsignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasAnyNameMinLength() => $_has(8);
  @$pb.TagNumber(9)
  void clearAnyNameMinLength() => $_clearField(9);

  /// localized strings for the features
  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get features => $_getList(9);

  /// green, blue, red, purple, custom
  @$pb.TagNumber(11)
  $core.String get colorStr => $_getSZ(10);
  @$pb.TagNumber(11)
  set colorStr($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasColorStr() => $_has(10);
  @$pb.TagNumber(11)
  void clearColorStr() => $_clearField(11);

  /// Stripe platform-specific data:
  @$pb.TagNumber(12)
  $core.String get stripeProductId => $_getSZ(11);
  @$pb.TagNumber(12)
  set stripeProductId($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasStripeProductId() => $_has(11);
  @$pb.TagNumber(12)
  void clearStripeProductId() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get stripeManageUrl => $_getSZ(12);
  @$pb.TagNumber(13)
  set stripeManageUrl($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasStripeManageUrl() => $_has(12);
  @$pb.TagNumber(13)
  void clearStripeManageUrl() => $_clearField(13);

  /// iOS platform-specific data:
  @$pb.TagNumber(15)
  $core.String get iosProductId => $_getSZ(13);
  @$pb.TagNumber(15)
  set iosProductId($core.String value) => $_setString(13, value);
  @$pb.TagNumber(15)
  $core.bool hasIosProductId() => $_has(13);
  @$pb.TagNumber(15)
  void clearIosProductId() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get iosManageUrl => $_getSZ(14);
  @$pb.TagNumber(16)
  set iosManageUrl($core.String value) => $_setString(14, value);
  @$pb.TagNumber(16)
  $core.bool hasIosManageUrl() => $_has(14);
  @$pb.TagNumber(16)
  void clearIosManageUrl() => $_clearField(16);

  /// Android platform-specific data:
  @$pb.TagNumber(17)
  $core.String get androidProductId => $_getSZ(15);
  @$pb.TagNumber(17)
  set androidProductId($core.String value) => $_setString(15, value);
  @$pb.TagNumber(17)
  $core.bool hasAndroidProductId() => $_has(15);
  @$pb.TagNumber(17)
  void clearAndroidProductId() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.String get androidManageUrl => $_getSZ(16);
  @$pb.TagNumber(18)
  set androidManageUrl($core.String value) => $_setString(16, value);
  @$pb.TagNumber(18)
  $core.bool hasAndroidManageUrl() => $_has(16);
  @$pb.TagNumber(18)
  void clearAndroidManageUrl() => $_clearField(18);

  /// "limited offer" or somehing like that
  @$pb.TagNumber(19)
  $core.String get offer => $_getSZ(17);
  @$pb.TagNumber(19)
  set offer($core.String value) => $_setString(17, value);
  @$pb.TagNumber(19)
  $core.bool hasOffer() => $_has(17);
  @$pb.TagNumber(19)
  void clearOffer() => $_clearField(19);
}

class MembershipV2_Amount extends $pb.GeneratedMessage {
  factory MembershipV2_Amount({
    $core.String? currency,
    $fixnum.Int64? amountCents,
  }) {
    final result = create();
    if (currency != null) result.currency = currency;
    if (amountCents != null) result.amountCents = amountCents;
    return result;
  }

  MembershipV2_Amount._();

  factory MembershipV2_Amount.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MembershipV2_Amount.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipV2.Amount',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'currency')
    ..aInt64(2, _omitFieldNames ? '' : 'amountCents', protoName: 'amountCents')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_Amount clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_Amount copyWith(void Function(MembershipV2_Amount) updates) =>
      super.copyWith((message) => updates(message as MembershipV2_Amount))
          as MembershipV2_Amount;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipV2_Amount create() => MembershipV2_Amount._();
  @$core.override
  MembershipV2_Amount createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MembershipV2_Amount getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MembershipV2_Amount>(create);
  static MembershipV2_Amount? _defaultInstance;

  /// ISO 4217 currency code
  @$pb.TagNumber(1)
  $core.String get currency => $_getSZ(0);
  @$pb.TagNumber(1)
  set currency($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCurrency() => $_has(0);
  @$pb.TagNumber(1)
  void clearCurrency() => $_clearField(1);

  /// $0.01 = 1
  /// $1.00 = 100
  /// also supports negative amounts!
  /// some invoices can have negatice amount (refund)
  @$pb.TagNumber(2)
  $fixnum.Int64 get amountCents => $_getI64(1);
  @$pb.TagNumber(2)
  set amountCents($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmountCents() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmountCents() => $_clearField(2);
}

class MembershipV2_Invoice extends $pb.GeneratedMessage {
  factory MembershipV2_Invoice({
    $fixnum.Int64? date,
    MembershipV2_Amount? total,
  }) {
    final result = create();
    if (date != null) result.date = date;
    if (total != null) result.total = total;
    return result;
  }

  MembershipV2_Invoice._();

  factory MembershipV2_Invoice.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MembershipV2_Invoice.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipV2.Invoice',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'date', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<MembershipV2_Amount>(2, _omitFieldNames ? '' : 'total',
        subBuilder: MembershipV2_Amount.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_Invoice clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_Invoice copyWith(void Function(MembershipV2_Invoice) updates) =>
      super.copyWith((message) => updates(message as MembershipV2_Invoice))
          as MembershipV2_Invoice;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipV2_Invoice create() => MembershipV2_Invoice._();
  @$core.override
  MembershipV2_Invoice createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MembershipV2_Invoice getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MembershipV2_Invoice>(create);
  static MembershipV2_Invoice? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get date => $_getI64(0);
  @$pb.TagNumber(1)
  set date($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => $_clearField(1);

  @$pb.TagNumber(2)
  MembershipV2_Amount get total => $_getN(1);
  @$pb.TagNumber(2)
  set total(MembershipV2_Amount value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);
  @$pb.TagNumber(2)
  MembershipV2_Amount ensureTotal() => $_ensure(1);
}

class MembershipV2_Features extends $pb.GeneratedMessage {
  factory MembershipV2_Features({
    $fixnum.Int64? storageBytes,
    $core.int? spaceReaders,
    $core.int? spaceWriters,
    $core.int? sharedSpaces,
    $core.int? teamSeats,
    $core.int? anyNameCount,
    $core.int? anyNameMinLen,
    $core.int? privateSpaces,
  }) {
    final result = create();
    if (storageBytes != null) result.storageBytes = storageBytes;
    if (spaceReaders != null) result.spaceReaders = spaceReaders;
    if (spaceWriters != null) result.spaceWriters = spaceWriters;
    if (sharedSpaces != null) result.sharedSpaces = sharedSpaces;
    if (teamSeats != null) result.teamSeats = teamSeats;
    if (anyNameCount != null) result.anyNameCount = anyNameCount;
    if (anyNameMinLen != null) result.anyNameMinLen = anyNameMinLen;
    if (privateSpaces != null) result.privateSpaces = privateSpaces;
    return result;
  }

  MembershipV2_Features._();

  factory MembershipV2_Features.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MembershipV2_Features.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipV2.Features',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'storageBytes', $pb.PbFieldType.OU6,
        protoName: 'storageBytes', defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(2, _omitFieldNames ? '' : 'spaceReaders',
        protoName: 'spaceReaders', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'spaceWriters',
        protoName: 'spaceWriters', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'sharedSpaces',
        protoName: 'sharedSpaces', fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'teamSeats',
        protoName: 'teamSeats', fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'anyNameCount',
        protoName: 'anyNameCount', fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'anyNameMinLen',
        protoName: 'anyNameMinLen', fieldType: $pb.PbFieldType.OU3)
    ..aI(8, _omitFieldNames ? '' : 'privateSpaces',
        protoName: 'privateSpaces', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_Features clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_Features copyWith(
          void Function(MembershipV2_Features) updates) =>
      super.copyWith((message) => updates(message as MembershipV2_Features))
          as MembershipV2_Features;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipV2_Features create() => MembershipV2_Features._();
  @$core.override
  MembershipV2_Features createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MembershipV2_Features getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MembershipV2_Features>(create);
  static MembershipV2_Features? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get storageBytes => $_getI64(0);
  @$pb.TagNumber(1)
  set storageBytes($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStorageBytes() => $_has(0);
  @$pb.TagNumber(1)
  void clearStorageBytes() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get spaceReaders => $_getIZ(1);
  @$pb.TagNumber(2)
  set spaceReaders($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpaceReaders() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpaceReaders() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get spaceWriters => $_getIZ(2);
  @$pb.TagNumber(3)
  set spaceWriters($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSpaceWriters() => $_has(2);
  @$pb.TagNumber(3)
  void clearSpaceWriters() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get sharedSpaces => $_getIZ(3);
  @$pb.TagNumber(4)
  set sharedSpaces($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSharedSpaces() => $_has(3);
  @$pb.TagNumber(4)
  void clearSharedSpaces() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get teamSeats => $_getIZ(4);
  @$pb.TagNumber(5)
  set teamSeats($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTeamSeats() => $_has(4);
  @$pb.TagNumber(5)
  void clearTeamSeats() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get anyNameCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set anyNameCount($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAnyNameCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearAnyNameCount() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get anyNameMinLen => $_getIZ(6);
  @$pb.TagNumber(7)
  set anyNameMinLen($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAnyNameMinLen() => $_has(6);
  @$pb.TagNumber(7)
  void clearAnyNameMinLen() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get privateSpaces => $_getIZ(7);
  @$pb.TagNumber(8)
  set privateSpaces($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPrivateSpaces() => $_has(7);
  @$pb.TagNumber(8)
  void clearPrivateSpaces() => $_clearField(8);
}

class MembershipV2_Product extends $pb.GeneratedMessage {
  factory MembershipV2_Product({
    $core.String? id,
    $core.String? name,
    $core.String? description,
    $core.bool? isTopLevel,
    $core.bool? isHidden,
    $core.bool? isIntro,
    $core.bool? isUpgradeable,
    $core.Iterable<MembershipV2_Amount>? pricesYearly,
    $core.Iterable<MembershipV2_Amount>? pricesMonthly,
    $core.String? colorStr,
    $core.String? offer,
    MembershipV2_Features? features,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (isTopLevel != null) result.isTopLevel = isTopLevel;
    if (isHidden != null) result.isHidden = isHidden;
    if (isIntro != null) result.isIntro = isIntro;
    if (isUpgradeable != null) result.isUpgradeable = isUpgradeable;
    if (pricesYearly != null) result.pricesYearly.addAll(pricesYearly);
    if (pricesMonthly != null) result.pricesMonthly.addAll(pricesMonthly);
    if (colorStr != null) result.colorStr = colorStr;
    if (offer != null) result.offer = offer;
    if (features != null) result.features = features;
    return result;
  }

  MembershipV2_Product._();

  factory MembershipV2_Product.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MembershipV2_Product.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipV2.Product',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aOB(4, _omitFieldNames ? '' : 'isTopLevel', protoName: 'isTopLevel')
    ..aOB(5, _omitFieldNames ? '' : 'isHidden', protoName: 'isHidden')
    ..aOB(6, _omitFieldNames ? '' : 'isIntro', protoName: 'isIntro')
    ..aOB(7, _omitFieldNames ? '' : 'isUpgradeable', protoName: 'isUpgradeable')
    ..pPM<MembershipV2_Amount>(8, _omitFieldNames ? '' : 'pricesYearly',
        protoName: 'pricesYearly', subBuilder: MembershipV2_Amount.create)
    ..pPM<MembershipV2_Amount>(9, _omitFieldNames ? '' : 'pricesMonthly',
        protoName: 'pricesMonthly', subBuilder: MembershipV2_Amount.create)
    ..aOS(10, _omitFieldNames ? '' : 'colorStr', protoName: 'colorStr')
    ..aOS(11, _omitFieldNames ? '' : 'offer')
    ..aOM<MembershipV2_Features>(12, _omitFieldNames ? '' : 'features',
        subBuilder: MembershipV2_Features.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_Product clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_Product copyWith(void Function(MembershipV2_Product) updates) =>
      super.copyWith((message) => updates(message as MembershipV2_Product))
          as MembershipV2_Product;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipV2_Product create() => MembershipV2_Product._();
  @$core.override
  MembershipV2_Product createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MembershipV2_Product getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MembershipV2_Product>(create);
  static MembershipV2_Product? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isTopLevel => $_getBF(3);
  @$pb.TagNumber(4)
  set isTopLevel($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsTopLevel() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsTopLevel() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isHidden => $_getBF(4);
  @$pb.TagNumber(5)
  set isHidden($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsHidden() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsHidden() => $_clearField(5);

  /// isIntro flag can be used as follows:
  ///
  /// 1. if current user's top level product has isIntro flag ->
  /// then you'd rather show a FULL list of all products
  /// to enable upgrading from CURRENT product
  /// 2. but if current user's top level product has no isIntro flag ->
  /// then it means that this plan was aquired and user need to control it.
  /// then show "second screen" to control that product instead
  @$pb.TagNumber(6)
  $core.bool get isIntro => $_getBF(5);
  @$pb.TagNumber(6)
  set isIntro($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsIntro() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsIntro() => $_clearField(6);

  /// isUpgradeable can be used as follows:
  ///
  /// if current user's top level product has isUpgradeable flag ->
  /// show incentives to buy something else
  @$pb.TagNumber(7)
  $core.bool get isUpgradeable => $_getBF(6);
  @$pb.TagNumber(7)
  set isUpgradeable($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIsUpgradeable() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsUpgradeable() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<MembershipV2_Amount> get pricesYearly => $_getList(7);

  @$pb.TagNumber(9)
  $pb.PbList<MembershipV2_Amount> get pricesMonthly => $_getList(8);

  /// green, blue, red, purple, custom, etc
  @$pb.TagNumber(10)
  $core.String get colorStr => $_getSZ(9);
  @$pb.TagNumber(10)
  set colorStr($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasColorStr() => $_has(9);
  @$pb.TagNumber(10)
  void clearColorStr() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get offer => $_getSZ(10);
  @$pb.TagNumber(11)
  set offer($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasOffer() => $_has(10);
  @$pb.TagNumber(11)
  void clearOffer() => $_clearField(11);

  @$pb.TagNumber(12)
  MembershipV2_Features get features => $_getN(11);
  @$pb.TagNumber(12)
  set features(MembershipV2_Features value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasFeatures() => $_has(11);
  @$pb.TagNumber(12)
  void clearFeatures() => $_clearField(12);
  @$pb.TagNumber(12)
  MembershipV2_Features ensureFeatures() => $_ensure(11);
}

class MembershipV2_PurchaseInfo extends $pb.GeneratedMessage {
  factory MembershipV2_PurchaseInfo({
    $fixnum.Int64? dateStarted,
    $fixnum.Int64? dateEnds,
    $core.bool? isAutoRenew,
    MembershipV2_Period? period,
  }) {
    final result = create();
    if (dateStarted != null) result.dateStarted = dateStarted;
    if (dateEnds != null) result.dateEnds = dateEnds;
    if (isAutoRenew != null) result.isAutoRenew = isAutoRenew;
    if (period != null) result.period = period;
    return result;
  }

  MembershipV2_PurchaseInfo._();

  factory MembershipV2_PurchaseInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MembershipV2_PurchaseInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipV2.PurchaseInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'dateStarted', $pb.PbFieldType.OU6,
        protoName: 'dateStarted', defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'dateEnds', $pb.PbFieldType.OU6,
        protoName: 'dateEnds', defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(3, _omitFieldNames ? '' : 'isAutoRenew', protoName: 'isAutoRenew')
    ..aE<MembershipV2_Period>(4, _omitFieldNames ? '' : 'period',
        enumValues: MembershipV2_Period.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_PurchaseInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_PurchaseInfo copyWith(
          void Function(MembershipV2_PurchaseInfo) updates) =>
      super.copyWith((message) => updates(message as MembershipV2_PurchaseInfo))
          as MembershipV2_PurchaseInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipV2_PurchaseInfo create() => MembershipV2_PurchaseInfo._();
  @$core.override
  MembershipV2_PurchaseInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MembershipV2_PurchaseInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MembershipV2_PurchaseInfo>(create);
  static MembershipV2_PurchaseInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get dateStarted => $_getI64(0);
  @$pb.TagNumber(1)
  set dateStarted($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDateStarted() => $_has(0);
  @$pb.TagNumber(1)
  void clearDateStarted() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get dateEnds => $_getI64(1);
  @$pb.TagNumber(2)
  set dateEnds($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDateEnds() => $_has(1);
  @$pb.TagNumber(2)
  void clearDateEnds() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isAutoRenew => $_getBF(2);
  @$pb.TagNumber(3)
  set isAutoRenew($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsAutoRenew() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsAutoRenew() => $_clearField(3);

  @$pb.TagNumber(4)
  MembershipV2_Period get period => $_getN(3);
  @$pb.TagNumber(4)
  set period(MembershipV2_Period value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasPeriod() => $_has(3);
  @$pb.TagNumber(4)
  void clearPeriod() => $_clearField(4);
}

class MembershipV2_ProductStatus extends $pb.GeneratedMessage {
  factory MembershipV2_ProductStatus({
    MembershipV2_ProductStatus_Status? status,
  }) {
    final result = create();
    if (status != null) result.status = status;
    return result;
  }

  MembershipV2_ProductStatus._();

  factory MembershipV2_ProductStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MembershipV2_ProductStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipV2.ProductStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aE<MembershipV2_ProductStatus_Status>(1, _omitFieldNames ? '' : 'status',
        enumValues: MembershipV2_ProductStatus_Status.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_ProductStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_ProductStatus copyWith(
          void Function(MembershipV2_ProductStatus) updates) =>
      super.copyWith(
              (message) => updates(message as MembershipV2_ProductStatus))
          as MembershipV2_ProductStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipV2_ProductStatus create() => MembershipV2_ProductStatus._();
  @$core.override
  MembershipV2_ProductStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MembershipV2_ProductStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MembershipV2_ProductStatus>(create);
  static MembershipV2_ProductStatus? _defaultInstance;

  @$pb.TagNumber(1)
  MembershipV2_ProductStatus_Status get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(MembershipV2_ProductStatus_Status value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);
}

class MembershipV2_PurchasedProduct extends $pb.GeneratedMessage {
  factory MembershipV2_PurchasedProduct({
    MembershipV2_Product? product,
    MembershipV2_PurchaseInfo? purchaseInfo,
    MembershipV2_ProductStatus? productStatus,
  }) {
    final result = create();
    if (product != null) result.product = product;
    if (purchaseInfo != null) result.purchaseInfo = purchaseInfo;
    if (productStatus != null) result.productStatus = productStatus;
    return result;
  }

  MembershipV2_PurchasedProduct._();

  factory MembershipV2_PurchasedProduct.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MembershipV2_PurchasedProduct.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipV2.PurchasedProduct',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOM<MembershipV2_Product>(1, _omitFieldNames ? '' : 'product',
        subBuilder: MembershipV2_Product.create)
    ..aOM<MembershipV2_PurchaseInfo>(2, _omitFieldNames ? '' : 'purchaseInfo',
        protoName: 'purchaseInfo', subBuilder: MembershipV2_PurchaseInfo.create)
    ..aOM<MembershipV2_ProductStatus>(3, _omitFieldNames ? '' : 'productStatus',
        protoName: 'productStatus',
        subBuilder: MembershipV2_ProductStatus.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_PurchasedProduct clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_PurchasedProduct copyWith(
          void Function(MembershipV2_PurchasedProduct) updates) =>
      super.copyWith(
              (message) => updates(message as MembershipV2_PurchasedProduct))
          as MembershipV2_PurchasedProduct;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipV2_PurchasedProduct create() =>
      MembershipV2_PurchasedProduct._();
  @$core.override
  MembershipV2_PurchasedProduct createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MembershipV2_PurchasedProduct getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MembershipV2_PurchasedProduct>(create);
  static MembershipV2_PurchasedProduct? _defaultInstance;

  @$pb.TagNumber(1)
  MembershipV2_Product get product => $_getN(0);
  @$pb.TagNumber(1)
  set product(MembershipV2_Product value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProduct() => $_has(0);
  @$pb.TagNumber(1)
  void clearProduct() => $_clearField(1);
  @$pb.TagNumber(1)
  MembershipV2_Product ensureProduct() => $_ensure(0);

  @$pb.TagNumber(2)
  MembershipV2_PurchaseInfo get purchaseInfo => $_getN(1);
  @$pb.TagNumber(2)
  set purchaseInfo(MembershipV2_PurchaseInfo value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPurchaseInfo() => $_has(1);
  @$pb.TagNumber(2)
  void clearPurchaseInfo() => $_clearField(2);
  @$pb.TagNumber(2)
  MembershipV2_PurchaseInfo ensurePurchaseInfo() => $_ensure(1);

  @$pb.TagNumber(3)
  MembershipV2_ProductStatus get productStatus => $_getN(2);
  @$pb.TagNumber(3)
  set productStatus(MembershipV2_ProductStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasProductStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearProductStatus() => $_clearField(3);
  @$pb.TagNumber(3)
  MembershipV2_ProductStatus ensureProductStatus() => $_ensure(2);
}

class MembershipV2_CartProduct extends $pb.GeneratedMessage {
  factory MembershipV2_CartProduct({
    MembershipV2_Product? product,
    $core.bool? isYearly,
    $core.bool? remove,
  }) {
    final result = create();
    if (product != null) result.product = product;
    if (isYearly != null) result.isYearly = isYearly;
    if (remove != null) result.remove = remove;
    return result;
  }

  MembershipV2_CartProduct._();

  factory MembershipV2_CartProduct.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MembershipV2_CartProduct.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipV2.CartProduct',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOM<MembershipV2_Product>(1, _omitFieldNames ? '' : 'product',
        subBuilder: MembershipV2_Product.create)
    ..aOB(2, _omitFieldNames ? '' : 'isYearly', protoName: 'isYearly')
    ..aOB(3, _omitFieldNames ? '' : 'remove')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_CartProduct clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_CartProduct copyWith(
          void Function(MembershipV2_CartProduct) updates) =>
      super.copyWith((message) => updates(message as MembershipV2_CartProduct))
          as MembershipV2_CartProduct;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipV2_CartProduct create() => MembershipV2_CartProduct._();
  @$core.override
  MembershipV2_CartProduct createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MembershipV2_CartProduct getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MembershipV2_CartProduct>(create);
  static MembershipV2_CartProduct? _defaultInstance;

  @$pb.TagNumber(1)
  MembershipV2_Product get product => $_getN(0);
  @$pb.TagNumber(1)
  set product(MembershipV2_Product value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProduct() => $_has(0);
  @$pb.TagNumber(1)
  void clearProduct() => $_clearField(1);
  @$pb.TagNumber(1)
  MembershipV2_Product ensureProduct() => $_ensure(0);

  /// otherwise - monthly
  @$pb.TagNumber(2)
  $core.bool get isYearly => $_getBF(1);
  @$pb.TagNumber(2)
  set isYearly($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsYearly() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsYearly() => $_clearField(2);

  /// set to true if you want to remove this item from the customer
  /// it's like setting -1 to some product
  @$pb.TagNumber(3)
  $core.bool get remove => $_getBF(2);
  @$pb.TagNumber(3)
  set remove($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRemove() => $_has(2);
  @$pb.TagNumber(3)
  void clearRemove() => $_clearField(3);
}

class MembershipV2_Cart extends $pb.GeneratedMessage {
  factory MembershipV2_Cart({
    $core.Iterable<MembershipV2_CartProduct>? products,
    MembershipV2_Amount? total,
    MembershipV2_Amount? totalNextInvoice,
    $fixnum.Int64? nextInvoiceDate,
  }) {
    final result = create();
    if (products != null) result.products.addAll(products);
    if (total != null) result.total = total;
    if (totalNextInvoice != null) result.totalNextInvoice = totalNextInvoice;
    if (nextInvoiceDate != null) result.nextInvoiceDate = nextInvoiceDate;
    return result;
  }

  MembershipV2_Cart._();

  factory MembershipV2_Cart.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MembershipV2_Cart.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipV2.Cart',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPM<MembershipV2_CartProduct>(1, _omitFieldNames ? '' : 'products',
        subBuilder: MembershipV2_CartProduct.create)
    ..aOM<MembershipV2_Amount>(2, _omitFieldNames ? '' : 'total',
        subBuilder: MembershipV2_Amount.create)
    ..aOM<MembershipV2_Amount>(3, _omitFieldNames ? '' : 'totalNextInvoice',
        protoName: 'totalNextInvoice', subBuilder: MembershipV2_Amount.create)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'nextInvoiceDate', $pb.PbFieldType.OU6,
        protoName: 'nextInvoiceDate', defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_Cart clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_Cart copyWith(void Function(MembershipV2_Cart) updates) =>
      super.copyWith((message) => updates(message as MembershipV2_Cart))
          as MembershipV2_Cart;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipV2_Cart create() => MembershipV2_Cart._();
  @$core.override
  MembershipV2_Cart createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MembershipV2_Cart getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MembershipV2_Cart>(create);
  static MembershipV2_Cart? _defaultInstance;

  /// if you add Nx the same product - it will be Nx in the 'products' array, i.e:
  /// each product instance has a unique index
  @$pb.TagNumber(1)
  $pb.PbList<MembershipV2_CartProduct> get products => $_getList(0);

  /// total amount of the cart (including discounts, etc)
  @$pb.TagNumber(2)
  MembershipV2_Amount get total => $_getN(1);
  @$pb.TagNumber(2)
  set total(MembershipV2_Amount value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);
  @$pb.TagNumber(2)
  MembershipV2_Amount ensureTotal() => $_ensure(1);

  /// in case you are paying in the middle of the period (for existing customers)
  /// the next invoice amount will also be generated
  @$pb.TagNumber(3)
  MembershipV2_Amount get totalNextInvoice => $_getN(2);
  @$pb.TagNumber(3)
  set totalNextInvoice(MembershipV2_Amount value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalNextInvoice() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalNextInvoice() => $_clearField(3);
  @$pb.TagNumber(3)
  MembershipV2_Amount ensureTotalNextInvoice() => $_ensure(2);

  @$pb.TagNumber(4)
  $fixnum.Int64 get nextInvoiceDate => $_getI64(3);
  @$pb.TagNumber(4)
  set nextInvoiceDate($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNextInvoiceDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearNextInvoiceDate() => $_clearField(4);
}

class MembershipV2_Data extends $pb.GeneratedMessage {
  factory MembershipV2_Data({
    $core.Iterable<MembershipV2_PurchasedProduct>? products,
    MembershipV2_Invoice? nextInvoice,
    $core.String? teamOwnerID,
    MembershipV2_PaymentProvider? paymentProvider,
  }) {
    final result = create();
    if (products != null) result.products.addAll(products);
    if (nextInvoice != null) result.nextInvoice = nextInvoice;
    if (teamOwnerID != null) result.teamOwnerID = teamOwnerID;
    if (paymentProvider != null) result.paymentProvider = paymentProvider;
    return result;
  }

  MembershipV2_Data._();

  factory MembershipV2_Data.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MembershipV2_Data.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipV2.Data',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPM<MembershipV2_PurchasedProduct>(1, _omitFieldNames ? '' : 'products',
        subBuilder: MembershipV2_PurchasedProduct.create)
    ..aOM<MembershipV2_Invoice>(2, _omitFieldNames ? '' : 'nextInvoice',
        protoName: 'nextInvoice', subBuilder: MembershipV2_Invoice.create)
    ..aOS(3, _omitFieldNames ? '' : 'teamOwnerID', protoName: 'teamOwnerID')
    ..aE<MembershipV2_PaymentProvider>(
        4, _omitFieldNames ? '' : 'paymentProvider',
        protoName: 'paymentProvider',
        enumValues: MembershipV2_PaymentProvider.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_Data clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2_Data copyWith(void Function(MembershipV2_Data) updates) =>
      super.copyWith((message) => updates(message as MembershipV2_Data))
          as MembershipV2_Data;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipV2_Data create() => MembershipV2_Data._();
  @$core.override
  MembershipV2_Data createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MembershipV2_Data getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MembershipV2_Data>(create);
  static MembershipV2_Data? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<MembershipV2_PurchasedProduct> get products => $_getList(0);

  @$pb.TagNumber(2)
  MembershipV2_Invoice get nextInvoice => $_getN(1);
  @$pb.TagNumber(2)
  set nextInvoice(MembershipV2_Invoice value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasNextInvoice() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextInvoice() => $_clearField(2);
  @$pb.TagNumber(2)
  MembershipV2_Invoice ensureNextInvoice() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get teamOwnerID => $_getSZ(2);
  @$pb.TagNumber(3)
  set teamOwnerID($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTeamOwnerID() => $_has(2);
  @$pb.TagNumber(3)
  void clearTeamOwnerID() => $_clearField(3);

  @$pb.TagNumber(4)
  MembershipV2_PaymentProvider get paymentProvider => $_getN(3);
  @$pb.TagNumber(4)
  set paymentProvider(MembershipV2_PaymentProvider value) =>
      $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasPaymentProvider() => $_has(3);
  @$pb.TagNumber(4)
  void clearPaymentProvider() => $_clearField(4);
}

class MembershipV2 extends $pb.GeneratedMessage {
  factory MembershipV2() => create();

  MembershipV2._();

  factory MembershipV2.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MembershipV2.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MembershipV2',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2 clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MembershipV2 copyWith(void Function(MembershipV2) updates) =>
      super.copyWith((message) => updates(message as MembershipV2))
          as MembershipV2;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MembershipV2 create() => MembershipV2._();
  @$core.override
  MembershipV2 createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MembershipV2 getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MembershipV2>(create);
  static MembershipV2? _defaultInstance;
}

class Detail extends $pb.GeneratedMessage {
  factory Detail({
    $core.String? key,
    $0.Value? value,
  }) {
    final result = create();
    if (key != null) result.key = key;
    if (value != null) result.value = value;
    return result;
  }

  Detail._();

  factory Detail.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Detail.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Detail',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'key')
    ..aOM<$0.Value>(2, _omitFieldNames ? '' : 'value',
        subBuilder: $0.Value.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Detail clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Detail copyWith(void Function(Detail) updates) =>
      super.copyWith((message) => updates(message as Detail)) as Detail;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Detail create() => Detail._();
  @$core.override
  Detail createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Detail getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Detail>(create);
  static Detail? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get key => $_getSZ(0);
  @$pb.TagNumber(1)
  set key($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Value get value => $_getN(1);
  @$pb.TagNumber(2)
  set value($0.Value value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Value ensureValue() => $_ensure(1);
}

class DeviceInfo extends $pb.GeneratedMessage {
  factory DeviceInfo({
    $core.String? id,
    $core.String? name,
    $fixnum.Int64? addDate,
    $core.bool? archived,
    $core.bool? isConnected,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (addDate != null) result.addDate = addDate;
    if (archived != null) result.archived = archived;
    if (isConnected != null) result.isConnected = isConnected;
    return result;
  }

  DeviceInfo._();

  factory DeviceInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeviceInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeviceInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aInt64(3, _omitFieldNames ? '' : 'addDate', protoName: 'addDate')
    ..aOB(4, _omitFieldNames ? '' : 'archived')
    ..aOB(5, _omitFieldNames ? '' : 'isConnected', protoName: 'isConnected')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceInfo copyWith(void Function(DeviceInfo) updates) =>
      super.copyWith((message) => updates(message as DeviceInfo)) as DeviceInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeviceInfo create() => DeviceInfo._();
  @$core.override
  DeviceInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeviceInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeviceInfo>(create);
  static DeviceInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get addDate => $_getI64(2);
  @$pb.TagNumber(3)
  set addDate($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddDate() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get archived => $_getBF(3);
  @$pb.TagNumber(4)
  set archived($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasArchived() => $_has(3);
  @$pb.TagNumber(4)
  void clearArchived() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isConnected => $_getBF(4);
  @$pb.TagNumber(5)
  set isConnected($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsConnected() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsConnected() => $_clearField(5);
}

class ChatState_UnreadState extends $pb.GeneratedMessage {
  factory ChatState_UnreadState({
    $core.String? oldestOrderId,
    $core.int? counter,
  }) {
    final result = create();
    if (oldestOrderId != null) result.oldestOrderId = oldestOrderId;
    if (counter != null) result.counter = counter;
    return result;
  }

  ChatState_UnreadState._();

  factory ChatState_UnreadState.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChatState_UnreadState.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatState.UnreadState',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'oldestOrderId', protoName: 'oldestOrderId')
    ..aI(2, _omitFieldNames ? '' : 'counter')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatState_UnreadState clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatState_UnreadState copyWith(
          void Function(ChatState_UnreadState) updates) =>
      super.copyWith((message) => updates(message as ChatState_UnreadState))
          as ChatState_UnreadState;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatState_UnreadState create() => ChatState_UnreadState._();
  @$core.override
  ChatState_UnreadState createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChatState_UnreadState getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatState_UnreadState>(create);
  static ChatState_UnreadState? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get oldestOrderId => $_getSZ(0);
  @$pb.TagNumber(1)
  set oldestOrderId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOldestOrderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOldestOrderId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get counter => $_getIZ(1);
  @$pb.TagNumber(2)
  set counter($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCounter() => $_has(1);
  @$pb.TagNumber(2)
  void clearCounter() => $_clearField(2);
}

class ChatState extends $pb.GeneratedMessage {
  factory ChatState({
    ChatState_UnreadState? messages,
    ChatState_UnreadState? mentions,
    $core.String? lastStateId,
    $fixnum.Int64? order,
    $core.String? unreadReactionOrderId,
  }) {
    final result = create();
    if (messages != null) result.messages = messages;
    if (mentions != null) result.mentions = mentions;
    if (lastStateId != null) result.lastStateId = lastStateId;
    if (order != null) result.order = order;
    if (unreadReactionOrderId != null)
      result.unreadReactionOrderId = unreadReactionOrderId;
    return result;
  }

  ChatState._();

  factory ChatState.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChatState.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatState',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOM<ChatState_UnreadState>(1, _omitFieldNames ? '' : 'messages',
        subBuilder: ChatState_UnreadState.create)
    ..aOM<ChatState_UnreadState>(2, _omitFieldNames ? '' : 'mentions',
        subBuilder: ChatState_UnreadState.create)
    ..aOS(3, _omitFieldNames ? '' : 'lastStateId', protoName: 'lastStateId')
    ..aInt64(4, _omitFieldNames ? '' : 'order')
    ..aOS(5, _omitFieldNames ? '' : 'unreadReactionOrderId',
        protoName: 'unreadReactionOrderId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatState clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatState copyWith(void Function(ChatState) updates) =>
      super.copyWith((message) => updates(message as ChatState)) as ChatState;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatState create() => ChatState._();
  @$core.override
  ChatState createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChatState getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatState>(create);
  static ChatState? _defaultInstance;

  @$pb.TagNumber(1)
  ChatState_UnreadState get messages => $_getN(0);
  @$pb.TagNumber(1)
  set messages(ChatState_UnreadState value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMessages() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessages() => $_clearField(1);
  @$pb.TagNumber(1)
  ChatState_UnreadState ensureMessages() => $_ensure(0);

  @$pb.TagNumber(2)
  ChatState_UnreadState get mentions => $_getN(1);
  @$pb.TagNumber(2)
  set mentions(ChatState_UnreadState value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMentions() => $_has(1);
  @$pb.TagNumber(2)
  void clearMentions() => $_clearField(2);
  @$pb.TagNumber(2)
  ChatState_UnreadState ensureMentions() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get lastStateId => $_getSZ(2);
  @$pb.TagNumber(3)
  set lastStateId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLastStateId() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastStateId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get order => $_getI64(3);
  @$pb.TagNumber(4)
  set order($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOrder() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrder() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get unreadReactionOrderId => $_getSZ(4);
  @$pb.TagNumber(5)
  set unreadReactionOrderId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUnreadReactionOrderId() => $_has(4);
  @$pb.TagNumber(5)
  void clearUnreadReactionOrderId() => $_clearField(5);
}

class ChatMessage_MessageContent extends $pb.GeneratedMessage {
  factory ChatMessage_MessageContent({
    $core.String? text,
    Block_Content_Text_Style? style,
    $core.Iterable<Block_Content_Text_Mark>? marks,
  }) {
    final result = create();
    if (text != null) result.text = text;
    if (style != null) result.style = style;
    if (marks != null) result.marks.addAll(marks);
    return result;
  }

  ChatMessage_MessageContent._();

  factory ChatMessage_MessageContent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChatMessage_MessageContent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatMessage.MessageContent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..aE<Block_Content_Text_Style>(2, _omitFieldNames ? '' : 'style',
        enumValues: Block_Content_Text_Style.values)
    ..pPM<Block_Content_Text_Mark>(3, _omitFieldNames ? '' : 'marks',
        subBuilder: Block_Content_Text_Mark.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage_MessageContent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage_MessageContent copyWith(
          void Function(ChatMessage_MessageContent) updates) =>
      super.copyWith(
              (message) => updates(message as ChatMessage_MessageContent))
          as ChatMessage_MessageContent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatMessage_MessageContent create() => ChatMessage_MessageContent._();
  @$core.override
  ChatMessage_MessageContent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChatMessage_MessageContent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatMessage_MessageContent>(create);
  static ChatMessage_MessageContent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  @$pb.TagNumber(2)
  Block_Content_Text_Style get style => $_getN(1);
  @$pb.TagNumber(2)
  set style(Block_Content_Text_Style value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStyle() => $_has(1);
  @$pb.TagNumber(2)
  void clearStyle() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<Block_Content_Text_Mark> get marks => $_getList(2);
}

class ChatMessage_Attachment extends $pb.GeneratedMessage {
  factory ChatMessage_Attachment({
    $core.String? target,
    ChatMessage_Attachment_AttachmentType? type,
  }) {
    final result = create();
    if (target != null) result.target = target;
    if (type != null) result.type = type;
    return result;
  }

  ChatMessage_Attachment._();

  factory ChatMessage_Attachment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChatMessage_Attachment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatMessage.Attachment',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'target')
    ..aE<ChatMessage_Attachment_AttachmentType>(
        2, _omitFieldNames ? '' : 'type',
        enumValues: ChatMessage_Attachment_AttachmentType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage_Attachment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage_Attachment copyWith(
          void Function(ChatMessage_Attachment) updates) =>
      super.copyWith((message) => updates(message as ChatMessage_Attachment))
          as ChatMessage_Attachment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatMessage_Attachment create() => ChatMessage_Attachment._();
  @$core.override
  ChatMessage_Attachment createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChatMessage_Attachment getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatMessage_Attachment>(create);
  static ChatMessage_Attachment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get target => $_getSZ(0);
  @$pb.TagNumber(1)
  set target($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTarget() => $_has(0);
  @$pb.TagNumber(1)
  void clearTarget() => $_clearField(1);

  @$pb.TagNumber(2)
  ChatMessage_Attachment_AttachmentType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(ChatMessage_Attachment_AttachmentType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);
}

class ChatMessage_Reactions_IdentityList extends $pb.GeneratedMessage {
  factory ChatMessage_Reactions_IdentityList({
    $core.Iterable<$core.String>? ids,
  }) {
    final result = create();
    if (ids != null) result.ids.addAll(ids);
    return result;
  }

  ChatMessage_Reactions_IdentityList._();

  factory ChatMessage_Reactions_IdentityList.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChatMessage_Reactions_IdentityList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatMessage.Reactions.IdentityList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'ids')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage_Reactions_IdentityList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage_Reactions_IdentityList copyWith(
          void Function(ChatMessage_Reactions_IdentityList) updates) =>
      super.copyWith((message) =>
              updates(message as ChatMessage_Reactions_IdentityList))
          as ChatMessage_Reactions_IdentityList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatMessage_Reactions_IdentityList create() =>
      ChatMessage_Reactions_IdentityList._();
  @$core.override
  ChatMessage_Reactions_IdentityList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChatMessage_Reactions_IdentityList getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatMessage_Reactions_IdentityList>(
          create);
  static ChatMessage_Reactions_IdentityList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get ids => $_getList(0);
}

class ChatMessage_Reactions extends $pb.GeneratedMessage {
  factory ChatMessage_Reactions({
    $core.Iterable<
            $core.MapEntry<$core.String, ChatMessage_Reactions_IdentityList>>?
        reactions,
  }) {
    final result = create();
    if (reactions != null) result.reactions.addEntries(reactions);
    return result;
  }

  ChatMessage_Reactions._();

  factory ChatMessage_Reactions.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChatMessage_Reactions.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatMessage.Reactions',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..m<$core.String, ChatMessage_Reactions_IdentityList>(
        1, _omitFieldNames ? '' : 'reactions',
        entryClassName: 'ChatMessage.Reactions.ReactionsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OM,
        valueCreator: ChatMessage_Reactions_IdentityList.create,
        valueDefaultOrMaker: ChatMessage_Reactions_IdentityList.getDefault,
        packageName: const $pb.PackageName('anytype.model'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage_Reactions clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage_Reactions copyWith(
          void Function(ChatMessage_Reactions) updates) =>
      super.copyWith((message) => updates(message as ChatMessage_Reactions))
          as ChatMessage_Reactions;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatMessage_Reactions create() => ChatMessage_Reactions._();
  @$core.override
  ChatMessage_Reactions createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChatMessage_Reactions getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatMessage_Reactions>(create);
  static ChatMessage_Reactions? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbMap<$core.String, ChatMessage_Reactions_IdentityList> get reactions =>
      $_getMap(0);
}

enum ChatMessage_MessageBlock_Content { text, link, embed, notSet }

class ChatMessage_MessageBlock extends $pb.GeneratedMessage {
  factory ChatMessage_MessageBlock({
    ChatMessage_MessageBlockText? text,
    ChatMessage_MessageBlockLink? link,
    ChatMessage_MessageBlockEmbed? embed,
  }) {
    final result = create();
    if (text != null) result.text = text;
    if (link != null) result.link = link;
    if (embed != null) result.embed = embed;
    return result;
  }

  ChatMessage_MessageBlock._();

  factory ChatMessage_MessageBlock.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChatMessage_MessageBlock.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ChatMessage_MessageBlock_Content>
      _ChatMessage_MessageBlock_ContentByTag = {
    1: ChatMessage_MessageBlock_Content.text,
    2: ChatMessage_MessageBlock_Content.link,
    3: ChatMessage_MessageBlock_Content.embed,
    0: ChatMessage_MessageBlock_Content.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatMessage.MessageBlock',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<ChatMessage_MessageBlockText>(1, _omitFieldNames ? '' : 'text',
        subBuilder: ChatMessage_MessageBlockText.create)
    ..aOM<ChatMessage_MessageBlockLink>(2, _omitFieldNames ? '' : 'link',
        subBuilder: ChatMessage_MessageBlockLink.create)
    ..aOM<ChatMessage_MessageBlockEmbed>(3, _omitFieldNames ? '' : 'embed',
        subBuilder: ChatMessage_MessageBlockEmbed.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage_MessageBlock clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage_MessageBlock copyWith(
          void Function(ChatMessage_MessageBlock) updates) =>
      super.copyWith((message) => updates(message as ChatMessage_MessageBlock))
          as ChatMessage_MessageBlock;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatMessage_MessageBlock create() => ChatMessage_MessageBlock._();
  @$core.override
  ChatMessage_MessageBlock createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChatMessage_MessageBlock getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatMessage_MessageBlock>(create);
  static ChatMessage_MessageBlock? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  ChatMessage_MessageBlock_Content whichContent() =>
      _ChatMessage_MessageBlock_ContentByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  void clearContent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  ChatMessage_MessageBlockText get text => $_getN(0);
  @$pb.TagNumber(1)
  set text(ChatMessage_MessageBlockText value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);
  @$pb.TagNumber(1)
  ChatMessage_MessageBlockText ensureText() => $_ensure(0);

  @$pb.TagNumber(2)
  ChatMessage_MessageBlockLink get link => $_getN(1);
  @$pb.TagNumber(2)
  set link(ChatMessage_MessageBlockLink value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasLink() => $_has(1);
  @$pb.TagNumber(2)
  void clearLink() => $_clearField(2);
  @$pb.TagNumber(2)
  ChatMessage_MessageBlockLink ensureLink() => $_ensure(1);

  @$pb.TagNumber(3)
  ChatMessage_MessageBlockEmbed get embed => $_getN(2);
  @$pb.TagNumber(3)
  set embed(ChatMessage_MessageBlockEmbed value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEmbed() => $_has(2);
  @$pb.TagNumber(3)
  void clearEmbed() => $_clearField(3);
  @$pb.TagNumber(3)
  ChatMessage_MessageBlockEmbed ensureEmbed() => $_ensure(2);
}

class ChatMessage_MessageBlockText extends $pb.GeneratedMessage {
  factory ChatMessage_MessageBlockText({
    $core.String? text,
    Block_Content_Text_Style? style,
    $core.Iterable<Block_Content_Text_Mark>? marks,
    $core.bool? checked,
    $core.String? lang,
  }) {
    final result = create();
    if (text != null) result.text = text;
    if (style != null) result.style = style;
    if (marks != null) result.marks.addAll(marks);
    if (checked != null) result.checked = checked;
    if (lang != null) result.lang = lang;
    return result;
  }

  ChatMessage_MessageBlockText._();

  factory ChatMessage_MessageBlockText.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChatMessage_MessageBlockText.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatMessage.MessageBlockText',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..aE<Block_Content_Text_Style>(2, _omitFieldNames ? '' : 'style',
        enumValues: Block_Content_Text_Style.values)
    ..pPM<Block_Content_Text_Mark>(3, _omitFieldNames ? '' : 'marks',
        subBuilder: Block_Content_Text_Mark.create)
    ..aOB(4, _omitFieldNames ? '' : 'checked')
    ..aOS(5, _omitFieldNames ? '' : 'lang')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage_MessageBlockText clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage_MessageBlockText copyWith(
          void Function(ChatMessage_MessageBlockText) updates) =>
      super.copyWith(
              (message) => updates(message as ChatMessage_MessageBlockText))
          as ChatMessage_MessageBlockText;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatMessage_MessageBlockText create() =>
      ChatMessage_MessageBlockText._();
  @$core.override
  ChatMessage_MessageBlockText createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChatMessage_MessageBlockText getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatMessage_MessageBlockText>(create);
  static ChatMessage_MessageBlockText? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  @$pb.TagNumber(2)
  Block_Content_Text_Style get style => $_getN(1);
  @$pb.TagNumber(2)
  set style(Block_Content_Text_Style value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStyle() => $_has(1);
  @$pb.TagNumber(2)
  void clearStyle() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<Block_Content_Text_Mark> get marks => $_getList(2);

  @$pb.TagNumber(4)
  $core.bool get checked => $_getBF(3);
  @$pb.TagNumber(4)
  set checked($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasChecked() => $_has(3);
  @$pb.TagNumber(4)
  void clearChecked() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get lang => $_getSZ(4);
  @$pb.TagNumber(5)
  set lang($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLang() => $_has(4);
  @$pb.TagNumber(5)
  void clearLang() => $_clearField(5);
}

class ChatMessage_MessageBlockLink extends $pb.GeneratedMessage {
  factory ChatMessage_MessageBlockLink({
    $core.String? targetObjectId,
    ChatMessage_MessageBlockLink_LinkType? type,
  }) {
    final result = create();
    if (targetObjectId != null) result.targetObjectId = targetObjectId;
    if (type != null) result.type = type;
    return result;
  }

  ChatMessage_MessageBlockLink._();

  factory ChatMessage_MessageBlockLink.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChatMessage_MessageBlockLink.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatMessage.MessageBlockLink',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'targetObjectId',
        protoName: 'targetObjectId')
    ..aE<ChatMessage_MessageBlockLink_LinkType>(
        2, _omitFieldNames ? '' : 'type',
        enumValues: ChatMessage_MessageBlockLink_LinkType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage_MessageBlockLink clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage_MessageBlockLink copyWith(
          void Function(ChatMessage_MessageBlockLink) updates) =>
      super.copyWith(
              (message) => updates(message as ChatMessage_MessageBlockLink))
          as ChatMessage_MessageBlockLink;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatMessage_MessageBlockLink create() =>
      ChatMessage_MessageBlockLink._();
  @$core.override
  ChatMessage_MessageBlockLink createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChatMessage_MessageBlockLink getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatMessage_MessageBlockLink>(create);
  static ChatMessage_MessageBlockLink? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get targetObjectId => $_getSZ(0);
  @$pb.TagNumber(1)
  set targetObjectId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTargetObjectId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTargetObjectId() => $_clearField(1);

  @$pb.TagNumber(2)
  ChatMessage_MessageBlockLink_LinkType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(ChatMessage_MessageBlockLink_LinkType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);
}

class ChatMessage_MessageBlockEmbed extends $pb.GeneratedMessage {
  factory ChatMessage_MessageBlockEmbed({
    $core.String? text,
    Block_Content_Latex_Processor? processor,
  }) {
    final result = create();
    if (text != null) result.text = text;
    if (processor != null) result.processor = processor;
    return result;
  }

  ChatMessage_MessageBlockEmbed._();

  factory ChatMessage_MessageBlockEmbed.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChatMessage_MessageBlockEmbed.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatMessage.MessageBlockEmbed',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..aE<Block_Content_Latex_Processor>(2, _omitFieldNames ? '' : 'processor',
        enumValues: Block_Content_Latex_Processor.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage_MessageBlockEmbed clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage_MessageBlockEmbed copyWith(
          void Function(ChatMessage_MessageBlockEmbed) updates) =>
      super.copyWith(
              (message) => updates(message as ChatMessage_MessageBlockEmbed))
          as ChatMessage_MessageBlockEmbed;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatMessage_MessageBlockEmbed create() =>
      ChatMessage_MessageBlockEmbed._();
  @$core.override
  ChatMessage_MessageBlockEmbed createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChatMessage_MessageBlockEmbed getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatMessage_MessageBlockEmbed>(create);
  static ChatMessage_MessageBlockEmbed? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  @$pb.TagNumber(2)
  Block_Content_Latex_Processor get processor => $_getN(1);
  @$pb.TagNumber(2)
  set processor(Block_Content_Latex_Processor value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasProcessor() => $_has(1);
  @$pb.TagNumber(2)
  void clearProcessor() => $_clearField(2);
}

class ChatMessage extends $pb.GeneratedMessage {
  factory ChatMessage({
    $core.String? id,
    $core.String? orderId,
    $core.String? creator,
    $fixnum.Int64? createdAt,
    $core.String? replyToMessageId,
    ChatMessage_MessageContent? message,
    $core.Iterable<ChatMessage_Attachment>? attachments,
    ChatMessage_Reactions? reactions,
    $fixnum.Int64? modifiedAt,
    $core.bool? read,
    $core.String? stateId,
    $core.bool? mentionRead,
    $core.bool? synced,
    $core.bool? hasMention,
    $core.bool? pinned,
    $core.bool? unreadReaction,
    $core.Iterable<ChatMessage_MessageBlock>? blocks,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (orderId != null) result.orderId = orderId;
    if (creator != null) result.creator = creator;
    if (createdAt != null) result.createdAt = createdAt;
    if (replyToMessageId != null) result.replyToMessageId = replyToMessageId;
    if (message != null) result.message = message;
    if (attachments != null) result.attachments.addAll(attachments);
    if (reactions != null) result.reactions = reactions;
    if (modifiedAt != null) result.modifiedAt = modifiedAt;
    if (read != null) result.read = read;
    if (stateId != null) result.stateId = stateId;
    if (mentionRead != null) result.mentionRead = mentionRead;
    if (synced != null) result.synced = synced;
    if (hasMention != null) result.hasMention = hasMention;
    if (pinned != null) result.pinned = pinned;
    if (unreadReaction != null) result.unreadReaction = unreadReaction;
    if (blocks != null) result.blocks.addAll(blocks);
    return result;
  }

  ChatMessage._();

  factory ChatMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChatMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ChatMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype.model'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'orderId', protoName: 'orderId')
    ..aOS(3, _omitFieldNames ? '' : 'creator')
    ..aInt64(4, _omitFieldNames ? '' : 'createdAt', protoName: 'createdAt')
    ..aOS(5, _omitFieldNames ? '' : 'replyToMessageId',
        protoName: 'replyToMessageId')
    ..aOM<ChatMessage_MessageContent>(6, _omitFieldNames ? '' : 'message',
        subBuilder: ChatMessage_MessageContent.create)
    ..pPM<ChatMessage_Attachment>(7, _omitFieldNames ? '' : 'attachments',
        subBuilder: ChatMessage_Attachment.create)
    ..aOM<ChatMessage_Reactions>(8, _omitFieldNames ? '' : 'reactions',
        subBuilder: ChatMessage_Reactions.create)
    ..aInt64(9, _omitFieldNames ? '' : 'modifiedAt', protoName: 'modifiedAt')
    ..aOB(10, _omitFieldNames ? '' : 'read')
    ..aOS(11, _omitFieldNames ? '' : 'stateId', protoName: 'stateId')
    ..aOB(12, _omitFieldNames ? '' : 'mentionRead', protoName: 'mentionRead')
    ..aOB(13, _omitFieldNames ? '' : 'synced')
    ..aOB(14, _omitFieldNames ? '' : 'hasMention', protoName: 'hasMention')
    ..aOB(15, _omitFieldNames ? '' : 'pinned')
    ..aOB(16, _omitFieldNames ? '' : 'unreadReaction',
        protoName: 'unreadReaction')
    ..pPM<ChatMessage_MessageBlock>(17, _omitFieldNames ? '' : 'blocks',
        subBuilder: ChatMessage_MessageBlock.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChatMessage copyWith(void Function(ChatMessage) updates) =>
      super.copyWith((message) => updates(message as ChatMessage))
          as ChatMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatMessage create() => ChatMessage._();
  @$core.override
  ChatMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChatMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChatMessage>(create);
  static ChatMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get orderId => $_getSZ(1);
  @$pb.TagNumber(2)
  set orderId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOrderId() => $_has(1);
  @$pb.TagNumber(2)
  void clearOrderId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get creator => $_getSZ(2);
  @$pb.TagNumber(3)
  set creator($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCreator() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreator() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get createdAt => $_getI64(3);
  @$pb.TagNumber(4)
  set createdAt($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get replyToMessageId => $_getSZ(4);
  @$pb.TagNumber(5)
  set replyToMessageId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReplyToMessageId() => $_has(4);
  @$pb.TagNumber(5)
  void clearReplyToMessageId() => $_clearField(5);

  @$pb.TagNumber(6)
  ChatMessage_MessageContent get message => $_getN(5);
  @$pb.TagNumber(6)
  set message(ChatMessage_MessageContent value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasMessage() => $_has(5);
  @$pb.TagNumber(6)
  void clearMessage() => $_clearField(6);
  @$pb.TagNumber(6)
  ChatMessage_MessageContent ensureMessage() => $_ensure(5);

  @$pb.TagNumber(7)
  $pb.PbList<ChatMessage_Attachment> get attachments => $_getList(6);

  @$pb.TagNumber(8)
  ChatMessage_Reactions get reactions => $_getN(7);
  @$pb.TagNumber(8)
  set reactions(ChatMessage_Reactions value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasReactions() => $_has(7);
  @$pb.TagNumber(8)
  void clearReactions() => $_clearField(8);
  @$pb.TagNumber(8)
  ChatMessage_Reactions ensureReactions() => $_ensure(7);

  @$pb.TagNumber(9)
  $fixnum.Int64 get modifiedAt => $_getI64(8);
  @$pb.TagNumber(9)
  set modifiedAt($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasModifiedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearModifiedAt() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get read => $_getBF(9);
  @$pb.TagNumber(10)
  set read($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasRead() => $_has(9);
  @$pb.TagNumber(10)
  void clearRead() => $_clearField(10);

  /// stateId is ever-increasing id (BSON ObjectId) for this message. Unlike orderId, this ID is ordered by the time messages are added. For example, it's useful to prevent accidental reading of messages from the past when a ChatReadMessages request is sent: a message from the past may appear, but the client is still unaware of it
  @$pb.TagNumber(11)
  $core.String get stateId => $_getSZ(10);
  @$pb.TagNumber(11)
  set stateId($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasStateId() => $_has(10);
  @$pb.TagNumber(11)
  void clearStateId() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get mentionRead => $_getBF(11);
  @$pb.TagNumber(12)
  set mentionRead($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasMentionRead() => $_has(11);
  @$pb.TagNumber(12)
  void clearMentionRead() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get synced => $_getBF(12);
  @$pb.TagNumber(13)
  set synced($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasSynced() => $_has(12);
  @$pb.TagNumber(13)
  void clearSynced() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get hasMention => $_getBF(13);
  @$pb.TagNumber(14)
  set hasMention($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasHasMention() => $_has(13);
  @$pb.TagNumber(14)
  void clearHasMention() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.bool get pinned => $_getBF(14);
  @$pb.TagNumber(15)
  set pinned($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasPinned() => $_has(14);
  @$pb.TagNumber(15)
  void clearPinned() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.bool get unreadReaction => $_getBF(15);
  @$pb.TagNumber(16)
  set unreadReaction($core.bool value) => $_setBool(15, value);
  @$pb.TagNumber(16)
  $core.bool hasUnreadReaction() => $_has(15);
  @$pb.TagNumber(16)
  void clearUnreadReaction() => $_clearField(16);

  @$pb.TagNumber(17)
  $pb.PbList<ChatMessage_MessageBlock> get blocks => $_getList(16);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
