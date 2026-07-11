#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIGURATION="${MANYTYPE_MACOS_CONFIGURATION:-Release}"
FLUTTER_TARGET="${MANYTYPE_FLUTTER_TARGET:-lib/main.dart}"
SIGNING_MODE="${MANYTYPE_MACOS_SIGNING_MODE:-adhoc}"

case "$CONFIGURATION" in
  Debug)
    flutter_mode="debug"
    adhoc_entitlements="DebugProfileAdHoc.entitlements"
    signed_entitlements="DebugProfile.entitlements"
    ;;
  Profile)
    flutter_mode="profile"
    adhoc_entitlements="DebugProfileAdHoc.entitlements"
    signed_entitlements="DebugProfile.entitlements"
    ;;
  Release)
    flutter_mode="release"
    adhoc_entitlements="ReleaseAdHoc.entitlements"
    signed_entitlements="Release.entitlements"
    ;;
  *)
    echo "unsupported MANYTYPE_MACOS_CONFIGURATION: $CONFIGURATION" >&2
    exit 64
    ;;
esac

(
  cd "$APP_DIR"
  flutter build macos \
    "--$flutter_mode" \
    --config-only \
    --target "$FLUTTER_TARGET"
)

declare -a xcode_arguments=(
  -quiet
  -workspace macos/Runner.xcworkspace
  -scheme Runner
  -configuration "$CONFIGURATION"
  -derivedDataPath build/macos
)
if [[ -n "${MANYTYPE_MACOS_BUNDLE_IDENTIFIER:-}" ]]; then
  xcode_arguments+=(
    "MANYTYPE_PRODUCT_BUNDLE_IDENTIFIER=$MANYTYPE_MACOS_BUNDLE_IDENTIFIER"
  )
fi
case "$SIGNING_MODE" in
  adhoc)
    xcode_arguments+=(
      "CODE_SIGN_STYLE=Manual"
      "CODE_SIGN_IDENTITY=-"
      "DEVELOPMENT_TEAM="
      "MANYTYPE_ENTITLEMENTS_FILE=$adhoc_entitlements"
    )
    ;;
  development)
    if [[ -z "${MANYTYPE_DEVELOPMENT_TEAM:-}" ]]; then
      echo "MANYTYPE_DEVELOPMENT_TEAM is required for development signing" >&2
      exit 64
    fi
    xcode_arguments+=(
      "CODE_SIGN_STYLE=Automatic"
      "CODE_SIGN_IDENTITY=${MANYTYPE_CODE_SIGN_IDENTITY:-Apple Development}"
      "DEVELOPMENT_TEAM=$MANYTYPE_DEVELOPMENT_TEAM"
      "MANYTYPE_ENTITLEMENTS_FILE=$signed_entitlements"
    )
    if [[ "${MANYTYPE_ALLOW_PROVISIONING_UPDATES:-0}" == "1" ]]; then
      xcode_arguments+=(-allowProvisioningUpdates)
    fi
    ;;
  *)
    echo "unsupported MANYTYPE_MACOS_SIGNING_MODE: $SIGNING_MODE" >&2
    exit 64
    ;;
esac

(
  cd "$APP_DIR"
  xcodebuild "${xcode_arguments[@]}" build
)

echo "$APP_DIR/build/macos/Build/Products/$CONFIGURATION/manytype.app"
