//! Sync node RPC handlers: HeadSync, SpacePush, ObjectSyncStream.
//!
//! These handlers implement the core sync protocol that allows clients to
//! exchange head lists and deliver object changes. Per Phase 5, the shared
//! sync state is backed by persistent redb storage rather than an in-memory
//! map tied to a single process lifetime.

use anyhow::Result;
use prost::Message;
use std::collections::{HashMap, HashSet};

use manytype_core::crdt::cid::compute_cid;
use manytype_core::ldiff::{Diff, Element, Hasher, Range};
use manytype_proto::consensus::RawRecordWithId;
use manytype_proto::coordinator::SpaceReceiptWithSignature;
use manytype_proto::spacesync::*;
use manytype_proto::treechange::{
    self, RawTreeChange, RawTreeChangeWithId, TreeChange, TreeErrorResponse, TreeFullSyncResponse,
    TreeSyncContentValue, TreeSyncMessage,
};

use crate::auth::AuthenticatedPeer;
use crate::coordinator::{self, CoordinatorConfig};

pub use crate::storage::sync_state::{SharedSyncState, SpaceState};
#[cfg(test)]
pub use crate::storage::sync_state::{new_shared_sync_state, new_shared_sync_state_at};

const LDIFF_DIVIDE_FACTOR: usize = 32;
const LDIFF_COMPARE_THRESHOLD: usize = 256;
// any-sync splits mismatched ranges holding more than 256 elements 32 ways, so
// a round carries at most about n/8 ranges; this covers ~1M-object spaces.
const MAX_DIFF_RANGES: usize = 131_072;

/// Handle /spacesync.SpaceSync/HeadSync
///
/// Returns the head list for all known objects in the requested space.
/// V2/V3 requests with ranges are answered with ldiff range hashes; other
/// requests get the full listing.
pub fn handle_head_sync(
    request_bytes: &[u8],
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let request = HeadSyncRequest::decode(request_bytes)?;
    let space_id = &request.space_id;
    sync_state.authorize_space(space_id, authenticated_peer)?;

    let state = sync_state.read().unwrap();
    let results = if let Some(space) = state.get(space_id) {
        if !request.ranges.is_empty() && matches!(request.diff_type(), DiffType::V2 | DiffType::V3)
        {
            let diff = build_head_diff(space, request.diff_type());
            diff_ranges(&diff, &request.ranges)?
        } else {
            let elements = collect_object_elements(space);

            if elements.is_empty() && space.space_header.is_some() {
                vec![HeadSyncResult {
                    hash: vec![],
                    elements: vec![],
                    count: 0,
                }]
            } else if !elements.is_empty() {
                vec![HeadSyncResult {
                    hash: vec![],
                    elements,
                    count: 0,
                }]
            } else {
                vec![]
            }
        }
    } else if !request.ranges.is_empty()
        && matches!(request.diff_type(), DiffType::V2 | DiffType::V3)
    {
        let diff = Diff::new_with_type(
            LDIFF_DIVIDE_FACTOR,
            LDIFF_COMPARE_THRESHOLD,
            request.diff_type(),
        );
        diff_ranges(&diff, &request.ranges)?
    } else {
        vec![]
    };

    let response = HeadSyncResponse {
        results,
        diff_type: if matches!(request.diff_type(), DiffType::V2 | DiffType::V3) {
            request.diff_type() as i32
        } else {
            DiffType::Initial as i32
        },
    };
    tracing::info!(
        "sync: headsync for {} returned {} ranges",
        space_id,
        response.results.len()
    );
    Ok(response.encode_to_vec())
}

/// Handle /spacesync.SpaceSync/StoreDiff.
///
/// Uses the same ldiff range-hash algorithm as HeadSync, but for persisted
/// key-value store entries keyed by `keyPeerId`.
pub fn handle_store_diff(
    request_bytes: &[u8],
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let request = StoreDiffRequest::decode(request_bytes)?;
    let space_id = &request.space_id;
    sync_state.authorize_space(space_id, authenticated_peer)?;

    let state = sync_state.read().unwrap();
    let results = if let Some(space) = state.get(space_id) {
        if !request.ranges.is_empty() {
            let diff = build_store_diff(space);
            diff_ranges(&diff, &request.ranges)?
        } else {
            let elements = collect_store_elements(space);
            if elements.is_empty() && space.space_header.is_some() {
                vec![HeadSyncResult {
                    hash: vec![],
                    elements: vec![],
                    count: 0,
                }]
            } else if !elements.is_empty() {
                vec![HeadSyncResult {
                    hash: vec![],
                    elements,
                    count: 0,
                }]
            } else {
                vec![]
            }
        }
    } else if !request.ranges.is_empty() {
        diff_ranges(
            &Diff::new(LDIFF_DIVIDE_FACTOR, LDIFF_COMPARE_THRESHOLD),
            &request.ranges,
        )?
    } else {
        vec![]
    };

    Ok(StoreDiffResponse { results }.encode_to_vec())
}

/// Handle /spacesync.SpaceSync/SpacePush
///
/// Stores the space header and ACL root from the push payload.
pub fn handle_space_push(
    request_bytes: &[u8],
    sync_state: &SharedSyncState,
    coordinator_config: &CoordinatorConfig,
    signing_key: &ed25519_dalek::SigningKey,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let request = SpacePushRequest::decode(request_bytes)?;
    let payload = request
        .payload
        .ok_or_else(|| anyhow::anyhow!("missing space payload"))?;

    let space_header_with_id = payload
        .space_header
        .ok_or_else(|| anyhow::anyhow!("missing space header"))?;
    let space_id = space_header_with_id.id.clone();
    let account_identity = coordinator::validate_space_header(
        &space_id,
        &space_header_with_id.raw_header,
        authenticated_peer.account_identity(),
    )?;
    let signed_receipt = SpaceReceiptWithSignature::decode(request.credential.as_slice())?;
    coordinator::validate_space_receipt(
        &signed_receipt,
        &space_id,
        authenticated_peer.id(),
        &account_identity,
        coordinator_config,
        &signing_key.verifying_key(),
    )?;
    sync_state.authorize_space(&space_id, authenticated_peer)?;

    let acl_payload = (!payload.acl_payload.is_empty()).then_some(payload.acl_payload);
    let acl_payload_id = (!payload.acl_payload_id.is_empty()).then_some(payload.acl_payload_id);
    let settings_payload =
        (!payload.space_settings_payload.is_empty()).then_some(payload.space_settings_payload);
    let settings_payload_id = (!payload.space_settings_payload_id.is_empty())
        .then_some(payload.space_settings_payload_id);

    sync_state.upsert_space_metadata(
        &space_id,
        Some(space_header_with_id.raw_header),
        acl_payload,
        acl_payload_id,
        settings_payload,
        settings_payload_id,
        None,
        None,
    )?;

    tracing::info!("sync: stored space {}", space_id);
    let response = SpacePushResponse {};
    Ok(response.encode_to_vec())
}

/// Handle /spacesync.SpaceSync/SpacePull
pub fn handle_space_pull(
    request_bytes: &[u8],
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let request = SpacePullRequest::decode(request_bytes)?;
    sync_state.authorize_space(&request.id, authenticated_peer)?;
    let state = sync_state.read().unwrap();
    let space = state
        .get(&request.id)
        .ok_or_else(|| anyhow::anyhow!("space not found: {}", request.id))?;

    let acl_records = space
        .acl_records
        .iter()
        .map(|encoded| {
            let record = RawRecordWithId::decode(encoded.as_slice())
                .map_err(|error| anyhow::anyhow!("failed to decode ACL record: {error}"))?;
            Ok(AclRecord {
                // SpacePull's AclRecord transports the RawRecord bytes with the
                // record id split out separately. (AclGetRecords returns
                // RawRecordWithId bytes instead.)
                acl_payload: record.payload,
                id: record.id,
            })
        })
        .collect::<Result<Vec<_>>>()?;

    let payload = SpacePayload {
        space_header: space
            .space_header
            .as_ref()
            .map(|raw_header| RawSpaceHeaderWithId {
                raw_header: raw_header.clone(),
                id: request.id.clone(),
            }),
        acl_payload: space.acl_root.clone().unwrap_or_default(),
        acl_payload_id: if !space.acl_root_id.is_empty() {
            space.acl_root_id.clone()
        } else {
            space
                .acl_root
                .as_deref()
                .map(compute_cid)
                .unwrap_or_default()
        },
        space_settings_payload: space.settings_payload.clone().unwrap_or_default(),
        space_settings_payload_id: space.settings_payload_id.clone(),
    };

    Ok(SpacePullResponse {
        payload: Some(payload),
        acl_records,
    }
    .encode_to_vec())
}

/// Handle a single ObjectSyncMessage from the bidirectional stream.
///
/// Stores pushed raw changes. An empty payload or a full-sync request is
/// answered with a `TreeFullSyncResponse` carrying the changes the peer is
/// missing.
pub fn handle_object_sync_message(
    message_bytes: &[u8],
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let msg = ObjectSyncMessage::decode(message_bytes)?;
    let space_id = &msg.space_id;
    let object_id = &msg.object_id;

    // Official any-sync nodes send a SpaceSubscription message as the first
    // ObjectSyncStream payload. Manytype_quic_ffi does the same for interop.
    // This server does not maintain subscription state, so treat it as a no-op.
    if object_id.is_empty()
        && !msg.payload.is_empty()
        && let Ok(sub) = SpaceSubscription::decode(msg.payload.as_slice())
    {
        if !space_id.is_empty() {
            sync_state.authorize_space(space_id, authenticated_peer)?;
        }
        anyhow::ensure!(!sub.space_ids.is_empty(), "space subscription is empty");
        for subscribed_space_id in &sub.space_ids {
            sync_state.authorize_space(subscribed_space_id, authenticated_peer)?;
        }
        tracing::info!(
            "sync: received SpaceSubscription for {} ({} spaceIds)",
            space_id,
            sub.space_ids.len()
        );
        let response = ObjectSyncMessage {
            space_id: space_id.clone(),
            reply_id: msg.request_id.clone(),
            ..Default::default()
        };
        return Ok(response.encode_to_vec());
    }

    sync_state.authorize_space(space_id, authenticated_peer)?;

    fn store_change(
        sync_state: &SharedSyncState,
        space_id: &str,
        object_id: &str,
        raw_change: &[u8],
        change_id: Option<&str>,
    ) -> Result<()> {
        let resolved_id = change_id
            .map(ToString::to_string)
            .unwrap_or_else(|| compute_cid(raw_change));
        let parent_heads = extract_parent_heads(raw_change);
        if let Ok(raw_tree_change) = RawTreeChange::decode(raw_change) {
            if let Ok(root) = treechange::RootChange::decode(raw_tree_change.payload.as_slice()) {
                if !root.space_id.is_empty() && !root.change_type.is_empty() {
                    tracing::info!(
                        "sync: store_change root id={} space_id={} object_id={} change_type={} payload_len={}",
                        resolved_id,
                        space_id,
                        object_id,
                        root.change_type,
                        raw_tree_change.payload.len()
                    );
                } else if let Ok(tree) = TreeChange::decode(raw_tree_change.payload.as_slice()) {
                    tracing::info!(
                        "sync: store_change tree id={} space_id={} object_id={} tree_head_ids={:?} snapshot={} read_key_id={} snapshot_base_id={} changes_data_len={}",
                        resolved_id,
                        space_id,
                        object_id,
                        tree.tree_head_ids,
                        tree.is_snapshot,
                        tree.read_key_id,
                        tree.snapshot_base_id,
                        tree.changes_data.len()
                    );
                }
            } else if let Ok(tree) = TreeChange::decode(raw_tree_change.payload.as_slice()) {
                tracing::info!(
                    "sync: store_change tree id={} space_id={} object_id={} tree_head_ids={:?} snapshot={} read_key_id={} snapshot_base_id={} changes_data_len={}",
                    resolved_id,
                    space_id,
                    object_id,
                    tree.tree_head_ids,
                    tree.is_snapshot,
                    tree.read_key_id,
                    tree.snapshot_base_id,
                    tree.changes_data.len()
                );
            }
        }
        sync_state.record_object_change(
            space_id,
            object_id,
            &resolved_id,
            raw_change.to_vec(),
            &parent_heads,
        )
    }

    fn build_full_sync_response(
        sync_state: &SharedSyncState,
        space_id: &str,
        object_id: &str,
        request_heads: &[String],
        request_snapshot_path: &[String],
    ) -> Vec<u8> {
        let heads = {
            let state = sync_state.read().unwrap();
            state
                .get(space_id)
                .and_then(|space| space.object_heads.get(object_id).cloned())
                .unwrap_or_default()
        };

        let all_raw_changes = sync_state.list_object_changes(space_id, object_id);
        tracing::info!(
            "sync: full sync response build {}/{} stored_changes={} request_heads={:?} request_snapshot_path={:?}",
            space_id,
            object_id,
            all_raw_changes.len(),
            request_heads,
            request_snapshot_path
        );
        if all_raw_changes.is_empty() {
            tracing::warn!(
                "sync: full sync response build {}/{} tree not found",
                space_id,
                object_id
            );
            return TreeSyncMessage {
                content: Some(TreeSyncContentValue {
                    value: Some(treechange::tree_sync_content_value::Value::ErrorResponse(
                        TreeErrorResponse {
                            error: "tree not found".to_string(),
                            err_code: treechange::ErrorCodes::GetTreeError as u64,
                        },
                    )),
                }),
                root_change: None,
            }
            .encode_to_vec();
        }

        fn extract_timestamp(raw_change_bytes: &[u8]) -> Option<i64> {
            let raw_change = RawTreeChange::decode(raw_change_bytes).ok()?;
            if let Ok(root_change) = treechange::RootChange::decode(raw_change.payload.as_slice()) {
                return Some(root_change.timestamp);
            }
            TreeChange::decode(raw_change.payload.as_slice())
                .ok()
                .map(|tree_change| tree_change.timestamp)
        }

        let mut candidates: Vec<Candidate> = all_raw_changes
            .into_iter()
            .map(|raw_change| {
                let id = compute_cid(&raw_change);
                let (is_root_payload, parent_heads, is_snapshot, snapshot_base_id) =
                    match RawTreeChange::decode(raw_change.as_slice()) {
                        Ok(raw_tree_change) => {
                            if let Ok(root_change) =
                                treechange::RootChange::decode(raw_tree_change.payload.as_slice())
                            {
                                // RootChange payloads must never end up in the "changes" list of a
                                // full sync response (official clients decode those as TreeChange).
                                let is_root = !root_change.space_id.is_empty()
                                    && !root_change.change_type.is_empty();
                                (is_root, Vec::new(), false, String::new())
                            } else if let Ok(tree_change) =
                                TreeChange::decode(raw_tree_change.payload.as_slice())
                            {
                                (
                                    false,
                                    tree_change.tree_head_ids,
                                    tree_change.is_snapshot,
                                    tree_change.snapshot_base_id,
                                )
                            } else {
                                (false, Vec::new(), false, String::new())
                            }
                        }
                        Err(_) => (false, Vec::new(), false, String::new()),
                    };
                let timestamp = extract_timestamp(&raw_change).unwrap_or(i64::MAX);
                Candidate {
                    change: RawTreeChangeWithId { id, raw_change },
                    is_root_payload,
                    parent_heads,
                    is_snapshot,
                    snapshot_base_id,
                    timestamp,
                }
            })
            .collect();

        let root_idx = candidates
            .iter()
            .enumerate()
            .filter(|(_, candidate)| candidate.is_root_payload)
            .min_by_key(|(_, candidate)| candidate.timestamp)
            .map(|(idx, _)| idx)
            .or_else(|| {
                candidates
                    .iter()
                    .enumerate()
                    .filter(|(_, candidate)| candidate.parent_heads.is_empty())
                    .min_by_key(|(_, candidate)| candidate.timestamp)
                    .map(|(idx, _)| idx)
            })
            .or_else(|| {
                candidates
                    .iter()
                    .enumerate()
                    .min_by_key(|(_, candidate)| candidate.timestamp)
                    .map(|(idx, _)| idx)
            })
            .unwrap_or(0);

        let root_candidate = candidates.remove(root_idx);
        let root_id = root_candidate.change.id.clone();
        let root_change = Some(root_candidate.change.clone());
        let change_candidates: Vec<Candidate> = candidates
            .into_iter()
            .filter(|candidate| !candidate.is_root_payload)
            .collect();
        let mut candidates_by_id: HashMap<String, Candidate> = change_candidates
            .iter()
            .cloned()
            .map(|candidate| (candidate.change.id.clone(), candidate))
            .collect();
        candidates_by_id.insert(root_id.clone(), root_candidate.clone());

        let mut snapshot_path = collect_snapshot_path(&heads, &root_id, &candidates_by_id);
        if snapshot_path.is_empty() {
            snapshot_path.push(root_id.clone());
        } else {
            snapshot_path.reverse();
        }

        let mut known_ids: HashSet<String> = request_heads.iter().cloned().collect();
        known_ids.extend(request_snapshot_path.iter().cloned());
        let change_ids = collect_missing_changes(&heads, &candidates_by_id, &known_ids);

        let is_snapshot_tree = snapshot_path.len() > 1;
        let changes: Vec<RawTreeChangeWithId> = change_ids
            .into_iter()
            .filter_map(|change_id| {
                if !is_snapshot_tree && change_id == root_id {
                    return None;
                }
                candidates_by_id
                    .get(&change_id)
                    .cloned()
                    .map(|candidate| candidate.change)
            })
            .collect();

        let response_change_ids: Vec<_> = changes.iter().map(|change| change.id.clone()).collect();
        tracing::info!(
            "sync: full sync response {}/{} root_id={} heads={:?} change_ids={:?} snapshot_path={:?}",
            space_id,
            object_id,
            root_id,
            heads,
            response_change_ids,
            snapshot_path
        );

        TreeSyncMessage {
            content: Some(TreeSyncContentValue {
                value: Some(
                    treechange::tree_sync_content_value::Value::FullSyncResponse(
                        TreeFullSyncResponse {
                            heads,
                            changes,
                            // Official clients reconstruct snapshot-based trees
                            // using the root + snapshot ancestry exposed here.
                            snapshot_path,
                        },
                    ),
                ),
            }),
            root_change,
        }
        .encode_to_vec()
    }

    let response_payload = if msg.payload.is_empty() {
        tracing::info!(
            "sync: full sync request (empty payload) for {}/{}",
            space_id,
            object_id
        );
        build_full_sync_response(sync_state, space_id, object_id, &[], &[])
    } else if let Ok(tree_msg) = TreeSyncMessage::decode(msg.payload.as_slice()) {
        if let Some(root) = &tree_msg.root_change {
            if RawTreeChange::decode(root.raw_change.as_slice()).is_ok() {
                store_change(
                    sync_state,
                    space_id,
                    object_id,
                    &root.raw_change,
                    Some(&root.id),
                )?;
            } else {
                tracing::warn!(
                    "sync: ignoring invalid root_change bytes for {}/{} (id={})",
                    space_id,
                    object_id,
                    root.id
                );
            }
        }

        if let Some(content) = &tree_msg.content {
            match &content.value {
                Some(treechange::tree_sync_content_value::Value::FullSyncRequest(_)) => {
                    let request = tree_msg.content.as_ref().and_then(|content| {
                        content.value.as_ref().and_then(|value| match value {
                            treechange::tree_sync_content_value::Value::FullSyncRequest(req) => {
                                Some(req)
                            }
                            _ => None,
                        })
                    });
                    let request_change_ids: Vec<_> = request
                        .map(|req| req.changes.iter().map(|change| change.id.clone()).collect())
                        .unwrap_or_else(Vec::new);
                    let request_heads = request.map(|req| req.heads.as_slice()).unwrap_or(&[]);
                    let request_snapshot_path = request
                        .map(|req| req.snapshot_path.as_slice())
                        .unwrap_or(&[]);
                    tracing::info!(
                        "sync: full sync request (TreeSyncMessage) for {}/{} heads={:?} snapshot_path={:?} change_ids={:?} has_root_change={}",
                        space_id,
                        object_id,
                        request_heads,
                        request_snapshot_path,
                        request_change_ids,
                        tree_msg.root_change.is_some()
                    );
                    build_full_sync_response(
                        sync_state,
                        space_id,
                        object_id,
                        request_heads,
                        request_snapshot_path,
                    )
                }
                Some(treechange::tree_sync_content_value::Value::HeadUpdate(update)) => {
                    for change in &update.changes {
                        if RawTreeChange::decode(change.raw_change.as_slice()).is_ok() {
                            store_change(
                                sync_state,
                                space_id,
                                object_id,
                                &change.raw_change,
                                Some(&change.id),
                            )?;
                        } else {
                            tracing::warn!(
                                "sync: ignoring invalid headUpdate raw_change for {}/{} (id={})",
                                space_id,
                                object_id,
                                change.id
                            );
                        }
                    }
                    Vec::new()
                }
                Some(treechange::tree_sync_content_value::Value::FullSyncResponse(resp)) => {
                    for change in &resp.changes {
                        if RawTreeChange::decode(change.raw_change.as_slice()).is_ok() {
                            store_change(
                                sync_state,
                                space_id,
                                object_id,
                                &change.raw_change,
                                Some(&change.id),
                            )?;
                        } else {
                            tracing::warn!(
                                "sync: ignoring invalid fullSyncResponse raw_change for {}/{} (id={})",
                                space_id,
                                object_id,
                                change.id
                            );
                        }
                    }
                    Vec::new()
                }
                Some(treechange::tree_sync_content_value::Value::ErrorResponse(_)) => Vec::new(),
                None => Vec::new(),
            }
        } else {
            if RawTreeChange::decode(msg.payload.as_slice()).is_ok() {
                store_change(sync_state, space_id, object_id, &msg.payload, None)?;
            }
            Vec::new()
        }
    } else if let Ok(content) = TreeSyncContentValue::decode(msg.payload.as_slice()) {
        match &content.value {
            Some(treechange::tree_sync_content_value::Value::FullSyncRequest(_)) => {
                let request = content.value.as_ref().and_then(|value| match value {
                    treechange::tree_sync_content_value::Value::FullSyncRequest(req) => Some(req),
                    _ => None,
                });
                let request_change_ids: Vec<_> = request
                    .map(|req| req.changes.iter().map(|change| change.id.clone()).collect())
                    .unwrap_or_else(Vec::new);
                let request_heads = request.map(|req| req.heads.as_slice()).unwrap_or(&[]);
                let request_snapshot_path = request
                    .map(|req| req.snapshot_path.as_slice())
                    .unwrap_or(&[]);
                tracing::info!(
                    "sync: full sync request (TreeSyncContentValue) for {}/{} heads={:?} snapshot_path={:?} change_ids={:?}",
                    space_id,
                    object_id,
                    request_heads,
                    request_snapshot_path,
                    request_change_ids
                );
                build_full_sync_response(
                    sync_state,
                    space_id,
                    object_id,
                    request_heads,
                    request_snapshot_path,
                )
            }
            Some(treechange::tree_sync_content_value::Value::HeadUpdate(update)) => {
                for change in &update.changes {
                    if RawTreeChange::decode(change.raw_change.as_slice()).is_ok() {
                        store_change(
                            sync_state,
                            space_id,
                            object_id,
                            &change.raw_change,
                            Some(&change.id),
                        )?;
                    } else {
                        tracing::warn!(
                            "sync: ignoring invalid headUpdate raw_change for {}/{} (id={})",
                            space_id,
                            object_id,
                            change.id
                        );
                    }
                }
                Vec::new()
            }
            Some(treechange::tree_sync_content_value::Value::FullSyncResponse(resp)) => {
                for change in &resp.changes {
                    if RawTreeChange::decode(change.raw_change.as_slice()).is_ok() {
                        store_change(
                            sync_state,
                            space_id,
                            object_id,
                            &change.raw_change,
                            Some(&change.id),
                        )?;
                    } else {
                        tracing::warn!(
                            "sync: ignoring invalid fullSyncResponse raw_change for {}/{} (id={})",
                            space_id,
                            object_id,
                            change.id
                        );
                    }
                }
                Vec::new()
            }
            Some(treechange::tree_sync_content_value::Value::ErrorResponse(_)) => Vec::new(),
            None => Vec::new(),
        }
    } else {
        if RawTreeChange::decode(msg.payload.as_slice()).is_ok() {
            store_change(sync_state, space_id, object_id, &msg.payload, None)?;
        }
        Vec::new()
    };

    let response = ObjectSyncMessage {
        space_id: space_id.clone(),
        object_id: object_id.clone(),
        reply_id: msg.request_id.clone(),
        payload: response_payload,
        object_type: manytype_proto::spacesync::ObjectType::Tree as i32,
        ..Default::default()
    };
    Ok(response.encode_to_vec())
}

/// Handle all StoreElements stream messages from one peer.
///
/// The client may send:
/// - an initial message containing only `spaceId`
/// - full `StoreKeyValue` entries to persist
/// - placeholder messages containing only `keyPeerId` to request entries
/// - an empty message to terminate the request phase
// Superseded by the inline StoreElements loop in drpc::router; kept for test coverage.
#[allow(dead_code)]
pub fn handle_store_elements_messages(
    messages: &[Vec<u8>],
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<Vec<u8>>> {
    let mut active_space_id = String::new();
    let mut requested = Vec::new();

    for message_bytes in messages {
        let mut msg = StoreKeyValue::decode(message_bytes.as_slice())?;

        if !msg.space_id.is_empty() {
            sync_state.authorize_space(&msg.space_id, authenticated_peer)?;
            active_space_id = msg.space_id.clone();
        }

        if msg.key_peer_id.is_empty() {
            if msg.space_id.is_empty()
                && msg.value.is_empty()
                && msg.identity_signature.is_empty()
                && msg.peer_signature.is_empty()
            {
                break;
            }
            continue;
        }

        if msg.space_id.is_empty() {
            msg.space_id = active_space_id.clone();
        }
        if msg.space_id.is_empty() {
            return Err(anyhow::anyhow!("missing space id for store element"));
        }
        sync_state.authorize_space(&msg.space_id, authenticated_peer)?;

        if msg.value.is_empty() {
            requested.push((msg.space_id.clone(), msg.key_peer_id.clone()));
        } else {
            sync_state.upsert_store_entry(msg)?;
        }
    }

    let mut responses = Vec::new();
    for (space_id, key_peer_id) in requested {
        if let Some(entry) = sync_state.get_store_entry(&space_id, &key_peer_id) {
            responses.push(entry.encode_to_vec());
        }
    }
    responses.push(StoreKeyValue::default().encode_to_vec());
    Ok(responses)
}

/// Answers HeadSync/StoreDiff range queries against `diff`.
///
/// Ranges from an honest peer are disjoint, so together they never select
/// more elements than the diff holds. Requests that do, or that carry an
/// unreasonable number of ranges, are rejected rather than copying the space
/// once per range.
fn diff_ranges(diff: &Diff, ranges: &[HeadSyncRange]) -> Result<Vec<HeadSyncResult>> {
    anyhow::ensure!(
        ranges.len() <= MAX_DIFF_RANGES,
        "diff request has {} ranges, limit {MAX_DIFF_RANGES}",
        ranges.len()
    );
    let mut remaining_elements = diff.len();
    ranges
        .iter()
        .map(|range| {
            let result = diff
                .ranges(&[Range {
                    from: range.from,
                    to: range.to,
                    elements: range.elements,
                    limit: range.limit as usize,
                }])
                .remove(0);
            remaining_elements = remaining_elements
                .checked_sub(result.elements.len())
                .ok_or_else(|| {
                    anyhow::anyhow!("diff request selects more elements than the space holds")
                })?;
            Ok(HeadSyncResult {
                hash: result.hash,
                elements: result
                    .elements
                    .into_iter()
                    .map(|element| HeadSyncResultElement {
                        id: element.id,
                        head: element.head,
                    })
                    .collect(),
                count: result.count as u32,
            })
        })
        .collect()
}

fn collect_object_elements(space: &SpaceState) -> Vec<HeadSyncResultElement> {
    let mut object_ids: Vec<_> = space.object_heads.keys().cloned().collect();
    object_ids.sort();

    let mut elements = Vec::new();
    for object_id in object_ids {
        let mut heads = space
            .object_heads
            .get(&object_id)
            .cloned()
            .unwrap_or_default();
        heads.sort();
        if heads.is_empty() {
            elements.push(HeadSyncResultElement {
                id: object_id,
                head: String::new(),
            });
        } else {
            elements.extend(heads.into_iter().map(|head| HeadSyncResultElement {
                id: object_id.clone(),
                head,
            }));
        }
    }

    elements
}

fn build_head_diff(space: &SpaceState, diff_type: DiffType) -> Diff {
    let mut diff = Diff::new_with_type(LDIFF_DIVIDE_FACTOR, LDIFF_COMPARE_THRESHOLD, diff_type);
    let mut hasher = Hasher::new();
    diff.set(space.object_heads.iter().map(|(object_id, heads)| {
        let mut sorted_heads = heads.clone();
        sorted_heads.sort();
        Element {
            id: object_id.clone(),
            head: hasher.hash_id(&sorted_heads.join("")),
        }
    }));
    diff
}

fn collect_store_elements(space: &SpaceState) -> Vec<HeadSyncResultElement> {
    let mut entries = Vec::new();
    for encoded in space.store_key_values.values() {
        let Ok(entry) = StoreKeyValue::decode(encoded.as_slice()) else {
            continue;
        };
        entries.push(HeadSyncResultElement {
            id: entry.key_peer_id.clone(),
            head: store_entry_head(&entry),
        });
    }
    entries.sort_by(|left, right| left.id.cmp(&right.id));
    entries
}

fn build_store_diff(space: &SpaceState) -> Diff {
    let mut diff = Diff::new(LDIFF_DIVIDE_FACTOR, LDIFF_COMPARE_THRESHOLD);
    diff.set(space.store_key_values.values().filter_map(|encoded| {
        let entry = StoreKeyValue::decode(encoded.as_slice()).ok()?;
        Some(Element {
            id: entry.key_peer_id.clone(),
            head: store_entry_head(&entry),
        })
    }));
    diff
}

#[derive(Clone)]
struct Candidate {
    change: RawTreeChangeWithId,
    is_root_payload: bool,
    parent_heads: Vec<String>,
    is_snapshot: bool,
    snapshot_base_id: String,
    timestamp: i64,
}

impl Candidate {
    /// Parent links in traversal order: tree heads, then the snapshot base
    /// when it is not already one of them.
    fn parent_link(&self, index: usize) -> Option<&str> {
        if let Some(parent) = self.parent_heads.get(index) {
            return Some(parent);
        }
        (index == self.parent_heads.len()
            && !self.snapshot_base_id.is_empty()
            && !self.parent_heads.contains(&self.snapshot_base_id))
        .then_some(self.snapshot_base_id.as_str())
    }
}

/// Post-order walk from `heads` towards the root, visiting each change once.
///
/// Returns every reachable stored change with its ancestors listed before it.
/// Boundary changes are returned but not descended into. The walk keeps an
/// explicit stack so long histories cannot exhaust the worker stack.
fn walk_ancestry<'a>(
    heads: &'a [String],
    candidates_by_id: &'a HashMap<String, Candidate>,
    is_boundary: impl Fn(&str) -> bool,
) -> Vec<&'a str> {
    let mut done = HashSet::new();
    let mut order = Vec::new();
    let mut stack: Vec<(&str, &Candidate, usize)> = Vec::new();
    for head in heads {
        let mut next = Some(head.as_str());
        loop {
            if let Some(change_id) = next.take()
                && done.insert(change_id)
                && let Some(candidate) = candidates_by_id.get(change_id)
            {
                if is_boundary(change_id) {
                    order.push(change_id);
                } else {
                    stack.push((change_id, candidate, 0));
                }
            }
            let Some((change_id, candidate, link)) = stack.last_mut() else {
                break;
            };
            match candidate.parent_link(*link) {
                Some(parent) => {
                    *link += 1;
                    next = Some(parent);
                }
                None => {
                    order.push(change_id);
                    stack.pop();
                }
            }
        }
    }
    order
}

/// Snapshots reachable from `heads`, ending at the root, oldest first.
fn collect_snapshot_path(
    heads: &[String],
    root_id: &str,
    candidates_by_id: &HashMap<String, Candidate>,
) -> Vec<String> {
    walk_ancestry(heads, candidates_by_id, |change_id| change_id == root_id)
        .into_iter()
        .filter(|change_id| *change_id == root_id || candidates_by_id[*change_id].is_snapshot)
        .map(ToString::to_string)
        .collect()
}

/// Changes reachable from `heads` that the peer does not already know,
/// parents before children.
fn collect_missing_changes(
    heads: &[String],
    candidates_by_id: &HashMap<String, Candidate>,
    known_ids: &HashSet<String>,
) -> Vec<String> {
    walk_ancestry(heads, candidates_by_id, |change_id| {
        known_ids.contains(change_id)
    })
    .into_iter()
    .filter(|change_id| !known_ids.contains(*change_id))
    .map(ToString::to_string)
    .collect()
}

fn extract_parent_heads(raw_change_bytes: &[u8]) -> Vec<String> {
    let Ok(raw_change) = RawTreeChange::decode(raw_change_bytes) else {
        return Vec::new();
    };
    // Root changes contain a `RootChange` payload, not a `TreeChange`. The wire
    // formats overlap enough that decoding a RootChange payload as TreeChange
    // can succeed while producing nonsense `tree_head_ids` (e.g. treating
    // `aclHeadId` as a parent head). This breaks root detection and head
    // tracking. Prefer RootChange detection first.
    if let Ok(root_change) = treechange::RootChange::decode(raw_change.payload.as_slice()) {
        // Treat any plausible RootChange as a root (no parents). Prost will
        // generally fail RootChange decoding on TreeChange payloads due to wire
        // type mismatches, but keep a minimal sanity check to avoid false
        // positives on arbitrary bytes.
        if !root_change.space_id.is_empty() && !root_change.change_type.is_empty() {
            return Vec::new();
        }
    }

    let Ok(tree_change) = TreeChange::decode(raw_change.payload.as_slice()) else {
        return Vec::new();
    };
    tree_change.tree_head_ids
}

fn store_entry_head(entry: &StoreKeyValue) -> String {
    if let Ok(inner) = StoreKeyInner::decode(entry.value.as_slice()) {
        return format!("{:020}", inner.timestamp_micro.max(0));
    }
    compute_cid(&entry.value)
}

#[cfg(test)]
mod tests {
    use tempfile::TempDir;

    use super::*;
    use crate::auth::AuthenticatedPeer;
    use ed25519_dalek::Signer;
    use manytype_core::crypto::ed25519;
    use manytype_proto::coordinator::{AclAddRecordRequest, AclAddRecordResponse};
    use manytype_proto::crypto::{Key, KeyType};
    use manytype_proto::treechange::{
        RawTreeChange, RootChange, TreeChange, TreeFullSyncRequest, TreeHeadUpdate,
    };

    const TEST_PEER_ID: &str = "test-owner";

    fn test_peer() -> AuthenticatedPeer<'static> {
        AuthenticatedPeer::for_test(TEST_PEER_ID)
    }

    fn owned_sync_state() -> SharedSyncState {
        let state = new_shared_sync_state();
        state.claim_space_owner("space-1", &test_peer()).unwrap();
        state
    }

    fn test_signing_key() -> ed25519_dalek::SigningKey {
        ed25519::signing_key_from_seed(&[9u8; 32])
    }

    fn test_coordinator_config() -> CoordinatorConfig {
        CoordinatorConfig {
            network_id: "manytype-dev".to_string(),
            peer_id: "test-peer".to_string(),
            addresses: vec!["127.0.0.1:4830".to_string()],
        }
    }

    fn test_remote_peer_id(seed: u8) -> String {
        let signing_key = ed25519::signing_key_from_seed(&[seed; 32]);
        ed25519::ed25519_pubkey_to_libp2p_peer_id(&signing_key.verifying_key().to_bytes())
    }

    fn remote_peer<'a>(peer_id: &'a str, account_seed: u8) -> AuthenticatedPeer<'a> {
        let account_identity = ed25519::signing_key_from_seed(&[account_seed; 32])
            .verifying_key()
            .to_bytes();
        AuthenticatedPeer::for_test_with_account(peer_id, account_identity)
    }

    fn make_space_header_with_receipt(
        sync_state: &SharedSyncState,
        account_seed: u8,
        remote_peer_id: &str,
    ) -> (String, RawSpaceHeaderWithId, Vec<u8>) {
        let signing_key = test_signing_key();
        let config = test_coordinator_config();
        let account_key = ed25519::signing_key_from_seed(&[account_seed; 32]);
        let account_identity = Key {
            r#type: KeyType::Ed25519Public as i32,
            data: account_key.verifying_key().to_bytes().to_vec(),
        }
        .encode_to_vec();
        let header_bytes = SpaceHeader {
            identity: account_identity.clone(),
            space_type: "anytype.space".to_string(),
            replication_key: 42,
            ..Default::default()
        }
        .encode_to_vec();
        let raw_header = RawSpaceHeader {
            signature: account_key.sign(&header_bytes).to_bytes().to_vec(),
            space_header: header_bytes,
        }
        .encode_to_vec();
        let space_id = format!("{}.16", compute_cid(&raw_header));
        let authenticated_peer = remote_peer(remote_peer_id, account_seed);
        sync_state
            .claim_space_owner(&space_id, &authenticated_peer)
            .unwrap();
        let signed_receipt = coordinator::build_signed_space_receipt(
            &space_id,
            remote_peer_id,
            &account_identity,
            &config,
            &signing_key,
        )
        .unwrap();
        (
            space_id.clone(),
            RawSpaceHeaderWithId {
                raw_header,
                id: space_id,
            },
            signed_receipt.encode_to_vec(),
        )
    }

    #[test]
    fn head_sync_empty_space_returns_empty_results() {
        let sync_state = owned_sync_state();
        let request = HeadSyncRequest {
            space_id: "space-1".to_string(),
            ..Default::default()
        };
        let response_bytes =
            handle_head_sync(&request.encode_to_vec(), &sync_state, &test_peer()).unwrap();
        let response = HeadSyncResponse::decode(response_bytes.as_slice()).unwrap();
        assert!(response.results.is_empty());
    }

    #[test]
    fn space_push_stores_header_and_returns_empty_response() {
        let sync_state = new_shared_sync_state();
        let remote_peer_id = test_remote_peer_id(1);
        let (space_id, space_header, credential) =
            make_space_header_with_receipt(&sync_state, 4, &remote_peer_id);
        let remote_peer = remote_peer(&remote_peer_id, 4);
        let request = SpacePushRequest {
            payload: Some(SpacePayload {
                space_header: Some(space_header),
                acl_payload: b"acl-root-bytes".to_vec(),
                acl_payload_id: "acl-1".to_string(),
                space_settings_payload: b"settings".to_vec(),
                space_settings_payload_id: "settings-1".to_string(),
            }),
            credential,
        };
        let response_bytes = handle_space_push(
            &request.encode_to_vec(),
            &sync_state,
            &test_coordinator_config(),
            &test_signing_key(),
            &remote_peer,
        )
        .unwrap();
        let _response = SpacePushResponse::decode(response_bytes.as_slice()).unwrap();

        let state = sync_state.read().unwrap();
        let space = state.get(&space_id).expect("space should exist");
        assert!(space.space_header.is_some());
        assert_eq!(space.acl_root.as_deref(), Some(b"acl-root-bytes".as_ref()));
        assert_eq!(space.acl_root_id, "acl-1");
        assert_eq!(
            space.settings_payload.as_deref(),
            Some(b"settings".as_ref())
        );
        assert_eq!(space.settings_payload_id, "settings-1");
    }

    #[test]
    fn space_push_keeps_coordinator_shared_flag() {
        let sync_state = new_shared_sync_state();
        let remote_peer_id = test_remote_peer_id(3);
        let (space_id, space_header, credential) =
            make_space_header_with_receipt(&sync_state, 6, &remote_peer_id);
        let remote_peer = remote_peer(&remote_peer_id, 6);
        let request = SpacePushRequest {
            payload: Some(SpacePayload {
                space_header: Some(space_header),
                ..Default::default()
            }),
            credential,
        }
        .encode_to_vec();
        let push = || {
            handle_space_push(
                &request,
                &sync_state,
                &test_coordinator_config(),
                &test_signing_key(),
                &remote_peer,
            )
            .unwrap()
        };

        push();
        sync_state.mark_space_shared(&space_id).unwrap();
        push();

        assert!(sync_state.read().unwrap()[&space_id].is_shared);
    }

    #[test]
    fn head_sync_after_space_push_returns_non_empty() {
        let sync_state = new_shared_sync_state();
        let remote_peer_id = test_remote_peer_id(2);
        let (space_id, space_header, credential) =
            make_space_header_with_receipt(&sync_state, 5, &remote_peer_id);
        let remote_peer = remote_peer(&remote_peer_id, 5);
        let push_request = SpacePushRequest {
            payload: Some(SpacePayload {
                space_header: Some(space_header),
                ..Default::default()
            }),
            credential,
        };
        handle_space_push(
            &push_request.encode_to_vec(),
            &sync_state,
            &test_coordinator_config(),
            &test_signing_key(),
            &remote_peer,
        )
        .unwrap();

        let hs_request = HeadSyncRequest {
            space_id,
            ..Default::default()
        };
        let response_bytes =
            handle_head_sync(&hs_request.encode_to_vec(), &sync_state, &remote_peer).unwrap();
        let response = HeadSyncResponse::decode(response_bytes.as_slice()).unwrap();
        assert!(
            !response.results.is_empty(),
            "HeadSync should return non-empty results for pushed space"
        );
    }

    #[test]
    fn space_pull_returns_acl_root_and_empty_records() {
        let sync_state = new_shared_sync_state();
        let remote_peer_id = test_remote_peer_id(3);
        let (space_id, space_header, credential) =
            make_space_header_with_receipt(&sync_state, 4, &remote_peer_id);
        let remote_peer = remote_peer(&remote_peer_id, 4);
        handle_space_push(
            &SpacePushRequest {
                payload: Some(SpacePayload {
                    space_header: Some(space_header),
                    acl_payload: b"acl-root-test".to_vec(),
                    acl_payload_id: "acl-root-id".to_string(),
                    space_settings_payload: b"settings".to_vec(),
                    space_settings_payload_id: "settings-id".to_string(),
                }),
                credential,
            }
            .encode_to_vec(),
            &sync_state,
            &test_coordinator_config(),
            &test_signing_key(),
            &remote_peer,
        )
        .unwrap();

        let response = SpacePullResponse::decode(
            handle_space_pull(
                &SpacePullRequest { id: space_id }.encode_to_vec(),
                &sync_state,
                &remote_peer,
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        let payload = response.payload.unwrap();
        assert_eq!(payload.acl_payload, b"acl-root-test".to_vec());
        assert_eq!(payload.acl_payload_id, "acl-root-id");
        assert_eq!(payload.space_settings_payload, b"settings".to_vec());
        assert_eq!(payload.space_settings_payload_id, "settings-id");
        assert!(response.acl_records.is_empty());
    }

    #[test]
    fn space_pull_returns_acl_records_after_acl_add() {
        let _guard = crate::consensus::TEST_MUTEX.lock().unwrap();
        let sync_state = new_shared_sync_state();
        let remote_peer_id = test_remote_peer_id(4);
        let (space_id, space_header, credential) =
            make_space_header_with_receipt(&sync_state, 4, &remote_peer_id);
        let remote_peer = remote_peer(&remote_peer_id, 4);
        handle_space_push(
            &SpacePushRequest {
                payload: Some(SpacePayload {
                    space_header: Some(space_header),
                    acl_payload: b"acl-root-test".to_vec(),
                    acl_payload_id: "acl-root-id".to_string(),
                    ..Default::default()
                }),
                credential,
            }
            .encode_to_vec(),
            &sync_state,
            &test_coordinator_config(),
            &test_signing_key(),
            &remote_peer,
        )
        .unwrap();

        let add_response = AclAddRecordResponse::decode(
            coordinator::handle_acl_add_record(
                &AclAddRecordRequest {
                    space_id: space_id.clone(),
                    payload: manytype_proto::consensus::RawRecord {
                        payload: manytype_proto::consensus::Record {
                            prev_id: "acl-root-id".to_string(),
                            identity: vec![7; 32],
                            data: b"acl".to_vec(),
                            timestamp: 1,
                        }
                        .encode_to_vec(),
                        signature: b"sig".to_vec(),
                        ..Default::default()
                    }
                    .encode_to_vec(),
                }
                .encode_to_vec(),
                &sync_state,
                &test_signing_key(),
                &remote_peer,
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();

        let response = SpacePullResponse::decode(
            handle_space_pull(
                &SpacePullRequest { id: space_id }.encode_to_vec(),
                &sync_state,
                &remote_peer,
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();

        assert_eq!(response.acl_records.len(), 1);
        assert_eq!(response.acl_records[0].id, add_response.record_id);
    }

    #[test]
    fn space_pull_unknown_space_returns_error() {
        let sync_state = new_shared_sync_state();
        let result = handle_space_pull(
            &SpacePullRequest {
                id: "missing".to_string(),
            }
            .encode_to_vec(),
            &sync_state,
            &test_peer(),
        );
        assert!(result.is_err());
        assert!(
            result
                .unwrap_err()
                .to_string()
                .contains("space access denied")
        );
    }

    #[test]
    fn space_pull_includes_space_header() {
        let sync_state = new_shared_sync_state();
        let remote_peer_id = test_remote_peer_id(5);
        let (space_id, space_header, credential) =
            make_space_header_with_receipt(&sync_state, 4, &remote_peer_id);
        let remote_peer = remote_peer(&remote_peer_id, 4);
        let expected_header = space_header.raw_header.clone();
        handle_space_push(
            &SpacePushRequest {
                payload: Some(SpacePayload {
                    space_header: Some(space_header),
                    ..Default::default()
                }),
                credential,
            }
            .encode_to_vec(),
            &sync_state,
            &test_coordinator_config(),
            &test_signing_key(),
            &remote_peer,
        )
        .unwrap();

        let response = SpacePullResponse::decode(
            handle_space_pull(
                &SpacePullRequest {
                    id: space_id.clone(),
                }
                .encode_to_vec(),
                &sync_state,
                &remote_peer,
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        let header = response.payload.unwrap().space_header.unwrap();
        assert_eq!(header.raw_header, expected_header);
        assert_eq!(header.id, space_id);
    }

    #[test]
    fn object_sync_message_stores_change_and_confirms() {
        let sync_state = owned_sync_state();
        let raw_change = make_tree_change_bytes(vec!["root".to_string()]);
        let expected_change_id = compute_cid(&raw_change);
        let msg = ObjectSyncMessage {
            space_id: "space-1".to_string(),
            object_id: "obj-1".to_string(),
            request_id: "req-42".to_string(),
            payload: raw_change,
            ..Default::default()
        };
        let response_bytes =
            handle_object_sync_message(&msg.encode_to_vec(), &sync_state, &test_peer()).unwrap();
        let response = ObjectSyncMessage::decode(response_bytes.as_slice()).unwrap();

        assert_eq!(response.space_id, "space-1");
        assert_eq!(response.object_id, "obj-1");
        assert_eq!(response.reply_id, "req-42");
        assert!(
            response.payload.is_empty(),
            "confirmation has empty payload"
        );

        let state = sync_state.read().unwrap();
        let space = state.get("space-1").expect("space should exist");
        assert_eq!(
            space.object_heads.get("obj-1"),
            Some(&vec![expected_change_id.clone()])
        );
        assert_eq!(
            space.object_changes.get("obj-1"),
            Some(&vec![expected_change_id.clone()])
        );
        assert_eq!(
            space.raw_changes.get(&expected_change_id),
            Some(&msg.payload)
        );
    }

    #[test]
    fn object_sync_pull_request_returns_full_sync_response() {
        let sync_state = owned_sync_state();
        let first_change = make_tree_change_bytes(Vec::new());
        let first_change_id = compute_cid(&first_change);
        let second_change = make_tree_change_bytes(vec![first_change_id]);
        let second_change_id = compute_cid(&second_change);

        for (index, payload) in [first_change.clone(), second_change.clone()]
            .into_iter()
            .enumerate()
        {
            let msg = ObjectSyncMessage {
                space_id: "space-1".to_string(),
                object_id: "obj-1".to_string(),
                request_id: format!("push-{index}"),
                payload,
                ..Default::default()
            };
            handle_object_sync_message(&msg.encode_to_vec(), &sync_state, &test_peer()).unwrap();
        }

        let pull_request = ObjectSyncMessage {
            space_id: "space-1".to_string(),
            object_id: "obj-1".to_string(),
            request_id: "pull-1".to_string(),
            payload: Vec::new(),
            ..Default::default()
        };
        let response_bytes =
            handle_object_sync_message(&pull_request.encode_to_vec(), &sync_state, &test_peer())
                .unwrap();
        let response = ObjectSyncMessage::decode(response_bytes.as_slice()).unwrap();
        assert_eq!(response.reply_id, "pull-1");

        let tree_msg = TreeSyncMessage::decode(response.payload.as_slice()).unwrap();
        let Some(content) = tree_msg.content else {
            panic!("expected TreeSyncMessage.content");
        };
        let Some(treechange::tree_sync_content_value::Value::FullSyncResponse(resp)) =
            content.value
        else {
            panic!("expected full sync response");
        };

        assert_eq!(resp.heads, vec![second_change_id]);
        let root = tree_msg.root_change.expect("expected root change");
        assert_eq!(root.raw_change, first_change);
        assert_eq!(resp.changes.len(), 1);
        assert_eq!(resp.changes[0].raw_change, second_change);
    }

    #[test]
    fn full_sync_response_never_includes_root_change_in_changes_list() {
        let sync_state = owned_sync_state();

        let space_id = "space-1";
        let object_id = "obj-derived-home";

        let root_raw = make_root_change_bytes(space_id, "anytype.object", true);
        let root_id = compute_cid(&root_raw);
        let bootstrap_raw = make_tree_change_bytes(vec![root_id.clone()]);
        let bootstrap_id = compute_cid(&bootstrap_raw);

        let update = TreeSyncMessage {
            content: Some(TreeSyncContentValue {
                value: Some(treechange::tree_sync_content_value::Value::HeadUpdate(
                    TreeHeadUpdate {
                        heads: vec![bootstrap_id.clone()],
                        changes: vec![
                            RawTreeChangeWithId {
                                id: root_id.clone(),
                                raw_change: root_raw.clone(),
                            },
                            RawTreeChangeWithId {
                                id: bootstrap_id.clone(),
                                raw_change: bootstrap_raw.clone(),
                            },
                        ],
                        snapshot_path: Vec::new(),
                    },
                )),
            }),
            root_change: None,
        };

        let push = ObjectSyncMessage {
            space_id: space_id.to_string(),
            object_id: object_id.to_string(),
            request_id: "push-1".to_string(),
            payload: update.encode_to_vec(),
            ..Default::default()
        };
        handle_object_sync_message(&push.encode_to_vec(), &sync_state, &test_peer()).unwrap();

        let pull = ObjectSyncMessage {
            space_id: space_id.to_string(),
            object_id: object_id.to_string(),
            request_id: "pull-1".to_string(),
            payload: TreeSyncMessage {
                content: Some(TreeSyncContentValue {
                    value: Some(treechange::tree_sync_content_value::Value::FullSyncRequest(
                        TreeFullSyncRequest {
                            heads: Vec::new(),
                            changes: Vec::new(),
                            snapshot_path: Vec::new(),
                        },
                    )),
                }),
                root_change: None,
            }
            .encode_to_vec(),
            ..Default::default()
        };
        let response_bytes =
            handle_object_sync_message(&pull.encode_to_vec(), &sync_state, &test_peer()).unwrap();
        let response = ObjectSyncMessage::decode(response_bytes.as_slice()).unwrap();

        let tree_msg = TreeSyncMessage::decode(response.payload.as_slice()).unwrap();
        let root = tree_msg.root_change.expect("root change required");
        assert_eq!(root.id, root_id);
        assert_eq!(root.raw_change, root_raw);

        let Some(content) = tree_msg.content else {
            panic!("expected TreeSyncMessage.content");
        };
        let Some(treechange::tree_sync_content_value::Value::FullSyncResponse(resp)) =
            content.value
        else {
            panic!("expected full sync response");
        };

        for change in &resp.changes {
            let raw = RawTreeChange::decode(change.raw_change.as_slice()).unwrap();
            assert!(
                RootChange::decode(raw.payload.as_slice()).is_err(),
                "root change payload leaked into changes list"
            );
            TreeChange::decode(raw.payload.as_slice())
                .expect("changes must be TreeChange payloads");
        }
    }

    #[test]
    fn full_sync_response_for_snapshot_trees_matches_official_shape_for_empty_request() {
        let sync_state = owned_sync_state();

        let space_id = "space-1";
        let object_id = "obj-snapshot";

        let root_raw = make_root_change_bytes(space_id, "anytype.object", true);
        let root_id = compute_cid(&root_raw);
        let snapshot_raw = make_tree_change_bytes_with(
            vec![root_id.clone()],
            root_id.clone(),
            true,
            1,
            b"snapshot-data",
        );
        let snapshot_id = compute_cid(&snapshot_raw);
        let edit_raw = make_tree_change_bytes_with(
            vec![snapshot_id.clone()],
            snapshot_id.clone(),
            false,
            2,
            b"edit-data",
        );
        let edit_id = compute_cid(&edit_raw);

        let update = TreeSyncMessage {
            content: Some(TreeSyncContentValue {
                value: Some(treechange::tree_sync_content_value::Value::HeadUpdate(
                    TreeHeadUpdate {
                        heads: vec![edit_id.clone()],
                        changes: vec![
                            RawTreeChangeWithId {
                                id: root_id.clone(),
                                raw_change: root_raw.clone(),
                            },
                            RawTreeChangeWithId {
                                id: snapshot_id.clone(),
                                raw_change: snapshot_raw.clone(),
                            },
                            RawTreeChangeWithId {
                                id: edit_id.clone(),
                                raw_change: edit_raw.clone(),
                            },
                        ],
                        snapshot_path: Vec::new(),
                    },
                )),
            }),
            root_change: None,
        };

        let push = ObjectSyncMessage {
            space_id: space_id.to_string(),
            object_id: object_id.to_string(),
            request_id: "push-1".to_string(),
            payload: update.encode_to_vec(),
            ..Default::default()
        };
        handle_object_sync_message(&push.encode_to_vec(), &sync_state, &test_peer()).unwrap();

        let pull = ObjectSyncMessage {
            space_id: space_id.to_string(),
            object_id: object_id.to_string(),
            request_id: "pull-1".to_string(),
            payload: TreeSyncMessage {
                content: Some(TreeSyncContentValue {
                    value: Some(treechange::tree_sync_content_value::Value::FullSyncRequest(
                        TreeFullSyncRequest {
                            heads: Vec::new(),
                            changes: Vec::new(),
                            snapshot_path: Vec::new(),
                        },
                    )),
                }),
                root_change: None,
            }
            .encode_to_vec(),
            ..Default::default()
        };

        let response_bytes =
            handle_object_sync_message(&pull.encode_to_vec(), &sync_state, &test_peer()).unwrap();
        let response = ObjectSyncMessage::decode(response_bytes.as_slice()).unwrap();
        let tree_msg = TreeSyncMessage::decode(response.payload.as_slice()).unwrap();
        let root = tree_msg.root_change.expect("root change required");
        assert_eq!(root.id, root_id);

        let Some(content) = tree_msg.content else {
            panic!("expected TreeSyncMessage.content");
        };
        let Some(treechange::tree_sync_content_value::Value::FullSyncResponse(resp)) =
            content.value
        else {
            panic!("expected full sync response");
        };

        assert_eq!(resp.heads, vec![edit_id]);
        assert_eq!(resp.snapshot_path, vec![snapshot_id, root_id]);
        assert_eq!(resp.changes.len(), 3);
        assert_eq!(resp.changes[0].raw_change, root_raw);
        assert_eq!(resp.changes[1].raw_change, snapshot_raw);
        assert_eq!(resp.changes[2].raw_change, edit_raw);
    }

    #[test]
    fn full_sync_response_for_snapshot_trees_only_returns_missing_edit_when_snapshot_known() {
        let sync_state = owned_sync_state();

        let space_id = "space-1";
        let object_id = "obj-snapshot-delta";

        let root_raw = make_root_change_bytes(space_id, "anytype.object", true);
        let root_id = compute_cid(&root_raw);
        let snapshot_raw = make_tree_change_bytes_with(
            vec![root_id.clone()],
            root_id.clone(),
            true,
            1,
            b"snapshot-data",
        );
        let snapshot_id = compute_cid(&snapshot_raw);
        let edit_raw = make_tree_change_bytes_with(
            vec![snapshot_id.clone()],
            snapshot_id.clone(),
            false,
            2,
            b"edit-data",
        );
        let edit_id = compute_cid(&edit_raw);

        let update = TreeSyncMessage {
            content: Some(TreeSyncContentValue {
                value: Some(treechange::tree_sync_content_value::Value::HeadUpdate(
                    TreeHeadUpdate {
                        heads: vec![edit_id.clone()],
                        changes: vec![
                            RawTreeChangeWithId {
                                id: root_id.clone(),
                                raw_change: root_raw.clone(),
                            },
                            RawTreeChangeWithId {
                                id: snapshot_id.clone(),
                                raw_change: snapshot_raw.clone(),
                            },
                            RawTreeChangeWithId {
                                id: edit_id.clone(),
                                raw_change: edit_raw.clone(),
                            },
                        ],
                        snapshot_path: Vec::new(),
                    },
                )),
            }),
            root_change: None,
        };

        let push = ObjectSyncMessage {
            space_id: space_id.to_string(),
            object_id: object_id.to_string(),
            request_id: "push-1".to_string(),
            payload: update.encode_to_vec(),
            ..Default::default()
        };
        handle_object_sync_message(&push.encode_to_vec(), &sync_state, &test_peer()).unwrap();

        let pull = ObjectSyncMessage {
            space_id: space_id.to_string(),
            object_id: object_id.to_string(),
            request_id: "pull-1".to_string(),
            payload: TreeSyncMessage {
                content: Some(TreeSyncContentValue {
                    value: Some(treechange::tree_sync_content_value::Value::FullSyncRequest(
                        TreeFullSyncRequest {
                            heads: vec![snapshot_id.clone()],
                            changes: Vec::new(),
                            snapshot_path: Vec::new(),
                        },
                    )),
                }),
                root_change: None,
            }
            .encode_to_vec(),
            ..Default::default()
        };

        let response_bytes =
            handle_object_sync_message(&pull.encode_to_vec(), &sync_state, &test_peer()).unwrap();
        let response = ObjectSyncMessage::decode(response_bytes.as_slice()).unwrap();
        let tree_msg = TreeSyncMessage::decode(response.payload.as_slice()).unwrap();
        let root = tree_msg.root_change.expect("root change required");
        assert_eq!(root.id, root_id);

        let Some(content) = tree_msg.content else {
            panic!("expected TreeSyncMessage.content");
        };
        let Some(treechange::tree_sync_content_value::Value::FullSyncResponse(resp)) =
            content.value
        else {
            panic!("expected full sync response");
        };

        assert_eq!(resp.heads, vec![edit_id.clone()]);
        assert_eq!(resp.snapshot_path, vec![snapshot_id, root_id]);
        assert_eq!(resp.changes.len(), 1);
        assert_eq!(resp.changes[0].id, edit_id);
        assert_eq!(resp.changes[0].raw_change, edit_raw);
    }

    #[test]
    fn full_sync_response_preserves_stored_multi_head_order_for_snapshot_trees() {
        let sync_state = owned_sync_state();

        let space_id = "space-1";
        let object_id = "obj-snapshot-fork";

        let root_raw = make_root_change_bytes(space_id, "anytype.object", true);
        let root_id = compute_cid(&root_raw);
        let snapshot_raw = make_tree_change_bytes_with(
            vec![root_id.clone()],
            root_id.clone(),
            true,
            1,
            b"snapshot-data",
        );
        let snapshot_id = compute_cid(&snapshot_raw);
        let manytype_edit_raw = make_tree_change_bytes_with(
            vec![snapshot_id.clone()],
            snapshot_id.clone(),
            false,
            2,
            b"manytype-edit",
        );
        let manytype_edit_id = compute_cid(&manytype_edit_raw);
        let official_sibling_raw = make_tree_change_bytes_with(
            vec![snapshot_id.clone()],
            snapshot_id.clone(),
            false,
            3,
            b"official-sibling",
        );
        let official_sibling_id = compute_cid(&official_sibling_raw);

        let update = TreeSyncMessage {
            content: Some(TreeSyncContentValue {
                value: Some(treechange::tree_sync_content_value::Value::HeadUpdate(
                    TreeHeadUpdate {
                        heads: vec![manytype_edit_id.clone(), official_sibling_id.clone()],
                        changes: vec![
                            RawTreeChangeWithId {
                                id: root_id.clone(),
                                raw_change: root_raw.clone(),
                            },
                            RawTreeChangeWithId {
                                id: snapshot_id.clone(),
                                raw_change: snapshot_raw.clone(),
                            },
                            RawTreeChangeWithId {
                                id: manytype_edit_id.clone(),
                                raw_change: manytype_edit_raw.clone(),
                            },
                            RawTreeChangeWithId {
                                id: official_sibling_id.clone(),
                                raw_change: official_sibling_raw.clone(),
                            },
                        ],
                        snapshot_path: Vec::new(),
                    },
                )),
            }),
            root_change: None,
        };

        let push = ObjectSyncMessage {
            space_id: space_id.to_string(),
            object_id: object_id.to_string(),
            request_id: "push-1".to_string(),
            payload: update.encode_to_vec(),
            ..Default::default()
        };
        handle_object_sync_message(&push.encode_to_vec(), &sync_state, &test_peer()).unwrap();

        let pull = ObjectSyncMessage {
            space_id: space_id.to_string(),
            object_id: object_id.to_string(),
            request_id: "pull-1".to_string(),
            payload: TreeSyncMessage {
                content: Some(TreeSyncContentValue {
                    value: Some(treechange::tree_sync_content_value::Value::FullSyncRequest(
                        TreeFullSyncRequest {
                            heads: vec![official_sibling_id.clone()],
                            changes: Vec::new(),
                            snapshot_path: vec![snapshot_id.clone(), root_id.clone()],
                        },
                    )),
                }),
                root_change: None,
            }
            .encode_to_vec(),
            ..Default::default()
        };

        let response_bytes =
            handle_object_sync_message(&pull.encode_to_vec(), &sync_state, &test_peer()).unwrap();
        let response = ObjectSyncMessage::decode(response_bytes.as_slice()).unwrap();
        let tree_msg = TreeSyncMessage::decode(response.payload.as_slice()).unwrap();

        let Some(content) = tree_msg.content else {
            panic!("expected TreeSyncMessage.content");
        };
        let Some(treechange::tree_sync_content_value::Value::FullSyncResponse(resp)) =
            content.value
        else {
            panic!("expected full sync response");
        };

        assert_eq!(
            resp.heads,
            vec![manytype_edit_id.clone(), official_sibling_id.clone()]
        );
        assert_eq!(resp.snapshot_path, vec![snapshot_id, root_id]);
        assert_eq!(resp.changes.len(), 1);
        assert_eq!(resp.changes[0].id, manytype_edit_id);
        assert_eq!(resp.changes[0].raw_change, manytype_edit_raw);
    }

    #[test]
    fn persisted_object_heads_survive_reopen() {
        let temp_dir = TempDir::new().unwrap();
        let raw_change = make_tree_change_bytes(Vec::new());
        let change_id = compute_cid(&raw_change);
        {
            let sync_state = new_shared_sync_state_at(temp_dir.path()).unwrap();
            sync_state
                .claim_space_owner("space-1", &test_peer())
                .unwrap();
            let msg = ObjectSyncMessage {
                space_id: "space-1".to_string(),
                object_id: "obj-1".to_string(),
                request_id: "req-1".to_string(),
                payload: raw_change,
                ..Default::default()
            };
            handle_object_sync_message(&msg.encode_to_vec(), &sync_state, &test_peer()).unwrap();
        }

        let reopened = new_shared_sync_state_at(temp_dir.path()).unwrap();
        let request = HeadSyncRequest {
            space_id: "space-1".to_string(),
            ..Default::default()
        };
        let response_bytes =
            handle_head_sync(&request.encode_to_vec(), &reopened, &test_peer()).unwrap();
        let response = HeadSyncResponse::decode(response_bytes.as_slice()).unwrap();

        assert_eq!(response.results.len(), 1);
        assert_eq!(response.results[0].elements.len(), 1);
        assert_eq!(response.results[0].elements[0].id, "obj-1");
        assert_eq!(response.results[0].elements[0].head, change_id);
    }

    #[test]
    fn reopened_space_rejects_same_peer_with_different_account() {
        let temp_dir = TempDir::new().unwrap();
        {
            let sync_state = new_shared_sync_state_at(temp_dir.path()).unwrap();
            sync_state
                .claim_space_owner("space-1", &test_peer())
                .unwrap();
        }

        let reopened = new_shared_sync_state_at(temp_dir.path()).unwrap();
        let different_account = AuthenticatedPeer::for_test_with_account(TEST_PEER_ID, [1; 32]);
        let result = handle_head_sync(
            &HeadSyncRequest {
                space_id: "space-1".to_string(),
                ..Default::default()
            }
            .encode_to_vec(),
            &reopened,
            &different_account,
        );

        assert!(result.is_err());
    }

    #[test]
    fn space_push_missing_payload_errors() {
        let sync_state = owned_sync_state();
        let request = SpacePushRequest {
            payload: None,
            ..Default::default()
        };
        let result = handle_space_push(
            &request.encode_to_vec(),
            &sync_state,
            &test_coordinator_config(),
            &test_signing_key(),
            &test_peer(),
        );
        assert!(result.is_err());
    }

    #[test]
    fn space_push_missing_header_errors() {
        let sync_state = owned_sync_state();
        let request = SpacePushRequest {
            payload: Some(SpacePayload {
                space_header: None,
                ..Default::default()
            }),
            ..Default::default()
        };
        let result = handle_space_push(
            &request.encode_to_vec(),
            &sync_state,
            &test_coordinator_config(),
            &test_signing_key(),
            &test_peer(),
        );
        assert!(result.is_err());
    }

    #[test]
    fn space_push_rejects_missing_receipt() {
        let sync_state = owned_sync_state();
        let request = SpacePushRequest {
            payload: Some(SpacePayload {
                space_header: Some(RawSpaceHeaderWithId {
                    raw_header: RawSpaceHeader {
                        space_header: SpaceHeader {
                            identity: vec![1; 32],
                            ..Default::default()
                        }
                        .encode_to_vec(),
                        signature: vec![1; 64],
                    }
                    .encode_to_vec(),
                    id: "space-1".to_string(),
                }),
                ..Default::default()
            }),
            credential: Vec::new(),
        };

        let result = handle_space_push(
            &request.encode_to_vec(),
            &sync_state,
            &test_coordinator_config(),
            &test_signing_key(),
            &test_peer(),
        );
        assert!(result.is_err());
    }

    #[test]
    fn store_diff_lists_known_store_entries() {
        let sync_state = owned_sync_state();
        sync_state
            .upsert_store_entry(make_store_entry("space-1", "settings-peer-1", 10))
            .unwrap();
        sync_state
            .upsert_store_entry(make_store_entry("space-1", "settings-peer-2", 20))
            .unwrap();

        let response_bytes = handle_store_diff(
            &StoreDiffRequest {
                space_id: "space-1".to_string(),
                ..Default::default()
            }
            .encode_to_vec(),
            &sync_state,
            &test_peer(),
        )
        .unwrap();
        let response = StoreDiffResponse::decode(response_bytes.as_slice()).unwrap();

        assert_eq!(response.results.len(), 1);
        let ids: Vec<_> = response.results[0]
            .elements
            .iter()
            .map(|element| element.id.as_str())
            .collect();
        assert_eq!(ids, vec!["settings-peer-1", "settings-peer-2"]);
    }

    #[test]
    fn head_sync_ranges_are_bounded_by_space_contents() {
        let sync_state = owned_sync_state();
        for object_id in ["obj-1", "obj-2", "obj-3"] {
            sync_state
                .record_object_change(
                    "space-1",
                    object_id,
                    &format!("{object_id}-change"),
                    object_id.as_bytes().to_vec(),
                    &[],
                )
                .unwrap();
        }
        let head_sync = |ranges: Vec<HeadSyncRange>| {
            handle_head_sync(
                &HeadSyncRequest {
                    space_id: "space-1".to_string(),
                    ranges,
                    diff_type: DiffType::V3 as i32,
                }
                .encode_to_vec(),
                &sync_state,
                &test_peer(),
            )
        };
        let range = |from, to| HeadSyncRange {
            from,
            to,
            limit: 0,
            elements: true,
        };

        let response = HeadSyncResponse::decode(
            head_sync(vec![
                range(0, u64::MAX / 2),
                range(u64::MAX / 2 + 1, u64::MAX),
            ])
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        let returned: usize = response
            .results
            .iter()
            .map(|result| result.elements.len())
            .sum();
        assert_eq!(returned, 3);

        let overlapping = head_sync(vec![range(0, u64::MAX); 2]).unwrap_err();
        assert!(overlapping.to_string().contains("more elements"));

        let too_many = head_sync(vec![
            HeadSyncRange {
                elements: false,
                ..range(0, u64::MAX)
            };
            MAX_DIFF_RANGES + 1
        ])
        .unwrap_err();
        assert!(too_many.to_string().contains("ranges, limit"));
    }

    #[test]
    fn store_elements_can_save_and_fetch_entries() {
        let sync_state = owned_sync_state();
        let existing = make_store_entry("space-1", "settings-peer-1", 10);
        let new_entry = make_store_entry("space-1", "settings-peer-2", 20);
        sync_state.upsert_store_entry(existing.clone()).unwrap();

        let responses = handle_store_elements_messages(
            &[
                StoreKeyValue {
                    space_id: "space-1".to_string(),
                    ..Default::default()
                }
                .encode_to_vec(),
                new_entry.clone().encode_to_vec(),
                StoreKeyValue {
                    key_peer_id: existing.key_peer_id.clone(),
                    ..Default::default()
                }
                .encode_to_vec(),
                StoreKeyValue::default().encode_to_vec(),
            ],
            &sync_state,
            &test_peer(),
        )
        .unwrap();

        let fetched = StoreKeyValue::decode(responses[0].as_slice()).unwrap();
        let terminator = StoreKeyValue::decode(responses[1].as_slice()).unwrap();
        assert_eq!(fetched.key_peer_id, existing.key_peer_id);
        assert!(terminator.key_peer_id.is_empty());

        let stored_new = sync_state
            .get_store_entry("space-1", "settings-peer-2")
            .unwrap();
        assert_eq!(stored_new.key_peer_id, new_entry.key_peer_id);
        assert_eq!(stored_new.value, new_entry.value);
    }

    #[test]
    fn unauthorized_peer_cannot_read_or_mutate_sync_state() {
        let sync_state = owned_sync_state();
        let other_peer = AuthenticatedPeer::for_test("other-peer");

        assert!(
            handle_head_sync(
                &HeadSyncRequest {
                    space_id: "space-1".to_string(),
                    ..Default::default()
                }
                .encode_to_vec(),
                &sync_state,
                &other_peer,
            )
            .is_err()
        );
        assert!(
            handle_store_diff(
                &StoreDiffRequest {
                    space_id: "space-1".to_string(),
                    ..Default::default()
                }
                .encode_to_vec(),
                &sync_state,
                &other_peer,
            )
            .is_err()
        );
        assert!(
            handle_space_pull(
                &SpacePullRequest {
                    id: "space-1".to_string(),
                }
                .encode_to_vec(),
                &sync_state,
                &other_peer,
            )
            .is_err()
        );

        let raw_change = make_tree_change_bytes(Vec::new());
        assert!(
            handle_object_sync_message(
                &ObjectSyncMessage {
                    space_id: "space-1".to_string(),
                    object_id: "obj-unauthorized".to_string(),
                    request_id: "req-unauthorized".to_string(),
                    payload: raw_change,
                    ..Default::default()
                }
                .encode_to_vec(),
                &sync_state,
                &other_peer,
            )
            .is_err()
        );
        assert!(
            handle_store_elements_messages(
                &[make_store_entry("space-1", "settings-other", 10).encode_to_vec()],
                &sync_state,
                &other_peer,
            )
            .is_err()
        );

        assert!(
            sync_state
                .list_object_changes("space-1", "obj-unauthorized")
                .is_empty()
        );
        assert!(
            sync_state
                .get_store_entry("space-1", "settings-other")
                .is_none()
        );
    }

    #[test]
    fn space_push_rejects_valid_receipt_from_non_owner() {
        let sync_state = new_shared_sync_state();
        let owner_peer_id = test_remote_peer_id(10);
        let (space_id, space_header, _) =
            make_space_header_with_receipt(&sync_state, 4, &owner_peer_id);
        let other_peer_id = test_remote_peer_id(11);
        let other_peer = remote_peer(&other_peer_id, 4);
        let account_key = ed25519::signing_key_from_seed(&[4; 32]);
        let account_identity = Key {
            r#type: KeyType::Ed25519Public as i32,
            data: account_key.verifying_key().to_bytes().to_vec(),
        }
        .encode_to_vec();
        let receipt = coordinator::build_signed_space_receipt(
            &space_id,
            &other_peer_id,
            &account_identity,
            &test_coordinator_config(),
            &test_signing_key(),
        )
        .unwrap()
        .encode_to_vec();

        let result = handle_space_push(
            &SpacePushRequest {
                payload: Some(SpacePayload {
                    space_header: Some(space_header),
                    ..Default::default()
                }),
                credential: receipt,
            }
            .encode_to_vec(),
            &sync_state,
            &test_coordinator_config(),
            &test_signing_key(),
            &other_peer,
        );

        assert!(
            result
                .unwrap_err()
                .to_string()
                .contains("space access denied")
        );
        let state = sync_state.read().unwrap();
        assert_eq!(state[&space_id].owner_peer_id, owner_peer_id);
        assert!(state[&space_id].space_header.is_none());
    }

    #[test]
    fn full_sync_response_orders_merged_parents_before_children() {
        let sync_state = owned_sync_state();
        let object_id = "obj-merge";
        let root_raw = make_root_change_bytes("space-1", "anytype.object", true);
        let root_id = compute_cid(&root_raw);
        let a_raw =
            make_tree_change_bytes_with(vec![root_id.clone()], root_id.clone(), false, 1, b"a");
        let a_id = compute_cid(&a_raw);
        let a2_raw =
            make_tree_change_bytes_with(vec![a_id.clone()], root_id.clone(), false, 2, b"a2");
        let a2_id = compute_cid(&a2_raw);
        let b_raw =
            make_tree_change_bytes_with(vec![root_id.clone()], root_id.clone(), false, 3, b"b");
        let b_id = compute_cid(&b_raw);
        let merge_raw = make_tree_change_bytes_with(
            vec![b_id.clone(), a2_id.clone()],
            root_id.clone(),
            false,
            4,
            b"merge",
        );
        let merge_id = compute_cid(&merge_raw);
        push_tree_changes(
            &sync_state,
            object_id,
            &[&root_raw, &a_raw, &a2_raw, &b_raw, &merge_raw],
        );

        let full = request_full_sync(&sync_state, object_id, Vec::new(), Vec::new());
        assert_eq!(full.heads, vec![merge_id.clone()]);
        assert_eq!(full.snapshot_path, vec![root_id.clone()]);
        assert_eq!(
            response_change_ids(&full),
            vec![b_id.clone(), a_id.clone(), a2_id.clone(), merge_id.clone()]
        );

        let partial = request_full_sync(&sync_state, object_id, vec![a_id], Vec::new());
        assert_eq!(partial.snapshot_path, vec![root_id]);
        assert_eq!(response_change_ids(&partial), vec![b_id, a2_id, merge_id]);
    }

    #[test]
    fn full_sync_response_walks_snapshots_across_forks() {
        let sync_state = owned_sync_state();
        let object_id = "obj-snapshot-merge";
        let root_raw = make_root_change_bytes("space-1", "anytype.object", true);
        let root_id = compute_cid(&root_raw);
        let s1_raw =
            make_tree_change_bytes_with(vec![root_id.clone()], root_id.clone(), true, 1, b"s1");
        let s1_id = compute_cid(&s1_raw);
        let a_raw = make_tree_change_bytes_with(vec![s1_id.clone()], s1_id.clone(), false, 2, b"a");
        let a_id = compute_cid(&a_raw);
        let b_raw = make_tree_change_bytes_with(vec![s1_id.clone()], s1_id.clone(), false, 3, b"b");
        let b_id = compute_cid(&b_raw);
        let merge_raw = make_tree_change_bytes_with(
            vec![a_id.clone(), b_id.clone()],
            s1_id.clone(),
            false,
            4,
            b"merge",
        );
        let merge_id = compute_cid(&merge_raw);
        let s2_raw =
            make_tree_change_bytes_with(vec![merge_id.clone()], s1_id.clone(), true, 5, b"s2");
        let s2_id = compute_cid(&s2_raw);
        let c_raw = make_tree_change_bytes_with(vec![s2_id.clone()], s2_id.clone(), false, 6, b"c");
        let c_id = compute_cid(&c_raw);
        push_tree_changes(
            &sync_state,
            object_id,
            &[
                &root_raw, &s1_raw, &a_raw, &b_raw, &merge_raw, &s2_raw, &c_raw,
            ],
        );

        let full = request_full_sync(&sync_state, object_id, Vec::new(), Vec::new());
        assert_eq!(full.heads, vec![c_id.clone()]);
        assert_eq!(
            full.snapshot_path,
            vec![s2_id.clone(), s1_id.clone(), root_id.clone()]
        );
        assert_eq!(
            response_change_ids(&full),
            vec![
                root_id.clone(),
                s1_id.clone(),
                a_id.clone(),
                b_id.clone(),
                merge_id.clone(),
                s2_id.clone(),
                c_id.clone(),
            ]
        );

        let partial = request_full_sync(
            &sync_state,
            object_id,
            vec![b_id],
            vec![s1_id.clone(), root_id.clone()],
        );
        assert_eq!(partial.snapshot_path, vec![s2_id.clone(), s1_id, root_id]);
        assert_eq!(
            response_change_ids(&partial),
            vec![a_id, merge_id, s2_id, c_id]
        );
    }

    #[test]
    fn full_sync_walks_diamond_heavy_history_once() {
        let mut candidates_by_id = HashMap::new();
        candidates_by_id.insert("root".to_string(), dag_candidate(Vec::new()));
        let mut head = "root".to_string();
        for index in 0..200 {
            let left = format!("a{index}");
            let right = format!("b{index}");
            let merge = format!("m{index}");
            candidates_by_id.insert(left.clone(), dag_candidate(vec![head.clone()]));
            candidates_by_id.insert(right.clone(), dag_candidate(vec![head.clone()]));
            candidates_by_id.insert(merge.clone(), dag_candidate(vec![left, right]));
            head = merge;
        }
        let heads = vec![head];

        let changes = collect_missing_changes(&heads, &candidates_by_id, &HashSet::new());
        assert_eq!(changes.len(), candidates_by_id.len());
        assert_eq!(changes[..4], ["root", "a0", "b0", "m0"]);
        assert_eq!(
            collect_snapshot_path(&heads, "root", &candidates_by_id),
            vec!["root"]
        );

        let known_ids = HashSet::from(["m100".to_string()]);
        let changes = collect_missing_changes(&heads, &candidates_by_id, &known_ids);
        assert_eq!(changes.len(), 99 * 3);
        assert_eq!(changes[0], "a101");
    }

    #[test]
    fn full_sync_walks_long_linear_history_without_recursion() {
        let mut candidates_by_id = HashMap::new();
        candidates_by_id.insert("root".to_string(), dag_candidate(Vec::new()));
        let mut head = "root".to_string();
        for index in 0..50_000 {
            let change_id = format!("c{index}");
            candidates_by_id.insert(change_id.clone(), dag_candidate(vec![head]));
            head = change_id;
        }
        let heads = vec![head];

        let changes = collect_missing_changes(&heads, &candidates_by_id, &HashSet::new());
        assert_eq!(changes.len(), 50_001);
        assert_eq!(changes[0], "root");
        assert_eq!(changes.last(), heads.first());
        assert_eq!(
            collect_snapshot_path(&heads, "root", &candidates_by_id),
            vec!["root"]
        );
    }

    fn dag_candidate(parent_heads: Vec<String>) -> Candidate {
        Candidate {
            change: RawTreeChangeWithId::default(),
            is_root_payload: false,
            parent_heads,
            is_snapshot: false,
            snapshot_base_id: String::new(),
            timestamp: 0,
        }
    }

    fn push_tree_changes(sync_state: &SharedSyncState, object_id: &str, changes: &[&Vec<u8>]) {
        let changes: Vec<_> = changes
            .iter()
            .map(|raw_change| RawTreeChangeWithId {
                id: compute_cid(raw_change),
                raw_change: raw_change.to_vec(),
            })
            .collect();
        let update = TreeSyncMessage {
            content: Some(TreeSyncContentValue {
                value: Some(treechange::tree_sync_content_value::Value::HeadUpdate(
                    TreeHeadUpdate {
                        heads: vec![changes.last().unwrap().id.clone()],
                        changes,
                        snapshot_path: Vec::new(),
                    },
                )),
            }),
            root_change: None,
        };
        let push = ObjectSyncMessage {
            space_id: "space-1".to_string(),
            object_id: object_id.to_string(),
            request_id: "push".to_string(),
            payload: update.encode_to_vec(),
            ..Default::default()
        };
        handle_object_sync_message(&push.encode_to_vec(), sync_state, &test_peer()).unwrap();
    }

    fn request_full_sync(
        sync_state: &SharedSyncState,
        object_id: &str,
        heads: Vec<String>,
        snapshot_path: Vec<String>,
    ) -> TreeFullSyncResponse {
        let pull = ObjectSyncMessage {
            space_id: "space-1".to_string(),
            object_id: object_id.to_string(),
            request_id: "pull".to_string(),
            payload: TreeSyncMessage {
                content: Some(TreeSyncContentValue {
                    value: Some(treechange::tree_sync_content_value::Value::FullSyncRequest(
                        TreeFullSyncRequest {
                            heads,
                            changes: Vec::new(),
                            snapshot_path,
                        },
                    )),
                }),
                root_change: None,
            }
            .encode_to_vec(),
            ..Default::default()
        };
        let response_bytes =
            handle_object_sync_message(&pull.encode_to_vec(), sync_state, &test_peer()).unwrap();
        let response = ObjectSyncMessage::decode(response_bytes.as_slice()).unwrap();
        let tree_msg = TreeSyncMessage::decode(response.payload.as_slice()).unwrap();
        match tree_msg.content.and_then(|content| content.value) {
            Some(treechange::tree_sync_content_value::Value::FullSyncResponse(response)) => {
                response
            }
            _ => panic!("expected full sync response"),
        }
    }

    fn response_change_ids(response: &TreeFullSyncResponse) -> Vec<String> {
        response
            .changes
            .iter()
            .map(|change| change.id.clone())
            .collect()
    }

    fn make_tree_change_bytes(parent_heads: Vec<String>) -> Vec<u8> {
        make_tree_change_bytes_with(
            parent_heads,
            "snapshot".to_string(),
            false,
            1,
            b"change-data",
        )
    }

    fn make_tree_change_bytes_with(
        parent_heads: Vec<String>,
        snapshot_base_id: String,
        is_snapshot: bool,
        timestamp: i64,
        changes_data: &[u8],
    ) -> Vec<u8> {
        let tree_change = TreeChange {
            tree_head_ids: parent_heads,
            acl_head_id: "acl-head".to_string(),
            snapshot_base_id,
            changes_data: changes_data.to_vec(),
            read_key_id: String::new(),
            timestamp,
            identity: vec![7; 32],
            is_snapshot,
            data_type: String::new(),
        };
        RawTreeChange {
            payload: tree_change.encode_to_vec(),
            signature: vec![9; 64],
        }
        .encode_to_vec()
    }

    fn make_root_change_bytes(space_id: &str, change_type: &str, is_derived: bool) -> Vec<u8> {
        let root_change = RootChange {
            space_id: space_id.to_string(),
            change_type: change_type.to_string(),
            change_payload: b"payload".to_vec(),
            is_derived,
            ..Default::default()
        };
        RawTreeChange {
            payload: root_change.encode_to_vec(),
            // Derived roots omit signatures.
            signature: Vec::new(),
        }
        .encode_to_vec()
    }

    fn make_store_entry(space_id: &str, key_peer_id: &str, timestamp_micro: i64) -> StoreKeyValue {
        let inner = StoreKeyInner {
            peer: vec![1; 32],
            identity: vec![2; 32],
            value: vec![3; 32],
            timestamp_micro,
            acl_head_id: "acl-head".to_string(),
            key: key_peer_id.to_string(),
        };
        StoreKeyValue {
            key_peer_id: key_peer_id.to_string(),
            value: inner.encode_to_vec(),
            identity_signature: vec![4; 64],
            peer_signature: vec![5; 64],
            space_id: space_id.to_string(),
        }
    }
}
