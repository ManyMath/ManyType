use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};

use anyhow::Result;

pub(crate) fn file_node_root_from_config(config_path: &Path) -> PathBuf {
    match config_path.extension().and_then(|ext| ext.to_str()) {
        Some("redb") => config_path.with_extension(""),
        _ => config_path.to_path_buf(),
    }
}

#[derive(Clone, Debug)]
pub struct BlobStore {
    blobs_dir: PathBuf,
}

impl BlobStore {
    pub fn open(config_path: impl AsRef<Path>) -> Result<Self> {
        let blobs_dir = file_node_root_from_config(config_path.as_ref()).join("blobs");
        std::fs::create_dir_all(&blobs_dir)?;
        Ok(Self { blobs_dir })
    }

    pub fn has(&self, cid: &str) -> bool {
        self.blob_path(cid).exists()
    }

    pub fn get(&self, cid: &str) -> Result<Option<Vec<u8>>> {
        let path = self.blob_path(cid);
        if !path.exists() {
            return Ok(None);
        }
        Ok(Some(std::fs::read(path)?))
    }

    pub fn put(&self, cid: &str, data: &[u8]) -> Result<()> {
        let path = self.blob_path(cid);
        if path.exists() {
            return Ok(());
        }

        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent)?;
        }

        let nonce = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_nanos();
        let tmp_path = path.with_extension(format!("tmp-{nonce}"));
        std::fs::write(&tmp_path, data)?;

        if path.exists() {
            let _ = std::fs::remove_file(&tmp_path);
            return Ok(());
        }

        std::fs::rename(&tmp_path, &path)?;
        Ok(())
    }

    pub fn remove(&self, cid: &str) -> Result<()> {
        let path = self.blob_path(cid);
        match std::fs::remove_file(path) {
            Ok(()) => Ok(()),
            Err(error) if error.kind() == std::io::ErrorKind::NotFound => Ok(()),
            Err(error) => Err(error.into()),
        }
    }

    pub fn blob_path(&self, cid: &str) -> PathBuf {
        let first = &cid[..cid.len().min(2)];
        let second = if cid.len() > 4 {
            &cid[2..4]
        } else if cid.len() > 2 {
            &cid[2..]
        } else {
            "root"
        };
        self.blobs_dir
            .join(first)
            .join(second)
            .join(format!("{cid}.blob"))
    }
}

#[cfg(test)]
mod tests {
    use tempfile::TempDir;

    use super::*;

    #[test]
    fn blob_store_persists_across_reopen() {
        let temp_dir = TempDir::new().unwrap();
        let config_path = temp_dir.path().join("manytype.redb");

        {
            let store = BlobStore::open(&config_path).unwrap();
            store.put("bafy-test-cid", b"hello").unwrap();
            assert!(store.has("bafy-test-cid"));
        }

        let reopened = BlobStore::open(&config_path).unwrap();
        assert_eq!(
            reopened.get("bafy-test-cid").unwrap(),
            Some(b"hello".to_vec())
        );
    }

    #[test]
    fn blob_store_put_is_idempotent() {
        let temp_dir = TempDir::new().unwrap();
        let store = BlobStore::open(temp_dir.path().join("manytype.redb")).unwrap();

        store.put("bafy-test-cid", b"hello").unwrap();
        store.put("bafy-test-cid", b"hello").unwrap();

        assert_eq!(store.get("bafy-test-cid").unwrap(), Some(b"hello".to_vec()));
    }
}
