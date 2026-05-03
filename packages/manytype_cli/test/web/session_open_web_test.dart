@TestOn('browser')
library;

// M017 follow-up: proves ManytypeSession.openWeb: the bootstrap that ties
// AccountRegistry's localStorage-backed credentials to a real,
// production-path ManytypeDatabase (see app_persistence_test.dart): is
// actually usable end to end, not just individually-tested pieces.
import 'package:manytype_cli/manytype_cli.dart';
import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/sync_service.dart';
import 'package:test/test.dart';

import 'web_db_test_helpers.dart';

const _mnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

void main() {
  setUpAll(configureWebAppDatabaseAssets);

  group('M017 ManytypeSession.openWeb', () {
    setUp(() {
      // Unique key prefix per test avoids cross-test localStorage bleed
      // within the same browser session (dart test -p chrome runs all
      // tests in one page context): same pattern as account_test.dart.
      AccountRegistry.keyPrefix =
          'manytype-m017-openweb-${DateTime.now().microsecondsSinceEpoch}';
    });

    test(
        'opens a session for a registered account and drives create -> edit -> read',
        () async {
      final profile = await AccountRegistry.createAccount(
        mnemonic: _mnemonic,
        displayName: 'work',
      );

      final session = await ManytypeSession.openWeb(accountId: profile.id);
      addTearDown(session.close);

      expect(session.config.mnemonic, _mnemonic);
      expect(session.identity.spaceId, isNotEmpty);

      final created = await session.objects.create('Session object');

      await session.objects.edit(
        created.objectId,
        'Session object (edited)',
        syncService: _NoopSyncService(),
      );

      final read = await session.objects.read(objectId: created.objectId);

      expect(read.detail, isNotNull);
      expect(
        read.detail!.lines
            .any((line) => line.contains('Session object (edited)')),
        isTrue,
      );
    });

    test('throws StateError for an unregistered account id', () async {
      await expectLater(
        ManytypeSession.openWeb(accountId: 'not-a-real-account'),
        throwsStateError,
      );
    });
  }, timeout: const Timeout(Duration(seconds: 90)));
}

class _NoopSyncService extends SyncService {
  @override
  Future<void> sync(
    ManytypeDatabase db,
    CliConfig config, {
    String? networkConfigPath,
    String? networkConfigContent,
  }) async {}
}
