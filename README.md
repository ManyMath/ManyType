# Manytype

A Dart/Rust client for the Any-Sync protocol used by Anytype, targeting
bidirectional interoperability with the official Anytype stack.

## Layout

- `packages/manytype_protocol`: protobuf-generated wire types.
- `packages/manytype_core`: CRDT object model and sync logic shared across
  clients.
- `packages/manytype_cli`: the Dart CLI/library surface (native + web),
  including account, network-config, and file-relation handling.
- `rust/`: Rust workspace: `manytype_core` (Rust-side CRDT engine),
  `manytype_proto`, `manytype_quic_ffi` (QUIC transport FFI), and
  `manytype_server` (a from-scratch Any-Sync-compatible server).
- `docs/`: design notes and rationale (see `docs/testing.md` for the
  test-suite layout and `docs/oracle-capture-rationale.md` for how protocol
  regression fixtures are captured).
- `test_vectors/`: recorded protocol fixtures used by regression tests.

## Development

This is a [melos](https://melos.invertase.dev/) workspace. From the repo
root:

```sh
dart pub global activate melos
melos bootstrap
melos run test:ci     # VM test suite (safe for a bare CI runner)
melos run test:web    # chrome test suite
melos run analyze
melos run format-check
```

The Rust workspace is developed independently from `rust/`:

```sh
cd rust
cargo test --workspace
cargo clippy --workspace --all-targets -- -D warnings
cargo audit
```

CI runs all of the above; see `.github/workflows/`. Because the Dart workspace
includes the ManyType app and its sibling-path ManyUI dependency, every Dart
workflow checks out ManyType as `ManyType/` and the exact compatible ManyUI
commit beside it as `ManyUI/`. Configure `DEPENDENCY_CHECKOUT_TOKEN` as a
read-only repository Actions secret that can clone the private
`sneurlax/manyui` repository. CI fails closed when this PAT is absent and does
not fall back to the current repository's job token.
