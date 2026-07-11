import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart' show ObjectMeta;
import 'package:manyui/manyui.dart';
import 'package:manyui_hooks/manyui_hooks.dart';
import 'package:manyui_riverpod/manyui_riverpod.dart';

import '../state/accounts_providers.dart';
import '../state/guest_demo.dart';
import '../state/objects_providers.dart';
import '../state/session_provider.dart';
import '../state/sync_controller.dart';
import '../theme.dart';
import 'account_page.dart';
import 'new_object_dialog.dart';
import 'object_detail.dart';
import 'sync_dialog.dart';

final objectSearchQueryProvider = StateProvider<String>((ref) => '');
final librarySectionProvider = StateProvider<LibrarySection>(
  (ref) => LibrarySection.pages,
);

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MTheme.of(context);
    final account = ref.watch(currentAccountProvider).valueOrNull;
    final session = ref.watch(sessionProvider);
    final syncState = ref.watch(
      syncControllerProvider(account?.id ?? 'opening-account'),
    );
    final demoState = ref.watch(guestDemoStateProvider);
    final pendingObjectSelection = ref.watch(pendingObjectSelectionProvider);
    final section = ref.watch(librarySectionProvider);
    final selectedObjectId = useState<String?>(null);
    final showAccount = useState(false);
    final navigationCollapsed = useState(false);
    final libraryCollapsed = useState(false);
    final pageMaximized = useState(false);
    final paneSizes = useMController<List<double>>(const <double>[0.36, 0.64]);
    final compactHeader = MediaQuery.sizeOf(context).width < 640;
    final isLegacySharedDemo = isLegacySharedDemoAccountId(account?.id);

    void selectSection(LibrarySection next) {
      ref.read(librarySectionProvider.notifier).state = next;
      showAccount.value = false;
      selectedObjectId.value = null;
      libraryCollapsed.value = false;
      pageMaximized.value = false;
    }

    void selectObjectAfterFocusSettles(String? objectId) {
      if (objectId == null) pageMaximized.value = false;
      FocusManager.instance.primaryFocus?.unfocus();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        FocusManager.instance.primaryFocus?.unfocus();
        // Allow the focus tree to complete a layout without the clicked
        // control before replacing the compact list/detail subtree. Flutter
        // web otherwise may ask focus traversal for a disposed RenderBox.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) selectedObjectId.value = objectId;
        });
      });
    }

    useEffect(() {
      if (pendingObjectSelection == null) return null;
      selectedObjectId.value = pendingObjectSelection;
      showAccount.value = false;
      libraryCollapsed.value = false;
      pageMaximized.value = false;
      Future<void>.microtask(() {
        ref.read(librarySectionProvider.notifier).state = LibrarySection.pages;
        ref.read(pendingObjectSelectionProvider.notifier).state = null;
      });
      return null;
    }, <Object?>[pendingObjectSelection]);

    final maximizeActive =
        pageMaximized.value && selectedObjectId.value != null;

    return MScaffold(
      header: maximizeActive
          ? null
          : MAppHeader(
              title: 'ManyType',
              subtitle: compactHeader ? null : account?.displayName,
              status: isLegacySharedDemo
                  ? const MBadge(
                      variant: MBadgeVariant.destructive,
                      child: Text('Legacy shared demo'),
                    )
                  : compactHeader
                  ? null
                  : _SyncStatusBadge(state: syncState),
              actions: <Widget>[
                if (session.valueOrNull != null &&
                    account != null &&
                    !isLegacySharedDemo)
                  MIconButton(
                    icon: MIconData.refresh,
                    label: 'Configure sync',
                    size: MButtonSize.sm,
                    onPressed: syncState.busy
                        ? null
                        : () => showSyncDialog(
                            context,
                            accountId: account.id,
                            spaceId: session.valueOrNull!.identity.spaceId,
                          ),
                  ),
                if (account != null)
                  MIconButton(
                    icon: MIconData.users,
                    label: 'Open account settings for ${account.displayName}',
                    variant: MButtonVariant.outline,
                    size: MButtonSize.sm,
                    onPressed: () {
                      selectedObjectId.value = null;
                      showAccount.value = true;
                      pageMaximized.value = false;
                    },
                  ),
                MIconButton(
                  icon:
                      ref.watchMThemeMode(themeModeProvider) == MThemeMode.dark
                      ? MIconData.sun
                      : MIconData.moon,
                  label: 'Toggle theme',
                  size: MButtonSize.sm,
                  onPressed: () => ref.toggleMThemeMode(themeModeProvider),
                ),
              ],
            ),
      body: session.when(
        loading: () => const Center(
          child: MLoadingState(message: 'Opening local workspace'),
        ),
        error: (e, _) => Center(
          child: MAlert(
            variant: MAlertVariant.destructive,
            message: 'Could not open local workspace: $e',
            maxWidth: 420,
          ),
        ),
        data: (open) {
          if (open == null) return const SizedBox.shrink();
          final spaceId = open.identity.spaceId;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (demoState.status == GuestDemoStatus.preparing)
                _WorkspaceNotice(
                  message:
                      demoState.message ??
                      'Preparing the editable demo page...',
                  busy: true,
                )
              else if (demoState.status == GuestDemoStatus.failed)
                _WorkspaceNotice(
                  message:
                      demoState.message ??
                      'The demo page could not be prepared.',
                  destructive: true,
                ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 1080;
                    final listPane = _LibraryPane(
                      spaceId: spaceId,
                      section: section,
                      compactNavigation: !wide,
                      selectedObjectId: selectedObjectId.value,
                      onSelect: (id) => selectObjectAfterFocusSettles(id),
                      onSectionChanged: selectSection,
                      onCollapse: wide
                          ? () => libraryCollapsed.value = true
                          : null,
                    );
                    final accountView = AccountView(
                      spaceId: spaceId,
                      isLegacySharedDemo: isLegacySharedDemo,
                      onBack: () => showAccount.value = false,
                    );
                    final detail = showAccount.value
                        ? accountView
                        : selectedObjectId.value == null
                        ? _EmptyDetailHint(section: section)
                        : ObjectDetailView(
                            objectId: selectedObjectId.value!,
                            spaceId: spaceId,
                            maximized: maximizeActive,
                            onToggleMaximized: section == LibrarySection.pages
                                ? () =>
                                      pageMaximized.value = !pageMaximized.value
                                : null,
                            onBack: wide
                                ? null
                                : () => selectObjectAfterFocusSettles(null),
                            onDeleted: () {
                              pageMaximized.value = false;
                              selectObjectAfterFocusSettles(null);
                            },
                          );

                    if (!wide) {
                      if (showAccount.value || selectedObjectId.value != null) {
                        return detail;
                      }
                      return listPane;
                    }

                    if (maximizeActive) {
                      return KeyedSubtree(
                        key: const ValueKey<String>('maximized-page'),
                        child: _DetailSurface(child: detail),
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          key: const ValueKey<String>('workspace-navigation'),
                          width: navigationCollapsed.value ? 60 : 232,
                          child: _WorkspaceSidebar(
                            spaceId: spaceId,
                            accountName: account?.displayName,
                            section: section,
                            syncState: syncState,
                            showAccount: showAccount.value,
                            isLegacySharedDemo: isLegacySharedDemo,
                            collapsed: navigationCollapsed.value,
                            onToggleCollapsed: () => navigationCollapsed.value =
                                !navigationCollapsed.value,
                            onSectionChanged: selectSection,
                            onShowAccount: account == null
                                ? null
                                : () {
                                    selectedObjectId.value = null;
                                    showAccount.value = true;
                                    pageMaximized.value = false;
                                  },
                            onOpenSync: account == null || isLegacySharedDemo
                                ? null
                                : () => showSyncDialog(
                                    context,
                                    accountId: account.id,
                                    spaceId: spaceId,
                                  ),
                          ),
                        ),
                        _PaneDivider(color: theme.colors.border),
                        Expanded(
                          child: libraryCollapsed.value
                              ? Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    _CollapsedLibraryRail(
                                      section: section,
                                      onExpand: () =>
                                          libraryCollapsed.value = false,
                                    ),
                                    _PaneDivider(color: theme.colors.border),
                                    Expanded(
                                      child: KeyedSubtree(
                                        key: const ValueKey<String>(
                                          'editor-detail',
                                        ),
                                        child: _DetailSurface(child: detail),
                                      ),
                                    ),
                                  ],
                                )
                              : KeyedSubtree(
                                  key: const ValueKey<String>(
                                    'library-browser',
                                  ),
                                  child: MResizable(
                                    semanticLabel: 'Library and editor panes',
                                    controller: paneSizes,
                                    children: <MResizableChild>[
                                      MResizableChild(
                                        id: 'library',
                                        minSize: 0.32,
                                        maxSize: 0.48,
                                        child: listPane,
                                      ),
                                      MResizableChild(
                                        id: 'editor',
                                        minSize: 0.5,
                                        child: _DetailSurface(child: detail),
                                      ),
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
        },
      ),
    );
  }
}

class _WorkspaceNotice extends StatelessWidget {
  const _WorkspaceNotice({
    required this.message,
    this.busy = false,
    this.destructive = false,
  });

  final String message;
  final bool busy;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: MAlert(
        variant: destructive
            ? MAlertVariant.destructive
            : MAlertVariant.neutral,
        message: message,
        leading: busy
            ? const SizedBox.square(
                dimension: 16,
                child: MCircularProgress.indeterminate(),
              )
            : null,
      ),
    );
  }
}

class _PaneDivider extends StatelessWidget {
  const _PaneDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(width: 1, color: color);
}

class _CollapsedLibraryRail extends StatelessWidget {
  const _CollapsedLibraryRail({required this.section, required this.onExpand});

  final LibrarySection section;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    return ColoredBox(
      key: const ValueKey<String>('library-browser-collapsed'),
      color: theme.colors.card,
      child: SizedBox(
        width: 48,
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Align(
            alignment: Alignment.topCenter,
            child: Semantics(
              expanded: false,
              child: MIconButton(
                icon: MIconData.chevronRight,
                label: 'Expand ${section.label} browser',
                size: MButtonSize.sm,
                tooltipPlacement: MTooltipPlacement.below,
                onPressed: onExpand,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailSurface extends StatelessWidget {
  const _DetailSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: MTheme.of(context).colors.background,
      child: child,
    );
  }
}

class _WorkspaceSidebar extends ConsumerWidget {
  const _WorkspaceSidebar({
    required this.spaceId,
    required this.accountName,
    required this.section,
    required this.syncState,
    required this.showAccount,
    required this.isLegacySharedDemo,
    required this.collapsed,
    required this.onToggleCollapsed,
    required this.onSectionChanged,
    required this.onShowAccount,
    required this.onOpenSync,
  });

  final String spaceId;
  final String? accountName;
  final LibrarySection section;
  final SyncUiState syncState;
  final bool showAccount;
  final bool isLegacySharedDemo;
  final bool collapsed;
  final VoidCallback onToggleCollapsed;
  final ValueChanged<LibrarySection> onSectionChanged;
  final VoidCallback? onShowAccount;
  final VoidCallback? onOpenSync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MTheme.of(context);
    final objects =
        ref.watch(objectsProvider(spaceId)).valueOrNull ?? const <ObjectMeta>[];
    int count(LibrarySection value) => objectsForSection(objects, value).length;

    if (collapsed) {
      Widget sectionAction(LibrarySection value) {
        final selected = !showAccount && section == value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Semantics(
            selected: selected,
            child: MIconButton(
              icon: _sectionIcon(value),
              label: '${value.label}, ${count(value)} items',
              variant: selected
                  ? MButtonVariant.secondary
                  : MButtonVariant.ghost,
              size: MButtonSize.sm,
              onPressed: () => onSectionChanged(value),
            ),
          ),
        );
      }

      return ColoredBox(
        color: theme.colors.card,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
          child: Column(
            children: <Widget>[
              Semantics(
                expanded: false,
                child: MIconButton(
                  icon: MIconData.chevronRight,
                  label: 'Expand workspace navigation',
                  size: MButtonSize.sm,
                  tooltipPlacement: MTooltipPlacement.below,
                  onPressed: onToggleCollapsed,
                ),
              ),
              const SizedBox(height: 14),
              sectionAction(LibrarySection.pages),
              sectionAction(LibrarySection.types),
              sectionAction(LibrarySection.relations),
              if (onShowAccount != null) ...<Widget>[
                const SizedBox(height: 2),
                Semantics(
                  selected: showAccount,
                  child: MIconButton(
                    icon: MIconData.users,
                    label: 'Account',
                    variant: showAccount
                        ? MButtonVariant.secondary
                        : MButtonVariant.ghost,
                    size: MButtonSize.sm,
                    onPressed: onShowAccount,
                  ),
                ),
              ],
              if (onOpenSync != null) ...<Widget>[
                const SizedBox(height: 8),
                MIconButton(
                  icon: MIconData.refresh,
                  label: 'Sync: ${_syncSummary(syncState.status)}',
                  size: MButtonSize.sm,
                  onPressed: onOpenSync,
                ),
              ],
              const Spacer(),
              MIcon(
                MIconData.lock,
                size: 14,
                color: theme.colors.mutedForeground,
                semanticLabel: 'Local-first workspace',
              ),
            ],
          ),
        ),
      );
    }

    return ColoredBox(
      color: theme.colors.card,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: <Widget>[
                  _SpaceMark(label: accountName ?? 'M'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          accountName ?? 'Local workspace',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.label,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isLegacySharedDemo
                              ? 'Known shared identity'
                              : 'Encrypted document changes',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.caption.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Semantics(
                    expanded: true,
                    child: MIconButton(
                      icon: MIconData.chevronLeft,
                      label: 'Collapse workspace navigation',
                      size: MButtonSize.xs,
                      tooltipPlacement: MTooltipPlacement.below,
                      onPressed: onToggleCollapsed,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SidebarRow(
              icon: MIconData.fileText,
              label: 'Pages',
              count: count(LibrarySection.pages),
              selected: !showAccount && section == LibrarySection.pages,
              onTap: () => onSectionChanged(LibrarySection.pages),
            ),
            _SidebarRow(
              icon: MIconData.shapes,
              label: 'Types',
              count: count(LibrarySection.types),
              selected: !showAccount && section == LibrarySection.types,
              onTap: () => onSectionChanged(LibrarySection.types),
            ),
            _SidebarRow(
              icon: MIconData.link,
              label: 'Relations',
              count: count(LibrarySection.relations),
              selected: !showAccount && section == LibrarySection.relations,
              onTap: () => onSectionChanged(LibrarySection.relations),
            ),
            if (onShowAccount != null)
              _SidebarRow(
                icon: MIconData.users,
                label: 'Account',
                selected: showAccount,
                onTap: onShowAccount!,
              ),
            const SizedBox(height: 14),
            if (isLegacySharedDemo)
              const MAlert(
                variant: MAlertVariant.destructive,
                title: 'Legacy shared demo',
                message:
                    'This old demo identity is public. Switch accounts or '
                    'forget it before storing private information.',
              )
            else if (onOpenSync != null)
              MListTile(
                leading: const MIcon(MIconData.refresh, size: 16),
                title: const Text('Sync'),
                subtitle: Text(_syncSummary(syncState.status)),
                semanticLabel: 'Open sync settings',
                onTap: onOpenSync,
                style: const MListTileStyleDelta(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                ),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: <Widget>[
                  MIcon(
                    MIconData.lock,
                    size: 14,
                    color: theme.colors.mutedForeground,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Local-first workspace',
                      style: theme.typography.caption.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpaceMark extends StatelessWidget {
  const _SpaceMark({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final trimmed = label.trim();
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colors.primary,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        trimmed.isEmpty ? 'M' : trimmed[0].toUpperCase(),
        style: theme.typography.label.copyWith(
          color: theme.colors.primaryForeground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SidebarRow extends StatelessWidget {
  const _SidebarRow({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final MIconData icon;
  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: MListTile(
        leading: MIcon(icon, size: 16),
        title: Text(label),
        trailing: count == null
            ? null
            : Text(
                '$count',
                style: theme.typography.caption.copyWith(
                  color: theme.colors.mutedForeground,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
        selected: selected,
        semanticLabel: '$label${count == null ? '' : ', $count'}',
        onTap: onTap,
        style: const MListTileStyleDelta(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
      ),
    );
  }
}

class _LibraryPane extends ConsumerWidget {
  const _LibraryPane({
    required this.spaceId,
    required this.section,
    required this.compactNavigation,
    required this.selectedObjectId,
    required this.onSelect,
    required this.onSectionChanged,
    this.onCollapse,
  });

  final String spaceId;
  final LibrarySection section;
  final bool compactNavigation;
  final String? selectedObjectId;
  final ValueChanged<String> onSelect;
  final ValueChanged<LibrarySection> onSectionChanged;
  final VoidCallback? onCollapse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MTheme.of(context);
    final objects = ref.watch(objectsProvider(spaceId));
    final query = ref.watch(objectSearchQueryProvider);

    Future<void> create() async {
      final objectId = await showNewObjectDialog(
        context,
        spaceId: spaceId,
        section: section,
      );
      if (objectId != null) onSelect(objectId);
    }

    return ColoredBox(
      color: theme.colors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (compactNavigation) ...<Widget>[
              MSegmentedControl<LibrarySection>(
                fullWidth: true,
                value: section,
                items: <MSegmentedItem<LibrarySection>>[
                  for (final value in LibrarySection.values)
                    MSegmentedItem(value: value, label: value.label),
                ],
                onChanged: onSectionChanged,
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    section.label,
                    style: theme.typography.headlineSmall,
                  ),
                ),
                if (onCollapse != null) ...<Widget>[
                  Semantics(
                    expanded: true,
                    child: MIconButton(
                      icon: MIconData.chevronLeft,
                      label: 'Collapse ${section.label} browser',
                      size: MButtonSize.sm,
                      tooltipPlacement: MTooltipPlacement.below,
                      onPressed: onCollapse,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                MButton(
                  size: MButtonSize.sm,
                  onPressed: create,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const MIcon(MIconData.plus, size: 15),
                      const SizedBox(width: 6),
                      Text('New ${section.singularLabel}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SearchField(query: query, section: section),
            const SizedBox(height: 12),
            Expanded(
              child: objects.when(
                loading: () => const MLoadingState(
                  message: 'Loading workspace',
                  alignment: MLoadingStateAlignment.start,
                ),
                error: (e, _) => MAlert(
                  variant: MAlertVariant.destructive,
                  message: 'Could not list objects: $e',
                ),
                data: (allObjects) {
                  final sectionObjects = objectsForSection(allObjects, section);
                  final filtered = filterObjectsForSearch(
                    sectionObjects,
                    query,
                  );
                  if (sectionObjects.isEmpty) {
                    return MEmptyState(
                      title: 'No ${section.label.toLowerCase()} yet',
                      description: _emptyDescription(section),
                      alignment: MEmptyStateAlignment.start,
                      leading: MIcon(_sectionIcon(section), size: 22),
                      actions: <Widget>[
                        MButton(
                          size: MButtonSize.sm,
                          onPressed: create,
                          child: Text('Create ${section.singularLabel}'),
                        ),
                      ],
                    );
                  }
                  if (filtered.isEmpty) {
                    return MEmptyState(
                      title: 'No matches',
                      description:
                          'Nothing in ${section.label.toLowerCase()} '
                          'matches "$query".',
                      alignment: MEmptyStateAlignment.start,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final meta = filtered[index];
                      return _ObjectTile(
                        meta: meta,
                        selected: meta.id == selectedObjectId,
                        onTap: () => onSelect(meta.id),
                      );
                    },
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

String _emptyDescription(LibrarySection section) => switch (section) {
  LibrarySection.pages => 'Create a page to start writing.',
  LibrarySection.types => 'Define a type to organize related pages.',
  LibrarySection.relations => 'Define a property for structured page data.',
};

MIconData _sectionIcon(LibrarySection section) => switch (section) {
  LibrarySection.pages => MIconData.fileText,
  LibrarySection.types => MIconData.shapes,
  LibrarySection.relations => MIconData.link,
};

class _SearchField extends HookConsumerWidget {
  const _SearchField({required this.query, required this.section});

  final String query;
  final LibrarySection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useMController<String>(query);
    return MTextField(
      controller: controller,
      leading: const MIcon(MIconData.search, size: 16),
      placeholder: 'Search ${section.label.toLowerCase()}',
      semanticLabel: 'Search ${section.label.toLowerCase()}',
      onChanged: (value) =>
          ref.read(objectSearchQueryProvider.notifier).state = value,
    );
  }
}

@visibleForTesting
List<ObjectMeta> filterObjectsForSearch(List<ObjectMeta> metas, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return metas;
  return metas
      .where((meta) {
        if (meta.displayName.toLowerCase().contains(q) ||
            friendlyObjectType(meta).toLowerCase().contains(q)) {
          return true;
        }
        for (final type in meta.types) {
          if (type.toLowerCase().contains(q)) return true;
        }
        for (final value in meta.details.values) {
          if (value.toLowerCase().contains(q)) return true;
        }
        return false;
      })
      .toList(growable: false);
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
    final uniqueKey = meta.details['uniqueKey'];
    final subtitle = <String>[
      friendlyObjectType(meta),
      if (uniqueKey != null && uniqueKey.isNotEmpty) uniqueKey,
    ].join(' - ');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? theme.colors.accent : theme.colors.card,
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(theme.radius),
      ),
      child: MListTile(
        leading: _ObjectGlyph(meta: meta, selected: selected),
        title: Text(
          meta.displayName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: MIcon(
          MIconData.chevronRight,
          size: 15,
          color: theme.colors.mutedForeground,
        ),
        selected: selected,
        onTap: onTap,
        semanticLabel: 'Open ${friendlyObjectType(meta)} ${meta.displayName}',
      ),
    );
  }
}

class _ObjectGlyph extends StatelessWidget {
  const _ObjectGlyph({required this.meta, required this.selected});

  final ObjectMeta meta;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = MTheme.of(context);
    final icon = isTypeObject(meta)
        ? MIconData.shapes
        : isRelationObject(meta)
        ? MIconData.link
        : MIconData.fileText;
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? theme.colors.primary : theme.colors.secondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: MIcon(
        icon,
        size: 16,
        color: selected
            ? theme.colors.primaryForeground
            : theme.colors.secondaryForeground,
      ),
    );
  }
}

class _EmptyDetailHint extends StatelessWidget {
  const _EmptyDetailHint({required this.section});

  final LibrarySection section;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MEmptyState(
        leading: MIcon(_sectionIcon(section), size: 26),
        title: 'Select a ${section.singularLabel}',
        description: switch (section) {
          LibrarySection.pages => 'Choose a page to read or edit it.',
          LibrarySection.types => 'Choose a type to inspect its definition.',
          LibrarySection.relations =>
            'Choose a relation to inspect its value format.',
        },
      ),
    );
  }
}

class _SyncStatusBadge extends StatelessWidget {
  const _SyncStatusBadge({required this.state});

  final SyncUiState state;

  @override
  Widget build(BuildContext context) {
    final variant = switch (state.status) {
      SyncUiStatus.failed => MBadgeVariant.destructive,
      SyncUiStatus.probeSucceeded ||
      SyncUiStatus.syncSucceeded => MBadgeVariant.primary,
      SyncUiStatus.ready ||
      SyncUiStatus.localChangesPending ||
      SyncUiStatus.probing ||
      SyncUiStatus.syncing => MBadgeVariant.secondary,
      SyncUiStatus.unsupported ||
      SyncUiStatus.unconfigured => MBadgeVariant.outline,
    };
    final label = switch (state.status) {
      SyncUiStatus.unsupported => 'Sync: native only',
      SyncUiStatus.unconfigured => 'Sync: configure',
      SyncUiStatus.ready => 'Sync: configured',
      SyncUiStatus.probing => 'Probing...',
      SyncUiStatus.syncing => 'Syncing...',
      SyncUiStatus.probeSucceeded => 'Network OK',
      SyncUiStatus.syncSucceeded => 'Synced',
      SyncUiStatus.localChangesPending => 'Changes pending',
      SyncUiStatus.failed => 'Sync error',
    };
    return MBadge(variant: variant, child: Text(label));
  }
}

String _syncSummary(SyncUiStatus status) => switch (status) {
  SyncUiStatus.unsupported => 'Unavailable in browser',
  SyncUiStatus.unconfigured => 'Not configured',
  SyncUiStatus.ready => 'Configured',
  SyncUiStatus.probing => 'Checking connection',
  SyncUiStatus.syncing => 'Sync in progress',
  SyncUiStatus.probeSucceeded => 'Connection healthy',
  SyncUiStatus.syncSucceeded => 'Up to date',
  SyncUiStatus.localChangesPending => 'Waiting to sync',
  SyncUiStatus.failed => 'Needs attention',
};
