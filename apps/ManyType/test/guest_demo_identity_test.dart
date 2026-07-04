@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
// AccountProfile is not re-exported by the manytype_cli barrel.
// ignore: implementation_imports
import 'package:manytype_cli/src/account_profile.dart' show AccountProfile;

import 'package:manytype/src/state/guest_demo.dart';

const _firstMnemonic =
    'tag volcano eight thank tide danger coast health above argue embrace '
    'heavy';
const _secondMnemonic =
    'legal winner thank year wave sausage worth useful legal winner thank '
    'yellow';
const _legacySharedMnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon abandon about';

void main() {
  test('only the retired public demo identity is treated as shared', () async {
    expect(
      await AccountProfile.deriveAccountId(_legacySharedMnemonic),
      legacySharedDemoAccountId,
    );
    expect(isLegacySharedDemoAccountId(legacySharedDemoAccountId), isTrue);
    expect(isLegacySharedDemoAccountId('fresh-template-account'), isFalse);
    expect(isLegacySharedDemoAccountId(null), isFalse);
  });

  test(
    'different recovery phrases derive different account identities',
    () async {
      final firstId = await AccountProfile.deriveAccountId(_firstMnemonic);
      final secondId = await AccountProfile.deriveAccountId(_secondMnemonic);

      expect(firstId, isNot(secondId));
      expect(isLegacySharedDemoAccountId(firstId), isFalse);
      expect(isLegacySharedDemoAccountId(secondId), isFalse);
    },
  );

  test('every demo launch selects a fresh account before seeding', () async {
    final generated = <String>[
      _legacySharedMnemonic,
      _firstMnemonic,
      _firstMnemonic,
      _secondMnemonic,
    ];
    var generatedIndex = 0;
    var seedCount = 0;
    final existingIds = <String>{};
    final createdMnemonics = <String>[];
    final order = <String>[];
    final progress = <String>[];
    final idsByMnemonic = <String, String>{
      _legacySharedMnemonic: legacySharedDemoAccountId,
      _firstMnemonic: 'first-account',
      _secondMnemonic: 'second-account',
    };

    Future<GuestDemoLaunchResult> launch() => createGuestDemoWorkspace(
      mnemonicGenerator: () => generated[generatedIndex++],
      createAndSelectIfNew: ({required mnemonic, required displayName}) async {
        final id = idsByMnemonic[mnemonic]!;
        if (id == legacySharedDemoAccountId || existingIds.contains(id)) {
          return null;
        }
        expect(displayName, guestDemoDisplayName);
        createdMnemonics.add(mnemonic);
        existingIds.add(id);
        order.add('create:$id');
        return id;
      },
      onProgress: progress.add,
      seedTemplate: () async {
        seedCount += 1;
        order.add('seed:$seedCount');
        return 'template-$seedCount';
      },
    );

    final first = await launch();
    final second = await launch();

    expect(first.accountId, 'first-account');
    expect(first.templateObjectId, 'template-1');
    expect(second.accountId, 'second-account');
    expect(second.templateObjectId, 'template-2');
    expect(isLegacySharedDemoAccountId(first.accountId), isFalse);
    expect(isLegacySharedDemoAccountId(second.accountId), isFalse);
    expect(createdMnemonics, <String>[_firstMnemonic, _secondMnemonic]);
    expect(existingIds, <String>{'first-account', 'second-account'});
    expect(generatedIndex, 4);
    expect(order, <String>[
      'create:first-account',
      'seed:1',
      'create:second-account',
      'seed:2',
    ]);
    expect(progress, <String>[
      guestDemoCreatingAccountMessage,
      guestDemoSeedingTemplateMessage,
      guestDemoCreatingAccountMessage,
      guestDemoSeedingTemplateMessage,
    ]);
  });
}
