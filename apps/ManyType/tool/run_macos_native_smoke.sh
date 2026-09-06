#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIGURATION="${MANYTYPE_MACOS_CONFIGURATION:-Release}"
APP_PATH="${1:-$APP_DIR/build/macos/Build/Products/$CONFIGURATION/manytype.app}"
EXECUTABLE="$APP_PATH/Contents/MacOS/manytype"

if [[ ! -x "$EXECUTABLE" ]]; then
  echo "ManyType app executable not found: $EXECUTABLE" >&2
  exit 66
fi

BUNDLE_IDENTIFIER="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP_PATH/Contents/Info.plist")"
CONTAINER_TMP="$HOME/Library/Containers/$BUNDLE_IDENTIFIER/Data/tmp"
RESULT_PATH="$CONTAINER_TMP/manytype-native-package-smoke.txt"

entitlements_file="$(mktemp)"
if ! /usr/bin/codesign -d --entitlements :- "$APP_PATH" \
  >"$entitlements_file" 2>/dev/null; then
  rm -f "$entitlements_file"
  echo "could not read the app's signed entitlements" >&2
  exit 1
fi
keychain_group="$(plutil -extract keychain-access-groups.0 raw -o - \
  "$entitlements_file" 2>/dev/null || true)"
rm -f "$entitlements_file"
if [[ -z "$keychain_group" ]]; then
  echo "secure-storage smoke requires a development-signed keychain entitlement" >&2
  exit 64
fi
if [[ "$keychain_group" != *".$BUNDLE_IDENTIFIER" ]]; then
  echo "keychain group does not match the app bundle identifier" >&2
  exit 64
fi
if /usr/bin/codesign -dv "$APP_PATH" 2>&1 | grep -q 'Signature=adhoc'; then
  echo "secure-storage smoke does not accept an ad-hoc app signature" >&2
  exit 64
fi

cleanup() {
  launchctl unsetenv MANYTYPE_NATIVE_SMOKE_PHASE 2>/dev/null || true
  launchctl unsetenv MANYTYPE_NATIVE_SMOKE_RESULT 2>/dev/null || true
  if [[ -n "${launcher_pid:-}" ]]; then
    kill "$launcher_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT

for phase in write read; do
  rm -f "$RESULT_PATH"
  launchctl setenv MANYTYPE_NATIVE_SMOKE_PHASE "$phase"
  launchctl setenv MANYTYPE_NATIVE_SMOKE_RESULT "$RESULT_PATH"

  open -n -W "$APP_PATH" &
  launcher_pid=$!
  launch_finished=0
  for _ in {1..60}; do
    if ! kill -0 "$launcher_pid" 2>/dev/null; then
      launch_finished=1
      break
    fi
    sleep 0.5
  done
  if [[ "$launch_finished" != "1" ]] || ! wait "$launcher_pid"; then
    pkill -f "$EXECUTABLE" 2>/dev/null || true
    echo "native package smoke launch timed out or failed for $phase" >&2
    exit 1
  fi
  launcher_pid=""
  output="$(cat "$RESULT_PATH" 2>/dev/null || true)"
  printf '%s\n' "$output"
  expected="NATIVE_PACKAGE_SMOKE phase=$phase ffi_abi=2 secure_storage=ok"
  if ! grep -Fq "$expected" <<<"$output"; then
    echo "native package smoke did not report success for $phase" >&2
    exit 1
  fi
done

echo "Verified QUIC FFI loading and secure-storage persistence across launches"
