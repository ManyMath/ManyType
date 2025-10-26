// This is a generated file - do not edit.
//
// Generated from any_block/events.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use eventDescriptor instead')
const Event$json = {
  '1': 'Event',
  '3': [Event_Message$json, Event_Block$json],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Message$json = {
  '1': 'Message',
  '2': [
    {'1': 'spaceId', '3': 132, '4': 1, '5': 9, '10': 'spaceId'},
    {
      '1': 'blockSetFields',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Fields',
      '9': 0,
      '10': 'blockSetFields'
    },
    {
      '1': 'blockSetChildrenIds',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.ChildrenIds',
      '9': 0,
      '10': 'blockSetChildrenIds'
    },
    {
      '1': 'blockSetBackgroundColor',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.BackgroundColor',
      '9': 0,
      '10': 'blockSetBackgroundColor'
    },
    {
      '1': 'blockSetText',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Text',
      '9': 0,
      '10': 'blockSetText'
    },
    {
      '1': 'blockSetAlign',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Align',
      '9': 0,
      '10': 'blockSetAlign'
    },
    {
      '1': 'blockSetDiv',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Div',
      '9': 0,
      '10': 'blockSetDiv'
    },
    {
      '1': 'blockSetRelation',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Relation',
      '9': 0,
      '10': 'blockSetRelation'
    },
    {
      '1': 'blockSetLatex',
      '3': 25,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Latex',
      '9': 0,
      '10': 'blockSetLatex'
    },
    {
      '1': 'blockSetVerticalAlign',
      '3': 36,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.VerticalAlign',
      '9': 0,
      '10': 'blockSetVerticalAlign'
    },
    {
      '1': 'blockSetTableRow',
      '3': 37,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.TableRow',
      '9': 0,
      '10': 'blockSetTableRow'
    },
    {
      '1': 'blockSetWidget',
      '3': 40,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Widget',
      '9': 0,
      '10': 'blockSetWidget'
    },
  ],
  '8': [
    {'1': 'value'},
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block$json = {
  '1': 'Block',
  '3': [Event_Block_Set$json],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set$json = {
  '1': 'Set',
  '3': [
    Event_Block_Set_Relation$json,
    Event_Block_Set_Fields$json,
    Event_Block_Set_ChildrenIds$json,
    Event_Block_Set_BackgroundColor$json,
    Event_Block_Set_Align$json,
    Event_Block_Set_VerticalAlign$json,
    Event_Block_Set_Text$json,
    Event_Block_Set_Latex$json,
    Event_Block_Set_Div$json,
    Event_Block_Set_TableRow$json,
    Event_Block_Set_Widget$json
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Relation$json = {
  '1': 'Relation',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'key',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Relation.Key',
      '10': 'key'
    },
  ],
  '3': [Event_Block_Set_Relation_Key$json],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Relation_Key$json = {
  '1': 'Key',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Fields$json = {
  '1': 'Fields',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'fields',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Struct',
      '10': 'fields'
    },
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_ChildrenIds$json = {
  '1': 'ChildrenIds',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'childrenIds', '3': 2, '4': 3, '5': 9, '10': 'childrenIds'},
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_BackgroundColor$json = {
  '1': 'BackgroundColor',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'backgroundColor', '3': 2, '4': 1, '5': 9, '10': 'backgroundColor'},
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Align$json = {
  '1': 'Align',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'align',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Align',
      '10': 'align'
    },
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_VerticalAlign$json = {
  '1': 'VerticalAlign',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'verticalAlign',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.VerticalAlign',
      '10': 'verticalAlign'
    },
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Text$json = {
  '1': 'Text',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'text',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Text.TextValue',
      '10': 'text'
    },
    {
      '1': 'style',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Text.Style',
      '10': 'style'
    },
    {
      '1': 'marks',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Text.Marks',
      '10': 'marks'
    },
    {
      '1': 'checked',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Text.Checked',
      '10': 'checked'
    },
    {
      '1': 'color',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Text.Color',
      '10': 'color'
    },
    {
      '1': 'iconEmoji',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Text.IconEmoji',
      '10': 'iconEmoji'
    },
    {
      '1': 'iconImage',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Text.IconImage',
      '10': 'iconImage'
    },
  ],
  '3': [
    Event_Block_Set_Text_TextValue$json,
    Event_Block_Set_Text_Style$json,
    Event_Block_Set_Text_Marks$json,
    Event_Block_Set_Text_Checked$json,
    Event_Block_Set_Text_Color$json,
    Event_Block_Set_Text_IconEmoji$json,
    Event_Block_Set_Text_IconImage$json
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Text_TextValue$json = {
  '1': 'TextValue',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Text_Style$json = {
  '1': 'Style',
  '2': [
    {
      '1': 'value',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Text.Style',
      '10': 'value'
    },
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Text_Marks$json = {
  '1': 'Marks',
  '2': [
    {
      '1': 'value',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.anytype.model.Block.Content.Text.Marks',
      '10': 'value'
    },
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Text_Checked$json = {
  '1': 'Checked',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 8, '10': 'value'},
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Text_Color$json = {
  '1': 'Color',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Text_IconEmoji$json = {
  '1': 'IconEmoji',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Text_IconImage$json = {
  '1': 'IconImage',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Latex$json = {
  '1': 'Latex',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'text',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Latex.TextValue',
      '10': 'text'
    },
    {
      '1': 'processor',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Latex.Processor',
      '10': 'processor'
    },
  ],
  '3': [
    Event_Block_Set_Latex_TextValue$json,
    Event_Block_Set_Latex_Processor$json
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Latex_TextValue$json = {
  '1': 'TextValue',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Latex_Processor$json = {
  '1': 'Processor',
  '2': [
    {
      '1': 'value',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Latex.Processor',
      '10': 'value'
    },
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Div$json = {
  '1': 'Div',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'style',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Div.Style',
      '10': 'style'
    },
  ],
  '3': [Event_Block_Set_Div_Style$json],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Div_Style$json = {
  '1': 'Style',
  '2': [
    {
      '1': 'value',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Div.Style',
      '10': 'value'
    },
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_TableRow$json = {
  '1': 'TableRow',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'isHeader',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.TableRow.IsHeader',
      '10': 'isHeader'
    },
  ],
  '3': [Event_Block_Set_TableRow_IsHeader$json],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_TableRow_IsHeader$json = {
  '1': 'IsHeader',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 8, '10': 'value'},
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Widget$json = {
  '1': 'Widget',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'layout',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Widget.Layout',
      '10': 'layout'
    },
    {
      '1': 'limit',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Widget.Limit',
      '10': 'limit'
    },
    {
      '1': 'viewId',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.anytype.Event.Block.Set.Widget.ViewId',
      '10': 'viewId'
    },
  ],
  '3': [
    Event_Block_Set_Widget_Layout$json,
    Event_Block_Set_Widget_Limit$json,
    Event_Block_Set_Widget_ViewId$json
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Widget_Layout$json = {
  '1': 'Layout',
  '2': [
    {
      '1': 'value',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.anytype.model.Block.Content.Widget.Layout',
      '10': 'value'
    },
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Widget_Limit$json = {
  '1': 'Limit',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 5, '10': 'value'},
  ],
};

@$core.Deprecated('Use eventDescriptor instead')
const Event_Block_Set_Widget_ViewId$json = {
  '1': 'ViewId',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `Event`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List eventDescriptor = $convert.base64Decode(
    'CgVFdmVudBqcBwoHTWVzc2FnZRIZCgdzcGFjZUlkGIQBIAEoCVIHc3BhY2VJZBJJCg5ibG9ja1'
    'NldEZpZWxkcxgGIAEoCzIfLmFueXR5cGUuRXZlbnQuQmxvY2suU2V0LkZpZWxkc0gAUg5ibG9j'
    'a1NldEZpZWxkcxJYChNibG9ja1NldENoaWxkcmVuSWRzGAcgASgLMiQuYW55dHlwZS5FdmVudC'
    '5CbG9jay5TZXQuQ2hpbGRyZW5JZHNIAFITYmxvY2tTZXRDaGlsZHJlbklkcxJkChdibG9ja1Nl'
    'dEJhY2tncm91bmRDb2xvchgJIAEoCzIoLmFueXR5cGUuRXZlbnQuQmxvY2suU2V0LkJhY2tncm'
    '91bmRDb2xvckgAUhdibG9ja1NldEJhY2tncm91bmRDb2xvchJDCgxibG9ja1NldFRleHQYCiAB'
    'KAsyHS5hbnl0eXBlLkV2ZW50LkJsb2NrLlNldC5UZXh0SABSDGJsb2NrU2V0VGV4dBJGCg1ibG'
    '9ja1NldEFsaWduGA8gASgLMh4uYW55dHlwZS5FdmVudC5CbG9jay5TZXQuQWxpZ25IAFINYmxv'
    'Y2tTZXRBbGlnbhJACgtibG9ja1NldERpdhgRIAEoCzIcLmFueXR5cGUuRXZlbnQuQmxvY2suU2'
    'V0LkRpdkgAUgtibG9ja1NldERpdhJPChBibG9ja1NldFJlbGF0aW9uGBUgASgLMiEuYW55dHlw'
    'ZS5FdmVudC5CbG9jay5TZXQuUmVsYXRpb25IAFIQYmxvY2tTZXRSZWxhdGlvbhJGCg1ibG9ja1'
    'NldExhdGV4GBkgASgLMh4uYW55dHlwZS5FdmVudC5CbG9jay5TZXQuTGF0ZXhIAFINYmxvY2tT'
    'ZXRMYXRleBJeChVibG9ja1NldFZlcnRpY2FsQWxpZ24YJCABKAsyJi5hbnl0eXBlLkV2ZW50Lk'
    'Jsb2NrLlNldC5WZXJ0aWNhbEFsaWduSABSFWJsb2NrU2V0VmVydGljYWxBbGlnbhJPChBibG9j'
    'a1NldFRhYmxlUm93GCUgASgLMiEuYW55dHlwZS5FdmVudC5CbG9jay5TZXQuVGFibGVSb3dIAF'
    'IQYmxvY2tTZXRUYWJsZVJvdxJJCg5ibG9ja1NldFdpZGdldBgoIAEoCzIfLmFueXR5cGUuRXZl'
    'bnQuQmxvY2suU2V0LldpZGdldEgAUg5ibG9ja1NldFdpZGdldEIHCgV2YWx1ZRq2EQoFQmxvY2'
    'sarBEKA1NldBpwCghSZWxhdGlvbhIOCgJpZBgBIAEoCVICaWQSNwoDa2V5GAIgASgLMiUuYW55'
    'dHlwZS5FdmVudC5CbG9jay5TZXQuUmVsYXRpb24uS2V5UgNrZXkaGwoDS2V5EhQKBXZhbHVlGA'
    'EgASgJUgV2YWx1ZRpJCgZGaWVsZHMSDgoCaWQYASABKAlSAmlkEi8KBmZpZWxkcxgCIAEoCzIX'
    'Lmdvb2dsZS5wcm90b2J1Zi5TdHJ1Y3RSBmZpZWxkcxo/CgtDaGlsZHJlbklkcxIOCgJpZBgBIA'
    'EoCVICaWQSIAoLY2hpbGRyZW5JZHMYAiADKAlSC2NoaWxkcmVuSWRzGksKD0JhY2tncm91bmRD'
    'b2xvchIOCgJpZBgBIAEoCVICaWQSKAoPYmFja2dyb3VuZENvbG9yGAIgASgJUg9iYWNrZ3JvdW'
    '5kQ29sb3IaSQoFQWxpZ24SDgoCaWQYASABKAlSAmlkEjAKBWFsaWduGAIgASgOMhouYW55dHlw'
    'ZS5tb2RlbC5CbG9jay5BbGlnblIFYWxpZ24aaQoNVmVydGljYWxBbGlnbhIOCgJpZBgBIAEoCV'
    'ICaWQSSAoNdmVydGljYWxBbGlnbhgCIAEoDjIiLmFueXR5cGUubW9kZWwuQmxvY2suVmVydGlj'
    'YWxBbGlnblINdmVydGljYWxBbGlnbhqMBgoEVGV4dBIOCgJpZBgBIAEoCVICaWQSOwoEdGV4dB'
    'gCIAEoCzInLmFueXR5cGUuRXZlbnQuQmxvY2suU2V0LlRleHQuVGV4dFZhbHVlUgR0ZXh0EjkK'
    'BXN0eWxlGAMgASgLMiMuYW55dHlwZS5FdmVudC5CbG9jay5TZXQuVGV4dC5TdHlsZVIFc3R5bG'
    'USOQoFbWFya3MYBCABKAsyIy5hbnl0eXBlLkV2ZW50LkJsb2NrLlNldC5UZXh0Lk1hcmtzUgVt'
    'YXJrcxI/CgdjaGVja2VkGAUgASgLMiUuYW55dHlwZS5FdmVudC5CbG9jay5TZXQuVGV4dC5DaG'
    'Vja2VkUgdjaGVja2VkEjkKBWNvbG9yGAYgASgLMiMuYW55dHlwZS5FdmVudC5CbG9jay5TZXQu'
    'VGV4dC5Db2xvclIFY29sb3ISRQoJaWNvbkVtb2ppGAcgASgLMicuYW55dHlwZS5FdmVudC5CbG'
    '9jay5TZXQuVGV4dC5JY29uRW1vamlSCWljb25FbW9qaRJFCglpY29uSW1hZ2UYCCABKAsyJy5h'
    'bnl0eXBlLkV2ZW50LkJsb2NrLlNldC5UZXh0Lkljb25JbWFnZVIJaWNvbkltYWdlGiEKCVRleH'
    'RWYWx1ZRIUCgV2YWx1ZRgBIAEoCVIFdmFsdWUaRgoFU3R5bGUSPQoFdmFsdWUYASABKA4yJy5h'
    'bnl0eXBlLm1vZGVsLkJsb2NrLkNvbnRlbnQuVGV4dC5TdHlsZVIFdmFsdWUaRgoFTWFya3MSPQ'
    'oFdmFsdWUYASABKAsyJy5hbnl0eXBlLm1vZGVsLkJsb2NrLkNvbnRlbnQuVGV4dC5NYXJrc1IF'
    'dmFsdWUaHwoHQ2hlY2tlZBIUCgV2YWx1ZRgBIAEoCFIFdmFsdWUaHQoFQ29sb3ISFAoFdmFsdW'
    'UYASABKAlSBXZhbHVlGiEKCUljb25FbW9qaRIUCgV2YWx1ZRgBIAEoCVIFdmFsdWUaIQoJSWNv'
    'bkltYWdlEhQKBXZhbHVlGAEgASgJUgV2YWx1ZRqRAgoFTGF0ZXgSDgoCaWQYASABKAlSAmlkEj'
    'wKBHRleHQYAiABKAsyKC5hbnl0eXBlLkV2ZW50LkJsb2NrLlNldC5MYXRleC5UZXh0VmFsdWVS'
    'BHRleHQSRgoJcHJvY2Vzc29yGAMgASgLMiguYW55dHlwZS5FdmVudC5CbG9jay5TZXQuTGF0ZX'
    'guUHJvY2Vzc29yUglwcm9jZXNzb3IaIQoJVGV4dFZhbHVlEhQKBXZhbHVlGAEgASgJUgV2YWx1'
    'ZRpPCglQcm9jZXNzb3ISQgoFdmFsdWUYASABKA4yLC5hbnl0eXBlLm1vZGVsLkJsb2NrLkNvbn'
    'RlbnQuTGF0ZXguUHJvY2Vzc29yUgV2YWx1ZRqWAQoDRGl2Eg4KAmlkGAEgASgJUgJpZBI4CgVz'
    'dHlsZRgCIAEoCzIiLmFueXR5cGUuRXZlbnQuQmxvY2suU2V0LkRpdi5TdHlsZVIFc3R5bGUaRQ'
    'oFU3R5bGUSPAoFdmFsdWUYASABKA4yJi5hbnl0eXBlLm1vZGVsLkJsb2NrLkNvbnRlbnQuRGl2'
    'LlN0eWxlUgV2YWx1ZRqEAQoIVGFibGVSb3cSDgoCaWQYASABKAlSAmlkEkYKCGlzSGVhZGVyGA'
    'IgASgLMiouYW55dHlwZS5FdmVudC5CbG9jay5TZXQuVGFibGVSb3cuSXNIZWFkZXJSCGlzSGVh'
    'ZGVyGiAKCElzSGVhZGVyEhQKBXZhbHVlGAEgASgIUgV2YWx1ZRrgAgoGV2lkZ2V0Eg4KAmlkGA'
    'EgASgJUgJpZBI+CgZsYXlvdXQYAiABKAsyJi5hbnl0eXBlLkV2ZW50LkJsb2NrLlNldC5XaWRn'
    'ZXQuTGF5b3V0UgZsYXlvdXQSOwoFbGltaXQYAyABKAsyJS5hbnl0eXBlLkV2ZW50LkJsb2NrLl'
    'NldC5XaWRnZXQuTGltaXRSBWxpbWl0Ej4KBnZpZXdJZBgEIAEoCzImLmFueXR5cGUuRXZlbnQu'
    'QmxvY2suU2V0LldpZGdldC5WaWV3SWRSBnZpZXdJZBpKCgZMYXlvdXQSQAoFdmFsdWUYASABKA'
    '4yKi5hbnl0eXBlLm1vZGVsLkJsb2NrLkNvbnRlbnQuV2lkZ2V0LkxheW91dFIFdmFsdWUaHQoF'
    'TGltaXQSFAoFdmFsdWUYASABKAVSBXZhbHVlGh4KBlZpZXdJZBIUCgV2YWx1ZRgBIAEoCVIFdm'
    'FsdWU=');
