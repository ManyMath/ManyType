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

import 'package:protobuf/protobuf.dart' as $pb;

class SmartBlockType extends $pb.ProtobufEnum {
  static const SmartBlockType AccountOld =
      SmartBlockType._(0, _omitEnumNames ? '' : 'AccountOld');
  static const SmartBlockType Page =
      SmartBlockType._(16, _omitEnumNames ? '' : 'Page');
  static const SmartBlockType ProfilePage =
      SmartBlockType._(17, _omitEnumNames ? '' : 'ProfilePage');
  static const SmartBlockType Home =
      SmartBlockType._(32, _omitEnumNames ? '' : 'Home');
  static const SmartBlockType Archive =
      SmartBlockType._(48, _omitEnumNames ? '' : 'Archive');
  static const SmartBlockType Widget =
      SmartBlockType._(112, _omitEnumNames ? '' : 'Widget');
  static const SmartBlockType File =
      SmartBlockType._(256, _omitEnumNames ? '' : 'File');
  static const SmartBlockType Template =
      SmartBlockType._(288, _omitEnumNames ? '' : 'Template');
  static const SmartBlockType BundledTemplate =
      SmartBlockType._(289, _omitEnumNames ? '' : 'BundledTemplate');
  static const SmartBlockType BundledRelation =
      SmartBlockType._(512, _omitEnumNames ? '' : 'BundledRelation');
  static const SmartBlockType SubObject =
      SmartBlockType._(513, _omitEnumNames ? '' : 'SubObject');
  static const SmartBlockType BundledObjectType =
      SmartBlockType._(514, _omitEnumNames ? '' : 'BundledObjectType');
  static const SmartBlockType AnytypeProfile =
      SmartBlockType._(515, _omitEnumNames ? '' : 'AnytypeProfile');
  static const SmartBlockType Date =
      SmartBlockType._(516, _omitEnumNames ? '' : 'Date');
  static const SmartBlockType Workspace =
      SmartBlockType._(518, _omitEnumNames ? '' : 'Workspace');
  static const SmartBlockType STRelation =
      SmartBlockType._(521, _omitEnumNames ? '' : 'STRelation');
  static const SmartBlockType STType =
      SmartBlockType._(528, _omitEnumNames ? '' : 'STType');
  static const SmartBlockType STRelationOption =
      SmartBlockType._(529, _omitEnumNames ? '' : 'STRelationOption');
  static const SmartBlockType SpaceView =
      SmartBlockType._(530, _omitEnumNames ? '' : 'SpaceView');
  static const SmartBlockType Identity =
      SmartBlockType._(532, _omitEnumNames ? '' : 'Identity');
  static const SmartBlockType Participant =
      SmartBlockType._(534, _omitEnumNames ? '' : 'Participant');
  static const SmartBlockType MissingObject =
      SmartBlockType._(519, _omitEnumNames ? '' : 'MissingObject');
  static const SmartBlockType FileObject =
      SmartBlockType._(533, _omitEnumNames ? '' : 'FileObject');
  static const SmartBlockType NotificationObject =
      SmartBlockType._(535, _omitEnumNames ? '' : 'NotificationObject');
  static const SmartBlockType DevicesObject =
      SmartBlockType._(536, _omitEnumNames ? '' : 'DevicesObject');
  static const SmartBlockType ChatObjectDeprecated =
      SmartBlockType._(537, _omitEnumNames ? '' : 'ChatObjectDeprecated');
  static const SmartBlockType ChatDerivedObject =
      SmartBlockType._(544, _omitEnumNames ? '' : 'ChatDerivedObject');
  static const SmartBlockType AccountObject =
      SmartBlockType._(545, _omitEnumNames ? '' : 'AccountObject');
  static const SmartBlockType DiscussionObject =
      SmartBlockType._(546, _omitEnumNames ? '' : 'DiscussionObject');

  static const $core.List<SmartBlockType> values = <SmartBlockType>[
    AccountOld,
    Page,
    ProfilePage,
    Home,
    Archive,
    Widget,
    File,
    Template,
    BundledTemplate,
    BundledRelation,
    SubObject,
    BundledObjectType,
    AnytypeProfile,
    Date,
    Workspace,
    STRelation,
    STType,
    STRelationOption,
    SpaceView,
    Identity,
    Participant,
    MissingObject,
    FileObject,
    NotificationObject,
    DevicesObject,
    ChatObjectDeprecated,
    ChatDerivedObject,
    AccountObject,
    DiscussionObject,
  ];

  static final $core.Map<$core.int, SmartBlockType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static SmartBlockType? valueOf($core.int value) => _byValue[value];

  const SmartBlockType._(super.value, super.name);
}

/// RelationFormat describes how the underlying data is stored in the google.protobuf.Value and how it should be validated/sanitized
class RelationFormat extends $pb.ProtobufEnum {
  static const RelationFormat longtext =
      RelationFormat._(0, _omitEnumNames ? '' : 'longtext');
  static const RelationFormat shorttext =
      RelationFormat._(1, _omitEnumNames ? '' : 'shorttext');
  static const RelationFormat number =
      RelationFormat._(2, _omitEnumNames ? '' : 'number');
  static const RelationFormat status =
      RelationFormat._(3, _omitEnumNames ? '' : 'status');
  static const RelationFormat tag =
      RelationFormat._(11, _omitEnumNames ? '' : 'tag');
  static const RelationFormat date =
      RelationFormat._(4, _omitEnumNames ? '' : 'date');
  static const RelationFormat file =
      RelationFormat._(5, _omitEnumNames ? '' : 'file');
  static const RelationFormat checkbox =
      RelationFormat._(6, _omitEnumNames ? '' : 'checkbox');
  static const RelationFormat url =
      RelationFormat._(7, _omitEnumNames ? '' : 'url');
  static const RelationFormat email =
      RelationFormat._(8, _omitEnumNames ? '' : 'email');
  static const RelationFormat phone =
      RelationFormat._(9, _omitEnumNames ? '' : 'phone');
  static const RelationFormat emoji =
      RelationFormat._(10, _omitEnumNames ? '' : 'emoji');
  static const RelationFormat object =
      RelationFormat._(100, _omitEnumNames ? '' : 'object');
  static const RelationFormat relations =
      RelationFormat._(101, _omitEnumNames ? '' : 'relations');

  static const $core.List<RelationFormat> values = <RelationFormat>[
    longtext,
    shorttext,
    number,
    status,
    tag,
    date,
    file,
    checkbox,
    url,
    email,
    phone,
    emoji,
    object,
    relations,
  ];

  static final $core.Map<$core.int, RelationFormat> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static RelationFormat? valueOf($core.int value) => _byValue[value];

  const RelationFormat._(super.value, super.name);
}

class ObjectOrigin extends $pb.ProtobufEnum {
  static const ObjectOrigin none =
      ObjectOrigin._(0, _omitEnumNames ? '' : 'none');
  static const ObjectOrigin clipboard =
      ObjectOrigin._(1, _omitEnumNames ? '' : 'clipboard');
  static const ObjectOrigin dragAndDrop =
      ObjectOrigin._(2, _omitEnumNames ? '' : 'dragAndDrop');
  static const ObjectOrigin import =
      ObjectOrigin._(3, _omitEnumNames ? '' : 'import');
  static const ObjectOrigin webclipper =
      ObjectOrigin._(4, _omitEnumNames ? '' : 'webclipper');
  static const ObjectOrigin sharingExtension =
      ObjectOrigin._(5, _omitEnumNames ? '' : 'sharingExtension');
  static const ObjectOrigin usecase =
      ObjectOrigin._(6, _omitEnumNames ? '' : 'usecase');
  static const ObjectOrigin builtin =
      ObjectOrigin._(7, _omitEnumNames ? '' : 'builtin');
  static const ObjectOrigin bookmark =
      ObjectOrigin._(8, _omitEnumNames ? '' : 'bookmark');
  static const ObjectOrigin api =
      ObjectOrigin._(9, _omitEnumNames ? '' : 'api');

  static const $core.List<ObjectOrigin> values = <ObjectOrigin>[
    none,
    clipboard,
    dragAndDrop,
    import,
    webclipper,
    sharingExtension,
    usecase,
    builtin,
    bookmark,
    api,
  ];

  static final $core.List<ObjectOrigin?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 9);
  static ObjectOrigin? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ObjectOrigin._(super.value, super.name);
}

class SpaceStatus extends $pb.ProtobufEnum {
  /// Unknown means the space is not loaded yet
  static const SpaceStatus Unknown =
      SpaceStatus._(0, _omitEnumNames ? '' : 'Unknown');

  /// Loading - the space in progress of loading
  static const SpaceStatus Loading =
      SpaceStatus._(1, _omitEnumNames ? '' : 'Loading');

  /// Ok - the space loaded and available
  static const SpaceStatus Ok = SpaceStatus._(2, _omitEnumNames ? '' : 'Ok');

  /// Missing - the space is missing
  static const SpaceStatus Missing =
      SpaceStatus._(3, _omitEnumNames ? '' : 'Missing');

  /// Error - the space loading ended with an error
  static const SpaceStatus Error =
      SpaceStatus._(4, _omitEnumNames ? '' : 'Error');

  /// RemoteWaitingDeletion - network status is "waiting deletion"
  static const SpaceStatus RemoteWaitingDeletion =
      SpaceStatus._(5, _omitEnumNames ? '' : 'RemoteWaitingDeletion');

  /// RemoteDeleted - the space is deleted in the current network
  static const SpaceStatus RemoteDeleted =
      SpaceStatus._(6, _omitEnumNames ? '' : 'RemoteDeleted');

  /// SpaceDeleted - the space should be deleted in the network
  static const SpaceStatus SpaceDeleted =
      SpaceStatus._(7, _omitEnumNames ? '' : 'SpaceDeleted');

  /// SpaceActive - the space is active in the network
  static const SpaceStatus SpaceActive =
      SpaceStatus._(8, _omitEnumNames ? '' : 'SpaceActive');

  /// SpaceJoining - the account is joining the space
  static const SpaceStatus SpaceJoining =
      SpaceStatus._(9, _omitEnumNames ? '' : 'SpaceJoining');

  /// SpaceRemoving - the account is removing from space or the space is removed from network
  static const SpaceStatus SpaceRemoving =
      SpaceStatus._(10, _omitEnumNames ? '' : 'SpaceRemoving');

  static const $core.List<SpaceStatus> values = <SpaceStatus>[
    Unknown,
    Loading,
    Ok,
    Missing,
    Error,
    RemoteWaitingDeletion,
    RemoteDeleted,
    SpaceDeleted,
    SpaceActive,
    SpaceJoining,
    SpaceRemoving,
  ];

  static final $core.List<SpaceStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 10);
  static SpaceStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SpaceStatus._(super.value, super.name);
}

class ParticipantPermissions extends $pb.ProtobufEnum {
  static const ParticipantPermissions Reader =
      ParticipantPermissions._(0, _omitEnumNames ? '' : 'Reader');
  static const ParticipantPermissions Writer =
      ParticipantPermissions._(1, _omitEnumNames ? '' : 'Writer');
  static const ParticipantPermissions Owner =
      ParticipantPermissions._(2, _omitEnumNames ? '' : 'Owner');
  static const ParticipantPermissions NoPermissions =
      ParticipantPermissions._(3, _omitEnumNames ? '' : 'NoPermissions');

  static const $core.List<ParticipantPermissions> values =
      <ParticipantPermissions>[
    Reader,
    Writer,
    Owner,
    NoPermissions,
  ];

  static final $core.List<ParticipantPermissions?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static ParticipantPermissions? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ParticipantPermissions._(super.value, super.name);
}

class InviteType extends $pb.ProtobufEnum {
  static const InviteType Member =
      InviteType._(0, _omitEnumNames ? '' : 'Member');
  static const InviteType Guest =
      InviteType._(1, _omitEnumNames ? '' : 'Guest');
  static const InviteType WithoutApprove =
      InviteType._(2, _omitEnumNames ? '' : 'WithoutApprove');

  static const $core.List<InviteType> values = <InviteType>[
    Member,
    Guest,
    WithoutApprove,
  ];

  static final $core.List<InviteType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static InviteType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const InviteType._(super.value, super.name);
}

class ParticipantStatus extends $pb.ProtobufEnum {
  static const ParticipantStatus Joining =
      ParticipantStatus._(0, _omitEnumNames ? '' : 'Joining');
  static const ParticipantStatus Active =
      ParticipantStatus._(1, _omitEnumNames ? '' : 'Active');
  static const ParticipantStatus Removed =
      ParticipantStatus._(2, _omitEnumNames ? '' : 'Removed');
  static const ParticipantStatus Declined =
      ParticipantStatus._(3, _omitEnumNames ? '' : 'Declined');
  static const ParticipantStatus Removing =
      ParticipantStatus._(4, _omitEnumNames ? '' : 'Removing');
  static const ParticipantStatus Canceled =
      ParticipantStatus._(5, _omitEnumNames ? '' : 'Canceled');

  static const $core.List<ParticipantStatus> values = <ParticipantStatus>[
    Joining,
    Active,
    Removed,
    Declined,
    Removing,
    Canceled,
  ];

  static final $core.List<ParticipantStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static ParticipantStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ParticipantStatus._(super.value, super.name);
}

class SpaceAccessType extends $pb.ProtobufEnum {
  static const SpaceAccessType Private =
      SpaceAccessType._(0, _omitEnumNames ? '' : 'Private');
  static const SpaceAccessType Personal =
      SpaceAccessType._(1, _omitEnumNames ? '' : 'Personal');
  static const SpaceAccessType Shared =
      SpaceAccessType._(2, _omitEnumNames ? '' : 'Shared');

  static const $core.List<SpaceAccessType> values = <SpaceAccessType>[
    Private,
    Personal,
    Shared,
  ];

  static final $core.List<SpaceAccessType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static SpaceAccessType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SpaceAccessType._(super.value, super.name);
}

class SpaceUxType extends $pb.ProtobufEnum {
  static const SpaceUxType None =
      SpaceUxType._(0, _omitEnumNames ? '' : 'None');
  static const SpaceUxType Data =
      SpaceUxType._(1, _omitEnumNames ? '' : 'Data');
  static const SpaceUxType Stream =
      SpaceUxType._(2, _omitEnumNames ? '' : 'Stream');
  static const SpaceUxType Chat =
      SpaceUxType._(3, _omitEnumNames ? '' : 'Chat');
  static const SpaceUxType OneToOne =
      SpaceUxType._(4, _omitEnumNames ? '' : 'OneToOne');

  static const $core.List<SpaceUxType> values = <SpaceUxType>[
    None,
    Data,
    Stream,
    Chat,
    OneToOne,
  ];

  static final $core.List<SpaceUxType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static SpaceUxType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SpaceUxType._(super.value, super.name);
}

class SpaceType extends $pb.ProtobufEnum {
  static const SpaceType SpaceTypeUnknown =
      SpaceType._(0, _omitEnumNames ? '' : 'SpaceTypeUnknown');
  static const SpaceType SpaceTypeRegular =
      SpaceType._(1, _omitEnumNames ? '' : 'SpaceTypeRegular');
  static const SpaceType SpaceTypeTech =
      SpaceType._(2, _omitEnumNames ? '' : 'SpaceTypeTech');
  static const SpaceType SpaceTypeChat =
      SpaceType._(3, _omitEnumNames ? '' : 'SpaceTypeChat');
  static const SpaceType SpaceTypeOneToOne =
      SpaceType._(4, _omitEnumNames ? '' : 'SpaceTypeOneToOne');

  static const $core.List<SpaceType> values = <SpaceType>[
    SpaceTypeUnknown,
    SpaceTypeRegular,
    SpaceTypeTech,
    SpaceTypeChat,
    SpaceTypeOneToOne,
  ];

  static final $core.List<SpaceType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static SpaceType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SpaceType._(super.value, super.name);
}

class ImageKind extends $pb.ProtobufEnum {
  static const ImageKind Basic = ImageKind._(0, _omitEnumNames ? '' : 'Basic');
  static const ImageKind Cover = ImageKind._(1, _omitEnumNames ? '' : 'Cover');
  static const ImageKind Icon = ImageKind._(2, _omitEnumNames ? '' : 'Icon');
  static const ImageKind AutomaticallyAdded =
      ImageKind._(3, _omitEnumNames ? '' : 'AutomaticallyAdded');

  static const $core.List<ImageKind> values = <ImageKind>[
    Basic,
    Cover,
    Icon,
    AutomaticallyAdded,
  ];

  static final $core.List<ImageKind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static ImageKind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ImageKind._(super.value, super.name);
}

class FileIndexingStatus extends $pb.ProtobufEnum {
  static const FileIndexingStatus NotIndexed =
      FileIndexingStatus._(0, _omitEnumNames ? '' : 'NotIndexed');
  static const FileIndexingStatus Indexed =
      FileIndexingStatus._(1, _omitEnumNames ? '' : 'Indexed');
  static const FileIndexingStatus NotFound =
      FileIndexingStatus._(2, _omitEnumNames ? '' : 'NotFound');

  static const $core.List<FileIndexingStatus> values = <FileIndexingStatus>[
    NotIndexed,
    Indexed,
    NotFound,
  ];

  static final $core.List<FileIndexingStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static FileIndexingStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FileIndexingStatus._(super.value, super.name);
}

class SpaceShareableStatus extends $pb.ProtobufEnum {
  static const SpaceShareableStatus StatusUnknown =
      SpaceShareableStatus._(0, _omitEnumNames ? '' : 'StatusUnknown');
  static const SpaceShareableStatus StatusShareable =
      SpaceShareableStatus._(1, _omitEnumNames ? '' : 'StatusShareable');
  static const SpaceShareableStatus StatusNotShareable =
      SpaceShareableStatus._(2, _omitEnumNames ? '' : 'StatusNotShareable');

  static const $core.List<SpaceShareableStatus> values = <SpaceShareableStatus>[
    StatusUnknown,
    StatusShareable,
    StatusNotShareable,
  ];

  static final $core.List<SpaceShareableStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static SpaceShareableStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SpaceShareableStatus._(super.value, super.name);
}

class NameserviceNameType extends $pb.ProtobufEnum {
  /// .any suffix
  static const NameserviceNameType AnyName =
      NameserviceNameType._(0, _omitEnumNames ? '' : 'AnyName');

  static const $core.List<NameserviceNameType> values = <NameserviceNameType>[
    AnyName,
  ];

  static final $core.List<NameserviceNameType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 0);
  static NameserviceNameType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const NameserviceNameType._(super.value, super.name);
}

class DeviceNetworkType extends $pb.ProtobufEnum {
  static const DeviceNetworkType WIFI =
      DeviceNetworkType._(0, _omitEnumNames ? '' : 'WIFI');
  static const DeviceNetworkType CELLULAR =
      DeviceNetworkType._(1, _omitEnumNames ? '' : 'CELLULAR');
  static const DeviceNetworkType NOT_CONNECTED =
      DeviceNetworkType._(2, _omitEnumNames ? '' : 'NOT_CONNECTED');

  static const $core.List<DeviceNetworkType> values = <DeviceNetworkType>[
    WIFI,
    CELLULAR,
    NOT_CONNECTED,
  ];

  static final $core.List<DeviceNetworkType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static DeviceNetworkType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DeviceNetworkType._(super.value, super.name);
}

class SyncStatus extends $pb.ProtobufEnum {
  static const SyncStatus SyncStatusSynced =
      SyncStatus._(0, _omitEnumNames ? '' : 'SyncStatusSynced');
  static const SyncStatus SyncStatusSyncing =
      SyncStatus._(1, _omitEnumNames ? '' : 'SyncStatusSyncing');
  static const SyncStatus SyncStatusError =
      SyncStatus._(2, _omitEnumNames ? '' : 'SyncStatusError');
  static const SyncStatus SyncStatusQueued =
      SyncStatus._(3, _omitEnumNames ? '' : 'SyncStatusQueued');

  static const $core.List<SyncStatus> values = <SyncStatus>[
    SyncStatusSynced,
    SyncStatusSyncing,
    SyncStatusError,
    SyncStatusQueued,
  ];

  static final $core.List<SyncStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static SyncStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SyncStatus._(super.value, super.name);
}

class SyncError extends $pb.ProtobufEnum {
  static const SyncError SyncErrorNull =
      SyncError._(0, _omitEnumNames ? '' : 'SyncErrorNull');
  static const SyncError SyncErrorIncompatibleVersion =
      SyncError._(2, _omitEnumNames ? '' : 'SyncErrorIncompatibleVersion');
  static const SyncError SyncErrorNetworkError =
      SyncError._(3, _omitEnumNames ? '' : 'SyncErrorNetworkError');
  static const SyncError SyncErrorOversized =
      SyncError._(4, _omitEnumNames ? '' : 'SyncErrorOversized');

  static const $core.List<SyncError> values = <SyncError>[
    SyncErrorNull,
    SyncErrorIncompatibleVersion,
    SyncErrorNetworkError,
    SyncErrorOversized,
  ];

  static final $core.List<SyncError?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static SyncError? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SyncError._(super.value, super.name);
}

class TemplateNamePrefillType extends $pb.ProtobufEnum {
  static const TemplateNamePrefillType Empty =
      TemplateNamePrefillType._(0, _omitEnumNames ? '' : 'Empty');
  static const TemplateNamePrefillType FromTemplateName =
      TemplateNamePrefillType._(1, _omitEnumNames ? '' : 'FromTemplateName');

  static const $core.List<TemplateNamePrefillType> values =
      <TemplateNamePrefillType>[
    Empty,
    FromTemplateName,
  ];

  static final $core.List<TemplateNamePrefillType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static TemplateNamePrefillType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TemplateNamePrefillType._(super.value, super.name);
}

class Search_Message_Sort_Key extends $pb.ProtobufEnum {
  static const Search_Message_Sort_Key ORDER_ID =
      Search_Message_Sort_Key._(0, _omitEnumNames ? '' : 'ORDER_ID');
  static const Search_Message_Sort_Key SCORE =
      Search_Message_Sort_Key._(1, _omitEnumNames ? '' : 'SCORE');
  static const Search_Message_Sort_Key CREATED_AT =
      Search_Message_Sort_Key._(2, _omitEnumNames ? '' : 'CREATED_AT');
  static const Search_Message_Sort_Key MODIFIED_AT =
      Search_Message_Sort_Key._(3, _omitEnumNames ? '' : 'MODIFIED_AT');

  static const $core.List<Search_Message_Sort_Key> values =
      <Search_Message_Sort_Key>[
    ORDER_ID,
    SCORE,
    CREATED_AT,
    MODIFIED_AT,
  ];

  static final $core.List<Search_Message_Sort_Key?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Search_Message_Sort_Key? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Search_Message_Sort_Key._(super.value, super.name);
}

class Search_Message_Sort_Type extends $pb.ProtobufEnum {
  static const Search_Message_Sort_Type Asc =
      Search_Message_Sort_Type._(0, _omitEnumNames ? '' : 'Asc');
  static const Search_Message_Sort_Type Desc =
      Search_Message_Sort_Type._(1, _omitEnumNames ? '' : 'Desc');

  static const $core.List<Search_Message_Sort_Type> values =
      <Search_Message_Sort_Type>[
    Asc,
    Desc,
  ];

  static final $core.List<Search_Message_Sort_Type?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static Search_Message_Sort_Type? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Search_Message_Sort_Type._(super.value, super.name);
}

class Block_Position extends $pb.ProtobufEnum {
  static const Block_Position None =
      Block_Position._(0, _omitEnumNames ? '' : 'None');

  /// above target block
  static const Block_Position Top =
      Block_Position._(1, _omitEnumNames ? '' : 'Top');

  /// under target block
  static const Block_Position Bottom =
      Block_Position._(2, _omitEnumNames ? '' : 'Bottom');

  /// to left of target block
  static const Block_Position Left =
      Block_Position._(3, _omitEnumNames ? '' : 'Left');

  /// to right of target block
  static const Block_Position Right =
      Block_Position._(4, _omitEnumNames ? '' : 'Right');

  /// inside target block, as last block
  static const Block_Position Inner =
      Block_Position._(5, _omitEnumNames ? '' : 'Inner');

  /// replace target block
  static const Block_Position Replace =
      Block_Position._(6, _omitEnumNames ? '' : 'Replace');

  /// inside target block, as first block
  static const Block_Position InnerFirst =
      Block_Position._(7, _omitEnumNames ? '' : 'InnerFirst');

  static const $core.List<Block_Position> values = <Block_Position>[
    None,
    Top,
    Bottom,
    Left,
    Right,
    Inner,
    Replace,
    InnerFirst,
  ];

  static final $core.List<Block_Position?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static Block_Position? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Position._(super.value, super.name);
}

class Block_Align extends $pb.ProtobufEnum {
  static const Block_Align AlignLeft =
      Block_Align._(0, _omitEnumNames ? '' : 'AlignLeft');
  static const Block_Align AlignCenter =
      Block_Align._(1, _omitEnumNames ? '' : 'AlignCenter');
  static const Block_Align AlignRight =
      Block_Align._(2, _omitEnumNames ? '' : 'AlignRight');
  static const Block_Align AlignJustify =
      Block_Align._(3, _omitEnumNames ? '' : 'AlignJustify');

  static const $core.List<Block_Align> values = <Block_Align>[
    AlignLeft,
    AlignCenter,
    AlignRight,
    AlignJustify,
  ];

  static final $core.List<Block_Align?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Block_Align? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Align._(super.value, super.name);
}

class Block_VerticalAlign extends $pb.ProtobufEnum {
  static const Block_VerticalAlign VerticalAlignTop =
      Block_VerticalAlign._(0, _omitEnumNames ? '' : 'VerticalAlignTop');
  static const Block_VerticalAlign VerticalAlignMiddle =
      Block_VerticalAlign._(1, _omitEnumNames ? '' : 'VerticalAlignMiddle');
  static const Block_VerticalAlign VerticalAlignBottom =
      Block_VerticalAlign._(2, _omitEnumNames ? '' : 'VerticalAlignBottom');

  static const $core.List<Block_VerticalAlign> values = <Block_VerticalAlign>[
    VerticalAlignTop,
    VerticalAlignMiddle,
    VerticalAlignBottom,
  ];

  static final $core.List<Block_VerticalAlign?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Block_VerticalAlign? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_VerticalAlign._(super.value, super.name);
}

class Block_Content_Layout_Style extends $pb.ProtobufEnum {
  static const Block_Content_Layout_Style Row =
      Block_Content_Layout_Style._(0, _omitEnumNames ? '' : 'Row');
  static const Block_Content_Layout_Style Column =
      Block_Content_Layout_Style._(1, _omitEnumNames ? '' : 'Column');
  static const Block_Content_Layout_Style Div =
      Block_Content_Layout_Style._(2, _omitEnumNames ? '' : 'Div');
  static const Block_Content_Layout_Style Header =
      Block_Content_Layout_Style._(3, _omitEnumNames ? '' : 'Header');
  static const Block_Content_Layout_Style TableRows =
      Block_Content_Layout_Style._(4, _omitEnumNames ? '' : 'TableRows');
  static const Block_Content_Layout_Style TableColumns =
      Block_Content_Layout_Style._(5, _omitEnumNames ? '' : 'TableColumns');

  static const $core.List<Block_Content_Layout_Style> values =
      <Block_Content_Layout_Style>[
    Row,
    Column,
    Div,
    Header,
    TableRows,
    TableColumns,
  ];

  static final $core.List<Block_Content_Layout_Style?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static Block_Content_Layout_Style? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Layout_Style._(super.value, super.name);
}

class Block_Content_Link_IconSize extends $pb.ProtobufEnum {
  static const Block_Content_Link_IconSize SizeNone =
      Block_Content_Link_IconSize._(0, _omitEnumNames ? '' : 'SizeNone');
  static const Block_Content_Link_IconSize SizeSmall =
      Block_Content_Link_IconSize._(1, _omitEnumNames ? '' : 'SizeSmall');
  static const Block_Content_Link_IconSize SizeMedium =
      Block_Content_Link_IconSize._(2, _omitEnumNames ? '' : 'SizeMedium');

  static const $core.List<Block_Content_Link_IconSize> values =
      <Block_Content_Link_IconSize>[
    SizeNone,
    SizeSmall,
    SizeMedium,
  ];

  static final $core.List<Block_Content_Link_IconSize?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Block_Content_Link_IconSize? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Link_IconSize._(super.value, super.name);
}

class Block_Content_Link_Style extends $pb.ProtobufEnum {
  static const Block_Content_Link_Style Page =
      Block_Content_Link_Style._(0, _omitEnumNames ? '' : 'Page');
  static const Block_Content_Link_Style Dataview =
      Block_Content_Link_Style._(1, _omitEnumNames ? '' : 'Dataview');
  static const Block_Content_Link_Style Dashboard =
      Block_Content_Link_Style._(2, _omitEnumNames ? '' : 'Dashboard');
  static const Block_Content_Link_Style Archive =
      Block_Content_Link_Style._(3, _omitEnumNames ? '' : 'Archive');

  static const $core.List<Block_Content_Link_Style> values =
      <Block_Content_Link_Style>[
    Page,
    Dataview,
    Dashboard,
    Archive,
  ];

  static final $core.List<Block_Content_Link_Style?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Block_Content_Link_Style? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Link_Style._(super.value, super.name);
}

class Block_Content_Link_Description extends $pb.ProtobufEnum {
  static const Block_Content_Link_Description None =
      Block_Content_Link_Description._(0, _omitEnumNames ? '' : 'None');
  static const Block_Content_Link_Description Added =
      Block_Content_Link_Description._(1, _omitEnumNames ? '' : 'Added');
  static const Block_Content_Link_Description Content =
      Block_Content_Link_Description._(2, _omitEnumNames ? '' : 'Content');

  static const $core.List<Block_Content_Link_Description> values =
      <Block_Content_Link_Description>[
    None,
    Added,
    Content,
  ];

  static final $core.List<Block_Content_Link_Description?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Block_Content_Link_Description? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Link_Description._(super.value, super.name);
}

class Block_Content_Link_CardStyle extends $pb.ProtobufEnum {
  static const Block_Content_Link_CardStyle Text =
      Block_Content_Link_CardStyle._(0, _omitEnumNames ? '' : 'Text');
  static const Block_Content_Link_CardStyle Card =
      Block_Content_Link_CardStyle._(1, _omitEnumNames ? '' : 'Card');
  static const Block_Content_Link_CardStyle Inline =
      Block_Content_Link_CardStyle._(2, _omitEnumNames ? '' : 'Inline');

  static const $core.List<Block_Content_Link_CardStyle> values =
      <Block_Content_Link_CardStyle>[
    Text,
    Card,
    Inline,
  ];

  static final $core.List<Block_Content_Link_CardStyle?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Block_Content_Link_CardStyle? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Link_CardStyle._(super.value, super.name);
}

class Block_Content_Div_Style extends $pb.ProtobufEnum {
  static const Block_Content_Div_Style Line =
      Block_Content_Div_Style._(0, _omitEnumNames ? '' : 'Line');
  static const Block_Content_Div_Style Dots =
      Block_Content_Div_Style._(1, _omitEnumNames ? '' : 'Dots');

  static const $core.List<Block_Content_Div_Style> values =
      <Block_Content_Div_Style>[
    Line,
    Dots,
  ];

  static final $core.List<Block_Content_Div_Style?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static Block_Content_Div_Style? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Div_Style._(super.value, super.name);
}

class Block_Content_Bookmark_State extends $pb.ProtobufEnum {
  static const Block_Content_Bookmark_State Empty =
      Block_Content_Bookmark_State._(0, _omitEnumNames ? '' : 'Empty');
  static const Block_Content_Bookmark_State Fetching =
      Block_Content_Bookmark_State._(1, _omitEnumNames ? '' : 'Fetching');
  static const Block_Content_Bookmark_State Done =
      Block_Content_Bookmark_State._(2, _omitEnumNames ? '' : 'Done');
  static const Block_Content_Bookmark_State Error =
      Block_Content_Bookmark_State._(3, _omitEnumNames ? '' : 'Error');

  static const $core.List<Block_Content_Bookmark_State> values =
      <Block_Content_Bookmark_State>[
    Empty,
    Fetching,
    Done,
    Error,
  ];

  static final $core.List<Block_Content_Bookmark_State?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Block_Content_Bookmark_State? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Bookmark_State._(super.value, super.name);
}

class Block_Content_Text_Style extends $pb.ProtobufEnum {
  static const Block_Content_Text_Style Paragraph =
      Block_Content_Text_Style._(0, _omitEnumNames ? '' : 'Paragraph');
  static const Block_Content_Text_Style Header1 =
      Block_Content_Text_Style._(1, _omitEnumNames ? '' : 'Header1');
  static const Block_Content_Text_Style Header2 =
      Block_Content_Text_Style._(2, _omitEnumNames ? '' : 'Header2');
  static const Block_Content_Text_Style Header3 =
      Block_Content_Text_Style._(3, _omitEnumNames ? '' : 'Header3');
  static const Block_Content_Text_Style Header4 =
      Block_Content_Text_Style._(4, _omitEnumNames ? '' : 'Header4');
  static const Block_Content_Text_Style Quote =
      Block_Content_Text_Style._(5, _omitEnumNames ? '' : 'Quote');
  static const Block_Content_Text_Style Code =
      Block_Content_Text_Style._(6, _omitEnumNames ? '' : 'Code');
  static const Block_Content_Text_Style Title =
      Block_Content_Text_Style._(7, _omitEnumNames ? '' : 'Title');
  static const Block_Content_Text_Style Checkbox =
      Block_Content_Text_Style._(8, _omitEnumNames ? '' : 'Checkbox');
  static const Block_Content_Text_Style Marked =
      Block_Content_Text_Style._(9, _omitEnumNames ? '' : 'Marked');
  static const Block_Content_Text_Style Numbered =
      Block_Content_Text_Style._(10, _omitEnumNames ? '' : 'Numbered');
  static const Block_Content_Text_Style Toggle =
      Block_Content_Text_Style._(11, _omitEnumNames ? '' : 'Toggle');
  static const Block_Content_Text_Style Description =
      Block_Content_Text_Style._(12, _omitEnumNames ? '' : 'Description');
  static const Block_Content_Text_Style Callout =
      Block_Content_Text_Style._(13, _omitEnumNames ? '' : 'Callout');
  static const Block_Content_Text_Style ToggleHeader1 =
      Block_Content_Text_Style._(14, _omitEnumNames ? '' : 'ToggleHeader1');
  static const Block_Content_Text_Style ToggleHeader2 =
      Block_Content_Text_Style._(15, _omitEnumNames ? '' : 'ToggleHeader2');
  static const Block_Content_Text_Style ToggleHeader3 =
      Block_Content_Text_Style._(16, _omitEnumNames ? '' : 'ToggleHeader3');

  static const $core.List<Block_Content_Text_Style> values =
      <Block_Content_Text_Style>[
    Paragraph,
    Header1,
    Header2,
    Header3,
    Header4,
    Quote,
    Code,
    Title,
    Checkbox,
    Marked,
    Numbered,
    Toggle,
    Description,
    Callout,
    ToggleHeader1,
    ToggleHeader2,
    ToggleHeader3,
  ];

  static final $core.List<Block_Content_Text_Style?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 16);
  static Block_Content_Text_Style? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Text_Style._(super.value, super.name);
}

class Block_Content_Text_Mark_Type extends $pb.ProtobufEnum {
  static const Block_Content_Text_Mark_Type Strikethrough =
      Block_Content_Text_Mark_Type._(0, _omitEnumNames ? '' : 'Strikethrough');
  static const Block_Content_Text_Mark_Type Keyboard =
      Block_Content_Text_Mark_Type._(1, _omitEnumNames ? '' : 'Keyboard');
  static const Block_Content_Text_Mark_Type Italic =
      Block_Content_Text_Mark_Type._(2, _omitEnumNames ? '' : 'Italic');
  static const Block_Content_Text_Mark_Type Bold =
      Block_Content_Text_Mark_Type._(3, _omitEnumNames ? '' : 'Bold');
  static const Block_Content_Text_Mark_Type Underscored =
      Block_Content_Text_Mark_Type._(4, _omitEnumNames ? '' : 'Underscored');
  static const Block_Content_Text_Mark_Type Link =
      Block_Content_Text_Mark_Type._(5, _omitEnumNames ? '' : 'Link');
  static const Block_Content_Text_Mark_Type TextColor =
      Block_Content_Text_Mark_Type._(6, _omitEnumNames ? '' : 'TextColor');
  static const Block_Content_Text_Mark_Type BackgroundColor =
      Block_Content_Text_Mark_Type._(
          7, _omitEnumNames ? '' : 'BackgroundColor');
  static const Block_Content_Text_Mark_Type Mention =
      Block_Content_Text_Mark_Type._(8, _omitEnumNames ? '' : 'Mention');
  static const Block_Content_Text_Mark_Type Emoji =
      Block_Content_Text_Mark_Type._(9, _omitEnumNames ? '' : 'Emoji');
  static const Block_Content_Text_Mark_Type Object_ =
      Block_Content_Text_Mark_Type._(10, _omitEnumNames ? '' : 'Object');

  static const $core.List<Block_Content_Text_Mark_Type> values =
      <Block_Content_Text_Mark_Type>[
    Strikethrough,
    Keyboard,
    Italic,
    Bold,
    Underscored,
    Link,
    TextColor,
    BackgroundColor,
    Mention,
    Emoji,
    Object_,
  ];

  static final $core.List<Block_Content_Text_Mark_Type?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 10);
  static Block_Content_Text_Mark_Type? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Text_Mark_Type._(super.value, super.name);
}

class Block_Content_File_Type extends $pb.ProtobufEnum {
  static const Block_Content_File_Type None =
      Block_Content_File_Type._(0, _omitEnumNames ? '' : 'None');
  static const Block_Content_File_Type File =
      Block_Content_File_Type._(1, _omitEnumNames ? '' : 'File');
  static const Block_Content_File_Type Image =
      Block_Content_File_Type._(2, _omitEnumNames ? '' : 'Image');
  static const Block_Content_File_Type Video =
      Block_Content_File_Type._(3, _omitEnumNames ? '' : 'Video');
  static const Block_Content_File_Type Audio =
      Block_Content_File_Type._(4, _omitEnumNames ? '' : 'Audio');
  static const Block_Content_File_Type PDF =
      Block_Content_File_Type._(5, _omitEnumNames ? '' : 'PDF');

  static const $core.List<Block_Content_File_Type> values =
      <Block_Content_File_Type>[
    None,
    File,
    Image,
    Video,
    Audio,
    PDF,
  ];

  static final $core.List<Block_Content_File_Type?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static Block_Content_File_Type? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_File_Type._(super.value, super.name);
}

class Block_Content_File_Style extends $pb.ProtobufEnum {
  static const Block_Content_File_Style Auto =
      Block_Content_File_Style._(0, _omitEnumNames ? '' : 'Auto');
  static const Block_Content_File_Style Link =
      Block_Content_File_Style._(1, _omitEnumNames ? '' : 'Link');
  static const Block_Content_File_Style Embed =
      Block_Content_File_Style._(2, _omitEnumNames ? '' : 'Embed');

  static const $core.List<Block_Content_File_Style> values =
      <Block_Content_File_Style>[
    Auto,
    Link,
    Embed,
  ];

  static final $core.List<Block_Content_File_Style?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Block_Content_File_Style? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_File_Style._(super.value, super.name);
}

class Block_Content_File_State extends $pb.ProtobufEnum {
  static const Block_Content_File_State Empty =
      Block_Content_File_State._(0, _omitEnumNames ? '' : 'Empty');
  static const Block_Content_File_State Uploading =
      Block_Content_File_State._(1, _omitEnumNames ? '' : 'Uploading');
  static const Block_Content_File_State Done =
      Block_Content_File_State._(2, _omitEnumNames ? '' : 'Done');
  static const Block_Content_File_State Error =
      Block_Content_File_State._(3, _omitEnumNames ? '' : 'Error');

  static const $core.List<Block_Content_File_State> values =
      <Block_Content_File_State>[
    Empty,
    Uploading,
    Done,
    Error,
  ];

  static final $core.List<Block_Content_File_State?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Block_Content_File_State? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_File_State._(super.value, super.name);
}

class Block_Content_Dataview_View_Type extends $pb.ProtobufEnum {
  static const Block_Content_Dataview_View_Type Table =
      Block_Content_Dataview_View_Type._(0, _omitEnumNames ? '' : 'Table');
  static const Block_Content_Dataview_View_Type List_ =
      Block_Content_Dataview_View_Type._(1, _omitEnumNames ? '' : 'List');
  static const Block_Content_Dataview_View_Type Gallery =
      Block_Content_Dataview_View_Type._(2, _omitEnumNames ? '' : 'Gallery');
  static const Block_Content_Dataview_View_Type Kanban =
      Block_Content_Dataview_View_Type._(3, _omitEnumNames ? '' : 'Kanban');
  static const Block_Content_Dataview_View_Type Calendar =
      Block_Content_Dataview_View_Type._(4, _omitEnumNames ? '' : 'Calendar');
  static const Block_Content_Dataview_View_Type Graph =
      Block_Content_Dataview_View_Type._(5, _omitEnumNames ? '' : 'Graph');

  static const $core.List<Block_Content_Dataview_View_Type> values =
      <Block_Content_Dataview_View_Type>[
    Table,
    List_,
    Gallery,
    Kanban,
    Calendar,
    Graph,
  ];

  static final $core.List<Block_Content_Dataview_View_Type?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static Block_Content_Dataview_View_Type? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Dataview_View_Type._(super.value, super.name);
}

class Block_Content_Dataview_View_Size extends $pb.ProtobufEnum {
  static const Block_Content_Dataview_View_Size Small =
      Block_Content_Dataview_View_Size._(0, _omitEnumNames ? '' : 'Small');
  static const Block_Content_Dataview_View_Size Medium =
      Block_Content_Dataview_View_Size._(1, _omitEnumNames ? '' : 'Medium');
  static const Block_Content_Dataview_View_Size Large =
      Block_Content_Dataview_View_Size._(2, _omitEnumNames ? '' : 'Large');

  static const $core.List<Block_Content_Dataview_View_Size> values =
      <Block_Content_Dataview_View_Size>[
    Small,
    Medium,
    Large,
  ];

  static final $core.List<Block_Content_Dataview_View_Size?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Block_Content_Dataview_View_Size? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Dataview_View_Size._(super.value, super.name);
}

class Block_Content_Dataview_View_ListSize extends $pb.ProtobufEnum {
  static const Block_Content_Dataview_View_ListSize Compact =
      Block_Content_Dataview_View_ListSize._(
          0, _omitEnumNames ? '' : 'Compact');
  static const Block_Content_Dataview_View_ListSize Regular =
      Block_Content_Dataview_View_ListSize._(
          1, _omitEnumNames ? '' : 'Regular');

  static const $core.List<Block_Content_Dataview_View_ListSize> values =
      <Block_Content_Dataview_View_ListSize>[
    Compact,
    Regular,
  ];

  static final $core.List<Block_Content_Dataview_View_ListSize?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static Block_Content_Dataview_View_ListSize? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Dataview_View_ListSize._(super.value, super.name);
}

class Block_Content_Dataview_Relation_DateFormat extends $pb.ProtobufEnum {
  static const Block_Content_Dataview_Relation_DateFormat MonthAbbrBeforeDay =
      Block_Content_Dataview_Relation_DateFormat._(
          0, _omitEnumNames ? '' : 'MonthAbbrBeforeDay');
  static const Block_Content_Dataview_Relation_DateFormat MonthAbbrAfterDay =
      Block_Content_Dataview_Relation_DateFormat._(
          1, _omitEnumNames ? '' : 'MonthAbbrAfterDay');
  static const Block_Content_Dataview_Relation_DateFormat Short =
      Block_Content_Dataview_Relation_DateFormat._(
          2, _omitEnumNames ? '' : 'Short');
  static const Block_Content_Dataview_Relation_DateFormat ShortUS =
      Block_Content_Dataview_Relation_DateFormat._(
          3, _omitEnumNames ? '' : 'ShortUS');
  static const Block_Content_Dataview_Relation_DateFormat ISO =
      Block_Content_Dataview_Relation_DateFormat._(
          4, _omitEnumNames ? '' : 'ISO');

  static const $core.List<Block_Content_Dataview_Relation_DateFormat> values =
      <Block_Content_Dataview_Relation_DateFormat>[
    MonthAbbrBeforeDay,
    MonthAbbrAfterDay,
    Short,
    ShortUS,
    ISO,
  ];

  static final $core.List<Block_Content_Dataview_Relation_DateFormat?>
      _byValue = $pb.ProtobufEnum.$_initByValueList(values, 4);
  static Block_Content_Dataview_Relation_DateFormat? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Dataview_Relation_DateFormat._(super.value, super.name);
}

class Block_Content_Dataview_Relation_TimeFormat extends $pb.ProtobufEnum {
  static const Block_Content_Dataview_Relation_TimeFormat Format12 =
      Block_Content_Dataview_Relation_TimeFormat._(
          0, _omitEnumNames ? '' : 'Format12');
  static const Block_Content_Dataview_Relation_TimeFormat Format24 =
      Block_Content_Dataview_Relation_TimeFormat._(
          1, _omitEnumNames ? '' : 'Format24');

  static const $core.List<Block_Content_Dataview_Relation_TimeFormat> values =
      <Block_Content_Dataview_Relation_TimeFormat>[
    Format12,
    Format24,
  ];

  static final $core.List<Block_Content_Dataview_Relation_TimeFormat?>
      _byValue = $pb.ProtobufEnum.$_initByValueList(values, 1);
  static Block_Content_Dataview_Relation_TimeFormat? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Dataview_Relation_TimeFormat._(super.value, super.name);
}

class Block_Content_Dataview_Relation_FormulaType extends $pb.ProtobufEnum {
  static const Block_Content_Dataview_Relation_FormulaType None =
      Block_Content_Dataview_Relation_FormulaType._(
          0, _omitEnumNames ? '' : 'None');
  static const Block_Content_Dataview_Relation_FormulaType Count =
      Block_Content_Dataview_Relation_FormulaType._(
          1, _omitEnumNames ? '' : 'Count');
  static const Block_Content_Dataview_Relation_FormulaType CountValue =
      Block_Content_Dataview_Relation_FormulaType._(
          2, _omitEnumNames ? '' : 'CountValue');
  static const Block_Content_Dataview_Relation_FormulaType CountDistinct =
      Block_Content_Dataview_Relation_FormulaType._(
          3, _omitEnumNames ? '' : 'CountDistinct');
  static const Block_Content_Dataview_Relation_FormulaType CountEmpty =
      Block_Content_Dataview_Relation_FormulaType._(
          4, _omitEnumNames ? '' : 'CountEmpty');
  static const Block_Content_Dataview_Relation_FormulaType CountNotEmpty =
      Block_Content_Dataview_Relation_FormulaType._(
          5, _omitEnumNames ? '' : 'CountNotEmpty');
  static const Block_Content_Dataview_Relation_FormulaType PercentEmpty =
      Block_Content_Dataview_Relation_FormulaType._(
          6, _omitEnumNames ? '' : 'PercentEmpty');
  static const Block_Content_Dataview_Relation_FormulaType PercentNotEmpty =
      Block_Content_Dataview_Relation_FormulaType._(
          7, _omitEnumNames ? '' : 'PercentNotEmpty');
  static const Block_Content_Dataview_Relation_FormulaType MathSum =
      Block_Content_Dataview_Relation_FormulaType._(
          8, _omitEnumNames ? '' : 'MathSum');
  static const Block_Content_Dataview_Relation_FormulaType MathAverage =
      Block_Content_Dataview_Relation_FormulaType._(
          9, _omitEnumNames ? '' : 'MathAverage');
  static const Block_Content_Dataview_Relation_FormulaType MathMedian =
      Block_Content_Dataview_Relation_FormulaType._(
          10, _omitEnumNames ? '' : 'MathMedian');
  static const Block_Content_Dataview_Relation_FormulaType MathMin =
      Block_Content_Dataview_Relation_FormulaType._(
          11, _omitEnumNames ? '' : 'MathMin');
  static const Block_Content_Dataview_Relation_FormulaType MathMax =
      Block_Content_Dataview_Relation_FormulaType._(
          12, _omitEnumNames ? '' : 'MathMax');
  static const Block_Content_Dataview_Relation_FormulaType Range =
      Block_Content_Dataview_Relation_FormulaType._(
          13, _omitEnumNames ? '' : 'Range');

  static const $core.List<Block_Content_Dataview_Relation_FormulaType> values =
      <Block_Content_Dataview_Relation_FormulaType>[
    None,
    Count,
    CountValue,
    CountDistinct,
    CountEmpty,
    CountNotEmpty,
    PercentEmpty,
    PercentNotEmpty,
    MathSum,
    MathAverage,
    MathMedian,
    MathMin,
    MathMax,
    Range,
  ];

  static final $core.List<Block_Content_Dataview_Relation_FormulaType?>
      _byValue = $pb.ProtobufEnum.$_initByValueList(values, 13);
  static Block_Content_Dataview_Relation_FormulaType? valueOf(
          $core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Dataview_Relation_FormulaType._(super.value, super.name);
}

class Block_Content_Dataview_Sort_Type extends $pb.ProtobufEnum {
  static const Block_Content_Dataview_Sort_Type Asc =
      Block_Content_Dataview_Sort_Type._(0, _omitEnumNames ? '' : 'Asc');
  static const Block_Content_Dataview_Sort_Type Desc =
      Block_Content_Dataview_Sort_Type._(1, _omitEnumNames ? '' : 'Desc');
  static const Block_Content_Dataview_Sort_Type Custom =
      Block_Content_Dataview_Sort_Type._(2, _omitEnumNames ? '' : 'Custom');

  static const $core.List<Block_Content_Dataview_Sort_Type> values =
      <Block_Content_Dataview_Sort_Type>[
    Asc,
    Desc,
    Custom,
  ];

  static final $core.List<Block_Content_Dataview_Sort_Type?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Block_Content_Dataview_Sort_Type? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Dataview_Sort_Type._(super.value, super.name);
}

class Block_Content_Dataview_Sort_EmptyType extends $pb.ProtobufEnum {
  static const Block_Content_Dataview_Sort_EmptyType NotSpecified =
      Block_Content_Dataview_Sort_EmptyType._(
          0, _omitEnumNames ? '' : 'NotSpecified');
  static const Block_Content_Dataview_Sort_EmptyType Start =
      Block_Content_Dataview_Sort_EmptyType._(1, _omitEnumNames ? '' : 'Start');
  static const Block_Content_Dataview_Sort_EmptyType End =
      Block_Content_Dataview_Sort_EmptyType._(2, _omitEnumNames ? '' : 'End');

  static const $core.List<Block_Content_Dataview_Sort_EmptyType> values =
      <Block_Content_Dataview_Sort_EmptyType>[
    NotSpecified,
    Start,
    End,
  ];

  static final $core.List<Block_Content_Dataview_Sort_EmptyType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Block_Content_Dataview_Sort_EmptyType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Dataview_Sort_EmptyType._(super.value, super.name);
}

class Block_Content_Dataview_Filter_Operator extends $pb.ProtobufEnum {
  static const Block_Content_Dataview_Filter_Operator No =
      Block_Content_Dataview_Filter_Operator._(0, _omitEnumNames ? '' : 'No');
  static const Block_Content_Dataview_Filter_Operator Or =
      Block_Content_Dataview_Filter_Operator._(1, _omitEnumNames ? '' : 'Or');
  static const Block_Content_Dataview_Filter_Operator And =
      Block_Content_Dataview_Filter_Operator._(2, _omitEnumNames ? '' : 'And');

  static const $core.List<Block_Content_Dataview_Filter_Operator> values =
      <Block_Content_Dataview_Filter_Operator>[
    No,
    Or,
    And,
  ];

  static final $core.List<Block_Content_Dataview_Filter_Operator?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Block_Content_Dataview_Filter_Operator? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Dataview_Filter_Operator._(super.value, super.name);
}

class Block_Content_Dataview_Filter_Condition extends $pb.ProtobufEnum {
  static const Block_Content_Dataview_Filter_Condition None =
      Block_Content_Dataview_Filter_Condition._(
          0, _omitEnumNames ? '' : 'None');
  static const Block_Content_Dataview_Filter_Condition Equal =
      Block_Content_Dataview_Filter_Condition._(
          1, _omitEnumNames ? '' : 'Equal');
  static const Block_Content_Dataview_Filter_Condition NotEqual =
      Block_Content_Dataview_Filter_Condition._(
          2, _omitEnumNames ? '' : 'NotEqual');
  static const Block_Content_Dataview_Filter_Condition Greater =
      Block_Content_Dataview_Filter_Condition._(
          3, _omitEnumNames ? '' : 'Greater');
  static const Block_Content_Dataview_Filter_Condition Less =
      Block_Content_Dataview_Filter_Condition._(
          4, _omitEnumNames ? '' : 'Less');
  static const Block_Content_Dataview_Filter_Condition GreaterOrEqual =
      Block_Content_Dataview_Filter_Condition._(
          5, _omitEnumNames ? '' : 'GreaterOrEqual');
  static const Block_Content_Dataview_Filter_Condition LessOrEqual =
      Block_Content_Dataview_Filter_Condition._(
          6, _omitEnumNames ? '' : 'LessOrEqual');
  static const Block_Content_Dataview_Filter_Condition Like =
      Block_Content_Dataview_Filter_Condition._(
          7, _omitEnumNames ? '' : 'Like');
  static const Block_Content_Dataview_Filter_Condition NotLike =
      Block_Content_Dataview_Filter_Condition._(
          8, _omitEnumNames ? '' : 'NotLike');
  static const Block_Content_Dataview_Filter_Condition In =
      Block_Content_Dataview_Filter_Condition._(9, _omitEnumNames ? '' : 'In');
  static const Block_Content_Dataview_Filter_Condition NotIn =
      Block_Content_Dataview_Filter_Condition._(
          10, _omitEnumNames ? '' : 'NotIn');
  static const Block_Content_Dataview_Filter_Condition Empty =
      Block_Content_Dataview_Filter_Condition._(
          11, _omitEnumNames ? '' : 'Empty');
  static const Block_Content_Dataview_Filter_Condition NotEmpty =
      Block_Content_Dataview_Filter_Condition._(
          12, _omitEnumNames ? '' : 'NotEmpty');
  static const Block_Content_Dataview_Filter_Condition AllIn =
      Block_Content_Dataview_Filter_Condition._(
          13, _omitEnumNames ? '' : 'AllIn');
  static const Block_Content_Dataview_Filter_Condition NotAllIn =
      Block_Content_Dataview_Filter_Condition._(
          14, _omitEnumNames ? '' : 'NotAllIn');
  static const Block_Content_Dataview_Filter_Condition ExactIn =
      Block_Content_Dataview_Filter_Condition._(
          15, _omitEnumNames ? '' : 'ExactIn');
  static const Block_Content_Dataview_Filter_Condition NotExactIn =
      Block_Content_Dataview_Filter_Condition._(
          16, _omitEnumNames ? '' : 'NotExactIn');
  static const Block_Content_Dataview_Filter_Condition Exists =
      Block_Content_Dataview_Filter_Condition._(
          17, _omitEnumNames ? '' : 'Exists');

  static const $core.List<Block_Content_Dataview_Filter_Condition> values =
      <Block_Content_Dataview_Filter_Condition>[
    None,
    Equal,
    NotEqual,
    Greater,
    Less,
    GreaterOrEqual,
    LessOrEqual,
    Like,
    NotLike,
    In,
    NotIn,
    Empty,
    NotEmpty,
    AllIn,
    NotAllIn,
    ExactIn,
    NotExactIn,
    Exists,
  ];

  static final $core.List<Block_Content_Dataview_Filter_Condition?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 17);
  static Block_Content_Dataview_Filter_Condition? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Dataview_Filter_Condition._(super.value, super.name);
}

class Block_Content_Dataview_Filter_QuickOption extends $pb.ProtobufEnum {
  static const Block_Content_Dataview_Filter_QuickOption ExactDate =
      Block_Content_Dataview_Filter_QuickOption._(
          0, _omitEnumNames ? '' : 'ExactDate');
  static const Block_Content_Dataview_Filter_QuickOption Yesterday =
      Block_Content_Dataview_Filter_QuickOption._(
          1, _omitEnumNames ? '' : 'Yesterday');
  static const Block_Content_Dataview_Filter_QuickOption Today =
      Block_Content_Dataview_Filter_QuickOption._(
          2, _omitEnumNames ? '' : 'Today');
  static const Block_Content_Dataview_Filter_QuickOption Tomorrow =
      Block_Content_Dataview_Filter_QuickOption._(
          3, _omitEnumNames ? '' : 'Tomorrow');
  static const Block_Content_Dataview_Filter_QuickOption LastWeek =
      Block_Content_Dataview_Filter_QuickOption._(
          4, _omitEnumNames ? '' : 'LastWeek');
  static const Block_Content_Dataview_Filter_QuickOption CurrentWeek =
      Block_Content_Dataview_Filter_QuickOption._(
          5, _omitEnumNames ? '' : 'CurrentWeek');
  static const Block_Content_Dataview_Filter_QuickOption NextWeek =
      Block_Content_Dataview_Filter_QuickOption._(
          6, _omitEnumNames ? '' : 'NextWeek');
  static const Block_Content_Dataview_Filter_QuickOption LastMonth =
      Block_Content_Dataview_Filter_QuickOption._(
          7, _omitEnumNames ? '' : 'LastMonth');
  static const Block_Content_Dataview_Filter_QuickOption CurrentMonth =
      Block_Content_Dataview_Filter_QuickOption._(
          8, _omitEnumNames ? '' : 'CurrentMonth');
  static const Block_Content_Dataview_Filter_QuickOption NextMonth =
      Block_Content_Dataview_Filter_QuickOption._(
          9, _omitEnumNames ? '' : 'NextMonth');
  static const Block_Content_Dataview_Filter_QuickOption NumberOfDaysAgo =
      Block_Content_Dataview_Filter_QuickOption._(
          10, _omitEnumNames ? '' : 'NumberOfDaysAgo');
  static const Block_Content_Dataview_Filter_QuickOption NumberOfDaysNow =
      Block_Content_Dataview_Filter_QuickOption._(
          11, _omitEnumNames ? '' : 'NumberOfDaysNow');
  static const Block_Content_Dataview_Filter_QuickOption LastYear =
      Block_Content_Dataview_Filter_QuickOption._(
          12, _omitEnumNames ? '' : 'LastYear');
  static const Block_Content_Dataview_Filter_QuickOption CurrentYear =
      Block_Content_Dataview_Filter_QuickOption._(
          13, _omitEnumNames ? '' : 'CurrentYear');
  static const Block_Content_Dataview_Filter_QuickOption NextYear =
      Block_Content_Dataview_Filter_QuickOption._(
          14, _omitEnumNames ? '' : 'NextYear');

  static const $core.List<Block_Content_Dataview_Filter_QuickOption> values =
      <Block_Content_Dataview_Filter_QuickOption>[
    ExactDate,
    Yesterday,
    Today,
    Tomorrow,
    LastWeek,
    CurrentWeek,
    NextWeek,
    LastMonth,
    CurrentMonth,
    NextMonth,
    NumberOfDaysAgo,
    NumberOfDaysNow,
    LastYear,
    CurrentYear,
    NextYear,
  ];

  static final $core.List<Block_Content_Dataview_Filter_QuickOption?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 14);
  static Block_Content_Dataview_Filter_QuickOption? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Dataview_Filter_QuickOption._(super.value, super.name);
}

class Block_Content_Latex_Processor extends $pb.ProtobufEnum {
  static const Block_Content_Latex_Processor Latex =
      Block_Content_Latex_Processor._(0, _omitEnumNames ? '' : 'Latex');
  static const Block_Content_Latex_Processor Mermaid =
      Block_Content_Latex_Processor._(1, _omitEnumNames ? '' : 'Mermaid');
  static const Block_Content_Latex_Processor Chart =
      Block_Content_Latex_Processor._(2, _omitEnumNames ? '' : 'Chart');
  static const Block_Content_Latex_Processor Youtube =
      Block_Content_Latex_Processor._(3, _omitEnumNames ? '' : 'Youtube');
  static const Block_Content_Latex_Processor Vimeo =
      Block_Content_Latex_Processor._(4, _omitEnumNames ? '' : 'Vimeo');
  static const Block_Content_Latex_Processor Soundcloud =
      Block_Content_Latex_Processor._(5, _omitEnumNames ? '' : 'Soundcloud');
  static const Block_Content_Latex_Processor GoogleMaps =
      Block_Content_Latex_Processor._(6, _omitEnumNames ? '' : 'GoogleMaps');
  static const Block_Content_Latex_Processor Miro =
      Block_Content_Latex_Processor._(7, _omitEnumNames ? '' : 'Miro');
  static const Block_Content_Latex_Processor Figma =
      Block_Content_Latex_Processor._(8, _omitEnumNames ? '' : 'Figma');
  static const Block_Content_Latex_Processor Twitter =
      Block_Content_Latex_Processor._(9, _omitEnumNames ? '' : 'Twitter');
  static const Block_Content_Latex_Processor OpenStreetMap =
      Block_Content_Latex_Processor._(
          10, _omitEnumNames ? '' : 'OpenStreetMap');
  static const Block_Content_Latex_Processor Reddit =
      Block_Content_Latex_Processor._(11, _omitEnumNames ? '' : 'Reddit');
  static const Block_Content_Latex_Processor Facebook =
      Block_Content_Latex_Processor._(12, _omitEnumNames ? '' : 'Facebook');
  static const Block_Content_Latex_Processor Instagram =
      Block_Content_Latex_Processor._(13, _omitEnumNames ? '' : 'Instagram');
  static const Block_Content_Latex_Processor Telegram =
      Block_Content_Latex_Processor._(14, _omitEnumNames ? '' : 'Telegram');
  static const Block_Content_Latex_Processor GithubGist =
      Block_Content_Latex_Processor._(15, _omitEnumNames ? '' : 'GithubGist');
  static const Block_Content_Latex_Processor Codepen =
      Block_Content_Latex_Processor._(16, _omitEnumNames ? '' : 'Codepen');
  static const Block_Content_Latex_Processor Bilibili =
      Block_Content_Latex_Processor._(17, _omitEnumNames ? '' : 'Bilibili');
  static const Block_Content_Latex_Processor Excalidraw =
      Block_Content_Latex_Processor._(18, _omitEnumNames ? '' : 'Excalidraw');
  static const Block_Content_Latex_Processor Kroki =
      Block_Content_Latex_Processor._(19, _omitEnumNames ? '' : 'Kroki');
  static const Block_Content_Latex_Processor Graphviz =
      Block_Content_Latex_Processor._(20, _omitEnumNames ? '' : 'Graphviz');
  static const Block_Content_Latex_Processor Sketchfab =
      Block_Content_Latex_Processor._(21, _omitEnumNames ? '' : 'Sketchfab');
  static const Block_Content_Latex_Processor Image =
      Block_Content_Latex_Processor._(22, _omitEnumNames ? '' : 'Image');
  static const Block_Content_Latex_Processor Drawio =
      Block_Content_Latex_Processor._(23, _omitEnumNames ? '' : 'Drawio');
  static const Block_Content_Latex_Processor Spotify =
      Block_Content_Latex_Processor._(24, _omitEnumNames ? '' : 'Spotify');

  static const $core.List<Block_Content_Latex_Processor> values =
      <Block_Content_Latex_Processor>[
    Latex,
    Mermaid,
    Chart,
    Youtube,
    Vimeo,
    Soundcloud,
    GoogleMaps,
    Miro,
    Figma,
    Twitter,
    OpenStreetMap,
    Reddit,
    Facebook,
    Instagram,
    Telegram,
    GithubGist,
    Codepen,
    Bilibili,
    Excalidraw,
    Kroki,
    Graphviz,
    Sketchfab,
    Image,
    Drawio,
    Spotify,
  ];

  static final $core.List<Block_Content_Latex_Processor?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 24);
  static Block_Content_Latex_Processor? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Latex_Processor._(super.value, super.name);
}

class Block_Content_Widget_Layout extends $pb.ProtobufEnum {
  static const Block_Content_Widget_Layout Link =
      Block_Content_Widget_Layout._(0, _omitEnumNames ? '' : 'Link');
  static const Block_Content_Widget_Layout Tree =
      Block_Content_Widget_Layout._(1, _omitEnumNames ? '' : 'Tree');
  static const Block_Content_Widget_Layout List_ =
      Block_Content_Widget_Layout._(2, _omitEnumNames ? '' : 'List');
  static const Block_Content_Widget_Layout CompactList =
      Block_Content_Widget_Layout._(3, _omitEnumNames ? '' : 'CompactList');
  static const Block_Content_Widget_Layout View =
      Block_Content_Widget_Layout._(4, _omitEnumNames ? '' : 'View');

  static const $core.List<Block_Content_Widget_Layout> values =
      <Block_Content_Widget_Layout>[
    Link,
    Tree,
    List_,
    CompactList,
    View,
  ];

  static final $core.List<Block_Content_Widget_Layout?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static Block_Content_Widget_Layout? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Block_Content_Widget_Layout._(super.value, super.name);
}

class Account_StatusType extends $pb.ProtobufEnum {
  static const Account_StatusType Active =
      Account_StatusType._(0, _omitEnumNames ? '' : 'Active');
  static const Account_StatusType PendingDeletion =
      Account_StatusType._(1, _omitEnumNames ? '' : 'PendingDeletion');
  static const Account_StatusType StartedDeletion =
      Account_StatusType._(2, _omitEnumNames ? '' : 'StartedDeletion');
  static const Account_StatusType Deleted =
      Account_StatusType._(3, _omitEnumNames ? '' : 'Deleted');

  static const $core.List<Account_StatusType> values = <Account_StatusType>[
    Active,
    PendingDeletion,
    StartedDeletion,
    Deleted,
  ];

  static final $core.List<Account_StatusType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Account_StatusType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Account_StatusType._(super.value, super.name);
}

class Account_Auth_LocalApiScope extends $pb.ProtobufEnum {
  static const Account_Auth_LocalApiScope Limited =
      Account_Auth_LocalApiScope._(0, _omitEnumNames ? '' : 'Limited');
  static const Account_Auth_LocalApiScope JsonAPI =
      Account_Auth_LocalApiScope._(1, _omitEnumNames ? '' : 'JsonAPI');
  static const Account_Auth_LocalApiScope Full =
      Account_Auth_LocalApiScope._(2, _omitEnumNames ? '' : 'Full');

  static const $core.List<Account_Auth_LocalApiScope> values =
      <Account_Auth_LocalApiScope>[
    Limited,
    JsonAPI,
    Full,
  ];

  static final $core.List<Account_Auth_LocalApiScope?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Account_Auth_LocalApiScope? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Account_Auth_LocalApiScope._(super.value, super.name);
}

class LinkPreview_Type extends $pb.ProtobufEnum {
  static const LinkPreview_Type Unknown =
      LinkPreview_Type._(0, _omitEnumNames ? '' : 'Unknown');
  static const LinkPreview_Type Page =
      LinkPreview_Type._(1, _omitEnumNames ? '' : 'Page');
  static const LinkPreview_Type Image =
      LinkPreview_Type._(2, _omitEnumNames ? '' : 'Image');
  static const LinkPreview_Type Text =
      LinkPreview_Type._(3, _omitEnumNames ? '' : 'Text');

  static const $core.List<LinkPreview_Type> values = <LinkPreview_Type>[
    Unknown,
    Page,
    Image,
    Text,
  ];

  static final $core.List<LinkPreview_Type?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static LinkPreview_Type? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const LinkPreview_Type._(super.value, super.name);
}

class Restrictions_ObjectRestriction extends $pb.ProtobufEnum {
  static const Restrictions_ObjectRestriction None =
      Restrictions_ObjectRestriction._(0, _omitEnumNames ? '' : 'None');

  /// restricts delete
  static const Restrictions_ObjectRestriction Delete =
      Restrictions_ObjectRestriction._(1, _omitEnumNames ? '' : 'Delete');

  /// restricts work with relations
  static const Restrictions_ObjectRestriction Relations =
      Restrictions_ObjectRestriction._(2, _omitEnumNames ? '' : 'Relations');

  /// restricts work with blocks
  static const Restrictions_ObjectRestriction Blocks =
      Restrictions_ObjectRestriction._(3, _omitEnumNames ? '' : 'Blocks');

  /// restricts work with details
  static const Restrictions_ObjectRestriction Details =
      Restrictions_ObjectRestriction._(4, _omitEnumNames ? '' : 'Details');

  /// restricts type changing
  static const Restrictions_ObjectRestriction TypeChange =
      Restrictions_ObjectRestriction._(5, _omitEnumNames ? '' : 'TypeChange');

  /// restricts layout changing
  static const Restrictions_ObjectRestriction LayoutChange =
      Restrictions_ObjectRestriction._(6, _omitEnumNames ? '' : 'LayoutChange');

  /// restricts template creation from this object
  static const Restrictions_ObjectRestriction Template =
      Restrictions_ObjectRestriction._(7, _omitEnumNames ? '' : 'Template');

  /// restricts duplicate object
  static const Restrictions_ObjectRestriction Duplicate =
      Restrictions_ObjectRestriction._(8, _omitEnumNames ? '' : 'Duplicate');

  /// can be set only for types. Restricts creating objects of this type
  static const Restrictions_ObjectRestriction CreateObjectOfThisType =
      Restrictions_ObjectRestriction._(
          9, _omitEnumNames ? '' : 'CreateObjectOfThisType');

  /// object is not allowed to publish
  static const Restrictions_ObjectRestriction Publish =
      Restrictions_ObjectRestriction._(10, _omitEnumNames ? '' : 'Publish');

  static const $core.List<Restrictions_ObjectRestriction> values =
      <Restrictions_ObjectRestriction>[
    None,
    Delete,
    Relations,
    Blocks,
    Details,
    TypeChange,
    LayoutChange,
    Template,
    Duplicate,
    CreateObjectOfThisType,
    Publish,
  ];

  static final $core.List<Restrictions_ObjectRestriction?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 10);
  static Restrictions_ObjectRestriction? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Restrictions_ObjectRestriction._(super.value, super.name);
}

class Restrictions_DataviewRestriction extends $pb.ProtobufEnum {
  static const Restrictions_DataviewRestriction DVNone =
      Restrictions_DataviewRestriction._(0, _omitEnumNames ? '' : 'DVNone');
  static const Restrictions_DataviewRestriction DVRelation =
      Restrictions_DataviewRestriction._(1, _omitEnumNames ? '' : 'DVRelation');
  static const Restrictions_DataviewRestriction DVCreateObject =
      Restrictions_DataviewRestriction._(
          2, _omitEnumNames ? '' : 'DVCreateObject');
  static const Restrictions_DataviewRestriction DVViews =
      Restrictions_DataviewRestriction._(3, _omitEnumNames ? '' : 'DVViews');

  static const $core.List<Restrictions_DataviewRestriction> values =
      <Restrictions_DataviewRestriction>[
    DVNone,
    DVRelation,
    DVCreateObject,
    DVViews,
  ];

  static final $core.List<Restrictions_DataviewRestriction?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Restrictions_DataviewRestriction? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Restrictions_DataviewRestriction._(super.value, super.name);
}

class ObjectType_Layout extends $pb.ProtobufEnum {
  static const ObjectType_Layout basic =
      ObjectType_Layout._(0, _omitEnumNames ? '' : 'basic');
  static const ObjectType_Layout profile =
      ObjectType_Layout._(1, _omitEnumNames ? '' : 'profile');
  static const ObjectType_Layout todo =
      ObjectType_Layout._(2, _omitEnumNames ? '' : 'todo');
  static const ObjectType_Layout set =
      ObjectType_Layout._(3, _omitEnumNames ? '' : 'set');
  static const ObjectType_Layout objectType =
      ObjectType_Layout._(4, _omitEnumNames ? '' : 'objectType');
  static const ObjectType_Layout relation =
      ObjectType_Layout._(5, _omitEnumNames ? '' : 'relation');
  static const ObjectType_Layout file =
      ObjectType_Layout._(6, _omitEnumNames ? '' : 'file');
  static const ObjectType_Layout dashboard =
      ObjectType_Layout._(7, _omitEnumNames ? '' : 'dashboard');
  static const ObjectType_Layout image =
      ObjectType_Layout._(8, _omitEnumNames ? '' : 'image');
  static const ObjectType_Layout note =
      ObjectType_Layout._(9, _omitEnumNames ? '' : 'note');
  static const ObjectType_Layout space =
      ObjectType_Layout._(10, _omitEnumNames ? '' : 'space');
  static const ObjectType_Layout bookmark =
      ObjectType_Layout._(11, _omitEnumNames ? '' : 'bookmark');
  static const ObjectType_Layout relationOptionsList =
      ObjectType_Layout._(12, _omitEnumNames ? '' : 'relationOptionsList');
  static const ObjectType_Layout relationOption =
      ObjectType_Layout._(13, _omitEnumNames ? '' : 'relationOption');
  static const ObjectType_Layout collection =
      ObjectType_Layout._(14, _omitEnumNames ? '' : 'collection');
  static const ObjectType_Layout audio =
      ObjectType_Layout._(15, _omitEnumNames ? '' : 'audio');
  static const ObjectType_Layout video =
      ObjectType_Layout._(16, _omitEnumNames ? '' : 'video');
  static const ObjectType_Layout date =
      ObjectType_Layout._(17, _omitEnumNames ? '' : 'date');
  static const ObjectType_Layout spaceView =
      ObjectType_Layout._(18, _omitEnumNames ? '' : 'spaceView');
  static const ObjectType_Layout participant =
      ObjectType_Layout._(19, _omitEnumNames ? '' : 'participant');
  static const ObjectType_Layout pdf =
      ObjectType_Layout._(20, _omitEnumNames ? '' : 'pdf');
  static const ObjectType_Layout chatDeprecated =
      ObjectType_Layout._(21, _omitEnumNames ? '' : 'chatDeprecated');
  static const ObjectType_Layout chatDerived =
      ObjectType_Layout._(22, _omitEnumNames ? '' : 'chatDerived');
  static const ObjectType_Layout tag =
      ObjectType_Layout._(23, _omitEnumNames ? '' : 'tag');
  static const ObjectType_Layout notification =
      ObjectType_Layout._(24, _omitEnumNames ? '' : 'notification');
  static const ObjectType_Layout missingObject =
      ObjectType_Layout._(25, _omitEnumNames ? '' : 'missingObject');
  static const ObjectType_Layout devices =
      ObjectType_Layout._(26, _omitEnumNames ? '' : 'devices');
  static const ObjectType_Layout discussion =
      ObjectType_Layout._(27, _omitEnumNames ? '' : 'discussion');

  static const $core.List<ObjectType_Layout> values = <ObjectType_Layout>[
    basic,
    profile,
    todo,
    set,
    objectType,
    relation,
    file,
    dashboard,
    image,
    note,
    space,
    bookmark,
    relationOptionsList,
    relationOption,
    collection,
    audio,
    video,
    date,
    spaceView,
    participant,
    pdf,
    chatDeprecated,
    chatDerived,
    tag,
    notification,
    missingObject,
    devices,
    discussion,
  ];

  static final $core.List<ObjectType_Layout?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 27);
  static ObjectType_Layout? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ObjectType_Layout._(super.value, super.name);
}

class Relation_Scope extends $pb.ProtobufEnum {
  static const Relation_Scope object =
      Relation_Scope._(0, _omitEnumNames ? '' : 'object');
  static const Relation_Scope type =
      Relation_Scope._(1, _omitEnumNames ? '' : 'type');
  static const Relation_Scope setOfTheSameType =
      Relation_Scope._(2, _omitEnumNames ? '' : 'setOfTheSameType');
  static const Relation_Scope objectsOfTheSameType =
      Relation_Scope._(3, _omitEnumNames ? '' : 'objectsOfTheSameType');
  static const Relation_Scope library =
      Relation_Scope._(4, _omitEnumNames ? '' : 'library');

  static const $core.List<Relation_Scope> values = <Relation_Scope>[
    object,
    type,
    setOfTheSameType,
    objectsOfTheSameType,
    library,
  ];

  static final $core.List<Relation_Scope?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static Relation_Scope? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Relation_Scope._(super.value, super.name);
}

class Relation_DataSource extends $pb.ProtobufEnum {
  static const Relation_DataSource details =
      Relation_DataSource._(0, _omitEnumNames ? '' : 'details');
  static const Relation_DataSource derived =
      Relation_DataSource._(1, _omitEnumNames ? '' : 'derived');
  static const Relation_DataSource account =
      Relation_DataSource._(2, _omitEnumNames ? '' : 'account');
  static const Relation_DataSource local =
      Relation_DataSource._(3, _omitEnumNames ? '' : 'local');

  static const $core.List<Relation_DataSource> values = <Relation_DataSource>[
    details,
    derived,
    account,
    local,
  ];

  static final $core.List<Relation_DataSource?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Relation_DataSource? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Relation_DataSource._(super.value, super.name);
}

/// Use such a weird construction due to the issue with imported repeated enum type
/// Look https://github.com/golang/protobuf/issues/1135 for more information.
class InternalFlag_Value extends $pb.ProtobufEnum {
  static const InternalFlag_Value editorDeleteEmpty =
      InternalFlag_Value._(0, _omitEnumNames ? '' : 'editorDeleteEmpty');
  static const InternalFlag_Value editorSelectType =
      InternalFlag_Value._(1, _omitEnumNames ? '' : 'editorSelectType');
  static const InternalFlag_Value editorSelectTemplate =
      InternalFlag_Value._(2, _omitEnumNames ? '' : 'editorSelectTemplate');
  static const InternalFlag_Value collectionDontIndexLinks =
      InternalFlag_Value._(3, _omitEnumNames ? '' : 'collectionDontIndexLinks');

  static const $core.List<InternalFlag_Value> values = <InternalFlag_Value>[
    editorDeleteEmpty,
    editorSelectType,
    editorSelectTemplate,
    collectionDontIndexLinks,
  ];

  static final $core.List<InternalFlag_Value?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static InternalFlag_Value? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const InternalFlag_Value._(super.value, super.name);
}

class Notification_Status extends $pb.ProtobufEnum {
  static const Notification_Status Created =
      Notification_Status._(0, _omitEnumNames ? '' : 'Created');
  static const Notification_Status Shown =
      Notification_Status._(1, _omitEnumNames ? '' : 'Shown');
  static const Notification_Status Read =
      Notification_Status._(2, _omitEnumNames ? '' : 'Read');
  static const Notification_Status Replied =
      Notification_Status._(3, _omitEnumNames ? '' : 'Replied');

  static const $core.List<Notification_Status> values = <Notification_Status>[
    Created,
    Shown,
    Read,
    Replied,
  ];

  static final $core.List<Notification_Status?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Notification_Status? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Notification_Status._(super.value, super.name);
}

class Notification_ActionType extends $pb.ProtobufEnum {
  static const Notification_ActionType CLOSE =
      Notification_ActionType._(0, _omitEnumNames ? '' : 'CLOSE');

  static const $core.List<Notification_ActionType> values =
      <Notification_ActionType>[
    CLOSE,
  ];

  static final $core.List<Notification_ActionType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 0);
  static Notification_ActionType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Notification_ActionType._(super.value, super.name);
}

class Notification_Export_Code extends $pb.ProtobufEnum {
  static const Notification_Export_Code NULL =
      Notification_Export_Code._(0, _omitEnumNames ? '' : 'NULL');
  static const Notification_Export_Code UNKNOWN_ERROR =
      Notification_Export_Code._(1, _omitEnumNames ? '' : 'UNKNOWN_ERROR');
  static const Notification_Export_Code BAD_INPUT =
      Notification_Export_Code._(2, _omitEnumNames ? '' : 'BAD_INPUT');

  static const $core.List<Notification_Export_Code> values =
      <Notification_Export_Code>[
    NULL,
    UNKNOWN_ERROR,
    BAD_INPUT,
  ];

  static final $core.List<Notification_Export_Code?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Notification_Export_Code? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Notification_Export_Code._(super.value, super.name);
}

class Export_Format extends $pb.ProtobufEnum {
  static const Export_Format Markdown =
      Export_Format._(0, _omitEnumNames ? '' : 'Markdown');
  static const Export_Format Protobuf =
      Export_Format._(1, _omitEnumNames ? '' : 'Protobuf');
  static const Export_Format JSON =
      Export_Format._(2, _omitEnumNames ? '' : 'JSON');
  static const Export_Format DOT =
      Export_Format._(3, _omitEnumNames ? '' : 'DOT');
  static const Export_Format SVG =
      Export_Format._(4, _omitEnumNames ? '' : 'SVG');
  static const Export_Format GRAPH_JSON =
      Export_Format._(5, _omitEnumNames ? '' : 'GRAPH_JSON');

  static const $core.List<Export_Format> values = <Export_Format>[
    Markdown,
    Protobuf,
    JSON,
    DOT,
    SVG,
    GRAPH_JSON,
  ];

  static final $core.List<Export_Format?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static Export_Format? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Export_Format._(super.value, super.name);
}

class Import_Type extends $pb.ProtobufEnum {
  static const Import_Type Notion =
      Import_Type._(0, _omitEnumNames ? '' : 'Notion');
  static const Import_Type Markdown =
      Import_Type._(1, _omitEnumNames ? '' : 'Markdown');
  static const Import_Type External =
      Import_Type._(2, _omitEnumNames ? '' : 'External');
  static const Import_Type Pb = Import_Type._(3, _omitEnumNames ? '' : 'Pb');
  static const Import_Type Html =
      Import_Type._(4, _omitEnumNames ? '' : 'Html');
  static const Import_Type Txt = Import_Type._(5, _omitEnumNames ? '' : 'Txt');
  static const Import_Type Csv = Import_Type._(6, _omitEnumNames ? '' : 'Csv');
  static const Import_Type Obsidian =
      Import_Type._(7, _omitEnumNames ? '' : 'Obsidian');

  static const $core.List<Import_Type> values = <Import_Type>[
    Notion,
    Markdown,
    External,
    Pb,
    Html,
    Txt,
    Csv,
    Obsidian,
  ];

  static final $core.List<Import_Type?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static Import_Type? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Import_Type._(super.value, super.name);
}

class Import_ErrorCode extends $pb.ProtobufEnum {
  static const Import_ErrorCode NULL =
      Import_ErrorCode._(0, _omitEnumNames ? '' : 'NULL');
  static const Import_ErrorCode UNKNOWN_ERROR =
      Import_ErrorCode._(1, _omitEnumNames ? '' : 'UNKNOWN_ERROR');
  static const Import_ErrorCode BAD_INPUT =
      Import_ErrorCode._(2, _omitEnumNames ? '' : 'BAD_INPUT');
  static const Import_ErrorCode INTERNAL_ERROR =
      Import_ErrorCode._(3, _omitEnumNames ? '' : 'INTERNAL_ERROR');
  static const Import_ErrorCode FILE_LOAD_ERROR =
      Import_ErrorCode._(8, _omitEnumNames ? '' : 'FILE_LOAD_ERROR');
  static const Import_ErrorCode IMPORT_IS_CANCELED =
      Import_ErrorCode._(6, _omitEnumNames ? '' : 'IMPORT_IS_CANCELED');
  static const Import_ErrorCode NOTION_NO_OBJECTS_IN_INTEGRATION =
      Import_ErrorCode._(
          5, _omitEnumNames ? '' : 'NOTION_NO_OBJECTS_IN_INTEGRATION');
  static const Import_ErrorCode NOTION_SERVER_IS_UNAVAILABLE =
      Import_ErrorCode._(
          12, _omitEnumNames ? '' : 'NOTION_SERVER_IS_UNAVAILABLE');
  static const Import_ErrorCode NOTION_RATE_LIMIT_EXCEEDED = Import_ErrorCode._(
      13, _omitEnumNames ? '' : 'NOTION_RATE_LIMIT_EXCEEDED');
  static const Import_ErrorCode FILE_IMPORT_NO_OBJECTS_IN_ZIP_ARCHIVE =
      Import_ErrorCode._(
          14, _omitEnumNames ? '' : 'FILE_IMPORT_NO_OBJECTS_IN_ZIP_ARCHIVE');
  static const Import_ErrorCode FILE_IMPORT_NO_OBJECTS_IN_DIRECTORY =
      Import_ErrorCode._(
          17, _omitEnumNames ? '' : 'FILE_IMPORT_NO_OBJECTS_IN_DIRECTORY');
  static const Import_ErrorCode HTML_WRONG_HTML_STRUCTURE =
      Import_ErrorCode._(10, _omitEnumNames ? '' : 'HTML_WRONG_HTML_STRUCTURE');
  static const Import_ErrorCode PB_NOT_ANYBLOCK_FORMAT =
      Import_ErrorCode._(11, _omitEnumNames ? '' : 'PB_NOT_ANYBLOCK_FORMAT');
  static const Import_ErrorCode CSV_LIMIT_OF_ROWS_OR_RELATIONS_EXCEEDED =
      Import_ErrorCode._(
          7, _omitEnumNames ? '' : 'CSV_LIMIT_OF_ROWS_OR_RELATIONS_EXCEEDED');
  static const Import_ErrorCode INSUFFICIENT_PERMISSIONS =
      Import_ErrorCode._(9, _omitEnumNames ? '' : 'INSUFFICIENT_PERMISSIONS');

  static const $core.List<Import_ErrorCode> values = <Import_ErrorCode>[
    NULL,
    UNKNOWN_ERROR,
    BAD_INPUT,
    INTERNAL_ERROR,
    FILE_LOAD_ERROR,
    IMPORT_IS_CANCELED,
    NOTION_NO_OBJECTS_IN_INTEGRATION,
    NOTION_SERVER_IS_UNAVAILABLE,
    NOTION_RATE_LIMIT_EXCEEDED,
    FILE_IMPORT_NO_OBJECTS_IN_ZIP_ARCHIVE,
    FILE_IMPORT_NO_OBJECTS_IN_DIRECTORY,
    HTML_WRONG_HTML_STRUCTURE,
    PB_NOT_ANYBLOCK_FORMAT,
    CSV_LIMIT_OF_ROWS_OR_RELATIONS_EXCEEDED,
    INSUFFICIENT_PERMISSIONS,
  ];

  static final $core.List<Import_ErrorCode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 17);
  static Import_ErrorCode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Import_ErrorCode._(super.value, super.name);
}

class Membership_Status extends $pb.ProtobufEnum {
  static const Membership_Status StatusUnknown =
      Membership_Status._(0, _omitEnumNames ? '' : 'StatusUnknown');

  /// please wait a bit more, we are still processing your request
  /// the payment is confirmed, but we need more time to do some side-effects:
  /// - increase limits
  /// - send emails
  /// - allocate names
  static const Membership_Status StatusPending =
      Membership_Status._(1, _omitEnumNames ? '' : 'StatusPending');

  /// the membership is active, ready to use!
  static const Membership_Status StatusActive =
      Membership_Status._(2, _omitEnumNames ? '' : 'StatusActive');

  /// in some cases we need to finalize the process:
  /// - if user has bought membership directly without first calling
  /// the BuySubscription method
  /// in this case please call Finalize to finish the process
  static const Membership_Status StatusPendingRequiresFinalization =
      Membership_Status._(
          3, _omitEnumNames ? '' : 'StatusPendingRequiresFinalization');

  static const $core.List<Membership_Status> values = <Membership_Status>[
    StatusUnknown,
    StatusPending,
    StatusActive,
    StatusPendingRequiresFinalization,
  ];

  static final $core.List<Membership_Status?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Membership_Status? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Membership_Status._(super.value, super.name);
}

class Membership_PaymentMethod extends $pb.ProtobufEnum {
  static const Membership_PaymentMethod MethodNone =
      Membership_PaymentMethod._(0, _omitEnumNames ? '' : 'MethodNone');
  static const Membership_PaymentMethod MethodStripe =
      Membership_PaymentMethod._(1, _omitEnumNames ? '' : 'MethodStripe');
  static const Membership_PaymentMethod MethodCrypto =
      Membership_PaymentMethod._(2, _omitEnumNames ? '' : 'MethodCrypto');
  static const Membership_PaymentMethod MethodInappApple =
      Membership_PaymentMethod._(3, _omitEnumNames ? '' : 'MethodInappApple');
  static const Membership_PaymentMethod MethodInappGoogle =
      Membership_PaymentMethod._(4, _omitEnumNames ? '' : 'MethodInappGoogle');

  static const $core.List<Membership_PaymentMethod> values =
      <Membership_PaymentMethod>[
    MethodNone,
    MethodStripe,
    MethodCrypto,
    MethodInappApple,
    MethodInappGoogle,
  ];

  static final $core.List<Membership_PaymentMethod?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static Membership_PaymentMethod? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Membership_PaymentMethod._(super.value, super.name);
}

class Membership_EmailVerificationStatus extends $pb.ProtobufEnum {
  /// user NEVER comleted the verification of the email
  static const Membership_EmailVerificationStatus StatusNotVerified =
      Membership_EmailVerificationStatus._(
          0, _omitEnumNames ? '' : 'StatusNotVerified');

  /// user has asked for new code, but did not enter it yet
  /// (even if email was verified before, you can ask to UPDATE your e-mail)
  /// please wait, you can not ask for more codes yet
  static const Membership_EmailVerificationStatus StatusCodeSent =
      Membership_EmailVerificationStatus._(
          1, _omitEnumNames ? '' : 'StatusCodeSent');

  /// the e-mail is finally verified
  static const Membership_EmailVerificationStatus StatusVerified =
      Membership_EmailVerificationStatus._(
          2, _omitEnumNames ? '' : 'StatusVerified');

  static const $core.List<Membership_EmailVerificationStatus> values =
      <Membership_EmailVerificationStatus>[
    StatusNotVerified,
    StatusCodeSent,
    StatusVerified,
  ];

  static final $core.List<Membership_EmailVerificationStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Membership_EmailVerificationStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Membership_EmailVerificationStatus._(super.value, super.name);
}

class MembershipTierData_PeriodType extends $pb.ProtobufEnum {
  static const MembershipTierData_PeriodType PeriodTypeUnknown =
      MembershipTierData_PeriodType._(
          0, _omitEnumNames ? '' : 'PeriodTypeUnknown');
  static const MembershipTierData_PeriodType PeriodTypeUnlimited =
      MembershipTierData_PeriodType._(
          1, _omitEnumNames ? '' : 'PeriodTypeUnlimited');
  static const MembershipTierData_PeriodType PeriodTypeDays =
      MembershipTierData_PeriodType._(
          2, _omitEnumNames ? '' : 'PeriodTypeDays');
  static const MembershipTierData_PeriodType PeriodTypeWeeks =
      MembershipTierData_PeriodType._(
          3, _omitEnumNames ? '' : 'PeriodTypeWeeks');
  static const MembershipTierData_PeriodType PeriodTypeMonths =
      MembershipTierData_PeriodType._(
          4, _omitEnumNames ? '' : 'PeriodTypeMonths');
  static const MembershipTierData_PeriodType PeriodTypeYears =
      MembershipTierData_PeriodType._(
          5, _omitEnumNames ? '' : 'PeriodTypeYears');

  static const $core.List<MembershipTierData_PeriodType> values =
      <MembershipTierData_PeriodType>[
    PeriodTypeUnknown,
    PeriodTypeUnlimited,
    PeriodTypeDays,
    PeriodTypeWeeks,
    PeriodTypeMonths,
    PeriodTypeYears,
  ];

  static final $core.List<MembershipTierData_PeriodType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static MembershipTierData_PeriodType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MembershipTierData_PeriodType._(super.value, super.name);
}

class MembershipV2_Platform extends $pb.ProtobufEnum {
  static const MembershipV2_Platform Unknown =
      MembershipV2_Platform._(0, _omitEnumNames ? '' : 'Unknown');
  static const MembershipV2_Platform Desktop =
      MembershipV2_Platform._(1, _omitEnumNames ? '' : 'Desktop');
  static const MembershipV2_Platform MobileIOS =
      MembershipV2_Platform._(2, _omitEnumNames ? '' : 'MobileIOS');
  static const MembershipV2_Platform MobileAndroid =
      MembershipV2_Platform._(3, _omitEnumNames ? '' : 'MobileAndroid');
  static const MembershipV2_Platform Web =
      MembershipV2_Platform._(4, _omitEnumNames ? '' : 'Web');

  static const $core.List<MembershipV2_Platform> values =
      <MembershipV2_Platform>[
    Unknown,
    Desktop,
    MobileIOS,
    MobileAndroid,
    Web,
  ];

  static final $core.List<MembershipV2_Platform?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static MembershipV2_Platform? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MembershipV2_Platform._(super.value, super.name);
}

class MembershipV2_PaymentProvider extends $pb.ProtobufEnum {
  static const MembershipV2_PaymentProvider None =
      MembershipV2_PaymentProvider._(0, _omitEnumNames ? '' : 'None');
  static const MembershipV2_PaymentProvider Stripe =
      MembershipV2_PaymentProvider._(1, _omitEnumNames ? '' : 'Stripe');
  static const MembershipV2_PaymentProvider Crypto =
      MembershipV2_PaymentProvider._(2, _omitEnumNames ? '' : 'Crypto');
  static const MembershipV2_PaymentProvider BillingPortal =
      MembershipV2_PaymentProvider._(3, _omitEnumNames ? '' : 'BillingPortal');
  static const MembershipV2_PaymentProvider AppStore =
      MembershipV2_PaymentProvider._(4, _omitEnumNames ? '' : 'AppStore');
  static const MembershipV2_PaymentProvider GooglePlay =
      MembershipV2_PaymentProvider._(5, _omitEnumNames ? '' : 'GooglePlay');

  static const $core.List<MembershipV2_PaymentProvider> values =
      <MembershipV2_PaymentProvider>[
    None,
    Stripe,
    Crypto,
    BillingPortal,
    AppStore,
    GooglePlay,
  ];

  static final $core.List<MembershipV2_PaymentProvider?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static MembershipV2_PaymentProvider? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MembershipV2_PaymentProvider._(super.value, super.name);
}

class MembershipV2_Period extends $pb.ProtobufEnum {
  static const MembershipV2_Period Unlimited =
      MembershipV2_Period._(0, _omitEnumNames ? '' : 'Unlimited');
  static const MembershipV2_Period Monthly =
      MembershipV2_Period._(1, _omitEnumNames ? '' : 'Monthly');
  static const MembershipV2_Period Yearly =
      MembershipV2_Period._(2, _omitEnumNames ? '' : 'Yearly');
  static const MembershipV2_Period ThreeYears =
      MembershipV2_Period._(3, _omitEnumNames ? '' : 'ThreeYears');

  static const $core.List<MembershipV2_Period> values = <MembershipV2_Period>[
    Unlimited,
    Monthly,
    Yearly,
    ThreeYears,
  ];

  static final $core.List<MembershipV2_Period?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static MembershipV2_Period? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MembershipV2_Period._(super.value, super.name);
}

class MembershipV2_ProductStatus_Status extends $pb.ProtobufEnum {
  static const MembershipV2_ProductStatus_Status StatusUnknown =
      MembershipV2_ProductStatus_Status._(
          0, _omitEnumNames ? '' : 'StatusUnknown');
  static const MembershipV2_ProductStatus_Status StatusPending =
      MembershipV2_ProductStatus_Status._(
          1, _omitEnumNames ? '' : 'StatusPending');
  static const MembershipV2_ProductStatus_Status StatusActive =
      MembershipV2_ProductStatus_Status._(
          2, _omitEnumNames ? '' : 'StatusActive');
  static const MembershipV2_ProductStatus_Status
      StatusPendingRequiresAnyNameAllocation =
      MembershipV2_ProductStatus_Status._(
          3, _omitEnumNames ? '' : 'StatusPendingRequiresAnyNameAllocation');

  static const $core.List<MembershipV2_ProductStatus_Status> values =
      <MembershipV2_ProductStatus_Status>[
    StatusUnknown,
    StatusPending,
    StatusActive,
    StatusPendingRequiresAnyNameAllocation,
  ];

  static final $core.List<MembershipV2_ProductStatus_Status?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static MembershipV2_ProductStatus_Status? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MembershipV2_ProductStatus_Status._(super.value, super.name);
}

class ChatMessage_Attachment_AttachmentType extends $pb.ProtobufEnum {
  static const ChatMessage_Attachment_AttachmentType FILE =
      ChatMessage_Attachment_AttachmentType._(0, _omitEnumNames ? '' : 'FILE');
  static const ChatMessage_Attachment_AttachmentType IMAGE =
      ChatMessage_Attachment_AttachmentType._(1, _omitEnumNames ? '' : 'IMAGE');
  static const ChatMessage_Attachment_AttachmentType LINK =
      ChatMessage_Attachment_AttachmentType._(2, _omitEnumNames ? '' : 'LINK');

  static const $core.List<ChatMessage_Attachment_AttachmentType> values =
      <ChatMessage_Attachment_AttachmentType>[
    FILE,
    IMAGE,
    LINK,
  ];

  static final $core.List<ChatMessage_Attachment_AttachmentType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ChatMessage_Attachment_AttachmentType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ChatMessage_Attachment_AttachmentType._(super.value, super.name);
}

class ChatMessage_MessageBlockLink_LinkType extends $pb.ProtobufEnum {
  static const ChatMessage_MessageBlockLink_LinkType Object_ =
      ChatMessage_MessageBlockLink_LinkType._(
          0, _omitEnumNames ? '' : 'Object');
  static const ChatMessage_MessageBlockLink_LinkType File =
      ChatMessage_MessageBlockLink_LinkType._(1, _omitEnumNames ? '' : 'File');
  static const ChatMessage_MessageBlockLink_LinkType Image =
      ChatMessage_MessageBlockLink_LinkType._(2, _omitEnumNames ? '' : 'Image');
  static const ChatMessage_MessageBlockLink_LinkType Bookmark =
      ChatMessage_MessageBlockLink_LinkType._(
          3, _omitEnumNames ? '' : 'Bookmark');

  static const $core.List<ChatMessage_MessageBlockLink_LinkType> values =
      <ChatMessage_MessageBlockLink_LinkType>[
    Object_,
    File,
    Image,
    Bookmark,
  ];

  static final $core.List<ChatMessage_MessageBlockLink_LinkType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static ChatMessage_MessageBlockLink_LinkType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ChatMessage_MessageBlockLink_LinkType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
