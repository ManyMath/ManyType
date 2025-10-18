//! File node stub -- accepts block pushes without storing to S3.
//!
//! In v1, the file node acknowledges all BlockPush requests but does not
//! persist the data. Real S3/local storage is deferred to a later phase.

use anyhow::Result;
use prost::Message;

use manytype_proto::filesync::{BlockPushRequest, Ok as FilesyncOk};

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

#[cfg(test)]
mod tests {
    use super::*;

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
}
