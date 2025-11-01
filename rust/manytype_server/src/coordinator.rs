//! Coordinator node handler -- provides network configuration to connecting clients.

use std::time::{SystemTime, UNIX_EPOCH};

use anyhow::Result;
use ed25519_dalek::{Signer, Verifier};
use prost::Message;

use manytype_proto::coordinator::{
    NetworkConfigurationRequest, NetworkConfigurationResponse, Node, NodeType, SpacePermissions,
    SpaceReceipt, SpaceReceiptWithSignature, SpaceSignRequest, SpaceSignResponse, SpaceStatus,
    SpaceStatusCheckRequest, SpaceStatusCheckResponse, SpaceStatusPayload,
};
use manytype_proto::spacesync::{RawSpaceHeader, SpaceHeader};

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
    let payload = if state.contains_key(&request.space_id) {
        SpaceStatusPayload {
            status: SpaceStatus::Created as i32,
            permissions: SpacePermissions::Owner as i32,
            is_shared: false,
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
    use crate::sync_node::new_shared_sync_state;
    use manytype_core::crypto::ed25519;
    use manytype_proto::spacesync::SpacePushRequest;

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
            .upsert_space_metadata("space-1", Some(b"raw".to_vec()), Some(b"acl".to_vec()))
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
        let _ = push_request;
    }
}
