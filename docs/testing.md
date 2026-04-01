# Running the test suite

The workspace has two melos test targets:

- **`melos run test`**: runs `dart test` (VM) for every package with a `test/`
  directory. This is the fast inner-loop target: pure Dart, real `dart:io`,
  real FFI, real subprocess harnesses. Some tests additionally require a live
  local `manytype_server` (`rust/manytype_server`, port 33020 by default) or
  the docker any-sync oracle stack (`docker/any-sync/`): see
  `scripts/README.md` for prerequisites.

- **`melos run test:web`**: fetches web test assets (sqlite3.wasm, the drift
  worker bundle) via `packages/manytype_cli/tool/fetch_web_test_assets.dart`
  where needed, then runs `dart test -p chrome -j 1` for every package with a
  `test/` directory. `-j 1` avoids headless-chrome resource contention across
  concurrently loaded browser instances (M014/S05). Both `manytype_core` and
  `manytype_protocol` run their full VM-equivalent suite on chrome.
  `manytype_cli` runs every test that does not require FFI, a live
  network connection, subprocess spawning, or real-filesystem access: those
  are marked `@TestOn('vm')` with a one-line justification comment and are
  automatically skipped by `dart test` on the `chrome` platform. See
  `packages/manytype_cli/test/web/persistence_test.dart` for the end-to-end
  IndexedDB open/write/close/reopen/read acceptance test, exercised through
  the public library entrypoint (`package:manytype_cli/manytype_cli.dart`).

Run either target with `--no-select` in non-interactive contexts (CI, agents)
to skip melos's package picker prompt, e.g. `melos run test:web --no-select`.
