//! ACL state machine tracking permissions for all known identities.
//!
//! Mirrors the Dart AclState implementation. Processes ACL chain records
//! and maintains a permission map. Supports all AclContentValue variants per D-11.

use std::collections::HashMap;

use anyhow::{bail, Result};

use manytype_proto::aclrecord::{
    acl_content_value::Value, AclContentValue, AclUserPermissions,
};

use super::acl_record::VerifiedAclRecord;

/// ACL state machine that tracks permissions for all known identities.
pub struct AclState {
    /// Permission map: hex-encoded identity -> permission level.
    permissions: HashMap<Vec<u8>, i32>,
    /// All verified records in chain order.
    records: Vec<String>,
    /// CID of the latest record in the chain.
    head_id: String,
    /// Pending invites: record_id -> (invite_key, permissions).
    pending_invites: HashMap<String, (Vec<u8>, i32)>,
}

impl AclState {
    /// Create a new empty ACL state.
    pub fn new() -> Self {
        Self {
            permissions: HashMap::new(),
            records: Vec::new(),
            head_id: String::new(),
            pending_invites: HashMap::new(),
        }
    }

    /// CID of the latest record in the chain.
    pub fn head_id(&self) -> &str {
        &self.head_id
    }

    /// Apply the root record (first record in chain).
    ///
    /// Sets the owner identity with Owner permission.
    pub fn apply_root(&mut self, record: VerifiedAclRecord) -> Result<()> {
        if !record.is_root() {
            bail!("Expected root record (empty prev_id)");
        }
        if !self.records.is_empty() {
            bail!("Root already applied");
        }

        self.permissions
            .insert(record.identity.clone(), AclUserPermissions::Owner as i32);
        self.head_id = record.id.clone();
        self.records.push(record.id);
        Ok(())
    }

    /// Apply a subsequent record in the chain.
    ///
    /// Validates prevId matches current head, then processes AclContentValues.
    pub fn apply_record(&mut self, record: VerifiedAclRecord) -> Result<()> {
        if record.is_root() {
            bail!("Cannot apply root record with apply_record");
        }
        if record.prev_id != self.head_id {
            bail!(
                "Invalid prev_id: expected={}, got={}",
                self.head_id,
                record.prev_id
            );
        }

        if let Some(ref acl_data) = record.acl_data {
            let record_id = record.id.clone();
            for content in &acl_data.acl_content {
                self.process_content_value(content, &record_id);
            }
        }

        self.head_id = record.id.clone();
        self.records.push(record.id);
        Ok(())
    }

    /// Get the permission level for an identity (raw bytes).
    pub fn get_permission(&self, identity: &[u8]) -> Option<i32> {
        self.permissions.get(identity).copied()
    }

    /// Check if an identity has at least the minimum required permission level.
    ///
    /// Permission levels: Owner(1) > Admin(2) > Writer(3) > Reader(4) > Guest(5).
    /// Lower numeric value = higher permission.
    pub fn has_permission(&self, identity: &[u8], min_level: i32) -> bool {
        match self.permissions.get(identity) {
            Some(&perm) => perm > 0 && perm <= min_level,
            None => false,
        }
    }

    fn process_content_value(&mut self, content: &AclContentValue, record_id: &str) {
        if let Some(ref value) = content.value {
            match value {
                Value::Invite(invite) => {
                    self.pending_invites.insert(
                        record_id.to_string(),
                        (invite.invite_key.clone(), invite.permissions),
                    );
                }
                Value::InviteRevoke(revoke) => {
                    self.pending_invites.remove(&revoke.invite_record_id);
                }
                Value::RequestJoin(_) => {
                    // Store pending request (simplified: no separate tracking needed for state)
                }
                Value::RequestAccept(accept) => {
                    self.permissions
                        .insert(accept.identity.clone(), accept.permissions);
                }
                Value::PermissionChange(change) => {
                    if change.permissions == AclUserPermissions::None as i32 {
                        self.permissions.remove(&change.identity);
                    } else {
                        self.permissions
                            .insert(change.identity.clone(), change.permissions);
                    }
                }
                Value::AccountRemove(remove) => {
                    for identity in &remove.identities {
                        self.permissions.remove(identity);
                    }
                }
                Value::ReadKeyChange(_) => {
                    // Read key changes don't affect permissions
                }
                Value::RequestDecline(_) => {
                    // Remove pending request
                }
                Value::AccountRequestRemove(_) => {
                    // No permission change needed
                }
                Value::PermissionChanges(changes) => {
                    for change in &changes.changes {
                        if change.permissions == AclUserPermissions::None as i32 {
                            self.permissions.remove(&change.identity);
                        } else {
                            self.permissions
                                .insert(change.identity.clone(), change.permissions);
                        }
                    }
                }
                Value::AccountsAdd(adds) => {
                    for addition in &adds.additions {
                        self.permissions
                            .insert(addition.identity.clone(), addition.permissions);
                    }
                }
                Value::RequestCancel(_) => {
                    // Remove pending request
                }
                Value::InviteJoin(join) => {
                    self.permissions
                        .insert(join.identity.clone(), join.permissions);
                }
                Value::InviteChange(change) => {
                    if let Some(invite) = self.pending_invites.get_mut(&change.invite_record_id) {
                        invite.1 = change.permissions;
                    }
                }
            }
        }
    }
}

impl Default for AclState {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::acl::acl_record::verify_acl_record;
    use crate::crdt::cid::compute_cid;
    use crate::crypto::ed25519::{sign, signing_key_from_seed, verifying_key};
    use manytype_proto::aclrecord::{
        acl_content_value::Value, AclAccountInvite, AclAccountInviteJoin, AclContentValue, AclData,
        AclUserPermissions,
    };
    use manytype_proto::consensus::{RawRecord, RawRecordWithId, Record};
    use prost::Message;

    fn build_test_root(seed: &[u8; 32]) -> RawRecordWithId {
        let sk = signing_key_from_seed(seed);
        let vk = verifying_key(&sk);
        let pub_key = vk.to_bytes().to_vec();

        let acl_root = manytype_proto::aclrecord::AclRoot {
            identity: pub_key.clone(),
            master_key: pub_key.clone(),
            space_id: "test-space".to_string(),
            encrypted_read_key: vec![1, 2, 3],
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

    fn build_test_record(seed: &[u8; 32], prev_id: &str, acl_data: AclData) -> RawRecordWithId {
        let sk = signing_key_from_seed(seed);
        let vk = verifying_key(&sk);
        let pub_key = vk.to_bytes().to_vec();

        let record = Record {
            prev_id: prev_id.to_string(),
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

        RawRecordWithId {
            payload: raw_bytes,
            id: cid,
        }
    }

    #[test]
    fn state_after_root_has_owner() {
        let seed = [1u8; 32];
        let raw = build_test_root(&seed);
        let verified = verify_acl_record(&raw).unwrap();

        let owner_identity = verified.identity.clone();
        let mut state = AclState::new();
        state.apply_root(verified).unwrap();

        assert_eq!(
            state.get_permission(&owner_identity),
            Some(AclUserPermissions::Owner as i32)
        );
    }

    #[test]
    fn state_rejects_wrong_prev_id() {
        let seed = [1u8; 32];
        let raw_root = build_test_root(&seed);
        let verified_root = verify_acl_record(&raw_root).unwrap();

        let mut state = AclState::new();
        state.apply_root(verified_root).unwrap();

        // Build record with wrong prev_id
        let acl_data = AclData {
            acl_content: vec![AclContentValue {
                value: Some(Value::Invite(AclAccountInvite {
                    invite_key: vec![42u8; 32],
                    permissions: AclUserPermissions::Writer as i32,
                    ..Default::default()
                })),
            }],
        };

        let wrong_record = build_test_record(&seed, "bafywrongprevid", acl_data);
        let verified_wrong = verify_acl_record(&wrong_record).unwrap();

        let result = state.apply_record(verified_wrong);
        assert!(result.is_err());
        assert!(result.unwrap_err().to_string().contains("Invalid prev_id"));
    }

    #[test]
    fn state_invite_join_adds_member() {
        let seed = [1u8; 32];
        let raw_root = build_test_root(&seed);
        let root_id = raw_root.id.clone();
        let verified_root = verify_acl_record(&raw_root).unwrap();

        let mut state = AclState::new();
        state.apply_root(verified_root).unwrap();

        // Invite
        let invite_data = AclData {
            acl_content: vec![AclContentValue {
                value: Some(Value::Invite(AclAccountInvite {
                    invite_key: vec![42u8; 32],
                    permissions: AclUserPermissions::Writer as i32,
                    ..Default::default()
                })),
            }],
        };

        let invite_raw = build_test_record(&seed, &root_id, invite_data);
        let invite_id = invite_raw.id.clone();
        let verified_invite = verify_acl_record(&invite_raw).unwrap();
        state.apply_record(verified_invite).unwrap();

        // InviteJoin
        let joiner_seed = [2u8; 32];
        let joiner_sk = signing_key_from_seed(&joiner_seed);
        let joiner_vk = verifying_key(&joiner_sk);
        let joiner_pub = joiner_vk.to_bytes().to_vec();

        let join_data = AclData {
            acl_content: vec![AclContentValue {
                value: Some(Value::InviteJoin(AclAccountInviteJoin {
                    identity: joiner_pub.clone(),
                    invite_record_id: invite_id.clone(),
                    permissions: AclUserPermissions::Writer as i32,
                    ..Default::default()
                })),
            }],
        };

        let join_raw = build_test_record(&seed, &invite_id, join_data);
        let verified_join = verify_acl_record(&join_raw).unwrap();
        state.apply_record(verified_join).unwrap();

        assert_eq!(
            state.get_permission(&joiner_pub),
            Some(AclUserPermissions::Writer as i32)
        );
    }
}
