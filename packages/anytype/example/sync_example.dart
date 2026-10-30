// Synchronization round trip between two devices of one account.
//
// Copy this file into your project's bin/ directory, then:
//
//   dart run anytype:build_native
//   dart run bin/sync_example.dart <network.yml>
//
// network.yml lists coordinator, tree, file and consensus nodes in the
// Any-Sync network configuration format described in the package README.
// The ManyType repository's scripts/sdk_loopback.sh runs this example
// against a local manytype_server it starts for the purpose. Device A creates an account and an
// object, registers the account's space and pushes the object, then device B restores the same account from its recovery
// phrase into a separate store and pulls the object back. Storage lives in a
// temporary directory that is removed afterwards. The recovery phrase is
// never printed.
import 'dart:io';

import 'package:anytype/anytype.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> arguments) async {
  if (arguments.length != 1) {
    stderr.writeln('usage: dart run bin/sync_example.dart <network.yml>');
    exitCode = 64;
    return;
  }
  final networkConfigPath = File(arguments.single).absolute.path;
  final root = await Directory.systemTemp.createTemp('anytype_sync_');
  try {
    ManytypeStorage.directory = p.join(root.path, 'device-a');
    await createAccountCommand(name: 'Device A');
    final String recoveryPhrase;
    final String objectId;
    final deviceA = await ManytypeSession.open();
    try {
      recoveryPhrase = deviceA.config.mnemonic;
      final created = await deviceA.objects.create('Synced by the anytype SDK');
      objectId = created.objectId;
      // A new account's space is registered with the network once, before
      // its first sync. Later syncs and restored devices skip this step.
      await seedLiveSpaceForSync(
        deviceA.db,
        deviceA.config,
        networkConfigPath: networkConfigPath,
      );
      await deviceA.sync.run(networkConfigPath: networkConfigPath);
      stdout.writeln('Device A pushed $objectId');
    } finally {
      await deviceA.close();
    }

    ManytypeStorage.directory = p.join(root.path, 'device-b');
    final restored = await AccountRegistry.createAccount(
      mnemonic: recoveryPhrase,
      displayName: 'Device B',
    );
    await AccountRegistry.setCurrentAccountId(restored.id);
    final deviceB = await ManytypeSession.open();
    try {
      await deviceB.sync.run(networkConfigPath: networkConfigPath);
      final objects = await deviceB.objects.list();
      final pulled = objects.where((object) => object.id == objectId);
      if (pulled.isEmpty) {
        stderr.writeln('Device B did not receive $objectId');
        exitCode = 1;
        return;
      }
      stdout.writeln('Device B pulled "${pulled.single.name}" ($objectId)');
    } finally {
      await deviceB.close();
    }
  } finally {
    ManytypeStorage.directory = null;
    await root.delete(recursive: true);
  }
}
