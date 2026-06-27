import 'dart:typed_data';

import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/models.dart';

import 'config.dart';
import 'identity.dart';
import 'store/database.dart';

/// Structural block IDs from `createMinimalPageSnapshotBase` that every page
/// object carries as scaffolding with no text content of its own. `title`
/// is deliberately NOT included here even though `read.dart`'s line-based
/// report skips it too: `title` holds the object's actual display name as
/// an editable text block, and a structured caller (unlike a human skimming
/// the CLI report) wants to bind an editor to it.
const structuralBlockIds = <String>{'header', 'featuredRelations'};

/// One user-visible content block, replayed to its current state.
///
/// Stable across re-reads: [id] is the same CRDT block ID `edit --block-id`
/// targets, so a UI can bind an editable control to a block once and keep
/// using that binding across rebuilds/replays.
class ReplayedBlockView {
  const ReplayedBlockView({
    required this.id,
    required this.style,
    required this.text,
    this.checked,
  });

  final String id;
  final Block_Content_Text_Style style;
  final String text;

  /// Only meaningful when [style] is [Block_Content_Text_Style.Checkbox].
  final bool? checked;
}

/// Structured replay of one object: the object's kind plus its ordered,
/// user-visible text/checkbox/quote/toggle/etc. blocks.
///
/// This is the same replay `readCommand`'s text report is derived from,
/// exposed as data instead of pre-rendered lines so a UI can bind editable
/// controls per block (text field, checkbox, toggle expand/collapse) rather
/// than parsing rendered text back apart.
class ReplayedObjectBlocks {
  const ReplayedObjectBlocks({
    required this.objectId,
    required this.smartBlockType,
    required this.blocks,
  });

  final String objectId;
  final int smartBlockType;
  final List<ReplayedBlockView> blocks;
}

/// Replay [objectId]'s current block state from local changes.
///
/// Returns `null` when the object has no local changes (not found) or its
/// root smart block type can't be parsed. Throws only on unexpected/decrypt
/// errors, matching `readCommand`'s own error surface for this object.
Future<ReplayedObjectBlocks?> replayObjectBlocks(
  ManytypeDatabase db,
  CliConfig config,
  String objectId,
) async {
  final changes = await db.getChangesForObject(objectId);
  if (changes.isEmpty) {
    return null;
  }

  final identity = await Identity.fromMnemonic(config.mnemonic);
  final accountPrivRaw = Uint8List(64)
    ..setRange(0, 32, identity.accountSeed)
    ..setRange(32, 64, identity.accountKeyPair.publicKey);
  final spaceKey = await deriveSpaceKey(accountPrivRaw);
  final treeKey = await deriveTreeKey(spaceKey, objectId);

  final rawTreeChanges =
      changes.map((change) => Uint8List.fromList(change.rawBytes)).toList();
  final replayed = await replayObjectState(
    rawTreeChanges: rawTreeChanges,
    treeKey: treeKey,
  );

  final blocks = <ReplayedBlockView>[
    for (final block in replayed.snapshot.blocks)
      if (!structuralBlockIds.contains(block.id) && block.hasText())
        ReplayedBlockView(
          id: block.id,
          style: block.text.style,
          text: block.text.text,
          checked: block.text.style == Block_Content_Text_Style.Checkbox
              ? block.text.checked
              : null,
        ),
  ];

  return ReplayedObjectBlocks(
    objectId: objectId,
    smartBlockType: replayed.smartBlockType,
    blocks: blocks,
  );
}
