import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart'
    show NewBlockKind, ReplayedBlockView;
import 'package:manytype_protocol/models.dart' show Block_Content_Text_Style;
import 'package:manyui/manyui.dart';

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
                loading: () => const Center(child: MProgress.indeterminate()),
                error: (e, _) => Text(
                  'Could not read object: $e',
                  style: theme.typography.bodySmall.copyWith(
                    color: theme.colors.destructive,
                  ),
                ),
                data: (result) {
                  if (result == null) {
                    return Text(
                      'Object not found in the local store.',
                      style: theme.typography.bodySmall.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    );
                  }
                  final metadataLines = detail.valueOrNull?.lines ?? const [];
                  return ListView(
                    children: <Widget>[
                      for (final block in result.blocks)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _BlockEditor(
                            objectId: objectId,
                            block: block,
                          ),
                        ),
                      _AddBlockCard(objectId: objectId),
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
              ref.read(objectsControllerProvider).editBlock(
                    objectId,
                    blockId: block.id,
                    setChecked: value,
                  );
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
    final theme = MTheme.of(context);
    final controller = useMemoized(() => MController<String>(''), const []);
    useEffect(() => controller.dispose, const []);
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
                  onChanged: (value) =>
                      kind.value = value ?? NewBlockKind.text,
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
            Text(
              error.value!,
              style: theme.typography.bodySmall.copyWith(
                color: theme.colors.destructive,
              ),
            ),
          ],
        ],
      ),
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
