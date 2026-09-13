//! Durable file-node handlers backed by a filesystem CAS plus redb metadata.

use std::fmt;
use std::io::Cursor;
use std::path::Path;
use std::sync::{Arc, Mutex};

use cid::Cid;
use multihash_codetable::{Code, MultihashDigest};
use prost::Message;

use manytype_core::crdt::cid::cid_bytes_to_string;
use manytype_proto::filesync::{
    AccountInfoRequest, AccountInfoResponse, AvailabilityStatus, BlockAvailability,
    BlockGetRequest, BlockGetResponse, BlockPushManyRequest, BlockPushRequest, BlocksBindRequest,
    BlocksCheckRequest, BlocksCheckResponse, CheckRequest, CheckResponse, ErrCodes,
    FilesDeleteRequest, FilesDeleteResponse, Ok as FilesyncOk, SpaceInfoRequest, SpaceInfoResponse,
};

use crate::auth::AuthenticatedPeer;
use crate::config::ResourceLimits;
use crate::storage::blob_index::{BlobIndex, SpaceUsage};
use crate::storage::blob_store::BlobStore;
use crate::storage::sync_state::SharedSyncState;

type Result<T> = std::result::Result<T, FileNodeError>;

#[derive(Clone)]
pub struct FileNodeState {
    blob_index: Arc<BlobIndex>,
    blob_store: Arc<BlobStore>,
    limits: ResourceLimits,
    quota_lock: Arc<Mutex<()>>,
}

impl FileNodeState {
    pub fn open(config_path: impl AsRef<Path>) -> anyhow::Result<Self> {
        Self::open_with_limits(config_path, ResourceLimits::default())
    }

    pub fn open_with_limits(
        config_path: impl AsRef<Path>,
        limits: ResourceLimits,
    ) -> anyhow::Result<Self> {
        Ok(Self {
            blob_index: Arc::new(BlobIndex::open_with_limit(
                config_path.as_ref(),
                limits.max_file_index_bytes,
            )?),
            blob_store: Arc::new(BlobStore::open(config_path.as_ref())?),
            limits,
            quota_lock: Arc::new(Mutex::new(())),
        })
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FileNodeError {
    code: ErrCodes,
    detail: String,
}

impl FileNodeError {
    fn new(code: ErrCodes, detail: impl Into<String>) -> Self {
        Self {
            code,
            detail: detail.into(),
        }
    }

    pub fn code(&self) -> ErrCodes {
        self.code
    }

    fn unexpected(error: impl fmt::Display) -> Self {
        Self::new(ErrCodes::Unexpected, error.to_string())
    }

    fn invalid_cid(error: impl fmt::Display) -> Self {
        Self::new(ErrCodes::Unexpected, format!("invalid cid: {error}"))
    }

    fn forbidden(detail: impl Into<String>) -> Self {
        Self::new(ErrCodes::Forbidden, detail)
    }

    fn cid_not_found(detail: impl Into<String>) -> Self {
        Self::new(ErrCodes::CidNotFound, detail)
    }

    fn wrong_hash(detail: impl Into<String>) -> Self {
        Self::new(ErrCodes::WrongHash, detail)
    }
}

impl fmt::Display for FileNodeError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if self.detail.is_empty() {
            write!(f, "{}", self.code.as_str_name())
        } else {
            write!(f, "{}: {}", self.code.as_str_name(), self.detail)
        }
    }
}

impl std::error::Error for FileNodeError {}

pub fn handle_blocks_check(
    request_bytes: &[u8],
    state: &FileNodeState,
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let request = BlocksCheckRequest::decode(request_bytes).map_err(FileNodeError::unexpected)?;
    let is_authorized = sync_state.peer_owns_space(&request.space_id, authenticated_peer);
    let owned_space_ids = sync_state.owned_space_ids(authenticated_peer);

    let mut availability = Vec::with_capacity(request.cids.len());
    for cid_bytes in request.cids {
        let cid = cid_bytes_to_string(&cid_bytes).map_err(FileNodeError::invalid_cid)?;
        let is_public = state
            .blob_index
            .is_public_invite(&cid)
            .map_err(FileNodeError::unexpected)?;
        let status = if !state.blob_store.has(&cid) {
            AvailabilityStatus::NotExists
        } else if is_public {
            AvailabilityStatus::Exists
        } else if !is_authorized {
            AvailabilityStatus::NotExists
        } else if state
            .blob_index
            .space_has_cid(&request.space_id, &cid)
            .map_err(FileNodeError::unexpected)?
        {
            AvailabilityStatus::ExistsInSpace
        } else if blob_bound_to_any_space(state, &owned_space_ids, &cid)? {
            AvailabilityStatus::Exists
        } else {
            AvailabilityStatus::NotExists
        };
        availability.push(BlockAvailability {
            cid: cid_bytes,
            status: status as i32,
        });
    }

    Ok(BlocksCheckResponse {
        blocks_availability: availability,
    }
    .encode_to_vec())
}

pub fn handle_block_push(
    request_bytes: &[u8],
    state: &FileNodeState,
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let request = BlockPushRequest::decode(request_bytes).map_err(FileNodeError::unexpected)?;
    ensure_space_authorized(&request.space_id, sync_state, authenticated_peer)?;
    put_and_bind_block(
        state,
        sync_state,
        authenticated_peer,
        &request.space_id,
        &request.file_id,
        &request.cid,
        &request.data,
    )?;

    Ok(FilesyncOk {}.encode_to_vec())
}

pub fn handle_block_push_many(
    request_bytes: &[u8],
    state: &FileNodeState,
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let request = BlockPushManyRequest::decode(request_bytes).map_err(FileNodeError::unexpected)?;
    for file_blocks in request.file_blocks {
        ensure_space_authorized(&file_blocks.space_id, sync_state, authenticated_peer)?;
        for block in file_blocks.blocks {
            put_and_bind_block(
                state,
                sync_state,
                authenticated_peer,
                &file_blocks.space_id,
                &file_blocks.file_id,
                &block.cid,
                &block.data,
            )?;
        }
    }

    Ok(FilesyncOk {}.encode_to_vec())
}

pub fn handle_blocks_bind(
    request_bytes: &[u8],
    state: &FileNodeState,
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let request = BlocksBindRequest::decode(request_bytes).map_err(FileNodeError::unexpected)?;
    ensure_space_authorized(&request.space_id, sync_state, authenticated_peer)?;
    let owned_space_ids = sync_state.owned_space_ids(authenticated_peer);

    for cid_bytes in request.cids {
        let cid = cid_bytes_to_string(&cid_bytes).map_err(FileNodeError::invalid_cid)?;
        // Binding grants BlockGet access, so it is limited to blobs the peer
        // already holds; anything else must be uploaded with BlockPush.
        let is_public = state
            .blob_index
            .is_public_invite(&cid)
            .map_err(FileNodeError::unexpected)?;
        if !is_public && !blob_bound_to_any_space(state, &owned_space_ids, &cid)? {
            return Err(FileNodeError::cid_not_found(format!("cid {cid} not found")));
        }
        let Some(data) = state
            .blob_store
            .get(&cid)
            .map_err(FileNodeError::unexpected)?
        else {
            return Err(FileNodeError::cid_not_found(format!("cid {cid} not found")));
        };
        let _quota_guard = state
            .quota_lock
            .lock()
            .map_err(|_| FileNodeError::unexpected("storage quota lock is poisoned"))?;
        ensure_storage_quota(
            state,
            sync_state,
            authenticated_peer,
            &request.space_id,
            &cid,
            data.len() as u64,
        )?;
        state
            .blob_index
            .bind_blob(&request.space_id, &request.file_id, &cid, data.len() as u64)
            .map_err(FileNodeError::unexpected)?;
    }

    Ok(FilesyncOk {}.encode_to_vec())
}

pub fn handle_files_delete(
    request_bytes: &[u8],
    _state: &FileNodeState,
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let request = FilesDeleteRequest::decode(request_bytes).map_err(FileNodeError::unexpected)?;
    ensure_space_authorized(&request.space_id, sync_state, authenticated_peer)?;
    Ok(FilesDeleteResponse {}.encode_to_vec())
}

pub fn handle_block_get(
    request_bytes: &[u8],
    state: &FileNodeState,
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let request = BlockGetRequest::decode(request_bytes).map_err(FileNodeError::unexpected)?;
    let cid = cid_bytes_to_string(&request.cid).map_err(FileNodeError::invalid_cid)?;
    let is_public = state
        .blob_index
        .is_public_invite(&cid)
        .map_err(FileNodeError::unexpected)?;
    tracing::info!(
        "file: BlockGet cid={} space_id={} wait={} public={}",
        cid,
        request.space_id,
        request.wait,
        is_public
    );
    if is_public {
        let Some(data) = state
            .blob_store
            .get(&cid)
            .map_err(FileNodeError::unexpected)?
        else {
            return Err(FileNodeError::cid_not_found(format!("cid {cid} not found")));
        };

        return Ok(BlockGetResponse {
            cid: request.cid,
            data,
        }
        .encode_to_vec());
    }

    ensure_space_authorized(&request.space_id, sync_state, authenticated_peer)?;
    if !state
        .blob_index
        .space_has_cid(&request.space_id, &cid)
        .map_err(FileNodeError::unexpected)?
    {
        return Err(FileNodeError::cid_not_found(format!(
            "cid {cid} is not bound to space {}",
            request.space_id
        )));
    }
    let Some(data) = state
        .blob_store
        .get(&cid)
        .map_err(FileNodeError::unexpected)?
    else {
        return Err(FileNodeError::cid_not_found(format!("cid {cid} not found")));
    };

    Ok(BlockGetResponse {
        cid: request.cid,
        data,
    }
    .encode_to_vec())
}

pub fn handle_check(
    request_bytes: &[u8],
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let _request = CheckRequest::decode(request_bytes).map_err(FileNodeError::unexpected)?;

    // Official Anytype clients gate *all* file-node activity behind a successful `Check`
    // response. When running against a custom coordinator+file peer (like manytype_server),
    // the client may not yet be registered as a space owner (e.g. before joining via invite).
    // Returning `allowWrite=false` or an empty space list can cause the client to ignore the
    // file node entirely, preventing invite fetch via `BlockGet`.
    //
    // We keep server-side authorization checks in the mutating RPCs, so advertising that the
    // node is writable here is safe.
    // Include the empty space id to support pre-join flows (SpaceInviteView) where
    // the official client fetches invite blocks without a known space id.
    let mut space_ids = sync_state.owned_space_ids(authenticated_peer);
    if space_ids.first().map(|id| !id.is_empty()).unwrap_or(true) {
        space_ids.insert(0, String::new());
    }

    Ok(CheckResponse {
        allow_write: true,
        space_ids,
    }
    .encode_to_vec())
}

pub fn handle_space_info(
    request_bytes: &[u8],
    state: &FileNodeState,
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let request = SpaceInfoRequest::decode(request_bytes).map_err(FileNodeError::unexpected)?;
    ensure_space_authorized(&request.space_id, sync_state, authenticated_peer)?;
    let usage = state
        .blob_index
        .get_space_usage(&request.space_id)
        .map_err(FileNodeError::unexpected)?;
    let account_snapshot = account_snapshot(sync_state, state, authenticated_peer)?;
    Ok(SpaceInfoResponse {
        limit_bytes: state.limits.max_space_storage_bytes,
        total_usage_bytes: account_snapshot.total_usage_bytes,
        cids_count: usage.cids_count,
        files_count: usage.files_count,
        space_usage_bytes: usage.usage_bytes,
        space_id: request.space_id,
    }
    .encode_to_vec())
}

pub fn handle_account_info(
    request_bytes: &[u8],
    state: &FileNodeState,
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let _request = AccountInfoRequest::decode(request_bytes).map_err(FileNodeError::unexpected)?;
    let snapshot = account_snapshot(sync_state, state, authenticated_peer)?;
    Ok(AccountInfoResponse {
        limit_bytes: state.limits.max_account_storage_bytes,
        total_usage_bytes: snapshot.total_usage_bytes,
        total_cids_count: snapshot.total_cids_count,
        spaces: snapshot
            .spaces
            .into_iter()
            .map(|(space_id, usage)| SpaceInfoResponse {
                limit_bytes: state.limits.max_space_storage_bytes,
                total_usage_bytes: snapshot.total_usage_bytes,
                cids_count: usage.cids_count,
                files_count: usage.files_count,
                space_usage_bytes: usage.usage_bytes,
                space_id,
            })
            .collect(),
        account_limit_bytes: state.limits.max_account_storage_bytes,
    }
    .encode_to_vec())
}

fn ensure_space_authorized(
    space_id: &str,
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<()> {
    if sync_state.peer_owns_space(space_id, authenticated_peer) {
        return Ok(());
    }
    Err(FileNodeError::forbidden(format!(
        "peer does not own or cannot access space {space_id}"
    )))
}

fn blob_bound_to_any_space(state: &FileNodeState, space_ids: &[String], cid: &str) -> Result<bool> {
    for space_id in space_ids {
        if state
            .blob_index
            .space_has_cid(space_id, cid)
            .map_err(FileNodeError::unexpected)?
        {
            return Ok(true);
        }
    }
    Ok(false)
}

fn put_and_bind_block(
    state: &FileNodeState,
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
    space_id: &str,
    file_id: &str,
    cid_bytes: &[u8],
    data: &[u8],
) -> Result<()> {
    ensure_blob_size(state, data.len() as u64)?;
    let claimed = Cid::read_bytes(Cursor::new(cid_bytes)).map_err(FileNodeError::invalid_cid)?;
    let claimed_cid = claimed
        .to_string_of_base(multibase::Base::Base32Lower)
        .map_err(FileNodeError::invalid_cid)?;
    let hash_code = Code::try_from(claimed.hash().code())
        .map_err(|error| FileNodeError::invalid_cid(format!("unsupported multihash: {error}")))?;
    let computed_hash = hash_code.digest(data);
    if claimed.hash().to_bytes() != computed_hash.to_bytes() {
        let computed_cid = Cid::new_v1(claimed.codec(), computed_hash)
            .to_string_of_base(multibase::Base::Base32Lower)
            .map_err(FileNodeError::invalid_cid)?;
        return Err(FileNodeError::wrong_hash(format!(
            "claimed {claimed_cid}, computed {computed_cid}"
        )));
    }

    let _quota_guard = state
        .quota_lock
        .lock()
        .map_err(|_| FileNodeError::unexpected("storage quota lock is poisoned"))?;
    ensure_storage_quota(
        state,
        sync_state,
        authenticated_peer,
        space_id,
        &claimed_cid,
        data.len() as u64,
    )?;
    let blob_preexisted = state.blob_store.has(&claimed_cid);
    state
        .blob_store
        .put(&claimed_cid, data)
        .map_err(FileNodeError::unexpected)?;
    if let Err(error) =
        state
            .blob_index
            .bind_blob(space_id, file_id, &claimed_cid, data.len() as u64)
    {
        if !blob_preexisted {
            state.blob_store.remove(&claimed_cid).map_err(|cleanup| {
                FileNodeError::unexpected(format!(
                    "failed to bind blob: {error}; failed to remove orphan blob: {cleanup}"
                ))
            })?;
        }
        return Err(FileNodeError::unexpected(error));
    }
    Ok(())
}

pub fn store_public_invite_block(
    state: &FileNodeState,
    cid_bytes: &[u8],
    data: &[u8],
) -> Result<()> {
    ensure_blob_size(state, data.len() as u64)?;
    let claimed = Cid::read_bytes(Cursor::new(cid_bytes)).map_err(FileNodeError::invalid_cid)?;
    let claimed_cid = claimed
        .to_string_of_base(multibase::Base::Base32Lower)
        .map_err(FileNodeError::invalid_cid)?;
    let hash_code = Code::try_from(claimed.hash().code())
        .map_err(|error| FileNodeError::invalid_cid(format!("unsupported multihash: {error}")))?;
    let computed_hash = hash_code.digest(data);
    if claimed.hash().to_bytes() != computed_hash.to_bytes() {
        let computed_cid = Cid::new_v1(claimed.codec(), computed_hash)
            .to_string_of_base(multibase::Base::Base32Lower)
            .map_err(FileNodeError::invalid_cid)?;
        return Err(FileNodeError::wrong_hash(format!(
            "claimed {claimed_cid}, computed {computed_cid}"
        )));
    }

    let _quota_guard = state
        .quota_lock
        .lock()
        .map_err(|_| FileNodeError::unexpected("storage quota lock is poisoned"))?;
    let global_usage = state
        .blob_index
        .get_global_usage()
        .map_err(FileNodeError::unexpected)?;
    let is_new = state
        .blob_index
        .get_blob_metadata(&claimed_cid)
        .map_err(FileNodeError::unexpected)?
        .is_none();
    if is_new {
        ensure_within_limit(
            "total storage",
            global_usage.total_usage_bytes,
            data.len() as u64,
            state.limits.max_total_storage_bytes,
        )?;
    }
    let blob_preexisted = state.blob_store.has(&claimed_cid);
    state
        .blob_store
        .put(&claimed_cid, data)
        .map_err(FileNodeError::unexpected)?;
    if let Err(error) = state
        .blob_index
        .register_public_invite(&claimed_cid, data.len() as u64)
    {
        if !blob_preexisted {
            state.blob_store.remove(&claimed_cid).map_err(|cleanup| {
                FileNodeError::unexpected(format!(
                    "failed to register public invite: {error}; failed to remove orphan blob: {cleanup}"
                ))
            })?;
        }
        return Err(FileNodeError::unexpected(error));
    }
    Ok(())
}

fn ensure_blob_size(state: &FileNodeState, size_bytes: u64) -> Result<()> {
    if size_bytes > state.limits.max_blob_bytes {
        return Err(FileNodeError::unexpected(format!(
            "blob size {size_bytes} exceeds {} byte limit",
            state.limits.max_blob_bytes
        )));
    }
    Ok(())
}

fn ensure_storage_quota(
    state: &FileNodeState,
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
    space_id: &str,
    cid: &str,
    size_bytes: u64,
) -> Result<()> {
    ensure_blob_size(state, size_bytes)?;
    let new_blob = state
        .blob_index
        .get_blob_metadata(cid)
        .map_err(FileNodeError::unexpected)?
        .is_none();
    let new_space_binding = !state
        .blob_index
        .space_has_cid(space_id, cid)
        .map_err(FileNodeError::unexpected)?;

    if new_blob {
        let global = state
            .blob_index
            .get_global_usage()
            .map_err(FileNodeError::unexpected)?;
        ensure_within_limit(
            "total storage",
            global.total_usage_bytes,
            size_bytes,
            state.limits.max_total_storage_bytes,
        )?;
    }
    if new_space_binding {
        let space = state
            .blob_index
            .get_space_usage(space_id)
            .map_err(FileNodeError::unexpected)?;
        ensure_within_limit(
            "space storage",
            space.usage_bytes,
            size_bytes,
            state.limits.max_space_storage_bytes,
        )?;
        let account = account_snapshot(sync_state, state, authenticated_peer)?;
        ensure_within_limit(
            "account storage",
            account.total_usage_bytes,
            size_bytes,
            state.limits.max_account_storage_bytes,
        )?;
    }
    Ok(())
}

fn ensure_within_limit(label: &str, used: u64, increase: u64, limit: u64) -> Result<()> {
    let requested = used
        .checked_add(increase)
        .ok_or_else(|| FileNodeError::unexpected(format!("{label} usage overflow")))?;
    if requested > limit {
        return Err(FileNodeError::unexpected(format!(
            "{label} quota exceeded: requested {requested} bytes, limit {limit} bytes"
        )));
    }
    Ok(())
}

struct AccountSnapshot {
    total_usage_bytes: u64,
    total_cids_count: u64,
    spaces: Vec<(String, SpaceUsage)>,
}

fn account_snapshot(
    sync_state: &SharedSyncState,
    state: &FileNodeState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<AccountSnapshot> {
    let owned_spaces = sync_state.owned_space_ids(authenticated_peer);
    let mut spaces = Vec::with_capacity(owned_spaces.len());
    let mut total_usage_bytes = 0u64;
    let mut total_cids_count = 0u64;

    for space_id in owned_spaces {
        let usage = state
            .blob_index
            .get_space_usage(&space_id)
            .map_err(FileNodeError::unexpected)?;
        total_usage_bytes = total_usage_bytes
            .checked_add(usage.usage_bytes)
            .ok_or_else(|| FileNodeError::unexpected("account usage overflow"))?;
        total_cids_count = total_cids_count
            .checked_add(usage.cids_count)
            .ok_or_else(|| FileNodeError::unexpected("account CID count overflow"))?;
        spaces.push((space_id, usage));
    }

    Ok(AccountSnapshot {
        total_usage_bytes,
        total_cids_count,
        spaces,
    })
}

#[cfg(test)]
mod tests {
    use tempfile::TempDir;

    use manytype_core::crdt::cid::{cid_string_to_bytes, compute_cid};

    use super::*;
    use crate::storage::sync_state::new_shared_sync_state_at;

    const OWNER_PEER_ID: &str = "peer-1";
    const OTHER_PEER_ID: &str = "peer-2";

    fn owner_peer() -> AuthenticatedPeer<'static> {
        AuthenticatedPeer::for_test(OWNER_PEER_ID)
    }

    fn other_peer() -> AuthenticatedPeer<'static> {
        AuthenticatedPeer::for_test(OTHER_PEER_ID)
    }

    fn seeded_sync_state(temp_dir: &TempDir) -> SharedSyncState {
        let path = temp_dir.path().join("sync.redb");
        let state = new_shared_sync_state_at(path).unwrap();
        state
            .upsert_space_metadata(
                "space-1",
                Some(vec![1]),
                None,
                None,
                None,
                None,
                Some(false),
                Some(&owner_peer()),
            )
            .unwrap();
        state
    }

    fn file_node_state(temp_dir: &TempDir) -> FileNodeState {
        FileNodeState::open(temp_dir.path().join("sync.redb")).unwrap()
    }

    fn file_node_state_with_limits(temp_dir: &TempDir, limits: ResourceLimits) -> FileNodeState {
        FileNodeState::open_with_limits(temp_dir.path().join("sync.redb"), limits).unwrap()
    }

    fn compute_raw_cid_bytes(data: &[u8]) -> Vec<u8> {
        let hash = Code::Sha2_256.digest(data);
        Cid::new_v1(0x55, hash).to_bytes()
    }

    fn compute_raw_cid(data: &[u8]) -> String {
        cid_bytes_to_string(&compute_raw_cid_bytes(data)).unwrap()
    }

    #[test]
    fn block_push_persists_and_block_get_returns_bytes_after_reopen() {
        let temp_dir = TempDir::new().unwrap();
        let sync_state = seeded_sync_state(&temp_dir);
        let payload = b"block-data-bytes".to_vec();
        let cid = compute_cid(&payload);
        let cid_bytes = cid_string_to_bytes(&cid).unwrap();

        {
            let state = file_node_state(&temp_dir);
            let request = BlockPushRequest {
                space_id: "space-1".to_string(),
                file_id: "file-1".to_string(),
                cid: cid_bytes.clone(),
                data: payload.clone(),
            };
            let response_bytes =
                handle_block_push(&request.encode_to_vec(), &state, &sync_state, &owner_peer())
                    .unwrap();
            let _ok = FilesyncOk::decode(response_bytes.as_slice()).unwrap();
        }

        let reopened = file_node_state(&temp_dir);
        let response_bytes = handle_block_get(
            &BlockGetRequest {
                space_id: "space-1".to_string(),
                cid: cid_bytes,
                wait: false,
            }
            .encode_to_vec(),
            &reopened,
            &sync_state,
            &owner_peer(),
        )
        .unwrap();
        let response = BlockGetResponse::decode(response_bytes.as_slice()).unwrap();
        assert_eq!(response.data, payload);
    }

    #[test]
    fn blocks_check_reports_not_exists_exists_and_exists_in_space() {
        let temp_dir = TempDir::new().unwrap();
        let sync_state = seeded_sync_state(&temp_dir);
        let state = file_node_state(&temp_dir);

        let payload = b"block-data-bytes".to_vec();
        let cid = compute_cid(&payload);
        let cid_bytes = cid_string_to_bytes(&cid).unwrap();

        handle_block_push(
            &BlockPushRequest {
                space_id: "space-1".to_string(),
                file_id: "file-1".to_string(),
                cid: cid_bytes.clone(),
                data: payload,
            }
            .encode_to_vec(),
            &state,
            &sync_state,
            &owner_peer(),
        )
        .unwrap();

        sync_state
            .upsert_space_metadata(
                "space-2",
                Some(vec![2]),
                None,
                None,
                None,
                None,
                Some(false),
                Some(&owner_peer()),
            )
            .unwrap();

        let in_space = BlocksCheckResponse::decode(
            handle_blocks_check(
                &BlocksCheckRequest {
                    space_id: "space-1".to_string(),
                    cids: vec![cid_bytes.clone()],
                }
                .encode_to_vec(),
                &state,
                &sync_state,
                &owner_peer(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        assert_eq!(
            in_space.blocks_availability[0].status,
            AvailabilityStatus::ExistsInSpace as i32
        );

        let exists_elsewhere = BlocksCheckResponse::decode(
            handle_blocks_check(
                &BlocksCheckRequest {
                    space_id: "space-2".to_string(),
                    cids: vec![cid_bytes.clone()],
                }
                .encode_to_vec(),
                &state,
                &sync_state,
                &owner_peer(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        assert_eq!(
            exists_elsewhere.blocks_availability[0].status,
            AvailabilityStatus::Exists as i32
        );

        let missing = BlocksCheckResponse::decode(
            handle_blocks_check(
                &BlocksCheckRequest {
                    space_id: "space-1".to_string(),
                    cids: vec![cid_string_to_bytes(&compute_cid(b"missing")).unwrap()],
                }
                .encode_to_vec(),
                &state,
                &sync_state,
                &owner_peer(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        assert_eq!(
            missing.blocks_availability[0].status,
            AvailabilityStatus::NotExists as i32
        );
    }

    #[test]
    fn block_push_rejects_wrong_hash() {
        let temp_dir = TempDir::new().unwrap();
        let sync_state = seeded_sync_state(&temp_dir);
        let state = file_node_state(&temp_dir);

        let error = handle_block_push(
            &BlockPushRequest {
                space_id: "space-1".to_string(),
                file_id: "file-1".to_string(),
                cid: cid_string_to_bytes(&compute_cid(b"claimed")).unwrap(),
                data: b"actual".to_vec(),
            }
            .encode_to_vec(),
            &state,
            &sync_state,
            &owner_peer(),
        )
        .unwrap_err()
        .to_string();

        assert!(error.contains("WrongHash"));
    }

    #[test]
    fn block_push_many_persists_multiple_blocks() {
        let temp_dir = TempDir::new().unwrap();
        let sync_state = seeded_sync_state(&temp_dir);
        let state = file_node_state(&temp_dir);
        let payload_a = b"block-a".to_vec();
        let payload_b = b"block-b".to_vec();
        let cid_a = cid_string_to_bytes(&compute_cid(&payload_a)).unwrap();
        let cid_b = cid_string_to_bytes(&compute_cid(&payload_b)).unwrap();

        let response = handle_block_push_many(
            &BlockPushManyRequest {
                file_blocks: vec![manytype_proto::filesync::FileBlocks {
                    file_id: "file-1".to_string(),
                    space_id: "space-1".to_string(),
                    blocks: vec![
                        manytype_proto::filesync::Block {
                            cid: cid_a.clone(),
                            data: payload_a.clone(),
                        },
                        manytype_proto::filesync::Block {
                            cid: cid_b.clone(),
                            data: payload_b.clone(),
                        },
                    ],
                }],
            }
            .encode_to_vec(),
            &state,
            &sync_state,
            &owner_peer(),
        )
        .unwrap();
        let _ok = FilesyncOk::decode(response.as_slice()).unwrap();

        let got_a = BlockGetResponse::decode(
            handle_block_get(
                &BlockGetRequest {
                    space_id: "space-1".to_string(),
                    cid: cid_a,
                    wait: false,
                }
                .encode_to_vec(),
                &state,
                &sync_state,
                &owner_peer(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        assert_eq!(got_a.data, payload_a);

        let got_b = BlockGetResponse::decode(
            handle_block_get(
                &BlockGetRequest {
                    space_id: "space-1".to_string(),
                    cid: cid_b,
                    wait: false,
                }
                .encode_to_vec(),
                &state,
                &sync_state,
                &owner_peer(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        assert_eq!(got_b.data, payload_b);
    }

    #[test]
    fn block_push_accepts_raw_file_cid_codec() {
        let temp_dir = TempDir::new().unwrap();
        let sync_state = seeded_sync_state(&temp_dir);
        let state = file_node_state(&temp_dir);
        let payload = b"file-block-data".to_vec();
        let cid_bytes = compute_raw_cid_bytes(&payload);

        let response = handle_block_push(
            &BlockPushRequest {
                space_id: "space-1".to_string(),
                file_id: "file-1".to_string(),
                cid: cid_bytes.clone(),
                data: payload.clone(),
            }
            .encode_to_vec(),
            &state,
            &sync_state,
            &owner_peer(),
        )
        .unwrap();
        let _ok = FilesyncOk::decode(response.as_slice()).unwrap();

        let got = BlockGetResponse::decode(
            handle_block_get(
                &BlockGetRequest {
                    space_id: "space-1".to_string(),
                    cid: cid_bytes,
                    wait: false,
                }
                .encode_to_vec(),
                &state,
                &sync_state,
                &owner_peer(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        assert_eq!(got.data, payload);
    }

    #[test]
    fn blocks_bind_attaches_existing_blob_to_new_file() {
        let temp_dir = TempDir::new().unwrap();
        let sync_state = seeded_sync_state(&temp_dir);
        let state = file_node_state(&temp_dir);
        let payload = b"block-data-bytes".to_vec();
        let cid = cid_string_to_bytes(&compute_cid(&payload)).unwrap();

        handle_block_push(
            &BlockPushRequest {
                space_id: "space-1".to_string(),
                file_id: "file-1".to_string(),
                cid: cid.clone(),
                data: payload,
            }
            .encode_to_vec(),
            &state,
            &sync_state,
            &owner_peer(),
        )
        .unwrap();

        let response = handle_blocks_bind(
            &BlocksBindRequest {
                space_id: "space-1".to_string(),
                file_id: "file-2".to_string(),
                cids: vec![cid.clone()],
            }
            .encode_to_vec(),
            &state,
            &sync_state,
            &owner_peer(),
        )
        .unwrap();
        let _ok = FilesyncOk::decode(response.as_slice()).unwrap();

        let binding = state
            .blob_index
            .get_file_binding("space-1", "file-2")
            .unwrap()
            .unwrap();
        assert_eq!(binding.cids, vec![compute_cid(b"block-data-bytes")]);
    }

    #[test]
    fn block_get_returns_missing_cid_error() {
        let temp_dir = TempDir::new().unwrap();
        let state = file_node_state(&temp_dir);

        let error = handle_block_get(
            &BlockGetRequest {
                space_id: "space-1".to_string(),
                cid: cid_string_to_bytes(&compute_cid(b"missing")).unwrap(),
                wait: false,
            }
            .encode_to_vec(),
            &state,
            &seeded_sync_state(&temp_dir),
            &owner_peer(),
        )
        .unwrap_err()
        .to_string();

        assert!(error.contains("CIDNotFound"));
    }

    #[test]
    fn block_push_rejects_unknown_space_as_forbidden() {
        let temp_dir = TempDir::new().unwrap();
        let sync_state = new_shared_sync_state_at(temp_dir.path().join("sync.redb")).unwrap();
        let state = file_node_state(&temp_dir);
        let payload = b"block-data-bytes".to_vec();
        let cid = cid_string_to_bytes(&compute_cid(&payload)).unwrap();

        let error = handle_block_push(
            &BlockPushRequest {
                space_id: "missing-space".to_string(),
                file_id: "file-1".to_string(),
                cid,
                data: payload,
            }
            .encode_to_vec(),
            &state,
            &sync_state,
            &owner_peer(),
        )
        .unwrap_err()
        .to_string();

        assert!(error.contains("Forbidden"));
    }

    #[test]
    fn check_lists_owned_spaces_plus_prejoin_placeholder() {
        // The pre-join placeholder is public, but private space IDs are scoped
        // to the authenticated owner.
        let temp_dir = TempDir::new().unwrap();
        let sync_state = seeded_sync_state(&temp_dir);
        let response = CheckResponse::decode(
            handle_check(&CheckRequest {}.encode_to_vec(), &sync_state, &owner_peer())
                .unwrap()
                .as_slice(),
        )
        .unwrap();
        assert_eq!(
            response.space_ids,
            vec![String::new(), "space-1".to_string()]
        );
        assert!(response.allow_write);

        let other = CheckResponse::decode(
            handle_check(&CheckRequest {}.encode_to_vec(), &sync_state, &other_peer())
                .unwrap()
                .as_slice(),
        )
        .unwrap();
        assert_eq!(other.space_ids, vec![String::new()]);
        assert!(other.allow_write);
    }

    #[test]
    fn space_info_and_account_info_report_real_usage() {
        let temp_dir = TempDir::new().unwrap();
        let sync_state = seeded_sync_state(&temp_dir);
        let state = file_node_state(&temp_dir);
        let payload = b"block-data-bytes".to_vec();
        let cid = cid_string_to_bytes(&compute_cid(&payload)).unwrap();

        handle_block_push(
            &BlockPushRequest {
                space_id: "space-1".to_string(),
                file_id: "file-1".to_string(),
                cid,
                data: payload.clone(),
            }
            .encode_to_vec(),
            &state,
            &sync_state,
            &owner_peer(),
        )
        .unwrap();

        let space_info = SpaceInfoResponse::decode(
            handle_space_info(
                &SpaceInfoRequest {
                    space_id: "space-1".to_string(),
                }
                .encode_to_vec(),
                &state,
                &sync_state,
                &owner_peer(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        assert_eq!(space_info.space_usage_bytes, payload.len() as u64);
        assert_eq!(space_info.cids_count, 1);
        assert_eq!(space_info.files_count, 1);
        assert_eq!(space_info.total_usage_bytes, payload.len() as u64);
        assert_eq!(
            space_info.limit_bytes,
            ResourceLimits::default().max_space_storage_bytes
        );

        let account_info = AccountInfoResponse::decode(
            handle_account_info(
                &AccountInfoRequest {}.encode_to_vec(),
                &state,
                &sync_state,
                &owner_peer(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        assert_eq!(account_info.total_usage_bytes, payload.len() as u64);
        assert_eq!(account_info.total_cids_count, 1);
        assert_eq!(account_info.spaces.len(), 1);
        assert_eq!(account_info.spaces[0].space_id, "space-1");
        assert_eq!(
            account_info.limit_bytes,
            ResourceLimits::default().max_account_storage_bytes
        );
        assert_eq!(
            account_info.account_limit_bytes,
            ResourceLimits::default().max_account_storage_bytes
        );
        assert_eq!(
            account_info.spaces[0].limit_bytes,
            ResourceLimits::default().max_space_storage_bytes
        );
    }

    #[test]
    fn block_push_rejects_blob_over_configured_limit() {
        let temp_dir = TempDir::new().unwrap();
        let sync_state = seeded_sync_state(&temp_dir);
        let limits = ResourceLimits {
            max_blob_bytes: 4,
            ..ResourceLimits::default()
        };
        let state = file_node_state_with_limits(&temp_dir, limits);
        let payload = b"12345".to_vec();
        let cid = compute_cid(&payload);

        let error = handle_block_push(
            &BlockPushRequest {
                space_id: "space-1".to_string(),
                file_id: "file-1".to_string(),
                cid: cid_string_to_bytes(&cid).unwrap(),
                data: payload,
            }
            .encode_to_vec(),
            &state,
            &sync_state,
            &owner_peer(),
        )
        .unwrap_err();

        assert!(error.to_string().contains("blob size"));
        assert!(!state.blob_store.has(&cid));
    }

    #[test]
    fn block_push_keeps_existing_data_when_storage_quota_is_exhausted() {
        let temp_dir = TempDir::new().unwrap();
        let sync_state = seeded_sync_state(&temp_dir);
        let limits = ResourceLimits {
            max_blob_bytes: 5,
            max_space_storage_bytes: 5,
            max_account_storage_bytes: 5,
            max_total_storage_bytes: 5,
            ..ResourceLimits::default()
        };
        let state = file_node_state_with_limits(&temp_dir, limits);
        let first = b"1234".to_vec();
        let first_cid = compute_cid(&first);
        handle_block_push(
            &BlockPushRequest {
                space_id: "space-1".to_string(),
                file_id: "file-1".to_string(),
                cid: cid_string_to_bytes(&first_cid).unwrap(),
                data: first,
            }
            .encode_to_vec(),
            &state,
            &sync_state,
            &owner_peer(),
        )
        .unwrap();

        let second = b"567".to_vec();
        let second_cid = compute_cid(&second);
        let error = handle_block_push(
            &BlockPushRequest {
                space_id: "space-1".to_string(),
                file_id: "file-2".to_string(),
                cid: cid_string_to_bytes(&second_cid).unwrap(),
                data: second,
            }
            .encode_to_vec(),
            &state,
            &sync_state,
            &owner_peer(),
        )
        .unwrap_err();

        assert!(error.to_string().contains("quota exceeded"));
        assert!(state.blob_store.has(&first_cid));
        assert!(!state.blob_store.has(&second_cid));
    }

    #[test]
    fn block_push_removes_new_blob_when_file_index_quota_is_exhausted() {
        let temp_dir = TempDir::new().unwrap();
        let sync_state = seeded_sync_state(&temp_dir);
        let first = b"first".to_vec();
        let first_cid = compute_cid(&first);
        let index_usage = {
            let state = file_node_state(&temp_dir);
            handle_block_push(
                &BlockPushRequest {
                    space_id: "space-1".to_string(),
                    file_id: "file-1".to_string(),
                    cid: cid_string_to_bytes(&first_cid).unwrap(),
                    data: first,
                }
                .encode_to_vec(),
                &state,
                &sync_state,
                &owner_peer(),
            )
            .unwrap();
            state
                .blob_index
                .get_global_usage()
                .unwrap()
                .index_usage_bytes
        };

        let limits = ResourceLimits {
            max_file_index_bytes: index_usage,
            ..ResourceLimits::default()
        };
        let state = file_node_state_with_limits(&temp_dir, limits);
        let second = b"second".to_vec();
        let second_cid = compute_cid(&second);
        let error = handle_block_push(
            &BlockPushRequest {
                space_id: "space-1".to_string(),
                file_id: "file-2".to_string(),
                cid: cid_string_to_bytes(&second_cid).unwrap(),
                data: second,
            }
            .encode_to_vec(),
            &state,
            &sync_state,
            &owner_peer(),
        )
        .unwrap_err();

        assert!(error.to_string().contains("file index quota exceeded"));
        assert!(state.blob_store.has(&first_cid));
        assert!(!state.blob_store.has(&second_cid));
        assert_eq!(
            state
                .blob_index
                .get_global_usage()
                .unwrap()
                .index_usage_bytes,
            index_usage
        );
    }

    #[test]
    fn public_invites_share_the_global_storage_quota() {
        let temp_dir = TempDir::new().unwrap();
        let limits = ResourceLimits {
            max_blob_bytes: 6,
            max_space_storage_bytes: 6,
            max_account_storage_bytes: 6,
            max_total_storage_bytes: 10,
            ..ResourceLimits::default()
        };
        let first = b"123456";
        let second = b"abcdef";

        {
            let state = file_node_state_with_limits(&temp_dir, limits.clone());
            store_public_invite_block(&state, &compute_raw_cid_bytes(first), first).unwrap();
        }
        let state = file_node_state_with_limits(&temp_dir, limits);
        let error =
            store_public_invite_block(&state, &compute_raw_cid_bytes(second), second).unwrap_err();

        assert!(error.to_string().contains("total storage quota exceeded"));
        assert_eq!(
            state
                .blob_index
                .get_global_usage()
                .unwrap()
                .total_usage_bytes,
            first.len() as u64
        );
        assert!(!state.blob_store.has(&compute_raw_cid(second)));
    }

    #[test]
    fn failed_public_invite_registration_removes_a_new_orphan_blob() {
        let temp_dir = TempDir::new().unwrap();
        let state = file_node_state(&temp_dir);
        let payload = b"invite";
        let cid = compute_raw_cid(payload);
        state
            .blob_index
            .bind_blob("space-1", "file-1", &cid, payload.len() as u64 + 1)
            .unwrap();

        let error = store_public_invite_block(&state, &compute_raw_cid_bytes(payload), payload)
            .unwrap_err();

        assert!(error.to_string().contains("blob metadata mismatch"));
        assert!(!state.blob_store.has(&cid));
    }

    #[test]
    fn blocks_check_is_allowed_for_unbound_peers() {
        use manytype_proto::filesync::{AvailabilityStatus, BlocksCheckResponse};

        let temp_dir = TempDir::new().unwrap();
        let sync_state = seeded_sync_state(&temp_dir);
        let state = file_node_state(&temp_dir);

        let response = BlocksCheckResponse::decode(
            handle_blocks_check(
                &BlocksCheckRequest {
                    space_id: "space-1".to_string(),
                    cids: vec![cid_string_to_bytes(&compute_cid(b"missing")).unwrap()],
                }
                .encode_to_vec(),
                &state,
                &sync_state,
                &other_peer(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();

        assert_eq!(response.blocks_availability.len(), 1);
        assert_eq!(
            response.blocks_availability[0].status,
            AvailabilityStatus::NotExists as i32
        );
    }

    #[test]
    fn block_get_requires_space_binding() {
        let temp_dir = TempDir::new().unwrap();
        let sync_state = seeded_sync_state(&temp_dir);
        let state = file_node_state(&temp_dir);
        let payload = b"block-data-bytes".to_vec();
        let cid = cid_string_to_bytes(&compute_cid(&payload)).unwrap();

        handle_block_push(
            &BlockPushRequest {
                space_id: "space-1".to_string(),
                file_id: "file-1".to_string(),
                cid: cid.clone(),
                data: payload,
            }
            .encode_to_vec(),
            &state,
            &sync_state,
            &owner_peer(),
        )
        .unwrap();

        sync_state
            .upsert_space_metadata(
                "space-2",
                Some(vec![2]),
                None,
                None,
                None,
                None,
                Some(false),
                Some(&owner_peer()),
            )
            .unwrap();

        let error = handle_block_get(
            &BlockGetRequest {
                space_id: "space-2".to_string(),
                cid,
                wait: false,
            }
            .encode_to_vec(),
            &state,
            &sync_state,
            &owner_peer(),
        )
        .unwrap_err()
        .to_string();

        assert!(error.contains("CIDNotFound"));
    }

    #[test]
    fn owner_of_another_space_cannot_check_bind_or_read_private_blobs() {
        let temp_dir = TempDir::new().unwrap();
        let sync_state = seeded_sync_state(&temp_dir);
        let state = file_node_state(&temp_dir);
        sync_state
            .upsert_space_metadata(
                "space-2",
                Some(vec![2]),
                None,
                None,
                None,
                None,
                Some(false),
                Some(&other_peer()),
            )
            .unwrap();
        let private_payload = b"private-block".to_vec();
        let private_cid = cid_string_to_bytes(&compute_cid(&private_payload)).unwrap();
        handle_block_push(
            &BlockPushRequest {
                space_id: "space-1".to_string(),
                file_id: "file-1".to_string(),
                cid: private_cid.clone(),
                data: private_payload.clone(),
            }
            .encode_to_vec(),
            &state,
            &sync_state,
            &owner_peer(),
        )
        .unwrap();

        let availability = BlocksCheckResponse::decode(
            handle_blocks_check(
                &BlocksCheckRequest {
                    space_id: "space-2".to_string(),
                    cids: vec![private_cid.clone()],
                }
                .encode_to_vec(),
                &state,
                &sync_state,
                &other_peer(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        assert_eq!(
            availability.blocks_availability[0].status,
            AvailabilityStatus::NotExists as i32
        );
        let bind_error = handle_blocks_bind(
            &BlocksBindRequest {
                space_id: "space-2".to_string(),
                file_id: "file-2".to_string(),
                cids: vec![private_cid.clone()],
            }
            .encode_to_vec(),
            &state,
            &sync_state,
            &other_peer(),
        )
        .unwrap_err();
        assert!(bind_error.to_string().contains("CIDNotFound"));
        assert!(
            !state
                .blob_index
                .space_has_cid("space-2", &compute_cid(&private_payload))
                .unwrap()
        );
        let block_get = BlockGetRequest {
            space_id: "space-2".to_string(),
            cid: private_cid.clone(),
            wait: false,
        }
        .encode_to_vec();
        assert!(
            handle_block_get(&block_get, &state, &sync_state, &other_peer())
                .unwrap_err()
                .to_string()
                .contains("CIDNotFound")
        );

        handle_block_push(
            &BlockPushRequest {
                space_id: "space-2".to_string(),
                file_id: "file-2".to_string(),
                cid: private_cid,
                data: private_payload.clone(),
            }
            .encode_to_vec(),
            &state,
            &sync_state,
            &other_peer(),
        )
        .unwrap();
        let response = BlockGetResponse::decode(
            handle_block_get(&block_get, &state, &sync_state, &other_peer())
                .unwrap()
                .as_slice(),
        )
        .unwrap();
        assert_eq!(response.data, private_payload);
    }

    #[test]
    fn unauthorized_peer_cannot_read_write_or_inspect_private_blobs() {
        let temp_dir = TempDir::new().unwrap();
        let sync_state = seeded_sync_state(&temp_dir);
        let state = file_node_state(&temp_dir);
        let private_payload = b"private-block".to_vec();
        let private_cid = compute_cid(&private_payload);
        let private_cid_bytes = cid_string_to_bytes(&private_cid).unwrap();

        handle_block_push(
            &BlockPushRequest {
                space_id: "space-1".to_string(),
                file_id: "file-1".to_string(),
                cid: private_cid_bytes.clone(),
                data: private_payload,
            }
            .encode_to_vec(),
            &state,
            &sync_state,
            &owner_peer(),
        )
        .unwrap();

        let availability = BlocksCheckResponse::decode(
            handle_blocks_check(
                &BlocksCheckRequest {
                    space_id: "space-1".to_string(),
                    cids: vec![private_cid_bytes.clone()],
                }
                .encode_to_vec(),
                &state,
                &sync_state,
                &other_peer(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        assert_eq!(
            availability.blocks_availability[0].status,
            AvailabilityStatus::NotExists as i32
        );
        assert!(
            handle_block_get(
                &BlockGetRequest {
                    space_id: "space-1".to_string(),
                    cid: private_cid_bytes,
                    wait: false,
                }
                .encode_to_vec(),
                &state,
                &sync_state,
                &other_peer(),
            )
            .unwrap_err()
            .to_string()
            .contains("Forbidden")
        );

        let unauthorized_payload = b"unauthorized-block".to_vec();
        let unauthorized_cid = compute_cid(&unauthorized_payload);
        assert!(
            handle_block_push(
                &BlockPushRequest {
                    space_id: "space-1".to_string(),
                    file_id: "file-other".to_string(),
                    cid: cid_string_to_bytes(&unauthorized_cid).unwrap(),
                    data: unauthorized_payload,
                }
                .encode_to_vec(),
                &state,
                &sync_state,
                &other_peer(),
            )
            .unwrap_err()
            .to_string()
            .contains("Forbidden")
        );
        assert!(!state.blob_store.has(&unauthorized_cid));
        assert!(
            handle_space_info(
                &SpaceInfoRequest {
                    space_id: "space-1".to_string(),
                }
                .encode_to_vec(),
                &state,
                &sync_state,
                &other_peer(),
            )
            .unwrap_err()
            .to_string()
            .contains("Forbidden")
        );
    }
}
