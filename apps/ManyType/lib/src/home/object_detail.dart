import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart'
    show NewBlockKind, ObjectMeta, ReplayedBlockView, ReplayedRelationView;
import 'package:manytype_protocol/models.dart'
    show Block_Content_Text_Style, RelationFormat;
import 'package:manyui/manyui.dart';
import 'package:manyui_hooks/manyui_hooks.dart';

import '../state/objects_providers.dart';
import 'delete_object.dart';

/// Detail pane: an editable per-block view built on `replayObjectBlocks`'s
/// structured replay (stable block id/style/text/checked), plus the
/// existing text-report metadata (relations, dataview, etc. that the
/// structured API doesn't cover yet) rendered below it.
class ObjectDetailView extends ConsumerWidget {
  const ObjectDetailView({
    super.key,
    required this.objectId,
    required this.spaceId,
    this.onBack,
    this.onDeleted,
  });

  final String objectId;
  final String spaceId;
  final VoidCallback? onBack;

  /// Called after the object is deleted (confirmed + committed). Callers
  /// typically clear their selection / navigate back in response.
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MTheme.of(context);
    final blocks = ref.watch(objectBlocksProvider(objectId));
    final detail = ref.watch(objectDetailProvider(objectId));
    final metas = ref.watch(objectsProvider(spaceId)).valueOrNull;
    String title = objectId;
    if (metas != null) {
      for (final meta in metas) {
        if (meta.id == objectId) {
          title = meta.displayName;
          break;
        }
      }
    }

    return MCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                if (onBack != null) ...<Widget>[
                  MButton(
                    variant: MButtonVariant.ghost,
                    onPressed: onBack,
                    child: const Text('Back'),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: theme.typography.headlineSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                MButton(
                  variant: MButtonVariant.destructive,
                  size: MButtonSize.sm,
                  onPressed: () async {
                    final deleted = await confirmDeleteObject(
                      context,
                      ref,
                      objectId: objectId,
                      spaceId: spaceId,
                      displayName: title,
                    );
                    if (deleted) {
                      onDeleted?.call();
                    }
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              objectId,
              style: theme.typography.code.copyWith(
                fontSize: 11,
                color: theme.colors.mutedForeground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            const MDivider(),
            const SizedBox(height: 12),
            Expanded(
              child: blocks.when(
                loading: () => const Center(
                  child: MLoadingState(message: 'Loading object'),
                ),
                error: (e, _) => MAlert(
                  variant: MAlertVariant.destructive,
                  message: 'Could not read object: $e',
                ),
                data: (result) {
                  if (result == null) {
                    return const Center(
                      child: MEmptyState(
                        title: 'Object not found',
                        description: 'This object is not in the local store.',
                      ),
                    );
                  }
                  final metadataLines = detail.valueOrNull?.lines ?? const [];
                  return ListView(
                    children: <Widget>[
                      for (final block in result.blocks)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _BlockEditor(objectId: objectId, block: block),
                        ),
                      _AddBlockCard(objectId: objectId),
                      const SizedBox(height: 8),
                      const MDivider(),
                      const SizedBox(height: 8),
                      _CurrentRelationsList(
                        objectId: objectId,
                        spaceId: spaceId,
                      ),
                      const SizedBox(height: 8),
                      _RelationEditorCard(objectId: objectId, spaceId: spaceId),
                      if (metadataLines.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 8),
                        const MDivider(),
                        const SizedBox(height: 8),
                        ..._renderMetadataLines(theme, metadataLines),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One editable block: a plain-text/quote/toggle-etc. `MTextField` bound to
/// `editBlock`'s set-text path, or an `MCheckbox` bound to its
/// set-checked path. Commits on submit/blur, not per-keystroke, so typing
/// doesn't spam one CRDT change per character.
class _BlockEditor extends HookConsumerWidget {
  const _BlockEditor({required this.objectId, required this.block});

  final String objectId;
  final ReplayedBlockView block;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (block.style == Block_Content_Text_Style.Checkbox) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MCheckbox(
            initialValue: block.checked ?? false,
            onChanged: (value) {
              ref
                  .read(objectsControllerProvider)
                  .editBlock(objectId, blockId: block.id, setChecked: value);
            },
            semanticLabel: block.text,
          ),
          const SizedBox(width: 8),
          Expanded(child: _textField(ref)),
        ],
      );
    }

    if (block.style == Block_Content_Text_Style.Toggle) {
      final expanded = useState(false);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MTreeListTile(
            title: Text(block.text.isEmpty ? '(empty toggle)' : block.text),
            depth: 0,
            expanded: expanded.value,
            semanticLabel: block.text,
            onToggle: () => expanded.value = !expanded.value,
          ),
          if (expanded.value)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 4),
              child: _textField(ref),
            ),
        ],
      );
    }

    return _textField(ref);
  }

  Widget _textField(WidgetRef ref) {
    return MTextField(
      key: ValueKey(block.id),
      initialValue: block.text,
      onSubmitted: (value) {
        if (value == block.text) return;
        ref
            .read(objectsControllerProvider)
            .editBlock(objectId, blockId: block.id, setText: value);
      },
    );
  }
}

/// Phase-2 follow-on to `_BlockEditor`: a block-type picker plus text field
/// to append a new typed block to the object via `insertBlock`, mirroring
/// `home_page.dart`'s `_NewObjectCard` shape (text field + `MSelect` kind
/// picker + submit button) but scoped to inserting into an existing object
/// rather than creating a new one.
class _AddBlockCard extends HookConsumerWidget {
  const _AddBlockCard({required this.objectId});

  final String objectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useMController<String>('');
    final kind = useState(NewBlockKind.text);
    final busy = useState(false);
    final error = useState<String?>(null);

    Future<void> insert() async {
      final text = controller.value.trim();
      if (text.isEmpty || busy.value) {
        return;
      }
      busy.value = true;
      error.value = null;
      try {
        await ref
            .read(objectsControllerProvider)
            .insertBlock(objectId, text: text, kind: kind.value);
        controller.value = '';
      } catch (e) {
        error.value = '$e';
      } finally {
        busy.value = false;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MTextField(
            controller: controller,
            placeholder: 'Add a block...',
            semanticLabel: 'New block text',
            enabled: !busy.value,
            onSubmitted: (_) => insert(),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: MSelect<NewBlockKind>(
                  items: <MSelectItem<NewBlockKind>>[
                    for (final k in NewBlockKind.values)
                      MSelectItem(value: k, label: k.label),
                  ],
                  initialValue: NewBlockKind.text,
                  onChanged: (value) => kind.value = value ?? NewBlockKind.text,
                  semanticLabel: 'Block kind',
                  enabled: !busy.value,
                ),
              ),
              const SizedBox(width: 8),
              MButton(
                onPressed: busy.value ? null : insert,
                child: const Text('Add block'),
              ),
            ],
          ),
          if (error.value != null) ...<Widget>[
            const SizedBox(height: 8),
            MAlert(variant: MAlertVariant.destructive, message: error.value!),
          ],
        ],
      ),
    );
  }
}

/// Relation value kinds `_RelationEditorCard` can write, mirroring
/// `editRelationOffline`'s scoped value parameters (everything except
/// file-relation and tag-delta, which need a network upload or an extra
/// replay read respectively and still only go through the online
/// `editCommand`). `status`/`tag`/`date` round out the phase-1 text/
/// checkbox pair now that a relation-format lookup exists (below) to
/// auto-select the right one when a known relation is picked.
enum _RelationValueKind { text, checkbox, status, tag, date, object }

/// Maps a `RelationFormat` enum value (as surfaced in
/// `ObjectMeta.details['relationFormat']`, a stringified double -- see
/// `create.dart`'s `_parseRelationFormat`/`read.dart`'s `_formatName`) to
/// the [_RelationValueKind] widget that best fits it. Formats with no
/// dedicated widget yet (file/number/url/email/phone/emoji) fall back to
/// plain text, matching the scoped values `editRelationOffline` can
/// construct today.
_RelationValueKind? _kindForFormat(String? relationFormat) {
  final numberValue = double.tryParse(relationFormat ?? '');
  if (numberValue == null) {
    return null;
  }
  return switch (RelationFormat.valueOf(numberValue.toInt())) {
    RelationFormat.checkbox => _RelationValueKind.checkbox,
    RelationFormat.status => _RelationValueKind.status,
    RelationFormat.tag => _RelationValueKind.tag,
    RelationFormat.date => _RelationValueKind.date,
    RelationFormat.object => _RelationValueKind.object,
    _ => _RelationValueKind.text,
  };
}

/// Renders [ReplayedRelationView]'s current value in the same one-line
/// shape `_RelationEditorCard`'s Status/Tag widgets accept as input, so a
/// user can see what's set before overwriting it -- the structured
/// counterpart to the text-report's `[key] value` metadata lines above
/// (`objectDetailProvider`), replaced here per relation now that
/// `replayObjectRelations` exists rather than only ever writing blind.
String _formatRelationValue(
  ReplayedRelationView view, {
  Map<String, ObjectMeta> objectLabels = const <String, ObjectMeta>{},
}) {
  switch (view.format) {
    case RelationFormat.checkbox:
      return view.boolValue == true ? 'true' : 'false';
    case RelationFormat.date:
      return view.dateValue?.toString() ?? '';
    case RelationFormat.status:
      final id = view.statusOptionId ?? '';
      final name = view.statusName;
      return name == null
          ? '<unsynced:${id.length <= 8 ? id : id.substring(0, 8)}>'
          : '$name (${view.statusColor ?? 'default'})';
    case RelationFormat.tag:
      return view.tagOptions
          .map(
            (o) =>
                o.name ??
                '<unsynced:${o.optionId.length <= 8 ? o.optionId : o.optionId.substring(0, 8)}>',
          )
          .join(', ');
    case RelationFormat.object:
      final objectId = view.objectIdValue;
      if (objectId == null || objectId.isEmpty) {
        return '';
      }
      final meta = objectLabels[objectId];
      return meta == null ? objectId : '${meta.displayName} ($objectId)';
    default:
      return view.stringValue ??
          view.stringListValue?.join(', ') ??
          (view.boolValue != null ? view.boolValue.toString() : '');
  }
}

/// Structured, editable-before-you-overwrite list of an object's current
/// relation values -- the data-shaped counterpart to
/// `objectDetailProvider`'s pre-rendered `[key] value` metadata lines,
/// rendered above `_RelationEditorCard` so a user can see what's already
/// set before writing a new value via the form below.
class _CurrentRelationsList extends ConsumerWidget {
  const _CurrentRelationsList({required this.objectId, required this.spaceId});

  final String objectId;
  final String spaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MTheme.of(context);
    final relations =
        ref.watch(objectRelationsProvider(objectId)).valueOrNull?.relations ??
        const <ReplayedRelationView>[];
    final objectLabels = <String, ObjectMeta>{
      for (final meta
          in ref.watch(objectsProvider(spaceId)).valueOrNull ??
              const <ObjectMeta>[])
        meta.id: meta,
    };
    if (relations.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Relations', style: theme.typography.label),
        const SizedBox(height: 4),
        for (final view in relations)
          Text(
            '${view.key}: ${_formatRelationValue(view, objectLabels: objectLabels)}',
            style: theme.typography.bodySmall.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
      ],
    );
  }
}

/// A key + typed value form to write one relation `DetailsSet` via
/// `editRelation`, mirroring `_AddBlockCard`'s shape (inputs + kind picker
/// + submit button, busy/error state). The relation key can be picked from
/// `spaceRelationsProvider` (an existing STRelation's `uniqueKey`, which
/// auto-selects the matching value widget via its `relationFormat`) or
/// typed freeform for a relation that doesn't exist as an object yet.
class _RelationEditorCard extends HookConsumerWidget {
  const _RelationEditorCard({required this.objectId, required this.spaceId});

  final String objectId;
  final String spaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MTheme.of(context);
    final keyController = useMController<String>('');
    final valueController = useMController<String>('');
    final kindController = useMController<_RelationValueKind?>(
      _RelationValueKind.text,
    );
    final kind = useValueListenable(kindController) ?? _RelationValueKind.text;
    final checked = useState(false);
    final objectIdValue = useState<String?>(null);
    final busy = useState(false);
    final error = useState<String?>(null);
    final relations =
        ref.watch(spaceRelationsProvider(spaceId)).valueOrNull ??
        const <ObjectMeta>[];
    final objects =
        (ref.watch(objectsProvider(spaceId)).valueOrNull ??
                const <ObjectMeta>[])
            .where((meta) => meta.id != objectId)
            .toList(growable: false);

    void pickRelation(ObjectMeta? relation) {
      if (relation == null) {
        return;
      }
      final uniqueKey = relation.details['uniqueKey'];
      if (uniqueKey != null) {
        keyController.value = uniqueKey;
      }
      final matchedKind = _kindForFormat(relation.details['relationFormat']);
      if (matchedKind != null) {
        kindController.value = matchedKind;
      }
    }

    Future<void> submit() async {
      final key = keyController.value.trim();
      if (key.isEmpty || busy.value) {
        return;
      }
      busy.value = true;
      error.value = null;
      try {
        await ref
            .read(objectsControllerProvider)
            .editRelation(
              objectId,
              relationKey: key,
              stringValue: kind == _RelationValueKind.text
                  ? valueController.value.trim()
                  : null,
              boolValue: kind == _RelationValueKind.checkbox
                  ? checked.value.toString()
                  : null,
              objectIdValue: kind == _RelationValueKind.object
                  ? objectIdValue.value
                  : null,
              stringListValue: kind == _RelationValueKind.tag
                  ? valueController.value
                        .split(',')
                        .map((tag) => tag.trim())
                        .where((tag) => tag.isNotEmpty)
                        .toList()
                  : null,
              dateValue: kind == _RelationValueKind.date
                  ? valueController.value.trim()
                  : null,
              status: kind == _RelationValueKind.status
                  ? valueController.value.trim()
                  : null,
            );
      } catch (e) {
        error.value = '$e';
      } finally {
        busy.value = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Set a relation', style: theme.typography.label),
        const SizedBox(height: 8),
        if (relations.isNotEmpty) ...<Widget>[
          MSelect<ObjectMeta?>(
            items: <MSelectItem<ObjectMeta?>>[
              const MSelectItem(value: null, label: 'Freeform key'),
              for (final relation in relations)
                MSelectItem(value: relation, label: relation.displayName),
            ],
            initialValue: null,
            onChanged: pickRelation,
            semanticLabel: 'Existing relation',
            enabled: !busy.value,
          ),
          const SizedBox(height: 8),
        ],
        MTextField(
          controller: keyController,
          placeholder: 'Relation key (e.g. description)',
          semanticLabel: 'Relation key',
          enabled: !busy.value,
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: MSelect<_RelationValueKind?>(
                items: const <MSelectItem<_RelationValueKind?>>[
                  MSelectItem(value: _RelationValueKind.text, label: 'Text'),
                  MSelectItem(
                    value: _RelationValueKind.checkbox,
                    label: 'Checkbox',
                  ),
                  MSelectItem(
                    value: _RelationValueKind.status,
                    label: 'Status',
                  ),
                  MSelectItem(value: _RelationValueKind.tag, label: 'Tag'),
                  MSelectItem(value: _RelationValueKind.date, label: 'Date'),
                  MSelectItem(
                    value: _RelationValueKind.object,
                    label: 'Object',
                  ),
                ],
                controller: kindController,
                onChanged: (value) =>
                    kindController.value = value ?? _RelationValueKind.text,
                semanticLabel: 'Relation value type',
                enabled: !busy.value,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: kind == _RelationValueKind.checkbox
                  ? MCheckbox(
                      initialValue: checked.value,
                      onChanged: (value) => checked.value = value,
                      semanticLabel: 'Relation value',
                    )
                  : kind == _RelationValueKind.object
                  ? MSelect<String?>(
                      items: <MSelectItem<String?>>[
                        const MSelectItem(value: null, label: 'Select object'),
                        for (final object in objects)
                          MSelectItem(
                            value: object.id,
                            label: object.displayName,
                          ),
                      ],
                      initialValue: null,
                      onChanged: (value) => objectIdValue.value = value,
                      semanticLabel: 'Relation object value',
                      enabled: !busy.value,
                    )
                  : MTextField(
                      controller: valueController,
                      placeholder: switch (kind) {
                        _RelationValueKind.tag => 'Tags, comma-separated',
                        _RelationValueKind.date => 'Unix seconds',
                        _RelationValueKind.status => 'Status',
                        _ => 'Value',
                      },
                      semanticLabel: 'Relation value',
                      enabled: !busy.value,
                      onSubmitted: (_) => submit(),
                    ),
            ),
            const SizedBox(width: 8),
            MButton(
              onPressed: busy.value ? null : submit,
              child: const Text('Set'),
            ),
          ],
        ),
        if (error.value != null) ...<Widget>[
          const SizedBox(height: 8),
          MAlert(variant: MAlertVariant.destructive, message: error.value!),
        ],
      ],
    );
  }
}

/// Per-block text/tagged-block lines that `_BlockEditor` already renders
/// structurally above -- skipped here so nothing shows up twice.
final _perBlockLine = RegExp(
  r'^\[[^\]]+\] (\[[x ]\] )?(\[(Checkbox|Numbered|Toggle|Quote|Callout|'
  r'Paragraph|Header1|Header2|Header3)\] )?.*$|'
  r'^Text \(updated\): ".*"$',
);

/// Everything `readCommand`'s text report emits that the structured block
/// editor above doesn't cover yet: object kind/type/relations/attachments/
/// collection members/dataview summaries. Rendered as muted metadata below
/// the editable blocks.
List<Widget> _renderMetadataLines(MThemeData theme, List<String> lines) {
  final widgets = <Widget>[];
  for (final raw in lines) {
    final line = raw.trim();
    if (_perBlockLine.hasMatch(line)) {
      continue;
    }
    if (line.isEmpty) {
      widgets.add(const SizedBox(height: 8));
      continue;
    }

    widgets.add(
      Text(
        line,
        style: theme.typography.code.copyWith(
          fontSize: 11,
          color: theme.colors.mutedForeground,
        ),
      ),
    );
  }
  return widgets;
}
