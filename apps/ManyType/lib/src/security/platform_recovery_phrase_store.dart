import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:manytype_cli/manytype_cli.dart' show RecoveryPhraseStore;

class PlatformRecoveryPhraseStore implements RecoveryPhraseStore {
  PlatformRecoveryPhraseStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static String _key(String accountId) {
    return 'manytype.account.$accountId.recovery-phrase';
  }

  @override
  Future<void> delete(String accountId) {
    return _storage.delete(key: _key(accountId));
  }

  @override
  Future<String?> read(String accountId) {
    return _storage.read(key: _key(accountId));
  }

  @override
  Future<void> write(String accountId, String recoveryPhrase) {
    return _storage.write(key: _key(accountId), value: recoveryPhrase);
  }
}
