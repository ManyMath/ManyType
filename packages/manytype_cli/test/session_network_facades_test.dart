@TestOn('browser')
library;

// M016/scope-item-4 follow-up — the facades that ultimately construct
// `NativeBridge()` (spaceDelete, aclLifecycle, consensus, sync,
// probeNetwork, probeFileNode, accountDelete) can't be driven end to end on
// web without a live server, so they were left out of session_test.dart's
// chrome coverage. That's a real platform gap, but it should be a *verified*
// gap, not an assumed one: this proves each facade fails predictably with
// `UnsupportedError` (lib/src/ffi/native_bridge_web.dart) — a clean,
// typed signal for web consumers — rather than crashing some other way.
//
// spacePull's bootstrap/refetch aren't covered here: both build their
// fixture via `dart:io` (temp directories / JSON file state) before ever
// reaching `NativeBridge()`, so they're unusable on web for reasons beyond
// just the network layer — see docs/m016-web-api-surface.md.
import 'package:manytype_cli/manytype_cli.dart';
import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:test/test.dart';

import 'web/web_db_test_helpers.dart';

const _testMnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

const _minimalNetworkConfig = '''
id: test
networkId: test-net
nodes:
  - peerId: peer-coordinator
    addresses:
      - 127.0.0.1:0
    types:
      - coordinator
''';

void main() {
  setUpAll(() async {
    await configureWebTestDatabaseAssets();
  });

  Future<ManytypeSession> openSession() async {
    final identity = await Identity.fromMnemonic(_testMnemonic);
    return ManytypeSession(
      db: ManytypeDatabase.forTesting(await openDatabaseForTesting()),
      config: CliConfig(mnemonic: _testMnemonic, serverAddress: '127.0.0.1:0'),
      identity: identity,
    );
  }

  group('network/FFI-dependent session facades fail predictably on web', () {
    test('session.probeNetwork.probe', () async {
      final session = await openSession();
      addTearDown(session.close);

      await expectLater(
        session.probeNetwork.probe(networkConfigContent: _minimalNetworkConfig),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('session.probeFileNode.probe', () async {
      final session = await openSession();
      addTearDown(session.close);

      await expectLater(
        session.probeFileNode.probe(networkConfigContent: _minimalNetworkConfig),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('session.accountDelete.run', () async {
      final session = await openSession();
      addTearDown(session.close);

      await expectLater(
        session.accountDelete.run(networkConfigContent: _minimalNetworkConfig),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('session.spaceDelete.run', () async {
      final session = await openSession();
      addTearDown(session.close);

      await expectLater(
        session.spaceDelete.run(networkConfigContent: _minimalNetworkConfig),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('session.aclLifecycle.run', () async {
      final session = await openSession();
      addTearDown(session.close);

      await expectLater(
        session.aclLifecycle.run(networkConfigContent: _minimalNetworkConfig),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('session.consensus.bootstrap', () async {
      final session = await openSession();
      addTearDown(session.close);

      await expectLater(
        session.consensus.bootstrap(serverAddress: '127.0.0.1:0'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('session.sync.run', () async {
      final session = await openSession();
      addTearDown(session.close);

      await expectLater(
        session.sync.run(networkConfigContent: _minimalNetworkConfig),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
