//! RedbTreeStorage: persistent TreeStorage backed by redb.
//!
//! Uses two tables:
//! - "changes": maps CID string -> raw change bytes
//! - "heads": stores current head CIDs as JSON array under key "heads"

use std::path::Path;

use anyhow::Result;
use redb::{Database, ReadableDatabase, TableDefinition};

use manytype_core::crdt::storage::TreeStorage;

const CHANGES_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("changes");
const HEADS_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("heads");

/// Persistent tree storage backed by a redb database file.
pub struct RedbTreeStorage {
    db: Database,
}

impl RedbTreeStorage {
    /// Open or create a redb database at the given path.
    pub fn open(path: &Path) -> Result<Self> {
        let db = Database::create(path)?;

        // Ensure tables exist by opening a write transaction
        let write_txn = db.begin_write()?;
        {
            let _changes = write_txn.open_table(CHANGES_TABLE)?;
            let _heads = write_txn.open_table(HEADS_TABLE)?;
        }
        write_txn.commit()?;

        Ok(Self { db })
    }
}

impl TreeStorage for RedbTreeStorage {
    fn add_raw_change(&mut self, id: String, raw: Vec<u8>) -> Result<()> {
        let write_txn = self.db.begin_write()?;
        {
            let mut table = write_txn.open_table(CHANGES_TABLE)?;
            table.insert(id.as_str(), raw.as_slice())?;
        }
        write_txn.commit()?;
        Ok(())
    }

    fn get_raw_change(&self, id: &str) -> Result<Option<Vec<u8>>> {
        let read_txn = self.db.begin_read()?;
        let table = read_txn.open_table(CHANGES_TABLE)?;
        match table.get(id)? {
            Some(value) => Ok(Some(value.value().to_vec())),
            None => Ok(None),
        }
    }

    fn has_change(&self, id: &str) -> bool {
        let Ok(read_txn) = self.db.begin_read() else {
            return false;
        };
        let Ok(table) = read_txn.open_table(CHANGES_TABLE) else {
            return false;
        };
        matches!(table.get(id), Ok(Some(_)))
    }

    fn get_heads(&self) -> Vec<String> {
        let Ok(read_txn) = self.db.begin_read() else {
            return Vec::new();
        };
        let Ok(table) = read_txn.open_table(HEADS_TABLE) else {
            return Vec::new();
        };
        match table.get("heads") {
            Ok(Some(value)) => {
                serde_json::from_slice(value.value()).unwrap_or_default()
            }
            _ => Vec::new(),
        }
    }

    fn set_heads(&mut self, heads: Vec<String>) {
        let Ok(write_txn) = self.db.begin_write() else {
            return;
        };
        let result = (|| -> Result<()> {
            let mut table = write_txn.open_table(HEADS_TABLE)?;
            let json = serde_json::to_vec(&heads)?;
            table.insert("heads", json.as_slice())?;
            Ok(())
        })();
        if result.is_ok() {
            let _ = write_txn.commit();
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::NamedTempFile;

    fn temp_storage() -> (RedbTreeStorage, NamedTempFile) {
        let tmp = NamedTempFile::new().unwrap();
        let storage = RedbTreeStorage::open(tmp.path()).unwrap();
        (storage, tmp)
    }

    #[test]
    fn add_and_get_raw_change_round_trips() {
        let (mut storage, _tmp) = temp_storage();
        let data = vec![1, 2, 3];
        storage.add_raw_change("cid1".to_string(), data.clone()).unwrap();
        let retrieved = storage.get_raw_change("cid1").unwrap().unwrap();
        assert_eq!(retrieved, data);
    }

    #[test]
    fn has_change_returns_false_before_add_true_after() {
        let (mut storage, _tmp) = temp_storage();
        assert!(!storage.has_change("cid1"));
        storage.add_raw_change("cid1".to_string(), vec![42]).unwrap();
        assert!(storage.has_change("cid1"));
    }

    #[test]
    fn set_and_get_heads() {
        let (mut storage, _tmp) = temp_storage();
        assert!(storage.get_heads().is_empty());
        storage.set_heads(vec!["h1".to_string(), "h2".to_string()]);
        assert_eq!(storage.get_heads(), vec!["h1".to_string(), "h2".to_string()]);
    }

    #[test]
    fn data_persists_across_reopen() {
        let tmp = NamedTempFile::new().unwrap();
        let path = tmp.path().to_path_buf();

        // Write data
        {
            let mut storage = RedbTreeStorage::open(&path).unwrap();
            storage.add_raw_change("cid1".to_string(), vec![10, 20, 30]).unwrap();
            storage.set_heads(vec!["h1".to_string()]);
        }

        // Reopen and verify
        {
            let storage = RedbTreeStorage::open(&path).unwrap();
            let retrieved = storage.get_raw_change("cid1").unwrap().unwrap();
            assert_eq!(retrieved, vec![10, 20, 30]);
            assert_eq!(storage.get_heads(), vec!["h1".to_string()]);
        }
    }

    #[test]
    fn get_raw_change_returns_none_for_unknown() {
        let (storage, _tmp) = temp_storage();
        assert!(storage.get_raw_change("nonexistent").unwrap().is_none());
    }

    #[test]
    fn object_tree_with_redb_storage() {
        use manytype_core::crdt::cid::compute_cid;
        use manytype_core::crdt::object_tree::ObjectTree;
        use manytype_core::crypto::ed25519;
        use manytype_proto::treechange::{RawTreeChange, RawTreeChangeWithId, RootChange, TreeChange};
        use prost::Message;

        let (storage, _tmp) = temp_storage();
        let mut tree = ObjectTree::new(storage);

        let sk = ed25519::signing_key_from_seed(&[1u8; 32]);
        let vk = ed25519::verifying_key(&sk);

        // Create root change
        let root = RootChange {
            acl_head_id: "acl-head-1".to_string(),
            space_id: "space-1".to_string(),
            change_type: "test".to_string(),
            timestamp: 1000,
            seed: b"seed123".to_vec(),
            identity: vk.to_bytes().to_vec(),
            change_payload: vec![],
            is_derived: false,
        };
        let payload = root.encode_to_vec();
        let sig = ed25519::sign(&sk, &payload);
        let raw = RawTreeChange {
            payload,
            signature: sig.to_bytes().to_vec(),
        };
        let raw_bytes = raw.encode_to_vec();
        let cid = compute_cid(&raw_bytes);
        let root_rwi = RawTreeChangeWithId {
            raw_change: raw_bytes,
            id: cid.clone(),
        };

        tree.add_root(&root_rwi).unwrap();
        assert_eq!(tree.heads(), vec![cid.clone()]);

        // Create tree change referencing root
        let tc = TreeChange {
            tree_head_ids: vec![cid.clone()],
            acl_head_id: "acl-head-1".to_string(),
            snapshot_base_id: cid.clone(),
            changes_data: b"some-data".to_vec(),
            read_key_id: String::new(),
            timestamp: 2000,
            identity: vk.to_bytes().to_vec(),
            is_snapshot: false,
            data_type: String::new(),
        };
        let payload = tc.encode_to_vec();
        let sig = ed25519::sign(&sk, &payload);
        let raw = RawTreeChange {
            payload,
            signature: sig.to_bytes().to_vec(),
        };
        let raw_bytes = raw.encode_to_vec();
        let tc_cid = compute_cid(&raw_bytes);
        let tc_rwi = RawTreeChangeWithId {
            raw_change: raw_bytes,
            id: tc_cid.clone(),
        };

        tree.add_change(&tc_rwi).unwrap();
        assert_eq!(tree.heads(), vec![tc_cid]);
    }
}
