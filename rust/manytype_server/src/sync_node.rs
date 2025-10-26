//! Sync node RPC handlers: HeadSync, SpacePush, ObjectSyncStream.
//!
//! These handlers implement the core sync protocol that allows clients to
//! exchange head lists and deliver object changes. Per Phase 5, the shared
//! sync state is backed by persistent redb storage rather than an in-memory
//! map tied to a single process lifetime.

use anyhow::Result;
use prost::Message;

use manytype_core::crdt::cid::compute_cid;
use manytype_core::ldiff::{Diff, Element, Hasher, Range};
use manytype_proto::coordinator::SpaceReceiptWithSignature;
use manytype_proto::spacesync::{RawSpaceHeader, SpaceHeader};
use manytype_proto::spacesync::*;
use manytype_proto::treechange::{RawTreeChange, TreeChange};

use crate::coordinator::{self, CoordinatorConfig};

pub use crate::storage::sync_state::{SharedSyncState, SpaceState};
#[cfg(test)]
pub use crate::storage::sync_state::{new_shared_sync_state, new_shared_sync_state_at};

const LDIFF_DIVIDE_FACTOR: usize = 32;
const LDIFF_COMPARE_THRESHOLD: usize = 256;

/// Handle /spacesync.SpaceSync/HeadSync
///
/// Returns the head list for all known objects in the requested space.
/// For Phase 5 this still returns a full listing; Phase 6 narrows this to
/// hash-based range diffing.
pub fn handle_head_sync(request_bytes: &[u8], sync_state: &SharedSyncState) -> Result<Vec<u8>> {
    let request = HeadSyncRequest::decode(request_bytes)?;
    let space_id = &request.space_id;

    let state = sync_state.read().unwrap();
    let results = if let Some(space) = state.get(space_id) {
        if !request.ranges.is_empty() && matches!(request.diff_type(), DiffType::V2 | DiffType::V3) {
            let diff = build_head_diff(space, request.diff_type());
            diff.ranges(
                &request
                    .ranges
                    .iter()
                    .map(|range| Range {
                        from: range.from,
                        to: range.to,
                        elements: range.elements,
                        limit: range.limit as usize,
                    })
                    .collect::<Vec<_>>(),
            )
            .into_iter()
            .map(|result| HeadSyncResult {
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
            .collect()
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
    } else if !request.ranges.is_empty() && matches!(request.diff_type(), DiffType::V2 | DiffType::V3) {
            let diff = Diff::new_with_type(
                LDIFF_DIVIDE_FACTOR,
                LDIFF_COMPARE_THRESHOLD,
                request.diff_type(),
            );
            diff.ranges(
                &request
                    .ranges
                    .iter()
                    .map(|range| Range {
                        from: range.from,
                        to: range.to,
                        elements: range.elements,
                        limit: range.limit as usize,
                    })
                    .collect::<Vec<_>>(),
            )
            .into_iter()
            .map(|result| HeadSyncResult {
                hash: result.hash,
                elements: Vec::new(),
                count: result.count as u32,
            })
            .collect()
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
    Ok(response.encode_to_vec())
}

/// Handle /spacesync.SpaceSync/StoreDiff.
///
/// Uses the same ldiff range-hash algorithm as HeadSync, but for persisted
/// key-value store entries keyed by `keyPeerId`.
pub fn handle_store_diff(request_bytes: &[u8], sync_state: &SharedSyncState) -> Result<Vec<u8>> {
    let request = StoreDiffRequest::decode(request_bytes)?;
    let space_id = &request.space_id;

    let state = sync_state.read().unwrap();
    let results = if let Some(space) = state.get(space_id) {
        if !request.ranges.is_empty() {
            let diff = build_store_diff(space);
            diff.ranges(
                &request
                    .ranges
                    .iter()
                    .map(|range| Range {
                        from: range.from,
                        to: range.to,
                        elements: range.elements,
                        limit: range.limit as usize,
                    })
                    .collect::<Vec<_>>(),
            )
            .into_iter()
            .map(|result| HeadSyncResult {
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
            .collect()
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
        Diff::new(LDIFF_DIVIDE_FACTOR, LDIFF_COMPARE_THRESHOLD)
            .ranges(
                &request
                    .ranges
                    .iter()
                    .map(|range| Range {
                        from: range.from,
                        to: range.to,
                        elements: range.elements,
                        limit: range.limit as usize,
                    })
                    .collect::<Vec<_>>(),
            )
            .into_iter()
            .map(|result| HeadSyncResult {
                hash: result.hash,
                elements: Vec::new(),
                count: result.count as u32,
            })
            .collect()
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
    remote_peer_id: &[u8],
) -> Result<Vec<u8>> {
    let request = SpacePushRequest::decode(request_bytes)?;
    let payload = request
        .payload
        .ok_or_else(|| anyhow::anyhow!("missing space payload"))?;

    let space_header_with_id = payload
        .space_header
        .ok_or_else(|| anyhow::anyhow!("missing space header"))?;
    let space_id = space_header_with_id.id.clone();
    let account_identity = decode_space_header_account_identity(&space_header_with_id.raw_header)?;
    let signed_receipt = SpaceReceiptWithSignature::decode(request.credential.as_slice())?;
    coordinator::validate_space_receipt(
        &signed_receipt,
        &space_id,
        &hex::encode(remote_peer_id),
        &account_identity,
        coordinator_config,
        &signing_key.verifying_key(),
    )?;

    sync_state.upsert_space_metadata(
        &space_id,
        Some(space_header_with_id.raw_header),
        (!payload.acl_payload.is_empty()).then_some(payload.acl_payload),
    )?;

    tracing::info!("sync: stored space {}", space_id);
    let response = SpacePushResponse {};
    Ok(response.encode_to_vec())
}

/// Handle a single ObjectSyncMessage from the bidirectional stream.
///
/// Stores pushed raw changes. When the payload is empty, treats the message as
/// a pull request and returns the local raw changes as a single
/// length-prefixed payload.
pub fn handle_object_sync_message(
    message_bytes: &[u8],
    sync_state: &SharedSyncState,
) -> Result<Vec<u8>> {
    let msg = ObjectSyncMessage::decode(message_bytes)?;
    let space_id = &msg.space_id;
    let object_id = &msg.object_id;

    let response_payload = if !msg.payload.is_empty() {
        let change_id = compute_cid(&msg.payload);
        let parent_heads = extract_parent_heads(&msg.payload);
        sync_state.record_object_change(
            space_id,
            object_id,
            &change_id,
            msg.payload.clone(),
            &parent_heads,
        )?;
        Vec::new()
    } else {
        {
            let mut state = sync_state.write().unwrap();
            state
                .entry(space_id.clone())
                .or_default()
                .object_heads
                .entry(object_id.clone())
                .or_default();
        }
        encode_length_prefixed_chunks(sync_state.list_object_changes(space_id, object_id))
    };

    tracing::info!(
        "sync: received ObjectSyncMessage for {}/{}",
        space_id,
        object_id
    );

    let response = ObjectSyncMessage {
        space_id: space_id.clone(),
        object_id: object_id.clone(),
        reply_id: msg.request_id.clone(),
        payload: response_payload,
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
pub fn handle_store_elements_messages(
    messages: &[Vec<u8>],
    sync_state: &SharedSyncState,
) -> Result<Vec<Vec<u8>>> {
    let mut active_space_id = String::new();
    let mut requested = Vec::new();

    for message_bytes in messages {
        let mut msg = StoreKeyValue::decode(message_bytes.as_slice())?;

        if !msg.space_id.is_empty() {
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

fn collect_object_elements(space: &SpaceState) -> Vec<HeadSyncResultElement> {
    let mut object_ids: Vec<_> = space.object_heads.keys().cloned().collect();
    object_ids.sort();

    let mut elements = Vec::new();
    for object_id in object_ids {
        let mut heads = space.object_heads.get(&object_id).cloned().unwrap_or_default();
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

fn extract_parent_heads(raw_change_bytes: &[u8]) -> Vec<String> {
    let Ok(raw_change) = RawTreeChange::decode(raw_change_bytes) else {
        return Vec::new();
    };
    let Ok(tree_change) = TreeChange::decode(raw_change.payload.as_slice()) else {
        return Vec::new();
    };
    tree_change.tree_head_ids
}

fn decode_space_header_account_identity(raw_header_bytes: &[u8]) -> Result<Vec<u8>> {
    let raw_header = RawSpaceHeader::decode(raw_header_bytes)?;
    let header = SpaceHeader::decode(raw_header.space_header.as_slice())?;
    Ok(header.identity)
}

fn store_entry_head(entry: &StoreKeyValue) -> String {
    if let Ok(inner) = StoreKeyInner::decode(entry.value.as_slice()) {
        return format!("{:020}", inner.timestamp_micro.max(0));
    }
    compute_cid(&entry.value)
}

fn encode_length_prefixed_chunks(chunks: Vec<Vec<u8>>) -> Vec<u8> {
    let mut out = Vec::new();
    for chunk in chunks {
        out.extend_from_slice(&(chunk.len() as u32).to_le_bytes());
        out.extend_from_slice(&chunk);
    }
    out
}

#[cfg(test)]
mod tests {
    use tempfile::TempDir;

    use super::*;
    use manytype_core::crypto::ed25519;
    use manytype_proto::treechange::{RawTreeChange, TreeChange};

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

    fn make_space_header_with_receipt(
        space_id: &str,
        account_identity: &[u8],
        remote_peer_id: &[u8],
    ) -> (RawSpaceHeaderWithId, Vec<u8>) {
        let signing_key = test_signing_key();
        let config = test_coordinator_config();
        let raw_header = RawSpaceHeader {
            space_header: SpaceHeader {
                identity: account_identity.to_vec(),
                space_type: "anytype.space".to_string(),
                ..Default::default()
            }
            .encode_to_vec(),
            signature: vec![1; 64],
        }
        .encode_to_vec();
        let signed_receipt = coordinator::build_signed_space_receipt(
            space_id,
            &hex::encode(remote_peer_id),
            account_identity,
            &config,
            &signing_key,
        )
        .unwrap();
        (
            RawSpaceHeaderWithId {
                raw_header,
                id: space_id.to_string(),
            },
            signed_receipt.encode_to_vec(),
        )
    }

    #[test]
    fn head_sync_empty_space_returns_empty_results() {
        let sync_state = new_shared_sync_state();
        let request = HeadSyncRequest {
            space_id: "unknown-space".to_string(),
            ..Default::default()
        };
        let response_bytes = handle_head_sync(&request.encode_to_vec(), &sync_state).unwrap();
        let response = HeadSyncResponse::decode(response_bytes.as_slice()).unwrap();
        assert!(response.results.is_empty());
    }

    #[test]
    fn space_push_stores_header_and_returns_empty_response() {
        let sync_state = new_shared_sync_state();
        let account_identity = vec![4; 32];
        let (space_header, credential) =
            make_space_header_with_receipt("space-1", &account_identity, b"peer-1");
        let request = SpacePushRequest {
            payload: Some(SpacePayload {
                space_header: Some(space_header),
                acl_payload: b"acl-root-bytes".to_vec(),
                acl_payload_id: "acl-1".to_string(),
                ..Default::default()
            }),
            credential,
            ..Default::default()
        };
        let response_bytes = handle_space_push(
            &request.encode_to_vec(),
            &sync_state,
            &test_coordinator_config(),
            &test_signing_key(),
            b"peer-1",
        )
        .unwrap();
        let _response = SpacePushResponse::decode(response_bytes.as_slice()).unwrap();

        let state = sync_state.read().unwrap();
        let space = state.get("space-1").expect("space should exist");
        assert!(space.space_header.is_some());
        assert_eq!(space.acl_root.as_deref(), Some(b"acl-root-bytes".as_ref()));
    }

    #[test]
    fn head_sync_after_space_push_returns_non_empty() {
        let sync_state = new_shared_sync_state();
        let account_identity = vec![5; 32];
        let (space_header, credential) =
            make_space_header_with_receipt("space-2", &account_identity, b"peer-2");
        let push_request = SpacePushRequest {
            payload: Some(SpacePayload {
                space_header: Some(space_header),
                ..Default::default()
            }),
            credential,
            ..Default::default()
        };
        handle_space_push(
            &push_request.encode_to_vec(),
            &sync_state,
            &test_coordinator_config(),
            &test_signing_key(),
            b"peer-2",
        )
        .unwrap();

        let hs_request = HeadSyncRequest {
            space_id: "space-2".to_string(),
            ..Default::default()
        };
        let response_bytes =
            handle_head_sync(&hs_request.encode_to_vec(), &sync_state).unwrap();
        let response = HeadSyncResponse::decode(response_bytes.as_slice()).unwrap();
        assert!(
            !response.results.is_empty(),
            "HeadSync should return non-empty results for pushed space"
        );
    }

    #[test]
    fn object_sync_message_stores_change_and_confirms() {
        let sync_state = new_shared_sync_state();
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
            handle_object_sync_message(&msg.encode_to_vec(), &sync_state).unwrap();
        let response = ObjectSyncMessage::decode(response_bytes.as_slice()).unwrap();

        assert_eq!(response.space_id, "space-1");
        assert_eq!(response.object_id, "obj-1");
        assert_eq!(response.reply_id, "req-42");
        assert!(response.payload.is_empty(), "confirmation has empty payload");

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
    fn object_sync_pull_request_returns_length_prefixed_raw_changes() {
        let sync_state = new_shared_sync_state();
        let first_change = make_tree_change_bytes(Vec::new());
        let first_change_id = compute_cid(&first_change);
        let second_change = make_tree_change_bytes(vec![first_change_id]);

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
            handle_object_sync_message(&msg.encode_to_vec(), &sync_state).unwrap();
        }

        let pull_request = ObjectSyncMessage {
            space_id: "space-1".to_string(),
            object_id: "obj-1".to_string(),
            request_id: "pull-1".to_string(),
            payload: Vec::new(),
            ..Default::default()
        };
        let response_bytes =
            handle_object_sync_message(&pull_request.encode_to_vec(), &sync_state).unwrap();
        let response = ObjectSyncMessage::decode(response_bytes.as_slice()).unwrap();
        assert_eq!(response.reply_id, "pull-1");

        let payload = response.payload;
        let first_len =
            u32::from_le_bytes(payload[0..4].try_into().unwrap()) as usize;
        let first = payload[4..4 + first_len].to_vec();
        let second_offset = 4 + first_len;
        let second_len = u32::from_le_bytes(
            payload[second_offset..second_offset + 4].try_into().unwrap(),
        ) as usize;
        let second = payload
            [second_offset + 4..second_offset + 4 + second_len]
            .to_vec();

        assert_eq!(first, first_change);
        assert_eq!(second, second_change);
    }

    #[test]
    fn persisted_object_heads_survive_reopen() {
        let temp_dir = TempDir::new().unwrap();
        let raw_change = make_tree_change_bytes(Vec::new());
        let change_id = compute_cid(&raw_change);
        {
            let sync_state = new_shared_sync_state_at(temp_dir.path()).unwrap();
            let msg = ObjectSyncMessage {
                space_id: "space-1".to_string(),
                object_id: "obj-1".to_string(),
                request_id: "req-1".to_string(),
                payload: raw_change,
                ..Default::default()
            };
            handle_object_sync_message(&msg.encode_to_vec(), &sync_state).unwrap();
        }

        let reopened = new_shared_sync_state_at(temp_dir.path()).unwrap();
        let request = HeadSyncRequest {
            space_id: "space-1".to_string(),
            ..Default::default()
        };
        let response_bytes = handle_head_sync(&request.encode_to_vec(), &reopened).unwrap();
        let response = HeadSyncResponse::decode(response_bytes.as_slice()).unwrap();

        assert_eq!(response.results.len(), 1);
        assert_eq!(response.results[0].elements.len(), 1);
        assert_eq!(response.results[0].elements[0].id, "obj-1");
        assert_eq!(response.results[0].elements[0].head, change_id);
    }

    #[test]
    fn space_push_missing_payload_errors() {
        let sync_state = new_shared_sync_state();
        let request = SpacePushRequest {
            payload: None,
            ..Default::default()
        };
        let result = handle_space_push(
            &request.encode_to_vec(),
            &sync_state,
            &test_coordinator_config(),
            &test_signing_key(),
            b"peer-1",
        );
        assert!(result.is_err());
    }

    #[test]
    fn space_push_missing_header_errors() {
        let sync_state = new_shared_sync_state();
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
            b"peer-1",
        );
        assert!(result.is_err());
    }

    #[test]
    fn space_push_rejects_missing_receipt() {
        let sync_state = new_shared_sync_state();
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
            ..Default::default()
        };

        let result = handle_space_push(
            &request.encode_to_vec(),
            &sync_state,
            &test_coordinator_config(),
            &test_signing_key(),
            b"peer-1",
        );
        assert!(result.is_err());
    }

    #[test]
    fn store_diff_lists_known_store_entries() {
        let sync_state = new_shared_sync_state();
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
    fn store_elements_can_save_and_fetch_entries() {
        let sync_state = new_shared_sync_state();
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
        )
        .unwrap();

        let fetched = StoreKeyValue::decode(responses[0].as_slice()).unwrap();
        let terminator = StoreKeyValue::decode(responses[1].as_slice()).unwrap();
        assert_eq!(fetched.key_peer_id, existing.key_peer_id);
        assert!(terminator.key_peer_id.is_empty());

        let stored_new = sync_state.get_store_entry("space-1", "settings-peer-2").unwrap();
        assert_eq!(stored_new.key_peer_id, new_entry.key_peer_id);
        assert_eq!(stored_new.value, new_entry.value);
    }

    fn make_tree_change_bytes(parent_heads: Vec<String>) -> Vec<u8> {
        let tree_change = TreeChange {
            tree_head_ids: parent_heads,
            acl_head_id: "acl-head".to_string(),
            snapshot_base_id: "snapshot".to_string(),
            changes_data: b"change-data".to_vec(),
            read_key_id: String::new(),
            timestamp: 1,
            identity: vec![7; 32],
            is_snapshot: false,
            data_type: String::new(),
        };
        RawTreeChange {
            payload: tree_change.encode_to_vec(),
            signature: vec![9; 64],
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
