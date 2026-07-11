#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$APP_DIR/../.." && pwd)"
APP_PATH="${1:-$APP_DIR/build/macos/Build/Products/Release/manytype.app}"
LIBRARY_NAME="libmanytype_quic_ffi.dylib"
LIBRARY_PATH="$APP_PATH/Contents/Frameworks/$LIBRARY_NAME"

if [[ ! -d "$APP_PATH" ]]; then
  echo "ManyType app bundle not found: $APP_PATH" >&2
  exit 66
fi
if [[ ! -f "$LIBRARY_PATH" ]]; then
  echo "packaged QUIC bridge not found: $LIBRARY_PATH" >&2
  exit 66
fi

bundle_executable_name="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$APP_PATH/Contents/Info.plist")"
bundle_executable="$APP_PATH/Contents/MacOS/$bundle_executable_name"
if [[ ! -x "$bundle_executable" ]]; then
  echo "bundle executable not found: $bundle_executable" >&2
  exit 66
fi

install_name="$(xcrun otool -D "$LIBRARY_PATH" | tail -n 1 | sed 's/^[[:space:]]*//')"
if [[ "$install_name" != "@rpath/$LIBRARY_NAME" ]]; then
  echo "unexpected dylib install name: $install_name" >&2
  exit 1
fi

app_architectures="$(xcrun lipo -archs "$bundle_executable")"
library_architectures="$(xcrun lipo -archs "$LIBRARY_PATH")"
for architecture in $app_architectures; do
  if [[ " $library_architectures " != *" $architecture "* ]]; then
    echo "QUIC bridge is missing app architecture $architecture" >&2
    exit 1
  fi
done

for symbol in \
  ffi_abi_version \
  ffi_connect \
  ffi_invoke \
  ffi_sync_object \
  ffi_request_object \
  ffi_sync_store \
  ffi_free_handle \
  ffi_free_result; do
  if ! nm -gU "$LIBRARY_PATH" | grep -Eq "[[:space:]]_${symbol}$"; then
    echo "QUIC bridge is missing exported symbol $symbol" >&2
    exit 1
  fi
done

unexpected_dependency="$(xcrun otool -L "$LIBRARY_PATH" \
  | awk '/^[[:space:]]/ { print $1 }' \
  | grep -Ev "^(@rpath/$LIBRARY_NAME$|/System/Library/|/usr/lib/)" \
  | head -n 1 || true)"
if [[ -n "$unexpected_dependency" ]]; then
  echo "QUIC bridge has a non-system dependency: $unexpected_dependency" >&2
  exit 1
fi

/usr/bin/codesign --verify --strict --verbose=2 "$LIBRARY_PATH"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$APP_PATH"

if ! /usr/bin/codesign -d --entitlements - "$APP_PATH" 2>/dev/null \
  | grep -q 'com.apple.security.network.client'; then
  echo "ManyType app is missing the outbound network entitlement" >&2
  exit 1
fi

if [[ -n "${MANYTYPE_QUIC_FFI_PATH:-}" ]]; then
  echo "unset MANYTYPE_QUIC_FFI_PATH before package verification" >&2
  exit 64
fi

(
  cd "$REPO_ROOT"
  dart run apps/ManyType/tool/probe_macos_quic_ffi.dart "$bundle_executable"
)

echo "Verified packaged ManyType QUIC bridge ($library_architectures)"
