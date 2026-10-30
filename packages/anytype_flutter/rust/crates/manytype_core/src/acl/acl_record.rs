//! ACL record verification: CID + Ed25519 signature validation.
//!
//! Verifies ACL records created by Dart (or Rust) by checking:
//! 1. CID matches (compute_cid(payload) == id)
//! 2. Ed25519 signature is valid
//! 3. Decodes inner Record and AclRoot/AclData

use anyhow::{Result, bail};
use ed25519_dalek::{Signature, VerifyingKey};
use prost::Message;

use manytype_proto::aclrecord::{AclData, AclRoot};
use manytype_proto::consensus::{RawRecord, RawRecordWithId, Record};

use crate::crdt::cid::{compute_cid, verify_cid};
use crate::crypto::ed25519;

/// A verified ACL record with decoded fields.
#[derive(Debug)]
pub struct VerifiedAclRecord {
    /// CID of this record.
    pub id: String,
    /// CID of the previous record (empty for root).
    pub prev_id: String,
    /// Signer's Ed25519 public key (32 bytes).
    pub identity: Vec<u8>,
    /// Decoded AclRoot (Some for root records).
    pub acl_root: Option<AclRoot>,
    /// Decoded AclData (Some for non-root records).
    pub acl_data: Option<AclData>,
    /// Timestamp from the inner Record.
    pub timestamp: i64,
}

impl VerifiedAclRecord {
    /// True if this is the root record in the ACL chain.
    pub fn is_root(&self) -> bool {
        self.prev_id.is_empty()
    }
}

/// Verify and decode an ACL record from its RawRecordWithId representation.
///
/// Checks:
/// 1. CID: compute_cid(payload) == id
/// 2. Ed25519 signature on the Record payload
/// 3. Decodes Record.data as AclRoot (if root) or AclData (if non-root)
pub fn verify_acl_record(raw_with_id: &RawRecordWithId) -> Result<VerifiedAclRecord> {
    // 1. Verify CID matches
    if !verify_cid(&raw_with_id.payload, &raw_with_id.id) {
        let computed = compute_cid(&raw_with_id.payload);
        bail!(
            "CID mismatch: computed={}, expected={}",
            computed,
            raw_with_id.id
        );
    }

    // 2. Decode RawRecord from payload bytes
    let raw_record = RawRecord::decode(raw_with_id.payload.as_slice())?;

    // 3. Decode inner Record from RawRecord.payload
    let record = Record::decode(raw_record.payload.as_slice())?;

    // 4. Verify Ed25519 signature
    let identity_bytes: [u8; 32] =
        record.identity.as_slice().try_into().map_err(|_| {
            anyhow::anyhow!("Identity must be 32 bytes, got {}", record.identity.len())
        })?;

    let verifying_key = VerifyingKey::from_bytes(&identity_bytes)
        .map_err(|e| anyhow::anyhow!("Invalid Ed25519 public key: {}", e))?;

    let sig_bytes: [u8; 64] = raw_record.signature.as_slice().try_into().map_err(|_| {
        anyhow::anyhow!(
            "Signature must be 64 bytes, got {}",
            raw_record.signature.len()
        )
    })?;

    let signature = Signature::from_bytes(&sig_bytes);

    if !ed25519::verify(&verifying_key, &raw_record.payload, &signature) {
        bail!("Invalid Ed25519 signature on ACL record {}", raw_with_id.id);
    }

    // 5. Decode data as AclRoot (if prevId empty) or AclData (otherwise)
    let is_root = record.prev_id.is_empty();
    let acl_root = if is_root {
        Some(AclRoot::decode(record.data.as_slice())?)
    } else {
        None
    };
    let acl_data = if !is_root {
        Some(AclData::decode(record.data.as_slice())?)
    } else {
        None
    };

    Ok(VerifiedAclRecord {
        id: raw_with_id.id.clone(),
        prev_id: record.prev_id,
        identity: record.identity,
        acl_root,
        acl_data,
        timestamp: record.timestamp,
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::crypto::ed25519::{sign, signing_key_from_seed, verifying_key};
    use manytype_proto::aclrecord::{AclAccountInvite, AclContentValue, AclUserPermissions};
    use prost::Message;

    /// Helper: build a valid AclRoot RawRecordWithId in Rust (mirrors Dart buildAclRoot).
    fn build_test_acl_root(seed: &[u8; 32], space_id: &str) -> RawRecordWithId {
        let sk = signing_key_from_seed(seed);
        let vk = verifying_key(&sk);
        let pub_key = vk.to_bytes().to_vec();

        let acl_root = AclRoot {
            identity: pub_key.clone(),
            master_key: pub_key.clone(),
            space_id: space_id.to_string(),
            encrypted_read_key: vec![1, 2, 3], // Simplified for unit test
            timestamp: 1000,
            identity_signature: sign(&sk, &pub_key).to_bytes().to_vec(),
            ..Default::default()
        };

        let record = Record {
            prev_id: String::new(),
            identity: pub_key,
            data: acl_root.encode_to_vec(),
            timestamp: 1000,
        };

        let record_bytes = record.encode_to_vec();
        let signature = sign(&sk, &record_bytes);

        let raw_record = RawRecord {
            payload: record_bytes,
            signature: signature.to_bytes().to_vec(),
            ..Default::default()
        };

        let raw_bytes = raw_record.encode_to_vec();
        let cid = compute_cid(&raw_bytes);

        RawRecordWithId {
            payload: raw_bytes,
            id: cid,
        }
    }

    #[test]
    fn verify_valid_acl_root() {
        let seed = [1u8; 32];
        let raw_with_id = build_test_acl_root(&seed, "test-space");
        let verified = verify_acl_record(&raw_with_id).unwrap();
        assert!(verified.is_root());
        assert!(verified.acl_root.is_some());
        assert!(verified.acl_data.is_none());
        assert_eq!(verified.id, raw_with_id.id);
    }

    #[test]
    fn reject_wrong_cid() {
        let seed = [1u8; 32];
        let mut raw_with_id = build_test_acl_root(&seed, "test-space");
        raw_with_id.id = "bafywrongcidvalue".to_string();
        let result = verify_acl_record(&raw_with_id);
        assert!(result.is_err());
        assert!(result.unwrap_err().to_string().contains("CID mismatch"));
    }

    #[test]
    fn reject_wrong_signature() {
        let seed = [1u8; 32];
        let raw_with_id = build_test_acl_root(&seed, "test-space");

        // Decode, tamper signature, re-encode with same CID
        let mut raw_record = RawRecord::decode(raw_with_id.payload.as_slice()).unwrap();
        // Flip a byte in the signature
        raw_record.signature[0] ^= 0xff;
        let tampered_bytes = raw_record.encode_to_vec();
        let tampered_cid = compute_cid(&tampered_bytes);

        let tampered = RawRecordWithId {
            payload: tampered_bytes,
            id: tampered_cid,
        };

        let result = verify_acl_record(&tampered);
        assert!(result.is_err());
        assert!(result.unwrap_err().to_string().contains("signature"));
    }

    #[test]
    fn acl_root_owner_identity_preserved() {
        let seed = [1u8; 32];
        let sk = signing_key_from_seed(&seed);
        let vk = verifying_key(&sk);
        let expected_pub = vk.to_bytes().to_vec();

        let raw_with_id = build_test_acl_root(&seed, "test-space");
        let verified = verify_acl_record(&raw_with_id).unwrap();

        assert_eq!(verified.identity, expected_pub);
        let root = verified.acl_root.as_ref().unwrap();
        assert_eq!(root.identity, expected_pub);
        assert_eq!(root.master_key, expected_pub);
    }

    #[test]
    fn verify_non_root_record_with_acl_data() {
        let seed = [1u8; 32];
        let root = build_test_acl_root(&seed, "test-space");

        // Build a non-root record with AclData
        let sk = signing_key_from_seed(&seed);
        let vk = verifying_key(&sk);
        let pub_key = vk.to_bytes().to_vec();

        let acl_data = AclData {
            acl_content: vec![AclContentValue {
                value: Some(manytype_proto::aclrecord::acl_content_value::Value::Invite(
                    AclAccountInvite {
                        invite_key: vec![42u8; 32],
                        permissions: AclUserPermissions::Writer as i32,
                        ..Default::default()
                    },
                )),
            }],
        };

        let record = Record {
            prev_id: root.id.clone(),
            identity: pub_key,
            data: acl_data.encode_to_vec(),
            timestamp: 2000,
        };

        let record_bytes = record.encode_to_vec();
        let signature = sign(&sk, &record_bytes);

        let raw_record = RawRecord {
            payload: record_bytes,
            signature: signature.to_bytes().to_vec(),
            ..Default::default()
        };

        let raw_bytes = raw_record.encode_to_vec();
        let cid = compute_cid(&raw_bytes);

        let raw_with_id = RawRecordWithId {
            payload: raw_bytes,
            id: cid,
        };

        let verified = verify_acl_record(&raw_with_id).unwrap();
        assert!(!verified.is_root());
        assert!(verified.acl_data.is_some());
        assert_eq!(verified.prev_id, root.id);
    }

    #[test]
    fn cross_language_cid_starts_with_bafy() {
        let seed = [1u8; 32];
        let raw_with_id = build_test_acl_root(&seed, "test-space");
        assert!(
            raw_with_id.id.starts_with("bafy"),
            "CID should start with bafy, got: {}",
            raw_with_id.id
        );
    }
}
