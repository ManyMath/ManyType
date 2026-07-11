#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
site_root="$(cd "$script_dir/.." && pwd)"
repo_root="$(cd "$site_root/../.." && pwd)"
site_dir="$site_root/site"
flutter_dir="$repo_root/apps/ManyType/build/web"
dist_dir="$site_root/build/dist"
staging_dir="$site_root/build/.dist-staging-$$"

cleanup() {
  rm -rf "$staging_dir"
}
trap cleanup EXIT

required_site_assets=(
  index.html
  404.html
  styles.css
  assets/manytype-mark.svg
  assets/manytype-workspace.png
)
for relative_path in "${required_site_assets[@]}"; do
  test -s "$site_dir/$relative_path" || {
    echo "missing site artifact: $site_dir/$relative_path" >&2
    exit 1
  }
done
if [[ -e "$site_dir/home" ]]; then
  echo "the site source may not contain a home path; /home/ is reserved for Flutter" >&2
  exit 1
fi

required_flutter_assets=(
  index.html
  flutter_bootstrap.js
  main.dart.js
  manifest.json
  sqlite3.wasm
  drift_worker.dart.js
)
for relative_path in "${required_flutter_assets[@]}"; do
  test -s "$flutter_dir/$relative_path" || {
    echo "missing Flutter artifact: $flutter_dir/$relative_path" >&2
    exit 1
  }
done

grep -Fq '<base href="/home/">' "$flutter_dir/index.html" || {
  echo "Flutter output does not have the required /home/ base href" >&2
  exit 1
}
if [[ -s "$flutter_dir/flutter_service_worker.js" ]]; then
  echo "Flutter output unexpectedly contains an active service worker" >&2
  exit 1
fi

sqlite_magic="$(od -An -tx1 -N4 "$flutter_dir/sqlite3.wasm" | tr -d '[:space:]')"
if [[ "$sqlite_magic" != "0061736d" ]]; then
  echo "sqlite3.wasm is not a valid WebAssembly binary" >&2
  exit 1
fi

rm -rf "$staging_dir"
mkdir -p "$staging_dir/home"
cp -R "$site_dir/." "$staging_dir/"
cp -R "$flutter_dir/." "$staging_dir/home/"

rm -rf "$dist_dir"
mv "$staging_dir" "$dist_dir"
trap - EXIT

echo "Assembled ManyType.com at $dist_dir"
