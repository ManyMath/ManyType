use std::fs::File;
use std::io::Write;
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
        // Keep an intact copy, but rewrite one left short or corrupt by a crash.
        let intact = std::fs::metadata(&path).is_ok_and(|metadata| {
            metadata.len() == data.len() as u64
                && std::fs::read(&path).is_ok_and(|existing| existing == data)
        });
        if intact {
            return Ok(());
        }

        let parent = path
            .parent()
            .ok_or_else(|| anyhow::anyhow!("blob path has no parent directory"))?;
        std::fs::create_dir_all(parent)?;

        let nonce = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_nanos();
        let tmp_path = path.with_extension(format!("tmp-{nonce}"));
        let result = (|| -> Result<()> {
            let mut file = File::create(&tmp_path)?;
            file.write_all(data)?;
            file.sync_all()?;
            std::fs::rename(&tmp_path, &path)?;
            sync_dir(parent)
        })();
        if result.is_err() {
            let _ = std::fs::remove_file(&tmp_path);
        }
        result
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

// The index commits durably, so the blob and its directory entry must be on
// disk before `put` returns.
#[cfg(unix)]
fn sync_dir(path: &Path) -> Result<()> {
    File::open(path)?.sync_all()?;
    Ok(())
}

#[cfg(not(unix))]
fn sync_dir(_path: &Path) -> Result<()> {
    Ok(())
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

    #[test]
    fn blob_store_put_repairs_a_damaged_blob() {
        let temp_dir = TempDir::new().unwrap();
        let store = BlobStore::open(temp_dir.path().join("manytype.redb")).unwrap();
        store.put("bafy-test-cid", b"hello").unwrap();

        std::fs::write(store.blob_path("bafy-test-cid"), b"he").unwrap();
        store.put("bafy-test-cid", b"hello").unwrap();
        assert_eq!(store.get("bafy-test-cid").unwrap(), Some(b"hello".to_vec()));

        std::fs::write(store.blob_path("bafy-test-cid"), b"\0\0\0\0\0").unwrap();
        store.put("bafy-test-cid", b"hello").unwrap();
        assert_eq!(store.get("bafy-test-cid").unwrap(), Some(b"hello".to_vec()));

        let blob_path = store.blob_path("bafy-test-cid");
        let leftovers: Vec<_> = std::fs::read_dir(blob_path.parent().unwrap())
            .unwrap()
            .map(|entry| entry.unwrap().file_name())
            .collect();
        assert_eq!(
            leftovers,
            vec![std::ffi::OsString::from("bafy-test-cid.blob")]
        );
    }
}
