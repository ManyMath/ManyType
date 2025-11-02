//! Minimal consensus log validation compatible with Anytype's RPC shape.
//!
//! Phase 6 requirements focus on:
//! - validating the first record payload CID on `LogAdd`
//! - enforcing `prevId` chain continuity on `RecordAdd`
//! - countersigning accepted records with the node identity

use std::collections::HashMap;
use std::sync::{LazyLock, Mutex};
use std::time::{SystemTime, UNIX_EPOCH};

use anyhow::Result;
use ed25519_dalek::Signer;
use prost::Message;

use manytype_core::crdt::cid::compute_cid;
use manytype_proto::consensus::{
    LogAddRequest, Ok as ConsensusOk, RawRecordWithId, Record, RecordAddRequest,
};

#[derive(Clone)]
struct StoredRecord {
    id: String,
}

static CONSENSUS_LOGS: LazyLock<Mutex<HashMap<String, Vec<StoredRecord>>>> =
    LazyLock::new(|| Mutex::new(HashMap::new()));

#[cfg(test)]
pub static TEST_MUTEX: LazyLock<Mutex<()>> = LazyLock::new(|| Mutex::new(()));

/// Handle /consensusProto.Consensus/LogAdd
///
/// Stores the first unsigned record of a log after verifying its CID.
pub fn handle_log_add(request_bytes: &[u8]) -> Result<Vec<u8>> {
    let request = LogAddRequest::decode(request_bytes)?;
    let record = request
        .record
        .ok_or_else(|| anyhow::anyhow!("missing first log record"))?;
    let computed = compute_cid(&record.payload);
    anyhow::ensure!(computed == record.id, "invalid initial record payload cid");

    let mut logs = CONSENSUS_LOGS.lock().unwrap();
    anyhow::ensure!(
        !logs.contains_key(&request.log_id),
        "consensus log already exists"
    );
    logs.insert(request.log_id, vec![StoredRecord { id: record.id }]);

    Ok(ConsensusOk {}.encode_to_vec())
}

/// Handle /consensusProto.Consensus/RecordAdd
///
/// Adds a countersigned record to an existing log after checking `prevId`.
pub fn handle_record_add(
    request_bytes: &[u8],
    signing_key: &ed25519_dalek::SigningKey,
) -> Result<Vec<u8>> {
    let request = RecordAddRequest::decode(request_bytes)?;
    let mut raw_record = request
        .record
        .ok_or_else(|| anyhow::anyhow!("missing record payload"))?;
    let record = Record::decode(raw_record.payload.as_slice())?;

    let mut logs = CONSENSUS_LOGS.lock().unwrap();
    let log = logs
        .get_mut(&request.log_id)
        .ok_or_else(|| anyhow::anyhow!("consensus log not found"))?;
    let last_record = log
        .last()
        .ok_or_else(|| anyhow::anyhow!("consensus log is empty"))?;
    anyhow::ensure!(
        record.prev_id == last_record.id,
        "record prevId does not match the current head"
    );

    raw_record.acceptor_timestamp = unix_now_secs() as i64;
    raw_record.acceptor_identity = signing_key.verifying_key().to_bytes().to_vec();
    raw_record.acceptor_signature = signing_key.sign(&raw_record.payload).to_bytes().to_vec();

    let payload = raw_record.encode_to_vec();
    let id = compute_cid(&payload);
    log.push(StoredRecord { id: id.clone() });

    let response = RawRecordWithId { payload, id };
    Ok(response.encode_to_vec())
}

/// Ensure a consensus log exists in memory for the given head.
///
/// This is used to re-seed the in-memory consensus view from persisted state
/// after a server restart. Only the latest head is required because
/// `handle_record_add` validates against the current tip.
pub fn ensure_log_exists(log_id: &str, head_id: &str) {
    let mut logs = CONSENSUS_LOGS.lock().unwrap();
    logs.entry(log_id.to_string()).or_insert_with(|| {
        vec![StoredRecord {
            id: head_id.to_string(),
        }]
    });
}

#[cfg(test)]
pub fn reset_logs_for_tests() {
    CONSENSUS_LOGS.lock().unwrap().clear();
}

fn unix_now_secs() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_secs()
}

#[cfg(test)]
mod tests {
    use super::*;
    use manytype_core::crypto::ed25519;
    use manytype_proto::consensus::RawRecord;

    fn test_signing_key() -> ed25519_dalek::SigningKey {
        ed25519::signing_key_from_seed(&[5u8; 32])
    }

    fn reset_logs() {
        reset_logs_for_tests();
    }

    fn raw_record_with_id(payload: &[u8]) -> RawRecordWithId {
        RawRecordWithId {
            payload: payload.to_vec(),
            id: compute_cid(payload),
        }
    }

    #[test]
    fn test_log_add_validates_payload_cid_and_returns_ok() {
        let _guard = TEST_MUTEX.lock().unwrap();
        reset_logs();
        let request = LogAddRequest {
            log_id: "test-log-id-validates-payload".to_string(),
            record: Some(raw_record_with_id(b"test-payload")),
        };
        let request_bytes = request.encode_to_vec();

        let response_bytes = handle_log_add(&request_bytes).unwrap();
        let _ok = ConsensusOk::decode(response_bytes.as_slice()).unwrap();
    }

    #[test]
    fn test_log_add_rejects_wrong_cid() {
        let _guard = TEST_MUTEX.lock().unwrap();
        reset_logs();
        let request = LogAddRequest {
            log_id: "test-log-id-rejects-wrong-cid".to_string(),
            record: Some(RawRecordWithId {
                payload: b"test-payload".to_vec(),
                id: "bafywrong".to_string(),
            }),
        };
        let err = handle_log_add(&request.encode_to_vec()).unwrap_err();
        assert!(
            err.to_string()
                .contains("invalid initial record payload cid")
        );
    }

    #[test]
    fn test_record_add_countersigns_and_computes_cid() {
        let _guard = TEST_MUTEX.lock().unwrap();
        reset_logs();
        let signing_key = test_signing_key();
        let root_payload = b"root-payload".to_vec();
        handle_log_add(
            &LogAddRequest {
                log_id: "test-log-record-add-success".to_string(),
                record: Some(raw_record_with_id(&root_payload)),
            }
            .encode_to_vec(),
        )
        .unwrap();

        let raw_record = RawRecord {
            payload: Record {
                prev_id: compute_cid(&root_payload),
                identity: vec![7; 32],
                data: b"some-change-data".to_vec(),
                timestamp: 1,
            }
            .encode_to_vec(),
            signature: b"sig".to_vec(),
            ..Default::default()
        };
        let request = RecordAddRequest {
            log_id: "test-log-record-add-success".to_string(),
            record: Some(raw_record),
        };

        let response_bytes = handle_record_add(&request.encode_to_vec(), &signing_key).unwrap();
        let response = RawRecordWithId::decode(response_bytes.as_slice()).unwrap();
        let signed = RawRecord::decode(response.payload.as_slice()).unwrap();

        assert_eq!(
            signed.acceptor_identity,
            signing_key.verifying_key().to_bytes().to_vec()
        );
        assert!(!signed.acceptor_signature.is_empty());
        assert_eq!(response.id, compute_cid(&response.payload));
    }

    #[test]
    fn test_record_add_rejects_prev_id_conflict() {
        let _guard = TEST_MUTEX.lock().unwrap();
        reset_logs();
        let signing_key = test_signing_key();
        handle_log_add(
            &LogAddRequest {
                log_id: "test-log-prev-id-conflict".to_string(),
                record: Some(raw_record_with_id(b"root-payload")),
            }
            .encode_to_vec(),
        )
        .unwrap();

        let request = RecordAddRequest {
            log_id: "test-log-prev-id-conflict".to_string(),
            record: Some(RawRecord {
                payload: Record {
                    prev_id: "wrong-prev".to_string(),
                    identity: vec![7; 32],
                    data: b"payload".to_vec(),
                    timestamp: 1,
                }
                .encode_to_vec(),
                signature: b"sig".to_vec(),
                ..Default::default()
            }),
        };
        let err = handle_record_add(&request.encode_to_vec(), &signing_key).unwrap_err();
        assert!(
            err.to_string()
                .contains("record prevId does not match the current head")
        );
    }

    #[test]
    fn ensure_log_exists_seeds_log_for_record_add() {
        let _guard = TEST_MUTEX.lock().unwrap();
        reset_logs();
        let signing_key = test_signing_key();
        ensure_log_exists("restart-log", "prior-cid");

        let response_bytes = handle_record_add(
            &RecordAddRequest {
                log_id: "restart-log".to_string(),
                record: Some(RawRecord {
                    payload: Record {
                        prev_id: "prior-cid".to_string(),
                        identity: vec![7; 32],
                        data: b"payload".to_vec(),
                        timestamp: 1,
                    }
                    .encode_to_vec(),
                    signature: b"sig".to_vec(),
                    ..Default::default()
                }),
            }
            .encode_to_vec(),
            &signing_key,
        )
        .unwrap();

        let response = RawRecordWithId::decode(response_bytes.as_slice()).unwrap();
        assert_eq!(response.id, compute_cid(&response.payload));
    }

    #[test]
    fn ensure_log_exists_is_noop_if_log_present() {
        let _guard = TEST_MUTEX.lock().unwrap();
        reset_logs();
        let signing_key = test_signing_key();
        handle_log_add(
            &LogAddRequest {
                log_id: "existing-log".to_string(),
                record: Some(raw_record_with_id(b"root-payload")),
            }
            .encode_to_vec(),
        )
        .unwrap();

        ensure_log_exists("existing-log", "wrong-head");

        let response_bytes = handle_record_add(
            &RecordAddRequest {
                log_id: "existing-log".to_string(),
                record: Some(RawRecord {
                    payload: Record {
                        prev_id: compute_cid(b"root-payload"),
                        identity: vec![7; 32],
                        data: b"payload".to_vec(),
                        timestamp: 1,
                    }
                    .encode_to_vec(),
                    signature: b"sig".to_vec(),
                    ..Default::default()
                }),
            }
            .encode_to_vec(),
            &signing_key,
        )
        .unwrap();

        let response = RawRecordWithId::decode(response_bytes.as_slice()).unwrap();
        assert_eq!(response.id, compute_cid(&response.payload));
    }
}
