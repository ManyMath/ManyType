use std::collections::{HashMap, HashSet};
use std::path::{Path, PathBuf};
#[cfg(test)]
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Arc, LockResult, Mutex, RwLock, RwLockReadGuard};
#[cfg(test)]
use std::time::{SystemTime, UNIX_EPOCH};

use anyhow::{Context, Result, ensure};
use manytype_core::crdt::cid::compute_cid;
use manytype_proto::consensus::RawRecordWithId;
use manytype_proto::spacesync::StoreKeyValue;
use manytype_proto::treechange::{RawTreeChange, RootChange};
use prost::Message;
use redb::{Database, ReadableDatabase, ReadableTable, TableDefinition};

use crate::auth::AuthenticatedPeer;
use crate::input::{validate_space_id, validate_storage_key};

const GLOBAL_SPACES_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("spaces");
const GLOBAL_DELETED_ACCOUNTS_TABLE: TableDefinition<&str, &[u8]> =
    TableDefinition::new("deleted_accounts");
const GLOBAL_SCHEMA_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("schema");
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
const META_OWNER_ACCOUNT_IDENTITY: &str = "owner_account_identity";
const SCHEMA_VERSION_KEY: &str = "version";
const CURRENT_SCHEMA_VERSION: &[u8] = b"2";
const LEGACY_PEER_ONLY_SCHEMA_VERSION: &[u8] = b"1";
const LOGICAL_ENTRY_OVERHEAD_BYTES: u64 = 64;

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
    pub owner_account_identity: Option<[u8; 32]>,
    pub store_key_values: HashMap<String, Vec<u8>>,
}

fn checked_add_bytes(total: &mut u64, bytes: u64) -> Result<()> {
    *total = total
        .checked_add(bytes)
        .ok_or_else(|| anyhow::anyhow!("sync state logical size overflow"))?;
    Ok(())
}

fn checked_len(value: usize) -> Result<u64> {
    u64::try_from(value).map_err(|_| anyhow::anyhow!("sync state value length overflow"))
}

fn add_logical_entry(total: &mut u64, key_bytes: usize, value_bytes: usize) -> Result<()> {
    checked_add_bytes(total, LOGICAL_ENTRY_OVERHEAD_BYTES)?;
    checked_add_bytes(total, checked_len(key_bytes)?)?;
    checked_add_bytes(total, checked_len(value_bytes)?)
}

fn encoded_string_list_bytes(values: &[String]) -> Result<usize> {
    values.iter().try_fold(2usize, |size, value| {
        size.checked_add(value.len().saturating_add(3))
            .ok_or_else(|| anyhow::anyhow!("sync state string list length overflow"))
    })
}

fn space_logical_bytes(space_id: &str, space: &SpaceState) -> Result<u64> {
    let mut total = 0u64;

    // Account for the global registration row and a conservative fixed
    // storage-engine overhead for every durable table entry. Metadata rows are
    // counted even when their current value is empty so tiny identifiers cannot
    // create an effectively unbounded number of per-space databases.
    add_logical_entry(&mut total, space_id.len(), 1)?;
    add_logical_entry(
        &mut total,
        META_SPACE_HEADER.len(),
        space.space_header.as_ref().map_or(0, Vec::len),
    )?;
    add_logical_entry(
        &mut total,
        META_ACL_ROOT.len(),
        space.acl_root.as_ref().map_or(0, Vec::len),
    )?;
    add_logical_entry(&mut total, META_ACL_ROOT_ID.len(), space.acl_root_id.len())?;
    add_logical_entry(
        &mut total,
        META_SETTINGS_PAYLOAD.len(),
        space.settings_payload.as_ref().map_or(0, Vec::len),
    )?;
    add_logical_entry(
        &mut total,
        META_SETTINGS_PAYLOAD_ID.len(),
        space.settings_payload_id.len(),
    )?;
    add_logical_entry(&mut total, META_IS_SHARED.len(), 1)?;
    add_logical_entry(
        &mut total,
        META_OWNER_PEER_ID.len(),
        space.owner_peer_id.len(),
    )?;
    add_logical_entry(
        &mut total,
        META_OWNER_ACCOUNT_IDENTITY.len(),
        space.owner_account_identity.map_or(0, |_| 32),
    )?;

    for (object_id, heads) in &space.object_heads {
        add_logical_entry(
            &mut total,
            object_id.len(),
            encoded_string_list_bytes(heads)?,
        )?;
    }
    for (object_id, change_ids) in &space.object_changes {
        add_logical_entry(
            &mut total,
            object_id.len(),
            encoded_string_list_bytes(change_ids)?,
        )?;
    }
    for (change_id, raw_change) in &space.raw_changes {
        add_logical_entry(&mut total, change_id.len(), raw_change.len())?;
    }
    for (key_peer_id, value) in &space.store_key_values {
        add_logical_entry(&mut total, key_peer_id.len(), value.len())?;
    }
    for (index, record) in space.acl_records.iter().enumerate() {
        add_logical_entry(&mut total, format!("{index:018}").len(), record.len())?;
    }

    Ok(total)
}

fn sync_state_logical_bytes(
    spaces: &HashMap<String, SpaceState>,
    deleted_accounts: &HashSet<String>,
) -> Result<u64> {
    let mut total = 0u64;
    for (space_id, space) in spaces {
        checked_add_bytes(&mut total, space_logical_bytes(space_id, space)?)?;
    }
    for account_key in deleted_accounts {
        add_logical_entry(&mut total, account_key.len(), 1)?;
    }
    Ok(total)
}

#[derive(Clone)]
pub struct SharedSyncState {
    inner: Arc<RwLock<HashMap<String, SpaceState>>>,
    deleted_accounts: Arc<RwLock<HashSet<String>>>,
    storage: Arc<SyncStateStorage>,
    mutation_lock: Arc<Mutex<()>>,
    max_logical_bytes: u64,
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

    fn space_db_path(&self, space_id: &str) -> Result<PathBuf> {
        validate_space_id(space_id)?;
        Ok(self.spaces_dir.join(format!("{space_id}.redb")))
    }
}

impl SyncStateStorage {
    fn open(config_path: &Path) -> Result<Self> {
        let paths = StoragePaths::from_config(config_path);
        std::fs::create_dir_all(&paths.spaces_dir)?;
        let global_db = Database::create(&paths.global_db_path)?;
        ensure_schema(&global_db)?;
        ensure_table(&global_db, GLOBAL_SPACES_TABLE)?;
        ensure_table(&global_db, GLOBAL_DELETED_ACCOUNTS_TABLE)?;
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
            validate_space_id(&space_id)?;
            let state = self.load_space(&space_id)?;
            spaces.insert(space_id, state);
        }
        Ok(spaces)
    }

    fn ensure_space_registered_locked(&self, space_id: &str) -> Result<()> {
        // Create the space database first so a registered space always has one.
        let space_db = Database::create(self.paths().space_db_path(space_id)?)?;
        ensure_space_tables(&space_db)?;
        let write_txn = self.global_db.begin_write()?;
        {
            let mut table = write_txn.open_table(GLOBAL_SPACES_TABLE)?;
            table.insert(space_id, b"1".as_slice())?;
        }
        write_txn.commit()?;
        Ok(())
    }

    fn load_space(&self, space_id: &str) -> Result<SpaceState> {
        let space_db_path = self.paths().space_db_path(space_id)?;
        let space_db = Database::open(&space_db_path).with_context(|| {
            format!(
                "registered space {space_id} has no readable database at {}",
                space_db_path.display()
            )
        })?;
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
        let owner_account_identity = meta_table
            .get(META_OWNER_ACCOUNT_IDENTITY)?
            .map(|value| {
                let bytes = value.value();
                bytes.try_into().map_err(|_| {
                    anyhow::anyhow!(
                        "space {space_id} owner account identity must contain 32 bytes, got {}",
                        bytes.len()
                    )
                })
            })
            .transpose()?;
        ensure!(
            owner_peer_id.is_empty() == owner_account_identity.is_none(),
            "space {space_id} has an incomplete owner binding; peer-only owners cannot be migrated automatically"
        );

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
            owner_account_identity,
            store_key_values,
        })
    }

    // Mirrors the SpaceHeader/ACL/settings fields 1:1; bundling into a
    // struct is a larger refactor than this cleanup warrants.
    #[allow(clippy::too_many_arguments)]
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
        owner_account_identity: Option<&[u8; 32]>,
    ) -> Result<()> {
        let _guard = self.persist_lock.lock().unwrap();
        self.ensure_space_registered_locked(space_id)?;
        let space_db = Database::create(self.paths().space_db_path(space_id)?)?;
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
            if let Some(owner_account_identity) = owner_account_identity {
                table.insert(
                    META_OWNER_ACCOUNT_IDENTITY,
                    owner_account_identity.as_slice(),
                )?;
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
        let space_db = Database::create(self.paths().space_db_path(space_id)?)?;
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
        let space_db = Database::create(self.paths().space_db_path(space_id)?)?;
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
        let space_db = Database::create(self.paths().space_db_path(space_id)?)?;
        let write_txn = space_db.begin_write()?;
        {
            let mut table = write_txn.open_table(SPACE_STORE_TABLE)?;
            table.insert(key_peer_id, value)?;
        }
        write_txn.commit()?;
        Ok(())
    }

    fn load_deleted_accounts(&self) -> Result<HashSet<String>> {
        let read_txn = self.global_db.begin_read()?;
        let table = read_txn.open_table(GLOBAL_DELETED_ACCOUNTS_TABLE)?;
        Ok(table
            .iter()?
            .flatten()
            .map(|entry| entry.0.value().to_string())
            .collect())
    }

    fn persist_deleted_account(&self, account_key: &str) -> Result<()> {
        let _guard = self.persist_lock.lock().unwrap();
        let write_txn = self.global_db.begin_write()?;
        {
            let mut table = write_txn.open_table(GLOBAL_DELETED_ACCOUNTS_TABLE)?;
            table.insert(account_key, b"1".as_slice())?;
        }
        write_txn.commit()?;
        Ok(())
    }
}

impl SharedSyncState {
    pub fn open(config_path: impl AsRef<Path>) -> Result<Self> {
        Self::open_with_limit(config_path, u64::MAX)
    }

    pub fn open_with_limit(config_path: impl AsRef<Path>, max_logical_bytes: u64) -> Result<Self> {
        ensure!(max_logical_bytes > 0, "sync state quota must be positive");
        let storage = Arc::new(SyncStateStorage::open(config_path.as_ref())?);
        let spaces = storage.load_spaces()?;
        let deleted_accounts = storage.load_deleted_accounts()?;
        let logical_bytes = sync_state_logical_bytes(&spaces, &deleted_accounts)?;
        ensure!(
            logical_bytes <= max_logical_bytes,
            "sync state quota exceeded: existing state uses {logical_bytes} logical bytes, limit {max_logical_bytes} bytes"
        );
        Ok(Self {
            inner: Arc::new(RwLock::new(spaces)),
            deleted_accounts: Arc::new(RwLock::new(deleted_accounts)),
            storage,
            mutation_lock: Arc::new(Mutex::new(())),
            max_logical_bytes,
        })
    }

    fn ensure_space_replacement_fits(
        &self,
        spaces: &HashMap<String, SpaceState>,
        deleted_accounts: &HashSet<String>,
        space_id: &str,
        replacement: &SpaceState,
    ) -> Result<()> {
        let current = sync_state_logical_bytes(spaces, deleted_accounts)?;
        let previous = spaces
            .get(space_id)
            .map(|space| space_logical_bytes(space_id, space))
            .transpose()?
            .unwrap_or_default();
        let replacement = space_logical_bytes(space_id, replacement)?;
        let requested = current
            .checked_sub(previous)
            .and_then(|usage| usage.checked_add(replacement))
            .ok_or_else(|| anyhow::anyhow!("sync state logical size overflow"))?;
        ensure!(
            requested <= self.max_logical_bytes,
            "sync state quota exceeded: requested {requested} logical bytes, limit {} bytes",
            self.max_logical_bytes
        );
        Ok(())
    }

    /// Returns whether `AccountDelete` has already been accepted for this
    /// account identity. Mirrors the one observable signal the official
    /// any-sync coordinator exposes for account deletion (a repeat
    /// `AccountDelete` call is rejected with "account is deleted"): there is
    /// no per-account status/reread RPC to check this any other way.
    pub fn is_account_deleted(&self, account_identity: &[u8]) -> bool {
        let key = hex::encode(account_identity);
        self.deleted_accounts.read().unwrap().contains(&key)
    }

    pub fn mark_account_deleted(&self, account_identity: &[u8]) -> Result<()> {
        let key = hex::encode(account_identity);
        let _mutation = self
            .mutation_lock
            .lock()
            .map_err(|_| anyhow::anyhow!("sync state mutation lock is poisoned"))?;
        let mut deleted = self.deleted_accounts.write().unwrap();
        if deleted.contains(&key) {
            return Ok(());
        }
        let spaces = self.inner.read().unwrap();
        let current = sync_state_logical_bytes(&spaces, &deleted)?;
        let mut requested = current;
        add_logical_entry(&mut requested, key.len(), 1)?;
        ensure!(
            requested <= self.max_logical_bytes,
            "sync state quota exceeded: requested {requested} logical bytes, limit {} bytes",
            self.max_logical_bytes
        );
        self.storage.persist_deleted_account(&key)?;
        deleted.insert(key);
        Ok(())
    }

    pub fn read(&self) -> LockResult<RwLockReadGuard<'_, HashMap<String, SpaceState>>> {
        self.inner.read()
    }

    #[allow(clippy::too_many_arguments)]
    pub fn upsert_space_metadata(
        &self,
        space_id: &str,
        space_header: Option<Vec<u8>>,
        acl_root: Option<Vec<u8>>,
        acl_root_id: Option<String>,
        settings_payload: Option<Vec<u8>>,
        settings_payload_id: Option<String>,
        is_shared: Option<bool>,
        owner: Option<&AuthenticatedPeer<'_>>,
    ) -> Result<()> {
        validate_space_id(space_id)?;
        let _mutation = self
            .mutation_lock
            .lock()
            .map_err(|_| anyhow::anyhow!("sync state mutation lock is poisoned"))?;
        let mut state = self.inner.write().unwrap();
        let mut replacement = state.get(space_id).cloned().unwrap_or_default();
        if let Some(owner) = owner {
            anyhow::ensure!(
                replacement.owner_peer_id.is_empty() || space_is_owned_by(&replacement, owner),
                "space ownership is immutable"
            );
        }
        if let Some(space_header) = space_header.clone() {
            replacement.space_header = Some(space_header);
        }
        if let Some(acl_root) = acl_root.clone() {
            replacement.acl_root = Some(acl_root);
        }
        if let Some(acl_root_id) = acl_root_id.clone() {
            replacement.acl_root_id = acl_root_id;
        }
        if let Some(settings_payload) = settings_payload.clone() {
            replacement.settings_payload = Some(settings_payload);
        }
        if let Some(settings_payload_id) = settings_payload_id.clone() {
            replacement.settings_payload_id = settings_payload_id;
        }
        if let Some(is_shared) = is_shared {
            replacement.is_shared = is_shared;
        }
        if let Some(owner) = owner {
            replacement.owner_peer_id = owner.id().to_string();
            replacement.owner_account_identity = Some(*owner.account_identity());
        }

        let deleted = self.deleted_accounts.read().unwrap();
        self.ensure_space_replacement_fits(&state, &deleted, space_id, &replacement)?;

        self.storage.persist_space_metadata(
            space_id,
            space_header.as_deref(),
            acl_root.as_deref(),
            acl_root_id.as_deref(),
            settings_payload.as_deref(),
            settings_payload_id.as_deref(),
            is_shared,
            owner.map(|principal| principal.id()),
            owner.map(AuthenticatedPeer::account_identity),
        )?;
        state.insert(space_id.to_string(), replacement);
        Ok(())
    }

    /// Atomically assigns the first authenticated owner of a space.
    ///
    /// Existing ownership may be reaffirmed by the same principal but can never be
    /// transferred through a later registration or metadata update.
    pub fn claim_space_owner(
        &self,
        space_id: &str,
        authenticated_peer: &AuthenticatedPeer<'_>,
    ) -> Result<()> {
        validate_space_id(space_id)?;

        let _mutation = self
            .mutation_lock
            .lock()
            .map_err(|_| anyhow::anyhow!("sync state mutation lock is poisoned"))?;
        let mut state = self.inner.write().unwrap();
        let mut replacement = state.get(space_id).cloned().unwrap_or_default();
        if !replacement.owner_peer_id.is_empty() {
            anyhow::ensure!(
                space_is_owned_by(&replacement, authenticated_peer),
                "space access denied"
            );
            return Ok(());
        }
        replacement.owner_peer_id = authenticated_peer.id().to_string();
        replacement.owner_account_identity = Some(*authenticated_peer.account_identity());
        let deleted = self.deleted_accounts.read().unwrap();
        self.ensure_space_replacement_fits(&state, &deleted, space_id, &replacement)?;

        self.storage.persist_space_metadata(
            space_id,
            None,
            None,
            None,
            None,
            None,
            None,
            Some(authenticated_peer.id()),
            Some(authenticated_peer.account_identity()),
        )?;
        state.insert(space_id.to_string(), replacement);
        Ok(())
    }

    pub fn authorize_space(
        &self,
        space_id: &str,
        authenticated_peer: &AuthenticatedPeer<'_>,
    ) -> Result<()> {
        validate_space_id(space_id)?;
        let state = self.inner.read().unwrap();
        let authorized = state
            .get(space_id)
            .is_some_and(|space| space_is_owned_by(space, authenticated_peer));
        anyhow::ensure!(authorized, "space access denied");
        Ok(())
    }

    pub fn mark_space_shared(&self, space_id: &str) -> Result<()> {
        validate_space_id(space_id)?;
        let _mutation = self
            .mutation_lock
            .lock()
            .map_err(|_| anyhow::anyhow!("sync state mutation lock is poisoned"))?;
        let mut state = self.inner.write().unwrap();
        let mut replacement = state
            .get(space_id)
            .cloned()
            .ok_or_else(|| anyhow::anyhow!("space not found: {space_id}"))?;
        replacement.is_shared = true;
        let (space_header, acl_root, acl_root_id, settings_payload, settings_payload_id) = {
            (
                replacement.space_header.clone(),
                replacement.acl_root.clone(),
                (!replacement.acl_root_id.is_empty()).then(|| replacement.acl_root_id.clone()),
                replacement.settings_payload.clone(),
                (!replacement.settings_payload_id.is_empty())
                    .then(|| replacement.settings_payload_id.clone()),
            )
        };
        let deleted = self.deleted_accounts.read().unwrap();
        self.ensure_space_replacement_fits(&state, &deleted, space_id, &replacement)?;

        self.storage.persist_space_metadata(
            space_id,
            space_header.as_deref(),
            acl_root.as_deref(),
            acl_root_id.as_deref(),
            settings_payload.as_deref(),
            settings_payload_id.as_deref(),
            Some(true),
            None,
            None,
        )?;
        state.insert(space_id.to_string(), replacement);
        Ok(())
    }

    pub fn peer_owns_space(
        &self,
        space_id: &str,
        authenticated_peer: &AuthenticatedPeer<'_>,
    ) -> bool {
        if validate_space_id(space_id).is_err() {
            return false;
        }
        let state = self.inner.read().unwrap();
        let Some(space) = state.get(space_id) else {
            return false;
        };
        space_is_owned_by(space, authenticated_peer)
    }

    pub fn owned_space_ids(&self, authenticated_peer: &AuthenticatedPeer<'_>) -> Vec<String> {
        let state = self.inner.read().unwrap();
        let mut owned: Vec<_> = state
            .iter()
            .filter(|(_, space)| space_is_owned_by(space, authenticated_peer))
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
        validate_space_id(space_id)?;
        validate_storage_key("ACL record id", record_id)?;
        let _mutation = self
            .mutation_lock
            .lock()
            .map_err(|_| anyhow::anyhow!("sync state mutation lock is poisoned"))?;
        let mut state = self.inner.write().unwrap();
        let mut replacement = state.get(space_id).cloned().unwrap_or_default();
        if let Some(existing) = replacement
            .acl_records
            .iter()
            .find(|record| decode_acl_record_id(record).as_deref() == Some(record_id))
        {
            ensure!(
                existing == &raw_record_with_id,
                "ACL record id collision for {record_id}"
            );
            return Ok(());
        }
        replacement.acl_records.push(raw_record_with_id.clone());
        replacement.acl_head = record_id.to_string();
        let index = replacement.acl_records.len() - 1;
        let deleted = self.deleted_accounts.read().unwrap();
        self.ensure_space_replacement_fits(&state, &deleted, space_id, &replacement)?;

        self.storage
            .persist_acl_record(space_id, index, &raw_record_with_id)?;
        state.insert(space_id.to_string(), replacement);
        Ok(())
    }

    pub fn list_acl_records(&self, space_id: &str, acl_head: &str) -> Vec<Vec<u8>> {
        let state = self.inner.read().unwrap();
        let Some(space) = state.get(space_id) else {
            return Vec::new();
        };

        let mut records = Vec::with_capacity(space.acl_records.len() + 1);
        if let Some(root_payload) = &space.acl_root {
            let root_id = if !space.acl_root_id.is_empty() {
                Some(space.acl_root_id.clone())
            } else {
                Some(compute_cid(root_payload))
            };
            if let Some(root_id) = root_id {
                records.push(
                    RawRecordWithId {
                        payload: root_payload.clone(),
                        id: root_id,
                    }
                    .encode_to_vec(),
                );
            }
        }
        records.extend(space.acl_records.clone());

        if acl_head.is_empty() {
            return records;
        }

        let Some(cursor_idx) = records
            .iter()
            .position(|raw| decode_acl_record_id(raw).as_deref() == Some(acl_head))
        else {
            return Vec::new();
        };

        records[cursor_idx + 1..].to_vec()
    }

    pub fn record_object_change(
        &self,
        space_id: &str,
        object_id: &str,
        change_id: &str,
        raw_change: Vec<u8>,
        parent_heads: &[String],
    ) -> Result<()> {
        validate_space_id(space_id)?;
        validate_storage_key("object id", object_id)?;
        validate_storage_key("change id", change_id)?;
        let is_root_change = RawTreeChange::decode(raw_change.as_slice())
            .ok()
            .and_then(|raw_tree| RootChange::decode(raw_tree.payload.as_slice()).ok())
            .is_some_and(|root| !root.space_id.is_empty() && !root.change_type.is_empty());

        let _mutation = self
            .mutation_lock
            .lock()
            .map_err(|_| anyhow::anyhow!("sync state mutation lock is poisoned"))?;
        let mut state = self.inner.write().unwrap();
        // A change that is already part of this object has already moved its
        // heads; applying it again would resurrect it as a stale head.
        if let Some(space) = state.get(space_id)
            && let Some(existing) = space.raw_changes.get(change_id)
        {
            ensure!(
                existing == &raw_change,
                "object change id collision for {change_id}"
            );
            if space
                .object_changes
                .get(object_id)
                .is_some_and(|change_ids| change_ids.iter().any(|id| id == change_id))
            {
                return Ok(());
            }
        }
        let mut replacement = state.get(space_id).cloned().unwrap_or_default();
        if !replacement.raw_changes.contains_key(change_id) {
            replacement
                .raw_changes
                .insert(change_id.to_string(), raw_change.clone());
        }

        let object_changes = replacement
            .object_changes
            .entry(object_id.to_string())
            .or_default();
        if !object_changes.iter().any(|existing| existing == change_id) {
            object_changes.push(change_id.to_string());
        }

        let heads = replacement
            .object_heads
            .entry(object_id.to_string())
            .or_default();
        heads.retain(|head| !parent_heads.iter().any(|parent| parent == head));
        if !is_root_change && !heads.iter().any(|existing| existing == change_id) {
            heads.push(change_id.to_string());
        }
        let heads = heads.clone();
        let object_changes = object_changes.clone();
        let deleted = self.deleted_accounts.read().unwrap();
        self.ensure_space_replacement_fits(&state, &deleted, space_id, &replacement)?;

        self.storage.persist_object_state(
            space_id,
            object_id,
            &heads,
            &object_changes,
            Some(change_id),
            Some(&raw_change),
        )?;
        state.insert(space_id.to_string(), replacement);
        Ok(())
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
        validate_space_id(&entry.space_id)?;
        validate_storage_key("store peer id", &entry.key_peer_id)?;
        let encoded = entry.encode_to_vec();
        let _mutation = self
            .mutation_lock
            .lock()
            .map_err(|_| anyhow::anyhow!("sync state mutation lock is poisoned"))?;
        let mut state = self.inner.write().unwrap();
        let mut replacement = state.get(&entry.space_id).cloned().unwrap_or_default();
        replacement
            .store_key_values
            .insert(entry.key_peer_id.clone(), encoded.clone());
        let deleted = self.deleted_accounts.read().unwrap();
        self.ensure_space_replacement_fits(&state, &deleted, &entry.space_id, &replacement)?;
        self.storage
            .persist_store_key_value(&entry.space_id, &entry.key_peer_id, &encoded)?;
        state.insert(entry.space_id, replacement);
        Ok(())
    }

    pub fn get_store_entry(&self, space_id: &str, key_peer_id: &str) -> Option<StoreKeyValue> {
        let state = self.inner.read().unwrap();
        let space = state.get(space_id)?;
        let encoded = space.store_key_values.get(key_peer_id)?;
        StoreKeyValue::decode(encoded.as_slice()).ok()
    }
}

#[cfg(test)]
static NEXT_TEST_STATE_ID: AtomicU64 = AtomicU64::new(0);

#[cfg(test)]
pub fn new_shared_sync_state() -> SharedSyncState {
    let nonce = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_nanos();
    let sequence = NEXT_TEST_STATE_ID.fetch_add(1, Ordering::Relaxed);
    let path = std::env::temp_dir().join(format!(
        "manytype-sync-state-{}-{nonce}-{sequence}",
        std::process::id()
    ));
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

fn ensure_schema(db: &Database) -> Result<()> {
    let write_txn = db.begin_write()?;
    {
        let mut table = write_txn.open_table(GLOBAL_SCHEMA_TABLE)?;
        let existing_version = table
            .get(SCHEMA_VERSION_KEY)?
            .map(|version| version.value().to_vec());
        match existing_version.as_deref() {
            Some(LEGACY_PEER_ONLY_SCHEMA_VERSION) => anyhow::bail!(
                "sync schema version 1 stores peer-only owners and cannot be migrated automatically; recreate the private canary state with schema version {}",
                String::from_utf8_lossy(CURRENT_SCHEMA_VERSION)
            ),
            Some(version) => anyhow::ensure!(
                version == CURRENT_SCHEMA_VERSION,
                "unsupported sync schema version {} (expected {})",
                String::from_utf8_lossy(version),
                String::from_utf8_lossy(CURRENT_SCHEMA_VERSION)
            ),
            None => {
                table.insert(SCHEMA_VERSION_KEY, CURRENT_SCHEMA_VERSION)?;
            }
        }
    }
    write_txn.commit()?;
    Ok(())
}

fn space_is_owned_by(space: &SpaceState, authenticated_peer: &AuthenticatedPeer<'_>) -> bool {
    !space.owner_peer_id.is_empty()
        && space.owner_peer_id == authenticated_peer.id()
        && space.owner_account_identity.as_ref() == Some(authenticated_peer.account_identity())
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
    use std::sync::{Arc, Barrier};
    use std::thread;

    use tempfile::TempDir;

    use super::*;

    fn test_peer(peer_id: &str) -> AuthenticatedPeer<'_> {
        AuthenticatedPeer::for_test(peer_id)
    }

    fn test_store_entry(key_peer_id: &str) -> StoreKeyValue {
        StoreKeyValue {
            key_peer_id: key_peer_id.to_string(),
            value: b"value".to_vec(),
            identity_signature: b"identity".to_vec(),
            peer_signature: b"peer".to_vec(),
            space_id: "space-1".to_string(),
        }
    }

    fn current_logical_usage(state: &SharedSyncState) -> u64 {
        sync_state_logical_bytes(
            &state.inner.read().unwrap(),
            &state.deleted_accounts.read().unwrap(),
        )
        .unwrap()
    }

    #[test]
    fn rejects_unsafe_space_id_before_creating_a_database_file() {
        let temp_dir = TempDir::new().unwrap();
        let state = new_shared_sync_state_at(temp_dir.path()).unwrap();
        assert!(
            state
                .claim_space_owner("../outside", &test_peer("peer-1"))
                .is_err()
        );
        assert!(
            !temp_dir
                .path()
                .parent()
                .unwrap()
                .join("outside.redb")
                .exists()
        );
    }

    #[test]
    fn rejects_unknown_persistent_schema_version() {
        let temp_dir = TempDir::new().unwrap();
        let global_path = temp_dir.path().join("global.redb");
        {
            let db = Database::create(&global_path).unwrap();
            let write_txn = db.begin_write().unwrap();
            {
                let mut table = write_txn.open_table(GLOBAL_SCHEMA_TABLE).unwrap();
                table.insert(SCHEMA_VERSION_KEY, b"999".as_slice()).unwrap();
            }
            write_txn.commit().unwrap();
        }
        let error = match new_shared_sync_state_at(temp_dir.path()) {
            Ok(_) => panic!("unknown schema version was accepted"),
            Err(error) => error,
        };
        assert!(
            error
                .to_string()
                .contains("unsupported sync schema version")
        );
    }

    #[test]
    fn rejects_legacy_peer_only_owner_schema_without_migration() {
        let temp_dir = TempDir::new().unwrap();
        let global_path = temp_dir.path().join("global.redb");
        {
            let db = Database::create(&global_path).unwrap();
            let write_txn = db.begin_write().unwrap();
            {
                let mut table = write_txn.open_table(GLOBAL_SCHEMA_TABLE).unwrap();
                table
                    .insert(SCHEMA_VERSION_KEY, LEGACY_PEER_ONLY_SCHEMA_VERSION)
                    .unwrap();
            }
            write_txn.commit().unwrap();
        }

        let error = match new_shared_sync_state_at(temp_dir.path()) {
            Ok(_) => panic!("peer-only owner schema was accepted"),
            Err(error) => error,
        };
        assert!(
            error
                .to_string()
                .contains("cannot be migrated automatically")
        );
    }

    #[test]
    fn rejects_incomplete_owner_binding_in_current_schema() {
        let temp_dir = TempDir::new().unwrap();
        {
            let state = new_shared_sync_state_at(temp_dir.path()).unwrap();
            state
                .storage
                .persist_space_metadata(
                    "space-1",
                    None,
                    None,
                    None,
                    None,
                    None,
                    None,
                    Some("peer-1"),
                    None,
                )
                .unwrap();
        }

        let error = match new_shared_sync_state_at(temp_dir.path()) {
            Ok(_) => panic!("incomplete owner binding was accepted"),
            Err(error) => error,
        };
        assert!(error.to_string().contains("incomplete owner binding"));
    }

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
                    Some(&test_peer("peer-1")),
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
    fn resending_an_ancestor_change_keeps_heads_unchanged() {
        let temp_dir = TempDir::new().unwrap();
        let state = new_shared_sync_state_at(temp_dir.path()).unwrap();
        let chain = [("a", None), ("b", Some("a")), ("c", Some("b"))];
        for (change_id, parent) in chain {
            let parents: Vec<String> = parent.into_iter().map(ToString::to_string).collect();
            state
                .record_object_change(
                    "space-1",
                    "object-1",
                    change_id,
                    change_id.as_bytes().to_vec(),
                    &parents,
                )
                .unwrap();
        }

        state
            .record_object_change(
                "space-1",
                "object-1",
                "b",
                b"b".to_vec(),
                &["a".to_string()],
            )
            .unwrap();

        assert_eq!(
            state.read().unwrap()["space-1"].object_heads["object-1"],
            vec!["c".to_string()]
        );
        drop(state);
        let reopened = new_shared_sync_state_at(temp_dir.path()).unwrap();
        let snapshot = reopened.read().unwrap();
        assert_eq!(
            snapshot["space-1"].object_heads["object-1"],
            vec!["c".to_string()]
        );
        assert_eq!(
            snapshot["space-1"].object_changes["object-1"],
            vec!["a".to_string(), "b".to_string(), "c".to_string()]
        );
    }

    #[test]
    fn repeated_object_change_is_idempotent_and_collision_is_rejected() {
        let state = new_shared_sync_state();
        state
            .record_object_change(
                "space-1",
                "object-1",
                "change-1",
                b"raw-change".to_vec(),
                &[],
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
        assert_eq!(
            state.read().unwrap()["space-1"].object_changes["object-1"],
            vec!["change-1".to_string()]
        );

        assert!(
            state
                .record_object_change(
                    "space-1",
                    "object-1",
                    "change-1",
                    b"different".to_vec(),
                    &[],
                )
                .unwrap_err()
                .to_string()
                .contains("collision")
        );
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
    fn repeated_acl_record_is_idempotent_and_collision_is_rejected() {
        let state = new_shared_sync_state();
        let record = RawRecordWithId {
            payload: b"record-1".to_vec(),
            id: "cid-1".to_string(),
        }
        .encode_to_vec();

        state
            .append_acl_record("space-1", record.clone(), "cid-1")
            .unwrap();
        state.append_acl_record("space-1", record, "cid-1").unwrap();
        assert_eq!(state.read().unwrap()["space-1"].acl_records.len(), 1);

        let collision = RawRecordWithId {
            payload: b"different".to_vec(),
            id: "cid-1".to_string(),
        }
        .encode_to_vec();
        assert!(
            state
                .append_acl_record("space-1", collision, "cid-1")
                .unwrap_err()
                .to_string()
                .contains("collision")
        );
    }

    #[test]
    fn sync_quota_survives_restart_and_serializes_concurrent_growth() {
        let calibration_dir = TempDir::new().unwrap();
        let calibration = new_shared_sync_state_at(calibration_dir.path()).unwrap();
        calibration
            .claim_space_owner("space-1", &test_peer("peer-owner"))
            .unwrap();
        calibration
            .upsert_store_entry(test_store_entry("peer-00"))
            .unwrap();
        calibration
            .upsert_store_entry(test_store_entry("peer-01"))
            .unwrap();
        let usage_with_two = current_logical_usage(&calibration);
        calibration
            .upsert_store_entry(test_store_entry("peer-02"))
            .unwrap();
        let one_entry_growth = current_logical_usage(&calibration) - usage_with_two;
        assert!(one_entry_growth > 0);

        let state_dir = TempDir::new().unwrap();
        {
            let state = new_shared_sync_state_at(state_dir.path()).unwrap();
            state
                .claim_space_owner("space-1", &test_peer("peer-owner"))
                .unwrap();
            state
                .upsert_store_entry(test_store_entry("peer-00"))
                .unwrap();
            state
                .upsert_store_entry(test_store_entry("peer-01"))
                .unwrap();
            assert_eq!(current_logical_usage(&state), usage_with_two);
        }

        let quota = usage_with_two + one_entry_growth;
        let state = Arc::new(SharedSyncState::open_with_limit(state_dir.path(), quota).unwrap());
        let attempts: Vec<_> = (2..10)
            .map(|index| {
                let state = Arc::clone(&state);
                thread::spawn(move || {
                    let key = format!("peer-{index:02}");
                    let accepted = state.upsert_store_entry(test_store_entry(&key)).is_ok();
                    (key, accepted)
                })
            })
            .collect();
        let results: Vec<_> = attempts
            .into_iter()
            .map(|attempt| attempt.join().unwrap())
            .collect();
        let accepted: Vec<_> = results
            .iter()
            .filter(|(_, accepted)| *accepted)
            .map(|(key, _)| key.clone())
            .collect();
        assert_eq!(accepted.len(), 1);
        assert_eq!(current_logical_usage(&state), quota);

        let accepted_key = accepted[0].clone();
        let retries: Vec<_> = (0..8)
            .map(|_| {
                let state = Arc::clone(&state);
                let key = accepted_key.clone();
                thread::spawn(move || state.upsert_store_entry(test_store_entry(&key)))
            })
            .collect();
        for retry in retries {
            retry.join().unwrap().unwrap();
        }
        assert_eq!(current_logical_usage(&state), quota);
        assert!(
            state
                .upsert_store_entry(test_store_entry("peer-10"))
                .unwrap_err()
                .to_string()
                .contains("sync state quota exceeded")
        );
        drop(state);

        let reopened = SharedSyncState::open_with_limit(state_dir.path(), quota).unwrap();
        assert_eq!(current_logical_usage(&reopened), quota);
        assert_eq!(
            reopened.read().unwrap()["space-1"].store_key_values.len(),
            3
        );
        assert!(
            reopened
                .upsert_store_entry(test_store_entry("peer-10"))
                .is_err()
        );
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
    fn list_acl_records_includes_root_when_present() {
        let state = new_shared_sync_state();
        state
            .upsert_space_metadata(
                "space-1",
                None,
                Some(b"acl-root-raw".to_vec()),
                Some("acl-root-id".to_string()),
                None,
                None,
                None,
                None,
            )
            .unwrap();
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

        let records = state.list_acl_records("space-1", "");
        assert_eq!(records.len(), 2);
        assert_eq!(
            RawRecordWithId::decode(records[0].as_slice()).unwrap().id,
            "acl-root-id"
        );
        assert_eq!(
            RawRecordWithId::decode(records[1].as_slice()).unwrap().id,
            "cid-1"
        );

        let after_root = state.list_acl_records("space-1", "acl-root-id");
        assert_eq!(after_root.len(), 1);
        assert_eq!(
            RawRecordWithId::decode(after_root[0].as_slice())
                .unwrap()
                .id,
            "cid-1"
        );
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
                    Some(&test_peer("peer-1")),
                )
                .unwrap();
            state.mark_space_shared("space-1").unwrap();
        }

        let reopened = new_shared_sync_state_at(temp_dir.path()).unwrap();
        assert!(reopened.read().unwrap()["space-1"].is_shared);
    }

    #[test]
    fn first_owner_claim_is_immutable_and_persists() {
        let temp_dir = TempDir::new().unwrap();
        {
            let state = new_shared_sync_state_at(temp_dir.path()).unwrap();
            state
                .upsert_space_metadata(
                    "space-1",
                    Some(b"header".to_vec()),
                    None,
                    None,
                    None,
                    None,
                    Some(false),
                    None,
                )
                .unwrap();
            assert!(
                state
                    .authorize_space("space-1", &test_peer("peer-1"))
                    .is_err()
            );

            state
                .claim_space_owner("space-1", &test_peer("peer-1"))
                .unwrap();
            state
                .claim_space_owner("space-1", &test_peer("peer-1"))
                .unwrap();
            assert!(
                state
                    .claim_space_owner("space-1", &test_peer("peer-2"))
                    .is_err()
            );
            assert!(
                state
                    .upsert_space_metadata(
                        "space-1",
                        None,
                        None,
                        None,
                        None,
                        None,
                        None,
                        Some(&test_peer("peer-2")),
                    )
                    .is_err()
            );
        }

        let reopened = new_shared_sync_state_at(temp_dir.path()).unwrap();
        reopened
            .authorize_space("space-1", &test_peer("peer-1"))
            .unwrap();
        assert!(
            reopened
                .authorize_space("space-1", &test_peer("peer-2"))
                .is_err()
        );
        let snapshot = reopened.read().unwrap();
        assert_eq!(snapshot["space-1"].owner_peer_id, "peer-1");
        assert_eq!(snapshot["space-1"].owner_account_identity, Some([0; 32]));
    }

    #[test]
    fn concurrent_first_claims_choose_one_durable_principal() {
        let temp_dir = TempDir::new().unwrap();
        let state = Arc::new(new_shared_sync_state_at(temp_dir.path()).unwrap());
        let barrier = Arc::new(Barrier::new(3));
        let attempts: Vec<_> = [("peer-1", [1; 32]), ("peer-2", [2; 32])]
            .into_iter()
            .map(|(peer_id, account_identity)| {
                let state = Arc::clone(&state);
                let barrier = Arc::clone(&barrier);
                thread::spawn(move || {
                    let principal =
                        AuthenticatedPeer::for_test_with_account(peer_id, account_identity);
                    barrier.wait();
                    (principal, state.claim_space_owner("space-1", &principal))
                })
            })
            .collect();

        barrier.wait();
        let results: Vec<_> = attempts
            .into_iter()
            .map(|attempt| attempt.join().unwrap())
            .collect();
        assert_eq!(
            results.iter().filter(|(_, result)| result.is_ok()).count(),
            1
        );
        let winner = results
            .iter()
            .find_map(|(principal, result)| result.is_ok().then_some(*principal))
            .unwrap();
        let loser = results
            .iter()
            .find_map(|(principal, result)| result.is_err().then_some(*principal))
            .unwrap();
        drop(state);

        let reopened = new_shared_sync_state_at(temp_dir.path()).unwrap();
        reopened.authorize_space("space-1", &winner).unwrap();
        assert!(reopened.authorize_space("space-1", &loser).is_err());
    }
}
