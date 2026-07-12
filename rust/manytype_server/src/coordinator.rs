//! Coordinator node handler -- provides network configuration to connecting clients.

use std::time::{SystemTime, UNIX_EPOCH};

use anyhow::Result;
use ed25519_dalek::{Signer, Verifier};
use prost::Message;

use manytype_proto::consensus::{RawRecord, RawRecordWithId, RecordAddRequest};
use manytype_proto::coordinator::{
    AccountDeleteRequest, AccountDeleteResponse, AccountDeletionConfirmPayload,
    AclAddRecordRequest, AclAddRecordResponse, AclGetRecordsRequest, AclGetRecordsResponse,
    AclUploadInviteRequest, AclUploadInviteResponse, DeletionConfirmPayloadWithSignature,
    DeletionLogRequest, DeletionLogResponse, NetworkConfigurationRequest,
    NetworkConfigurationResponse, Node, NodeType, SpaceDeleteRequest, SpaceDeleteResponse,
    SpaceMakeShareableRequest, SpaceMakeShareableResponse, SpacePermissions, SpaceReceipt,
    SpaceReceiptWithSignature, SpaceSignRequest, SpaceSignResponse, SpaceStatus,
    SpaceStatusCheckRequest, SpaceStatusCheckResponse, SpaceStatusPayload,
};
use manytype_proto::crypto::{Key, KeyType};
use manytype_proto::spacesync::{RawSpaceHeader, SpaceHeader};

use crate::auth::AuthenticatedPeer;
use crate::consensus;
use crate::file_node;
use crate::storage::sync_state::SharedSyncState;
use manytype_core::crdt::cid::compute_cid;

/// Configuration for the coordinator subsystem.
pub struct CoordinatorConfig {
    pub network_id: String,
    pub peer_id: String,
    pub addresses: Vec<String>,
}

pub const SPACE_RECEIPT_TTL_SECS: u64 = 6 * 60 * 60;
const ACCOUNT_DELETE_MAX_AGE_SECS: i64 = 5 * 60;
const ACCOUNT_DELETE_MAX_FUTURE_SKEW_SECS: i64 = 60;

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

    // Build response with this server as the only physical peer, but advertise
    // one Node entry per API type (mirrors the official any-sync config shape
    // and avoids client code that assumes a single NodeType per entry).
    let nodes = [
        NodeType::TreeApi,
        NodeType::FileApi,
        NodeType::CoordinatorApi,
        NodeType::ConsensusApi,
    ]
    .into_iter()
    .map(|node_type| Node {
        peer_id: config.peer_id.clone(),
        addresses: config.addresses.clone(),
        types: vec![node_type as i32],
    })
    .collect();

    let response = NetworkConfigurationResponse {
        network_id: config.network_id.clone(),
        nodes,
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
    authenticated_peer: &AuthenticatedPeer<'_>,
    sync_state: &SharedSyncState,
) -> Result<Vec<u8>> {
    let request = SpaceSignRequest::decode(request_bytes)?;
    let account_identity = validate_space_header(
        &request.space_id,
        &request.header,
        authenticated_peer.account_identity(),
    )?;
    sync_state.claim_space_owner(&request.space_id, authenticated_peer)?;
    let receipt = build_signed_space_receipt(
        &request.space_id,
        authenticated_peer.id(),
        &account_identity,
        config,
        signing_key,
    )?;
    // Registers the space as SpaceStatusCreated for the signing peer so an
    // immediately-following SpaceStatusCheck preflight (see sync_service.dart
    // `discoverSyncTargetsForSync`) succeeds on a brand-new space, before any
    // sync data has been pushed. SpacePush/HeadSync upsert the same entry
    // later with the real header/ACL payloads once available.
    sync_state.upsert_space_metadata(
        &request.space_id,
        Some(request.header.clone()),
        None,
        None,
        None,
        None,
        None,
        None,
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
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let request = SpaceStatusCheckRequest::decode(request_bytes)?;
    let owns_space = sync_state.peer_owns_space(&request.space_id, authenticated_peer);
    let state = sync_state.read().unwrap();
    let payload = if let Some(space) = state.get(&request.space_id).filter(|_| owns_space) {
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
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let request = SpaceMakeShareableRequest::decode(request_bytes)?;
    sync_state.authorize_space(&request.space_id, authenticated_peer)?;
    sync_state.mark_space_shared(&request.space_id)?;
    Ok(SpaceMakeShareableResponse::default().encode_to_vec())
}

/// Handle /coordinator.Coordinator/AclAddRecord
pub fn handle_acl_add_record(
    request_bytes: &[u8],
    sync_state: &SharedSyncState,
    signing_key: &ed25519_dalek::SigningKey,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let request = AclAddRecordRequest::decode(request_bytes)?;
    sync_state.authorize_space(&request.space_id, authenticated_peer)?;
    let raw_record = RawRecord::decode(request.payload.as_slice())?;

    if consensus::ensure_log_exists_from_sync_state(&request.space_id, sync_state).is_none() {
        return Err(anyhow::anyhow!(
            "space ACL root not initialized: {}",
            request.space_id
        ));
    }
    let record_add_request = RecordAddRequest {
        log_id: request.space_id.clone(),
        record: Some(raw_record),
    };
    let raw_with_id_bytes =
        consensus::handle_record_add(&record_add_request.encode_to_vec(), signing_key)?;
    let raw_with_id = RawRecordWithId::decode(raw_with_id_bytes.as_slice())?;
    let record_id = raw_with_id.id.clone();
    let payload = raw_with_id.payload.clone();

    consensus::persist_space_linked_record_add(
        &request.space_id,
        raw_with_id_bytes.as_slice(),
        &record_id,
        sync_state,
    )?;

    Ok(AclAddRecordResponse { record_id, payload }.encode_to_vec())
}

/// Handle /coordinator.Coordinator/AclGetRecords
pub fn handle_acl_get_records(
    request_bytes: &[u8],
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let request = AclGetRecordsRequest::decode(request_bytes)?;
    sync_state.authorize_space(&request.space_id, authenticated_peer)?;
    let response = AclGetRecordsResponse {
        records: sync_state.list_acl_records(&request.space_id, &request.acl_head),
    };
    Ok(response.encode_to_vec())
}

/// Handle /coordinator.Coordinator/AclUploadInvite
///
/// Stores a unixfs DAG-PB invite block in the file-node blob store and marks it
/// as publicly readable by CID (invite flow requires unauthenticated fetch by
/// joiners).
pub fn handle_acl_upload_invite(
    request_bytes: &[u8],
    file_node: &file_node::FileNodeState,
) -> Result<Vec<u8>> {
    let request = AclUploadInviteRequest::decode(request_bytes)?;
    file_node::store_public_invite_block(file_node, &request.cid, &request.data)?;
    Ok(AclUploadInviteResponse {}.encode_to_vec())
}

/// Handle /coordinator.Coordinator/SpaceDelete
///
/// Stub: returns success with a future timestamp. No actual space teardown in v2.4.
pub fn handle_space_delete(
    request_bytes: &[u8],
    sync_state: &SharedSyncState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<Vec<u8>> {
    let request = SpaceDeleteRequest::decode(request_bytes)?;
    sync_state.authorize_space(&request.space_id, authenticated_peer)?;
    let response = SpaceDeleteResponse {
        to_be_deleted_timestamp: unix_now_secs() as i64,
    };
    tracing::info!("coordinator: SpaceDelete stub (no-op)");
    Ok(response.encode_to_vec())
}

/// Handle /coordinator.Coordinator/AccountDelete
///
/// The signed confirmation must be fresh and bound to the authenticated
/// account, peer, and configured network. No actual account teardown (same as
/// `SpaceDelete`), but a repeat call for the same account identity is
/// rejected with "account is deleted": the one observable, replayable
/// signal the official any-sync coordinator exposes for this RPC (there is
/// no per-account status/reread RPC, and `DeletionLog` is space-scoped).
/// Confirmed against the official self-hosted oracle in
/// `test_vectors/phase50/oracle_account_delete.json`.
pub fn handle_account_delete(
    request_bytes: &[u8],
    config: &CoordinatorConfig,
    authenticated_peer: &AuthenticatedPeer<'_>,
    sync_state: &SharedSyncState,
) -> Result<Vec<u8>> {
    let request = AccountDeleteRequest::decode(request_bytes)?;
    let now = i64::try_from(unix_now_secs())
        .map_err(|_| anyhow::anyhow!("current timestamp exceeds protocol range"))?;
    validate_account_delete_confirmation(&request, config, authenticated_peer, now)?;

    if sync_state.is_account_deleted(authenticated_peer.account_identity()) {
        anyhow::bail!("account is deleted");
    }
    sync_state.mark_account_deleted(authenticated_peer.account_identity())?;

    let response = AccountDeleteResponse {
        to_be_deleted_timestamp: now,
    };
    tracing::info!("coordinator: AccountDelete accepted (no teardown, idempotency tracked)");
    Ok(response.encode_to_vec())
}

fn validate_account_delete_confirmation(
    request: &AccountDeleteRequest,
    config: &CoordinatorConfig,
    authenticated_peer: &AuthenticatedPeer<'_>,
    now: i64,
) -> Result<()> {
    anyhow::ensure!(
        request.deletion_payload_id == compute_cid(&request.deletion_payload),
        "account deletion payload id is incorrect"
    );
    let signed = DeletionConfirmPayloadWithSignature::decode(request.deletion_payload.as_slice())?;
    let signature_bytes: [u8; 64] = signed
        .signature
        .as_slice()
        .try_into()
        .map_err(|_| anyhow::anyhow!("account deletion signature must be 64 bytes"))?;
    let verifying_key =
        ed25519_dalek::VerifyingKey::from_bytes(authenticated_peer.account_identity())?;
    verifying_key
        .verify_strict(
            &signed.deletion_payload,
            &ed25519_dalek::Signature::from_bytes(&signature_bytes),
        )
        .map_err(|_| anyhow::anyhow!("account deletion signature verification failed"))?;

    let payload = AccountDeletionConfirmPayload::decode(signed.deletion_payload.as_slice())?;
    let identity = Key::decode(payload.account_identity.as_slice())?;
    anyhow::ensure!(
        identity.r#type == KeyType::Ed25519Public as i32,
        "account deletion identity must be an Ed25519 public key"
    );
    let payload_identity: [u8; 32] = identity
        .data
        .as_slice()
        .try_into()
        .map_err(|_| anyhow::anyhow!("account deletion identity must be 32 bytes"))?;
    anyhow::ensure!(
        &payload_identity == authenticated_peer.account_identity(),
        "account deletion identity does not match authenticated account"
    );
    anyhow::ensure!(
        payload.peer_id == authenticated_peer.id(),
        "account deletion peer id does not match authenticated peer"
    );
    anyhow::ensure!(
        payload.network_id == config.network_id,
        "account deletion network id is incorrect"
    );
    anyhow::ensure!(
        payload.timestamp >= now.saturating_sub(ACCOUNT_DELETE_MAX_AGE_SECS),
        "account deletion timestamp is stale"
    );
    anyhow::ensure!(
        payload.timestamp <= now.saturating_add(ACCOUNT_DELETE_MAX_FUTURE_SKEW_SECS),
        "account deletion timestamp is too far in the future"
    );
    Ok(())
}

/// Handle /coordinator.Coordinator/DeletionLog
///
/// Stub: returns an empty deletion log (no records). Sufficient for official
/// client flows to complete without errors.
pub fn handle_deletion_log(request_bytes: &[u8]) -> Result<Vec<u8>> {
    let _request = DeletionLogRequest::decode(request_bytes)?;
    let response = DeletionLogResponse {
        records: vec![],
        has_more: false,
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

/// Validates that a space claim is account-signed and content-addressed.
pub fn validate_space_header(
    space_id: &str,
    raw_header_bytes: &[u8],
    authenticated_account_identity: &[u8; 32],
) -> Result<Vec<u8>> {
    let raw_header = RawSpaceHeader::decode(raw_header_bytes)?;
    let header = SpaceHeader::decode(raw_header.space_header.as_slice())?;
    let identity = Key::decode(header.identity.as_slice())?;
    anyhow::ensure!(
        identity.r#type == KeyType::Ed25519Public as i32,
        "space header identity must be an Ed25519 public key"
    );
    let public_key: [u8; 32] = identity
        .data
        .as_slice()
        .try_into()
        .map_err(|_| anyhow::anyhow!("space header identity must be 32 bytes"))?;
    anyhow::ensure!(
        &public_key == authenticated_account_identity,
        "space header identity does not match authenticated account"
    );
    let verifying_key = ed25519_dalek::VerifyingKey::from_bytes(&public_key)?;
    let signature_bytes: [u8; 64] = raw_header
        .signature
        .as_slice()
        .try_into()
        .map_err(|_| anyhow::anyhow!("space header signature must be 64 bytes"))?;
    verifying_key.verify(
        &raw_header.space_header,
        &ed25519_dalek::Signature::from_bytes(&signature_bytes),
    )?;

    let expected_space_id = format!(
        "{}.{}",
        compute_cid(raw_header_bytes),
        format_base36(header.replication_key)
    );
    anyhow::ensure!(
        space_id == expected_space_id,
        "space header id is incorrect"
    );
    Ok(header.identity)
}

fn format_base36(mut value: u64) -> String {
    const DIGITS: &[u8; 36] = b"0123456789abcdefghijklmnopqrstuvwxyz";
    if value == 0 {
        return "0".to_string();
    }

    let mut encoded = Vec::new();
    while value > 0 {
        encoded.push(DIGITS[(value % 36) as usize]);
        value /= 36;
    }
    encoded.reverse();
    String::from_utf8(encoded).expect("base36 alphabet is valid UTF-8")
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
    use crate::auth::AuthenticatedPeer;
    use crate::consensus::reset_logs_for_tests;
    use crate::sync_node::new_shared_sync_state;
    use crate::sync_node::new_shared_sync_state_at;
    use manytype_core::crdt::cid::compute_cid;
    use manytype_core::crypto::ed25519;
    use manytype_proto::consensus::{RawRecord, Record};
    use manytype_proto::spacesync::SpacePushRequest;
    use tempfile::TempDir;

    const OWNER_PEER_ID: &str = "remote-peer";
    const OTHER_PEER_ID: &str = "other-peer";

    fn owner_peer() -> AuthenticatedPeer<'static> {
        let account_identity = ed25519::signing_key_from_seed(&[3; 32])
            .verifying_key()
            .to_bytes();
        AuthenticatedPeer::for_test_with_account(OWNER_PEER_ID, account_identity)
    }

    fn other_peer() -> AuthenticatedPeer<'static> {
        let account_identity = ed25519::signing_key_from_seed(&[4; 32])
            .verifying_key()
            .to_bytes();
        AuthenticatedPeer::for_test_with_account(OTHER_PEER_ID, account_identity)
    }

    fn other_peer_for_owner_account() -> AuthenticatedPeer<'static> {
        let account_identity = ed25519::signing_key_from_seed(&[3; 32])
            .verifying_key()
            .to_bytes();
        AuthenticatedPeer::for_test_with_account(OTHER_PEER_ID, account_identity)
    }

    fn test_signing_key() -> ed25519_dalek::SigningKey {
        ed25519::signing_key_from_seed(&[7u8; 32])
    }

    fn test_server_libp2p_peer_id() -> String {
        let signing_key = test_signing_key();
        let verifying_key = ed25519::verifying_key(&signing_key);
        ed25519::ed25519_pubkey_to_libp2p_peer_id(&verifying_key.to_bytes())
    }

    fn test_space_header(seed: u8) -> (String, Vec<u8>, Vec<u8>) {
        let account_key = ed25519::signing_key_from_seed(&[seed; 32]);
        let account_identity = Key {
            r#type: KeyType::Ed25519Public as i32,
            data: account_key.verifying_key().to_bytes().to_vec(),
        }
        .encode_to_vec();
        let header = SpaceHeader {
            identity: account_identity.clone(),
            space_type: "anytype.space".to_string(),
            replication_key: 42,
            ..Default::default()
        };
        let header_bytes = header.encode_to_vec();
        let raw_header = RawSpaceHeader {
            signature: account_key.sign(&header_bytes).to_bytes().to_vec(),
            space_header: header_bytes,
        }
        .encode_to_vec();
        let space_id = format!("{}.{}", compute_cid(&raw_header), format_base36(42));
        (space_id, raw_header, account_identity)
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

        assert!(response.nodes.len() >= 4);

        for node in &response.nodes {
            assert!(
                node.peer_id.starts_with("12D3KooW"),
                "peer_id was: {}",
                node.peer_id
            );
            assert_eq!(node.addresses.len(), 2);
            assert_eq!(node.addresses[0], "127.0.0.1:4830");
        }

        let has_type = |want: NodeType| {
            response
                .nodes
                .iter()
                .any(|node| node.types.contains(&(want as i32)))
        };

        assert!(has_type(NodeType::TreeApi), "should have TreeApi");
        assert!(
            has_type(NodeType::CoordinatorApi),
            "should have CoordinatorApi"
        );
        assert!(has_type(NodeType::FileApi), "should have FileApi");
        assert!(has_type(NodeType::ConsensusApi), "should have ConsensusApi");
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
        let (space_id, header, account_identity) = test_space_header(3);
        let request = SpaceSignRequest {
            space_id: space_id.clone(),
            header,
            ..Default::default()
        };

        let sync_state = new_shared_sync_state();
        let response_bytes = handle_space_sign(
            &request.encode_to_vec(),
            &config,
            &signing_key,
            &owner_peer(),
            &sync_state,
        )
        .unwrap();
        let response = SpaceSignResponse::decode(response_bytes.as_slice()).unwrap();
        let receipt = response.receipt.unwrap();
        validate_space_receipt(
            &receipt,
            &space_id,
            OWNER_PEER_ID,
            &account_identity,
            &config,
            &ed25519::verifying_key(&signing_key),
        )
        .unwrap();
    }

    #[test]
    fn space_sign_registers_space_so_status_check_reports_created() {
        let config = CoordinatorConfig {
            network_id: "manytype-dev".to_string(),
            peer_id: "test-peer".to_string(),
            addresses: vec!["127.0.0.1:4830".to_string()],
        };
        let signing_key = test_signing_key();
        let (space_id, header, _) = test_space_header(3);
        let request = SpaceSignRequest {
            space_id: space_id.clone(),
            header,
            ..Default::default()
        };
        let sync_state = new_shared_sync_state();

        // Before SpaceSign, a brand-new space is unknown to the coordinator.
        let before = SpaceStatusCheckResponse::decode(
            handle_space_status_check(
                &SpaceStatusCheckRequest {
                    space_id: space_id.clone(),
                }
                .encode_to_vec(),
                &sync_state,
                &owner_peer(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        assert_eq!(
            before.payload.unwrap().status,
            SpaceStatus::NotExists as i32
        );

        handle_space_sign(
            &request.encode_to_vec(),
            &config,
            &signing_key,
            &owner_peer(),
            &sync_state,
        )
        .unwrap();

        // The client's sync preflight (discoverSyncTargetsForSync) issues
        // SpaceStatusCheck immediately after SpaceSign, before any
        // SpacePush/HeadSync has happened; this must already report Created.
        let after = SpaceStatusCheckResponse::decode(
            handle_space_status_check(
                &SpaceStatusCheckRequest { space_id }.encode_to_vec(),
                &sync_state,
                &owner_peer(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        let payload = after.payload.unwrap();
        assert_eq!(payload.status, SpaceStatus::Created as i32);
        assert_eq!(payload.permissions, SpacePermissions::Owner as i32);
    }

    #[test]
    fn space_sign_binds_the_first_claim_to_account_and_peer() {
        let config = CoordinatorConfig {
            network_id: "manytype-dev".to_string(),
            peer_id: "test-peer".to_string(),
            addresses: vec!["127.0.0.1:4830".to_string()],
        };
        let signing_key = test_signing_key();
        let (space_id, header, _) = test_space_header(3);
        let request = SpaceSignRequest {
            space_id: space_id.clone(),
            header,
            ..Default::default()
        };
        let sync_state = new_shared_sync_state();

        let wrong_account = handle_space_sign(
            &request.encode_to_vec(),
            &config,
            &signing_key,
            &other_peer(),
            &sync_state,
        )
        .unwrap_err();
        assert!(
            wrong_account
                .to_string()
                .contains("does not match authenticated account")
        );
        assert!(!sync_state.read().unwrap().contains_key(&space_id));

        handle_space_sign(
            &request.encode_to_vec(),
            &config,
            &signing_key,
            &owner_peer(),
            &sync_state,
        )
        .unwrap();

        let second_peer = handle_space_sign(
            &request.encode_to_vec(),
            &config,
            &signing_key,
            &other_peer_for_owner_account(),
            &sync_state,
        )
        .unwrap_err();
        assert!(second_peer.to_string().contains("space access denied"));
        assert!(sync_state.peer_owns_space(&space_id, &owner_peer()));
        assert!(!sync_state.peer_owns_space(&space_id, &other_peer()));
    }

    #[test]
    fn unauthorized_peer_cannot_discover_or_administer_space() {
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
                Some(&owner_peer()),
            )
            .unwrap();

        let status = SpaceStatusCheckResponse::decode(
            handle_space_status_check(
                &SpaceStatusCheckRequest {
                    space_id: "space-1".to_string(),
                }
                .encode_to_vec(),
                &sync_state,
                &other_peer(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        assert_eq!(
            status.payload.unwrap().status,
            SpaceStatus::NotExists as i32
        );

        assert!(
            handle_space_make_shareable(
                &SpaceMakeShareableRequest {
                    space_id: "space-1".to_string(),
                }
                .encode_to_vec(),
                &sync_state,
                &other_peer(),
            )
            .is_err()
        );
        assert!(
            handle_acl_get_records(
                &AclGetRecordsRequest {
                    space_id: "space-1".to_string(),
                    acl_head: String::new(),
                }
                .encode_to_vec(),
                &sync_state,
                &other_peer(),
            )
            .is_err()
        );
        assert!(
            handle_acl_add_record(
                &acl_add_request("space-1", "root-cid", b"unauthorized").encode_to_vec(),
                &sync_state,
                &test_signing_key(),
                &other_peer(),
            )
            .is_err()
        );
        assert!(
            handle_space_delete(
                &SpaceDeleteRequest {
                    space_id: "space-1".to_string(),
                    ..Default::default()
                }
                .encode_to_vec(),
                &sync_state,
                &other_peer(),
            )
            .is_err()
        );

        let space = &sync_state.read().unwrap()["space-1"];
        assert!(!space.is_shared);
        assert!(space.acl_records.is_empty());
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
                Some(&owner_peer()),
            )
            .unwrap();

        let response_bytes = handle_space_status_check(
            &SpaceStatusCheckRequest {
                space_id: "space-1".to_string(),
            }
            .encode_to_vec(),
            &sync_state,
            &owner_peer(),
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
                Some(&owner_peer()),
            )
            .unwrap();

        handle_space_make_shareable(
            &SpaceMakeShareableRequest {
                space_id: "space-1".to_string(),
            }
            .encode_to_vec(),
            &sync_state,
            &owner_peer(),
        )
        .unwrap();

        let response = SpaceStatusCheckResponse::decode(
            handle_space_status_check(
                &SpaceStatusCheckRequest {
                    space_id: "space-1".to_string(),
                }
                .encode_to_vec(),
                &sync_state,
                &owner_peer(),
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
                    Some(&owner_peer()),
                )
                .unwrap();

            handle_space_make_shareable(
                &SpaceMakeShareableRequest {
                    space_id: "space-1".to_string(),
                }
                .encode_to_vec(),
                &sync_state,
                &owner_peer(),
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
                &owner_peer(),
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
                Some(&owner_peer()),
            )
            .unwrap();

        let response_bytes = handle_acl_add_record(
            &acl_add_request("space-1", "root-cid", b"first").encode_to_vec(),
            &sync_state,
            &test_signing_key(),
            &owner_peer(),
        )
        .unwrap();
        let response = AclAddRecordResponse::decode(response_bytes.as_slice()).unwrap();

        assert_eq!(response.record_id, compute_cid(&response.payload));
        let stored = sync_state.list_acl_records("space-1", "");
        assert_eq!(stored.len(), 2);
        assert_eq!(
            RawRecordWithId::decode(stored[1].as_slice()).unwrap().id,
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
                Some(&owner_peer()),
            )
            .unwrap();

        let first = AclAddRecordResponse::decode(
            handle_acl_add_record(
                &acl_add_request("space-1", "root-cid", b"first").encode_to_vec(),
                &sync_state,
                &test_signing_key(),
                &owner_peer(),
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
                &owner_peer(),
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
                &owner_peer(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        assert_eq!(all.records.len(), 3);

        let tail = AclGetRecordsResponse::decode(
            handle_acl_get_records(
                &AclGetRecordsRequest {
                    space_id: "space-1".to_string(),
                    acl_head: first.record_id.clone(),
                }
                .encode_to_vec(),
                &sync_state,
                &owner_peer(),
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
                    Some(&owner_peer()),
                )
                .unwrap();

            let first = AclAddRecordResponse::decode(
                handle_acl_add_record(
                    &acl_add_request("space-1", "root-cid", b"first").encode_to_vec(),
                    &sync_state,
                    &signing_key,
                    &owner_peer(),
                )
                .unwrap()
                .as_slice(),
            )
            .unwrap();
            handle_acl_add_record(
                &acl_add_request("space-1", &first.record_id, b"second").encode_to_vec(),
                &sync_state,
                &signing_key,
                &owner_peer(),
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
                &owner_peer(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();
        let latest_id = RawRecordWithId::decode(get_response.records.last().unwrap().as_slice())
            .unwrap()
            .id;

        let third = AclAddRecordResponse::decode(
            handle_acl_add_record(
                &acl_add_request("space-1", &latest_id, b"third").encode_to_vec(),
                &reopened,
                &signing_key,
                &owner_peer(),
            )
            .unwrap()
            .as_slice(),
        )
        .unwrap();

        assert_eq!(third.record_id, compute_cid(&third.payload));
        assert_eq!(reopened.list_acl_records("space-1", "").len(), 4);
    }

    #[test]
    fn space_delete_stub_returns_timestamp() {
        let sync_state = new_shared_sync_state();
        sync_state
            .claim_space_owner("space-1", &owner_peer())
            .unwrap();
        let request = SpaceDeleteRequest {
            space_id: "space-1".to_string(),
            ..Default::default()
        };
        let response_bytes =
            handle_space_delete(&request.encode_to_vec(), &sync_state, &owner_peer()).unwrap();
        let response = SpaceDeleteResponse::decode(response_bytes.as_slice()).unwrap();
        assert!(response.to_be_deleted_timestamp > 0);
    }

    fn account_delete_config(network_id: &str) -> CoordinatorConfig {
        CoordinatorConfig {
            network_id: network_id.to_string(),
            peer_id: "coordinator-peer".to_string(),
            addresses: vec![],
        }
    }

    fn account_peer(seed: u8, peer_id: &'static str) -> AuthenticatedPeer<'static> {
        AuthenticatedPeer::for_test_with_account(
            peer_id,
            ed25519::signing_key_from_seed(&[seed; 32])
                .verifying_key()
                .to_bytes(),
        )
    }

    fn account_delete_request(
        signer: &ed25519_dalek::SigningKey,
        embedded_identity: [u8; 32],
        peer_id: &str,
        network_id: &str,
        timestamp: i64,
    ) -> AccountDeleteRequest {
        let payload = AccountDeletionConfirmPayload {
            peer_id: peer_id.to_string(),
            account_identity: Key {
                r#type: KeyType::Ed25519Public as i32,
                data: embedded_identity.to_vec(),
            }
            .encode_to_vec(),
            network_id: network_id.to_string(),
            timestamp,
        };
        let deletion_payload = payload.encode_to_vec();
        let signed = DeletionConfirmPayloadWithSignature {
            signature: signer.sign(&deletion_payload).to_bytes().to_vec(),
            deletion_payload,
        };
        let deletion_payload = signed.encode_to_vec();
        AccountDeleteRequest {
            deletion_payload_id: compute_cid(&deletion_payload),
            deletion_payload,
        }
    }

    fn valid_account_delete_request(seed: u8, peer_id: &str) -> AccountDeleteRequest {
        let signer = ed25519::signing_key_from_seed(&[seed; 32]);
        account_delete_request(
            &signer,
            signer.verifying_key().to_bytes(),
            peer_id,
            "network-1",
            unix_now_secs() as i64,
        )
    }

    fn assert_account_delete_error(
        request: AccountDeleteRequest,
        config: &CoordinatorConfig,
        peer: &AuthenticatedPeer<'_>,
        expected: &str,
    ) {
        let sync_state = new_shared_sync_state();
        let error =
            handle_account_delete(&request.encode_to_vec(), config, peer, &sync_state).unwrap_err();
        assert!(
            error.to_string().contains(expected),
            "expected {expected:?}, got {error:#}"
        );
        assert!(!sync_state.is_account_deleted(peer.account_identity()));
    }

    #[test]
    fn account_delete_first_call_returns_timestamp() {
        let sync_state = new_shared_sync_state();
        let config = account_delete_config("network-1");
        let peer = account_peer(3, "peer-1");
        let request = valid_account_delete_request(3, "peer-1");
        let response_bytes =
            handle_account_delete(&request.encode_to_vec(), &config, &peer, &sync_state).unwrap();
        let response = AccountDeleteResponse::decode(response_bytes.as_slice()).unwrap();
        assert!(response.to_be_deleted_timestamp > 0);
        assert!(sync_state.is_account_deleted(peer.account_identity()));
    }

    #[test]
    fn account_delete_second_call_rejected() {
        let sync_state = new_shared_sync_state();
        let config = account_delete_config("network-1");
        let peer = account_peer(3, "peer-1");
        let request = valid_account_delete_request(3, "peer-1");
        handle_account_delete(&request.encode_to_vec(), &config, &peer, &sync_state).unwrap();

        let error = handle_account_delete(&request.encode_to_vec(), &config, &peer, &sync_state)
            .unwrap_err();
        assert!(error.to_string().contains("account is deleted"));
    }

    #[test]
    fn account_delete_tracks_identity_independently() {
        let sync_state = new_shared_sync_state();
        let config = account_delete_config("network-1");
        let first_peer = account_peer(3, "peer-1");
        handle_account_delete(
            &valid_account_delete_request(3, "peer-1").encode_to_vec(),
            &config,
            &first_peer,
            &sync_state,
        )
        .unwrap();

        let other_peer = account_peer(4, "peer-2");
        let other = valid_account_delete_request(4, "peer-2");
        let response_bytes =
            handle_account_delete(&other.encode_to_vec(), &config, &other_peer, &sync_state)
                .unwrap();
        let response = AccountDeleteResponse::decode(response_bytes.as_slice()).unwrap();
        assert!(response.to_be_deleted_timestamp > 0);
    }

    #[test]
    fn authenticated_account_delete_survives_restart() {
        let temp_dir = TempDir::new().unwrap();
        let config = account_delete_config("network-1");
        let peer = account_peer(3, "peer-1");
        let request = valid_account_delete_request(3, "peer-1");
        {
            let sync_state = new_shared_sync_state_at(temp_dir.path()).unwrap();
            handle_account_delete(&request.encode_to_vec(), &config, &peer, &sync_state).unwrap();
        }

        let reopened = new_shared_sync_state_at(temp_dir.path()).unwrap();
        let error =
            handle_account_delete(&request.encode_to_vec(), &config, &peer, &reopened).unwrap_err();
        assert!(error.to_string().contains("account is deleted"));
    }

    #[test]
    fn account_delete_rejects_forged_signature() {
        let config = account_delete_config("network-1");
        let peer = account_peer(3, "peer-1");
        let mut request = valid_account_delete_request(3, "peer-1");
        let mut signed =
            DeletionConfirmPayloadWithSignature::decode(request.deletion_payload.as_slice())
                .unwrap();
        signed.signature[0] ^= 1;
        request.deletion_payload = signed.encode_to_vec();
        request.deletion_payload_id = compute_cid(&request.deletion_payload);

        assert_account_delete_error(request, &config, &peer, "signature verification failed");
    }

    #[test]
    fn account_delete_rejects_account_mismatch() {
        let config = account_delete_config("network-1");
        let peer = account_peer(3, "peer-1");
        let signer = ed25519::signing_key_from_seed(&[3; 32]);
        let other_identity = ed25519::signing_key_from_seed(&[4; 32])
            .verifying_key()
            .to_bytes();
        let request = account_delete_request(
            &signer,
            other_identity,
            "peer-1",
            "network-1",
            unix_now_secs() as i64,
        );

        assert_account_delete_error(
            request,
            &config,
            &peer,
            "does not match authenticated account",
        );
    }

    #[test]
    fn account_delete_rejects_peer_mismatch() {
        let config = account_delete_config("network-1");
        let peer = account_peer(3, "peer-1");
        let request = valid_account_delete_request(3, "peer-2");

        assert_account_delete_error(request, &config, &peer, "does not match authenticated peer");
    }

    #[test]
    fn account_delete_rejects_network_mismatch() {
        let config = account_delete_config("network-1");
        let peer = account_peer(3, "peer-1");
        let signer = ed25519::signing_key_from_seed(&[3; 32]);
        let request = account_delete_request(
            &signer,
            signer.verifying_key().to_bytes(),
            "peer-1",
            "other-network",
            unix_now_secs() as i64,
        );

        assert_account_delete_error(request, &config, &peer, "network id is incorrect");
    }

    #[test]
    fn account_delete_rejects_stale_and_future_timestamps() {
        let config = account_delete_config("network-1");
        let peer = account_peer(3, "peer-1");
        let signer = ed25519::signing_key_from_seed(&[3; 32]);
        let now = unix_now_secs() as i64;
        let stale = account_delete_request(
            &signer,
            signer.verifying_key().to_bytes(),
            "peer-1",
            "network-1",
            now - ACCOUNT_DELETE_MAX_AGE_SECS - 10,
        );
        assert_account_delete_error(stale, &config, &peer, "timestamp is stale");

        let future = account_delete_request(
            &signer,
            signer.verifying_key().to_bytes(),
            "peer-1",
            "network-1",
            now + ACCOUNT_DELETE_MAX_FUTURE_SKEW_SECS + 10,
        );
        assert_account_delete_error(future, &config, &peer, "too far in the future");
    }

    #[test]
    fn account_delete_rejects_payload_id_mismatch() {
        let config = account_delete_config("network-1");
        let peer = account_peer(3, "peer-1");
        let mut request = valid_account_delete_request(3, "peer-1");
        request.deletion_payload_id = compute_cid(b"different payload");

        assert_account_delete_error(request, &config, &peer, "payload id is incorrect");
    }

    #[test]
    fn deletion_log_stub_returns_empty() {
        let request = DeletionLogRequest {
            ..Default::default()
        };
        let response_bytes = handle_deletion_log(&request.encode_to_vec()).unwrap();
        let response = DeletionLogResponse::decode(response_bytes.as_slice()).unwrap();
        assert!(response.records.is_empty());
        assert!(!response.has_more);
    }
}
