//! Consensus node stubs -- approve-all for single-user v1 operation.
//!
//! In v1, the consensus node unconditionally approves all LogAdd and
//! RecordAdd requests. This is safe because only a single user operates
//! the server; multi-user consensus validation is deferred to a later phase.

use anyhow::Result;
use prost::Message;

use manytype_proto::consensus::{
    LogAddRequest, Ok as ConsensusOk, RawRecordWithId, RecordAddRequest,
};

/// Handle /consensusProto.Consensus/LogAdd
///
/// Stub: approves all log additions for single-user operation.
/// Returns an empty Ok response.
pub fn handle_log_add(request_bytes: &[u8]) -> Result<Vec<u8>> {
    // Decode request to validate it's well-formed
    let _request = LogAddRequest::decode(request_bytes)?;
    eprintln!("consensus: approved LogAdd (stub)");
    // Return Ok {} (empty success response)
    let response = ConsensusOk {};
    Ok(response.encode_to_vec())
}

/// Handle /consensusProto.Consensus/RecordAdd
///
/// Stub: approves all record additions and returns the record with a
/// computed CID as its ID. The CID is computed from the raw record's
/// payload bytes, matching Anytype's consensus behavior.
pub fn handle_record_add(request_bytes: &[u8]) -> Result<Vec<u8>> {
    let request = RecordAddRequest::decode(request_bytes)?;
    let log_id = &request.log_id;
    eprintln!("consensus: approved RecordAdd for log {log_id} (stub)");

    // Encode the RawRecord back to bytes and compute its CID.
    // The ID is the CID of the entire marshalled RawRecord, matching
    // Anytype's consensus node behavior.
    let record = request.record.unwrap_or_default();
    let record_bytes = record.encode_to_vec();
    let cid = manytype_core::crdt::cid::compute_cid(&record_bytes);

    let response = RawRecordWithId {
        payload: record_bytes,
        id: cid,
    };
    Ok(response.encode_to_vec())
}

#[cfg(test)]
mod tests {
    use super::*;
    use manytype_proto::consensus::RawRecord;

    #[test]
    fn test_log_add_approves_and_returns_ok() {
        let request = LogAddRequest {
            log_id: "test-log-id".to_string(),
            record: Some(RawRecordWithId {
                payload: b"test-payload".to_vec(),
                id: "test-record-id".to_string(),
            }),
        };
        let request_bytes = request.encode_to_vec();

        let response_bytes = handle_log_add(&request_bytes).unwrap();
        // ConsensusOk is an empty message -- decoding should succeed
        let _ok = ConsensusOk::decode(response_bytes.as_slice()).unwrap();
    }

    #[test]
    fn test_record_add_returns_record_with_cid() {
        let raw_record = RawRecord {
            payload: b"some-change-data".to_vec(),
            signature: b"sig".to_vec(),
            ..Default::default()
        };

        let request = RecordAddRequest {
            log_id: "test-log".to_string(),
            record: Some(raw_record.clone()),
        };
        let request_bytes = request.encode_to_vec();

        let response_bytes = handle_record_add(&request_bytes).unwrap();
        let response = RawRecordWithId::decode(response_bytes.as_slice()).unwrap();

        // ID should be a valid CID string (starts with 'b')
        assert!(
            response.id.starts_with("b"),
            "CID should start with 'b', got: {}",
            response.id
        );
        // Payload should be the marshalled RawRecord bytes
        assert!(!response.payload.is_empty());
        // Verify the CID matches recomputation
        let expected_cid =
            manytype_core::crdt::cid::compute_cid(&response.payload);
        assert_eq!(response.id, expected_cid);
    }

    #[test]
    fn test_log_add_empty_request_still_succeeds() {
        let request = LogAddRequest::default();
        let request_bytes = request.encode_to_vec();
        let result = handle_log_add(&request_bytes);
        assert!(result.is_ok());
    }
}
