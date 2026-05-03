@TestOn('browser')
library;

// M016/scope-item-4 follow-up: none of these facades (spaceDelete,
// aclLifecycle, consensus, spacePull, sync, probeNetwork, probeFileNode,
// accountDelete) can be driven end to end on web without a live server, so
// they were left out of session_test.dart's chrome coverage. That's a real
// platform gap, but it should be a *verified* gap, not an assumed one: this
// proves each facade still fails predictably with `UnsupportedError` on
// web: either from `NativeBridge()` directly
// (lib/src/ffi/native_bridge_web.dart) or, for spacePull/consensus.continueFlow,
// from the `dart:io` (temp directories / JSON state files) they touch before
// ever reaching `NativeBridge()`: rather than crashing some other, less
// legible way.
import 'package:manytype_cli/manytype_cli.dart';
import 'package:manytype_cli/src/store/database_opener.dart';
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

    test('session.spacePull.bootstrap', () async {
      final session = await openSession();
      addTearDown(session.close);

      await expectLater(
        session.spacePull.bootstrap(
          networkConfigContent: _minimalNetworkConfig,
          serverAddress: '127.0.0.1:0',
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('session.spacePull.refetch', () async {
      final session = await openSession();
      addTearDown(session.close);

      await expectLater(
        session.spacePull.refetch(stateIn: 'unused.json'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('session.consensus.continueFlow', () async {
      final session = await openSession();
      addTearDown(session.close);

      await expectLater(
        session.consensus.continueFlow(stateIn: 'unused.json'),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
