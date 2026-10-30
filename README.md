# ManyType

A Dart/Rust client for the Any-Sync protocol used by Anytype, targeting
bidirectional interoperability with the official Anytype stack.

## Layout

- `packages/manytype_protocol`: protobuf-generated wire types.
- `packages/manytype_core`: CRDT object model and sync logic shared across
  clients.
- `packages/anytype`: the reusable native/web account, session, storage,
  synchronization, and recovery library, prepared for pub.dev as the pure
  Dart `anytype` SDK together with `manytype_core` and `manytype_protocol`
  (see `docs/module-boundaries.md`).
- `packages/anytype_flutter`: the Flutter plugin that builds and bundles the
  QUIC bridge with cargokit. Its `rust/` directory holds the production
  crates: `manytype_quic_ffi` (QUIC transport FFI) and, under `crates/`,
  `manytype_core` (Rust-side CRDT engine), `manytype_proto` and
  `manytype_transport` (shared wire helpers).
- `packages/manytype_cli`: the command-line entry point and operator tools,
  consuming the public client API.
- `rust/`: the server workspace: `manytype_server` (a from-scratch
  Any-Sync-compatible server), which uses the plugin's crates by path, and
  `manytype_quic_ffi_host`, which lets `cargo build -p manytype_quic_ffi` run
  here for repository harnesses.
- `docs/`: design notes and rationale (see `docs/testing.md` for the
  test-suite layout and `docs/oracle-capture-rationale.md` for how protocol
  regression fixtures are captured).
- `test_vectors/`: recorded protocol fixtures used by regression tests.

## Development

This is a [melos](https://melos.invertase.dev/) workspace. From the repo
root:

```sh
flutter pub get --enforce-lockfile
./tool/melos run test:ci     # VM test suite (safe for a bare CI runner)
./tool/melos run test:web    # chrome test suite
./tool/melos run analyze
./tool/melos run format-check
```

The Rust workspace is developed independently from `rust/`:

```sh
cd rust
cargo test --workspace
cargo clippy --workspace --all-targets -- -D warnings
cargo audit
```

Private CI runs these validation lanes in `.gitea/workflows/`. The optional
Docker oracle needs a separately provisioned runner and configuration. The ManyType app depends
on ManyUI through a pinned commit of its public git repository
(https://github.com/ManyMath/ManyUI), so a single ManyType clone is enough to
build and test. To work against a local ManyUI checkout at `../ManyUI`, add an
untracked `pubspec_overrides.yaml` at the repository root; the root
`pubspec.yaml` comment above `dependency_overrides` has the snippet.

See [module boundaries and protocol generation](docs/module-boundaries.md) for
the client/server dependency contracts and pinned regeneration commands. See
[protocol licenses and provenance](third_party/README.md) before preparing any
public distribution. First-party licensing remains an owner decision; this
private maintenance candidate is not a public release.
