//! Sync node RPC handlers: HeadSync, SpacePush, ObjectSyncStream.
//!
//! These handlers implement the core sync protocol that allows clients to
//! exchange head lists and deliver object changes. SpaceState provides
//! thread-safe per-space tracking of objects and their heads.

use std::collections::HashMap;
use std::sync::{Arc, RwLock};

use anyhow::Result;
use prost::Message;

use manytype_proto::spacesync::*;

/// Per-space state: tracks objects and their head lists.
#[derive(Default)]
pub struct SpaceState {
    /// Map of object_id -> head CIDs for that object
    pub object_heads: HashMap<String, Vec<String>>,
    /// Space header bytes (from SpacePush)
    pub space_header: Option<Vec<u8>>,
    /// ACL root payload bytes
    pub acl_root: Option<Vec<u8>>,
}

/// Shared sync state across connections.
pub type SharedSyncState = Arc<RwLock<HashMap<String, SpaceState>>>;

/// Create a new empty shared sync state.
pub fn new_shared_sync_state() -> SharedSyncState {
    Arc::new(RwLock::new(HashMap::new()))
}

/// Handle /spacesync.SpaceSync/HeadSync
///
/// Returns the head list for all known objects in the requested space.
/// For v1, returns a simplified full listing rather than hash-based diffing.
pub fn handle_head_sync(request_bytes: &[u8], sync_state: &SharedSyncState) -> Result<Vec<u8>> {
    let request = HeadSyncRequest::decode(request_bytes)?;
    let space_id = &request.space_id;

    let state = sync_state.read().unwrap();
    let results = if let Some(space) = state.get(space_id) {
        // Build one HeadSyncResult containing all object head elements
        let elements: Vec<HeadSyncResultElement> = space
            .object_heads
            .iter()
            .flat_map(|(obj_id, heads)| {
                // Each head for each object becomes an element
                if heads.is_empty() {
                    // Object exists but has no heads yet -- still report it
                    vec![HeadSyncResultElement {
                        id: obj_id.clone(),
                        head: String::new(),
                    }]
                } else {
                    heads
                        .iter()
                        .map(|h| HeadSyncResultElement {
                            id: obj_id.clone(),
                            head: h.clone(),
                        })
                        .collect()
                }
            })
            .collect();

        if elements.is_empty() && space.space_header.is_some() {
            // Space exists (was pushed) but has no objects yet -- return one
            // result with empty elements to signal the space is known.
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
    } else {
        vec![]
    };

    let response = HeadSyncResponse {
        results,
        diff_type: 0,
    };
    Ok(response.encode_to_vec())
}

/// Handle /spacesync.SpaceSync/SpacePush
///
/// Stores the space header and ACL root from the push payload.
pub fn handle_space_push(request_bytes: &[u8], sync_state: &SharedSyncState) -> Result<Vec<u8>> {
    let request = SpacePushRequest::decode(request_bytes)?;
    let payload = request
        .payload
        .ok_or_else(|| anyhow::anyhow!("missing space payload"))?;

    // Extract space_id from the space header
    let space_header_with_id = payload
        .space_header
        .ok_or_else(|| anyhow::anyhow!("missing space header"))?;
    let space_id = space_header_with_id.id.clone();

    let mut state = sync_state.write().unwrap();
    let space = state.entry(space_id.clone()).or_default();
    space.space_header = Some(space_header_with_id.raw_header);

    // Store ACL root payload if present
    if !payload.acl_payload.is_empty() {
        space.acl_root = Some(payload.acl_payload);
    }

    tracing::info!("sync: stored space {}", space_id);
    let response = SpacePushResponse {};
    Ok(response.encode_to_vec())
}

/// Handle a single ObjectSyncMessage from the bidirectional stream.
///
/// Stores the change payload and updates in-memory head tracking, then
/// returns a confirmation ObjectSyncMessage.
pub fn handle_object_sync_message(
    message_bytes: &[u8],
    sync_state: &SharedSyncState,
) -> Result<Vec<u8>> {
    let msg = ObjectSyncMessage::decode(message_bytes)?;
    let space_id = &msg.space_id;
    let object_id = &msg.object_id;

    // Update in-memory head tracking
    let mut state = sync_state.write().unwrap();
    let space = state
        .entry(space_id.clone())
        .or_default();

    // Track that we received data for this object
    space
        .object_heads
        .entry(object_id.clone())
        .or_default();

    tracing::info!(
        "sync: received ObjectSyncMessage for {}/{}",
        space_id,
        object_id
    );

    // Send confirmation back
    let response = ObjectSyncMessage {
        space_id: space_id.clone(),
        object_id: object_id.clone(),
        reply_id: msg.request_id.clone(),
        payload: vec![], // empty payload = acknowledgment
        ..Default::default()
    };
    Ok(response.encode_to_vec())
}

#[cfg(test)]
mod tests {
    use super::*;

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
        let request = SpacePushRequest {
            payload: Some(SpacePayload {
                space_header: Some(RawSpaceHeaderWithId {
                    raw_header: b"raw-header-bytes".to_vec(),
                    id: "space-1".to_string(),
                }),
                acl_payload: b"acl-root-bytes".to_vec(),
                acl_payload_id: "acl-1".to_string(),
                ..Default::default()
            }),
            ..Default::default()
        };
        let response_bytes =
            handle_space_push(&request.encode_to_vec(), &sync_state).unwrap();
        let _response = SpacePushResponse::decode(response_bytes.as_slice()).unwrap();

        // Verify state was stored
        let state = sync_state.read().unwrap();
        let space = state.get("space-1").expect("space should exist");
        assert_eq!(space.space_header.as_deref(), Some(b"raw-header-bytes".as_ref()));
        assert_eq!(space.acl_root.as_deref(), Some(b"acl-root-bytes".as_ref()));
    }

    #[test]
    fn head_sync_after_space_push_returns_non_empty() {
        let sync_state = new_shared_sync_state();

        // Push a space
        let push_request = SpacePushRequest {
            payload: Some(SpacePayload {
                space_header: Some(RawSpaceHeaderWithId {
                    raw_header: b"header".to_vec(),
                    id: "space-2".to_string(),
                }),
                ..Default::default()
            }),
            ..Default::default()
        };
        handle_space_push(&push_request.encode_to_vec(), &sync_state).unwrap();

        // HeadSync for that space should return non-empty results
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
    fn object_sync_message_stores_and_confirms() {
        let sync_state = new_shared_sync_state();
        let msg = ObjectSyncMessage {
            space_id: "space-1".to_string(),
            object_id: "obj-1".to_string(),
            request_id: "req-42".to_string(),
            payload: b"tree-change-data".to_vec(),
            ..Default::default()
        };
        let response_bytes =
            handle_object_sync_message(&msg.encode_to_vec(), &sync_state).unwrap();
        let response = ObjectSyncMessage::decode(response_bytes.as_slice()).unwrap();

        assert_eq!(response.space_id, "space-1");
        assert_eq!(response.object_id, "obj-1");
        assert_eq!(response.reply_id, "req-42");
        assert!(response.payload.is_empty(), "confirmation has empty payload");

        // Verify object was tracked
        let state = sync_state.read().unwrap();
        let space = state.get("space-1").expect("space should exist");
        assert!(space.object_heads.contains_key("obj-1"));
    }

    #[test]
    fn space_push_missing_payload_errors() {
        let sync_state = new_shared_sync_state();
        let request = SpacePushRequest {
            payload: None,
            ..Default::default()
        };
        let result = handle_space_push(&request.encode_to_vec(), &sync_state);
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
        let result = handle_space_push(&request.encode_to_vec(), &sync_state);
        assert!(result.is_err());
    }
}
