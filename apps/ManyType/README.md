# ManyType

ManyType is the Flutter workspace client for the repository's offline-first
Any-Sync implementation. Document change payloads are encrypted before they
are written to the local database. Recovery phrases remain in the native
account config or browser profile storage and therefore rely on the device and
browser's access controls. Synchronization is opt-in and requires a real
Any-Sync network configuration.

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

Sync configuration and status are currently held in memory and scoped to the
active account. Reloading therefore returns to **Not configured** rather than
claiming stale readiness. When server deployment and configuration persistence
are added, they must remain per-account and store real probe/sync timestamps;
the app must not infer sync state from legacy account metadata.
