//! Offline server locking, snapshot backup, and staged restore.

use std::fs::{File, OpenOptions};
use std::io::Write;
use std::path::Path;
use std::time::{SystemTime, UNIX_EPOCH};

use anyhow::{Context, Result, bail, ensure};
use fs2::FileExt;
use serde::{Deserialize, Serialize};

use crate::config::StoragePaths;
use crate::file_node::FileNodeState;
use crate::sync_node::SharedSyncState;

const SNAPSHOT_FORMAT_VERSION: u32 = 1;
const MANIFEST_FILE: &str = "manifest.json";

pub struct ServerLock {
    _file: File,
}

impl ServerLock {
    pub fn acquire(paths: &StoragePaths) -> Result<Self> {
        create_private_dir(&paths.data_dir)?;
        let file = open_private_lock(&paths.lock_file)?;
        file.try_lock_exclusive().with_context(|| {
            format!(
                "server data is in use; stop manytype_server before operating on {}",
                paths.data_dir.display()
            )
        })?;
        Ok(Self { _file: file })
    }
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct SnapshotManifest {
    format_version: u32,
    created_unix_seconds: u64,
    sync_directory: String,
    files_directory: String,
}

pub fn create_backup(paths: &StoragePaths, output: &Path) -> Result<()> {
    ensure_operational_layout(paths)?;
    let _lock = ServerLock::acquire(paths)?;
    ensure!(
        !output.starts_with(&paths.data_dir),
        "backup output must be outside the server data directory"
    );
    ensure!(!output.exists(), "backup output already exists");
    create_private_dir_exact(output)?;

    let result = (|| -> Result<()> {
        copy_tree(&paths.sync_root, &output.join("sync"))?;
        copy_tree(&paths.files_root, &output.join("files"))?;
        let manifest = SnapshotManifest {
            format_version: SNAPSHOT_FORMAT_VERSION,
            created_unix_seconds: unix_now(),
            sync_directory: "sync".to_string(),
            files_directory: "files".to_string(),
        };
        write_private(
            &output.join(MANIFEST_FILE),
            &serde_json::to_vec_pretty(&manifest)?,
        )?;
        Ok(())
    })();

    if result.is_err() {
        let _ = std::fs::remove_dir_all(output);
    }
    result
}

pub fn restore_backup(paths: &StoragePaths, input: &Path, force: bool) -> Result<()> {
    ensure!(force, "restore requires explicit --force confirmation");
    ensure_operational_layout(paths)?;
    let _lock = ServerLock::acquire(paths)?;
    let manifest: SnapshotManifest = serde_json::from_slice(
        &std::fs::read(input.join(MANIFEST_FILE)).context("snapshot manifest is missing")?,
    )
    .context("snapshot manifest is invalid")?;
    ensure!(
        manifest.format_version == SNAPSHOT_FORMAT_VERSION,
        "unsupported snapshot format version {}",
        manifest.format_version
    );
    ensure!(
        manifest.sync_directory == "sync" && manifest.files_directory == "files",
        "snapshot manifest contains unsafe directory names"
    );

    let nonce = format!("{}-{}", std::process::id(), unix_now());
    let staging = paths.data_dir.join(format!(".restore-staging-{nonce}"));
    let previous = paths.data_dir.join(format!(".restore-previous-{nonce}"));
    ensure!(
        !staging.exists() && !previous.exists(),
        "restore staging path exists"
    );
    create_private_dir_exact(&staging)?;

    let preflight_result = (|| -> Result<()> {
        copy_tree(&input.join("sync"), &staging.join("sync"))?;
        copy_tree(&input.join("files"), &staging.join("files"))?;

        require_snapshot_database(
            &staging.join("sync").join("global.redb"),
            "snapshot sync database",
        )?;
        require_snapshot_database(
            &staging.join("files").join("files.redb"),
            "snapshot file database",
        )?;

        // Opening both stores proves the snapshot matches the supported schemas
        // before any current data is moved.
        drop(SharedSyncState::open(staging.join("sync"))?);
        drop(FileNodeState::open(staging.join("files"))?);
        Ok(())
    })();

    if let Err(error) = preflight_result {
        let _ = std::fs::remove_dir_all(&staging);
        return Err(error);
    }

    create_private_dir_exact(&previous)?;
    swap_staged_restore(paths, &staging, &previous)
}

fn swap_staged_restore(paths: &StoragePaths, staging: &Path, previous: &Path) -> Result<()> {
    let mut saved_sync = false;
    let mut saved_files = false;
    let mut installed_sync = false;
    let mut installed_files = false;

    let swap_result = (|| -> Result<()> {
        saved_sync = move_if_present(&paths.sync_root, &previous.join("sync"))?;
        saved_files = move_if_present(&paths.files_root, &previous.join("files"))?;

        std::fs::rename(staging.join("sync"), &paths.sync_root)
            .context("failed to install restored sync data")?;
        installed_sync = true;
        std::fs::rename(staging.join("files"), &paths.files_root)
            .context("failed to install restored file data")?;
        installed_files = true;
        Ok(())
    })();

    if let Err(error) = swap_result {
        let rollback_result = rollback_restore(
            paths,
            previous,
            saved_sync,
            saved_files,
            installed_sync,
            installed_files,
        );
        if let Err(rollback_error) = rollback_result {
            return Err(anyhow::anyhow!(
                "restore failed: {error:#}; rollback also failed: {rollback_error:#}; recovery data remains at {} and {}",
                previous.display(),
                staging.display()
            ));
        }
        let _ = std::fs::remove_dir_all(staging);
        let _ = std::fs::remove_dir_all(previous);
        return Err(error).context("restore failed; previous data was reinstated");
    }

    std::fs::remove_dir_all(previous).context("failed to remove previous data after restore")?;
    let _ = std::fs::remove_dir_all(staging);
    Ok(())
}

fn rollback_restore(
    paths: &StoragePaths,
    previous: &Path,
    saved_sync: bool,
    saved_files: bool,
    installed_sync: bool,
    installed_files: bool,
) -> Result<()> {
    if installed_sync {
        std::fs::remove_dir_all(&paths.sync_root)
            .context("failed to remove partially restored sync data")?;
    }
    if installed_files {
        std::fs::remove_dir_all(&paths.files_root)
            .context("failed to remove partially restored file data")?;
    }
    if saved_sync {
        std::fs::rename(previous.join("sync"), &paths.sync_root)
            .context("failed to reinstate previous sync data")?;
    }
    if saved_files {
        std::fs::rename(previous.join("files"), &paths.files_root)
            .context("failed to reinstate previous file data")?;
    }
    Ok(())
}

fn ensure_operational_layout(paths: &StoragePaths) -> Result<()> {
    ensure!(
        paths.sync_root != paths.files_root,
        "backup and restore require the data_dir storage layout"
    );
    ensure!(
        paths.sync_root.starts_with(&paths.data_dir)
            && paths.files_root.starts_with(&paths.data_dir),
        "storage roots must be inside data_dir"
    );
    Ok(())
}

fn require_snapshot_database(path: &Path, label: &str) -> Result<()> {
    let metadata = std::fs::symlink_metadata(path)
        .with_context(|| format!("{label} is missing at {}", path.display()))?;
    ensure!(
        metadata.is_file() && !metadata.file_type().is_symlink(),
        "{label} is not a regular file"
    );
    Ok(())
}

fn move_if_present(source: &Path, destination: &Path) -> Result<bool> {
    if source.exists() {
        std::fs::rename(source, destination).with_context(|| {
            format!(
                "failed to move {} to {}",
                source.display(),
                destination.display()
            )
        })?;
        return Ok(true);
    }
    Ok(false)
}

fn copy_tree(source: &Path, destination: &Path) -> Result<()> {
    let metadata = std::fs::symlink_metadata(source)
        .with_context(|| format!("snapshot source {} is missing", source.display()))?;
    ensure!(metadata.is_dir(), "snapshot source is not a directory");
    ensure!(
        !metadata.file_type().is_symlink(),
        "snapshot source is a symlink"
    );
    create_private_dir_exact(destination)?;

    for entry in std::fs::read_dir(source)? {
        let entry = entry?;
        let source_path = entry.path();
        let destination_path = destination.join(entry.file_name());
        let metadata = std::fs::symlink_metadata(&source_path)?;
        ensure!(
            !metadata.file_type().is_symlink(),
            "snapshot trees must not contain symlinks"
        );
        if metadata.is_dir() {
            copy_tree(&source_path, &destination_path)?;
        } else if metadata.is_file() {
            std::fs::copy(&source_path, &destination_path).with_context(|| {
                format!(
                    "failed to copy {} to {}",
                    source_path.display(),
                    destination_path.display()
                )
            })?;
        } else {
            bail!("snapshot trees must contain only regular files and directories");
        }
    }
    Ok(())
}

fn write_private(path: &Path, contents: &[u8]) -> Result<()> {
    let mut file = open_new_private(path)?;
    file.write_all(contents)?;
    file.sync_all()?;
    Ok(())
}

#[cfg(unix)]
fn create_private_dir(path: &Path) -> Result<()> {
    use std::os::unix::fs::DirBuilderExt;

    let mut builder = std::fs::DirBuilder::new();
    builder.recursive(true).mode(0o700);
    builder.create(path)?;
    Ok(())
}

#[cfg(not(unix))]
fn create_private_dir(path: &Path) -> Result<()> {
    std::fs::create_dir_all(path)?;
    Ok(())
}

#[cfg(unix)]
fn create_private_dir_exact(path: &Path) -> Result<()> {
    use std::os::unix::fs::DirBuilderExt;

    let mut builder = std::fs::DirBuilder::new();
    builder.mode(0o700);
    builder.create(path)?;
    Ok(())
}

#[cfg(not(unix))]
fn create_private_dir_exact(path: &Path) -> Result<()> {
    std::fs::create_dir(path)?;
    Ok(())
}

#[cfg(unix)]
fn open_private_lock(path: &Path) -> Result<File> {
    use std::os::unix::fs::OpenOptionsExt;

    Ok(OpenOptions::new()
        .create(true)
        .read(true)
        .write(true)
        .truncate(false)
        .mode(0o600)
        .open(path)?)
}

#[cfg(not(unix))]
fn open_private_lock(path: &Path) -> Result<File> {
    Ok(OpenOptions::new()
        .create(true)
        .read(true)
        .write(true)
        .truncate(false)
        .open(path)?)
}

#[cfg(unix)]
fn open_new_private(path: &Path) -> Result<File> {
    use std::os::unix::fs::OpenOptionsExt;

    Ok(OpenOptions::new()
        .create_new(true)
        .write(true)
        .mode(0o600)
        .open(path)?)
}

#[cfg(not(unix))]
fn open_new_private(path: &Path) -> Result<File> {
    Ok(OpenOptions::new().create_new(true).write(true).open(path)?)
}

fn unix_now() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::storage::blob_index::BlobIndex;
    use crate::storage::blob_store::BlobStore;
    use tempfile::TempDir;

    fn paths(temp: &TempDir) -> StoragePaths {
        let data_dir = temp.path().join("data");
        StoragePaths {
            sync_root: data_dir.join("sync"),
            files_root: data_dir.join("files"),
            identity_file: data_dir.join("identity.key"),
            lock_file: data_dir.join("server.lock"),
            data_dir,
        }
    }

    #[test]
    fn snapshot_restore_reopens_semantic_state_and_blob_index() {
        let temp = TempDir::new().unwrap();
        let paths = paths(&temp);
        {
            let state = SharedSyncState::open(&paths.sync_root).unwrap();
            state.claim_space_owner("space-1", "peer-1").unwrap();
            state
                .upsert_space_metadata(
                    "space-1",
                    Some(b"header".to_vec()),
                    None,
                    None,
                    None,
                    None,
                    Some(false),
                    Some("peer-1".to_string()),
                )
                .unwrap();
            let blobs = BlobStore::open(&paths.files_root).unwrap();
            blobs.put("bafy-test-cid", b"blob payload").unwrap();
            let index = BlobIndex::open(&paths.files_root).unwrap();
            index
                .bind_blob("space-1", "file-1", "bafy-test-cid", 12)
                .unwrap();
        }

        let backup = temp.path().join("backup");
        create_backup(&paths, &backup).unwrap();
        std::fs::remove_dir_all(&paths.sync_root).unwrap();
        std::fs::remove_dir_all(&paths.files_root).unwrap();
        restore_backup(&paths, &backup, true).unwrap();

        let restored = SharedSyncState::open(&paths.sync_root).unwrap();
        restored.authorize_space("space-1", "peer-1").unwrap();
        assert_eq!(
            restored.read().unwrap()["space-1"].space_header.as_deref(),
            Some(b"header".as_slice())
        );
        let blobs = BlobStore::open(&paths.files_root).unwrap();
        assert_eq!(
            blobs.get("bafy-test-cid").unwrap().unwrap(),
            b"blob payload"
        );
        let index = BlobIndex::open(&paths.files_root).unwrap();
        assert_eq!(index.get_space_usage("space-1").unwrap().usage_bytes, 12);
    }

    #[test]
    fn backup_refuses_live_server_lock() {
        let temp = TempDir::new().unwrap();
        let paths = paths(&temp);
        std::fs::create_dir_all(&paths.sync_root).unwrap();
        std::fs::create_dir_all(&paths.files_root).unwrap();
        let _lock = ServerLock::acquire(&paths).unwrap();
        let error = create_backup(&paths, &temp.path().join("backup")).unwrap_err();
        assert!(error.to_string().contains("in use"));
    }

    #[test]
    fn restore_requires_force_before_touching_data() {
        let temp = TempDir::new().unwrap();
        let paths = paths(&temp);
        let error = restore_backup(&paths, &temp.path().join("missing"), false).unwrap_err();
        assert!(error.to_string().contains("--force"));
        assert!(!paths.sync_root.exists());
    }

    #[test]
    fn restore_rejects_empty_snapshot_without_replacing_live_data() {
        let temp = TempDir::new().unwrap();
        let paths = paths(&temp);
        let live = SharedSyncState::open(&paths.sync_root).unwrap();
        live.claim_space_owner("space-1", "peer-1").unwrap();
        drop(live);
        FileNodeState::open(&paths.files_root).unwrap();

        let backup = temp.path().join("empty-backup");
        std::fs::create_dir_all(backup.join("sync")).unwrap();
        std::fs::create_dir_all(backup.join("files")).unwrap();
        let manifest = SnapshotManifest {
            format_version: SNAPSHOT_FORMAT_VERSION,
            created_unix_seconds: unix_now(),
            sync_directory: "sync".to_string(),
            files_directory: "files".to_string(),
        };
        std::fs::write(
            backup.join(MANIFEST_FILE),
            serde_json::to_vec_pretty(&manifest).unwrap(),
        )
        .unwrap();

        let error = restore_backup(&paths, &backup, true).unwrap_err();

        assert!(
            error
                .to_string()
                .contains("snapshot sync database is missing")
        );
        let reopened = SharedSyncState::open(&paths.sync_root).unwrap();
        reopened.authorize_space("space-1", "peer-1").unwrap();
    }

    #[test]
    fn failed_install_reinstates_both_live_stores() {
        let temp = TempDir::new().unwrap();
        let paths = paths(&temp);
        let live = SharedSyncState::open(&paths.sync_root).unwrap();
        live.claim_space_owner("space-1", "peer-1").unwrap();
        drop(live);
        let blobs = BlobStore::open(&paths.files_root).unwrap();
        blobs.put("live-cid", b"live payload").unwrap();

        let staging = paths.data_dir.join("staging");
        let previous = paths.data_dir.join("previous");
        std::fs::create_dir_all(staging.join("sync")).unwrap();
        std::fs::write(staging.join("sync").join("sentinel"), b"new").unwrap();
        std::fs::create_dir_all(&previous).unwrap();

        let error = swap_staged_restore(&paths, &staging, &previous).unwrap_err();

        assert!(error.to_string().contains("previous data was reinstated"));
        let reopened = SharedSyncState::open(&paths.sync_root).unwrap();
        reopened.authorize_space("space-1", "peer-1").unwrap();
        let reopened_blobs = BlobStore::open(&paths.files_root).unwrap();
        assert_eq!(
            reopened_blobs.get("live-cid").unwrap(),
            Some(b"live payload".to_vec())
        );
        assert!(!staging.exists());
        assert!(!previous.exists());
    }

    #[cfg(unix)]
    #[test]
    fn backup_rejects_symlinks() {
        use std::os::unix::fs::symlink;

        let temp = TempDir::new().unwrap();
        let paths = paths(&temp);
        std::fs::create_dir_all(&paths.sync_root).unwrap();
        std::fs::create_dir_all(&paths.files_root).unwrap();
        symlink(temp.path(), paths.sync_root.join("escape")).unwrap();
        let error = create_backup(&paths, &temp.path().join("backup")).unwrap_err();
        assert!(error.to_string().contains("symlinks"));
    }
}
