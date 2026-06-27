import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart' show ObjectMeta;
import 'package:manyui/manyui.dart';

import '../state/accounts_providers.dart';
import '../state/objects_providers.dart';
import '../state/session_provider.dart';
import '../theme.dart';
import 'account_page.dart';
import 'object_detail.dart';

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
      header: Row(
        children: <Widget>[
          Text('ManyType', style: theme.typography.title),
          const SizedBox(width: 12),
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
          const Spacer(),
          // TODO(manytype): phase 2 sync status. Sync is native-only today
          // (QUIC FFI, rust build) and not wired into the app yet.
          MBadge(
            variant: MBadgeVariant.outline,
            child: Text(
              'Sync: not configured',
              style: theme.typography.caption.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(width: 8),
          MButton(
            variant: MButtonVariant.ghost,
            onPressed: () {
              final mode = ref.read(themeModeProvider);
              ref.read(themeModeProvider.notifier).state =
                  mode == MThemeMode.dark ? MThemeMode.light : MThemeMode.dark;
            },
            semanticLabel: 'Toggle theme',
            child: MIcon(ref.watch(themeModeProvider) == MThemeMode.dark
                ? MIconData.sun
                : MIconData.moon),
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
  });

  final String spaceId;
  final String? selectedObjectId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MTheme.of(context);
    final objects = ref.watch(objectsProvider(spaceId));

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: <Widget>[
        _SpaceCard(spaceId: spaceId),
        const SizedBox(height: 12),
        _NewObjectCard(spaceId: spaceId, onCreated: onSelect),
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
          data: (metas) => metas.isEmpty
              ? <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No objects yet. Create your first one above.',
                      style: theme.typography.bodySmall.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                ]
              : <Widget>[
                  for (final meta in metas) ...<Widget>[
                    _ObjectTile(
                      meta: meta,
                      selected: meta.id == selectedObjectId,
                      onTap: () => onSelect(meta.id),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
        ),
      ],
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
    final controller = useMemoized(() => MController<String>(''), const []);
    useEffect(() => controller.dispose, const []);
    final kind = useState(NewObjectKind.text);
    final busy = useState(false);
    final error = useState<String?>(null);

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
            .create(text, kind: kind.value);
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

class _ObjectTile extends StatelessWidget {
  const _ObjectTile({
    required this.meta,
    required this.selected,
    required this.onTap,
  });

  final ObjectMeta meta;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final createdDate = meta.details['createdDate'];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: MCard(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      meta.displayName,
                      style: theme.typography.body.copyWith(
                        color: selected ? theme.colors.primary : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (createdDate != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        createdDate,
                        style: theme.typography.caption.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              MBadge(
                variant: MBadgeVariant.secondary,
                child: Text(meta.displayType, style: theme.typography.caption),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
