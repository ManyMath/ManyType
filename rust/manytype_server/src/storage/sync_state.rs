use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::sync::{Arc, LockResult, Mutex, RwLock, RwLockReadGuard, RwLockWriteGuard};
#[cfg(test)]
use std::time::{SystemTime, UNIX_EPOCH};

use anyhow::Result;
use manytype_proto::consensus::RawRecordWithId;
use manytype_proto::spacesync::StoreKeyValue;
use prost::Message;
use redb::{Database, ReadableDatabase, ReadableTable, TableDefinition};

const GLOBAL_SPACES_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("spaces");
const SPACE_META_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("meta");
const SPACE_HEADS_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("heads");
const SPACE_OBJECT_CHANGES_TABLE: TableDefinition<&str, &[u8]> =
    TableDefinition::new("object_changes");
const SPACE_CHANGES_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("changes");
const SPACE_STORE_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("store");
const SPACE_ACL_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("acl");

const META_SPACE_HEADER: &str = "space_header";
const META_ACL_ROOT: &str = "acl_root";
const META_ACL_ROOT_ID: &str = "acl_root_id";
const META_SETTINGS_PAYLOAD: &str = "settings_payload";
const META_SETTINGS_PAYLOAD_ID: &str = "settings_payload_id";
const META_IS_SHARED: &str = "is_shared";
const META_OWNER_PEER_ID: &str = "owner_peer_id";

#[derive(Clone, Debug, Default)]
pub struct SpaceState {
    pub object_heads: HashMap<String, Vec<String>>,
    pub object_changes: HashMap<String, Vec<String>>,
    pub raw_changes: HashMap<String, Vec<u8>>,
    pub space_header: Option<Vec<u8>>,
    pub acl_root: Option<Vec<u8>>,
    pub acl_root_id: String,
    pub acl_records: Vec<Vec<u8>>,
    pub acl_head: String,
    pub settings_payload: Option<Vec<u8>>,
    pub settings_payload_id: String,
    pub is_shared: bool,
    pub owner_peer_id: String,
    pub store_key_values: HashMap<String, Vec<u8>>,
}

#[derive(Clone)]
pub struct SharedSyncState {
    inner: Arc<RwLock<HashMap<String, SpaceState>>>,
    storage: Arc<SyncStateStorage>,
}

struct SyncStateStorage {
    global_db: Database,
    root_dir: PathBuf,
    persist_lock: Mutex<()>,
}

#[derive(Clone, Debug)]
struct StoragePaths {
    root_dir: PathBuf,
    global_db_path: PathBuf,
    spaces_dir: PathBuf,
}

impl StoragePaths {
    fn from_config(config_path: &Path) -> Self {
        let root_dir = match config_path.extension().and_then(|ext| ext.to_str()) {
            Some("redb") => config_path.with_extension(""),
            _ => config_path.to_path_buf(),
        };
        let spaces_dir = root_dir.join("spaces");
        let global_db_path = root_dir.join("global.redb");
        Self {
            root_dir,
            global_db_path,
            spaces_dir,
        }
    }

    fn space_db_path(&self, space_id: &str) -> PathBuf {
        self.spaces_dir.join(format!("{space_id}.redb"))
    }
}

impl SyncStateStorage {
    fn open(config_path: &Path) -> Result<Self> {
        let paths = StoragePaths::from_config(config_path);
        std::fs::create_dir_all(&paths.spaces_dir)?;
        let global_db = Database::create(&paths.global_db_path)?;
        ensure_table(&global_db, GLOBAL_SPACES_TABLE)?;
        Ok(Self {
            global_db,
            root_dir: paths.root_dir,
            persist_lock: Mutex::new(()),
        })
    }

    fn paths(&self) -> StoragePaths {
        StoragePaths::from_config(&self.root_dir)
    }

    fn load_spaces(&self) -> Result<HashMap<String, SpaceState>> {
        let read_txn = self.global_db.begin_read()?;
        let table = read_txn.open_table(GLOBAL_SPACES_TABLE)?;
        let mut spaces = HashMap::new();
        for entry in table.iter()?.flatten() {
            let space_id = entry.0.value().to_string();
            let state = self.load_space(&space_id)?;
            spaces.insert(space_id, state);
        }
        Ok(spaces)
    }

    fn ensure_space_registered_locked(&self, space_id: &str) -> Result<()> {
        let write_txn = self.global_db.begin_write()?;
        {
            let mut table = write_txn.open_table(GLOBAL_SPACES_TABLE)?;
            table.insert(space_id, b"1".as_slice())?;
        }
        write_txn.commit()?;
        let space_db = Database::create(self.paths().space_db_path(space_id))?;
        ensure_space_tables(&space_db)?;
        Ok(())
    }

    fn load_space(&self, space_id: &str) -> Result<SpaceState> {
        let space_db = Database::create(self.paths().space_db_path(space_id))?;
        ensure_space_tables(&space_db)?;

        let read_txn = space_db.begin_read()?;
        let meta_table = read_txn.open_table(SPACE_META_TABLE)?;
        let heads_table = read_txn.open_table(SPACE_HEADS_TABLE)?;
        let object_changes_table = read_txn.open_table(SPACE_OBJECT_CHANGES_TABLE)?;
        let changes_table = read_txn.open_table(SPACE_CHANGES_TABLE)?;
        let store_table = read_txn.open_table(SPACE_STORE_TABLE)?;
        let acl_table = read_txn.open_table(SPACE_ACL_TABLE)?;

        let space_header = meta_table
            .get(META_SPACE_HEADER)?
            .map(|value| value.value().to_vec());
        let acl_root = meta_table
            .get(META_ACL_ROOT)?
            .map(|value| value.value().to_vec());
        let acl_root_id = meta_table
            .get(META_ACL_ROOT_ID)?
            .map(|value| String::from_utf8_lossy(value.value()).into_owned())
            .unwrap_or_default();
        let settings_payload = meta_table
            .get(META_SETTINGS_PAYLOAD)?
            .map(|value| value.value().to_vec());
        let settings_payload_id = meta_table
            .get(META_SETTINGS_PAYLOAD_ID)?
            .map(|value| String::from_utf8_lossy(value.value()).into_owned())
            .unwrap_or_default();
        let is_shared = meta_table
            .get(META_IS_SHARED)?
            .map(|value| value.value() == b"1")
            .unwrap_or(false);
        let owner_peer_id = meta_table
            .get(META_OWNER_PEER_ID)?
            .map(|value| String::from_utf8_lossy(value.value()).into_owned())
            .unwrap_or_default();

        let mut object_heads = HashMap::new();
        for entry in heads_table.iter()?.flatten() {
            let object_id = entry.0.value().to_string();
            let heads: Vec<String> = serde_json::from_slice(entry.1.value())?;
            object_heads.insert(object_id, heads);
        }

        let mut object_changes = HashMap::new();
        for entry in object_changes_table.iter()?.flatten() {
            let object_id = entry.0.value().to_string();
            let changes: Vec<String> = serde_json::from_slice(entry.1.value())?;
            object_changes.insert(object_id, changes);
        }

        let mut raw_changes = HashMap::new();
        for entry in changes_table.iter()?.flatten() {
            raw_changes.insert(entry.0.value().to_string(), entry.1.value().to_vec());
        }

        let mut store_key_values = HashMap::new();
        for entry in store_table.iter()?.flatten() {
            store_key_values.insert(entry.0.value().to_string(), entry.1.value().to_vec());
        }

        let mut acl_records = Vec::new();
        for entry in acl_table.iter()?.flatten() {
            acl_records.push(entry.1.value().to_vec());
        }
        let acl_head = acl_records
            .last()
            .and_then(|encoded| decode_acl_record_id(encoded))
            .unwrap_or_default();

        Ok(SpaceState {
            object_heads,
            object_changes,
            raw_changes,
            space_header,
            acl_root,
            acl_root_id,
            acl_records,
            acl_head,
            settings_payload,
            settings_payload_id,
            is_shared,
            owner_peer_id,
            store_key_values,
        })
    }

    fn persist_space_metadata(
        &self,
        space_id: &str,
        space_header: Option<&[u8]>,
        acl_root: Option<&[u8]>,
        acl_root_id: Option<&str>,
        settings_payload: Option<&[u8]>,
        settings_payload_id: Option<&str>,
        is_shared: Option<bool>,
        owner_peer_id: Option<&str>,
    ) -> Result<()> {
        let _guard = self.persist_lock.lock().unwrap();
        self.ensure_space_registered_locked(space_id)?;
        let space_db = Database::create(self.paths().space_db_path(space_id))?;
        let write_txn = space_db.begin_write()?;
        {
            let mut table = write_txn.open_table(SPACE_META_TABLE)?;
            if let Some(space_header) = space_header {
                table.insert(META_SPACE_HEADER, space_header)?;
            }
            if let Some(acl_root) = acl_root {
                table.insert(META_ACL_ROOT, acl_root)?;
            }
            if let Some(acl_root_id) = acl_root_id {
                table.insert(META_ACL_ROOT_ID, acl_root_id.as_bytes())?;
            }
            if let Some(settings_payload) = settings_payload {
                table.insert(META_SETTINGS_PAYLOAD, settings_payload)?;
            }
            if let Some(settings_payload_id) = settings_payload_id {
                table.insert(META_SETTINGS_PAYLOAD_ID, settings_payload_id.as_bytes())?;
            }
            if let Some(is_shared) = is_shared {
                table.insert(
                    META_IS_SHARED,
                    if is_shared { &b"1"[..] } else { &b"0"[..] },
                )?;
            }
            if let Some(owner_peer_id) = owner_peer_id {
                table.insert(META_OWNER_PEER_ID, owner_peer_id.as_bytes())?;
            }
        }
        write_txn.commit()?;
        Ok(())
    }

    fn persist_acl_record(
        &self,
        space_id: &str,
        index: usize,
        raw_record_with_id: &[u8],
    ) -> Result<()> {
        let _guard = self.persist_lock.lock().unwrap();
        self.ensure_space_registered_locked(space_id)?;
        let space_db = Database::create(self.paths().space_db_path(space_id))?;
        let write_txn = space_db.begin_write()?;
        {
            let mut table = write_txn.open_table(SPACE_ACL_TABLE)?;
            let key = format!("{index:018}");
            table.insert(key.as_str(), raw_record_with_id)?;
        }
        write_txn.commit()?;
        Ok(())
    }

    fn persist_object_state(
        &self,
        space_id: &str,
        object_id: &str,
        object_heads: &[String],
        object_changes: &[String],
        raw_change_id: Option<&str>,
        raw_change: Option<&[u8]>,
    ) -> Result<()> {
        let _guard = self.persist_lock.lock().unwrap();
        self.ensure_space_registered_locked(space_id)?;
        let space_db = Database::create(self.paths().space_db_path(space_id))?;
        let write_txn = space_db.begin_write()?;
        {
            let mut heads_table = write_txn.open_table(SPACE_HEADS_TABLE)?;
            heads_table.insert(object_id, serde_json::to_vec(object_heads)?.as_slice())?;

            let mut object_changes_table = write_txn.open_table(SPACE_OBJECT_CHANGES_TABLE)?;
            object_changes_table
                .insert(object_id, serde_json::to_vec(object_changes)?.as_slice())?;

            if let (Some(raw_change_id), Some(raw_change)) = (raw_change_id, raw_change) {
                let mut changes_table = write_txn.open_table(SPACE_CHANGES_TABLE)?;
                changes_table.insert(raw_change_id, raw_change)?;
            }
        }
        write_txn.commit()?;
        Ok(())
    }

    fn persist_store_key_value(
        &self,
        space_id: &str,
        key_peer_id: &str,
        value: &[u8],
    ) -> Result<()> {
        let _guard = self.persist_lock.lock().unwrap();
        self.ensure_space_registered_locked(space_id)?;
        let space_db = Database::create(self.paths().space_db_path(space_id))?;
        let write_txn = space_db.begin_write()?;
        {
            let mut table = write_txn.open_table(SPACE_STORE_TABLE)?;
            table.insert(key_peer_id, value)?;
        }
        write_txn.commit()?;
        Ok(())
    }
}

impl SharedSyncState {
    pub fn open(config_path: impl AsRef<Path>) -> Result<Self> {
        let storage = Arc::new(SyncStateStorage::open(config_path.as_ref())?);
        let spaces = storage.load_spaces()?;
        Ok(Self {
            inner: Arc::new(RwLock::new(spaces)),
            storage,
        })
    }

    pub fn read(&self) -> LockResult<RwLockReadGuard<'_, HashMap<String, SpaceState>>> {
        self.inner.read()
    }

    pub fn write(&self) -> LockResult<RwLockWriteGuard<'_, HashMap<String, SpaceState>>> {
        self.inner.write()
    }

    pub fn upsert_space_metadata(
        &self,
        space_id: &str,
        space_header: Option<Vec<u8>>,
        acl_root: Option<Vec<u8>>,
        acl_root_id: Option<String>,
        settings_payload: Option<Vec<u8>>,
        settings_payload_id: Option<String>,
        is_shared: Option<bool>,
        owner_peer_id: Option<String>,
    ) -> Result<()> {
        {
            let mut state = self.inner.write().unwrap();
            let space = state.entry(space_id.to_string()).or_default();
            if let Some(space_header) = space_header.clone() {
                space.space_header = Some(space_header);
            }
            if let Some(acl_root) = acl_root.clone() {
                space.acl_root = Some(acl_root);
            }
            if let Some(acl_root_id) = acl_root_id.clone() {
                space.acl_root_id = acl_root_id;
            }
            if let Some(settings_payload) = settings_payload.clone() {
                space.settings_payload = Some(settings_payload);
            }
            if let Some(settings_payload_id) = settings_payload_id.clone() {
                space.settings_payload_id = settings_payload_id;
            }
            if let Some(is_shared) = is_shared {
                space.is_shared = is_shared;
            }
            if let Some(owner_peer_id) = owner_peer_id.clone() {
                space.owner_peer_id = owner_peer_id;
            }
        }

        self.storage.persist_space_metadata(
            space_id,
            space_header.as_deref(),
            acl_root.as_deref(),
            acl_root_id.as_deref(),
            settings_payload.as_deref(),
            settings_payload_id.as_deref(),
            is_shared,
            owner_peer_id.as_deref(),
        )
    }

    pub fn mark_space_shared(&self, space_id: &str) -> Result<()> {
        let (
            space_header,
            acl_root,
            acl_root_id,
            settings_payload,
            settings_payload_id,
            owner_peer_id,
        ) = {
            let mut state = self.inner.write().unwrap();
            let Some(space) = state.get_mut(space_id) else {
                anyhow::bail!("space not found: {space_id}");
            };
            space.is_shared = true;
            (
                space.space_header.clone(),
                space.acl_root.clone(),
                (!space.acl_root_id.is_empty()).then(|| space.acl_root_id.clone()),
                space.settings_payload.clone(),
                (!space.settings_payload_id.is_empty()).then(|| space.settings_payload_id.clone()),
                (!space.owner_peer_id.is_empty()).then(|| space.owner_peer_id.clone()),
            )
        };

        self.storage.persist_space_metadata(
            space_id,
            space_header.as_deref(),
            acl_root.as_deref(),
            acl_root_id.as_deref(),
            settings_payload.as_deref(),
            settings_payload_id.as_deref(),
            Some(true),
            owner_peer_id.as_deref(),
        )
    }

    pub fn peer_owns_space(&self, space_id: &str, peer_id_hex: &str) -> bool {
        let state = self.inner.read().unwrap();
        let Some(space) = state.get(space_id) else {
            return false;
        };
        space.owner_peer_id.is_empty() || space.owner_peer_id == peer_id_hex
    }

    pub fn owned_space_ids(&self, peer_id_hex: &str) -> Vec<String> {
        let state = self.inner.read().unwrap();
        let mut owned: Vec<_> = state
            .iter()
            .filter(|(_, space)| {
                space.owner_peer_id.is_empty() || space.owner_peer_id == peer_id_hex
            })
            .map(|(space_id, _)| space_id.clone())
            .collect();
        owned.sort();
        owned
    }

    pub fn append_acl_record(
        &self,
        space_id: &str,
        raw_record_with_id: Vec<u8>,
        record_id: &str,
    ) -> Result<()> {
        let index = {
            let mut state = self.inner.write().unwrap();
            let space = state.entry(space_id.to_string()).or_default();
            space.acl_records.push(raw_record_with_id.clone());
            space.acl_head = record_id.to_string();
            space.acl_records.len() - 1
        };

        self.storage
            .persist_acl_record(space_id, index, &raw_record_with_id)
    }

    pub fn list_acl_records(&self, space_id: &str, acl_head: &str) -> Vec<Vec<u8>> {
        let state = self.inner.read().unwrap();
        let Some(space) = state.get(space_id) else {
            return Vec::new();
        };
        if acl_head.is_empty() {
            return space.acl_records.clone();
        }

        let Some(cursor_idx) = space
            .acl_records
            .iter()
            .position(|raw| decode_acl_record_id(raw).as_deref() == Some(acl_head))
        else {
            return Vec::new();
        };

        space.acl_records[cursor_idx + 1..].to_vec()
    }

    pub fn record_object_change(
        &self,
        space_id: &str,
        object_id: &str,
        change_id: &str,
        raw_change: Vec<u8>,
        parent_heads: &[String],
    ) -> Result<()> {
        let (heads, object_changes) = {
            let mut state = self.inner.write().unwrap();
            let space = state.entry(space_id.to_string()).or_default();
            if !space.raw_changes.contains_key(change_id) {
                space
                    .raw_changes
                    .insert(change_id.to_string(), raw_change.clone());
            }

            let object_changes = space
                .object_changes
                .entry(object_id.to_string())
                .or_default();
            if !object_changes.iter().any(|existing| existing == change_id) {
                object_changes.push(change_id.to_string());
            }

            let heads = space.object_heads.entry(object_id.to_string()).or_default();
            heads.retain(|head| !parent_heads.iter().any(|parent| parent == head));
            if !heads.iter().any(|existing| existing == change_id) {
                heads.push(change_id.to_string());
            }
            (heads.clone(), object_changes.clone())
        };

        self.storage.persist_object_state(
            space_id,
            object_id,
            &heads,
            &object_changes,
            Some(change_id),
            Some(&raw_change),
        )
    }

    pub fn list_object_changes(&self, space_id: &str, object_id: &str) -> Vec<Vec<u8>> {
        let state = self.inner.read().unwrap();
        let Some(space) = state.get(space_id) else {
            return Vec::new();
        };
        let Some(change_ids) = space.object_changes.get(object_id) else {
            return Vec::new();
        };
        change_ids
            .iter()
            .filter_map(|change_id| space.raw_changes.get(change_id).cloned())
            .collect()
    }

    pub fn upsert_store_entry(&self, entry: StoreKeyValue) -> Result<()> {
        let encoded = entry.encode_to_vec();
        {
            let mut state = self.inner.write().unwrap();
            let space = state.entry(entry.space_id.clone()).or_default();
            space
                .store_key_values
                .insert(entry.key_peer_id.clone(), encoded.clone());
        }
        self.storage
            .persist_store_key_value(&entry.space_id, &entry.key_peer_id, &encoded)
    }

    pub fn get_store_entry(&self, space_id: &str, key_peer_id: &str) -> Option<StoreKeyValue> {
        let state = self.inner.read().unwrap();
        let space = state.get(space_id)?;
        let encoded = space.store_key_values.get(key_peer_id)?;
        StoreKeyValue::decode(encoded.as_slice()).ok()
    }
}

#[cfg(test)]
pub fn new_shared_sync_state() -> SharedSyncState {
    let nonce = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_nanos();
    let path = std::env::temp_dir().join(format!("manytype-sync-state-{nonce}"));
    SharedSyncState::open(path).expect("failed to create sync state")
}

#[cfg(test)]
pub fn new_shared_sync_state_at(path: impl AsRef<Path>) -> Result<SharedSyncState> {
    SharedSyncState::open(path)
}

fn ensure_table(db: &Database, definition: TableDefinition<&str, &[u8]>) -> Result<()> {
    let write_txn = db.begin_write()?;
    {
        let _table = write_txn.open_table(definition)?;
    }
    write_txn.commit()?;
    Ok(())
}

fn ensure_space_tables(db: &Database) -> Result<()> {
    let write_txn = db.begin_write()?;
    {
        let _meta = write_txn.open_table(SPACE_META_TABLE)?;
        let _heads = write_txn.open_table(SPACE_HEADS_TABLE)?;
        let _object_changes = write_txn.open_table(SPACE_OBJECT_CHANGES_TABLE)?;
        let _changes = write_txn.open_table(SPACE_CHANGES_TABLE)?;
        let _store = write_txn.open_table(SPACE_STORE_TABLE)?;
        let _acl = write_txn.open_table(SPACE_ACL_TABLE)?;
    }
    write_txn.commit()?;
    Ok(())
}

fn decode_acl_record_id(raw_record_with_id: &[u8]) -> Option<String> {
    RawRecordWithId::decode(raw_record_with_id)
        .ok()
        .map(|record| record.id)
}

#[cfg(test)]
mod tests {
    use tempfile::TempDir;

    use super::*;

    #[test]
    fn sync_state_persists_space_metadata_and_changes_across_reopen() {
        let temp_dir = TempDir::new().unwrap();
        let store_entry = StoreKeyValue {
            key_peer_id: "peer-1".to_string(),
            value: b"value".to_vec(),
            identity_signature: b"identity".to_vec(),
            peer_signature: b"peer".to_vec(),
            space_id: "space-1".to_string(),
        };
        {
            let state = new_shared_sync_state_at(temp_dir.path()).unwrap();
            state
                .upsert_space_metadata(
                    "space-1",
                    Some(b"header".to_vec()),
                    Some(b"acl-root".to_vec()),
                    Some("acl-root-id".to_string()),
                    Some(b"settings".to_vec()),
                    Some("settings-id".to_string()),
                    Some(false),
                    Some("peer-1".to_string()),
                )
                .unwrap();
            state
                .record_object_change(
                    "space-1",
                    "object-1",
                    "change-1",
                    b"raw-change".to_vec(),
                    &[],
                )
                .unwrap();
            state.upsert_store_entry(store_entry.clone()).unwrap();
        }

        let reopened = new_shared_sync_state_at(temp_dir.path()).unwrap();
        let snapshot = reopened.read().unwrap();
        let space = snapshot.get("space-1").unwrap();
        assert_eq!(space.space_header.as_deref(), Some(b"header".as_ref()));
        assert_eq!(space.acl_root.as_deref(), Some(b"acl-root".as_ref()));
        assert_eq!(space.acl_root_id, "acl-root-id");
        assert_eq!(
            space.settings_payload.as_deref(),
            Some(b"settings".as_ref())
        );
        assert_eq!(space.settings_payload_id, "settings-id");
        assert!(!space.is_shared);
        assert_eq!(
            space.object_heads.get("object-1"),
            Some(&vec!["change-1".to_string()])
        );
        assert_eq!(
            reopened.list_object_changes("space-1", "object-1"),
            vec![b"raw-change".to_vec()]
        );
        let stored = reopened.get_store_entry("space-1", "peer-1").unwrap();
        assert_eq!(stored.key_peer_id, store_entry.key_peer_id);
        assert_eq!(stored.value, store_entry.value);
        assert_eq!(stored.identity_signature, store_entry.identity_signature);
        assert_eq!(stored.peer_signature, store_entry.peer_signature);
    }

    #[test]
    fn recording_child_change_replaces_parent_head() {
        let temp_dir = TempDir::new().unwrap();
        let state = new_shared_sync_state_at(temp_dir.path()).unwrap();
        state
            .record_object_change("space-1", "object-1", "root", b"root".to_vec(), &[])
            .unwrap();
        state
            .record_object_change(
                "space-1",
                "object-1",
                "child",
                b"child".to_vec(),
                &["root".to_string()],
            )
            .unwrap();

        let snapshot = state.read().unwrap();
        let heads = &snapshot.get("space-1").unwrap().object_heads["object-1"];
        assert_eq!(heads, &vec!["child".to_string()]);
    }

    #[test]
    fn acl_records_persist_across_reopen() {
        let temp_dir = TempDir::new().unwrap();
        {
            let state = new_shared_sync_state_at(temp_dir.path()).unwrap();
            state
                .append_acl_record(
                    "space-1",
                    RawRecordWithId {
                        payload: b"record-1".to_vec(),
                        id: "cid-1".to_string(),
                    }
                    .encode_to_vec(),
                    "cid-1",
                )
                .unwrap();
            state
                .append_acl_record(
                    "space-1",
                    RawRecordWithId {
                        payload: b"record-2".to_vec(),
                        id: "cid-2".to_string(),
                    }
                    .encode_to_vec(),
                    "cid-2",
                )
                .unwrap();
        }

        let reopened = new_shared_sync_state_at(temp_dir.path()).unwrap();
        let records = reopened.list_acl_records("space-1", "");
        assert_eq!(records.len(), 2);
        assert_eq!(
            RawRecordWithId::decode(records[0].as_slice()).unwrap().id,
            "cid-1"
        );
        assert_eq!(
            RawRecordWithId::decode(records[1].as_slice()).unwrap().id,
            "cid-2"
        );
        assert_eq!(reopened.read().unwrap()["space-1"].acl_head, "cid-2");
    }

    #[test]
    fn list_acl_records_cursor_excludes_head_record() {
        let state = new_shared_sync_state();
        state
            .append_acl_record(
                "space-1",
                RawRecordWithId {
                    payload: b"record-1".to_vec(),
                    id: "cid-1".to_string(),
                }
                .encode_to_vec(),
                "cid-1",
            )
            .unwrap();
        state
            .append_acl_record(
                "space-1",
                RawRecordWithId {
                    payload: b"record-2".to_vec(),
                    id: "cid-2".to_string(),
                }
                .encode_to_vec(),
                "cid-2",
            )
            .unwrap();

        let records = state.list_acl_records("space-1", "cid-1");
        assert_eq!(records.len(), 1);
        assert_eq!(
            RawRecordWithId::decode(records[0].as_slice()).unwrap().id,
            "cid-2"
        );
    }

    #[test]
    fn list_acl_records_unknown_head_returns_empty() {
        let state = new_shared_sync_state();
        state
            .append_acl_record(
                "space-1",
                RawRecordWithId {
                    payload: b"record-1".to_vec(),
                    id: "cid-1".to_string(),
                }
                .encode_to_vec(),
                "cid-1",
            )
            .unwrap();

        assert!(state.list_acl_records("space-1", "missing").is_empty());
    }

    #[test]
    fn mark_space_shared_persists_across_reopen() {
        let temp_dir = TempDir::new().unwrap();
        {
            let state = new_shared_sync_state_at(temp_dir.path()).unwrap();
            state
                .upsert_space_metadata(
                    "space-1",
                    Some(b"header".to_vec()),
                    Some(b"acl-root".to_vec()),
                    Some("acl-root-id".to_string()),
                    None,
                    None,
                    Some(false),
                    Some("peer-1".to_string()),
                )
                .unwrap();
            state.mark_space_shared("space-1").unwrap();
        }

        let reopened = new_shared_sync_state_at(temp_dir.path()).unwrap();
        assert!(reopened.read().unwrap()["space-1"].is_shared);
    }
}
