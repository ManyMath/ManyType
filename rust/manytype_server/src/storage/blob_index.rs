use std::path::Path;

use anyhow::{Result, bail};
use redb::{Database, ReadableDatabase, ReadableTable, TableDefinition};
use serde::{Deserialize, Serialize};

use super::blob_store::file_node_root_from_config;

const BLOBS_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("blobs");
const SPACE_CIDS_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("space_cids");
const FILE_CIDS_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("file_cids");
const SPACE_USAGE_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("space_usage");
const GLOBAL_USAGE_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("global_usage");
const PUBLIC_INVITES_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("public_invites");
const GLOBAL_TOTALS_KEY: &str = "totals";

#[derive(Clone, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct BlobMetadata {
    pub size_bytes: u64,
}

#[derive(Clone, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct SpaceCidBinding {
    pub file_ids: Vec<String>,
}

#[derive(Clone, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct FileCidBinding {
    pub cids: Vec<String>,
    pub usage_bytes: u64,
}

#[derive(Clone, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct SpaceUsage {
    pub usage_bytes: u64,
    pub cids_count: u64,
    pub files_count: u64,
}

#[derive(Clone, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
pub struct GlobalUsage {
    pub total_usage_bytes: u64,
    pub total_cids_count: u64,
}

#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct BindOutcome {
    pub new_blob: bool,
    pub new_space_binding: bool,
    pub new_file_binding: bool,
}

pub struct BlobIndex {
    db: Database,
}

impl BlobIndex {
    pub fn open(config_path: impl AsRef<Path>) -> Result<Self> {
        let path = file_node_root_from_config(config_path.as_ref()).join("files.redb");
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent)?;
        }
        let db = Database::create(path)?;
        ensure_tables(&db)?;
        Ok(Self { db })
    }

    pub fn has_blob(&self, cid: &str) -> Result<bool> {
        Ok(self.get_blob_metadata(cid)?.is_some())
    }

    pub fn get_blob_metadata(&self, cid: &str) -> Result<Option<BlobMetadata>> {
        let read_txn = self.db.begin_read()?;
        let table = read_txn.open_table(BLOBS_TABLE)?;
        decode_optional(table.get(cid)?)
    }

    pub fn space_has_cid(&self, space_id: &str, cid: &str) -> Result<bool> {
        let read_txn = self.db.begin_read()?;
        let table = read_txn.open_table(SPACE_CIDS_TABLE)?;
        Ok(table.get(space_cid_key(space_id, cid).as_str())?.is_some())
    }

    pub fn get_file_binding(
        &self,
        space_id: &str,
        file_id: &str,
    ) -> Result<Option<FileCidBinding>> {
        let read_txn = self.db.begin_read()?;
        let table = read_txn.open_table(FILE_CIDS_TABLE)?;
        decode_optional(table.get(space_file_key(space_id, file_id).as_str())?)
    }

    pub fn get_space_usage(&self, space_id: &str) -> Result<SpaceUsage> {
        let read_txn = self.db.begin_read()?;
        let table = read_txn.open_table(SPACE_USAGE_TABLE)?;
        Ok(decode_optional(table.get(space_id)?)?.unwrap_or_default())
    }

    pub fn get_global_usage(&self) -> Result<GlobalUsage> {
        let read_txn = self.db.begin_read()?;
        let table = read_txn.open_table(GLOBAL_USAGE_TABLE)?;
        Ok(decode_optional(table.get(GLOBAL_TOTALS_KEY)?)?.unwrap_or_default())
    }

    pub fn mark_public_invite(&self, cid: &str) -> Result<()> {
        let write_txn = self.db.begin_write()?;
        {
            let mut table = write_txn.open_table(PUBLIC_INVITES_TABLE)?;
            table.insert(cid, b"1".as_slice())?;
        }
        write_txn.commit()?;
        Ok(())
    }

    pub fn is_public_invite(&self, cid: &str) -> Result<bool> {
        let read_txn = self.db.begin_read()?;
        let table = read_txn.open_table(PUBLIC_INVITES_TABLE)?;
        Ok(table.get(cid)?.is_some())
    }

    pub fn bind_blob(
        &self,
        space_id: &str,
        file_id: &str,
        cid: &str,
        size_bytes: u64,
    ) -> Result<BindOutcome> {
        let write_txn = self.db.begin_write()?;
        let outcome = (|| -> Result<BindOutcome> {
            let mut blobs_table = write_txn.open_table(BLOBS_TABLE)?;
            let mut space_cids_table = write_txn.open_table(SPACE_CIDS_TABLE)?;
            let mut file_cids_table = write_txn.open_table(FILE_CIDS_TABLE)?;
            let mut space_usage_table = write_txn.open_table(SPACE_USAGE_TABLE)?;
            let mut global_usage_table = write_txn.open_table(GLOBAL_USAGE_TABLE)?;

            let blob_metadata: Option<BlobMetadata> = decode_optional(blobs_table.get(cid)?)?;
            let mut outcome = BindOutcome::default();
            if let Some(existing) = &blob_metadata {
                if existing.size_bytes != size_bytes {
                    bail!(
                        "blob metadata mismatch for cid {cid}: existing size {} != {size_bytes}",
                        existing.size_bytes
                    );
                }
            } else {
                outcome.new_blob = true;
                blobs_table.insert(cid, encode_json(&BlobMetadata { size_bytes })?.as_slice())?;
            }

            let space_key = space_cid_key(space_id, cid);
            let mut space_binding: SpaceCidBinding =
                decode_optional(space_cids_table.get(space_key.as_str())?)?.unwrap_or_default();
            if !space_binding
                .file_ids
                .iter()
                .any(|existing| existing == file_id)
            {
                space_binding.file_ids.push(file_id.to_string());
                space_binding.file_ids.sort();
            }
            let new_space_binding = space_cids_table.get(space_key.as_str())?.is_none();
            if new_space_binding {
                outcome.new_space_binding = true;
            }
            space_cids_table.insert(space_key.as_str(), encode_json(&space_binding)?.as_slice())?;

            let file_key = space_file_key(space_id, file_id);
            let existing_file_binding: FileCidBinding =
                decode_optional(file_cids_table.get(file_key.as_str())?)?.unwrap_or_default();
            let mut file_binding = existing_file_binding.clone();
            let new_file_binding = existing_file_binding.cids.is_empty();
            if !file_binding.cids.iter().any(|existing| existing == cid) {
                file_binding.cids.push(cid.to_string());
                file_binding.cids.sort();
                file_binding.usage_bytes += size_bytes;
            }
            if new_file_binding {
                outcome.new_file_binding = true;
            }
            file_cids_table.insert(file_key.as_str(), encode_json(&file_binding)?.as_slice())?;

            let mut space_usage: SpaceUsage =
                decode_optional(space_usage_table.get(space_id)?)?.unwrap_or_default();
            if outcome.new_space_binding {
                space_usage.usage_bytes += size_bytes;
                space_usage.cids_count += 1;
            }
            if outcome.new_file_binding {
                space_usage.files_count += 1;
            }
            space_usage_table.insert(space_id, encode_json(&space_usage)?.as_slice())?;

            let mut global_usage: GlobalUsage =
                decode_optional(global_usage_table.get(GLOBAL_TOTALS_KEY)?)?.unwrap_or_default();
            if outcome.new_blob {
                global_usage.total_usage_bytes += size_bytes;
                global_usage.total_cids_count += 1;
                global_usage_table
                    .insert(GLOBAL_TOTALS_KEY, encode_json(&global_usage)?.as_slice())?;
            }

            Ok(outcome)
        })()?;
        write_txn.commit()?;
        Ok(outcome)
    }
}

fn ensure_tables(db: &Database) -> Result<()> {
    let write_txn = db.begin_write()?;
    {
        let _blobs = write_txn.open_table(BLOBS_TABLE)?;
        let _space_cids = write_txn.open_table(SPACE_CIDS_TABLE)?;
        let _file_cids = write_txn.open_table(FILE_CIDS_TABLE)?;
        let _space_usage = write_txn.open_table(SPACE_USAGE_TABLE)?;
        let _global_usage = write_txn.open_table(GLOBAL_USAGE_TABLE)?;
        let _public_invites = write_txn.open_table(PUBLIC_INVITES_TABLE)?;
    }
    write_txn.commit()?;
    Ok(())
}

fn encode_json<T: Serialize>(value: &T) -> Result<Vec<u8>> {
    Ok(serde_json::to_vec(value)?)
}

fn decode_optional<T: for<'de> Deserialize<'de>>(
    value: Option<redb::AccessGuard<'_, &[u8]>>,
) -> Result<Option<T>> {
    match value {
        Some(value) => Ok(Some(serde_json::from_slice(value.value())?)),
        None => Ok(None),
    }
}

fn space_cid_key(space_id: &str, cid: &str) -> String {
    format!("{space_id}\0{cid}")
}

fn space_file_key(space_id: &str, file_id: &str) -> String {
    format!("{space_id}\0{file_id}")
}

#[cfg(test)]
mod tests {
    use tempfile::TempDir;

    use super::*;

    #[test]
    fn blob_index_persists_bindings_and_usage_across_reopen() {
        let temp_dir = TempDir::new().unwrap();
        let config_path = temp_dir.path().join("manytype.redb");

        {
            let index = BlobIndex::open(&config_path).unwrap();
            let outcome = index.bind_blob("space-1", "file-1", "cid-1", 5).unwrap();
            assert!(outcome.new_blob);
            assert!(outcome.new_space_binding);
            assert!(outcome.new_file_binding);
        }

        let reopened = BlobIndex::open(&config_path).unwrap();
        assert!(reopened.has_blob("cid-1").unwrap());
        assert!(reopened.space_has_cid("space-1", "cid-1").unwrap());
        assert_eq!(
            reopened.get_space_usage("space-1").unwrap(),
            SpaceUsage {
                usage_bytes: 5,
                cids_count: 1,
                files_count: 1,
            }
        );
        assert_eq!(
            reopened.get_global_usage().unwrap(),
            GlobalUsage {
                total_usage_bytes: 5,
                total_cids_count: 1,
            }
        );
    }

    #[test]
    fn rebinding_same_cid_to_new_file_keeps_space_usage_flat() {
        let temp_dir = TempDir::new().unwrap();
        let index = BlobIndex::open(temp_dir.path().join("manytype.redb")).unwrap();

        index.bind_blob("space-1", "file-1", "cid-1", 5).unwrap();
        let outcome = index.bind_blob("space-1", "file-2", "cid-1", 5).unwrap();

        assert!(!outcome.new_blob);
        assert!(!outcome.new_space_binding);
        assert!(outcome.new_file_binding);
        assert_eq!(
            index.get_space_usage("space-1").unwrap(),
            SpaceUsage {
                usage_bytes: 5,
                cids_count: 1,
                files_count: 2,
            }
        );
        assert_eq!(
            index.get_global_usage().unwrap(),
            GlobalUsage {
                total_usage_bytes: 5,
                total_cids_count: 1,
            }
        );
        assert_eq!(
            index.get_file_binding("space-1", "file-2").unwrap(),
            Some(FileCidBinding {
                cids: vec!["cid-1".to_string()],
                usage_bytes: 5,
            })
        );
    }

    #[test]
    fn binding_existing_cid_into_new_space_sets_exists_not_in_space_state() {
        let temp_dir = TempDir::new().unwrap();
        let index = BlobIndex::open(temp_dir.path().join("manytype.redb")).unwrap();

        index.bind_blob("space-1", "file-1", "cid-1", 5).unwrap();
        assert!(!index.space_has_cid("space-2", "cid-1").unwrap());

        let outcome = index.bind_blob("space-2", "file-2", "cid-1", 5).unwrap();
        assert!(!outcome.new_blob);
        assert!(outcome.new_space_binding);
        assert!(outcome.new_file_binding);
        assert_eq!(
            index.get_global_usage().unwrap(),
            GlobalUsage {
                total_usage_bytes: 5,
                total_cids_count: 1,
            }
        );
        assert_eq!(
            index.get_space_usage("space-2").unwrap(),
            SpaceUsage {
                usage_bytes: 5,
                cids_count: 1,
                files_count: 1,
            }
        );
    }
}
