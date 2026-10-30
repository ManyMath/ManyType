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
and no native library.

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
package's `tool/drift_web_worker.dart`, from its origin root.

## Native QUIC bridge

Synchronization calls into `manytype_quic_ffi`, a Rust library that handles
QUIC, libp2p TLS, the Any-Sync handshake and DRPC framing. Its production
sources ship in this package under `native/`, with a locked dependency
graph. Offline use does not load it.

Build it for your project with Rust 1.85 or newer (1.94.0 is the tested
toolchain):

```sh
dart run anytype:build_native
```

This runs `cargo build --locked --release` on the shipped sources and places
the library in `.dart_tool/anytype/native/` of your project. Pass
`--output-dir <dir>` to copy it somewhere else as well, for example into an
application bundle.

`NativeBridge` loads the library from the first of these that applies:

1. `NativeBridge.libraryPath`, if your code sets it.
2. The `MANYTYPE_QUIC_FFI_PATH` environment variable.
3. On macOS, `Contents/Frameworks/libmanytype_quic_ffi.dylib` in the running
   app bundle.
4. `.dart_tool/anytype/native/` of the running project, when a package config
   is available (`dart run`, `dart test`, JIT executables).
5. The platform's library search path.
6. `rust/target/release` and `rust/target/debug` in the current directory or
   any parent, for development inside the ManyType repository.

Steps 1 to 4 do not fall back when the library they name exists but fails to
load. Every load checks the library's C ABI version against
`NativeBridge.expectedAbiVersion` and throws on a mismatch. If nothing loads,
a `StateError` explains how to build or point at the library. AOT-compiled
executables have no package config, so they should set
`NativeBridge.libraryPath` to the library they ship.

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
round trip. The sync service currently prints progress lines to standard
output.

## Supported targets

| Target | Local storage and objects | Native sync |
| --- | --- | --- |
| Linux x64 (Dart VM) | Tested | Tested against a loopback server |
| macOS arm64 (Dart VM) | Tested | Tested against a loopback server |
| Windows x64 (Dart VM) | Tested on Windows 10 | Not supported: the loader has no Windows library and `build_native` refuses |
| Web | Supported via drift WebAssembly | Not available: `NativeBridge` throws `UnsupportedError` |
| Android, iOS | Not validated | Not supported by the loader |

The ManyType app also bundles the bridge into a macOS `.app`
(`Contents/Frameworks`); that path is covered by the app's own packaging
checks, not by this package's release checks.

Native storage uses the system SQLite library through `package:sqlite3`: on
Windows that is `sqlite3.dll` if one is on the search path, otherwise the
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

First-party code in this package is MIT licensed. `native/manytype_proto`
contains code generated from Anytype-heart schemas under the Any Source
Available License 1.0, and this package depends on `manytype_protocol`,
whose Anytype-heart types carry the same terms. ASAL allows use only for
Non-Commercial Use or for Commercial Use in Allowed Networks. See
[LICENSE](LICENSE) and the `manytype_protocol` LICENSE before distributing
software built on this package.
