#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
site_root="$(cd "$script_dir/.." && pwd)"
repo_root="$(cd "$site_root/../.." && pwd)"
app_dir="$repo_root/apps/ManyType"
manyui_dir="$repo_root/../ManyUI/manyui"

command -v flutter >/dev/null 2>&1 || {
  echo "flutter is required to build ManyType" >&2
  exit 1
}
test -s "$manyui_dir/pubspec.yaml" || {
  echo "missing sibling ManyUI package: $manyui_dir" >&2
  echo "check out ManyUI beside ManyType before building" >&2
  exit 1
}
test -s "$app_dir/web/sqlite3.wasm" || {
  echo "missing ManyType web runtime: $app_dir/web/sqlite3.wasm" >&2
  exit 1
}
test -s "$app_dir/web/drift_worker.dart.js" || {
  echo "missing ManyType web runtime: $app_dir/web/drift_worker.dart.js" >&2
  exit 1
}

rm -rf "$app_dir/build/web"
(
  cd "$app_dir"
  flutter build web \
    --release \
    --base-href=/home/ \
    --pwa-strategy=none \
    --no-web-resources-cdn \
    --no-wasm-dry-run
)

"$script_dir/assemble_web_dist.sh"
