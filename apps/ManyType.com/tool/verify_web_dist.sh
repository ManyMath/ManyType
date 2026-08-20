#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
site_root="$(cd "$script_dir/.." && pwd)"
dist_dir="${1:-$site_root/build/dist}"
server_log="${TMPDIR:-/tmp}/manytype-web-smoke-$$.log"
download_dir="${TMPDIR:-/tmp}/manytype-web-smoke-$$"
server_pid=""

cleanup() {
  if [[ -n "$server_pid" ]]; then
    kill "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
  fi
  rm -rf "$download_dir" "$server_log"
}
trap cleanup EXIT

for command in curl python3; do
  command -v "$command" >/dev/null 2>&1 || {
    echo "$command is required to verify the ManyType.com distribution" >&2
    exit 1
  }
done

port="${MANYTYPE_SMOKE_PORT:-$(python3 -c '
import socket

with socket.socket() as server:
    server.bind(("127.0.0.1", 0))
    print(server.getsockname()[1])
')}"

required_files=(
  index.html
  404.html
  assets/site.css
  assets/brand/marks/manytype.svg
  assets/brand/og.png
  assets/hero.png
  home/index.html
  home/flutter_bootstrap.js
  home/main.dart.js
  home/sqlite3.wasm
  home/drift_worker.dart.js
)
for relative_path in "${required_files[@]}"; do
  test -s "$dist_dir/$relative_path" || {
    echo "missing distribution artifact: $dist_dir/$relative_path" >&2
    exit 1
  }
done

grep -Fq '<meta name="robots" content="noindex">' "$dist_dir/404.html" || {
  echo "distribution 404 page must be excluded from indexing" >&2
  exit 1
}
if cmp -s "$dist_dir/404.html" "$dist_dir/index.html"; then
  echo "distribution 404 page must not be the site entry point" >&2
  exit 1
fi

grep -Fq '<base href="/home/">' "$dist_dir/home/index.html" || {
  echo "composed app does not have the required /home/ base href" >&2
  exit 1
}
if [[ -s "$dist_dir/home/flutter_service_worker.js" ]]; then
  echo "composed app unexpectedly contains an active service worker" >&2
  exit 1
fi

for url in \
  'https://manymath.com/' \
  'https://manymatrix.com/' \
  'https://manykee.com/' \
  'https://manytier.com/'; do
  grep -Fq "href=\"$url\"" "$dist_dir/index.html" || {
    echo "landing page is missing ecosystem link: $url" >&2
    exit 1
  }
done

mkdir -p "$download_dir"
python3 -m http.server "$port" \
  --bind 127.0.0.1 \
  --directory "$dist_dir" >"$server_log" 2>&1 &
server_pid=$!

for _ in $(seq 1 50); do
  if curl --fail --silent --show-error "http://127.0.0.1:$port/" \
    --output "$download_dir/site.html" 2>/dev/null; then
    break
  fi
  sleep 0.1
done
if ! kill -0 "$server_pid" 2>/dev/null; then
  cat "$server_log" >&2
  echo "ManyType.com distribution server failed to start" >&2
  exit 1
fi

curl --fail --silent --show-error "http://127.0.0.1:$port/home/" \
  --output "$download_dir/app.html"
curl --fail --silent --show-error "http://127.0.0.1:$port/assets/site.css" \
  --output "$download_dir/styles.css"
curl --fail --silent --show-error "http://127.0.0.1:$port/assets/brand/marks/manytype.svg" \
  --output "$download_dir/manytype-mark.svg"
curl --fail --silent --show-error "http://127.0.0.1:$port/assets/hero.png" \
  --output "$download_dir/manytype-workspace.png"
curl --fail --silent --show-error "http://127.0.0.1:$port/home/main.dart.js" \
  --output "$download_dir/main.dart.js"
curl --fail --silent --show-error \
  --dump-header "$download_dir/wasm.headers" \
  "http://127.0.0.1:$port/home/sqlite3.wasm" \
  --output "$download_dir/sqlite3.wasm"
curl --fail --silent --show-error "http://127.0.0.1:$port/home/drift_worker.dart.js" \
  --output "$download_dir/drift_worker.dart.js"

grep -Fq 'id="hero-title"' "$download_dir/site.html"
grep -Fq '<base href="/home/">' "$download_dir/app.html"
if grep -Eiq '<!doctype html|<html' "$download_dir/styles.css"; then
  echo "/assets/site.css returned HTML" >&2
  exit 1
fi
if ! grep -Fq '<svg' "$download_dir/manytype-mark.svg"; then
  echo "/assets/brand/marks/manytype.svg is not an SVG image" >&2
  exit 1
fi
preview_magic="$(od -An -tx1 -N8 "$download_dir/manytype-workspace.png" | tr -d '[:space:]')"
if [[ "$preview_magic" != "89504e470d0a1a0a" ]]; then
  echo "/assets/hero.png is not a valid PNG image" >&2
  exit 1
fi
for javascript in main.dart.js drift_worker.dart.js; do
  if grep -Eiq '<!doctype html|<html' "$download_dir/$javascript"; then
    echo "/home/$javascript returned HTML" >&2
    exit 1
  fi
done
sqlite_magic="$(od -An -tx1 -N4 "$download_dir/sqlite3.wasm" | tr -d '[:space:]')"
if [[ "$sqlite_magic" != "0061736d" ]]; then
  echo "/home/sqlite3.wasm is not a valid WebAssembly binary" >&2
  exit 1
fi
grep -Eiq '^Content-Type: application/wasm([[:space:]]*;|[[:space:]]*$)' \
  "$download_dir/wasm.headers" || {
  echo "served SQLite WebAssembly does not use the application/wasm content type" >&2
  exit 1
}

for missing_path in home/missing.js home/missing.wasm; do
  status="$({ curl --silent --show-error \
    --output "$download_dir/missing" \
    --write-out '%{http_code}' \
    "http://127.0.0.1:$port/$missing_path"; } || true)"
  if [[ "$status" != "404" ]]; then
    echo "/$missing_path returned $status instead of 404" >&2
    exit 1
  fi
  if cmp -s "$download_dir/missing" "$download_dir/site.html" || \
    cmp -s "$download_dir/missing" "$download_dir/app.html"; then
    echo "/$missing_path fell back to an application entry point" >&2
    exit 1
  fi
done

echo "Verified ManyType.com at / and the ManyType app at /home/."
