@TestOn('vm') // reads/writes real config.toml files via dart:io Directory/File — no browser filesystem equivalent used here
library;

import 'dart:io';
import 'package:test/test.dart';
import 'package:manytype_cli/src/config.dart';

void main() {
  group('CliConfig', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('manytype_config_test_');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('parses TOML config with mnemonic and server_address', () async {
      final configFile = File('${tempDir.path}/config.toml');
      await configFile.writeAsString(
        'mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"\n'
        'server_address = "10.0.0.1:5000"\n',
      );

      final config = await CliConfig.loadFrom(configFile.path);

      expect(config.mnemonic,
          'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about');
      expect(config.serverAddress, '10.0.0.1:5000');
    });

    test('uses default server_address when not specified', () async {
      final configFile = File('${tempDir.path}/config.toml');
      await configFile.writeAsString(
        'mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"\n',
      );

      final config = await CliConfig.loadFrom(configFile.path);

      expect(config.serverAddress, '127.0.0.1:33020');
    });

    test('server override takes precedence over config file', () async {
      final configFile = File('${tempDir.path}/config.toml');
      await configFile.writeAsString(
        'mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"\n'
        'server_address = "10.0.0.1:5000"\n',
      );

      final config = await CliConfig.loadFrom(
        configFile.path,
        serverOverride: '192.168.1.1:9999',
      );

      expect(config.serverAddress, '192.168.1.1:9999');
    });

    test('throws when mnemonic is missing', () async {
      final configFile = File('${tempDir.path}/config.toml');
      await configFile.writeAsString('server_address = "127.0.0.1:33020"\n');

      expect(
        () => CliConfig.loadFrom(configFile.path),
        throwsA(isA<StateError>()),
      );
    });

    test('throws when config file does not exist', () {
      expect(
        () => CliConfig.loadFrom('${tempDir.path}/nonexistent.toml'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
