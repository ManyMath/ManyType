// Two-device synchronization round trip through the bundled bridge, run on
// a device or simulator against an Any-Sync network the host provides:
//
//   flutter test integration_test/loopback_test.dart -d <device> \
//     --dart-define=ANYTYPE_NETWORK_YML_B64=<base64 network.yml>
//
// Skipped when no network is given. The recovery phrase is never printed.
import 'dart:convert';
import 'dart:io';

import 'package:anytype_flutter/anytype_flutter.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;

const _networkBase64 = String.fromEnvironment('ANYTYPE_NETWORK_YML_B64');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'device B pulls what device A pushed',
    (tester) async {
      final network = utf8.decode(base64.decode(_networkBase64));
      final root = await Directory.systemTemp.createTemp('anytype_loopback_');
      addTearDown(() async {
        ManytypeStorage.directory = null;
        await root.delete(recursive: true);
      });
      expect(
        AnytypeFlutter.ensureInitialized(),
        NativeBridge.expectedAbiVersion,
      );

      ManytypeStorage.directory = p.join(root.path, 'device-a');
      await createAccountCommand(name: 'Device A');
      final deviceA = await ManytypeSession.open();
      final String recoveryPhrase;
      final String objectId;
      try {
        recoveryPhrase = deviceA.config.mnemonic;
        objectId = (await deviceA.objects.create(
          'Synced from a device',
        )).objectId;
        await seedLiveSpaceForSync(
          deviceA.db,
          deviceA.config,
          networkConfigContent: network,
        );
        await deviceA.sync.run(networkConfigContent: network);
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
        await deviceB.sync.run(networkConfigContent: network);
        final objects = await deviceB.objects.list();
        expect(objects.map((object) => object.id), contains(objectId));
        debugPrint('LOOPBACK device B pulled $objectId');
      } finally {
        await deviceB.close();
      }
    },
    skip: _networkBase64.isEmpty,
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
