# Local Cargokit patches

`tool/cargokit/manifest.json` lists the ordered patches applied to the pinned
private fork revision when `tool/cargokit_sync.py` materializes
`packages/anytype_flutter/cargokit`:

- `01-windows-symlink-paths.patch`: resolve Flutter symlink paths before parent
  traversal and support the Windows PowerShell 5 `Target` property.
- `02-gradle-exec-operations.patch`: use injected `ExecOperations` instead of the
  removed `Project.exec`, for Gradle 9.
- `03-no-environment-dump.patch`: `build_pod.sh` no longer prints the complete
  caller environment, which can expose CI secrets. Build behavior is otherwise
  unchanged.
