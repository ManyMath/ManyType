@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:manytype_cli/src/account_registry.dart';
import 'package:manytype_cli/src/commands/create.dart';
import 'package:manytype_cli/src/config.dart';
import 'package:manytype_cli/src/ffi/native_bridge.dart';
import 'package:manytype_cli/src/operator_flow_support.dart';
import 'package:manytype_cli/src/store/database.dart';
import 'package:manytype_cli/src/store/database_opener.dart';
import 'package:manytype_cli/src/sync_service.dart';
import 'package:manytype_protocol/coordinator.dart';
import 'package:manytype_protocol/spacesync.dart';
import 'package:test/test.dart';

const _mnemonic =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon about';

void main() {
  late Directory tempDir;
  late ManytypeDatabase db;
  late CliConfig config;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('manytype_pull_failures_');
    AccountRegistry.testBaseDirOverride = tempDir.path;
    CliConfig.testConfigDirOverride = tempDir.path;
    db = ManytypeDatabase.forTesting(await openDatabaseForTesting());
    config = CliConfig(mnemonic: _mnemonic, serverAddress: '127.0.0.1:1');
  });

  tearDown(() async {
    await db.close();
    AccountRegistry.testBaseDirOverride = null;
    CliConfig.testConfigDirOverride = null;
    await tempDir.delete(recursive: true);
  });

  Future<List<String>> syncAgainst(_FakeBridge bridge) async {
    final lines = <String>[];
    await runZoned(
      () => SyncService(bridgeFactory: () => bridge).sync(db, config),
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => lines.add(line),
      ),
    );
    return lines;
  }

  test('warns about objects no sync node could serve', () async {
    final created = await createCommand('hello', db, config);
    final aclRootId = await findAclRootId(db, created.spaceId);

    final lines = await syncAgainst(
      _FakeBridge(remoteObjectIds: ['remote-obj', aclRootId]),
    );

    expect(
      lines,
      contains('WARN: could not pull 1 object(s) from any sync node: '
          'remote-obj'),
    );
    expect(lines.last, startsWith('Sync complete:'));
  });

  test('does not warn when nodes answer, even with nothing', () async {
    await createCommand('hello', db, config);

    final lines = await syncAgainst(
      _FakeBridge(remoteObjectIds: ['remote-obj'], failPulls: false),
    );

    expect(lines.where((line) => line.startsWith('WARN')), isEmpty);
  });
}

class _FakeBridge implements NativeBridge {
  _FakeBridge({required this.remoteObjectIds, this.failPulls = true});

  final List<String> remoteObjectIds;
  final bool failPulls;

  @override
  Uint8List invoke(int handleId, String method, Uint8List payload) {
    final response = switch (method) {
      '/coordinator.Coordinator/NetworkConfiguration' =>
        NetworkConfigurationResponse(),
      '/coordinator.Coordinator/SpaceStatusCheck' => SpaceStatusCheckResponse(),
      '/coordinator.Coordinator/SpaceSign' => SpaceSignResponse(),
      '/spacesync.SpaceSync/HeadSync' => HeadSyncResponse(
          results: [
            HeadSyncResult(
              count: remoteObjectIds.length,
              elements: [
                for (final id in remoteObjectIds)
                  HeadSyncResultElement(id: id, head: 'remote-head'),
              ],
            ),
          ],
        ),
      '/spacesync.SpaceSync/StoreDiff' => StoreDiffResponse(),
      _ => null,
    };
    return Uint8List.fromList(response?.writeToBuffer() ?? const []);
  }

  @override
  Uint8List syncObject(
    int handleId,
    String spaceId,
    String objectId,
    Uint8List payload,
  ) =>
      Uint8List(0);

  @override
  Uint8List requestObject(
    int handleId,
    String spaceId,
    String objectId,
    Uint8List payload,
  ) {
    if (failPulls) throw StateError('tree not found');
    return Uint8List(0);
  }

  @override
  Uint8List syncStore(int handleId, Uint8List messagesData) => Uint8List(0);

  @override
  void freeHandle(int handleId) {}

  // connect() is answered here so this fake does not depend on its exact
  // parameter list.
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      invocation.memberName == #connect ? 1 : super.noSuchMethod(invocation);
}
