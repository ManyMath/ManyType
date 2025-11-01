//! File node stub -- accepts block pushes without storing to S3.
//!
//! In v1, the file node acknowledges all BlockPush requests but does not
//! persist the data. Real S3/local storage is deferred to a later phase.

use anyhow::Result;
use prost::Message;

use manytype_proto::filesync::{
    AccountInfoRequest, AccountInfoResponse, BlockPushRequest, CheckRequest, CheckResponse,
    Ok as FilesyncOk, SpaceInfoRequest, SpaceInfoResponse,
};

use crate::storage::sync_state::SharedSyncState;

/// Handle /filesync.File/BlockPush
///
/// Stub: logs receipt and returns success without storing the block.
pub fn handle_block_push(request_bytes: &[u8]) -> Result<Vec<u8>> {
    // Decode to validate structure
    let request = BlockPushRequest::decode(request_bytes)?;
    eprintln!(
        "file_node: BlockPush received for file={} space={} ({} bytes, stub - not stored)",
        request.file_id,
        request.space_id,
        request.data.len()
    );
    // Return empty Ok response
    let response = FilesyncOk {};
    Ok(response.encode_to_vec())
}

/// Handle /filesync.File/Check
///
/// Returns the currently known space IDs and a permissive write flag so
/// official clients can validate the file node surface during bootstrap.
pub fn handle_check(request_bytes: &[u8], sync_state: &SharedSyncState) -> Result<Vec<u8>> {
    let _request = CheckRequest::decode(request_bytes)?;

    let mut space_ids: Vec<_> = sync_state.read().unwrap().keys().cloned().collect();
    space_ids.sort();

    let response = CheckResponse {
        space_ids,
        allow_write: true,
    };
    Ok(response.encode_to_vec())
}

/// Handle /filesync.File/SpaceInfo
pub fn handle_space_info(request_bytes: &[u8]) -> Result<Vec<u8>> {
    let request = SpaceInfoRequest::decode(request_bytes)?;
    let response = SpaceInfoResponse {
        limit_bytes: 0,
        total_usage_bytes: 0,
        cids_count: 0,
        files_count: 0,
        space_usage_bytes: 0,
        space_id: request.space_id,
    };
    Ok(response.encode_to_vec())
}

/// Handle /filesync.File/AccountInfo
pub fn handle_account_info(request_bytes: &[u8]) -> Result<Vec<u8>> {
    let _request = AccountInfoRequest::decode(request_bytes)?;
    let response = AccountInfoResponse {
        limit_bytes: 0,
        total_usage_bytes: 0,
        total_cids_count: 0,
        spaces: Vec::new(),
        account_limit_bytes: 0,
    };
    Ok(response.encode_to_vec())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::sync_node::new_shared_sync_state;

    #[test]
    fn test_block_push_returns_ok() {
        let request = BlockPushRequest {
            space_id: "test-space".to_string(),
            file_id: "test-file".to_string(),
            cid: b"test-cid".to_vec(),
            data: b"block-data-bytes".to_vec(),
        };
        let request_bytes = request.encode_to_vec();

        let response_bytes = handle_block_push(&request_bytes).unwrap();
        // FilesyncOk is an empty message
        let _ok = FilesyncOk::decode(response_bytes.as_slice()).unwrap();
    }

    #[test]
    fn test_block_push_empty_data() {
        let request = BlockPushRequest::default();
        let request_bytes = request.encode_to_vec();
        let result = handle_block_push(&request_bytes);
        assert!(result.is_ok());
    }

    #[test]
    fn test_check_returns_known_spaces_and_write_access() {
        let sync_state = new_shared_sync_state();
        sync_state
            .upsert_space_metadata("space-b", Some(vec![1]), None)
            .unwrap();
        sync_state
            .upsert_space_metadata("space-a", Some(vec![2]), None)
            .unwrap();

        let response_bytes = handle_check(&CheckRequest {}.encode_to_vec(), &sync_state).unwrap();
        let response = CheckResponse::decode(response_bytes.as_slice()).unwrap();

        assert_eq!(
            response.space_ids,
            vec!["space-a".to_string(), "space-b".to_string()]
        );
        assert!(response.allow_write);
    }

    #[test]
    fn test_space_info_echoes_requested_space() {
        let response_bytes = handle_space_info(
            &SpaceInfoRequest {
                space_id: "space-1".to_string(),
            }
            .encode_to_vec(),
        )
        .unwrap();
        let response = SpaceInfoResponse::decode(response_bytes.as_slice()).unwrap();
        assert_eq!(response.space_id, "space-1");
    }

    #[test]
    fn test_account_info_returns_empty_totals() {
        let response_bytes = handle_account_info(&AccountInfoRequest {}.encode_to_vec()).unwrap();
        let response = AccountInfoResponse::decode(response_bytes.as_slice()).unwrap();
        assert_eq!(response.total_usage_bytes, 0);
        assert!(response.spaces.is_empty());
    }
}
