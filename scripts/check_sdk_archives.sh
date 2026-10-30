#!/usr/bin/env bash
# Build the anytype SDK publish archives and prove fresh consumers can use
# them.
#
#   scripts/check_sdk_archives.sh [output-dir]
#
# 1. Runs `dart pub publish --dry-run` and `--to-archive` for
#    manytype_protocol, manytype_core, anytype and anytype_flutter, and checks
#    each archive for required and forbidden content.
# 2. Serves the archives from a disposable local registry
#    (scripts/sdk_registry.dart) and resolves new consumer projects against
#    it with an empty PUB_CACHE and no path or git overrides.
# 3. Runs the companion packages' own tests from their archives, analyzes a
#    pure Dart consumer and runs the published offline example, also at the
#    lowest versions the constraints allow.
# 4. Follows the README's Dart CLI path: fetches the hosted anytype_flutter
#    into the pub cache, builds its Rust sources with cargo, and runs the
#    published sync example against a loopback manytype_server.
# 5. Builds a fresh Flutter desktop app for this host on the hosted
#    anytype_flutter, so cargokit compiles the bridge from the archive's
#    sources. On Linux it proves the bundled library is the one the app maps
#    and syncs with it over loopback; on macOS it checks the framework exports
#    the bridge and that the launched app maps the framework and loads ABI 2.
#
# Archives and logs are kept in output-dir, which must be new or empty
# (default: a new temp directory). Runs on Linux or macOS. Needs Flutter with
# that desktop toolchain, Rust 1.88+ via rustup, Python 3.11+, coreutils
# timeout, and network access to pub.dev and crates.io. On Linux the app is
# launched only when xvfb-run is present.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${1:-$(mktemp -d)}"
mkdir -p "$OUT_DIR"
OUT_DIR="$(cd "$OUT_DIR" && pwd)"
if [[ -n "$(ls -A "$OUT_DIR")" ]]; then
  printf 'output directory %s is not empty\n' "$OUT_DIR" >&2
  exit 64
fi
ARCHIVES="$OUT_DIR/archives"
WORK="$(mktemp -d)"
REGISTRY_PID=""
APP_RUNNER=""
APP_PID=""
APP_EXECUTABLE=""
cleanup() {
  for pid in "$APP_PID" "$APP_RUNNER" "$REGISTRY_PID"; do
    if [[ -n "$pid" ]]; then
      kill "$pid" >/dev/null 2>&1 || true
      wait "$pid" 2>/dev/null || true
    fi
  done
  rm -rf "$WORK"
}
trap cleanup EXIT
mkdir -p "$ARCHIVES"
PACKAGES=(manytype_protocol manytype_core anytype anytype_flutter)
VERSION=0.0.2
case "$(uname -s)" in
  Linux) HOST=linux; BRIDGE_FILE=libmanytype_quic_ffi.so ;;
  Darwin) HOST=macos; BRIDGE_FILE=libmanytype_quic_ffi.dylib ;;
  *) printf 'the archive gate runs on Linux or macOS\n' >&2; exit 64 ;;
esac

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

(cd "$ROOT_DIR" && pub_retry get >/dev/null)

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
contract() {
  local file="$1" text="$2"
  tar xzOf "$ARCHIVES/anytype_flutter-$VERSION.tar.gz" "$file" | grep -qF "$text" ||
    fail "anytype_flutter $file does not contain: $text"
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
require anytype example/example.dart example/sync_example.dart
forbid anytype '^test/|^native/|^bin/'
require anytype_flutter lib/anytype_flutter.dart rust/Cargo.toml rust/Cargo.lock \
  rust/LICENSE rust/src/lib.rs cargokit/cmake/cargokit.cmake cargokit/build_pod.sh \
  cargokit/gradle/plugin.gradle cargokit/VENDOR_PROVENANCE.json cargokit/LICENSE \
  rust/crates/manytype_proto/licenses/any-sync-v0.9.9-MIT.txt \
  rust/crates/manytype_proto/licenses/anytype-heart-cfb7ec9-ASAL-1.0.txt
for crate in manytype_transport manytype_core manytype_proto; do
  require anytype_flutter "rust/crates/$crate/Cargo.toml" "rust/crates/$crate/LICENSE" \
    "rust/crates/$crate/src/lib.rs"
done
forbid anytype_flutter 'manytype_server'
contract linux/CMakeLists.txt 'apply_cargokit(${PROJECT_NAME} ../rust manytype_quic_ffi'
contract windows/CMakeLists.txt 'apply_cargokit(${PROJECT_NAME} ../rust manytype_quic_ffi ffi_abi_version)'
contract android/build.gradle 'manifestDir = "../rust"'
contract ios/anytype_flutter.podspec 'build_pod.sh" ../rust manytype_quic_ffi'
contract macos/anytype_flutter.podspec 'build_pod.sh" ../rust manytype_quic_ffi'
plugin_lock="$(tar xzOf "$ARCHIVES/anytype_flutter-$VERSION.tar.gz" rust/Cargo.lock)"
if grep -Eq 'name = "(manytype_server|redb)"' <<<"$plugin_lock"; then
  fail 'anytype_flutter lockfile includes the server or its storage'
fi
echo 'Required files and platform wiring present; no build output, tests, server or path dependencies.'

step 'Start disposable registry'
(cd "$ROOT_DIR" && exec dart --packages=.dart_tool/package_config.json \
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

step 'Fresh Dart consumer'
CONSUMER="$WORK/consumer"
mkdir -p "$CONSUMER/bin"
tar xzf "$ARCHIVES/anytype-$VERSION.tar.gz" -C "$CONSUMER/bin" --strip-components=1 \
  example/example.dart example/sync_example.dart
cp "$ROOT_DIR/scripts/sdk_check_bridge.dart" "$CONSUMER/bin/check_bridge.dart"
cat >"$CONSUMER/pubspec.yaml" <<YAML
name: anytype_consumer
publish_to: none
environment:
  sdk: ^3.8.1
dependencies:
  anytype: $VERSION
  path: ^1.9.0
YAML
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

step 'Fresh Dart consumer at lowest allowed versions'
(cd "$CONSUMER" && pub_retry downgrade >"$OUT_DIR/consumer-downgrade.log" 2>&1 &&
  dart analyze bin && dart run bin/example.dart >"$OUT_DIR/offline-example-downgraded.log") ||
  { cat "$OUT_DIR/consumer-downgrade.log"; fail 'consumer at lowest versions'; }
grep -q 'matches: true' "$OUT_DIR/offline-example-downgraded.log" || fail 'downgraded offline example'
(cd "$CONSUMER" && pub_retry upgrade >/dev/null)

# Prove a library loads as the only mapped bridge, then sync over loopback.
loopback() {
  local library="$1" label="$2"
  (cd "$CONSUMER" && MANYTYPE_QUIC_FFI_PATH="$library" dart run bin/check_bridge.dart) |
    tee "$OUT_DIR/check-bridge-$label.log"
  grep -q '^Loaded ' "$OUT_DIR/check-bridge-$label.log" || fail "bridge check ($label)"
  MANYTYPE_QUIC_FFI_PATH="$library" "$ROOT_DIR/scripts/sdk_loopback.sh" \
    "$CONSUMER" bin/sync_example.dart 2>&1 | tee "$OUT_DIR/loopback-$label.log" |
    grep -v '^ *Compiling'
  grep -q '^Device B pulled ' "$OUT_DIR/loopback-$label.log" || fail "loopback sync ($label)"
}

step 'Dart CLI path: bridge built from the hosted anytype_flutter sources'
pub_retry cache add anytype_flutter --version "$VERSION" >"$OUT_DIR/cache-add.log" 2>&1 ||
  { cat "$OUT_DIR/cache-add.log"; fail 'pub cache add anytype_flutter'; }
plugin_sources=("$PUB_CACHE"/hosted/*/anytype_flutter-"$VERSION")
[[ -f "${plugin_sources[0]}/rust/Cargo.toml" ]] || fail 'anytype_flutter sources not in the pub cache'
cargo build --locked --release --manifest-path "${plugin_sources[0]}/rust/Cargo.toml" \
  --target-dir "$WORK/cli-target" >"$OUT_DIR/cli-cargo.log" 2>&1 ||
  { tail -30 "$OUT_DIR/cli-cargo.log"; fail 'cargo build of the hosted plugin sources'; }
grep -qF "Compiling manytype_quic_ffi v0.1.0 (${plugin_sources[0]}/rust)" "$OUT_DIR/cli-cargo.log" ||
  fail 'bridge was not built from the pub cache copy'
loopback "$WORK/cli-target/release/$BRIDGE_FILE" cli

step 'Flutter consumer: cargokit build from the hosted anytype_flutter'
APP="$WORK/flutter_consumer"
(cd "$WORK" && timeout 600 flutter create --no-pub --platforms="$HOST" \
  --project-name anytype_flutter_consumer flutter_consumer) >"$OUT_DIR/flutter-create.log" 2>&1 ||
  { cat "$OUT_DIR/flutter-create.log"; fail 'flutter create'; }
rm -rf "$APP/test"
cat >"$APP/pubspec.yaml" <<YAML
name: anytype_flutter_consumer
publish_to: none
environment:
  sdk: ^3.10.0
dependencies:
  flutter:
    sdk: flutter
  anytype_flutter: $VERSION
YAML
cp "$ROOT_DIR/scripts/sdk_flutter_consumer_main.dart" "$APP/lib/main.dart"
# Build from source even if a user or ancestor directory prefers prebuilts.
printf 'use_precompiled_binaries: false\n' >"$APP/cargokit_options.yaml"
(cd "$APP" && timeout 600 flutter pub get) >"$OUT_DIR/flutter-pub-get.log" 2>&1 ||
  { cat "$OUT_DIR/flutter-pub-get.log"; fail 'flutter consumer pub get'; }
grep -A5 '^  anytype_flutter:' "$APP/pubspec.lock" | grep -qF "url: \"$PUB_HOSTED_URL\"" ||
  fail 'anytype_flutter not resolved from the registry'
cp "$APP/pubspec.lock" "$OUT_DIR/flutter-consumer-pubspec.lock"
if [[ "$HOST" == linux ]]; then
  plugin_link="$APP/linux/flutter/ephemeral/.plugin_symlinks/anytype_flutter"
else
  plugin_link="$APP/macos/Flutter/ephemeral/.symlinks/plugins/anytype_flutter"
fi
(cd "$APP" && timeout 1500 flutter build "$HOST" --debug) >"$OUT_DIR/flutter-build.log" 2>&1 ||
  { tail -40 "$OUT_DIR/flutter-build.log"; fail "flutter build $HOST"; }
[[ "$(readlink -f "$plugin_link")" == "$(readlink -f "${plugin_sources[0]}")" ]] ||
  fail "plugin is not the pub cache copy: $(readlink -f "$plugin_link")"

# Launch the app from an empty directory, so no library in the caller's
# directory or its parents can stand in for the bundled one, and wait until it
# reports the bridge ABI. Sets APP_PID.
launch() {
  local executable="$1"; shift
  mkdir -p "$WORK/launch"
  (cd "$WORK/launch" && exec "$@" "$executable") >"$OUT_DIR/flutter-app.log" 2>&1 &
  APP_RUNNER=$!
  APP_EXECUTABLE="$executable"
  APP_PID=""
  for _ in $(seq 1 90); do
    APP_PID="$(pgrep -f "^$executable\$" | head -1 || true)"
    [[ -n "$APP_PID" ]] && grep -q 'bridge ABI' "$OUT_DIR/flutter-app.log" && break
    sleep 1
  done
}
stop_app() {
  [[ -n "$APP_PID" ]] && kill "$APP_PID" 2>/dev/null || true
  pkill -f "^$APP_EXECUTABLE\$" 2>/dev/null || true
  kill "$APP_RUNNER" 2>/dev/null || true
  wait "$APP_RUNNER" 2>/dev/null || true
  APP_RUNNER=""
  APP_PID=""
  grep 'bridge ABI 2' "$OUT_DIR/flutter-app.log" || fail 'Flutter app did not load the bridge'
}

if [[ "$HOST" == linux ]]; then
  bundled="$APP/build/linux/x64/debug/bundle/lib/$BRIDGE_FILE"
  [[ -f "$bundled" ]] || fail "the Linux bundle has no $BRIDGE_FILE"
  echo "Bundled $bundled (sha256 $(sha256sum "$bundled" | cut -d' ' -f1))"
  if command -v xvfb-run >/dev/null; then
    launch "$APP/build/linux/x64/debug/bundle/anytype_flutter_consumer" xvfb-run -a
    mapped=""
    [[ -n "$APP_PID" ]] &&
      mapped="$(grep manytype_quic_ffi "/proc/$APP_PID/maps" | awk '{print $6}' | sort -u || true)"
    stop_app
    [[ "$mapped" == "$(readlink -f "$bundled")" ]] || fail "Flutter app mapped: $mapped"
    echo "Flutter app mapped $mapped"
  elif [[ "${CI:-}" == true ]]; then
    fail 'xvfb-run is required in CI to launch the Flutter app'
  else
    echo 'xvfb-run not found: skipped launching the Flutter app'
  fi
  loopback "$bundled" flutter-bundle
else
  app="$APP/build/macos/Build/Products/Debug/anytype_flutter_consumer.app"
  framework="$app/Contents/Frameworks/anytype_flutter.framework/anytype_flutter"
  [[ -f "$framework" ]] || fail 'the macOS app has no anytype_flutter framework'
  nm -gU "$framework" | grep -q ' _ffi_abi_version$' ||
    fail 'the anytype_flutter framework does not export ffi_abi_version'
  echo "Bundled the bridge into $framework (sha256 $(shasum -a 256 "$framework" | cut -d' ' -f1))"
  launch "$app/Contents/MacOS/anytype_flutter_consumer" env
  images=""
  [[ -n "$APP_PID" ]] && images="$(lsof -p "$APP_PID" 2>/dev/null || true)"
  stop_app
  grep -q 'anytype_flutter.framework/Versions/A/anytype_flutter' <<<"$images" ||
    fail 'the Flutter app did not map the anytype_flutter framework'
  # The framework carries the bridge statically, so a separate bridge dylib
  # in the process would mean the loader found something else.
  if grep -q "$BRIDGE_FILE" <<<"$images"; then
    fail "the Flutter app mapped a separate $BRIDGE_FILE"
  fi
  echo "Flutter app mapped the anytype_flutter framework and no separate $BRIDGE_FILE"
  # The framework links FlutterMacOS, so a plain Dart process cannot load
  # it; the loopback above used the same sources built as a dylib.
fi

step "PASSED: archives in $ARCHIVES"
