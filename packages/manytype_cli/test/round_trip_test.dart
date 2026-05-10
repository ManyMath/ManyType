@TestOn(
    'vm') // shells out via Process.run to the bin/manytype.dart CLI binary against a live server
@Tags(['round_trip'])
library;

// Integration test for the full create -> sync -> read round-trip.
//
// Run with: dart test packages/manytype_cli/test/round_trip_test.dart
// Requires:
//   1. Rust server running: cd rust && cargo run -p manytype_server -- test_config.toml
//   2. FFI library built: cargo build -p manytype_quic_ffi --release
//   3. LD_LIBRARY_PATH includes rust/target/release/

import 'dart:io';
import 'package:test/test.dart';

import 'support/repo_root.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('manytype_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('create -> sync -> read round-trip', () async {
    final repoRoot = findRepoRoot();
    final env = {
      ...Platform.environment,
      'HOME': tempDir.path,
      'LD_LIBRARY_PATH':
          '${Platform.environment['LD_LIBRARY_PATH'] ?? ''}:$repoRoot/rust/target/release',
    };

    // Step 1: Initialize config
    final initResult = await Process.run(
      'dart',
      ['run', 'packages/manytype_cli/bin/manytype.dart', 'init'],
      environment: env,
      workingDirectory: repoRoot,
    );
    expect(initResult.exitCode, equals(0),
        reason: 'init failed: ${initResult.stderr}');
    expect(initResult.stdout.toString(), contains('Initialized'));

    // Step 2: Create a text object
    final createResult = await Process.run(
      'dart',
      [
        'run',
        'packages/manytype_cli/bin/manytype.dart',
        'create',
        'Hello round-trip world',
      ],
      environment: env,
      workingDirectory: repoRoot,
    );
    expect(createResult.exitCode, equals(0),
        reason: 'create failed: ${createResult.stderr}');
    expect(createResult.stdout.toString(), contains('Created object'));

    // Extract object ID from create output
    final createOutput = createResult.stdout.toString();
    final objectIdMatch =
        RegExp(r'Created object: (.+)').firstMatch(createOutput);
    expect(objectIdMatch, isNotNull,
        reason: 'Could not find object ID in output: $createOutput');

    // Step 3: Read locally (should show the object before sync)
    final readLocalResult = await Process.run(
      'dart',
      ['run', 'packages/manytype_cli/bin/manytype.dart', 'read'],
      environment: env,
      workingDirectory: repoRoot,
    );
    expect(readLocalResult.exitCode, equals(0),
        reason: 'read failed: ${readLocalResult.stderr}');

    // Step 4: Sync to server (requires server running)
    // This exercises: object push via HeadSync + ObjectSyncStream,
    // AND store-sync via StoreDiff + StoreElements (ffi_sync_store).
    final syncResult = await Process.run(
      'dart',
      ['run', 'packages/manytype_cli/bin/manytype.dart', 'sync'],
      environment: env,
      workingDirectory: repoRoot,
    );
    expect(syncResult.exitCode, equals(0),
        reason: 'sync failed: ${syncResult.stderr}');
    final syncOutput = syncResult.stdout.toString();
    expect(syncOutput, contains('Sync complete'));
    // Verify store-sync was exercised (output includes store value counts)
    expect(syncOutput, contains('store values'),
        reason: 'sync output should report store values: $syncOutput');

    // Step 5: Read after sync (text should still be present)
    final readAfterResult = await Process.run(
      'dart',
      ['run', 'packages/manytype_cli/bin/manytype.dart', 'read'],
      environment: env,
      workingDirectory: repoRoot,
    );
    expect(readAfterResult.exitCode, equals(0),
        reason: 'read after sync failed: ${readAfterResult.stderr}');
    expect(
        readAfterResult.stdout.toString(), contains('Hello round-trip world'));

    // Step 6: Re-sync to verify store-sync round-trip (server should have
    // our store values from step 4; a second sync pulls them back).
    final resyncResult = await Process.run(
      'dart',
      ['run', 'packages/manytype_cli/bin/manytype.dart', 'sync'],
      environment: env,
      workingDirectory: repoRoot,
    );
    expect(resyncResult.exitCode, equals(0),
        reason: 're-sync failed: ${resyncResult.stderr}');
    final resyncOutput = resyncResult.stdout.toString();
    expect(resyncOutput, contains('Sync complete'));
    expect(resyncOutput, contains('store values'),
        reason: 're-sync should report store values: $resyncOutput');
  }, timeout: Timeout(Duration(minutes: 3)));
}
