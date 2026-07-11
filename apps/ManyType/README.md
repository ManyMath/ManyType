# ManyType

ManyType is the Flutter workspace client for the repository's offline-first
Any-Sync implementation. Document change payloads are encrypted before they
are written to the local database. Native recovery phrases are stored through
the operating system's secure credential store; existing plaintext native
configs migrate on their first successful open. The offline web editor keeps
its identity in browser-local storage. Synchronization is opt-in and requires a
real Any-Sync network configuration.

The pure Dart `manytype_cli` package retains its original plaintext
`config.toml` behavior when no `RecoveryPhraseStore` is injected. This keeps
command-line installs compatible, while making the boundary explicit: an
account created by this Flutter app must be opened by a native host that can
read its platform-secure phrase.

## Run and test

From this directory:

```sh
flutter run -d chrome
flutter test
flutter analyze
flutter build web --release
```

The release web output is written to `build/web`.

## Accounts and the demo template

`Explore demo workspace` generates a new recovery phrase and local account on
every launch, then copies editable sample content into that account. It does
not connect to or reuse a shared identity. The recovery phrase is available
from Account settings like it is for any other account.

Upgraded installations may still contain the retired public demo identity.
ManyType recognizes only that exact legacy account ID and keeps its warning and
editing/sync restrictions in place; newly generated template accounts are
normal accounts.

## Synchronization

Each account starts with sync **Not configured**. Pasting a valid `client.yml`
marks that account as configured, probing the coordinator reports `Network OK`,
and only a completed sync reports `Synced`. A later local edit returns the
account to `Changes pending` until the next successful sync.

Network configuration, configuration/probe/success timestamps, pending local
changes, and the last error persist with that account. A probe never advances
the successful-sync timestamp, a failed sync preserves the prior success, and
an edit that races a sync remains pending. Forgetting an account removes this
metadata with its local workspace.

Browser workspaces remain offline-only. They retain a browser-local recovery
identity and editable documents, but sync controls are disabled before the
native transport bridge can be instantiated. Configure and run device sync in
a native ManyType app.
