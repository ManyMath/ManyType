// This is a generated file - do not edit.
//
// Generated from any_block/events.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $0;

import 'models.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

enum Event_Message_Value {
  blockSetFields,
  blockSetChildrenIds,
  blockSetBackgroundColor,
  blockSetText,
  blockSetAlign,
  blockSetDiv,
  blockSetRelation,
  blockSetLatex,
  blockSetVerticalAlign,
  blockSetTableRow,
  blockSetWidget,
  notSet
}

class Event_Message extends $pb.GeneratedMessage {
  factory Event_Message({
    Event_Block_Set_Fields? blockSetFields,
    Event_Block_Set_ChildrenIds? blockSetChildrenIds,
    Event_Block_Set_BackgroundColor? blockSetBackgroundColor,
    Event_Block_Set_Text? blockSetText,
    Event_Block_Set_Align? blockSetAlign,
    Event_Block_Set_Div? blockSetDiv,
    Event_Block_Set_Relation? blockSetRelation,
    Event_Block_Set_Latex? blockSetLatex,
    Event_Block_Set_VerticalAlign? blockSetVerticalAlign,
    Event_Block_Set_TableRow? blockSetTableRow,
    Event_Block_Set_Widget? blockSetWidget,
    $core.String? spaceId,
  }) {
    final result = create();
    if (blockSetFields != null) result.blockSetFields = blockSetFields;
    if (blockSetChildrenIds != null)
      result.blockSetChildrenIds = blockSetChildrenIds;
    if (blockSetBackgroundColor != null)
      result.blockSetBackgroundColor = blockSetBackgroundColor;
    if (blockSetText != null) result.blockSetText = blockSetText;
    if (blockSetAlign != null) result.blockSetAlign = blockSetAlign;
    if (blockSetDiv != null) result.blockSetDiv = blockSetDiv;
    if (blockSetRelation != null) result.blockSetRelation = blockSetRelation;
    if (blockSetLatex != null) result.blockSetLatex = blockSetLatex;
    if (blockSetVerticalAlign != null)
      result.blockSetVerticalAlign = blockSetVerticalAlign;
    if (blockSetTableRow != null) result.blockSetTableRow = blockSetTableRow;
    if (blockSetWidget != null) result.blockSetWidget = blockSetWidget;
    if (spaceId != null) result.spaceId = spaceId;
    return result;
  }

  Event_Message._();

  factory Event_Message.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Message.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Event_Message_Value>
      _Event_Message_ValueByTag = {
    6: Event_Message_Value.blockSetFields,
    7: Event_Message_Value.blockSetChildrenIds,
    9: Event_Message_Value.blockSetBackgroundColor,
    10: Event_Message_Value.blockSetText,
    15: Event_Message_Value.blockSetAlign,
    17: Event_Message_Value.blockSetDiv,
    21: Event_Message_Value.blockSetRelation,
    25: Event_Message_Value.blockSetLatex,
    36: Event_Message_Value.blockSetVerticalAlign,
    37: Event_Message_Value.blockSetTableRow,
    40: Event_Message_Value.blockSetWidget,
    0: Event_Message_Value.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Message',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..oo(0, [6, 7, 9, 10, 15, 17, 21, 25, 36, 37, 40])
    ..aOM<Event_Block_Set_Fields>(6, _omitFieldNames ? '' : 'blockSetFields',
        protoName: 'blockSetFields', subBuilder: Event_Block_Set_Fields.create)
    ..aOM<Event_Block_Set_ChildrenIds>(
        7, _omitFieldNames ? '' : 'blockSetChildrenIds',
        protoName: 'blockSetChildrenIds',
        subBuilder: Event_Block_Set_ChildrenIds.create)
    ..aOM<Event_Block_Set_BackgroundColor>(
        9, _omitFieldNames ? '' : 'blockSetBackgroundColor',
        protoName: 'blockSetBackgroundColor',
        subBuilder: Event_Block_Set_BackgroundColor.create)
    ..aOM<Event_Block_Set_Text>(10, _omitFieldNames ? '' : 'blockSetText',
        protoName: 'blockSetText', subBuilder: Event_Block_Set_Text.create)
    ..aOM<Event_Block_Set_Align>(15, _omitFieldNames ? '' : 'blockSetAlign',
        protoName: 'blockSetAlign', subBuilder: Event_Block_Set_Align.create)
    ..aOM<Event_Block_Set_Div>(17, _omitFieldNames ? '' : 'blockSetDiv',
        protoName: 'blockSetDiv', subBuilder: Event_Block_Set_Div.create)
    ..aOM<Event_Block_Set_Relation>(
        21, _omitFieldNames ? '' : 'blockSetRelation',
        protoName: 'blockSetRelation',
        subBuilder: Event_Block_Set_Relation.create)
    ..aOM<Event_Block_Set_Latex>(25, _omitFieldNames ? '' : 'blockSetLatex',
        protoName: 'blockSetLatex', subBuilder: Event_Block_Set_Latex.create)
    ..aOM<Event_Block_Set_VerticalAlign>(
        36, _omitFieldNames ? '' : 'blockSetVerticalAlign',
        protoName: 'blockSetVerticalAlign',
        subBuilder: Event_Block_Set_VerticalAlign.create)
    ..aOM<Event_Block_Set_TableRow>(
        37, _omitFieldNames ? '' : 'blockSetTableRow',
        protoName: 'blockSetTableRow',
        subBuilder: Event_Block_Set_TableRow.create)
    ..aOM<Event_Block_Set_Widget>(40, _omitFieldNames ? '' : 'blockSetWidget',
        protoName: 'blockSetWidget', subBuilder: Event_Block_Set_Widget.create)
    ..aOS(132, _omitFieldNames ? '' : 'spaceId', protoName: 'spaceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Message clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Message copyWith(void Function(Event_Message) updates) =>
      super.copyWith((message) => updates(message as Event_Message))
          as Event_Message;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Message create() => Event_Message._();
  @$core.override
  Event_Message createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Message getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Message>(create);
  static Event_Message? _defaultInstance;

  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(15)
  @$pb.TagNumber(17)
  @$pb.TagNumber(21)
  @$pb.TagNumber(25)
  @$pb.TagNumber(36)
  @$pb.TagNumber(37)
  @$pb.TagNumber(40)
  Event_Message_Value whichValue() =>
      _Event_Message_ValueByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(9)
  @$pb.TagNumber(10)
  @$pb.TagNumber(15)
  @$pb.TagNumber(17)
  @$pb.TagNumber(21)
  @$pb.TagNumber(25)
  @$pb.TagNumber(36)
  @$pb.TagNumber(37)
  @$pb.TagNumber(40)
  void clearValue() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(6)
  Event_Block_Set_Fields get blockSetFields => $_getN(0);
  @$pb.TagNumber(6)
  set blockSetFields(Event_Block_Set_Fields value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasBlockSetFields() => $_has(0);
  @$pb.TagNumber(6)
  void clearBlockSetFields() => $_clearField(6);
  @$pb.TagNumber(6)
  Event_Block_Set_Fields ensureBlockSetFields() => $_ensure(0);

  @$pb.TagNumber(7)
  Event_Block_Set_ChildrenIds get blockSetChildrenIds => $_getN(1);
  @$pb.TagNumber(7)
  set blockSetChildrenIds(Event_Block_Set_ChildrenIds value) =>
      $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasBlockSetChildrenIds() => $_has(1);
  @$pb.TagNumber(7)
  void clearBlockSetChildrenIds() => $_clearField(7);
  @$pb.TagNumber(7)
  Event_Block_Set_ChildrenIds ensureBlockSetChildrenIds() => $_ensure(1);

  @$pb.TagNumber(9)
  Event_Block_Set_BackgroundColor get blockSetBackgroundColor => $_getN(2);
  @$pb.TagNumber(9)
  set blockSetBackgroundColor(Event_Block_Set_BackgroundColor value) =>
      $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasBlockSetBackgroundColor() => $_has(2);
  @$pb.TagNumber(9)
  void clearBlockSetBackgroundColor() => $_clearField(9);
  @$pb.TagNumber(9)
  Event_Block_Set_BackgroundColor ensureBlockSetBackgroundColor() =>
      $_ensure(2);

  @$pb.TagNumber(10)
  Event_Block_Set_Text get blockSetText => $_getN(3);
  @$pb.TagNumber(10)
  set blockSetText(Event_Block_Set_Text value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasBlockSetText() => $_has(3);
  @$pb.TagNumber(10)
  void clearBlockSetText() => $_clearField(10);
  @$pb.TagNumber(10)
  Event_Block_Set_Text ensureBlockSetText() => $_ensure(3);

  @$pb.TagNumber(15)
  Event_Block_Set_Align get blockSetAlign => $_getN(4);
  @$pb.TagNumber(15)
  set blockSetAlign(Event_Block_Set_Align value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasBlockSetAlign() => $_has(4);
  @$pb.TagNumber(15)
  void clearBlockSetAlign() => $_clearField(15);
  @$pb.TagNumber(15)
  Event_Block_Set_Align ensureBlockSetAlign() => $_ensure(4);

  @$pb.TagNumber(17)
  Event_Block_Set_Div get blockSetDiv => $_getN(5);
  @$pb.TagNumber(17)
  set blockSetDiv(Event_Block_Set_Div value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasBlockSetDiv() => $_has(5);
  @$pb.TagNumber(17)
  void clearBlockSetDiv() => $_clearField(17);
  @$pb.TagNumber(17)
  Event_Block_Set_Div ensureBlockSetDiv() => $_ensure(5);

  @$pb.TagNumber(21)
  Event_Block_Set_Relation get blockSetRelation => $_getN(6);
  @$pb.TagNumber(21)
  set blockSetRelation(Event_Block_Set_Relation value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasBlockSetRelation() => $_has(6);
  @$pb.TagNumber(21)
  void clearBlockSetRelation() => $_clearField(21);
  @$pb.TagNumber(21)
  Event_Block_Set_Relation ensureBlockSetRelation() => $_ensure(6);

  @$pb.TagNumber(25)
  Event_Block_Set_Latex get blockSetLatex => $_getN(7);
  @$pb.TagNumber(25)
  set blockSetLatex(Event_Block_Set_Latex value) => $_setField(25, value);
  @$pb.TagNumber(25)
  $core.bool hasBlockSetLatex() => $_has(7);
  @$pb.TagNumber(25)
  void clearBlockSetLatex() => $_clearField(25);
  @$pb.TagNumber(25)
  Event_Block_Set_Latex ensureBlockSetLatex() => $_ensure(7);

  @$pb.TagNumber(36)
  Event_Block_Set_VerticalAlign get blockSetVerticalAlign => $_getN(8);
  @$pb.TagNumber(36)
  set blockSetVerticalAlign(Event_Block_Set_VerticalAlign value) =>
      $_setField(36, value);
  @$pb.TagNumber(36)
  $core.bool hasBlockSetVerticalAlign() => $_has(8);
  @$pb.TagNumber(36)
  void clearBlockSetVerticalAlign() => $_clearField(36);
  @$pb.TagNumber(36)
  Event_Block_Set_VerticalAlign ensureBlockSetVerticalAlign() => $_ensure(8);

  @$pb.TagNumber(37)
  Event_Block_Set_TableRow get blockSetTableRow => $_getN(9);
  @$pb.TagNumber(37)
  set blockSetTableRow(Event_Block_Set_TableRow value) => $_setField(37, value);
  @$pb.TagNumber(37)
  $core.bool hasBlockSetTableRow() => $_has(9);
  @$pb.TagNumber(37)
  void clearBlockSetTableRow() => $_clearField(37);
  @$pb.TagNumber(37)
  Event_Block_Set_TableRow ensureBlockSetTableRow() => $_ensure(9);

  @$pb.TagNumber(40)
  Event_Block_Set_Widget get blockSetWidget => $_getN(10);
  @$pb.TagNumber(40)
  set blockSetWidget(Event_Block_Set_Widget value) => $_setField(40, value);
  @$pb.TagNumber(40)
  $core.bool hasBlockSetWidget() => $_has(10);
  @$pb.TagNumber(40)
  void clearBlockSetWidget() => $_clearField(40);
  @$pb.TagNumber(40)
  Event_Block_Set_Widget ensureBlockSetWidget() => $_ensure(10);

  @$pb.TagNumber(132)
  $core.String get spaceId => $_getSZ(11);
  @$pb.TagNumber(132)
  set spaceId($core.String value) => $_setString(11, value);
  @$pb.TagNumber(132)
  $core.bool hasSpaceId() => $_has(11);
  @$pb.TagNumber(132)
  void clearSpaceId() => $_clearField(132);
}

class Event_Block_Set_Relation_Key extends $pb.GeneratedMessage {
  factory Event_Block_Set_Relation_Key({
    $core.String? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  Event_Block_Set_Relation_Key._();

  factory Event_Block_Set_Relation_Key.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Relation_Key.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Relation.Key',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Relation_Key clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Relation_Key copyWith(
          void Function(Event_Block_Set_Relation_Key) updates) =>
      super.copyWith(
              (message) => updates(message as Event_Block_Set_Relation_Key))
          as Event_Block_Set_Relation_Key;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Relation_Key create() =>
      Event_Block_Set_Relation_Key._();
  @$core.override
  Event_Block_Set_Relation_Key createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Relation_Key getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Relation_Key>(create);
  static Event_Block_Set_Relation_Key? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class Event_Block_Set_Relation extends $pb.GeneratedMessage {
  factory Event_Block_Set_Relation({
    $core.String? id,
    Event_Block_Set_Relation_Key? key,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (key != null) result.key = key;
    return result;
  }

  Event_Block_Set_Relation._();

  factory Event_Block_Set_Relation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Relation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Relation',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<Event_Block_Set_Relation_Key>(2, _omitFieldNames ? '' : 'key',
        subBuilder: Event_Block_Set_Relation_Key.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Relation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Relation copyWith(
          void Function(Event_Block_Set_Relation) updates) =>
      super.copyWith((message) => updates(message as Event_Block_Set_Relation))
          as Event_Block_Set_Relation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Relation create() => Event_Block_Set_Relation._();
  @$core.override
  Event_Block_Set_Relation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Relation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Relation>(create);
  static Event_Block_Set_Relation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  Event_Block_Set_Relation_Key get key => $_getN(1);
  @$pb.TagNumber(2)
  set key(Event_Block_Set_Relation_Key value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearKey() => $_clearField(2);
  @$pb.TagNumber(2)
  Event_Block_Set_Relation_Key ensureKey() => $_ensure(1);
}

class Event_Block_Set_Fields extends $pb.GeneratedMessage {
  factory Event_Block_Set_Fields({
    $core.String? id,
    $0.Struct? fields,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (fields != null) result.fields = fields;
    return result;
  }

  Event_Block_Set_Fields._();

  factory Event_Block_Set_Fields.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Fields.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Fields',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$0.Struct>(2, _omitFieldNames ? '' : 'fields',
        subBuilder: $0.Struct.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Fields clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Fields copyWith(
          void Function(Event_Block_Set_Fields) updates) =>
      super.copyWith((message) => updates(message as Event_Block_Set_Fields))
          as Event_Block_Set_Fields;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Fields create() => Event_Block_Set_Fields._();
  @$core.override
  Event_Block_Set_Fields createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Fields getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Fields>(create);
  static Event_Block_Set_Fields? _defaultInstance;

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

class Event_Block_Set_ChildrenIds extends $pb.GeneratedMessage {
  factory Event_Block_Set_ChildrenIds({
    $core.String? id,
    $core.Iterable<$core.String>? childrenIds,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (childrenIds != null) result.childrenIds.addAll(childrenIds);
    return result;
  }

  Event_Block_Set_ChildrenIds._();

  factory Event_Block_Set_ChildrenIds.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_ChildrenIds.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.ChildrenIds',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..pPS(2, _omitFieldNames ? '' : 'childrenIds', protoName: 'childrenIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_ChildrenIds clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_ChildrenIds copyWith(
          void Function(Event_Block_Set_ChildrenIds) updates) =>
      super.copyWith(
              (message) => updates(message as Event_Block_Set_ChildrenIds))
          as Event_Block_Set_ChildrenIds;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_ChildrenIds create() =>
      Event_Block_Set_ChildrenIds._();
  @$core.override
  Event_Block_Set_ChildrenIds createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_ChildrenIds getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_ChildrenIds>(create);
  static Event_Block_Set_ChildrenIds? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get childrenIds => $_getList(1);
}

class Event_Block_Set_BackgroundColor extends $pb.GeneratedMessage {
  factory Event_Block_Set_BackgroundColor({
    $core.String? id,
    $core.String? backgroundColor,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (backgroundColor != null) result.backgroundColor = backgroundColor;
    return result;
  }

  Event_Block_Set_BackgroundColor._();

  factory Event_Block_Set_BackgroundColor.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_BackgroundColor.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.BackgroundColor',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'backgroundColor',
        protoName: 'backgroundColor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_BackgroundColor clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_BackgroundColor copyWith(
          void Function(Event_Block_Set_BackgroundColor) updates) =>
      super.copyWith(
              (message) => updates(message as Event_Block_Set_BackgroundColor))
          as Event_Block_Set_BackgroundColor;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_BackgroundColor create() =>
      Event_Block_Set_BackgroundColor._();
  @$core.override
  Event_Block_Set_BackgroundColor createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_BackgroundColor getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_BackgroundColor>(
          create);
  static Event_Block_Set_BackgroundColor? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get backgroundColor => $_getSZ(1);
  @$pb.TagNumber(2)
  set backgroundColor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBackgroundColor() => $_has(1);
  @$pb.TagNumber(2)
  void clearBackgroundColor() => $_clearField(2);
}

class Event_Block_Set_Align extends $pb.GeneratedMessage {
  factory Event_Block_Set_Align({
    $core.String? id,
    $1.Block_Align? align,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (align != null) result.align = align;
    return result;
  }

  Event_Block_Set_Align._();

  factory Event_Block_Set_Align.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Align.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Align',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<$1.Block_Align>(2, _omitFieldNames ? '' : 'align',
        enumValues: $1.Block_Align.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Align clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Align copyWith(
          void Function(Event_Block_Set_Align) updates) =>
      super.copyWith((message) => updates(message as Event_Block_Set_Align))
          as Event_Block_Set_Align;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Align create() => Event_Block_Set_Align._();
  @$core.override
  Event_Block_Set_Align createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Align getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Align>(create);
  static Event_Block_Set_Align? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Block_Align get align => $_getN(1);
  @$pb.TagNumber(2)
  set align($1.Block_Align value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAlign() => $_has(1);
  @$pb.TagNumber(2)
  void clearAlign() => $_clearField(2);
}

class Event_Block_Set_VerticalAlign extends $pb.GeneratedMessage {
  factory Event_Block_Set_VerticalAlign({
    $core.String? id,
    $1.Block_VerticalAlign? verticalAlign,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (verticalAlign != null) result.verticalAlign = verticalAlign;
    return result;
  }

  Event_Block_Set_VerticalAlign._();

  factory Event_Block_Set_VerticalAlign.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_VerticalAlign.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.VerticalAlign',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<$1.Block_VerticalAlign>(2, _omitFieldNames ? '' : 'verticalAlign',
        protoName: 'verticalAlign', enumValues: $1.Block_VerticalAlign.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_VerticalAlign clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_VerticalAlign copyWith(
          void Function(Event_Block_Set_VerticalAlign) updates) =>
      super.copyWith(
              (message) => updates(message as Event_Block_Set_VerticalAlign))
          as Event_Block_Set_VerticalAlign;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_VerticalAlign create() =>
      Event_Block_Set_VerticalAlign._();
  @$core.override
  Event_Block_Set_VerticalAlign createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_VerticalAlign getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_VerticalAlign>(create);
  static Event_Block_Set_VerticalAlign? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.Block_VerticalAlign get verticalAlign => $_getN(1);
  @$pb.TagNumber(2)
  set verticalAlign($1.Block_VerticalAlign value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasVerticalAlign() => $_has(1);
  @$pb.TagNumber(2)
  void clearVerticalAlign() => $_clearField(2);
}

class Event_Block_Set_Text_TextValue extends $pb.GeneratedMessage {
  factory Event_Block_Set_Text_TextValue({
    $core.String? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  Event_Block_Set_Text_TextValue._();

  factory Event_Block_Set_Text_TextValue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Text_TextValue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Text.TextValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Text_TextValue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Text_TextValue copyWith(
          void Function(Event_Block_Set_Text_TextValue) updates) =>
      super.copyWith(
              (message) => updates(message as Event_Block_Set_Text_TextValue))
          as Event_Block_Set_Text_TextValue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Text_TextValue create() =>
      Event_Block_Set_Text_TextValue._();
  @$core.override
  Event_Block_Set_Text_TextValue createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Text_TextValue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Text_TextValue>(create);
  static Event_Block_Set_Text_TextValue? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class Event_Block_Set_Text_Style extends $pb.GeneratedMessage {
  factory Event_Block_Set_Text_Style({
    $1.Block_Content_Text_Style? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  Event_Block_Set_Text_Style._();

  factory Event_Block_Set_Text_Style.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Text_Style.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Text.Style',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aE<$1.Block_Content_Text_Style>(1, _omitFieldNames ? '' : 'value',
        enumValues: $1.Block_Content_Text_Style.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Text_Style clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Text_Style copyWith(
          void Function(Event_Block_Set_Text_Style) updates) =>
      super.copyWith(
              (message) => updates(message as Event_Block_Set_Text_Style))
          as Event_Block_Set_Text_Style;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Text_Style create() => Event_Block_Set_Text_Style._();
  @$core.override
  Event_Block_Set_Text_Style createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Text_Style getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Text_Style>(create);
  static Event_Block_Set_Text_Style? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Block_Content_Text_Style get value => $_getN(0);
  @$pb.TagNumber(1)
  set value($1.Block_Content_Text_Style value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class Event_Block_Set_Text_Marks extends $pb.GeneratedMessage {
  factory Event_Block_Set_Text_Marks({
    $1.Block_Content_Text_Marks? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  Event_Block_Set_Text_Marks._();

  factory Event_Block_Set_Text_Marks.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Text_Marks.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Text.Marks',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOM<$1.Block_Content_Text_Marks>(1, _omitFieldNames ? '' : 'value',
        subBuilder: $1.Block_Content_Text_Marks.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Text_Marks clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Text_Marks copyWith(
          void Function(Event_Block_Set_Text_Marks) updates) =>
      super.copyWith(
              (message) => updates(message as Event_Block_Set_Text_Marks))
          as Event_Block_Set_Text_Marks;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Text_Marks create() => Event_Block_Set_Text_Marks._();
  @$core.override
  Event_Block_Set_Text_Marks createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Text_Marks getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Text_Marks>(create);
  static Event_Block_Set_Text_Marks? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Block_Content_Text_Marks get value => $_getN(0);
  @$pb.TagNumber(1)
  set value($1.Block_Content_Text_Marks value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.Block_Content_Text_Marks ensureValue() => $_ensure(0);
}

class Event_Block_Set_Text_Checked extends $pb.GeneratedMessage {
  factory Event_Block_Set_Text_Checked({
    $core.bool? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  Event_Block_Set_Text_Checked._();

  factory Event_Block_Set_Text_Checked.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Text_Checked.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Text.Checked',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Text_Checked clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Text_Checked copyWith(
          void Function(Event_Block_Set_Text_Checked) updates) =>
      super.copyWith(
              (message) => updates(message as Event_Block_Set_Text_Checked))
          as Event_Block_Set_Text_Checked;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Text_Checked create() =>
      Event_Block_Set_Text_Checked._();
  @$core.override
  Event_Block_Set_Text_Checked createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Text_Checked getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Text_Checked>(create);
  static Event_Block_Set_Text_Checked? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get value => $_getBF(0);
  @$pb.TagNumber(1)
  set value($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class Event_Block_Set_Text_Color extends $pb.GeneratedMessage {
  factory Event_Block_Set_Text_Color({
    $core.String? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  Event_Block_Set_Text_Color._();

  factory Event_Block_Set_Text_Color.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Text_Color.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Text.Color',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Text_Color clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Text_Color copyWith(
          void Function(Event_Block_Set_Text_Color) updates) =>
      super.copyWith(
              (message) => updates(message as Event_Block_Set_Text_Color))
          as Event_Block_Set_Text_Color;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Text_Color create() => Event_Block_Set_Text_Color._();
  @$core.override
  Event_Block_Set_Text_Color createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Text_Color getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Text_Color>(create);
  static Event_Block_Set_Text_Color? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class Event_Block_Set_Text_IconEmoji extends $pb.GeneratedMessage {
  factory Event_Block_Set_Text_IconEmoji({
    $core.String? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  Event_Block_Set_Text_IconEmoji._();

  factory Event_Block_Set_Text_IconEmoji.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Text_IconEmoji.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Text.IconEmoji',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Text_IconEmoji clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Text_IconEmoji copyWith(
          void Function(Event_Block_Set_Text_IconEmoji) updates) =>
      super.copyWith(
              (message) => updates(message as Event_Block_Set_Text_IconEmoji))
          as Event_Block_Set_Text_IconEmoji;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Text_IconEmoji create() =>
      Event_Block_Set_Text_IconEmoji._();
  @$core.override
  Event_Block_Set_Text_IconEmoji createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Text_IconEmoji getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Text_IconEmoji>(create);
  static Event_Block_Set_Text_IconEmoji? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class Event_Block_Set_Text_IconImage extends $pb.GeneratedMessage {
  factory Event_Block_Set_Text_IconImage({
    $core.String? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  Event_Block_Set_Text_IconImage._();

  factory Event_Block_Set_Text_IconImage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Text_IconImage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Text.IconImage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Text_IconImage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Text_IconImage copyWith(
          void Function(Event_Block_Set_Text_IconImage) updates) =>
      super.copyWith(
              (message) => updates(message as Event_Block_Set_Text_IconImage))
          as Event_Block_Set_Text_IconImage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Text_IconImage create() =>
      Event_Block_Set_Text_IconImage._();
  @$core.override
  Event_Block_Set_Text_IconImage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Text_IconImage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Text_IconImage>(create);
  static Event_Block_Set_Text_IconImage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class Event_Block_Set_Text extends $pb.GeneratedMessage {
  factory Event_Block_Set_Text({
    $core.String? id,
    Event_Block_Set_Text_TextValue? text,
    Event_Block_Set_Text_Style? style,
    Event_Block_Set_Text_Marks? marks,
    Event_Block_Set_Text_Checked? checked,
    Event_Block_Set_Text_Color? color,
    Event_Block_Set_Text_IconEmoji? iconEmoji,
    Event_Block_Set_Text_IconImage? iconImage,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (text != null) result.text = text;
    if (style != null) result.style = style;
    if (marks != null) result.marks = marks;
    if (checked != null) result.checked = checked;
    if (color != null) result.color = color;
    if (iconEmoji != null) result.iconEmoji = iconEmoji;
    if (iconImage != null) result.iconImage = iconImage;
    return result;
  }

  Event_Block_Set_Text._();

  factory Event_Block_Set_Text.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Text.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Text',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<Event_Block_Set_Text_TextValue>(2, _omitFieldNames ? '' : 'text',
        subBuilder: Event_Block_Set_Text_TextValue.create)
    ..aOM<Event_Block_Set_Text_Style>(3, _omitFieldNames ? '' : 'style',
        subBuilder: Event_Block_Set_Text_Style.create)
    ..aOM<Event_Block_Set_Text_Marks>(4, _omitFieldNames ? '' : 'marks',
        subBuilder: Event_Block_Set_Text_Marks.create)
    ..aOM<Event_Block_Set_Text_Checked>(5, _omitFieldNames ? '' : 'checked',
        subBuilder: Event_Block_Set_Text_Checked.create)
    ..aOM<Event_Block_Set_Text_Color>(6, _omitFieldNames ? '' : 'color',
        subBuilder: Event_Block_Set_Text_Color.create)
    ..aOM<Event_Block_Set_Text_IconEmoji>(7, _omitFieldNames ? '' : 'iconEmoji',
        protoName: 'iconEmoji',
        subBuilder: Event_Block_Set_Text_IconEmoji.create)
    ..aOM<Event_Block_Set_Text_IconImage>(8, _omitFieldNames ? '' : 'iconImage',
        protoName: 'iconImage',
        subBuilder: Event_Block_Set_Text_IconImage.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Text clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Text copyWith(void Function(Event_Block_Set_Text) updates) =>
      super.copyWith((message) => updates(message as Event_Block_Set_Text))
          as Event_Block_Set_Text;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Text create() => Event_Block_Set_Text._();
  @$core.override
  Event_Block_Set_Text createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Text getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Text>(create);
  static Event_Block_Set_Text? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  Event_Block_Set_Text_TextValue get text => $_getN(1);
  @$pb.TagNumber(2)
  set text(Event_Block_Set_Text_TextValue value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);
  @$pb.TagNumber(2)
  Event_Block_Set_Text_TextValue ensureText() => $_ensure(1);

  @$pb.TagNumber(3)
  Event_Block_Set_Text_Style get style => $_getN(2);
  @$pb.TagNumber(3)
  set style(Event_Block_Set_Text_Style value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStyle() => $_has(2);
  @$pb.TagNumber(3)
  void clearStyle() => $_clearField(3);
  @$pb.TagNumber(3)
  Event_Block_Set_Text_Style ensureStyle() => $_ensure(2);

  @$pb.TagNumber(4)
  Event_Block_Set_Text_Marks get marks => $_getN(3);
  @$pb.TagNumber(4)
  set marks(Event_Block_Set_Text_Marks value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasMarks() => $_has(3);
  @$pb.TagNumber(4)
  void clearMarks() => $_clearField(4);
  @$pb.TagNumber(4)
  Event_Block_Set_Text_Marks ensureMarks() => $_ensure(3);

  @$pb.TagNumber(5)
  Event_Block_Set_Text_Checked get checked => $_getN(4);
  @$pb.TagNumber(5)
  set checked(Event_Block_Set_Text_Checked value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasChecked() => $_has(4);
  @$pb.TagNumber(5)
  void clearChecked() => $_clearField(5);
  @$pb.TagNumber(5)
  Event_Block_Set_Text_Checked ensureChecked() => $_ensure(4);

  @$pb.TagNumber(6)
  Event_Block_Set_Text_Color get color => $_getN(5);
  @$pb.TagNumber(6)
  set color(Event_Block_Set_Text_Color value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasColor() => $_has(5);
  @$pb.TagNumber(6)
  void clearColor() => $_clearField(6);
  @$pb.TagNumber(6)
  Event_Block_Set_Text_Color ensureColor() => $_ensure(5);

  @$pb.TagNumber(7)
  Event_Block_Set_Text_IconEmoji get iconEmoji => $_getN(6);
  @$pb.TagNumber(7)
  set iconEmoji(Event_Block_Set_Text_IconEmoji value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasIconEmoji() => $_has(6);
  @$pb.TagNumber(7)
  void clearIconEmoji() => $_clearField(7);
  @$pb.TagNumber(7)
  Event_Block_Set_Text_IconEmoji ensureIconEmoji() => $_ensure(6);

  @$pb.TagNumber(8)
  Event_Block_Set_Text_IconImage get iconImage => $_getN(7);
  @$pb.TagNumber(8)
  set iconImage(Event_Block_Set_Text_IconImage value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasIconImage() => $_has(7);
  @$pb.TagNumber(8)
  void clearIconImage() => $_clearField(8);
  @$pb.TagNumber(8)
  Event_Block_Set_Text_IconImage ensureIconImage() => $_ensure(7);
}

class Event_Block_Set_Latex_TextValue extends $pb.GeneratedMessage {
  factory Event_Block_Set_Latex_TextValue({
    $core.String? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  Event_Block_Set_Latex_TextValue._();

  factory Event_Block_Set_Latex_TextValue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Latex_TextValue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Latex.TextValue',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Latex_TextValue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Latex_TextValue copyWith(
          void Function(Event_Block_Set_Latex_TextValue) updates) =>
      super.copyWith(
              (message) => updates(message as Event_Block_Set_Latex_TextValue))
          as Event_Block_Set_Latex_TextValue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Latex_TextValue create() =>
      Event_Block_Set_Latex_TextValue._();
  @$core.override
  Event_Block_Set_Latex_TextValue createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Latex_TextValue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Latex_TextValue>(
          create);
  static Event_Block_Set_Latex_TextValue? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class Event_Block_Set_Latex_Processor extends $pb.GeneratedMessage {
  factory Event_Block_Set_Latex_Processor({
    $1.Block_Content_Latex_Processor? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  Event_Block_Set_Latex_Processor._();

  factory Event_Block_Set_Latex_Processor.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Latex_Processor.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Latex.Processor',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aE<$1.Block_Content_Latex_Processor>(1, _omitFieldNames ? '' : 'value',
        enumValues: $1.Block_Content_Latex_Processor.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Latex_Processor clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Latex_Processor copyWith(
          void Function(Event_Block_Set_Latex_Processor) updates) =>
      super.copyWith(
              (message) => updates(message as Event_Block_Set_Latex_Processor))
          as Event_Block_Set_Latex_Processor;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Latex_Processor create() =>
      Event_Block_Set_Latex_Processor._();
  @$core.override
  Event_Block_Set_Latex_Processor createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Latex_Processor getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Latex_Processor>(
          create);
  static Event_Block_Set_Latex_Processor? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Block_Content_Latex_Processor get value => $_getN(0);
  @$pb.TagNumber(1)
  set value($1.Block_Content_Latex_Processor value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class Event_Block_Set_Latex extends $pb.GeneratedMessage {
  factory Event_Block_Set_Latex({
    $core.String? id,
    Event_Block_Set_Latex_TextValue? text,
    Event_Block_Set_Latex_Processor? processor,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (text != null) result.text = text;
    if (processor != null) result.processor = processor;
    return result;
  }

  Event_Block_Set_Latex._();

  factory Event_Block_Set_Latex.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Latex.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Latex',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<Event_Block_Set_Latex_TextValue>(2, _omitFieldNames ? '' : 'text',
        subBuilder: Event_Block_Set_Latex_TextValue.create)
    ..aOM<Event_Block_Set_Latex_Processor>(
        3, _omitFieldNames ? '' : 'processor',
        subBuilder: Event_Block_Set_Latex_Processor.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Latex clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Latex copyWith(
          void Function(Event_Block_Set_Latex) updates) =>
      super.copyWith((message) => updates(message as Event_Block_Set_Latex))
          as Event_Block_Set_Latex;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Latex create() => Event_Block_Set_Latex._();
  @$core.override
  Event_Block_Set_Latex createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Latex getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Latex>(create);
  static Event_Block_Set_Latex? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  Event_Block_Set_Latex_TextValue get text => $_getN(1);
  @$pb.TagNumber(2)
  set text(Event_Block_Set_Latex_TextValue value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasText() => $_has(1);
  @$pb.TagNumber(2)
  void clearText() => $_clearField(2);
  @$pb.TagNumber(2)
  Event_Block_Set_Latex_TextValue ensureText() => $_ensure(1);

  @$pb.TagNumber(3)
  Event_Block_Set_Latex_Processor get processor => $_getN(2);
  @$pb.TagNumber(3)
  set processor(Event_Block_Set_Latex_Processor value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasProcessor() => $_has(2);
  @$pb.TagNumber(3)
  void clearProcessor() => $_clearField(3);
  @$pb.TagNumber(3)
  Event_Block_Set_Latex_Processor ensureProcessor() => $_ensure(2);
}

class Event_Block_Set_Div_Style extends $pb.GeneratedMessage {
  factory Event_Block_Set_Div_Style({
    $1.Block_Content_Div_Style? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  Event_Block_Set_Div_Style._();

  factory Event_Block_Set_Div_Style.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Div_Style.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Div.Style',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aE<$1.Block_Content_Div_Style>(1, _omitFieldNames ? '' : 'value',
        enumValues: $1.Block_Content_Div_Style.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Div_Style clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Div_Style copyWith(
          void Function(Event_Block_Set_Div_Style) updates) =>
      super.copyWith((message) => updates(message as Event_Block_Set_Div_Style))
          as Event_Block_Set_Div_Style;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Div_Style create() => Event_Block_Set_Div_Style._();
  @$core.override
  Event_Block_Set_Div_Style createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Div_Style getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Div_Style>(create);
  static Event_Block_Set_Div_Style? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Block_Content_Div_Style get value => $_getN(0);
  @$pb.TagNumber(1)
  set value($1.Block_Content_Div_Style value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class Event_Block_Set_Div extends $pb.GeneratedMessage {
  factory Event_Block_Set_Div({
    $core.String? id,
    Event_Block_Set_Div_Style? style,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (style != null) result.style = style;
    return result;
  }

  Event_Block_Set_Div._();

  factory Event_Block_Set_Div.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Div.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Div',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<Event_Block_Set_Div_Style>(2, _omitFieldNames ? '' : 'style',
        subBuilder: Event_Block_Set_Div_Style.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Div clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Div copyWith(void Function(Event_Block_Set_Div) updates) =>
      super.copyWith((message) => updates(message as Event_Block_Set_Div))
          as Event_Block_Set_Div;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Div create() => Event_Block_Set_Div._();
  @$core.override
  Event_Block_Set_Div createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Div getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Div>(create);
  static Event_Block_Set_Div? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  Event_Block_Set_Div_Style get style => $_getN(1);
  @$pb.TagNumber(2)
  set style(Event_Block_Set_Div_Style value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStyle() => $_has(1);
  @$pb.TagNumber(2)
  void clearStyle() => $_clearField(2);
  @$pb.TagNumber(2)
  Event_Block_Set_Div_Style ensureStyle() => $_ensure(1);
}

class Event_Block_Set_TableRow_IsHeader extends $pb.GeneratedMessage {
  factory Event_Block_Set_TableRow_IsHeader({
    $core.bool? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  Event_Block_Set_TableRow_IsHeader._();

  factory Event_Block_Set_TableRow_IsHeader.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_TableRow_IsHeader.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.TableRow.IsHeader',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_TableRow_IsHeader clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_TableRow_IsHeader copyWith(
          void Function(Event_Block_Set_TableRow_IsHeader) updates) =>
      super.copyWith((message) =>
              updates(message as Event_Block_Set_TableRow_IsHeader))
          as Event_Block_Set_TableRow_IsHeader;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_TableRow_IsHeader create() =>
      Event_Block_Set_TableRow_IsHeader._();
  @$core.override
  Event_Block_Set_TableRow_IsHeader createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_TableRow_IsHeader getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_TableRow_IsHeader>(
          create);
  static Event_Block_Set_TableRow_IsHeader? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get value => $_getBF(0);
  @$pb.TagNumber(1)
  set value($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class Event_Block_Set_TableRow extends $pb.GeneratedMessage {
  factory Event_Block_Set_TableRow({
    $core.String? id,
    Event_Block_Set_TableRow_IsHeader? isHeader,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (isHeader != null) result.isHeader = isHeader;
    return result;
  }

  Event_Block_Set_TableRow._();

  factory Event_Block_Set_TableRow.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_TableRow.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.TableRow',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<Event_Block_Set_TableRow_IsHeader>(
        2, _omitFieldNames ? '' : 'isHeader',
        protoName: 'isHeader',
        subBuilder: Event_Block_Set_TableRow_IsHeader.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_TableRow clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_TableRow copyWith(
          void Function(Event_Block_Set_TableRow) updates) =>
      super.copyWith((message) => updates(message as Event_Block_Set_TableRow))
          as Event_Block_Set_TableRow;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_TableRow create() => Event_Block_Set_TableRow._();
  @$core.override
  Event_Block_Set_TableRow createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_TableRow getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_TableRow>(create);
  static Event_Block_Set_TableRow? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  Event_Block_Set_TableRow_IsHeader get isHeader => $_getN(1);
  @$pb.TagNumber(2)
  set isHeader(Event_Block_Set_TableRow_IsHeader value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasIsHeader() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsHeader() => $_clearField(2);
  @$pb.TagNumber(2)
  Event_Block_Set_TableRow_IsHeader ensureIsHeader() => $_ensure(1);
}

class Event_Block_Set_Widget_Layout extends $pb.GeneratedMessage {
  factory Event_Block_Set_Widget_Layout({
    $1.Block_Content_Widget_Layout? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  Event_Block_Set_Widget_Layout._();

  factory Event_Block_Set_Widget_Layout.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Widget_Layout.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Widget.Layout',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aE<$1.Block_Content_Widget_Layout>(1, _omitFieldNames ? '' : 'value',
        enumValues: $1.Block_Content_Widget_Layout.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Widget_Layout clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Widget_Layout copyWith(
          void Function(Event_Block_Set_Widget_Layout) updates) =>
      super.copyWith(
              (message) => updates(message as Event_Block_Set_Widget_Layout))
          as Event_Block_Set_Widget_Layout;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Widget_Layout create() =>
      Event_Block_Set_Widget_Layout._();
  @$core.override
  Event_Block_Set_Widget_Layout createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Widget_Layout getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Widget_Layout>(create);
  static Event_Block_Set_Widget_Layout? _defaultInstance;

  @$pb.TagNumber(1)
  $1.Block_Content_Widget_Layout get value => $_getN(0);
  @$pb.TagNumber(1)
  set value($1.Block_Content_Widget_Layout value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class Event_Block_Set_Widget_Limit extends $pb.GeneratedMessage {
  factory Event_Block_Set_Widget_Limit({
    $core.int? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  Event_Block_Set_Widget_Limit._();

  factory Event_Block_Set_Widget_Limit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Widget_Limit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Widget.Limit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Widget_Limit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Widget_Limit copyWith(
          void Function(Event_Block_Set_Widget_Limit) updates) =>
      super.copyWith(
              (message) => updates(message as Event_Block_Set_Widget_Limit))
          as Event_Block_Set_Widget_Limit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Widget_Limit create() =>
      Event_Block_Set_Widget_Limit._();
  @$core.override
  Event_Block_Set_Widget_Limit createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Widget_Limit getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Widget_Limit>(create);
  static Event_Block_Set_Widget_Limit? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get value => $_getIZ(0);
  @$pb.TagNumber(1)
  set value($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class Event_Block_Set_Widget_ViewId extends $pb.GeneratedMessage {
  factory Event_Block_Set_Widget_ViewId({
    $core.String? value,
  }) {
    final result = create();
    if (value != null) result.value = value;
    return result;
  }

  Event_Block_Set_Widget_ViewId._();

  factory Event_Block_Set_Widget_ViewId.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Widget_ViewId.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Widget.ViewId',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Widget_ViewId clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Widget_ViewId copyWith(
          void Function(Event_Block_Set_Widget_ViewId) updates) =>
      super.copyWith(
              (message) => updates(message as Event_Block_Set_Widget_ViewId))
          as Event_Block_Set_Widget_ViewId;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Widget_ViewId create() =>
      Event_Block_Set_Widget_ViewId._();
  @$core.override
  Event_Block_Set_Widget_ViewId createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Widget_ViewId getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Widget_ViewId>(create);
  static Event_Block_Set_Widget_ViewId? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);
}

class Event_Block_Set_Widget extends $pb.GeneratedMessage {
  factory Event_Block_Set_Widget({
    $core.String? id,
    Event_Block_Set_Widget_Layout? layout,
    Event_Block_Set_Widget_Limit? limit,
    Event_Block_Set_Widget_ViewId? viewId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (layout != null) result.layout = layout;
    if (limit != null) result.limit = limit;
    if (viewId != null) result.viewId = viewId;
    return result;
  }

  Event_Block_Set_Widget._();

  factory Event_Block_Set_Widget.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set_Widget.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set.Widget',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<Event_Block_Set_Widget_Layout>(2, _omitFieldNames ? '' : 'layout',
        subBuilder: Event_Block_Set_Widget_Layout.create)
    ..aOM<Event_Block_Set_Widget_Limit>(3, _omitFieldNames ? '' : 'limit',
        subBuilder: Event_Block_Set_Widget_Limit.create)
    ..aOM<Event_Block_Set_Widget_ViewId>(4, _omitFieldNames ? '' : 'viewId',
        protoName: 'viewId', subBuilder: Event_Block_Set_Widget_ViewId.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Widget clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set_Widget copyWith(
          void Function(Event_Block_Set_Widget) updates) =>
      super.copyWith((message) => updates(message as Event_Block_Set_Widget))
          as Event_Block_Set_Widget;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Widget create() => Event_Block_Set_Widget._();
  @$core.override
  Event_Block_Set_Widget createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set_Widget getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set_Widget>(create);
  static Event_Block_Set_Widget? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  Event_Block_Set_Widget_Layout get layout => $_getN(1);
  @$pb.TagNumber(2)
  set layout(Event_Block_Set_Widget_Layout value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasLayout() => $_has(1);
  @$pb.TagNumber(2)
  void clearLayout() => $_clearField(2);
  @$pb.TagNumber(2)
  Event_Block_Set_Widget_Layout ensureLayout() => $_ensure(1);

  @$pb.TagNumber(3)
  Event_Block_Set_Widget_Limit get limit => $_getN(2);
  @$pb.TagNumber(3)
  set limit(Event_Block_Set_Widget_Limit value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);
  @$pb.TagNumber(3)
  Event_Block_Set_Widget_Limit ensureLimit() => $_ensure(2);

  @$pb.TagNumber(4)
  Event_Block_Set_Widget_ViewId get viewId => $_getN(3);
  @$pb.TagNumber(4)
  set viewId(Event_Block_Set_Widget_ViewId value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasViewId() => $_has(3);
  @$pb.TagNumber(4)
  void clearViewId() => $_clearField(4);
  @$pb.TagNumber(4)
  Event_Block_Set_Widget_ViewId ensureViewId() => $_ensure(3);
}

class Event_Block_Set extends $pb.GeneratedMessage {
  factory Event_Block_Set() => create();

  Event_Block_Set._();

  factory Event_Block_Set.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block_Set.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block.Set',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block_Set copyWith(void Function(Event_Block_Set) updates) =>
      super.copyWith((message) => updates(message as Event_Block_Set))
          as Event_Block_Set;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block_Set create() => Event_Block_Set._();
  @$core.override
  Event_Block_Set createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block_Set getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block_Set>(create);
  static Event_Block_Set? _defaultInstance;
}

class Event_Block extends $pb.GeneratedMessage {
  factory Event_Block() => create();

  Event_Block._();

  factory Event_Block.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event_Block.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event.Block',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event_Block copyWith(void Function(Event_Block) updates) =>
      super.copyWith((message) => updates(message as Event_Block))
          as Event_Block;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event_Block create() => Event_Block._();
  @$core.override
  Event_Block createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event_Block getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Event_Block>(create);
  static Event_Block? _defaultInstance;
}

class Event extends $pb.GeneratedMessage {
  factory Event() => create();

  Event._();

  factory Event.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Event.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Event',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'anytype'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Event copyWith(void Function(Event) updates) =>
      super.copyWith((message) => updates(message as Event)) as Event;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Event create() => Event._();
  @$core.override
  Event createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Event getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Event>(create);
  static Event? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
