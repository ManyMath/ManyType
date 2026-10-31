# Native QUIC bridge packaging

The native ManyType client loads `manytype_quic_ffi`, the Rust QUIC transport
bridge. The app gets it from the `anytype_flutter` plugin on every platform.
The plugin builds the crate with cargokit from its own `rust/Cargo.lock` and
bundles the result, so the app has no packaging script for it. Where the
library ends up in a built app:

| Platform | Bundled library |
| --- | --- |
| Linux | `bundle/lib/libmanytype_quic_ffi.so` |
| Windows | `manytype_quic_ffi.dll` beside the executable |
| Android | `lib/<abi>/libmanytype_quic_ffi.so` in the APK (arm64-v8a, armeabi-v7a, x86_64), with `libsqlite3.so` |
| iOS, macOS | `anytype_flutter.framework` (macOS: `manytype.app/Contents/Frameworks/anytype_flutter.framework`) |

On Apple platforms cargokit links the crate into the plugin framework, which
Xcode signs with the app. The macOS app has an outbound-network sandbox
entitlement.

Build and verify an ad-hoc release bundle from the repository root:

```sh
apps/ManyType/tool/build_macos_app.sh
apps/ManyType/tool/verify_macos_quic_ffi.sh
```

The ad-hoc build is a portable packaging check only. It uses
`DebugProfileAdHoc.entitlements` or `ReleaseAdHoc.entitlements`, which omit
Keychain Sharing. It must not be used as evidence that recovery phrases persist
through the operating-system credential store.

Private canaries require an externally supplied development team and the
keychain-sharing entitlements. No team or signing identity is committed:

```sh
MANYTYPE_MACOS_SIGNING_MODE=development \
MANYTYPE_DEVELOPMENT_TEAM="$APPLE_DEVELOPMENT_TEAM" \
MANYTYPE_ALLOW_PROVISIONING_UPDATES=1 \
apps/ManyType/tool/build_macos_app.sh
```

To exercise both the packaged FFI and credential persistence, build the smoke
entrypoint with those same signing variables and run it twice:

```sh
MANYTYPE_MACOS_SIGNING_MODE=development \
MANYTYPE_DEVELOPMENT_TEAM="$APPLE_DEVELOPMENT_TEAM" \
MANYTYPE_ALLOW_PROVISIONING_UPDATES=1 \
MANYTYPE_MACOS_BUNDLE_IDENTIFIER=com.manytype.manytype.package-smoke \
MANYTYPE_FLUTTER_TARGET=tool/native_package_smoke.dart \
apps/ManyType/tool/build_macos_app.sh
apps/ManyType/tool/run_macos_native_smoke.sh
```

The verifier checks the `anytype_flutter.framework` in the built app: its
signature, its install name, architectures covering the app's, the exported
FFI API, that it links only itself and system libraries, the network
entitlement, that no stale `libmanytype_quic_ffi.dylib` remains in
`Contents/Frameworks`, and an ABI call through Dart's production loader.

## Current signed-canary blocker

On 2026-07-13, the repository-safe ad-hoc universal build, package verifier,
and normal app launch passed on the canary host. The sandboxed development
smoke could not be completed with an isolated bundle identifier because the
host's Xcode account credential is missing its token and no matching Mac App
Development provisioning profile exists. Xcode reports both `missing
Xcode-Token` and `No profiles ... were found`.

Do not reuse the production bundle identifier or remove the app sandbox to
bypass this boundary. Refresh the Xcode account credential, create or download
a profile for the isolated smoke identifier, then rerun the development-signed
build and two-launch smoke commands above.

## Library discovery

`NativeBridge.libraryPath` and then `MANYTYPE_QUIC_FFI_PATH` are explicit
overrides. Without them, the loader prefers the copy an anytype_flutter
app carries next to its executable (`lib/` on Linux, beside the executable on
Windows, the `anytype_flutter` framework on iOS and macOS), then on macOS a
signed `libmanytype_quic_ffi.dylib` in the app bundle's `Contents/Frameworks`
(the ManyType app does not ship one there, and the plugin framework wins over
a stale one), then the platform library name through the
platform loader path (`libmanytype_quic_ffi.so` on Linux and Android, where
this finds the APK copy, `manytype_quic_ffi.dll` on Windows,
`libmanytype_quic_ffi.dylib` on Apple platforms), then on iOS and macOS the
framework by its short path, then on iOS and macOS the process's own symbols,
checked for `ffi_abi_version`, and finally release and debug builds in
`rust/target` and `packages/anytype_flutter/rust/target` found while walking
up from the current directory. A configured override is always used and fails
the load if it is missing or broken. If the plugin's bundled copy or the app
bundle library exists but cannot load, the load fails rather than falling back,
so a shipped app whose bundled copy is present never reaches the development
walk. Every load checks `ffi_abi_version` against the Dart bindings.

The ManyType app and Flutter apps outside this repository get the library from
`anytype_flutter`, which builds it from source with cargokit for each platform
and bundles it.
Dart programs build it with cargo from that package's `rust/` directory; see
`packages/anytype/README.md`. No prebuilt binaries are published.
