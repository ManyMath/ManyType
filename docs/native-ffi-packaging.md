# Native QUIC bridge packaging

The native ManyType client loads `manytype_quic_ffi`, the Rust QUIC transport
bridge. macOS app builds compile the bridge from `rust/Cargo.lock` with
`cargo build --locked --release` and place it at this stable bundle path:

```text
manytype.app/Contents/Frameworks/libmanytype_quic_ffi.dylib
```

The build rewrites the dylib ID to
`@rpath/libmanytype_quic_ffi.dylib` and signs the library with the same identity
Xcode uses for the app. The app has an outbound-network sandbox entitlement.

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

The verifier checks the app and nested-library signatures, architectures,
install name, system-only dynamic dependencies, exported FFI API, network
entitlement, and ABI call through Dart's production bundle-path resolver.

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
overrides. Without them, the loader prefers the signed library in a macOS app
bundle, then the platform loader path, then the library `dart run
anytype:build_native` placed in the running project's
`.dart_tool/anytype/native`, then release and debug Rust artifacts found while
walking up from the current directory. The platform path precedes the project
build so a stale `.dart_tool` copy in this workspace cannot shadow a library
a harness selects through `LD_LIBRARY_PATH`. Inside the repository,
`build_native` builds from `rust/` rather than a staged snapshot. If a bundle or project library exists but cannot load, the load
fails rather than falling back to another artifact. Every load checks
`ffi_abi_version` against the Dart bindings. Package consumers outside this
repository rely on the first four; the directory walk serves repository
development only. The loader maps Linux and macOS only.

SDK consumers build the bridge from the Rust sources shipped in the `anytype`
archive; see `packages/anytype/README.md`. No prebuilt binaries are
published.
