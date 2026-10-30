#!/usr/bin/env bash
# Build the anytype SDK publish archives and prove a fresh consumer can use
# them.
#
#   scripts/check_sdk_archives.sh [output-dir]
#
# 1. Stages the native sources and runs `dart pub publish --dry-run` and
#    `--to-archive` for manytype_protocol, manytype_core and anytype.
# 2. Checks each archive for required and forbidden content.
# 3. Serves the archives from a disposable local registry
#    (scripts/sdk_registry.dart) and resolves a new consumer project against
#    it with an empty PUB_CACHE and no path or git overrides.
# 4. Runs the companion packages' own tests from their archives, analyzes the
#    consumer and runs the published offline example, also at the lowest
#    versions the constraints allow.
# 5. Builds the QUIC bridge from the pub cache copy of native/ with
#    `dart run anytype:build_native` and runs the published sync example
#    against a loopback manytype_server.
#
# Archives and logs are kept in output-dir (default: a new temp directory).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${1:-$(mktemp -d)}"
mkdir -p "$OUT_DIR"
OUT_DIR="$(cd "$OUT_DIR" && pwd)"
ARCHIVES="$OUT_DIR/archives"
WORK="$(mktemp -d)"
REGISTRY_PID=""
cleanup() {
  if [[ -n "$REGISTRY_PID" ]]; then
    kill "$REGISTRY_PID" >/dev/null 2>&1 || true
    wait "$REGISTRY_PID" 2>/dev/null || true
  fi
  rm -rf "$WORK"
}
trap cleanup EXIT
rm -rf "$ARCHIVES"
mkdir -p "$ARCHIVES"
PACKAGES=(manytype_protocol manytype_core anytype)
VERSION=0.0.2

step() { printf '\n== %s\n' "$*"; }
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
# A stalled pub.dev connection can hang pub indefinitely; bound and retry.
pub_retry() {
  local attempt
  for attempt in 1 2 3; do
    timeout 300 dart pub "$@" && return 0
    printf 'dart pub %s failed (attempt %s)\n' "$*" "$attempt" >&2
  done
  return 1
}

step 'Stage native sources'
python3 "$ROOT_DIR/scripts/stage_sdk_native.py"
(cd "$ROOT_DIR" && dart pub get >/dev/null)

step 'Pub dry runs and archives'
for package in "${PACKAGES[@]}"; do
  log="$OUT_DIR/dry-run-$package.log"
  (cd "$ROOT_DIR/packages/$package" && dart pub publish --dry-run) >"$log" 2>&1 ||
    { cat "$log"; fail "$package dry run"; }
  grep -q 'Package has 0 warnings' "$log" || { cat "$log"; fail "$package has warnings"; }
  (cd "$ROOT_DIR/packages/$package" &&
    dart pub publish --to-archive="$ARCHIVES/$package-$VERSION.tar.gz") \
    >"$OUT_DIR/archive-$package.log" 2>&1 ||
    { cat "$OUT_DIR/archive-$package.log"; fail "$package archive"; }
  tar tzf "$ARCHIVES/$package-$VERSION.tar.gz" | sort >"$OUT_DIR/files-$package.txt"
  printf '%s: %s files, %s bytes\n' "$package" \
    "$(wc -l <"$OUT_DIR/files-$package.txt")" \
    "$(wc -c <"$ARCHIVES/$package-$VERSION.tar.gz")"
done

step 'Archive contents'
require() {
  local package="$1"; shift
  for file in "$@"; do
    grep -qx "$file" "$OUT_DIR/files-$package.txt" || fail "$package archive lacks $file"
  done
}
forbid() {
  local package="$1" pattern="$2"
  if grep -E "$pattern" "$OUT_DIR/files-$package.txt"; then
    fail "$package archive contains $pattern"
  fi
}
for package in "${PACKAGES[@]}"; do
  require "$package" pubspec.yaml LICENSE README.md CHANGELOG.md
  forbid "$package" '(^|/)(\.dart_tool|build|target)/'
  pubspec="$(tar xzOf "$ARCHIVES/$package-$VERSION.tar.gz" pubspec.yaml)"
  grep -q "^version: $VERSION\$" <<<"$pubspec" || fail "$package is not $VERSION"
  if grep -Eq '^    (path|git):|^publish_to:|^dependency_overrides:' <<<"$pubspec"; then
    fail "$package pubspec has a non-hosted dependency or publish_to"
  fi
done
require manytype_protocol licenses/any-sync-v0.9.9-MIT.txt \
  licenses/anytype-heart-cfb7ec9-ASAL-1.0.txt
require anytype example/example.dart example/sync_example.dart bin/build_native.dart \
  native/Cargo.toml native/Cargo.lock native/README.md \
  native/manytype_quic_ffi/src/lib.rs native/manytype_transport/src/lib.rs \
  native/manytype_core/src/lib.rs native/manytype_proto/src/lib.rs \
  native/manytype_proto/licenses/any-sync-v0.9.9-MIT.txt \
  native/manytype_proto/licenses/anytype-heart-cfb7ec9-ASAL-1.0.txt
for crate in manytype_quic_ffi manytype_transport manytype_core manytype_proto; do
  require anytype "native/$crate/Cargo.toml" "native/$crate/LICENSE"
done
forbid anytype '^test/|manytype_server'
if tar xzOf "$ARCHIVES/anytype-$VERSION.tar.gz" native/Cargo.lock | grep -Eq 'name = "(manytype_server|redb)"'; then
  fail 'anytype native lockfile includes the server or its storage'
fi
echo 'Required files present; no build output, tests, server or path dependencies.'

step 'Start disposable registry'
(cd "$ROOT_DIR" && dart --packages=.dart_tool/package_config.json \
  scripts/sdk_registry.dart "$WORK/port" "$ARCHIVES"/*.tar.gz) >"$OUT_DIR/registry.log" 2>&1 &
REGISTRY_PID=$!
for _ in $(seq 1 60); do [[ -s "$WORK/port" ]] && break; sleep 0.5; done
[[ -s "$WORK/port" ]] || { cat "$OUT_DIR/registry.log"; fail 'registry did not start'; }
export PUB_HOSTED_URL="http://127.0.0.1:$(cat "$WORK/port")"
export PUB_CACHE="$WORK/pub-cache"
unset MANYTYPE_QUIC_FFI_PATH LD_LIBRARY_PATH DYLD_LIBRARY_PATH
echo "Registry at $PUB_HOSTED_URL, empty PUB_CACHE at $PUB_CACHE"

step 'Companion package tests from their archives'
for package in manytype_protocol manytype_core; do
  mkdir -p "$WORK/$package"
  tar xzf "$ARCHIVES/$package-$VERSION.tar.gz" -C "$WORK/$package"
  # Outside the monorepo there is no workspace root, as on pub.dev.
  sed -i.bak '/^resolution: workspace$/d' "$WORK/$package/pubspec.yaml"
  (cd "$WORK/$package" && pub_retry get >/dev/null && dart test -r compact) ||
    fail "$package archive tests"
done

step 'Fresh consumer'
CONSUMER="$WORK/consumer"
mkdir -p "$CONSUMER/bin"
tar xzf "$ARCHIVES/anytype-$VERSION.tar.gz" -C "$CONSUMER/bin" --strip-components=1 \
  example/example.dart example/sync_example.dart
cat >"$CONSUMER/pubspec.yaml" <<EOF
name: anytype_consumer
publish_to: none
environment:
  sdk: ^3.5.3
dependencies:
  anytype: $VERSION
  path: ^1.9.0
EOF
(cd "$CONSUMER" && pub_retry get) >"$OUT_DIR/consumer-pub-get.log" 2>&1 ||
  { cat "$OUT_DIR/consumer-pub-get.log"; fail 'consumer pub get'; }
python3 - "$CONSUMER/pubspec.lock" "$PUB_HOSTED_URL" "$VERSION" <<'PY'
import re
import sys
lock, registry, version = sys.argv[1:]
text = open(lock).read()
if re.search(r'^    source: (path|git)$', text, re.M):
    raise SystemExit('consumer lockfile has path or git sources')
for name in ['anytype', 'manytype_core', 'manytype_protocol']:
    match = re.search(rf'^  {name}:\n((?:    .*\n)+)', text, re.M)
    body = match.group(1) if match else ''
    if (f'url: "{registry}"' not in body or 'source: hosted' not in body
            or f'version: "{version}"' not in body):
        raise SystemExit(f'{name} not resolved as hosted {version} from {registry}')
print(f'anytype, manytype_core and manytype_protocol resolved as hosted {version}')
PY
cp "$CONSUMER/pubspec.lock" "$OUT_DIR/consumer-pubspec.lock"
(cd "$CONSUMER" && dart analyze --fatal-infos bin) || fail 'consumer analyze'
(cd "$CONSUMER" && dart run bin/example.dart) | tee "$OUT_DIR/offline-example.log"
grep -q 'matches: true' "$OUT_DIR/offline-example.log" || fail 'offline example'

step 'Fresh consumer at lowest allowed versions'
(cd "$CONSUMER" && pub_retry downgrade >"$OUT_DIR/consumer-downgrade.log" 2>&1 &&
  dart analyze bin && dart run bin/example.dart >"$OUT_DIR/offline-example-downgraded.log") ||
  { cat "$OUT_DIR/consumer-downgrade.log"; fail 'consumer at lowest versions'; }
grep -q 'matches: true' "$OUT_DIR/offline-example-downgraded.log" || fail 'downgraded offline example'
(cd "$CONSUMER" && pub_retry upgrade >/dev/null)

step 'Native bridge from the published sources'
(cd "$CONSUMER" && dart run anytype:build_native) 2>&1 | tee "$OUT_DIR/build-native.log" | grep -v '^ *Compiling'
grep -q "Compiling manytype_quic_ffi v0.1.0 ($PUB_CACHE/" "$OUT_DIR/build-native.log" ||
  fail 'bridge was not built from the pub cache copy'

step 'Loopback sync with the published example'
"$ROOT_DIR/scripts/sdk_loopback.sh" "$CONSUMER" bin/sync_example.dart 2>&1 |
  tee "$OUT_DIR/loopback.log" | grep -v '^ *Compiling'
grep -q '^Device B pulled ' "$OUT_DIR/loopback.log" || fail 'loopback sync'

step "PASSED: archives in $ARCHIVES"
