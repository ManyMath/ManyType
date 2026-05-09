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

- **`melos run test:ci`**: runs `dart test --exclude-tags=round_trip -j 1`
  for every package with a `test/` directory: the VM suite minus tests
  tagged `round_trip` (docker any-sync oracle / live external-server
  integration tests, e.g. `packages/manytype_cli/test/oracle_*.dart`,
  `round_trip_test.dart`, `consensus_service_test.dart`). Every other VM
  test either has no live-infra dependency or self-skips via an env-var
  gate (`MANYTYPE_LIVE_SERVER_TESTS`, `MANYTYPE_RUN_PHASE*`) when its
  prerequisites aren't set up, so `test:ci` is safe to run on a bare
  runner with the Dart and Rust toolchains but no docker/oracle stack.
  `-j 1` is required, not just conventional: some harness tests
  (`phase38_relation_option_test.dart`, `phase39_collection_test.dart`)
  build and start a real `manytype_server` themselves and race on port
  allocation under concurrent test-file execution: `-j 4` reproduced
  intermittent "Address already in use" failures in testing, `-j 1` did
  not.

## CI

`.github/workflows/web-tests.yml` runs `melos run test:web` and
`.github/workflows/vm-tests.yml` runs `melos run test:ci`, both on push to
`main` and on every pull request. Neither workflow provisions docker or an
any-sync oracle stack, so `round_trip`-tagged and env-var-gated
integration tests remain local-only for now (M021).
