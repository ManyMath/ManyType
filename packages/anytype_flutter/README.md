# anytype_flutter

Flutter integration for the [anytype](https://pub.dev/packages/anytype) SDK.
Adding this package builds `manytype_quic_ffi`, the Rust QUIC bridge that
`anytype` synchronizes through, from source with cargokit and bundles it with
your app. It re-exports the whole `anytype` API, so apps import only this
package.

This is an independent implementation and is not made or endorsed by Anytype
or the Any Association. Version 0.0.2 is an early release.

## Getting started

```yaml
dependencies:
  anytype_flutter: ^0.0.2
```

```dart
import 'package:anytype_flutter/anytype_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AnytypeFlutter.ensureInitialized(); // loads the bridge and checks its ABI
  runApp(const MyApp());
}
```

`AnytypeFlutter.ensureInitialized()` is optional; without it the bridge loads
on the first network operation. Accounts, storage, objects and sync are the
`anytype` API, documented in its README. Set `ManytypeStorage.directory` to an
app-owned directory, and give `AccountRegistry` a `RecoveryPhraseStore` backed
by the platform keychain if recovery phrases must not sit in plaintext files.

[example/](example) shows the bridge ABI and creates notes in a local account.

## Building

Builds compile the bridge for each target with cargokit, so the build machine
needs Rust 1.88 or newer installed with rustup. Cargokit installs the Rust
targets it needs. No prebuilt binaries are downloaded: this release has no
precompiled-binary configuration.

| Platform | How the bridge ships |
| --- | --- |
| Android | `libmanytype_quic_ffi.so` per ABI in the APK |
| iOS, macOS | static library force-loaded into `anytype_flutter.framework` |
| Linux | `libmanytype_quic_ffi.so` in the bundle's `lib/` |
| Windows | `manytype_quic_ffi.dll` beside the executable |

The Rust sources ship in this package under `rust/`: the `manytype_quic_ffi`
crate with `manytype_proto`, `manytype_core` and `manytype_transport` under
`rust/crates/`, and a locked dependency graph. Dart programs outside Flutter
can build the same sources with cargo, as the `anytype` README describes.

## Supported targets

| Target | Build | Bridge loads | Loopback sync |
| --- | --- | --- | --- |
| Linux x64 | Tested | Tested | Tested |
| macOS arm64 | Pending | Pending | Pending |
| iOS | Pending | Not run | Not run |
| Windows x64 | Pending | Pending | Not run |
| Android | Pending | Not run | Not run |

"Loopback sync" means synchronization between two SDK instances through the
ManyType repository's `manytype_server`. It is not compatibility evidence
against an official Any-Sync deployment or Anytype's hosted network.

## License

First-party code in this package is MIT licensed. `rust/crates/manytype_proto`
contains code generated from Anytype-heart schemas under the Any Source
Available License 1.0 and from Any-Sync schemas under the MIT License, and
`anytype` depends on `manytype_protocol`, whose Anytype-heart types carry the
same ASAL terms. ASAL allows use only for Non-Commercial Use or for Commercial
Use in Allowed Networks. The vendored `cargokit/` keeps its own license. See
[LICENSE](LICENSE) before distributing an app built on this package.
