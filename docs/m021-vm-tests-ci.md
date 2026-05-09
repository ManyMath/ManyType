# M021: CI automation for the container-free VM test suite

Follow-on to M020 (`docs/m020-web-tests-ci.md`). M020 explicitly deferred
the plain `melos run test` (VM) target because "some of those tests
require a live local `manytype_server` or the docker any-sync oracle
stack... a separate scoping pass." This milestone did that scoping pass.

## Investigation

Grepped `packages/*/test/*.dart` for live-infra dependencies. Findings:

- Only `manytype_cli` has tests requiring external infra; `manytype_core`
  and `manytype_protocol` are pure unit tests with no VM-vs-web
  distinction beyond platform (`@TestOn`).
- Tests needing the docker any-sync oracle stack or a manually-started
  live server/FFI build are consistently tagged `@Tags(['round_trip'])`
  (defined in `packages/manytype_cli/dart_test.yaml`) — e.g.
  `oracle_acl_lifecycle_test.dart`, `oracle_object_sync_test.dart`,
  `round_trip_test.dart`, `consensus_service_test.dart`,
  `space_pull_bootstrap_test.dart`. These attempt a real connection
  unconditionally and would fail (not skip) without that infra.
- Tests named `phase*_test.dart` for numbered milestone/phase harnesses
  self-skip via `Platform.environment['MANYTYPE_RUN_PHASE<N>'] != '1'`
  checks, printing a skip message and returning early — safe to run
  as-is in any environment.
- Two exceptions: `phase38_relation_option_test.dart` and
  `phase39_collection_test.dart` do NOT self-skip — they build and start
  a real `manytype_server` via `cargo build` + `Process.run` on every
  run, entirely self-contained (no docker, no manual setup). Running
  these concurrently with other test files at `-j 4` reproduced
  intermittent `Address already in use (os error 98)` failures from port
  collisions between concurrently-spawned server instances; `-j 1`
  eliminated the flakiness in three consecutive local runs.

## What shipped

- New melos script `test:ci` (`pubspec.yaml`): `dart test
  --exclude-tags=round_trip -j 1` across every package with a `test/`
  directory.
- New workflow `.github/workflows/vm-tests.yml`: installs Dart stable,
  verifies `cargo` is present (ubuntu-latest ships it), activates melos,
  bootstraps, runs `melos run test:ci --no-select`.
- `docs/testing.md` documents the new target and the `-j 1` requirement.

## Verification

Ran the underlying command directly multiple times before committing:
- `-j 4`: passed once, then failed on a second consecutive run with two
  "Address already in use" errors in phase38/phase39 — confirmed
  concurrency-induced, not a missing-infra failure (both tests otherwise
  pass; the skipped/self-gated tests around them all reported "Skipping
  ... test: set MANYTYPE_RUN_PHASE*=1").
- `-j 1`: passed cleanly across two separate runs (once via raw `melos
  exec`, once via the final `melos run test:ci --no-select` wiring),
  confirming the fix and that the wired script matches what was verified.

## Next milestone

Undecided. Remaining candidates: `AccountRegistry` cross-tab sync (R042,
still no real consumer to justify scope), or provisioning the docker
any-sync oracle stack as a CI service container to bring `round_trip`-
tagged tests under CI as well (real scope: service container config,
image build/pull time, secrets if any live-network probes are involved).
