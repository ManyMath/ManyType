import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'account_profile.dart';
import 'account_sync_metadata.dart';
import 'config.dart';
import 'private_files.dart';
import 'recovery_phrase_store.dart';

/// Durable boundaries in the native local-account removal transaction.
///
/// [AccountRegistry.testAccountRemovalStageHook] is test-only and runs after
/// each boundary has reached disk.
enum AccountRemovalStage {
  intentPersisted,
  dataStaged,
  registryUpdated,
  currentPointerUpdated,
  securePhraseDeleted,
  stagedDataPurged,
}

/// Test-only crash sentinel. Unlike an ordinary failure, this deliberately
/// leaves the durable removal journal in place so a fresh registry call can
/// prove restart recovery.
final class AccountRemovalInterruption implements Exception {
  const AccountRemovalInterruption(this.stage);

  final AccountRemovalStage stage;

  @override
  String toString() => 'AccountRemovalInterruption($stage)';
}

/// Native (vm) account registry backed by files under `~/.manytype`:
/// - `accounts.json`: index of known account summaries (no secrets)
/// - `current`: plain-text file naming the currently-selected account id
/// - `accounts/<id>/config.toml`: server address and, for CLI-only hosts,
///   the account mnemonic
/// - `accounts/<id>/store.db`: that account's database
class AccountRegistry {
  /// Test-only override for [baseDir]. When null, baseDir resolves to
  /// `$HOME/.manytype` (or `$USERPROFILE` on Windows) as usual.
  static String? testBaseDirOverride;
  static RecoveryPhraseStore? _recoveryPhraseStore;

  /// Test-only fault injection hook invoked after a removal stage is durable.
  static Future<void> Function(AccountRemovalStage stage)?
      testAccountRemovalStageHook;

  /// Test-only fault injection hook invoked after an atomic temporary file is flushed
  /// but before it replaces [path]. Throwing leaves the prior file untouched.
  static Future<void> Function(String path)? testBeforeAtomicReplaceHook;

  static Future<void>? _activeRecovery;
  static final Object _lifecycleZoneKey = Object();
  static Future<void> _lifecycleTail = Future<void>.value();
  static var _queuedLifecycleOperations = 0;

  static Future<T> _serializeLifecycle<T>(
    Future<T> Function() operation,
  ) {
    if (Zone.current[_lifecycleZoneKey] == true) {
      return operation();
    }

    final predecessor = _lifecycleTail;
    final release = Completer<void>();
    _lifecycleTail = release.future;
    _queuedLifecycleOperations++;

    return () async {
      await predecessor;
      RandomAccessFile? lock;
      var lockHeld = false;
      try {
        await createPrivateDirectory(baseDir);
        lock = await File(_lifecycleLockPath).open(mode: FileMode.append);
        await lock.lock(FileLock.exclusive);
        lockHeld = true;
        return await runZoned<Future<T>>(
          operation,
          zoneValues: <Object?, Object?>{_lifecycleZoneKey: true},
        );
      } finally {
        try {
          if (lock != null) {
            try {
              if (lockHeld) await lock.unlock();
            } finally {
              await lock.close();
            }
          }
        } finally {
          _queuedLifecycleOperations--;
          release.complete();
        }
      }
    }();
  }

  /// Clears native lifecycle fault injection hooks between isolated filesystem tests.
  /// Call only after all registry futures from the prior test have completed.
  static void resetLifecycleTestState() {
    if (_activeRecovery != null || _queuedLifecycleOperations != 0) {
      throw StateError('Cannot reset account lifecycle during an operation.');
    }
    _recoveryPhraseStore = null;
    _lifecycleTail = Future<void>.value();
    testAccountRemovalStageHook = null;
    testBeforeAtomicReplaceHook = null;
  }

  /// Supplies the native host's OS-backed secret storage.
  ///
  /// The Flutter app configures this before accessing accounts. A pure Dart
  /// CLI host leaves it null to retain the established plaintext
  /// `config.toml` format and receives an explicit error if it encounters an
  /// app-owned config whose phrase is only available from platform storage.
  static void configureRecoveryPhraseStore(RecoveryPhraseStore? store) {
    _recoveryPhraseStore = store;
  }

  static String get baseDir {
    if (testBaseDirOverride != null) {
      return testBaseDirOverride!;
    }
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    return p.join(home, '.manytype');
  }

  static String get registryPath => p.join(baseDir, 'accounts.json');
  static String get currentPath => p.join(baseDir, 'current');
  static String get accountsDir => p.join(baseDir, 'accounts');
  static String get pendingRemovalsDir =>
      p.join(baseDir, 'pending-account-removals');
  static String get _lifecycleLockPath =>
      p.join(baseDir, '.account-lifecycle.lock');

  static String accountDir(String id) => p.join(accountsDir, id);
  static String accountConfigPath(String id) =>
      p.join(accountDir(id), 'config.toml');
  static String accountDbPath(String id) => p.join(accountDir(id), 'store.db');
  static String accountDownloadsDir(String id) =>
      p.join(accountDir(id), 'downloads');
  static String accountSyncMetadataPath(String id) =>
      p.join(accountDir(id), 'sync.json');

  static String accountRemovalJournalPath(String id) =>
      p.join(pendingRemovalsDir, _removalToken(id), 'intent.json');

  /// List all known account summaries, in the order they were registered.
  /// Any interrupted local forget is recovered before registry state is
  /// returned, so callers never observe a half-applied transaction.
  static Future<List<AccountSummary>> listAccounts() {
    return _serializeLifecycle(() async {
      await _recoverPendingRemovals();
      return _readAccountsRaw();
    });
  }

  static Future<List<AccountSummary>> _readAccountsRaw() async {
    final file = File(registryPath);
    if (!await file.exists()) {
      return [];
    }
    final content = await file.readAsString();
    if (content.trim().isEmpty) {
      return [];
    }
    final decoded = jsonDecode(content) as Map<String, dynamic>;
    final accounts = (decoded['accounts'] as List<dynamic>? ?? [])
        .map((e) => AccountSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    for (final account in accounts) {
      _validateAccountSummary(account);
    }
    return accounts;
  }

  static Future<void> _writeAccounts(List<AccountSummary> accounts) async {
    final encoded = jsonEncode({
      'accounts': accounts.map((a) => a.toJson()).toList(),
    });
    await _writeFileAtomically(registryPath, encoded);
  }

  /// Register (or re-register, idempotently) an account summary in the
  /// shared index. Does not touch the account's own config/db.
  static Future<void> registerAccount(AccountSummary summary) {
    return _serializeLifecycle(() async {
      _validateAccountSummary(summary);
      final accounts = await listAccounts();
      final withoutExisting =
          accounts.where((a) => a.id != summary.id).toList();
      await _writeAccounts([...withoutExisting, summary]);
    });
  }

  /// Durably forget a local account without exposing an active registry entry
  /// whose secure recovery phrase has already been deleted.
  ///
  /// Data is first renamed into a reversible staging area, then the registry
  /// and current pointer are atomically updated. Secure storage deletion is
  /// the commit boundary. Pre-commit failures roll the account back; a crash
  /// at any boundary resumes from the non-secret journal on the next registry
  /// access. This is local profile removal only, never protocol AccountDelete.
  static Future<void> removeAccount(String id) {
    return _serializeLifecycle(() async {
      await _recoverPendingRemovals();
      final accounts = await _readAccountsRaw();
      final index = accounts.indexWhere((account) => account.id == id);
      if (index < 0) return;

      final summary = accounts[index];
      final currentId = await _readCurrentAccountIdRaw();
      final deleteSecurePhrase = await _securePhraseDeletionRequired(summary);
      final record = _AccountRemovalRecord(
        account: summary,
        wasCurrent: currentId == id,
        deleteSecurePhrase: deleteSecurePhrase,
        phase: _AccountRemovalPhase.prepared,
        entries: _removalEntries(summary),
      );
      await _validateNewRemovalPaths(record);
      await _writeRemovalRecord(record);
      await _executeRemoval(
        record,
        invokeTestHooks: true,
        invokeIntentHook: true,
      );
    });
  }

  static Future<bool> _securePhraseDeletionRequired(
    AccountSummary summary,
  ) async {
    if (_recoveryPhraseStore != null) return true;

    final configPath =
        summary.configPathOverride ?? accountConfigPath(summary.id);
    final config = File(configPath);
    if (!await config.exists()) {
      throw StateError(
        'Cannot safely remove account ${summary.id} without its config or '
        'platform secure storage.',
      );
    }
    final values = await readSimpleTomlFile(configPath);
    final plaintextPhrase = values['mnemonic']?.trim();
    final usesPlatformStore =
        values['recovery_phrase_store']?.trim() == 'platform';
    if (usesPlatformStore ||
        plaintextPhrase == null ||
        plaintextPhrase.isEmpty) {
      throw StateError(
        'Account ${summary.id} requires platform secure storage before it '
        'can be removed.',
      );
    }
    return false;
  }

  static Future<void> _recoverPendingRemovals() async {
    final active = _activeRecovery;
    if (active != null) {
      await active;
      return;
    }

    final recovery = _recoverPendingRemovalsInternal();
    _activeRecovery = recovery;
    try {
      await recovery;
    } finally {
      if (identical(_activeRecovery, recovery)) {
        _activeRecovery = null;
      }
    }
  }

  static Future<void> _recoverPendingRemovalsInternal() async {
    final directory = Directory(pendingRemovalsDir);
    if (!await directory.exists()) return;

    await for (final entity in directory.list()) {
      if (entity is! Directory) continue;
      final journal = File(p.join(entity.path, 'intent.json'));
      if (!await journal.exists()) continue;
      final record = await _readRemovalRecord(journal.path);
      await _executeRemoval(record, invokeTestHooks: false);
    }
  }

  static Future<void> _executeRemoval(
    _AccountRemovalRecord initial, {
    required bool invokeTestHooks,
    bool invokeIntentHook = false,
  }) async {
    if (initial.deleteSecurePhrase && _recoveryPhraseStore == null) {
      throw StateError(
        'Account removal requires platform secure storage to recover safely; '
        'the durable journal was left untouched.',
      );
    }
    try {
      if (invokeIntentHook) {
        await _runRemovalHook(AccountRemovalStage.intentPersisted);
      }
      await _continueRemoval(initial, invokeTestHooks: invokeTestHooks);
    } on AccountRemovalInterruption {
      rethrow;
    } catch (error, stackTrace) {
      final latest = await _tryReadRemovalRecord(initial.account.id);
      if (latest == null) {
        Error.throwWithStackTrace(error, stackTrace);
      }

      if (latest.phase == _AccountRemovalPhase.committing) {
        final store = _recoveryPhraseStore;
        if (!latest.deleteSecurePhrase ||
            (store != null && await store.read(latest.account.id) == null)) {
          final committed = latest.copyWith(
            phase: _AccountRemovalPhase.committed,
          );
          await _writeRemovalRecord(committed);
          await _continueRemoval(
            committed,
            invokeTestHooks: invokeTestHooks,
          );
          return;
        }
      }

      if (latest.phase != _AccountRemovalPhase.committed) {
        final rollingBack = latest.copyWith(
          phase: _AccountRemovalPhase.rollingBack,
        );
        await _writeRemovalRecord(rollingBack);
        try {
          await _rollbackRemoval(rollingBack);
        } catch (rollbackError) {
          throw StateError(
            'Account removal failed ($error) and rollback could not finish '
            '($rollbackError). The durable journal will retry recovery.',
          );
        }
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  static Future<void> _continueRemoval(
    _AccountRemovalRecord initial, {
    required bool invokeTestHooks,
  }) async {
    var record = initial;
    if (record.phase == _AccountRemovalPhase.rollingBack) {
      await _rollbackRemoval(record);
      return;
    }

    if (record.phase == _AccountRemovalPhase.prepared) {
      for (final entry in record.entries) {
        await _stageRemovalEntry(entry);
      }
      record = record.copyWith(phase: _AccountRemovalPhase.dataStaged);
      await _writeRemovalRecord(record);
      if (invokeTestHooks) {
        await _runRemovalHook(AccountRemovalStage.dataStaged);
      }
    }

    if (record.phase == _AccountRemovalPhase.dataStaged) {
      final accounts = await _readAccountsRaw();
      if (accounts.any((account) => account.id == record.account.id)) {
        await _writeAccounts(
          accounts.where((account) => account.id != record.account.id).toList(),
        );
      }
      record = record.copyWith(phase: _AccountRemovalPhase.registryUpdated);
      await _writeRemovalRecord(record);
      if (invokeTestHooks) {
        await _runRemovalHook(AccountRemovalStage.registryUpdated);
      }
    }

    if (record.phase == _AccountRemovalPhase.registryUpdated) {
      if (await _readCurrentAccountIdRaw() == record.account.id) {
        await _writeCurrentAccountIdRaw('');
      }
      record = record.copyWith(
        phase: _AccountRemovalPhase.currentPointerUpdated,
      );
      await _writeRemovalRecord(record);
      if (invokeTestHooks) {
        await _runRemovalHook(AccountRemovalStage.currentPointerUpdated);
      }
    }

    if (record.phase == _AccountRemovalPhase.currentPointerUpdated) {
      record = record.copyWith(phase: _AccountRemovalPhase.committing);
      await _writeRemovalRecord(record);
    }

    if (record.phase == _AccountRemovalPhase.committing) {
      if (record.deleteSecurePhrase) {
        await _recoveryPhraseStore!.delete(record.account.id);
      }
      record = record.copyWith(phase: _AccountRemovalPhase.committed);
      await _writeRemovalRecord(record);
      if (invokeTestHooks) {
        await _runRemovalHook(AccountRemovalStage.securePhraseDeleted);
      }
    }

    if (record.phase == _AccountRemovalPhase.committed) {
      for (final entry in record.entries.reversed) {
        await _purgeRemovalEntry(entry);
      }
      if (invokeTestHooks) {
        await _runRemovalHook(AccountRemovalStage.stagedDataPurged);
      }
      await _deleteRemovalJournal(record.account.id);
    }
  }

  static Future<void> _rollbackRemoval(_AccountRemovalRecord record) async {
    for (final entry in record.entries.reversed) {
      await _restoreRemovalEntry(entry);
    }

    final accounts = await _readAccountsRaw();
    if (accounts.every((account) => account.id != record.account.id)) {
      await _writeAccounts(<AccountSummary>[...accounts, record.account]);
    }
    if (record.wasCurrent) {
      final currentId = await _readCurrentAccountIdRaw();
      if (currentId == null || currentId == record.account.id) {
        await _writeCurrentAccountIdRaw(record.account.id);
      }
    }
    await _deleteRemovalJournal(record.account.id);
  }

  static List<_AccountRemovalEntry> _removalEntries(AccountSummary summary) {
    final token = _removalToken(summary.id);
    final recordDirectory = p.dirname(accountRemovalJournalPath(summary.id));
    final entries = <_AccountRemovalEntry>[
      _AccountRemovalEntry(
        kind: _AccountRemovalEntryKind.directory,
        originalPath: accountDir(summary.id),
        stagedPath: p.join(recordDirectory, 'account-data'),
      ),
    ];
    final seen = <String>{accountDir(summary.id)};

    void addFile(String? path) {
      if (path == null || !seen.add(path)) return;
      entries.add(
        _AccountRemovalEntry(
          kind: _AccountRemovalEntryKind.file,
          originalPath: path,
          stagedPath: '$path.manytype-removal-$token',
        ),
      );
    }

    addFile(summary.configPathOverride);
    final dbPath = summary.dbPathOverride;
    addFile(dbPath);
    if (dbPath != null) {
      for (final suffix in const <String>['-wal', '-shm', '-journal']) {
        addFile('$dbPath$suffix');
      }
    }
    return entries;
  }

  static Future<void> _validateNewRemovalPaths(
    _AccountRemovalRecord record,
  ) async {
    _validateRemovalRecordContents(
      record,
      accountRemovalJournalPath(record.account.id),
    );
    final recordDirectory =
        p.dirname(accountRemovalJournalPath(record.account.id));
    if (await FileSystemEntity.type(recordDirectory, followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw StateError(
        'Removal staging already exists for account ${record.account.id}; '
        'refusing to treat it as a new transaction.',
      );
    }
    for (final entry in record.entries) {
      if (await FileSystemEntity.type(entry.stagedPath, followLinks: false) !=
          FileSystemEntityType.notFound) {
        throw StateError(
          'Removal staging already exists at ${entry.stagedPath}; refusing '
          'to overwrite it.',
        );
      }
    }
  }

  static void _validateRemovalRecordContents(
    _AccountRemovalRecord record,
    String journalPath,
  ) {
    _validateAccountSummary(record.account);
    final expectedJournal = accountRemovalJournalPath(record.account.id);
    if (!_samePath(journalPath, expectedJournal)) {
      throw StateError(
        'Account removal journal is outside its deterministic location.',
      );
    }

    final expectedEntries = _removalEntries(record.account);
    if (record.entries.length != expectedEntries.length) {
      throw StateError('Account removal journal has unexpected entries.');
    }
    for (var index = 0; index < expectedEntries.length; index++) {
      final actual = record.entries[index];
      final expected = expectedEntries[index];
      if (actual.kind != expected.kind ||
          !_samePath(actual.originalPath, expected.originalPath) ||
          !_samePath(actual.stagedPath, expected.stagedPath)) {
        throw StateError(
          'Account removal journal contains a non-deterministic path.',
        );
      }
    }
  }

  static void _validateAccountSummary(AccountSummary summary) {
    if (!RegExp(r'^[a-z2-7]{16}$').hasMatch(summary.id)) {
      throw StateError('Invalid account id in native account registry.');
    }
    final hasConfigOverride = summary.configPathOverride != null;
    final hasDbOverride = summary.dbPathOverride != null;
    if (hasConfigOverride != hasDbOverride) {
      throw StateError(
        'Legacy account config and database overrides must be paired.',
      );
    }
    if (hasConfigOverride) {
      _validateLegacyPaths(
        configPath: summary.configPathOverride!,
        dbPath: summary.dbPathOverride!,
      );
    }
  }

  static void _validateLegacyPaths({
    required String configPath,
    required String dbPath,
  }) {
    if (!_samePath(configPath, p.join(baseDir, 'config.toml')) ||
        !_samePath(dbPath, p.join(baseDir, 'store.db'))) {
      throw StateError(
        'Legacy account paths must use the native base directory.',
      );
    }
  }

  static bool _samePath(String left, String right) {
    return p.normalize(p.absolute(left)) == p.normalize(p.absolute(right));
  }

  static Future<void> _stageRemovalEntry(_AccountRemovalEntry entry) async {
    final originalType = await FileSystemEntity.type(
      entry.originalPath,
      followLinks: false,
    );
    final stagedType = await FileSystemEntity.type(
      entry.stagedPath,
      followLinks: false,
    );
    if (stagedType != FileSystemEntityType.notFound) {
      if (originalType != FileSystemEntityType.notFound) {
        throw StateError(
          'Both active and staged account data exist for '
          '${entry.originalPath}; refusing to overwrite either.',
        );
      }
      _requireEntryType(entry, stagedType);
      return;
    }
    if (originalType == FileSystemEntityType.notFound) return;
    _requireEntryType(entry, originalType);
    await createPrivateDirectory(p.dirname(entry.stagedPath));
    switch (entry.kind) {
      case _AccountRemovalEntryKind.file:
        await File(entry.originalPath).rename(entry.stagedPath);
        break;
      case _AccountRemovalEntryKind.directory:
        await Directory(entry.originalPath).rename(entry.stagedPath);
        break;
    }
  }

  static Future<void> _restoreRemovalEntry(_AccountRemovalEntry entry) async {
    final stagedType = await FileSystemEntity.type(
      entry.stagedPath,
      followLinks: false,
    );
    if (stagedType == FileSystemEntityType.notFound) return;
    _requireEntryType(entry, stagedType);
    if (await FileSystemEntity.type(
          entry.originalPath,
          followLinks: false,
        ) !=
        FileSystemEntityType.notFound) {
      throw StateError(
        'Cannot restore ${entry.originalPath}: an active path already exists.',
      );
    }
    await createPrivateDirectory(p.dirname(entry.originalPath));
    switch (entry.kind) {
      case _AccountRemovalEntryKind.file:
        await File(entry.stagedPath).rename(entry.originalPath);
        break;
      case _AccountRemovalEntryKind.directory:
        await Directory(entry.stagedPath).rename(entry.originalPath);
        break;
    }
  }

  static Future<void> _purgeRemovalEntry(_AccountRemovalEntry entry) async {
    final type = await FileSystemEntity.type(
      entry.stagedPath,
      followLinks: false,
    );
    if (type == FileSystemEntityType.notFound) return;
    _requireEntryType(entry, type);
    switch (entry.kind) {
      case _AccountRemovalEntryKind.file:
        await File(entry.stagedPath).delete();
        break;
      case _AccountRemovalEntryKind.directory:
        await Directory(entry.stagedPath).delete(recursive: true);
        break;
    }
  }

  static void _requireEntryType(
    _AccountRemovalEntry entry,
    FileSystemEntityType type,
  ) {
    final expected = switch (entry.kind) {
      _AccountRemovalEntryKind.file => FileSystemEntityType.file,
      _AccountRemovalEntryKind.directory => FileSystemEntityType.directory,
    };
    if (type != expected) {
      throw StateError(
        'Unexpected filesystem entity at ${entry.originalPath}: $type.',
      );
    }
  }

  static Future<void> _writeRemovalRecord(
    _AccountRemovalRecord record,
  ) {
    _validateRemovalRecordContents(
      record,
      accountRemovalJournalPath(record.account.id),
    );
    return _writeFileAtomically(
      accountRemovalJournalPath(record.account.id),
      jsonEncode(record.toJson()),
    );
  }

  static Future<_AccountRemovalRecord> _readRemovalRecord(String path) async {
    if (await FileSystemEntity.type(path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw StateError('Account removal journal is not a regular file.');
    }
    final decoded = jsonDecode(await File(path).readAsString());
    final record = _AccountRemovalRecord.fromJson(
      decoded as Map<String, Object?>,
    );
    _validateRemovalRecordContents(record, path);
    return record;
  }

  static Future<_AccountRemovalRecord?> _tryReadRemovalRecord(String id) async {
    final path = accountRemovalJournalPath(id);
    if (!await File(path).exists()) return null;
    return _readRemovalRecord(path);
  }

  static Future<void> _deleteRemovalJournal(String id) async {
    final journal = File(accountRemovalJournalPath(id));
    if (await journal.exists()) await journal.delete();
    final directory = journal.parent;
    if (await directory.exists() && await directory.list().isEmpty) {
      await directory.delete();
    }
    final root = Directory(pendingRemovalsDir);
    if (await root.exists() && await root.list().isEmpty) {
      await root.delete();
    }
  }

  static Future<void> _runRemovalHook(AccountRemovalStage stage) async {
    await testAccountRemovalStageHook?.call(stage);
  }

  static Future<void> _deleteFileIfPresent(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Rename an already-registered account's display name. Throws
  /// [StateError] if no account is registered under [id].
  static Future<void> renameAccount(String id, String displayName) {
    return _serializeLifecycle(() async {
      final accounts = await listAccounts();
      final index = accounts.indexWhere((a) => a.id == id);
      if (index < 0) {
        throw StateError('no account registered with id $id');
      }
      final updated = List<AccountSummary>.of(accounts);
      updated[index] = accounts[index].copyWith(displayName: displayName);
      await _writeAccounts(updated);
    });
  }

  /// Persist whether [id] still needs its app-provided starter template.
  static Future<void> setStarterTemplatePending(
    String id,
    bool pending,
  ) {
    return _serializeLifecycle(() async {
      final accounts = await listAccounts();
      final index = accounts.indexWhere((account) => account.id == id);
      if (index < 0) {
        throw StateError('no account registered with id $id');
      }
      final updated = List<AccountSummary>.of(accounts);
      updated[index] = accounts[index].copyWith(
        pendingStarterTemplate: pending,
      );
      await _writeAccounts(updated);
    });
  }

  /// Update an account's server address in its own config.toml, preserving
  /// its mnemonic. Throws [StateError] if no account is registered under
  /// [id].
  static Future<void> updateServerAddress(String id, String serverAddress) {
    return _serializeLifecycle(() async {
      final summary = await _requireSummary(id);
      final configPath = summary.configPathOverride ?? accountConfigPath(id);
      final config = await loadConfig(id);
      await _writeFileAtomically(
        configPath,
        encodeCliConfig(
          mnemonic: _recoveryPhraseStore == null ? config.mnemonic : null,
          serverAddress: serverAddress,
          usesPlatformRecoveryPhrase: _recoveryPhraseStore != null,
        ),
      );
    });
  }

  /// Load an account's config (mnemonic + server address), the same way
  /// [resolveActiveAccount] does for the currently-active account :
  /// respecting [AccountSummary.configPathOverride] for migrated legacy
  /// accounts. Throws [StateError] if no account is registered under [id].
  static Future<CliConfig> loadConfig(
    String id, {
    String? serverOverride,
  }) {
    return _serializeLifecycle(() async {
      final summary = await _requireSummary(id);
      final configPath = summary.configPathOverride ?? accountConfigPath(id);
      final store = _recoveryPhraseStore;
      if (store == null) {
        return CliConfig.loadFrom(configPath, serverOverride: serverOverride);
      }

      final values = await readSimpleTomlFile(configPath);
      final serverAddress =
          serverOverride ?? (values['server_address'] ?? '127.0.0.1:33020');
      final plaintextPhrase = values['mnemonic']?.trim();
      var securePhrase = await store.read(id);

      if (plaintextPhrase != null && plaintextPhrase.isNotEmpty) {
        if (securePhrase != null && securePhrase != plaintextPhrase) {
          throw StateError(
            'Platform recovery phrase does not match the plaintext phrase for '
            'account $id; refusing to overwrite either copy.',
          );
        }

        final createdSecureCopy = securePhrase == null;
        try {
          if (createdSecureCopy) {
            // As with account creation, a platform store may persist and then
            // throw. The preflight read proved there was no prior value, so an
            // idempotent delete is the correct rollback for any attempted write.
            await store.write(id, plaintextPhrase);
          }
          await _writeFileAtomically(
            configPath,
            encodeCliConfig(
              serverAddress: values['server_address'] ?? '127.0.0.1:33020',
              usesPlatformRecoveryPhrase: true,
            ),
          );
        } catch (_) {
          if (createdSecureCopy) {
            await store.delete(id);
          }
          rethrow;
        }
        securePhrase = plaintextPhrase;
      }

      if (securePhrase == null || securePhrase.trim().isEmpty) {
        throw StateError(
          'Recovery phrase is missing from platform secure storage for account '
          '$id.',
        );
      }
      return CliConfig(mnemonic: securePhrase, serverAddress: serverAddress);
    });
  }

  static Future<AccountSummary> _requireSummary(String id) async {
    final accounts = await listAccounts();
    for (final account in accounts) {
      if (account.id == id) return account;
    }
    throw StateError('no account registered with id $id');
  }

  static Future<AccountSyncMetadata> loadSyncMetadata(String id) {
    return _serializeLifecycle(() async {
      await _requireSummary(id);
      final file = File(accountSyncMetadataPath(id));
      if (!await file.exists()) return const AccountSyncMetadata();
      final content = await file.readAsString();
      if (content.trim().isEmpty) return const AccountSyncMetadata();
      final decoded = jsonDecode(content) as Map<String, Object?>;
      return AccountSyncMetadata.fromJson(decoded);
    });
  }

  static Future<void> saveSyncMetadata(
    String id,
    AccountSyncMetadata metadata,
  ) {
    return _serializeLifecycle(() async {
      await _requireSummary(id);
      await createPrivateDirectory(accountDir(id));
      await _writeFileAtomically(
        accountSyncMetadataPath(id),
        jsonEncode(metadata.toJson()),
      );
    });
  }

  static Future<String?> getCurrentAccountId() {
    return _serializeLifecycle(() async {
      await _recoverPendingRemovals();
      return _readCurrentAccountIdRaw();
    });
  }

  static Future<String?> _readCurrentAccountIdRaw() async {
    final file = File(currentPath);
    if (!await file.exists()) {
      return null;
    }
    final content = (await file.readAsString()).trim();
    return content.isEmpty ? null : content;
  }

  static Future<void> setCurrentAccountId(String id) {
    return _serializeLifecycle(() async {
      await _recoverPendingRemovals();
      await _writeCurrentAccountIdRaw(id);
    });
  }

  static Future<void> _writeCurrentAccountIdRaw(String id) {
    return _writeFileAtomically(currentPath, id);
  }

  /// Create the on-disk directory for a new account and write its
  /// config.toml (mnemonic + server_address). Registers the summary in the
  /// shared index. Does not change which account is "current".
  static Future<AccountProfile> createAccount({
    required String mnemonic,
    required String displayName,
    String serverAddress = '127.0.0.1:33020',
    bool pendingStarterTemplate = false,
  }) {
    return _serializeLifecycle(() async {
      final id = await AccountProfile.deriveAccountId(mnemonic);
      return _createAccountWithId(
        id: id,
        mnemonic: mnemonic,
        displayName: displayName,
        serverAddress: serverAddress,
        pendingStarterTemplate: pendingStarterTemplate,
      );
    });
  }

  /// Creates an account only when its mnemonic-derived ID is not registered.
  /// Returns null without touching the existing account when the ID collides.
  static Future<AccountProfile?> createAccountIfNew({
    required String mnemonic,
    required String displayName,
    String serverAddress = '127.0.0.1:33020',
    Set<String> excludedAccountIds = const <String>{},
    bool pendingStarterTemplate = false,
  }) {
    return _serializeLifecycle(() async {
      final id = await AccountProfile.deriveAccountId(mnemonic);
      if (excludedAccountIds.contains(id)) return null;
      final accounts = await listAccounts();
      if (accounts.any((account) => account.id == id)) return null;
      return _createAccountWithId(
        id: id,
        mnemonic: mnemonic,
        displayName: displayName,
        serverAddress: serverAddress,
        pendingStarterTemplate: pendingStarterTemplate,
      );
    });
  }

  static Future<AccountProfile> _createAccountWithId({
    required String id,
    required String mnemonic,
    required String displayName,
    required String serverAddress,
    required bool pendingStarterTemplate,
  }) async {
    final accounts = await listAccounts();
    if (accounts.any((account) => account.id == id)) {
      throw StateError(
        'account $id is already registered; use account selection instead',
      );
    }

    final dir = Directory(accountDir(id));
    final directoryExisted = await dir.exists();
    if (directoryExisted && !await dir.list().isEmpty) {
      throw StateError(
        'account storage already exists for $id; refusing to overwrite it',
      );
    }
    final store = _recoveryPhraseStore;
    if (await store?.read(id) != null) {
      throw StateError(
        'a platform recovery phrase already exists for $id; refusing to '
        'overwrite it',
      );
    }
    if (!directoryExisted) {
      await createPrivateDirectory(dir.path);
    }

    final createdAt = DateTime.now().toUtc();
    var securePhraseWriteAttempted = false;
    var configWritten = false;
    try {
      if (store != null) {
        // Preflight proved no value exists. Mark the attempt first because a
        // platform store can persist and then report failure; cleanup remains
        // safe and idempotent in either case.
        securePhraseWriteAttempted = true;
        await store.write(id, mnemonic);
      }
      await _writeFileAtomically(
        accountConfigPath(id),
        encodeCliConfig(
          mnemonic: store == null ? mnemonic : null,
          serverAddress: serverAddress,
          usesPlatformRecoveryPhrase: store != null,
        ),
      );
      configWritten = true;

      await _writeAccounts(<AccountSummary>[
        ...accounts,
        AccountSummary(
          id: id,
          displayName: displayName,
          createdAt: createdAt,
          pendingStarterTemplate: pendingStarterTemplate,
        ),
      ]);
    } catch (_) {
      if (securePhraseWriteAttempted) {
        await store!.delete(id);
      }
      if (configWritten) {
        await _deleteFileIfPresent(accountConfigPath(id));
      }
      if (!directoryExisted && await dir.exists()) {
        final children = await dir.list().toList();
        if (children.isEmpty) await dir.delete();
      }
      rethrow;
    }

    return AccountProfile(
      id: id,
      displayName: displayName,
      mnemonic: mnemonic,
      createdAt: createdAt,
    );
  }

  /// Register a pre-existing legacy single-account install (a top-level
  /// `~/.manytype/config.toml` + `store.db`, from before named account
  /// profiles existed) as a real, selectable account profile: without
  /// moving or copying any files. The registered [AccountSummary] carries
  /// `configPathOverride`/`dbPathOverride` pointing at the exact legacy
  /// paths, so the migrated account's storage location never changes and
  /// there is no risk of two divergent copies of the data.
  ///
  /// No-op (returns null) if any account is already registered: this makes
  /// the migration idempotent and safe to attempt on every invocation.
  static Future<AccountProfile?> migrateLegacyAccount({
    required String legacyConfigPath,
    required String legacyDbPath,
    required String legacyMnemonic,
    String displayName = 'default',
  }) {
    return _serializeLifecycle(() async {
      final existing = await listAccounts();
      if (existing.isNotEmpty) {
        return null;
      }
      _validateLegacyPaths(
        configPath: legacyConfigPath,
        dbPath: legacyDbPath,
      );

      final id = await AccountProfile.deriveAccountId(legacyMnemonic);
      final createdAt = DateTime.now().toUtc();

      await registerAccount(AccountSummary(
        id: id,
        displayName: displayName,
        createdAt: createdAt,
        configPathOverride: legacyConfigPath,
        dbPathOverride: legacyDbPath,
      ));
      await setCurrentAccountId(id);

      return AccountProfile(
        id: id,
        displayName: displayName,
        mnemonic: legacyMnemonic,
        createdAt: createdAt,
      );
    });
  }

  static Future<void> _writeFileAtomically(String path, String content) {
    return writePrivateFileAtomically(
      path,
      content,
      beforeReplace: testBeforeAtomicReplaceHook,
    );
  }
}

enum _AccountRemovalPhase {
  prepared,
  dataStaged,
  registryUpdated,
  currentPointerUpdated,
  committing,
  committed,
  rollingBack,
}

enum _AccountRemovalEntryKind { file, directory }

final class _AccountRemovalEntry {
  const _AccountRemovalEntry({
    required this.kind,
    required this.originalPath,
    required this.stagedPath,
  });

  final _AccountRemovalEntryKind kind;
  final String originalPath;
  final String stagedPath;

  Map<String, Object?> toJson() => <String, Object?>{
        'kind': kind.name,
        'originalPath': originalPath,
        'stagedPath': stagedPath,
      };

  static _AccountRemovalEntry fromJson(Map<String, Object?> json) {
    return _AccountRemovalEntry(
      kind: _AccountRemovalEntryKind.values.byName(json['kind'] as String),
      originalPath: json['originalPath'] as String,
      stagedPath: json['stagedPath'] as String,
    );
  }
}

final class _AccountRemovalRecord {
  const _AccountRemovalRecord({
    required this.account,
    required this.wasCurrent,
    required this.deleteSecurePhrase,
    required this.phase,
    required this.entries,
  });

  final AccountSummary account;
  final bool wasCurrent;
  final bool deleteSecurePhrase;
  final _AccountRemovalPhase phase;
  final List<_AccountRemovalEntry> entries;

  _AccountRemovalRecord copyWith({_AccountRemovalPhase? phase}) {
    return _AccountRemovalRecord(
      account: account,
      wasCurrent: wasCurrent,
      deleteSecurePhrase: deleteSecurePhrase,
      phase: phase ?? this.phase,
      entries: entries,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'version': 1,
        'account': account.toJson(),
        'wasCurrent': wasCurrent,
        'deleteSecurePhrase': deleteSecurePhrase,
        'phase': phase.name,
        'entries': entries.map((entry) => entry.toJson()).toList(),
      };

  static _AccountRemovalRecord fromJson(Map<String, Object?> json) {
    if (json['version'] != 1) {
      throw StateError('Unsupported account removal journal version.');
    }
    return _AccountRemovalRecord(
      account: AccountSummary.fromJson(
        Map<String, dynamic>.from(json['account']! as Map),
      ),
      wasCurrent: json['wasCurrent'] as bool,
      deleteSecurePhrase: json['deleteSecurePhrase'] as bool,
      phase: _AccountRemovalPhase.values.byName(json['phase'] as String),
      entries: (json['entries'] as List<Object?>)
          .map(
            (entry) => _AccountRemovalEntry.fromJson(
              Map<String, Object?>.from(entry! as Map),
            ),
          )
          .toList(growable: false),
    );
  }
}

String _removalToken(String id) {
  return base64Url.encode(utf8.encode(id)).replaceAll('=', '');
}
