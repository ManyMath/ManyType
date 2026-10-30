# anytype

A Dart SDK for Any-Sync accounts. It derives account keys from a BIP-39
recovery phrase, keeps signed and encrypted object changes in a local SQLite
store, edits and replays objects with Anytype's block model, and synchronizes
spaces over QUIC through a small Rust bridge (`manytype_quic_ffi`).

This is the client library behind the ManyType app and command line. It is an
independent implementation and is not made or endorsed by Anytype or the Any
Association.

Version 0.0.2 is an early release. The API is the one ManyType itself uses and
may change before 1.0.

## Packages

| Package | Contents |
| --- | --- |
| `anytype` | Accounts, recovery, sessions, local storage, object commands, sync, and the native bridge loader. |
| `manytype_core` | Pure Dart key derivation, encryption, signing, ACL records, and CRDT object trees. |
| `manytype_protocol` | Generated protobuf types for the Any-Sync and Anytype block protocols. |

`anytype` depends on the other two. Add them directly only when your code
imports their libraries.

## Getting started

```yaml
dependencies:
  anytype: ^0.0.2
```

```dart
import 'package:anytype/anytype.dart';

Future<void> main() async {
  ManytypeStorage.directory = '/path/to/app/data';
  await createAccountCommand(name: 'Personal');

  final session = await ManytypeSession.open();
  try {
    await session.objects.create('First note');
    for (final object in await session.objects.list()) {
      print('${object.name} ${object.id}');
    }
  } finally {
    await session.close();
  }
}
```

[example/example.dart](example/example.dart) is a complete offline program:
it creates an account, adds and edits objects, reads them back, and restores
the account from its recovery phrase into a second store. It needs no network
and no QUIC bridge, only the system SQLite library (see Supported targets).

## Accounts, storage and recovery

On native platforms all account data lives under `ManytypeStorage.directory`,
which defaults to `.manytype` in the user's home directory. Set it before
resolving accounts or opening a session. It contains:

- `accounts.json` and `current`: the account index and the selected account.
- `accounts/<id>/config.toml`: the account's recovery phrase and server
  address.
- `accounts/<id>/store.db`: the SQLite object store.

Account IDs, identity keys and the personal space ID are derived
deterministically from the recovery phrase, so restoring a phrase with
`AccountRegistry.createAccount(mnemonic: ...)` on another device yields the
same account and space. Objects appear on the new device after a sync.

Object changes are signed with the account's identity key and their contents
are encrypted with keys derived from the phrase before they are stored. The
recovery phrase itself is stored in plaintext in `config.toml`, in a
directory and file restricted to the owner on Linux and macOS. Hosts that have
a platform credential store should implement `RecoveryPhraseStore` and pass
it to `AccountRegistry.configureRecoveryPhraseStore` before using accounts;
the ManyType app does this with the Keychain and other OS credential stores.
Never log `session.config.mnemonic` or `Identity` key material.

On the web, account data lives in the browser's OPFS or IndexedDB storage
through drift's WebAssembly backend, and `ManytypeSession.openWeb` opens an
account by ID. The page must serve `sqlite3.wasm` (matching the resolved
`sqlite3` package version) and `drift_worker.dart.js`, compiled from this
package's `tool/drift_web_worker.dart`. Both are fetched by relative URL, so
they must sit beside the page (relative to its base URL).

## Native QUIC bridge

Synchronization calls into `manytype_quic_ffi`, a Rust library that handles
QUIC, libp2p TLS, the Any-Sync handshake and DRPC framing. This package is
pure Dart and does not contain it; offline use never loads it.

Flutter apps depend on
[anytype_flutter](https://pub.dev/packages/anytype_flutter) instead, which
re-exports this package and builds and bundles the library for the app with
cargokit. The build machine needs a Rust toolchain installed with rustup.

Dart programs outside Flutter build the library from anytype_flutter's Rust
sources with Rust 1.88 or newer (tested with 1.94.0 on Linux and 1.89.0 on
macOS), then point the SDK at it:

```sh
dart pub cache add anytype_flutter --version 0.0.2
cargo build --locked --release \
  --manifest-path "${PUB_CACHE:-$HOME/.pub-cache}/hosted/pub.dev/anytype_flutter-0.0.2/rust/Cargo.toml" \
  --target-dir build/anytype
export MANYTYPE_QUIC_FFI_PATH="$PWD/build/anytype/release/libmanytype_quic_ffi.so"
```

On macOS the file is `libmanytype_quic_ffi.dylib`. AOT-compiled executables
can instead set `NativeBridge.libraryPath` to the library they ship.

`NativeBridge` loads the library from the first of these that applies:

1. `NativeBridge.libraryPath`, if your code sets it.
2. The `MANYTYPE_QUIC_FFI_PATH` environment variable.
3. On macOS, `Contents/Frameworks/libmanytype_quic_ffi.dylib` in the running
   app bundle (the ManyType app's layout).
4. The copy an anytype_flutter app carries next to its executable:
   `lib/libmanytype_quic_ffi.so` on Linux, `manytype_quic_ffi.dll` on Windows,
   and the `anytype_flutter.framework` binary on iOS and macOS.
5. The platform library name (`libmanytype_quic_ffi.so` on Linux and Android,
   `manytype_quic_ffi.dll` on Windows, `libmanytype_quic_ffi.dylib` on Apple
   platforms) through the platform's search path. On Android this finds the
   copy anytype_flutter puts in the APK.
6. On iOS and macOS, `anytype_flutter.framework/anytype_flutter` by its short
   path.
7. On iOS and macOS, symbols already loaded into the process, checked for
   `ffi_abi_version`.
8. `rust/target` and `packages/anytype_flutter/rust/target` release and debug
   builds in the current directory or any parent, for development inside the
   ManyType repository.

A path set through steps 1 or 2 is always used: if it is missing or fails to
load, the load fails. When the library named by steps 3 or 4 exists but fails
to load, the load fails too rather than trying the next step, so an app whose
bundled copy is present never falls back to a development build. Every load
checks the library's C ABI version against `NativeBridge.expectedAbiVersion`
and throws on a mismatch. If nothing loads, a `StateError` lists what was
tried and how to provide the library.

## Synchronization

Synchronization targets an Any-Sync network described by a YAML network
configuration listing coordinator, tree, file and consensus nodes:

```yaml
id: my-network
networkId: my-network
nodes:
  - peerId: 12D3KooW...
    addresses:
      - 127.0.0.1:4830
    types:
      - coordinator
  # ...one entry each for tree, file and consensus nodes
```

A new account's space must be registered once with
`seedLiveSpaceForSync` before its first sync. After that,
`session.sync.run(networkConfigPath: ...)` pushes local changes and pulls
remote ones. Restored devices only call `sync.run`.
[example/sync_example.dart](example/sync_example.dart) performs a two-device
round trip; copy it into your project's `bin/` to run it, since examples are
not runnable from the pub cache, and provide the bridge as described above. The sync service currently prints progress
lines to standard output.

## Supported targets

| Target | Local storage and objects | Native sync |
| --- | --- | --- |
| Linux x64 (Dart VM) | Tested | Tested against a loopback server, also with the library a Flutter build bundles |
| macOS arm64 (Dart VM) | Tested | Tested against a loopback server |
| Windows x64 (Dart VM) | Tested on Windows 10 | The DLL an anytype_flutter build bundles loads; sync not run |
| Android, iOS (Flutter) | Tested through anytype_flutter, which bundles SQLite, on an emulator and a simulator | Tested against a loopback server through anytype_flutter on an emulator and a simulator |
| Web | Supported via drift WebAssembly | Not available: `NativeBridge` throws `UnsupportedError` |

anytype_flutter's README lists exactly what was checked on each platform.

The ManyType app also bundles the bridge into a macOS `.app`
(`Contents/Frameworks`); that path is covered by the app's own packaging
checks, not by this package's release checks.

Native storage uses SQLite through `package:sqlite3`. Flutter apps on
anytype_flutter get a bundled copy from `sqlite3_flutter_libs`. Dart programs
use the system library: on Linux it opens `libsqlite3.so`, which Debian and
Ubuntu install only with `libsqlite3-dev`. macOS uses the system library. On
Windows it uses `sqlite3.dll` if one is on the search path, otherwise the
operating system's `winsqlite3.dll`.

## Interoperability

The verified evidence for this release is loopback synchronization between
SDK instances through `manytype_server`, the Any-Sync-compatible server in
the ManyType repository. That repository also has harnesses against a
self-hosted Any-Sync stack and the official Anytype CLI, but they were not
run for this release and are not compatibility evidence for it. Nothing here
has been validated against Anytype's hosted network.

Known limitations:

- Object operations cover the kinds, relations and block styles that
  `session.objects.create` and `edit` expose, not the full Anytype model.
- Object commands work in the account's personal space, derived from the
  recovery phrase.
- Each `sync.run` call is a batch push and pull, not a live subscription.

## License

First-party code in this package is MIT licensed. It depends on
`manytype_protocol`, whose types generated from Anytype-heart schemas are under
the Any Source Available License 1.0. ASAL allows use only for Non-Commercial
Use or for Commercial Use in Allowed Networks. See [LICENSE](LICENSE) and the
`manytype_protocol` LICENSE before distributing software built on this
package.
