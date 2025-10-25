#!/bin/bash
set -e

echo "=== Manytype Round-Trip Test ==="
echo ""

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# Build FFI library
echo "Building FFI library..."
cd rust && cargo build -p manytype_quic_ffi --release && cd ..

# Start server in background
echo "Starting server..."
cd rust && cargo run -p manytype_server --release -- test_config.toml &
SERVER_PID=$!
cd ..
sleep 2

# Set up temp home
export MANYTYPE_HOME=$(mktemp -d)
export HOME=$MANYTYPE_HOME
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:$(pwd)/rust/target/release"

cleanup() {
  kill $SERVER_PID 2>/dev/null || true
  rm -rf "$MANYTYPE_HOME"
}
trap cleanup EXIT

# Run round-trip
echo ""
echo "Step 1: Initialize"
dart run packages/manytype_cli/bin/manytype.dart init

echo ""
echo "Step 2: Create"
dart run packages/manytype_cli/bin/manytype.dart create "Hello from manytype"

echo ""
echo "Step 3: Sync"
dart run packages/manytype_cli/bin/manytype.dart sync

echo ""
echo "Step 4: Read"
dart run packages/manytype_cli/bin/manytype.dart read

echo ""
echo "=== Round-trip complete ==="
