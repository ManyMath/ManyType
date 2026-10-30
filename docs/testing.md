# Running the test suite

Use `./tool/melos` from the repository root. This launcher also routes Melos's
internal child commands through the workspace-pinned dependency, so no global
Melos installation is required.

The workspace has three melos test targets:

- **`melos run test`**: runs `dart test` (VM) for every package with a `test/`
  directory. This is the fast inner-loop target: pure Dart, real `dart:io`,
  real FFI, real subprocess harnesses. Some tests additionally require a live
  local `manytype_server` (`rust/manytype_server`, port 33020 by default) or
  the docker any-sync oracle stack (`docker/any-sync/`): see
  `scripts/README.md` for prerequisites.

- **`melos run test:web`**: fetches web test assets (sqlite3.wasm, the drift
  worker bundle) via `packages/anytype/tool/fetch_web_test_assets.dart`
  where needed, then runs `dart test -p chrome -j 1` for every package with a
  `test/` directory. `-j 1` avoids headless-chrome resource contention across
  concurrently loaded browser instances (M014/S05). Both `manytype_core` and
  `manytype_protocol` run their full VM-equivalent suite on chrome.
  `anytype` runs every test that does not require FFI, a live
  network connection, subprocess spawning, or real-filesystem access: those
  are marked `@TestOn('vm')` with a one-line justification comment and are
  automatically skipped by `dart test` on the `chrome` platform. See
  `packages/anytype/test/web/persistence_test.dart` for the end-to-end
  IndexedDB open/write/close/reopen/read acceptance test, exercised through
  the public library entrypoint (`package:anytype/anytype.dart`).
  The CLI's process tests and Flutter app are excluded from this Dart browser
  target; the app has its own Flutter Chrome test.

Browser test assets are generated under the ignored
`packages/anytype/test/web_assets/` directory rather than committed.
The asset tool downloads sqlite3.wasm for the version in the workspace lockfile,
records its source and hash, and compiles the checked-in Drift worker source
with the provisioned Dart SDK before the browser suite runs.

Run either target with `--no-select` in non-interactive contexts (CI, agents)
to skip melos's package picker prompt, e.g. `melos run test:web --no-select`.

- **`melos run test:ci`**: runs `dart test --exclude-tags=round_trip -j 1`
  for every package with a `test/` directory: the VM suite minus tests
  tagged `round_trip` (docker any-sync oracle / live external-server
  integration tests, e.g. `packages/anytype/test/oracle_*.dart`,
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

## SDK archives

`scripts/check_sdk_archives.sh [output-dir]` builds the `anytype`,
`manytype_core` and `manytype_protocol` publish archives and tests them from a
fresh consumer through a disposable local registry, including a native bridge
build and a loopback sync (see [module boundaries](module-boundaries.md)). It
needs Dart, Rust 1.85 or newer and network access to pub.dev and crates.io.
A pass is loopback evidence, not compatibility evidence against an official
Any-Sync deployment.

## Self-hosted oracle stack

The oracle tests and harnesses expect the docker any-sync stack and the
official Anytype CLI image pinned by `docker/any-sync/oracle.lock.env`:

```sh
bash scripts/self_hosted_oracle_pin.sh   # writes docker/any-sync/.env.override, pulls the pinned anytype-cli image
(cd docker/any-sync && make start)
bash scripts/self_hosted_oracle_preflight.sh
```

Without the pin step, `make start` resolves the `prod` any-sync versions
and the preflight rejects the stack.

## CI

`.gitea/workflows/web-tests.yml` runs `melos run test:web` and
`.gitea/workflows/vm-tests.yml` runs `melos run test:ci` on the private primary
forge. Neither workflow provisions Docker or an any-sync oracle stack, so
`round_trip`-tagged and env-var-gated tests require separate configuration.
The manual oracle lane requires a dedicated runner with an isolated rootless
Docker daemon; see [module boundaries](module-boundaries.md). The GitHub mirror
workflows remain owner-operated.
