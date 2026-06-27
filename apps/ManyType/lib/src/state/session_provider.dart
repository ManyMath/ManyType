import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manytype_cli/manytype_cli.dart';

import 'accounts_providers.dart';

/// Test-only override point for [sessionProvider]'s native database.
///
/// Null in production, which keeps [ManytypeSession.open]'s normal
/// `ManytypeDatabase(active.dbPath)` (real on-disk file, opened on a
/// background isolate). Widget tests override this with
/// `ManytypeDatabase.forTesting(await openDatabaseForTesting())` --
/// see [ManytypeSession.open]'s dbOverride doc comment for why the
/// real background-isolate constructor never completes under
/// `testWidgets()`.
final sessionTestDbOverrideProvider = Provider<ManytypeDatabase?>((ref) => null);

/// Open [ManytypeSession] for the current account, or null before
/// onboarding completes.
///
/// Native resolves the account through `~/.manytype` via
/// [ManytypeSession.open]; web has no filesystem to resolve from, so it
/// passes the account id explicitly to [ManytypeSession.openWeb] (backed by
/// localStorage registry + OPFS/IndexedDB database). Switching accounts
/// invalidates [currentAccountIdProvider], which rebuilds this provider and
/// closes the previous session.
final sessionProvider = FutureProvider<ManytypeSession?>((ref) async {
  final accountId = await ref.watch(currentAccountIdProvider.future);
  if (accountId == null) {
    return null;
  }
  final session = kIsWeb
      ? await ManytypeSession.openWeb(accountId: accountId)
      : await ManytypeSession.open(
          accountOverride: accountId,
          dbOverride: ref.watch(sessionTestDbOverrideProvider),
        );
  ref.onDispose(session.close);
  return session;
});

/// Deterministic personal space id for the current account (derived from
/// the mnemonic by `Identity.fromMnemonic` when the session opens).
final personalSpaceIdProvider = FutureProvider<String?>((ref) async {
  final session = await ref.watch(sessionProvider.future);
  return session?.identity.spaceId;
});
