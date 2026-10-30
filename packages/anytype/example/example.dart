// Offline tour of the anytype SDK. It creates an account, writes and edits
// objects in the account's local store, reads them back, and restores the
// account from its recovery phrase into a second storage root. It needs no
// network and no native QUIC library. The recovery phrase stays in memory
// and is never printed.
import 'dart:io';

import 'package:anytype/anytype.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  final root = await Directory.systemTemp.createTemp('anytype_example_');
  try {
    ManytypeStorage.directory = p.join(root.path, 'device-a');
    final account = await createAccountCommand(name: 'Example');
    stdout.writeln('Created account ${account.id}');

    final String recoveryPhrase;
    final session = await ManytypeSession.open();
    try {
      recoveryPhrase = session.config.mnemonic;
      stdout.writeln('Personal space ${session.identity.spaceId}');

      await session.objects.create('Weekend plans');
      final task = await session.objects.create('Buy oat milk', checkbox: true);

      final before = await replayObjectBlocks(
        session.db,
        session.config,
        task.objectId,
      );
      final checkbox = before!.blocks.firstWhere((b) => b.checked != null);
      await editOffline(
        task.objectId,
        session.db,
        session.config,
        blockId: checkbox.id,
        setChecked: true,
      );

      stdout.writeln('Objects:');
      for (final object in await session.objects.list()) {
        stdout.writeln('  ${object.name} (${object.id})');
      }
      final after = await replayObjectBlocks(
        session.db,
        session.config,
        task.objectId,
      );
      final checked = after!.blocks.firstWhere((b) => b.id == checkbox.id);
      final changes = await session.db.getChangesForObject(task.objectId);
      stdout.writeln('Task checked: ${checked.checked}; '
          '${changes.length} signed, encrypted changes stored locally');
    } finally {
      await session.close();
    }

    // Restoring on another device derives the same account and space.
    // Objects arrive there only after a sync, so the new store is empty.
    ManytypeStorage.directory = p.join(root.path, 'device-b');
    final restored = await AccountRegistry.createAccount(
      mnemonic: recoveryPhrase,
      displayName: 'Restored',
    );
    stdout.writeln('Restored account ${restored.id} '
        '(matches: ${restored.id == account.id})');
  } finally {
    ManytypeStorage.directory = null;
    await root.delete(recursive: true);
  }
}
