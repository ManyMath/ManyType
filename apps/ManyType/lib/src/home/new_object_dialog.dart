import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart' show ObjectMeta;
import 'package:manyui/manyui.dart';
import 'package:manyui_hooks/manyui_hooks.dart';

import '../state/objects_providers.dart';

Future<String?> showNewObjectDialog(
  BuildContext context, {
  required String spaceId,
  required LibrarySection section,
}) {
  return showMDialog<String>(
    context,
    semanticLabel: 'Create ${section.singularLabel}',
    builder: (context) => _NewObjectDialog(spaceId: spaceId, section: section),
  );
}

class _NewObjectDialog extends HookConsumerWidget {
  const _NewObjectDialog({required this.spaceId, required this.section});

  final String spaceId;
  final LibrarySection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useMController<String>('');
    final nameFocus = useFocusNode();
    final assignedType = useState<String?>(null);
    final relationFormat = useState(NewRelationFormat.text);
    final busy = useState(false);
    final error = useState<String?>(null);
    final types =
        ref.watch(spaceTypesProvider(spaceId)).valueOrNull ??
        const <ObjectMeta>[];

    Future<void> create() async {
      final name = nameController.value.trim();
      if (name.isEmpty || busy.value) return;
      busy.value = true;
      error.value = null;
      try {
        final result = await ref
            .read(objectsControllerProvider)
            .create(
              name,
              kind: switch (section) {
                LibrarySection.pages => NewObjectKind.text,
                LibrarySection.types => NewObjectKind.type,
                LibrarySection.relations => NewObjectKind.relation,
              },
              assignedType: section == LibrarySection.pages
                  ? assignedType.value
                  : null,
              relationFormat: section == LibrarySection.relations
                  ? relationFormat.value
                  : null,
            );
        if (result != null && context.mounted) {
          Navigator.of(context).pop(result.objectId);
        }
      } catch (e) {
        if (context.mounted) error.value = '$e';
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    return MDialogContent(
      title: 'New ${section.singularLabel}',
      description: switch (section) {
        LibrarySection.pages => 'Create a page in this local workspace.',
        LibrarySection.types => 'Define a reusable type for pages.',
        LibrarySection.relations => 'Define a property and its value format.',
      },
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MField(
            label: switch (section) {
              LibrarySection.pages => 'Page title',
              LibrarySection.types => 'Type name',
              LibrarySection.relations => 'Property name',
            },
            focusNode: nameFocus,
            enabled: !busy.value,
            child: MTextField(
              controller: nameController,
              focusNode: nameFocus,
              autofocus: true,
              enabled: !busy.value,
              placeholder: switch (section) {
                LibrarySection.pages => 'Untitled page',
                LibrarySection.types => 'Project',
                LibrarySection.relations => 'Status',
              },
              semanticLabel: 'New ${section.singularLabel} name',
              onSubmitted: (_) => create(),
            ),
          ),
          if (section == LibrarySection.pages && types.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            MField(
              label: 'Type',
              description: 'Optional',
              enabled: !busy.value,
              child: MSelect<String?>(
                items: <MSelectItem<String?>>[
                  const MSelectItem(value: null, label: 'No type'),
                  for (final type in types)
                    MSelectItem(value: type.id, label: type.displayName),
                ],
                initialValue: null,
                onChanged: (value) => assignedType.value = value,
                enabled: !busy.value,
                semanticLabel: 'Page type',
              ),
            ),
          ],
          if (section == LibrarySection.relations) ...<Widget>[
            const SizedBox(height: 16),
            MField(
              label: 'Value format',
              enabled: !busy.value,
              child: MSelect<NewRelationFormat>(
                items: <MSelectItem<NewRelationFormat>>[
                  for (final format in NewRelationFormat.values)
                    MSelectItem(value: format, label: format.label),
                ],
                initialValue: NewRelationFormat.text,
                onChanged: (value) =>
                    relationFormat.value = value ?? NewRelationFormat.text,
                enabled: !busy.value,
                semanticLabel: 'Property value format',
              ),
            ),
          ],
          if (error.value != null) ...<Widget>[
            const SizedBox(height: 16),
            MAlert(variant: MAlertVariant.destructive, message: error.value!),
          ],
          if (busy.value) ...<Widget>[
            const SizedBox(height: 16),
            const MProgress.indeterminate(),
          ],
        ],
      ),
      actions: <Widget>[
        MButton(
          variant: MButtonVariant.outline,
          onPressed: busy.value ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        MButton(
          onPressed: busy.value ? null : create,
          child: Text('Create ${section.singularLabel}'),
        ),
      ],
    );
  }
}
