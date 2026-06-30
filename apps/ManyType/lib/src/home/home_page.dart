import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart' show ObjectMeta;
import 'package:manyui/manyui.dart';
import 'package:manyui_hooks/manyui_hooks.dart';
import 'package:manyui_riverpod/manyui_riverpod.dart';

import '../state/accounts_providers.dart';
import '../state/objects_providers.dart';
import '../state/session_provider.dart';
import '../theme.dart';
import 'account_page.dart';
import 'delete_object.dart';
import 'object_detail.dart';

/// Client-side search query over the object list. Filtering happens in Dart
/// against the already-loaded [objectsProvider] results (no library-level
/// search/filter function exists yet -- see ROADMAP.md's ManyType section).
final _objectSearchQueryProvider = StateProvider<String>((ref) => '');

/// Main workspace: personal space card, object list, inline create, and a
/// detail pane (side-by-side when wide, drill-in when narrow).
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MTheme.of(context);
    final account = ref.watch(currentAccountProvider).valueOrNull;
    final session = ref.watch(sessionProvider);
    final selectedObjectId = useState<String?>(null);
    final showAccount = useState(false);

    return MScaffold(
      header: MAppHeader(
        title: 'ManyType',
        // TODO(manytype): phase 2 sync status. Sync is native-only today
        // (QUIC FFI, rust build) and not wired into the app yet.
        status: MBadge(
          variant: MBadgeVariant.outline,
          child: Text(
            'Sync: not configured',
            style: theme.typography.caption.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
        actions: <Widget>[
          if (account != null)
            MButton(
              variant: MButtonVariant.ghost,
              size: MButtonSize.sm,
              onPressed: () => showAccount.value = !showAccount.value,
              child: Text(
                account.displayName,
                style: theme.typography.bodySmall.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          MButton(
            variant: MButtonVariant.ghost,
            onPressed: () => ref.toggleMThemeMode(themeModeProvider),
            semanticLabel: 'Toggle theme',
            child: MIcon(
              ref.watchMThemeMode(themeModeProvider) == MThemeMode.dark
                  ? MIconData.sun
                  : MIconData.moon,
            ),
          ),
        ],
      ),
      body: session.when(
        loading: () => const Center(child: MProgress.indeterminate()),
        error: (e, _) => Center(
          child: Text(
            'Could not open local store: $e',
            style: theme.typography.bodySmall.copyWith(
              color: theme.colors.destructive,
            ),
          ),
        ),
        data: (open) {
          if (open == null) {
            // The root gate swaps to onboarding; transient frame only.
            return const SizedBox.shrink();
          }
          final spaceId = open.identity.spaceId;
          return LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final listPane = _ListPane(
                spaceId: spaceId,
                selectedObjectId: selectedObjectId.value,
                onSelect: (id) => selectedObjectId.value = id,
                onClearSelection: () => selectedObjectId.value = null,
              );
              final accountView = AccountView(
                spaceId: spaceId,
                onBack: () => showAccount.value = false,
              );
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: 380, child: listPane),
                    const SizedBox(width: 16),
                    Expanded(
                      child: showAccount.value
                          ? accountView
                          : selectedObjectId.value == null
                          ? _EmptyDetailHint()
                          : ObjectDetailView(
                              objectId: selectedObjectId.value!,
                              spaceId: spaceId,
                              onDeleted: () => selectedObjectId.value = null,
                            ),
                    ),
                  ],
                );
              }
              if (showAccount.value) {
                return accountView;
              }
              if (selectedObjectId.value != null) {
                return ObjectDetailView(
                  objectId: selectedObjectId.value!,
                  spaceId: spaceId,
                  onBack: () => selectedObjectId.value = null,
                  onDeleted: () => selectedObjectId.value = null,
                );
              }
              return listPane;
            },
          );
        },
      ),
    );
  }
}

class _EmptyDetailHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    return Center(
      child: Text(
        'Select an object to view it.',
        style: theme.typography.bodySmall.copyWith(
          color: theme.colors.mutedForeground,
        ),
      ),
    );
  }
}

class _ListPane extends ConsumerWidget {
  const _ListPane({
    required this.spaceId,
    required this.selectedObjectId,
    required this.onSelect,
    required this.onClearSelection,
  });

  final String spaceId;
  final String? selectedObjectId;
  final ValueChanged<String> onSelect;
  final VoidCallback onClearSelection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MTheme.of(context);
    final objects = ref.watch(objectsProvider(spaceId));
    final query = ref.watch(_objectSearchQueryProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: <Widget>[
        _SpaceCard(spaceId: spaceId),
        const SizedBox(height: 12),
        _NewObjectCard(spaceId: spaceId, onCreated: onSelect),
        const SizedBox(height: 12),
        _SearchField(query: query),
        const SizedBox(height: 12),
        ...objects.when(
          loading: () => const <Widget>[
            Padding(
              padding: EdgeInsets.all(16),
              child: MProgress.indeterminate(),
            ),
          ],
          error: (e, _) => <Widget>[
            Text(
              'Could not list objects: $e',
              style: theme.typography.bodySmall.copyWith(
                color: theme.colors.destructive,
              ),
            ),
          ],
          data: (metas) {
            final filtered = filterObjectsForSearch(metas, query);
            if (metas.isEmpty) {
              return <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No objects yet. Create your first one above.',
                    style: theme.typography.bodySmall.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ),
              ];
            }
            if (filtered.isEmpty) {
              return <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No objects match "$query".',
                    style: theme.typography.bodySmall.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ),
              ];
            }
            return <Widget>[
              for (final meta in filtered) ...<Widget>[
                _ObjectTile(
                  meta: meta,
                  spaceId: spaceId,
                  selected: meta.id == selectedObjectId,
                  onTap: () => onSelect(meta.id),
                  onDeleted: () {
                    if (meta.id == selectedObjectId) {
                      onClearSelection();
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ];
          },
        ),
      ],
    );
  }
}

/// Filters [metas] by [query] (case-insensitive substring match against
/// display name, type, and detail values -- the text content already
/// surfaced by `listCommand`). Empty query returns [metas] unchanged.
@visibleForTesting
List<ObjectMeta> filterObjectsForSearch(List<ObjectMeta> metas, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return metas;
  }
  return metas.where((meta) {
    if (meta.displayName.toLowerCase().contains(q)) {
      return true;
    }
    if (meta.displayType.toLowerCase().contains(q)) {
      return true;
    }
    for (final type in meta.types) {
      if (type.toLowerCase().contains(q)) {
        return true;
      }
    }
    for (final value in meta.details.values) {
      if (value.toLowerCase().contains(q)) {
        return true;
      }
    }
    return false;
  }).toList();
}

class _SearchField extends HookConsumerWidget {
  const _SearchField({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useMController<String>(query);
    return MTextField(
      controller: controller,
      placeholder: 'Search objects...',
      semanticLabel: 'Search objects',
      onChanged: (value) =>
          ref.read(_objectSearchQueryProvider.notifier).state = value,
    );
  }
}

class _SpaceCard extends StatelessWidget {
  const _SpaceCard({required this.spaceId});

  final String spaceId;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    return MCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Personal space', style: theme.typography.label),
            const SizedBox(height: 4),
            Text(
              spaceId,
              style: theme.typography.code.copyWith(
                fontSize: 11,
                color: theme.colors.mutedForeground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _NewObjectCard extends HookConsumerWidget {
  const _NewObjectCard({required this.spaceId, required this.onCreated});

  final String spaceId;
  final ValueChanged<String> onCreated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MTheme.of(context);
    final controller = useMController<String>('');
    final kind = useState(NewObjectKind.text);
    final assignedType = useState<String?>(null);
    final relationFormat = useState(NewRelationFormat.text);
    final busy = useState(false);
    final error = useState<String?>(null);
    final types =
        ref.watch(spaceTypesProvider(spaceId)).valueOrNull ??
        const <ObjectMeta>[];

    Future<void> create() async {
      final text = controller.value.trim();
      if (text.isEmpty || busy.value) {
        return;
      }
      busy.value = true;
      error.value = null;
      try {
        final result = await ref
            .read(objectsControllerProvider)
            .create(
              text,
              kind: kind.value,
              assignedType: assignedType.value,
              relationFormat: relationFormat.value,
            );
        controller.value = '';
        if (result != null) {
          onCreated(result.objectId);
        }
      } catch (e) {
        error.value = '$e';
      } finally {
        busy.value = false;
      }
    }

    return MCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('New object', style: theme.typography.label),
            const SizedBox(height: 8),
            MTextField(
              controller: controller,
              placeholder: 'Write something...',
              semanticLabel: 'New object text',
              enabled: !busy.value,
              onSubmitted: (_) => create(),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: MSelect<NewObjectKind>(
                    items: <MSelectItem<NewObjectKind>>[
                      for (final k in NewObjectKind.values)
                        MSelectItem(value: k, label: k.label),
                    ],
                    initialValue: NewObjectKind.text,
                    onChanged: (value) =>
                        kind.value = value ?? NewObjectKind.text,
                    semanticLabel: 'Object kind',
                    enabled: !busy.value,
                  ),
                ),
                const SizedBox(width: 8),
                MButton(
                  onPressed: busy.value ? null : create,
                  child: const Text('Create'),
                ),
              ],
            ),
            if (types.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              MSelect<String?>(
                items: <MSelectItem<String?>>[
                  const MSelectItem(value: null, label: 'No type'),
                  for (final type in types)
                    MSelectItem(value: type.id, label: type.displayName),
                ],
                initialValue: null,
                onChanged: (value) => assignedType.value = value,
                semanticLabel: 'Object type',
                enabled: !busy.value,
              ),
            ],
            if (kind.value == NewObjectKind.relation) ...<Widget>[
              const SizedBox(height: 8),
              MSelect<NewRelationFormat>(
                items: <MSelectItem<NewRelationFormat>>[
                  for (final format in NewRelationFormat.values)
                    MSelectItem(value: format, label: format.label),
                ],
                initialValue: NewRelationFormat.text,
                onChanged: (value) =>
                    relationFormat.value = value ?? NewRelationFormat.text,
                semanticLabel: 'Relation value format',
                enabled: !busy.value,
              ),
            ],
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
      ),
    );
  }
}

class _ObjectTile extends ConsumerWidget {
  const _ObjectTile({
    required this.meta,
    required this.spaceId,
    required this.selected,
    required this.onTap,
    required this.onDeleted,
  });

  final ObjectMeta meta;
  final String spaceId;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MTheme.of(context);
    final createdDate = meta.details['createdDate'];
    return MCard(
      style: const MCardStyleDelta(padding: EdgeInsets.zero),
      child: MListTile(
        title: Text(
          meta.displayName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.typography.body.copyWith(
            color: selected ? theme.colors.primary : null,
          ),
        ),
        subtitle: createdDate != null
            ? Text(createdDate, style: theme.typography.caption)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MBadge(
              variant: MBadgeVariant.secondary,
              child: Text(meta.displayType, style: theme.typography.caption),
            ),
            const SizedBox(width: 4),
            MButton(
              variant: MButtonVariant.ghost,
              size: MButtonSize.sm,
              semanticLabel: 'Delete ${meta.displayName}',
              onPressed: () async {
                final deleted = await confirmDeleteObject(
                  context,
                  ref,
                  objectId: meta.id,
                  spaceId: spaceId,
                  displayName: meta.displayName,
                );
                if (deleted) {
                  onDeleted();
                }
              },
              child: MIcon(MIconData.close),
            ),
          ],
        ),
        selected: selected,
        onTap: onTap,
        semanticLabel: 'Open object ${meta.displayName}',
      ),
    );
  }
}
