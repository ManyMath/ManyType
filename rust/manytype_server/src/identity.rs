//! Persistent server identity management.

use std::fs::{File, OpenOptions};
use std::io::{ErrorKind, Read, Write};
use std::path::Path;

use anyhow::{Context, Result, ensure};
use rand::RngCore;

const IDENTITY_BYTES: usize = 32;

pub fn load_or_create(path: &Path) -> Result<[u8; IDENTITY_BYTES]> {
    if let Some(parent) = path.parent() {
        create_private_dir(parent)?;
    }

    match open_new_private(path) {
        Ok(mut file) => {
            let mut seed = [0u8; IDENTITY_BYTES];
            rand::rng().fill_bytes(&mut seed);
            file.write_all(&seed)
                .with_context(|| format!("failed to write identity {}", path.display()))?;
            file.sync_all()
                .with_context(|| format!("failed to sync identity {}", path.display()))?;
            Ok(seed)
        }
        Err(error) if error.kind() == ErrorKind::AlreadyExists => load_existing(path),
        Err(error) => {
            Err(error).with_context(|| format!("failed to create identity {}", path.display()))
        }
    }
}

fn load_existing(path: &Path) -> Result<[u8; IDENTITY_BYTES]> {
    ensure_private_file(path)?;
    let mut bytes = Vec::new();
    File::open(path)
        .with_context(|| format!("failed to open identity {}", path.display()))?
        .read_to_end(&mut bytes)
        .with_context(|| format!("failed to read identity {}", path.display()))?;
    bytes.try_into().map_err(|bytes: Vec<u8>| {
        anyhow::anyhow!(
            "identity {} must contain exactly {IDENTITY_BYTES} bytes, found {}",
            path.display(),
            bytes.len()
        )
    })
}

#[cfg(unix)]
fn create_private_dir(path: &Path) -> Result<()> {
    use std::os::unix::fs::DirBuilderExt;

    let mut builder = std::fs::DirBuilder::new();
    builder.recursive(true).mode(0o700);
    builder
        .create(path)
        .with_context(|| format!("failed to create private directory {}", path.display()))?;
    Ok(())
}

#[cfg(not(unix))]
fn create_private_dir(path: &Path) -> Result<()> {
    std::fs::create_dir_all(path)
        .with_context(|| format!("failed to create private directory {}", path.display()))
}

#[cfg(unix)]
fn open_new_private(path: &Path) -> std::io::Result<File> {
    use std::os::unix::fs::OpenOptionsExt;

    OpenOptions::new()
        .create_new(true)
        .write(true)
        .mode(0o600)
        .open(path)
}

#[cfg(not(unix))]
fn open_new_private(path: &Path) -> std::io::Result<File> {
    OpenOptions::new().create_new(true).write(true).open(path)
}

#[cfg(unix)]
fn ensure_private_file(path: &Path) -> Result<()> {
    use std::os::unix::fs::MetadataExt;

    let metadata = std::fs::symlink_metadata(path)?;
    ensure!(
        metadata.file_type().is_file(),
        "identity path is not a regular file"
    );
    ensure!(
        metadata.mode() & 0o077 == 0,
        "identity {} is accessible by group or other users",
        path.display()
    );
    Ok(())
}

#[cfg(not(unix))]
fn ensure_private_file(path: &Path) -> Result<()> {
    ensure!(path.is_file(), "identity path is not a regular file");
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    #[test]
    fn identity_is_generated_once_and_persisted() {
        let temp = TempDir::new().unwrap();
        let path = temp.path().join("state/identity.key");
        let first = load_or_create(&path).unwrap();
        let second = load_or_create(&path).unwrap();
        assert_eq!(first, second);
        assert_ne!(first, [0; 32]);
    }

    #[cfg(unix)]
    #[test]
    fn identity_rejects_permissions_accessible_to_other_users() {
        use std::os::unix::fs::PermissionsExt;

        let temp = TempDir::new().unwrap();
        let path = temp.path().join("identity.key");
        std::fs::write(&path, [7; 32]).unwrap();
        std::fs::set_permissions(&path, std::fs::Permissions::from_mode(0o644)).unwrap();
        assert!(
            load_or_create(&path)
                .unwrap_err()
                .to_string()
                .contains("accessible")
        );
    }

    #[test]
    fn identity_rejects_truncated_state() {
        let temp = TempDir::new().unwrap();
        let path = temp.path().join("identity.key");
        std::fs::write(&path, [7; 16]).unwrap();
        assert!(load_or_create(&path).is_err());
    }
}
