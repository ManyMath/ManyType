//! Coordinator node handler -- provides network configuration to connecting clients.

use std::time::{SystemTime, UNIX_EPOCH};

use anyhow::Result;
use ed25519_dalek::{Signer, Verifier};
use prost::Message;

use manytype_proto::consensus::{RawRecord, RawRecordWithId, RecordAddRequest};
use manytype_proto::coordinator::{
    AclAddRecordRequest, AclAddRecordResponse, AclGetRecordsRequest, AclGetRecordsResponse,
    NetworkConfigurationRequest, NetworkConfigurationResponse, Node, NodeType,
    SpaceMakeShareableRequest, SpaceMakeShareableResponse, SpacePermissions, SpaceReceipt,
    SpaceReceiptWithSignature, SpaceSignRequest, SpaceSignResponse, SpaceStatus,
    SpaceStatusCheckRequest, SpaceStatusCheckResponse, SpaceStatusPayload,
};
use manytype_proto::spacesync::{RawSpaceHeader, SpaceHeader};

use crate::consensus;
use crate::storage::sync_state::SharedSyncState;

/// Configuration for the coordinator subsystem.
pub struct CoordinatorConfig {
    pub network_id: String,
    pub peer_id: String,
    pub addresses: Vec<String>,
}

pub const SPACE_RECEIPT_TTL_SECS: u64 = 6 * 60 * 60;

/// Handle /coordinator.Coordinator/NetworkConfiguration
///
/// Returns the network configuration with this node's addresses and supported
/// roles. In manytype's single-binary architecture, one node advertises all
/// four roles (tree, file, coordinator, consensus).
pub fn handle_network_configuration(
    request_bytes: &[u8],
    config: &CoordinatorConfig,
) -> Result<Vec<u8>> {
    // Decode request (validates it's well-formed protobuf)
    let _request = NetworkConfigurationRequest::decode(request_bytes)?;

    // Build response with this server as the only node.
    // NodeType enum values: TreeApi=0, FileApi=1, CoordinatorApi=2, ConsensusApi=3
    let node = Node {
        peer_id: config.peer_id.clone(),
        addresses: config.addresses.clone(),
        types: vec![
            NodeType::TreeApi as i32,
            NodeType::FileApi as i32,
            NodeType::CoordinatorApi as i32,
            NodeType::ConsensusApi as i32,
        ],
    };

    let response = NetworkConfigurationResponse {
        network_id: config.network_id.clone(),
        nodes: vec![node],
        configuration_id: "manytype-v1".to_string(),
        creation_time_unix: std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs(),
    };

    Ok(response.encode_to_vec())
}

/// Handle /coordinator.Coordinator/SpaceSign
///
/// Creates a receipt bound to the requester's peer ID and the account
/// identity embedded in the provided space header.
pub fn handle_space_sign(
    request_bytes: &[u8],
    config: &CoordinatorConfig,
    signing_key: &ed25519_dalek::SigningKey,
    remote_peer_id: &[u8],
) -> Result<Vec<u8>> {
    let request = SpaceSignRequest::decode(request_bytes)?;
    let account_identity = decode_account_identity(&request.header)?;
    let receipt = build_signed_space_receipt(
        &request.space_id,
        &hex::encode(remote_peer_id),
        &account_identity,
        config,
        signing_key,
    )?;
    let response = SpaceSignResponse {
        receipt: Some(receipt),
    };
    tracing::info!("coordinator: signed space {}", request.space_id);
    Ok(response.encode_to_vec())
}

/// Handle /coordinator.Coordinator/SpaceStatusCheck
pub fn handle_space_status_check(
    request_bytes: &[u8],
    sync_state: &SharedSyncState,
) -> Result<Vec<u8>> {
    let request = SpaceStatusCheckRequest::decode(request_bytes)?;
    let state = sync_state.read().unwrap();
    let payload = if let Some(space) = state.get(&request.space_id) {
        SpaceStatusPayload {
            status: SpaceStatus::Created as i32,
            permissions: SpacePermissions::Owner as i32,
            is_shared: space.is_shared,
            ..Default::default()
        }
    } else {
        SpaceStatusPayload {
            status: SpaceStatus::NotExists as i32,
            permissions: SpacePermissions::Unknown as i32,
            is_shared: false,
            ..Default::default()
        }
    };
    let response = SpaceStatusCheckResponse {
        payload: Some(payload),
    };
    Ok(response.encode_to_vec())
}

/// Handle /coordinator.Coordinator/SpaceMakeShareable
pub fn handle_space_make_shareable(
    request_bytes: &[u8],
    sync_state: &SharedSyncState,
) -> Result<Vec<u8>> {
    let request = SpaceMakeShareableRequest::decode(request_bytes)?;
    sync_state.mark_space_shared(&request.space_id)?;
    Ok(SpaceMakeShareableResponse::default().encode_to_vec())
}

/// Handle /coordinator.Coordinator/AclAddRecord
pub fn handle_acl_add_record(
    request_bytes: &[u8],
    sync_state: &SharedSyncState,
    signing_key: &ed25519_dalek::SigningKey,
) -> Result<Vec<u8>> {
    let request = AclAddRecordRequest::decode(request_bytes)?;
    let raw_record = RawRecord::decode(request.payload.as_slice())?;

    let seed_head = {
        let state = sync_state.read().unwrap();
        let space = state
            .get(&request.space_id)
            .ok_or_else(|| anyhow::anyhow!("space not found: {}", request.space_id))?;

        if !space.acl_head.is_empty() {
            space.acl_head.clone()
        } else if !space.acl_root_id.is_empty() {
            space.acl_root_id.clone()
        } else {
            return Err(anyhow::anyhow!(
                "space ACL root not initialized: {}",
                request.space_id
            ));
        }
    };

    consensus::ensure_log_exists(&request.space_id, &seed_head);
    let record_add_request = RecordAddRequest {
        log_id: request.space_id.clone(),
        record: Some(raw_record),
    };
    let raw_with_id_bytes =
        consensus::handle_record_add(&record_add_request.encode_to_vec(), signing_key)?;
    let raw_with_id = RawRecordWithId::decode(raw_with_id_bytes.as_slice())?;
    let record_id = raw_with_id.id.clone();
    let payload = raw_with_id.payload.clone();

    sync_state.append_acl_record(&request.space_id, raw_with_id_bytes, &record_id)?;

    Ok(AclAddRecordResponse { record_id, payload }.encode_to_vec())
}

/// Handle /coordinator.Coordinator/AclGetRecords
pub fn handle_acl_get_records(
    request_bytes: &[u8],
    sync_state: &SharedSyncState,
) -> Result<Vec<u8>> {
    let request = AclGetRecordsRequest::decode(request_bytes)?;
    let response = AclGetRecordsResponse {
        records: sync_state.list_acl_records(&request.space_id, &request.acl_head),
    };
    Ok(response.encode_to_vec())
}

pub fn build_signed_space_receipt(
    space_id: &str,
    remote_peer_id: &str,
    account_identity: &[u8],
    config: &CoordinatorConfig,
    signing_key: &ed25519_dalek::SigningKey,
) -> Result<SpaceReceiptWithSignature> {
    let receipt = SpaceReceipt {
        space_id: space_id.to_string(),
        peer_id: remote_peer_id.to_string(),
        account_identity: account_identity.to_vec(),
        network_id: config.network_id.clone(),
        valid_until: unix_now_secs() + SPACE_RECEIPT_TTL_SECS,
    };
    let payload = receipt.encode_to_vec();
    let signature = signing_key.sign(&payload).to_bytes().to_vec();
    Ok(SpaceReceiptWithSignature {
        space_receipt_payload: payload,
        signature,
    })
}

pub fn validate_space_receipt(
    signed_receipt: &SpaceReceiptWithSignature,
    expected_space_id: &str,
    expected_peer_id: &str,
    expected_account_identity: &[u8],
    config: &CoordinatorConfig,
    verifying_key: &ed25519_dalek::VerifyingKey,
) -> Result<()> {
    let receipt = SpaceReceipt::decode(signed_receipt.space_receipt_payload.as_slice())?;
    anyhow::ensure!(
        receipt.space_id == expected_space_id,
        "receipt space id is incorrect"
    );
    anyhow::ensure!(
        receipt.peer_id == expected_peer_id,
        "receipt peer id is incorrect"
    );
    anyhow::ensure!(
        receipt.account_identity == expected_account_identity,
        "receipt account identity is incorrect"
    );
    anyhow::ensure!(
        receipt.network_id == config.network_id,
        "receipt network id is incorrect"
    );
    anyhow::ensure!(receipt.valid_until > unix_now_secs(), "receipt is expired");

    let signature_bytes: [u8; 64] = signed_receipt
        .signature
        .as_slice()
        .try_into()
        .map_err(|_| anyhow::anyhow!("receipt signature must be 64 bytes"))?;
    let signature = ed25519_dalek::Signature::from_bytes(&signature_bytes);
    verifying_key.verify(&signed_receipt.space_receipt_payload, &signature)?;
    Ok(())
}

pub fn decode_account_identity(raw_header_bytes: &[u8]) -> Result<Vec<u8>> {
    let raw_header = RawSpaceHeader::decode(raw_header_bytes)?;
    let header = SpaceHeader::decode(raw_header.space_header.as_slice())?;
    Ok(header.identity)
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
    use crate::consensus::reset_logs_for_tests;
    use crate::sync_node::new_shared_sync_state;
    use crate::sync_node::new_shared_sync_state_at;
    use manytype_core::crdt::cid::compute_cid;
    use manytype_core::crypto::ed25519;
    use manytype_proto::consensus::{RawRecord, Record};
    use manytype_proto::spacesync::SpacePushRequest;
    use tempfile::TempDir;

    fn test_signing_key() -> ed25519_dalek::SigningKey {
        ed25519::signing_key_from_seed(&[7u8; 32])
    }

    fn test_server_libp2p_peer_id() -> String {
        let signing_key = test_signing_key();
        let verifying_key = ed25519::verifying_key(&signing_key);
        ed25519::ed25519_pubkey_to_libp2p_peer_id(&verifying_key.to_bytes())
    }

    fn test_space_header(account_identity: &[u8]) -> Vec<u8> {
        let header = SpaceHeader {
            identity: account_identity.to_vec(),
            space_type: "anytype.space".to_string(),
            ..Default::default()
        };
        RawSpaceHeader {
            space_header: header.encode_to_vec(),
            signature: vec![1; 64],
        }
        .encode_to_vec()
    }

    fn acl_add_request(space_id: &str, prev_id: &str, data: &[u8]) -> AclAddRecordRequest {
        AclAddRecordRequest {
            space_id: space_id.to_string(),
            payload: RawRecord {
                payload: Record {
                    prev_id: prev_id.to_string(),
                    identity: vec![7; 32],
                    data: data.to_vec(),
                    timestamp: 1,
                }
                .encode_to_vec(),
                signature: b"sig".to_vec(),
                ..Default::default()
            }
            .encode_to_vec(),
        }
    }

    #[test]
    fn test_network_configuration_returns_valid_response() {
        let config = CoordinatorConfig {
            network_id: "manytype-test-net".to_string(),
            peer_id: test_server_libp2p_peer_id(),
            addresses: vec!["127.0.0.1:4830".to_string()],
        };

        // Empty request (all fields default)
        let request = NetworkConfigurationRequest::default();
        let request_bytes = request.encode_to_vec();

        let response_bytes = handle_network_configuration(&request_bytes, &config).unwrap();
        let response = NetworkConfigurationResponse::decode(response_bytes.as_slice()).unwrap();

        assert_eq!(response.network_id, "manytype-test-net");
        assert_eq!(response.configuration_id, "manytype-v1");
        assert!(!response.nodes.is_empty(), "should have at least one node");
        assert!(
            response.creation_time_unix > 0,
            "creation time should be set"
        );
    }

    #[test]
    fn test_node_has_peer_id_address_and_all_roles() {
        let config = CoordinatorConfig {
            network_id: "test-net".to_string(),
            peer_id: test_server_libp2p_peer_id(),
            addresses: vec!["127.0.0.1:4830".to_string(), "192.168.1.1:4830".to_string()],
        };

        let request_bytes = NetworkConfigurationRequest::default().encode_to_vec();
        let response_bytes = handle_network_configuration(&request_bytes, &config).unwrap();
        let response = NetworkConfigurationResponse::decode(response_bytes.as_slice()).unwrap();

        let node = &response.nodes[0];
        assert!(
            node.peer_id.starts_with("12D3KooW"),
            "peer_id was: {}",
            node.peer_id
        );
        assert_eq!(node.addresses.len(), 2);
        assert_eq!(node.addresses[0], "127.0.0.1:4830");

        // Should advertise all four roles
        assert!(
            node.types.contains(&(NodeType::TreeApi as i32)),
            "should have TreeApi"
        );
        assert!(
            node.types.contains(&(NodeType::CoordinatorApi as i32)),
            "should have CoordinatorApi"
        );
        assert!(
            node.types.contains(&(NodeType::FileApi as i32)),
            "should have FileApi"
        );
        assert!(
            node.types.contains(&(NodeType::ConsensusApi as i32)),
            "should have ConsensusApi"
        );
    }

    #[test]
    fn test_network_configuration_peer_id_is_libp2p_encoded() {
        let config = CoordinatorConfig {
            network_id: "test-net".to_string(),
            peer_id: test_server_libp2p_peer_id(),
            addresses: vec!["127.0.0.1:4830".to_string()],
        };

        let request_bytes = NetworkConfigurationRequest::default().encode_to_vec();
        let response_bytes = handle_network_configuration(&request_bytes, &config).unwrap();
        let response = NetworkConfigurationResponse::decode(response_bytes.as_slice()).unwrap();

        assert!(
            response.nodes[0].peer_id.starts_with("12D3KooW"),
            "peer_id should be libp2p-encoded, got: {}",
            response.nodes[0].peer_id
        );
    }

    #[test]
    fn test_space_sign_returns_receipt_for_remote_peer() {
        let config = CoordinatorConfig {
            network_id: "manytype-dev".to_string(),
            peer_id: "test-peer".to_string(),
            addresses: vec!["127.0.0.1:4830".to_string()],
        };
        let signing_key = test_signing_key();
        let account_identity = vec![3; 32];
        let request = SpaceSignRequest {
            space_id: "space-1".to_string(),
            header: test_space_header(&account_identity),
            ..Default::default()
        };

        let response_bytes = handle_space_sign(
            &request.encode_to_vec(),
            &config,
            &signing_key,
            b"remote-peer",
        )
        .unwrap();
        let response = SpaceSignResponse::decode(response_bytes.as_slice()).unwrap();
        let receipt = response.receipt.unwrap();
        validate_space_receipt(
            &receipt,
            "space-1",
            &hex::encode(b"remote-peer"),
            &account_identity,
            &config,
            &ed25519::verifying_key(&signing_key),
        )
        .unwrap();
    }

    #[test]
    fn test_space_status_check_reports_known_space_as_owner() {
        let _guard = crate::consensus::TEST_MUTEX.lock().unwrap();
        reset_logs_for_tests();
        let sync_state = new_shared_sync_state();
        let push_request = SpacePushRequest {
            payload: Some(manytype_proto::spacesync::SpacePayload {
                space_header: Some(manytype_proto::spacesync::RawSpaceHeaderWithId {
                    raw_header: b"raw".to_vec(),
                    id: "space-1".to_string(),
                }),
                acl_payload: b"acl".to_vec(),
                ..Default::default()
            }),
            ..Default::default()
        };
        sync_state
            .upsert_space_metadata(
                "space-1",
                Some(b"raw".to_vec()),
                Some(b"acl".to_vec()),
                Some("acl-root-id".to_string()),
                None,
                None,
                Some(false),
            )
            .unwrap();

        let response_bytes = handle_space_status_check(
            &SpaceStatusCheckRequest {
                space_id: "space-1".to_string(),
            }
            .encode_to_vec(),
            &sync_state,
        )
        .unwrap();
        let response = SpaceStatusCheckResponse::decode(response_bytes.as_slice()).unwrap();
        let payload = response.payload.unwrap();
        assert_eq!(payload.status, SpaceStatus::Created as i32);
        assert_eq!(payload.permissions, SpacePermissions::Owner as i32);
        assert!(!payload.is_shared);
        let _ = push_request;
    }

    #[test]
    fn space_make_shareable_updates_status_check() {
        let sync_state = new_shared_sync_state();
        sync_state
            .upsert_space_metadata(
                "space-1",
                Some(b"raw".to_vec()),
                Some(b"acl".to_vec()),
                Some("acl-root-id".to_string()),
                None,
                None,
                Some(false),
            )
            .unwrap();

        handle_space_make_shareable(
            &SpaceMakeShareableRequest {
                space_id: "space-1".to_string(),
            }
            .encode_to_vec(),
            &sync_state,
        )
        .unwrap();

        let response = SpaceStatusCheckResponse::decode(
            handle_space_status_check(
                &SpaceStatusCheckRequest {
                    space_id: "space-1".to_string(),
                }
                .encode_to_vec(),
                &sync_state,
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();

        assert!(response.payload.unwrap().is_shared);
    }

    #[test]
    fn space_make_shareable_survives_restart() {
        let temp_dir = TempDir::new().unwrap();
        {
            let sync_state = new_shared_sync_state_at(temp_dir.path()).unwrap();
            sync_state
                .upsert_space_metadata(
                    "space-1",
                    Some(b"raw".to_vec()),
                    Some(b"acl".to_vec()),
                    Some("acl-root-id".to_string()),
                    None,
                    None,
                    Some(false),
                )
                .unwrap();

            handle_space_make_shareable(
                &SpaceMakeShareableRequest {
                    space_id: "space-1".to_string(),
                }
                .encode_to_vec(),
                &sync_state,
            )
            .unwrap();
        }

        let reopened = new_shared_sync_state_at(temp_dir.path()).unwrap();
        let response = SpaceStatusCheckResponse::decode(
            handle_space_status_check(
                &SpaceStatusCheckRequest {
                    space_id: "space-1".to_string(),
                }
                .encode_to_vec(),
                &reopened,
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();

        assert!(response.payload.unwrap().is_shared);
    }

    #[test]
    fn acl_add_record_returns_server_confirmed_record_id() {
        let _guard = crate::consensus::TEST_MUTEX.lock().unwrap();
        reset_logs_for_tests();
        let sync_state = new_shared_sync_state();
        sync_state
            .upsert_space_metadata(
                "space-1",
                Some(b"raw".to_vec()),
                Some(b"acl-root".to_vec()),
                Some("root-cid".to_string()),
                None,
                None,
                Some(false),
            )
            .unwrap();

        let response_bytes = handle_acl_add_record(
            &acl_add_request("space-1", "root-cid", b"first").encode_to_vec(),
            &sync_state,
            &test_signing_key(),
        )
        .unwrap();
        let response = AclAddRecordResponse::decode(response_bytes.as_slice()).unwrap();

        assert_eq!(response.record_id, compute_cid(&response.payload));
        let stored = sync_state.list_acl_records("space-1", "");
        assert_eq!(stored.len(), 1);
        assert_eq!(
            RawRecordWithId::decode(stored[0].as_slice()).unwrap().id,
            response.record_id
        );
    }

    #[test]
    fn acl_add_record_and_get_records_follow_cursor_rules() {
        let _guard = crate::consensus::TEST_MUTEX.lock().unwrap();
        reset_logs_for_tests();
        let sync_state = new_shared_sync_state();
        sync_state
            .upsert_space_metadata(
                "space-1",
                Some(b"raw".to_vec()),
                Some(b"acl-root".to_vec()),
                Some("root-cid".to_string()),
                None,
                None,
                Some(false),
            )
            .unwrap();

        let first = AclAddRecordResponse::decode(
            handle_acl_add_record(
                &acl_add_request("space-1", "root-cid", b"first").encode_to_vec(),
                &sync_state,
                &test_signing_key(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        let second = AclAddRecordResponse::decode(
            handle_acl_add_record(
                &acl_add_request("space-1", &first.record_id, b"second").encode_to_vec(),
                &sync_state,
                &test_signing_key(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();

        let all = AclGetRecordsResponse::decode(
            handle_acl_get_records(
                &AclGetRecordsRequest {
                    space_id: "space-1".to_string(),
                    acl_head: String::new(),
                }
                .encode_to_vec(),
                &sync_state,
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        assert_eq!(all.records.len(), 2);

        let tail = AclGetRecordsResponse::decode(
            handle_acl_get_records(
                &AclGetRecordsRequest {
                    space_id: "space-1".to_string(),
                    acl_head: first.record_id.clone(),
                }
                .encode_to_vec(),
                &sync_state,
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        assert_eq!(tail.records.len(), 1);
        assert_eq!(
            RawRecordWithId::decode(tail.records[0].as_slice())
                .unwrap()
                .id,
            second.record_id
        );
    }

    #[test]
    fn acl_add_record_reseeds_consensus_after_restart() {
        let _guard = crate::consensus::TEST_MUTEX.lock().unwrap();
        reset_logs_for_tests();
        let temp_dir = TempDir::new().unwrap();
        let signing_key = test_signing_key();
        {
            let sync_state = new_shared_sync_state_at(temp_dir.path()).unwrap();
            sync_state
                .upsert_space_metadata(
                    "space-1",
                    Some(b"raw".to_vec()),
                    Some(b"acl-root".to_vec()),
                    Some("root-cid".to_string()),
                    None,
                    None,
                    Some(false),
                )
                .unwrap();

            let first = AclAddRecordResponse::decode(
                handle_acl_add_record(
                    &acl_add_request("space-1", "root-cid", b"first").encode_to_vec(),
                    &sync_state,
                    &signing_key,
                )
                .unwrap()
                .as_slice(),
            )
            .unwrap();
            handle_acl_add_record(
                &acl_add_request("space-1", &first.record_id, b"second").encode_to_vec(),
                &sync_state,
                &signing_key,
            )
            .unwrap();
        }

        reset_logs_for_tests();
        let reopened = new_shared_sync_state_at(temp_dir.path()).unwrap();
        let get_response = AclGetRecordsResponse::decode(
            handle_acl_get_records(
                &AclGetRecordsRequest {
                    space_id: "space-1".to_string(),
                    acl_head: String::new(),
                }
                .encode_to_vec(),
                &reopened,
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        let latest_id = RawRecordWithId::decode(get_response.records[1].as_slice())
            .unwrap()
            .id;

        let third = AclAddRecordResponse::decode(
            handle_acl_add_record(
                &acl_add_request("space-1", &latest_id, b"third").encode_to_vec(),
                &reopened,
                &signing_key,
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();

        assert_eq!(third.record_id, compute_cid(&third.payload));
        assert_eq!(reopened.list_acl_records("space-1", "").len(), 3);
    }
}
