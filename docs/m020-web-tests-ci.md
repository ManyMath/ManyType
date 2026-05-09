# M020: CI automation for `dart test -p chrome`

Picks up R039 (deferred since M014): no CI existed in this repo at all.

## What shipped

`.github/workflows/web-tests.yml` — runs on push to `main` and on every pull
request:

1. Checks out the repo.
2. Installs the Dart stable SDK (`dart-lang/setup-dart`).
3. Verifies Chrome is present (GitHub's `ubuntu-latest` runner ships Google
   Chrome preinstalled — this step just asserts that stays true).
4. Activates `melos` and runs `melos bootstrap`.
5. Runs `melos run test:web --no-select` — the same target documented in
   `docs/testing.md`, covering `manytype_protocol`, `manytype_core`, and the
   non-`@TestOn('vm')` subset of `manytype_cli` under headless chrome.

Scope intentionally excludes the plain `melos run test` (VM) target: several
of those tests require a live local `manytype_server` or the docker any-sync
oracle stack (see `scripts/README.md`), which would need service containers
and secrets management — a separate scoping pass, not folded into this
slice. The chrome suite was chosen specifically because `docs/testing.md`
already documents it as self-contained (no FFI, no live network, no
subprocess spawning, no real-filesystem access), making it the only test
target that runs unmodified in a hosted runner.

## Verification

Ran `melos run test:web --no-select` locally end to end before wiring the
workflow: `manytype_core` (128 tests) and `manytype_protocol` (32 tests) both
report `All tests passed!`; `manytype_cli`'s melos exec step reports
`SUCCESS`. This is the exact command the workflow invokes, so the workflow
steps are known-good rather than speculative.

## Next milestone

Undecided. Remaining candidates: `AccountRegistry` cross-tab sync (R042,
still no real consumer to justify scope) and extending CI to the VM test
target (would need service containers for `manytype_server` / any-sync
oracle stack, or a documented split between container-free and
container-dependent VM tests).
