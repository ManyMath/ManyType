import 'dart:async';

import 'package:flutter/services.dart' show TextInputAction;
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

enum _EditorSaveState { idle, saving, saved, failed }

typedef ObjectBlockTextSaver =
    Future<void> Function(String objectId, String blockId, String value);

final objectBlockTextSaverProvider = Provider<ObjectBlockTextSaver>((ref) {
  return (objectId, blockId, value) async {
    await ref
        .read(objectsControllerProvider)
        .editBlock(objectId, blockId: blockId, setText: value);
  };
});

/// An unframed, document-first editor backed by the local CRDT replay APIs.
class ObjectDetailView extends HookConsumerWidget {
  const ObjectDetailView({
    super.key,
    required this.objectId,
    required this.spaceId,
    this.onBack,
    this.onDeleted,
    this.maximized = false,
    this.onToggleMaximized,
  });

  final String objectId;
  final String spaceId;
  final VoidCallback? onBack;
  final VoidCallback? onDeleted;
  final bool maximized;
  final VoidCallback? onToggleMaximized;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocks = ref.watch(objectBlocksProvider(objectId));
    final metas = ref.watch(objectsProvider(spaceId)).valueOrNull;
    final saveBlockText = ref.watch(objectBlockTextSaverProvider);
    final saveState = useState(_EditorSaveState.idle);
    final saveError = useState<String?>(null);
    final pendingSaveCount = useRef(0);
    final latestSaveRequest = useRef(0);
    final meta = (metas ?? const <ObjectMeta>[])
        .where((candidate) => candidate.id == objectId)
        .firstOrNull;
    final displayName = meta?.displayName ?? 'Untitled';

    Future<void> saveText(ReplayedBlockView block, String value) async {
      final request = ++latestSaveRequest.value;
      pendingSaveCount.value++;
      saveState.value = _EditorSaveState.saving;
      saveError.value = null;
      try {
        await saveBlockText(objectId, block.id, value);
        if (context.mounted && request == latestSaveRequest.value) {
          saveState.value = _EditorSaveState.saved;
        }
      } catch (error) {
        if (context.mounted && request == latestSaveRequest.value) {
          saveState.value = _EditorSaveState.failed;
          saveError.value = '$error';
        }
        rethrow;
      } finally {
        pendingSaveCount.value--;
        if (context.mounted && pendingSaveCount.value > 0) {
          saveState.value = _EditorSaveState.saving;
        }
      }
    }

    Future<void> saveChecked(ReplayedBlockView block, bool value) async {
      final request = ++latestSaveRequest.value;
      pendingSaveCount.value++;
      saveState.value = _EditorSaveState.saving;
      saveError.value = null;
      try {
        await ref
            .read(objectsControllerProvider)
            .editBlock(objectId, blockId: block.id, setChecked: value);
        if (context.mounted && request == latestSaveRequest.value) {
          saveState.value = _EditorSaveState.saved;
        }
      } catch (error) {
        if (context.mounted && request == latestSaveRequest.value) {
          saveState.value = _EditorSaveState.failed;
          saveError.value = '$error';
        }
      } finally {
        pendingSaveCount.value--;
        if (context.mounted && pendingSaveCount.value > 0) {
          saveState.value = _EditorSaveState.saving;
        }
      }
    }

    Future<void> deleteObject() async {
      final deleted = await confirmDeleteObject(
        context,
        ref,
        objectId: objectId,
        spaceId: spaceId,
        displayName: displayName,
      );
      if (deleted) onDeleted?.call();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _EditorToolbar(
          saveState: saveState.value,
          onBack: onBack,
          onDelete: deleteObject,
          maximized: maximized,
          onToggleMaximized: onToggleMaximized,
        ),
        if (saveError.value != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: MAlert(
              variant: MAlertVariant.destructive,
              message: 'Could not save the latest change: ${saveError.value}',
            ),
          ),
        Expanded(
          child: blocks.when(
            loading: () =>
                const Center(child: MLoadingState(message: 'Opening page')),
            error: (error, _) => Center(
              child: MAlert(
                variant: MAlertVariant.destructive,
                message: 'Could not open this object: $error',
                maxWidth: 440,
              ),
            ),
            data: (result) {
              if (result == null) {
                return const Center(
                  child: MEmptyState(
                    title: 'Object not found',
                    description: 'It is no longer in the local workspace.',
                  ),
                );
              }
              final titleBlock = result.blocks
                  .where((block) => block.id == 'title')
                  .firstOrNull;
              final bodyBlocks = result.blocks
                  .where((block) => block.id != 'title')
                  .toList(growable: false);
              final schemaMeta =
                  meta != null && (isTypeObject(meta) || isRelationObject(meta))
                  ? meta
                  : null;

              return ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 56),
                children: <Widget>[
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          if (schemaMeta != null)
                            _SchemaKindLabel(meta: schemaMeta)
                          else
                            const SizedBox(height: 4),
                          if (titleBlock != null)
                            _EditableBlock(
                              key: ValueKey<String>(
                                '$objectId/${titleBlock.id}',
                              ),
                              block: titleBlock,
                              title: true,
                              titleSemanticLabel: schemaMeta == null
                                  ? 'Page title'
                                  : isRelationObject(schemaMeta)
                                  ? 'Relation name'
                                  : 'Type name',
                              onSaveText: saveText,
                              onSaveChecked: saveChecked,
                            )
                          else
                            Text(
                              displayName,
                              style: MTheme.of(
                                context,
                              ).typography.headlineLarge,
                            ),
                          const SizedBox(height: 20),
                          if (schemaMeta != null)
                            _SchemaSummary(meta: schemaMeta)
                          else ...<Widget>[
                            for (
                              var index = 0;
                              index < bodyBlocks.length;
                              index++
                            )
                              Padding(
                                key: ValueKey<String>(
                                  '$objectId/${bodyBlocks[index].id}',
                                ),
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _EditableBlock(
                                  block: bodyBlocks[index],
                                  number: index + 1,
                                  onSaveText: saveText,
                                  onSaveChecked: saveChecked,
                                ),
                              ),
                            _AddBlockComposer(objectId: objectId),
                            const SizedBox(height: 24),
                            _PropertiesSection(
                              objectId: objectId,
                              spaceId: spaceId,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EditorToolbar extends StatelessWidget {
  const _EditorToolbar({
    required this.saveState,
    required this.onBack,
    required this.onDelete,
    required this.maximized,
    required this.onToggleMaximized,
  });

  final _EditorSaveState saveState;
  final VoidCallback? onBack;
  final VoidCallback onDelete;
  final bool maximized;
  final VoidCallback? onToggleMaximized;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: <Widget>[
            if (onBack != null)
              MIconButton(
                icon: MIconData.chevronLeft,
                label: 'Back to library',
                size: MButtonSize.sm,
                onPressed: onBack,
              ),
            const Spacer(),
            _SaveIndicator(state: saveState),
            const SizedBox(width: 8),
            if (onToggleMaximized != null) ...<Widget>[
              MIconButton(
                icon: maximized ? MIconData.restore : MIconData.maximize,
                label: maximized ? 'Restore workspace' : 'Maximize page',
                size: MButtonSize.sm,
                variant: MButtonVariant.ghost,
                tooltipPlacement: MTooltipPlacement.below,
                onPressed: onToggleMaximized,
              ),
              const SizedBox(width: 4),
            ],
            MIconButton(
              icon: MIconData.trash,
              label: 'Delete object',
              size: MButtonSize.sm,
              variant: MButtonVariant.ghost,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveIndicator extends StatelessWidget {
  const _SaveIndicator({required this.state});

  final _EditorSaveState state;

  @override
  Widget build(BuildContext context) {
    if (state == _EditorSaveState.idle) return const SizedBox.shrink();
    final theme = MTheme.of(context);
    final failed = state == _EditorSaveState.failed;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (state == _EditorSaveState.saving)
          const SizedBox.square(
            dimension: 14,
            child: MCircularProgress.indeterminate(),
          )
        else
          MIcon(
            failed ? MIconData.info : MIconData.check,
            size: 14,
            color: failed
                ? theme.colors.destructive
                : theme.colors.mutedForeground,
          ),
        const SizedBox(width: 6),
        Text(
          switch (state) {
            _EditorSaveState.saving => 'Saving',
            _EditorSaveState.saved => 'Saved locally',
            _EditorSaveState.failed => 'Save failed',
            _EditorSaveState.idle => '',
          },
          style: theme.typography.caption.copyWith(
            color: failed
                ? theme.colors.destructive
                : theme.colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

class _SchemaKindLabel extends StatelessWidget {
  const _SchemaKindLabel({required this.meta});

  final ObjectMeta meta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        isRelationObject(meta) ? 'RELATION' : 'TYPE',
        style: MTheme.of(context).typography.caption.copyWith(
          color: MTheme.of(context).colors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SchemaSummary extends StatelessWidget {
  const _SchemaSummary({required this.meta});

  final ObjectMeta meta;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final key = meta.details['uniqueKey'];
    final format = meta.details['relationFormat'];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.muted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MPropertyRow(
              label: 'Kind',
              layout: MPropertyRowLayout.inline,
              value: Text(isRelationObject(meta) ? 'Relation' : 'Type'),
            ),
            if (key != null && key.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              MPropertyRow(
                label: 'Key',
                layout: MPropertyRowLayout.inline,
                valueStyle: theme.typography.code,
                value: Text(key),
              ),
            ],
            if (format != null && format.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              MPropertyRow(
                label: 'Value format',
                layout: MPropertyRowLayout.inline,
                value: Text(_relationFormatLabel(format)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _relationFormatLabel(String raw) {
  final value = double.tryParse(raw)?.toInt();
  if (value == null) return raw;
  final format = RelationFormat.valueOf(value);
  if (format == null) return raw;
  return switch (format) {
    RelationFormat.shorttext => 'Short text',
    RelationFormat.longtext => 'Long text',
    RelationFormat.checkbox => 'Checkbox',
    RelationFormat.status => 'Status',
    RelationFormat.tag => 'Tag',
    RelationFormat.date => 'Date',
    RelationFormat.object => 'Object',
    RelationFormat.number => 'Number',
    RelationFormat.url => 'URL',
    RelationFormat.email => 'Email',
    RelationFormat.phone => 'Phone',
    RelationFormat.file => 'File',
    RelationFormat.emoji => 'Emoji',
    _ => format.name,
  };
}

typedef _SaveText =
    Future<void> Function(ReplayedBlockView block, String value);
typedef _SaveChecked =
    Future<void> Function(ReplayedBlockView block, bool value);

class _EditableBlock extends HookWidget {
  const _EditableBlock({
    super.key,
    required this.block,
    required this.onSaveText,
    required this.onSaveChecked,
    this.title = false,
    this.titleSemanticLabel,
    this.number,
  });

  final ReplayedBlockView block;
  final _SaveText onSaveText;
  final _SaveChecked onSaveChecked;
  final bool title;
  final String? titleSemanticLabel;
  final int? number;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final controller = useMController<String>(block.text);
    final focusNode = useFocusNode();
    final lastSaved = useRef(block.text);
    final lastQueued = useRef(block.text);
    final pendingSaves = useRef(0);
    final saveTail = useRef<Future<void>>(Future<void>.value());
    final checkedController = useMController<bool>(block.checked ?? false);
    final pendingCheckedSaves = useRef(0);

    Future<void> commit([String? submitted]) {
      final value = submitted ?? controller.value;
      if (value == lastQueued.value) return saveTail.value;
      lastQueued.value = value;
      pendingSaves.value++;
      final operation = saveTail.value
          .then((_) async {
            if (value == lastSaved.value) return;
            try {
              await onSaveText(block, value);
              lastSaved.value = value;
            } catch (_) {
              if (lastQueued.value == value) {
                lastQueued.value = lastSaved.value;
              }
            }
          })
          .whenComplete(() => pendingSaves.value--);
      saveTail.value = operation;
      return operation;
    }

    Future<void> toggleChecked(bool value) async {
      pendingCheckedSaves.value++;
      try {
        await onSaveChecked(block, value);
      } finally {
        pendingCheckedSaves.value--;
      }
    }

    final latestCommit = useRef(commit);
    latestCommit.value = commit;

    useEffect(() {
      void saveOnBlur() {
        if (!focusNode.hasFocus) unawaited(latestCommit.value());
      }

      focusNode.addListener(saveOnBlur);
      return () => focusNode.removeListener(saveOnBlur);
    }, <Object?>[focusNode]);

    useEffect(() {
      if (!focusNode.hasFocus &&
          pendingSaves.value == 0 &&
          block.text != lastSaved.value) {
        controller.value = block.text;
        lastSaved.value = block.text;
        lastQueued.value = block.text;
      }
      return null;
    }, <Object?>[block.text]);

    useEffect(() {
      final checked = block.checked ?? false;
      if (pendingCheckedSaves.value == 0 &&
          checkedController.value != checked) {
        checkedController.value = checked;
      }
      return null;
    }, <Object?>[block.id, block.checked]);

    final textStyle = title
        ? theme.typography.headlineLarge.copyWith(fontWeight: FontWeight.w700)
        : switch (block.style) {
            Block_Content_Text_Style.Header1 => theme.typography.headlineLarge,
            Block_Content_Text_Style.Header2 => theme.typography.headlineSmall,
            Block_Content_Text_Style.Header3 => theme.typography.headlineSmall,
            Block_Content_Text_Style.Quote => theme.typography.body.copyWith(
              fontStyle: FontStyle.italic,
            ),
            _ => theme.typography.body,
          };
    final field = MTextField(
      key: ValueKey<String>(block.id),
      controller: controller,
      focusNode: focusNode,
      placeholder: title ? 'Untitled' : 'Write something...',
      semanticLabel: title ? titleSemanticLabel ?? 'Page title' : 'Block text',
      minLines: title ? 1 : null,
      maxLines: title ? 2 : null,
      textInputAction: title ? TextInputAction.done : TextInputAction.newline,
      onSubmitted: commit,
      style: MTextFieldStyleDelta(
        minHeight: title ? 62 : 42,
        padding: EdgeInsets.symmetric(
          horizontal: title ? 4 : 8,
          vertical: title ? 8 : 6,
        ),
        backgroundColor: const Color(0x00000000),
        borderColor: const Color(0x00000000),
        focusedBorderColor: theme.colors.primary,
        borderWidth: 1,
        radius: BorderRadius.circular(4),
        textStyle: textStyle,
      ),
    );

    if (title) return field;
    if (block.style == Block_Content_Text_Style.Checkbox) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: MCheckbox(
              controller: checkedController,
              semanticLabel: block.text.isEmpty ? 'Task' : block.text,
              onChanged: (value) => unawaited(toggleChecked(value)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: field),
        ],
      );
    }
    if (block.style == Block_Content_Text_Style.Numbered) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 30,
            child: Padding(
              padding: const EdgeInsets.only(top: 11),
              child: Text(
                '${number ?? 1}.',
                textAlign: TextAlign.right,
                style: theme.typography.bodySmall.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: field),
        ],
      );
    }
    if (block.style == Block_Content_Text_Style.Quote) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: theme.colors.primary, width: 3),
          ),
        ),
        child: Padding(padding: const EdgeInsets.only(left: 10), child: field),
      );
    }
    if (block.style == Block_Content_Text_Style.Callout) {
      return MInsetPanel(padding: const EdgeInsets.all(8), child: field);
    }
    if (block.style == Block_Content_Text_Style.Toggle) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: MIcon(
              MIconData.chevronRight,
              size: 16,
              color: theme.colors.mutedForeground,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(child: field),
        ],
      );
    }
    return field;
  }
}

class _AddBlockComposer extends HookConsumerWidget {
  const _AddBlockComposer({required this.objectId});

  final String objectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = useState(false);
    final controller = useMController<String>('');
    final kind = useState(NewBlockKind.text);
    final busy = useState(false);
    final error = useState<String?>(null);

    Future<void> insert() async {
      final text = controller.value.trim();
      if (text.isEmpty || busy.value) return;
      busy.value = true;
      error.value = null;
      try {
        await ref
            .read(objectsControllerProvider)
            .insertBlock(objectId, text: text, kind: kind.value);
        if (!context.mounted) return;
        controller.value = '';
        expanded.value = false;
      } catch (exception) {
        if (context.mounted) error.value = '$exception';
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    if (!expanded.value) {
      return Align(
        alignment: Alignment.centerLeft,
        child: MButton(
          variant: MButtonVariant.ghost,
          size: MButtonSize.sm,
          onPressed: () => expanded.value = true,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MIcon(MIconData.plus, size: 16),
              SizedBox(width: 6),
              Text('Add block'),
            ],
          ),
        ),
      );
    }

    return MInsetPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MField(
            label: 'Content',
            child: MTextField(
              controller: controller,
              autofocus: true,
              enabled: !busy.value,
              maxLines: 4,
              placeholder: 'New block',
              semanticLabel: 'New block text',
              onSubmitted: (_) => insert(),
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final picker = MSelect<NewBlockKind>(
                items: <MSelectItem<NewBlockKind>>[
                  for (final value in NewBlockKind.values)
                    MSelectItem(value: value, label: value.label),
                ],
                initialValue: NewBlockKind.text,
                onChanged: (value) => kind.value = value ?? NewBlockKind.text,
                semanticLabel: 'Block kind',
                enabled: !busy.value,
              );
              final actions = Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MButton(
                    variant: MButtonVariant.ghost,
                    size: MButtonSize.sm,
                    onPressed: busy.value ? null : () => expanded.value = false,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  MButton(
                    size: MButtonSize.sm,
                    onPressed: busy.value ? null : insert,
                    child: Text(busy.value ? 'Adding...' : 'Add'),
                  ),
                ],
              );
              if (constraints.maxWidth < 440) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    picker,
                    const SizedBox(height: 10),
                    Align(alignment: Alignment.centerRight, child: actions),
                  ],
                );
              }
              return Row(
                children: <Widget>[
                  Expanded(child: picker),
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            },
          ),
          if (error.value != null) ...<Widget>[
            const SizedBox(height: 10),
            MAlert(variant: MAlertVariant.destructive, message: error.value!),
          ],
        ],
      ),
    );
  }
}

class _PropertiesSection extends StatelessWidget {
  const _PropertiesSection({required this.objectId, required this.spaceId});

  final String objectId;
  final String spaceId;

  @override
  Widget build(BuildContext context) {
    return MAccordion(
      semanticLabel: 'Page properties',
      items: <MAccordionItem>[
        MAccordionItem(
          id: 'properties',
          title: const Text('Properties'),
          trailing: const MIcon(MIconData.tag, size: 16),
          content: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: _PropertiesPanel(objectId: objectId, spaceId: spaceId),
          ),
        ),
      ],
    );
  }
}

class _PropertiesPanel extends ConsumerWidget {
  const _PropertiesPanel({required this.objectId, required this.spaceId});

  final String objectId;
  final String spaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relations = ref.watch(objectRelationsProvider(objectId));
    final objectLabels = <String, ObjectMeta>{
      for (final meta
          in ref.watch(objectsProvider(spaceId)).valueOrNull ??
              const <ObjectMeta>[])
        meta.id: meta,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        relations.when(
          loading: () => const MLoadingState(
            message: 'Loading properties',
            alignment: MLoadingStateAlignment.start,
          ),
          error: (error, _) => MAlert(
            variant: MAlertVariant.destructive,
            message: 'Could not load properties: $error',
          ),
          data: (result) {
            final values = result?.relations ?? const <ReplayedRelationView>[];
            if (values.isEmpty) {
              return Text(
                'No properties yet',
                style: MTheme.of(context).typography.bodySmall.copyWith(
                  color: MTheme.of(context).colors.mutedForeground,
                ),
              );
            }
            return Column(
              children: <Widget>[
                for (var index = 0; index < values.length; index++) ...<Widget>[
                  MPropertyRow(
                    label: _humanizeKey(values[index].key),
                    layout: MPropertyRowLayout.inline,
                    value: Text(
                      _formatRelationValue(
                        values[index],
                        objectLabels: objectLabels,
                      ),
                    ),
                  ),
                  if (index != values.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: MDivider(),
                    ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        const MDivider(),
        const SizedBox(height: 16),
        _RelationEditor(objectId: objectId, spaceId: spaceId),
      ],
    );
  }
}

enum _RelationValueKind { text, checkbox, status, tag, date, object }

_RelationValueKind? _kindForFormat(String? relationFormat) {
  final numberValue = double.tryParse(relationFormat ?? '');
  if (numberValue == null) return null;
  return switch (RelationFormat.valueOf(numberValue.toInt())) {
    RelationFormat.checkbox => _RelationValueKind.checkbox,
    RelationFormat.status => _RelationValueKind.status,
    RelationFormat.tag => _RelationValueKind.tag,
    RelationFormat.date => _RelationValueKind.date,
    RelationFormat.object => _RelationValueKind.object,
    _ => _RelationValueKind.text,
  };
}

String _formatRelationValue(
  ReplayedRelationView view, {
  Map<String, ObjectMeta> objectLabels = const <String, ObjectMeta>{},
}) {
  switch (view.format) {
    case RelationFormat.checkbox:
      return view.boolValue == true ? 'Yes' : 'No';
    case RelationFormat.date:
      final seconds = view.dateValue;
      if (seconds == null) return '';
      final date = DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000,
        isUtc: true,
      );
      return '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    case RelationFormat.status:
      return view.statusName ?? 'Unavailable status';
    case RelationFormat.tag:
      return view.tagOptions
          .map((option) => option.name ?? 'Unavailable tag')
          .join(', ');
    case RelationFormat.object:
      final id = view.objectIdValue;
      if (id == null || id.isEmpty) return '';
      return objectLabels[id]?.displayName ?? 'Unavailable object';
    default:
      return view.stringValue ??
          view.stringListValue?.join(', ') ??
          (view.boolValue?.toString() ?? '');
  }
}

String _humanizeKey(String value) {
  final words = value
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match.group(1)} ${match.group(2)}',
      )
      .split(RegExp(r'[-_\s]+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
  if (words.isEmpty) return value;
  final joined = words.join(' ').toLowerCase();
  return '${joined[0].toUpperCase()}${joined.substring(1)}';
}

class _RelationEditor extends HookConsumerWidget {
  const _RelationEditor({required this.objectId, required this.spaceId});

  final String objectId;
  final String spaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyController = useMController<String>('');
    final valueController = useMController<String>('');
    final dateController = useMController<DateTime?>(null);
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
            .where((meta) => meta.id != objectId && isPageObject(meta))
            .toList(growable: false);
    final optionBacked =
        kind == _RelationValueKind.status || kind == _RelationValueKind.tag;

    void pickRelation(ObjectMeta? relation) {
      valueController.value = '';
      dateController.value = null;
      checked.value = false;
      objectIdValue.value = null;
      error.value = null;
      if (relation == null) {
        keyController.value = '';
        kindController.value = _RelationValueKind.text;
        return;
      }
      keyController.value = relation.details['uniqueKey'] ?? '';
      kindController.value =
          _kindForFormat(relation.details['relationFormat']) ??
          _RelationValueKind.text;
    }

    Future<void> submit() async {
      final key = keyController.value.trim();
      if (key.isEmpty || busy.value || optionBacked) return;
      if (kind == _RelationValueKind.date && dateController.value == null) {
        error.value = 'Choose a date.';
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
              dateValue: kind == _RelationValueKind.date
                  ? (dateController.value!.millisecondsSinceEpoch ~/ 1000)
                        .toString()
                  : null,
            );
        if (context.mounted) valueController.value = '';
      } catch (exception) {
        if (context.mounted) error.value = '$exception';
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    Widget valueField() {
      if (kind == _RelationValueKind.checkbox) {
        return Align(
          alignment: Alignment.centerLeft,
          child: MCheckbox(
            initialValue: checked.value,
            onChanged: (value) => checked.value = value,
            semanticLabel: 'Property value',
            enabled: !busy.value,
          ),
        );
      }
      if (kind == _RelationValueKind.object) {
        return MSelect<String?>(
          items: <MSelectItem<String?>>[
            const MSelectItem(value: null, label: 'Choose a page'),
            for (final object in objects)
              MSelectItem(value: object.id, label: object.displayName),
          ],
          initialValue: null,
          onChanged: (value) => objectIdValue.value = value,
          semanticLabel: 'Property object value',
          enabled: !busy.value,
        );
      }
      if (kind == _RelationValueKind.date) {
        return MDateField(
          controller: dateController,
          placeholder: 'YYYY-MM-DD',
          semanticLabel: 'Property date value',
          enabled: !busy.value,
        );
      }
      return MTextField(
        controller: valueController,
        placeholder: 'Value',
        semanticLabel: 'Property value',
        enabled: !busy.value && !optionBacked,
        onSubmitted: (_) => submit(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Add property', style: MTheme.of(context).typography.label),
        const SizedBox(height: 10),
        if (relations.isNotEmpty) ...<Widget>[
          MField(
            label: 'Relation',
            child: MSelect<ObjectMeta?>(
              items: <MSelectItem<ObjectMeta?>>[
                const MSelectItem(value: null, label: 'Custom property'),
                for (final relation in relations)
                  MSelectItem(value: relation, label: relation.displayName),
              ],
              initialValue: null,
              onChanged: pickRelation,
              semanticLabel: 'Relation',
              enabled: !busy.value,
            ),
          ),
          const SizedBox(height: 10),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final keyField = MField(
              label: 'Property',
              child: MTextField(
                controller: keyController,
                placeholder: 'Description',
                semanticLabel: 'Property key',
                enabled: !busy.value,
              ),
            );
            final kindField = MField(
              label: 'Format',
              child: MSelect<_RelationValueKind?>(
                items: const <MSelectItem<_RelationValueKind?>>[
                  MSelectItem(value: _RelationValueKind.text, label: 'Text'),
                  MSelectItem(
                    value: _RelationValueKind.checkbox,
                    label: 'Checkbox',
                  ),
                  MSelectItem(value: _RelationValueKind.date, label: 'Date'),
                  MSelectItem(value: _RelationValueKind.object, label: 'Page'),
                  MSelectItem(
                    value: _RelationValueKind.status,
                    label: 'Status',
                  ),
                  MSelectItem(value: _RelationValueKind.tag, label: 'Tag'),
                ],
                controller: kindController,
                onChanged: (value) =>
                    kindController.value = value ?? _RelationValueKind.text,
                semanticLabel: 'Property format',
                enabled: !busy.value,
              ),
            );
            if (constraints.maxWidth < 520) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  keyField,
                  const SizedBox(height: 10),
                  kindField,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(flex: 3, child: keyField),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: kindField),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        MField(label: 'Value', child: valueField()),
        if (optionBacked) ...<Widget>[
          const SizedBox(height: 10),
          const MAlert(
            variant: MAlertVariant.neutral,
            message:
                'Status and tag properties can be viewed here after their '
                'options sync, but editing those options is not available yet.',
          ),
        ],
        if (error.value != null) ...<Widget>[
          const SizedBox(height: 10),
          MAlert(variant: MAlertVariant.destructive, message: error.value!),
        ],
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: MButton(
            size: MButtonSize.sm,
            onPressed: busy.value || optionBacked ? null : submit,
            child: Text(busy.value ? 'Adding...' : 'Add property'),
          ),
        ),
      ],
    );
  }
}
