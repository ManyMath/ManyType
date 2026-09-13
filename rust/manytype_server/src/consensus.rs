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
use manytype_proto::aclrecord::AclRoot;
use manytype_proto::consensus::{
    LogAddRequest, Ok as ConsensusOk, RawRecord, RawRecordWithId, Record, RecordAddRequest,
};

use crate::storage::sync_state::SharedSyncState;

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
    let is_space_linked = is_space_linked_log_add(&request);
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
    // Space-linked logs are registered by `persist_space_linked_log_add` once
    // their root is durable.
    if !is_space_linked {
        logs.insert(request.log_id, vec![StoredRecord { id: record.id }]);
    }

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
/// An existing log is left untouched. Only the latest head is required because
/// `handle_record_add` validates against the current tip.
pub fn ensure_log_exists(log_id: &str, head_id: &str) {
    let mut logs = CONSENSUS_LOGS.lock().unwrap();
    logs.entry(log_id.to_string()).or_insert_with(|| {
        vec![StoredRecord {
            id: head_id.to_string(),
        }]
    });
}

/// Re-seed an in-memory log from persisted ACL state when available.
///
/// The persisted head always wins over the in-memory one, so a record whose
/// persistence failed cannot leave a phantom head behind.
///
/// Returns the persisted head used for seeding, or `None` when the requested
/// log does not map to a persisted space-linked ACL log.
pub fn ensure_log_exists_from_sync_state(
    log_id: &str,
    sync_state: &SharedSyncState,
) -> Option<String> {
    let head_id = persisted_head(log_id, sync_state)?;
    CONSENSUS_LOGS.lock().unwrap().insert(
        log_id.to_string(),
        vec![StoredRecord {
            id: head_id.clone(),
        }],
    );
    Some(head_id)
}

fn persisted_head(log_id: &str, sync_state: &SharedSyncState) -> Option<String> {
    let state = sync_state.read().unwrap();
    let space = state.get(log_id)?;
    if !space.acl_head.is_empty() {
        Some(space.acl_head.clone())
    } else if !space.acl_root_id.is_empty() {
        Some(space.acl_root_id.clone())
    } else {
        None
    }
}

/// True when the persisted sync state already contains a space-linked ACL log.
pub fn has_persisted_space_linked_log(log_id: &str, sync_state: &SharedSyncState) -> bool {
    let state = sync_state.read().unwrap();
    let Some(space) = state.get(log_id) else {
        return false;
    };
    !space.acl_root_id.is_empty() || !space.acl_head.is_empty() || !space.acl_records.is_empty()
}

/// Returns true when a generic `LogAdd` is an ACL root for its space-scoped log.
pub fn is_space_linked_log_add(request: &LogAddRequest) -> bool {
    let Some(raw_with_id) = request.record.as_ref() else {
        return false;
    };
    let Ok(raw_record) = RawRecord::decode(raw_with_id.payload.as_slice()) else {
        return false;
    };
    let Ok(record) = Record::decode(raw_record.payload.as_slice()) else {
        return false;
    };
    if !record.prev_id.is_empty() {
        return false;
    }
    let Ok(acl_root) = AclRoot::decode(record.data.as_slice()) else {
        return false;
    };
    acl_root.space_id == request.log_id
}

/// Persist a direct `LogAdd` root when it is a space-linked ACL root.
///
/// Direct consensus RPCs remain generic, so non-ACL logs are ignored here.
pub fn persist_space_linked_log_add(
    request: &LogAddRequest,
    sync_state: &SharedSyncState,
) -> Result<bool> {
    if !is_space_linked_log_add(request) {
        return Ok(false);
    }
    let raw_with_id = request.record.as_ref().expect("space-linked record exists");

    let mut logs = CONSENSUS_LOGS.lock().unwrap();
    anyhow::ensure!(
        !logs.contains_key(&request.log_id)
            && !has_persisted_space_linked_log(&request.log_id, sync_state),
        "consensus log already exists"
    );
    sync_state.upsert_space_metadata(
        &request.log_id,
        None,
        Some(raw_with_id.payload.clone()),
        Some(raw_with_id.id.clone()),
        None,
        None,
        None,
        None,
    )?;
    logs.insert(
        request.log_id.clone(),
        vec![StoredRecord {
            id: raw_with_id.id.clone(),
        }],
    );
    Ok(true)
}

/// Persist a direct `RecordAdd` result when it belongs to a persisted space log.
///
/// The record must still extend the persisted head; concurrent adds that were
/// accepted against the same head are rejected here. Afterwards the in-memory
/// head matches the persisted log, rolling back `handle_record_add` on failure.
pub fn persist_space_linked_record_add(
    log_id: &str,
    raw_with_id_bytes: &[u8],
    record_id: &str,
    sync_state: &SharedSyncState,
) -> Result<bool> {
    let mut logs = CONSENSUS_LOGS.lock().unwrap();
    let Some(head_id) = persisted_head(log_id, sync_state) else {
        return Ok(false);
    };
    let persisted = record_prev_id(raw_with_id_bytes).and_then(|prev_id| {
        anyhow::ensure!(
            prev_id == head_id,
            "record prevId does not match the current head"
        );
        sync_state.append_acl_record(log_id, raw_with_id_bytes.to_vec(), record_id)
    });
    let id = match persisted {
        Ok(()) => record_id.to_string(),
        Err(_) => head_id,
    };
    logs.insert(log_id.to_string(), vec![StoredRecord { id }]);
    persisted.map(|()| true)
}

fn record_prev_id(raw_with_id_bytes: &[u8]) -> Result<String> {
    let raw_with_id = RawRecordWithId::decode(raw_with_id_bytes)?;
    let raw_record = RawRecord::decode(raw_with_id.payload.as_slice())?;
    Ok(Record::decode(raw_record.payload.as_slice())?.prev_id)
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
    use manytype_proto::aclrecord::{
        AclAccountInvite, AclContentValue, AclData, AclUserPermissions, acl_content_value::Value,
    };
    use manytype_proto::consensus::RawRecord;
    use tempfile::TempDir;

    use crate::storage::sync_state::new_shared_sync_state_at;

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

    fn build_test_acl_root(seed: &[u8; 32], space_id: &str) -> RawRecordWithId {
        let sk = ed25519::signing_key_from_seed(seed);
        let public_key = sk.verifying_key().to_bytes().to_vec();

        let acl_root = AclRoot {
            identity: public_key.clone(),
            master_key: public_key.clone(),
            space_id: space_id.to_string(),
            encrypted_read_key: vec![1, 2, 3, 4],
            timestamp: 1000,
            identity_signature: ed25519::sign(&sk, &public_key).to_bytes().to_vec(),
            ..Default::default()
        };
        let record = Record {
            prev_id: String::new(),
            identity: public_key,
            data: acl_root.encode_to_vec(),
            timestamp: 1000,
        };
        let record_bytes = record.encode_to_vec();
        let signature = ed25519::sign(&sk, &record_bytes);
        let raw_record = RawRecord {
            payload: record_bytes,
            signature: signature.to_bytes().to_vec(),
            ..Default::default()
        };
        let raw_bytes = raw_record.encode_to_vec();
        RawRecordWithId {
            payload: raw_bytes.clone(),
            id: compute_cid(&raw_bytes),
        }
    }

    fn build_test_acl_record(seed: &[u8; 32], prev_id: &str) -> RawRecordWithId {
        let sk = ed25519::signing_key_from_seed(seed);
        let record = Record {
            prev_id: prev_id.to_string(),
            identity: sk.verifying_key().to_bytes().to_vec(),
            data: AclData {
                acl_content: vec![AclContentValue {
                    value: Some(Value::Invite(AclAccountInvite {
                        invite_key: vec![42; 32],
                        permissions: AclUserPermissions::Writer as i32,
                        ..Default::default()
                    })),
                }],
            }
            .encode_to_vec(),
            timestamp: 2000,
        };
        let record_bytes = record.encode_to_vec();
        let signature = ed25519::sign(&sk, &record_bytes);
        let raw_record = RawRecord {
            payload: record_bytes,
            signature: signature.to_bytes().to_vec(),
            ..Default::default()
        };
        let raw_bytes = raw_record.encode_to_vec();
        RawRecordWithId {
            payload: raw_bytes.clone(),
            id: compute_cid(&raw_bytes),
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

    #[test]
    fn persist_space_linked_log_add_exposes_root_via_acl_reads() {
        let _guard = TEST_MUTEX.lock().unwrap();
        reset_logs();
        let sync_state = crate::sync_node::new_shared_sync_state();
        let root = build_test_acl_root(&[1u8; 32], "space-1");
        let request = LogAddRequest {
            log_id: "space-1".to_string(),
            record: Some(root.clone()),
        };

        handle_log_add(&request.encode_to_vec()).unwrap();
        let persisted = persist_space_linked_log_add(&request, &sync_state).unwrap();

        assert!(persisted);
        let records = sync_state.list_acl_records("space-1", "");
        assert_eq!(records.len(), 1);
        let stored = RawRecordWithId::decode(records[0].as_slice()).unwrap();
        assert_eq!(stored.id, root.id);
    }

    #[test]
    fn persisted_space_linked_record_add_reseeds_after_restart() {
        let _guard = TEST_MUTEX.lock().unwrap();
        reset_logs();
        let temp_dir = TempDir::new().unwrap();
        let path = temp_dir.path().join("sync.redb");
        let root = build_test_acl_root(&[1u8; 32], "space-1");
        let first = build_test_acl_record(&[1u8; 32], &root.id);
        let second_seed = [2u8; 32];

        {
            let sync_state = new_shared_sync_state_at(&path).unwrap();
            let log_add = LogAddRequest {
                log_id: "space-1".to_string(),
                record: Some(root.clone()),
            };
            handle_log_add(&log_add.encode_to_vec()).unwrap();
            persist_space_linked_log_add(&log_add, &sync_state).unwrap();

            let first_bytes = handle_record_add(
                &RecordAddRequest {
                    log_id: "space-1".to_string(),
                    record: Some(RawRecord::decode(first.payload.as_slice()).unwrap()),
                }
                .encode_to_vec(),
                &test_signing_key(),
            )
            .unwrap();
            let first_response = RawRecordWithId::decode(first_bytes.as_slice()).unwrap();
            persist_space_linked_record_add(
                "space-1",
                first_bytes.as_slice(),
                &first_response.id,
                &sync_state,
            )
            .unwrap();
        }

        reset_logs_for_tests();
        let reopened = new_shared_sync_state_at(&path).unwrap();
        let seeded_head = ensure_log_exists_from_sync_state("space-1", &reopened);
        assert!(seeded_head.is_some());

        let second = build_test_acl_record(&second_seed, &seeded_head.clone().unwrap());
        let second_bytes = handle_record_add(
            &RecordAddRequest {
                log_id: "space-1".to_string(),
                record: Some(RawRecord::decode(second.payload.as_slice()).unwrap()),
            }
            .encode_to_vec(),
            &test_signing_key(),
        )
        .unwrap();
        let second_response = RawRecordWithId::decode(second_bytes.as_slice()).unwrap();
        persist_space_linked_record_add(
            "space-1",
            second_bytes.as_slice(),
            &second_response.id,
            &reopened,
        )
        .unwrap();

        let records = reopened.list_acl_records("space-1", "");
        assert_eq!(records.len(), 3);
        let last = RawRecordWithId::decode(records.last().unwrap().as_slice()).unwrap();
        assert_eq!(last.id, second_response.id);
    }

    fn raw_record_with_data(prev_id: &str, data: Vec<u8>) -> RawRecord {
        RawRecord {
            payload: Record {
                prev_id: prev_id.to_string(),
                identity: vec![7; 32],
                data,
                timestamp: 1,
            }
            .encode_to_vec(),
            signature: b"sig".to_vec(),
            ..Default::default()
        }
    }

    fn add_space_linked_record(
        log_id: &str,
        record: RawRecord,
        sync_state: &SharedSyncState,
    ) -> Result<RawRecordWithId> {
        ensure_log_exists_from_sync_state(log_id, sync_state);
        let response_bytes = handle_record_add(
            &RecordAddRequest {
                log_id: log_id.to_string(),
                record: Some(record),
            }
            .encode_to_vec(),
            &test_signing_key(),
        )?;
        let response = RawRecordWithId::decode(response_bytes.as_slice())?;
        persist_space_linked_record_add(log_id, &response_bytes, &response.id, sync_state)?;
        Ok(response)
    }

    #[test]
    fn failed_log_add_persist_can_be_retried() {
        let _guard = TEST_MUTEX.lock().unwrap();
        reset_logs();
        let temp_dir = TempDir::new().unwrap();
        let path = temp_dir.path().join("sync.redb");
        let root = build_test_acl_root(&[1u8; 32], "space-1");
        let log_add = LogAddRequest {
            log_id: "space-1".to_string(),
            record: Some(root),
        };

        {
            let full = SharedSyncState::open_with_limit(&path, 1).unwrap();
            handle_log_add(&log_add.encode_to_vec()).unwrap();
            let error = persist_space_linked_log_add(&log_add, &full).unwrap_err();
            assert!(error.to_string().contains("quota exceeded"));
        }

        let sync_state = new_shared_sync_state_at(&path).unwrap();
        assert!(!has_persisted_space_linked_log("space-1", &sync_state));
        handle_log_add(&log_add.encode_to_vec()).unwrap();
        assert!(persist_space_linked_log_add(&log_add, &sync_state).unwrap());
        assert!(
            persist_space_linked_log_add(&log_add, &sync_state)
                .unwrap_err()
                .to_string()
                .contains("already exists")
        );
    }

    #[test]
    fn failed_record_persist_does_not_advance_the_log_head() {
        let _guard = TEST_MUTEX.lock().unwrap();
        reset_logs();
        let temp_dir = TempDir::new().unwrap();
        let sync_state =
            SharedSyncState::open_with_limit(temp_dir.path().join("sync.redb"), 64 * 1024).unwrap();
        let root = build_test_acl_root(&[1u8; 32], "space-1");
        let log_add = LogAddRequest {
            log_id: "space-1".to_string(),
            record: Some(root.clone()),
        };
        handle_log_add(&log_add.encode_to_vec()).unwrap();
        persist_space_linked_log_add(&log_add, &sync_state).unwrap();

        let error = add_space_linked_record(
            "space-1",
            raw_record_with_data(&root.id, vec![0; 128 * 1024]),
            &sync_state,
        )
        .unwrap_err();
        assert!(error.to_string().contains("quota exceeded"));
        assert_eq!(
            CONSENSUS_LOGS.lock().unwrap()["space-1"].last().unwrap().id,
            root.id
        );

        let accepted = add_space_linked_record(
            "space-1",
            raw_record_with_data(&root.id, b"small".to_vec()),
            &sync_state,
        )
        .unwrap();
        let records = sync_state.list_acl_records("space-1", "");
        assert_eq!(records.len(), 2);
        assert_eq!(
            RawRecordWithId::decode(records[1].as_slice()).unwrap().id,
            accepted.id
        );

        let stale_payload = raw_record_with_data(&root.id, b"stale".to_vec()).encode_to_vec();
        let stale = RawRecordWithId {
            id: compute_cid(&stale_payload),
            payload: stale_payload,
        };
        let error = persist_space_linked_record_add(
            "space-1",
            &stale.encode_to_vec(),
            &stale.id,
            &sync_state,
        )
        .unwrap_err();
        assert!(error.to_string().contains("prevId does not match"));
        assert_eq!(sync_state.list_acl_records("space-1", "").len(), 2);
    }
}
