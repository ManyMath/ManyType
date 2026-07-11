#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
RUST_DIR="$REPO_ROOT/rust"
LIBRARY_NAME="libmanytype_quic_ffi.dylib"
DESTINATION_DIR="${1:-$RUST_DIR/target/macos-package}"

export PATH="$HOME/.cargo/bin:$PATH"
CARGO_BIN="${CARGO:-$(command -v cargo || true)}"
if [[ -z "$CARGO_BIN" ]]; then
  echo "cargo is required to build the ManyType QUIC bridge" >&2
  exit 1
fi

requested_architectures="${ARCHS:-$(uname -m)}"
declare -a built_libraries=()
declare -a normalized_architectures=()

for architecture in $requested_architectures; do
  case "$architecture" in
    arm64 | aarch64)
      normalized_architecture="arm64"
      rust_target="aarch64-apple-darwin"
      ;;
    x86_64)
      normalized_architecture="x86_64"
      rust_target="x86_64-apple-darwin"
      ;;
    *)
      echo "unsupported macOS architecture: $architecture" >&2
      exit 1
      ;;
  esac

  echo "Building $LIBRARY_NAME for $rust_target"
  (
    cd "$RUST_DIR"
    CARGO_INCREMENTAL=0 \
      CARGO_TARGET_DIR="$RUST_DIR/target" \
      "$CARGO_BIN" build \
      --locked \
      --release \
      --package manytype_quic_ffi \
      --target "$rust_target"
  )

  built_library="$RUST_DIR/target/$rust_target/release/$LIBRARY_NAME"
  if [[ ! -f "$built_library" ]]; then
    echo "cargo did not produce $built_library" >&2
    exit 1
  fi
  built_libraries+=("$built_library")
  normalized_architectures+=("$normalized_architecture")
done

mkdir -p "$DESTINATION_DIR"
destination="$DESTINATION_DIR/$LIBRARY_NAME"
if [[ ${#built_libraries[@]} -eq 1 ]]; then
  cp -f "${built_libraries[0]}" "$destination"
else
  xcrun lipo -create "${built_libraries[@]}" -output "$destination"
fi

# Cargo records an absolute LC_ID_DYLIB. Packaged clients use the app runpath
# and must not retain a path to the checkout that produced the artifact.
xcrun install_name_tool -id "@rpath/$LIBRARY_NAME" "$destination"
xattr -cr "$destination"

if [[ "${CODE_SIGNING_ALLOWED:-YES}" != "NO" ]]; then
  signing_identity="${EXPANDED_CODE_SIGN_IDENTITY:--}"
  if [[ -z "$signing_identity" ]]; then
    signing_identity="-"
  fi
  /usr/bin/codesign \
    --force \
    --sign "$signing_identity" \
    --timestamp=none \
    "$destination"
fi

actual_architectures="$(xcrun lipo -archs "$destination")"
for architecture in "${normalized_architectures[@]}"; do
  if [[ " $actual_architectures " != *" $architecture "* ]]; then
    echo "$destination is missing architecture $architecture" >&2
    exit 1
  fi
done

install_name="$(xcrun otool -D "$destination" | tail -n 1 | sed 's/^[[:space:]]*//')"
if [[ "$install_name" != "@rpath/$LIBRARY_NAME" ]]; then
  echo "unexpected dylib install name: $install_name" >&2
  exit 1
fi

echo "Packaged $destination ($actual_architectures)"
