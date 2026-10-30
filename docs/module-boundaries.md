# ManyType module boundaries

The repository stays together. `anytype` (formerly `manytype_client`) owns the
reusable account, session, storage, sync, recovery, and transport API. The Flutter app and CLI
consume `package:anytype/anytype.dart`; application tests use
`package:anytype/testing.dart` for platform-specific in-memory storage.
The legacy `manytype_cli.dart` export remains a compatibility facade. CLI argument
parsing, process output, and developer/operator tools remain in `manytype_cli`.
Existing `*Command` function names and `CliConfig` are retained for source
compatibility: they are typed client operations, without command-line parsing.

The client has no dependency on the CLI. Its implementation and tests moved
without changing storage schemas, key handling, network wire formats, or native
ABI names. The public barrel exposes the API the app and CLI already used; at
0.0.x it is not a promise that every helper stays stable.

## Public SDK packages

The publishable family is `manytype_protocol`, `manytype_core` and `anytype`
(pure Dart) plus `anytype_flutter` (Flutter ffiPlugin), all at the same version
and depending on each other through hosted caret constraints. The pub workspace
resolves those constraints to the local members, so development needs no
overrides. The app, CLI and server stay `publish_to: none`. The Dart packages
must not depend on them, on Flutter, or on ManyUI; the plugin may depend on
Flutter but not on the others. `anytype` is the only client implementation and
`anytype_flutter` re-exports it. `manytype_protocol` stays separate because
its generated Anytype-heart types carry ASAL 1.0 terms that the MIT packages
do not, and `manytype_core` is the IO-free layer that the app and CLI also
import.

The plugin follows the other ManyMath `<x>_dart` + plugin pairs (sound,
bluetooth, ratex). It owns the production Rust crates in
`packages/anytype_flutter/rust`, so they ship in its archive, and builds them
with the pinned, patched cargokit fork vendored in
`packages/anytype_flutter/cargokit` (see `tool/cargokit/README.md`).
`manytype_quic_ffi` is the root package of that directory, because cargokit
needs a `[package]` in its manifest dir, and `manytype_proto`,
`manytype_core` and `manytype_transport` sit under `rust/crates/` in the same
Cargo workspace with their own lockfile. The server workspace in `rust/`
depends on them by path. Its `manytype_quic_ffi_host` member only keeps the
bridge in that build graph, so repository harnesses can still run `cargo
build -p manytype_quic_ffi` from `rust/` and find the library in
`rust/target`; cargo cannot select a package reachable only as a
dev-dependency. The boundary check fails if the two lockfiles disagree on any
shared crate.

The ManyType app keeps depending on `anytype` and its own macOS bundling
(`apps/ManyType/tool/build_macos_quic_ffi.sh`), which places a signed
`libmanytype_quic_ffi.dylib` in `Contents/Frameworks`. Switching it to
`anytype_flutter` would force-load a static library into the plugin
framework instead and break what `verify_macos_quic_ffi.sh` checks.

Publish in dependency order: `manytype_protocol`, `manytype_core`, `anytype`,
then `anytype_flutter`.

`scripts/check_sdk_archives.sh` is the release gate. It writes the real
archives with `dart pub publish --to-archive`, checks their contents and the
plugin's platform wiring, serves them from a disposable local registry
(`scripts/sdk_registry.dart`), and resolves fresh consumers against it with an
empty pub cache and no overrides. A pure Dart consumer runs the published
offline example at the newest and lowest allowed versions. The gate then
builds the bridge with cargo from the hosted plugin's sources, as the
`anytype` README tells Dart programs to, and builds a fresh Flutter desktop
app on the hosted plugin so cargokit compiles it. On Linux both libraries
must be the only bridge mapped into the process and must sync with the
published example over a loopback `manytype_server`
(`scripts/sdk_loopback.sh`); on macOS the launched app must map the plugin
framework and report the ABI. `.gitea/workflows/sdk-archives.yml` runs it on
Linux.

`manytype_transport` owns DRPC framing/streams, deadlines, and credential
handshake helpers shared by the server and QUIC FFI client. Server-side routing,
listener setup, persistence, and application behavior remain in
`manytype_server`. The server reexports the old helper module paths for existing
internal consumers. The client FFI has no server dependency at all; its
loopback handshake tests build an equivalent QUIC listener themselves.

Run `python3 scripts/check_module_boundaries.py` with Rust 1.94.0 to enforce
public consumer imports, keep the SDK pubspecs hosted-only and free of
application packages, and verify the actual Cargo production graph excludes
the server and its `redb` storage dependency. Run client tests from
`packages/anytype`, CLI subprocess tests from `packages/manytype_cli`,
and app tests with Flutter from `apps/ManyType`. Existing shell harnesses retain
the CLI executable and operator-tool paths.

## Protocol generation

Provision protoc 3.21.12, Rust/rustfmt 1.94.0, Dart 3.13.2 and
protoc-gen-prost 0.5.0. Install generators in a disposable tool directory, never
by changing a shared Rust default. `tool/protocol_codegen/pubspec.lock` pins the
Dart plugin 25.0.0 and its transitive dependencies. Set `PROTOC_GEN_PROST` to the
pinned executable if it is not on PATH.

Set `PROTOC_INCLUDE` to the matching protobuf include directory when needed
(for an official Windows protoc archive, its `include` directory). The script
checks for `google/protobuf/struct.proto`; without an override it looks beside
the selected protoc installation and then under `/usr/include`. Windows uses
the checked-in `.bat` Dart-plugin adapter. Keep the provisioned Dart SDK on PATH.
The formatter is resolved directly from the installed Rust 1.94.0 toolchain;
a missing component fails instead of using another formatter from PATH.
Generated text uses canonical LF bytes on every host. Git attributes prevent
checkout conversion of those bytes, and `--check` compares checked-in bytes
exactly rather than hiding line-ending drift.

```
python3 scripts/generate_protocol.py
python3 scripts/generate_protocol.py --check
```

The check generates into a fresh temporary directory and compares every Dart
and Rust generated file, including additions and removals. The generator
encodes two existing prost collision repairs (`block::ContentOneOf` and
`metadata::PayloadOneOf`) with checked occurrence counts, then applies pinned
rustfmt. These names already existed in the baseline; schema messages also
named Content/Payload make raw prost output invalid. `buf.gen.yaml` remains a
schema/tool reference; direct unpinned Buf generation is not the canonical
reproduction path.

## Private CI and remaining validation

`.gitea/workflows` ports all existing validation lanes: Rust, static analysis,
VM, browser, product distribution, offline artifact verification, and the
optional Docker oracle. Protocol drift and module boundaries have their own
lane. This complete directory avoids silently hiding existing GitHub fallback
workflows. Host guards run before checkout; SDKs are provisioned and Cargo homes
are isolated per job. CI does not publish or change shared tool defaults.

The Docker oracle is manual and requires the separate
`manymath-oracle-linux-x64` runner with provisioned rootless Docker tooling.
The manual script creates its own daemon/socket/data directory and fresh source
snapshot under RUNNER_TEMP. It refuses an unexpected Docker data root and stops
only its own direct child processes after checking kernel process identity.
It never connects to the default Docker daemon or removes preexisting volumes.
This lane is not runtime-verified until that runner is available. It is not started on
the maintenance runner. Tests skipped for missing oracle configuration or
explicit live-service opt-ins are not passing compatibility evidence. Private
web build artifacts do not deploy the site. Public mirrors and publication
remain owner actions.
