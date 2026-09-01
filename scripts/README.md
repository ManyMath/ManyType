# Manytype Automation & Verification Scripts

This directory contains the scripts used for automated verification, artifact generation, and live environment probes.

## Environment Prerequisites

Running the scripts in this directory requires several external dependencies depending on the target task.

### 1. Docker & Docker Compose
**Required for:** 
- `scripts/oracle_capture.sh`: Drives multi-user ACL lifecycles against a local any-sync oracle stack.
- `scripts/phase25_capture_official_client_api.sh`: Orchestrates the official `anytype-cli` headless gRPC service.
- `docker/any-sync/`: Local deployment of any-sync node roles (consensus, coordinator, file, etc.).

Ensure Docker is installed and the daemon is running.

### 2. Production Network Access
**Required for:**
- `scripts/live_file_node_probe.sh`: Performs read-only protocol probes against live production Anytype nodes.

### 3. Python 3
**Required for:**
- `scripts/verify_file_artifacts.py`: Validates protocol-level evidence artifacts.
- `scripts/verify_nyquist_artifacts.py`: Validates general Nyquist protocol artifacts.

### 4. Dart & Rust Toolchains
**Required for:**
- The server and CLI must be built before some scripts can run successfully.

## Replaying vs. Regenerating

Artifacts are already checked into the `test_vectors/` directory. 
- **Verifiers** (Python scripts) only require the checked-in artifacts and can run offline. Absolute paths recorded in artifacts are mapped back onto the current checkout (`scripts/artifact_paths.py`). The exceptions are `verify_phase49_signoff.py` and `verify_phase53_signoff.py`, which also compare locally built `rust/target` binaries against the hashes recorded at sign-off.
- **Regenerators** (Shell scripts) are only needed if you are performing protocol-level research, updating contracts, or investigating regressions that require a fresh capture from a live or containerized environment.
