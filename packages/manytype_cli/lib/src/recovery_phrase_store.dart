/// Platform secret storage used by native application hosts.
///
/// `manytype_cli` does not depend on Flutter, so a host such as
/// the ManyType app injects a Keychain/credential-store implementation. The
/// command-line binary leaves this unset and retains its existing plaintext
/// `config.toml` compatibility.
abstract interface class RecoveryPhraseStore {
  Future<String?> read(String accountId);

  Future<void> write(String accountId, String recoveryPhrase);

  Future<void> delete(String accountId);
}
