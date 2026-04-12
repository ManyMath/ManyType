@TestOn('vm') // exercises AccountResolver against AccountRegistry's real file I/O via a temp base dir — no browser filesystem equivalent used here
library;

import 'dart:io';

import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/account_resolver.dart';
import 'package:test/test.dart';

void main() {
  const mnemonicA =
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
  const mnemonicB =
      'guilt universe cup credit night tissue pencil window brother ecology marriage over';

  group('AccountResolver.resolveAccountId', () {
    late Directory tempBase;

    setUp(() async {
      tempBase = await Directory.systemTemp.createTemp('manytype_account_resolver_test_');
      AccountRegistry.testBaseDirOverride = tempBase.path;
    });

    tearDown(() async {
      AccountRegistry.testBaseDirOverride = null;
      if (await tempBase.exists()) {
        await tempBase.delete(recursive: true);
      }
    });

    test('throws NoAccountError when zero accounts exist', () {
      expect(
        () => AccountResolver.resolveAccountId(),
        throwsA(isA<NoAccountError>()),
      );
    });

    test('auto-selects the only account when exactly one exists', () async {
      final profile = await AccountRegistry.createAccount(
        mnemonic: mnemonicA,
        displayName: 'work',
      );

      final resolved = await AccountResolver.resolveAccountId();

      expect(resolved, profile.id);
    });

    test('throws AmbiguousAccountError with 2+ accounts and no selection', () async {
      await AccountRegistry.createAccount(mnemonic: mnemonicA, displayName: 'work');
      await AccountRegistry.createAccount(mnemonic: mnemonicB, displayName: 'personal');

      expect(
        () => AccountResolver.resolveAccountId(),
        throwsA(isA<AmbiguousAccountError>()),
      );
    });

    test('persisted current pointer wins over auto-select ambiguity', () async {
      final profileA =
          await AccountRegistry.createAccount(mnemonic: mnemonicA, displayName: 'work');
      await AccountRegistry.createAccount(mnemonic: mnemonicB, displayName: 'personal');
      await AccountRegistry.setCurrentAccountId(profileA.id);

      final resolved = await AccountResolver.resolveAccountId();

      expect(resolved, profileA.id);
    });

    test('envAccountId wins over the persisted current pointer', () async {
      final profileA =
          await AccountRegistry.createAccount(mnemonic: mnemonicA, displayName: 'work');
      final profileB =
          await AccountRegistry.createAccount(mnemonic: mnemonicB, displayName: 'personal');
      await AccountRegistry.setCurrentAccountId(profileA.id);

      final resolved =
          await AccountResolver.resolveAccountId(envAccountId: profileB.id);

      expect(resolved, profileB.id);
    });

    test('explicitAccountId wins over envAccountId and the current pointer', () async {
      final profileA =
          await AccountRegistry.createAccount(mnemonic: mnemonicA, displayName: 'work');
      final profileB =
          await AccountRegistry.createAccount(mnemonic: mnemonicB, displayName: 'personal');
      await AccountRegistry.setCurrentAccountId(profileA.id);

      final resolved = await AccountResolver.resolveAccountId(
        explicitAccountId: profileB.id,
        envAccountId: profileA.id,
      );

      expect(resolved, profileB.id);
    });

    test('resolves by displayName when unambiguous', () async {
      final profileA =
          await AccountRegistry.createAccount(mnemonic: mnemonicA, displayName: 'work');
      await AccountRegistry.createAccount(mnemonic: mnemonicB, displayName: 'personal');

      final resolved =
          await AccountResolver.resolveAccountId(explicitAccountId: 'work');

      expect(resolved, profileA.id);
    });

    test('throws NoAccountError for an unknown id/name', () async {
      await AccountRegistry.createAccount(mnemonic: mnemonicA, displayName: 'work');

      expect(
        () => AccountResolver.resolveAccountId(explicitAccountId: 'nonexistent'),
        throwsA(isA<NoAccountError>()),
      );
    });
  });
}
