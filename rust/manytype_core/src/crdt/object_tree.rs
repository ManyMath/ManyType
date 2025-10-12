//! ObjectTree: DAG storage with head tracking, CID and Ed25519 verification.
//!
//! Per D-08: Rust verifies + stores + tracks heads. Does NOT interpret changesData.
//! Per D-09: Uses TreeStorage trait for future persistence swap.

use std::collections::HashSet;

use anyhow::{bail, Result};
use ed25519_dalek::Verifier;
use prost::Message;

use crate::crdt::cid::compute_cid;
use crate::crdt::storage::TreeStorage;
use manytype_proto::treechange::{RawTreeChange, RawTreeChangeWithId, RootChange, TreeChange};

/// A verified change with extracted metadata.
#[derive(Debug)]
pub struct VerifiedChange {
    pub id: String,
    pub parent_ids: Vec<String>,
    pub is_snapshot: bool,
    pub identity: Vec<u8>,
}

/// Verify CID and Ed25519 signature on a RawTreeChangeWithId containing a RootChange payload.
pub fn verify_root_change(raw_with_id: &RawTreeChangeWithId) -> Result<VerifiedChange> {
    // 1. Verify CID
    let computed_cid = compute_cid(&raw_with_id.raw_change);
    if computed_cid != raw_with_id.id {
        bail!(
            "CID mismatch: computed {} != provided {}",
            computed_cid,
            raw_with_id.id
        );
    }

    // 2. Decode RawTreeChange
    let raw = RawTreeChange::decode(raw_with_id.raw_change.as_slice())?;

    // 3. Decode RootChange from payload
    let root = RootChange::decode(raw.payload.as_slice())?;

    // 4. Verify Ed25519 signature
    verify_signature(&root.identity, &raw.payload, &raw.signature)?;

    Ok(VerifiedChange {
        id: raw_with_id.id.clone(),
        parent_ids: vec![], // Root has no parents
        is_snapshot: false,
        identity: root.identity,
    })
}

/// Verify CID and Ed25519 signature on a RawTreeChangeWithId containing a TreeChange payload.
/// Does NOT interpret changesData (per D-08).
pub fn verify_tree_change(raw_with_id: &RawTreeChangeWithId) -> Result<VerifiedChange> {
    // 1. Verify CID
    let computed_cid = compute_cid(&raw_with_id.raw_change);
    if computed_cid != raw_with_id.id {
        bail!(
            "CID mismatch: computed {} != provided {}",
            computed_cid,
            raw_with_id.id
        );
    }

    // 2. Decode RawTreeChange
    let raw = RawTreeChange::decode(raw_with_id.raw_change.as_slice())?;

    // 3. Decode TreeChange from payload
    let tc = TreeChange::decode(raw.payload.as_slice())?;

    // 4. Verify Ed25519 signature
    verify_signature(&tc.identity, &raw.payload, &raw.signature)?;

    Ok(VerifiedChange {
        id: raw_with_id.id.clone(),
        parent_ids: tc.tree_head_ids,
        is_snapshot: tc.is_snapshot,
        identity: tc.identity,
    })
}

fn verify_signature(identity: &[u8], payload: &[u8], signature: &[u8]) -> Result<()> {
    let pubkey_bytes: [u8; 32] = identity
        .try_into()
        .map_err(|_| anyhow::anyhow!("identity not 32 bytes"))?;
    let verifying_key = ed25519_dalek::VerifyingKey::from_bytes(&pubkey_bytes)?;
    let sig_bytes: [u8; 64] = signature
        .try_into()
        .map_err(|_| anyhow::anyhow!("signature not 64 bytes"))?;
    let sig = ed25519_dalek::Signature::from_bytes(&sig_bytes);
    verifying_key
        .verify(payload, &sig)
        .map_err(|e| anyhow::anyhow!("signature verification failed: {}", e))?;
    Ok(())
}

/// ObjectTree manages a DAG of verified tree changes with head tracking.
pub struct ObjectTree<S: TreeStorage> {
    storage: S,
    heads: HashSet<String>,
}

impl<S: TreeStorage> ObjectTree<S> {
    pub fn new(storage: S) -> Self {
        Self {
            storage,
            heads: HashSet::new(),
        }
    }

    /// Returns sorted head list for deterministic comparison.
    pub fn heads(&self) -> Vec<String> {
        let mut h: Vec<String> = self.heads.iter().cloned().collect();
        h.sort();
        h
    }

    /// Add a verified root change.
    pub fn add_root(&mut self, raw_with_id: &RawTreeChangeWithId) -> Result<()> {
        let verified = verify_root_change(raw_with_id)?;
        self.storage
            .add_raw_change(verified.id.clone(), raw_with_id.raw_change.clone())?;
        self.heads.insert(verified.id);
        self.storage.set_heads(self.heads());
        Ok(())
    }

    /// Add a verified tree change (non-root).
    pub fn add_change(&mut self, raw_with_id: &RawTreeChangeWithId) -> Result<()> {
        let verified = verify_tree_change(raw_with_id)?;

        // Validate all parents exist
        for parent_id in &verified.parent_ids {
            if !self.storage.has_change(parent_id) {
                bail!("parent {} not found in tree", parent_id);
            }
        }

        // Store raw change
        self.storage
            .add_raw_change(verified.id.clone(), raw_with_id.raw_change.clone())?;

        // Update heads: remove consumed parents, add new change
        for parent_id in &verified.parent_ids {
            self.heads.remove(parent_id);
        }
        self.heads.insert(verified.id);

        self.storage.set_heads(self.heads());
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::crdt::cid::compute_cid;
    use crate::crdt::storage::InMemoryTreeStorage;
    use crate::crypto::ed25519;
    use manytype_proto::treechange::{RawTreeChange, RawTreeChangeWithId, RootChange, TreeChange};
    use prost::Message;

    fn test_signing_key() -> ed25519_dalek::SigningKey {
        ed25519::signing_key_from_seed(&[1u8; 32])
    }

    fn make_root_change(
        sk: &ed25519_dalek::SigningKey,
        space_id: &str,
        seed: &[u8],
    ) -> RawTreeChangeWithId {
        let vk = ed25519::verifying_key(sk);
        let root = RootChange {
            acl_head_id: "acl-head-1".to_string(),
            space_id: space_id.to_string(),
            change_type: "test".to_string(),
            timestamp: 1000,
            seed: seed.to_vec(),
            identity: vk.to_bytes().to_vec(),
            change_payload: vec![],
            is_derived: false,
        };
        let payload = root.encode_to_vec();
        let sig = ed25519::sign(sk, &payload);
        let raw = RawTreeChange {
            payload,
            signature: sig.to_bytes().to_vec(),
        };
        let raw_bytes = raw.encode_to_vec();
        let cid = compute_cid(&raw_bytes);
        RawTreeChangeWithId {
            raw_change: raw_bytes,
            id: cid,
        }
    }

    fn make_tree_change(
        sk: &ed25519_dalek::SigningKey,
        parent_ids: Vec<String>,
        snapshot_base_id: &str,
        changes_data: &[u8],
    ) -> RawTreeChangeWithId {
        let vk = ed25519::verifying_key(sk);
        let tc = TreeChange {
            tree_head_ids: parent_ids,
            acl_head_id: "acl-head-1".to_string(),
            snapshot_base_id: snapshot_base_id.to_string(),
            changes_data: changes_data.to_vec(),
            read_key_id: String::new(),
            timestamp: 2000,
            identity: vk.to_bytes().to_vec(),
            is_snapshot: false,
            data_type: String::new(),
        };
        let payload = tc.encode_to_vec();
        let sig = ed25519::sign(sk, &payload);
        let raw = RawTreeChange {
            payload,
            signature: sig.to_bytes().to_vec(),
        };
        let raw_bytes = raw.encode_to_vec();
        let cid = compute_cid(&raw_bytes);
        RawTreeChangeWithId {
            raw_change: raw_bytes,
            id: cid,
        }
    }

    #[test]
    fn verify_root_change_succeeds_with_valid_data() {
        let sk = test_signing_key();
        let root = make_root_change(&sk, "space-1", b"seed123");
        let verified = verify_root_change(&root).unwrap();
        assert_eq!(verified.id, root.id);
        assert!(verified.parent_ids.is_empty());
    }

    #[test]
    fn verify_tree_change_succeeds_with_valid_data() {
        let sk = test_signing_key();
        let root = make_root_change(&sk, "space-1", b"seed123");
        let tc = make_tree_change(&sk, vec![root.id.clone()], &root.id, b"data");
        let verified = verify_tree_change(&tc).unwrap();
        assert_eq!(verified.parent_ids, vec![root.id]);
    }

    #[test]
    fn verify_rejects_wrong_cid() {
        let sk = test_signing_key();
        let mut root = make_root_change(&sk, "space-1", b"seed123");
        root.id = "bafywrongcid".to_string();
        let err = verify_root_change(&root);
        assert!(err.is_err());
        assert!(err.unwrap_err().to_string().contains("CID mismatch"));
    }

    #[test]
    fn verify_rejects_invalid_signature() {
        let sk = test_signing_key();
        let vk = ed25519::verifying_key(&sk);
        let root = RootChange {
            acl_head_id: "acl-head-1".to_string(),
            space_id: "space-1".to_string(),
            change_type: "test".to_string(),
            timestamp: 1000,
            seed: b"seed123".to_vec(),
            identity: vk.to_bytes().to_vec(),
            change_payload: vec![],
            is_derived: false,
        };
        let payload = root.encode_to_vec();
        // Use wrong signature (all zeros)
        let raw = RawTreeChange {
            payload,
            signature: vec![0u8; 64],
        };
        let raw_bytes = raw.encode_to_vec();
        let cid = compute_cid(&raw_bytes);
        let raw_with_id = RawTreeChangeWithId {
            raw_change: raw_bytes,
            id: cid,
        };
        let err = verify_root_change(&raw_with_id);
        assert!(err.is_err());
        assert!(err
            .unwrap_err()
            .to_string()
            .contains("signature verification failed"));
    }

    #[test]
    fn object_tree_root_has_single_head() {
        let sk = test_signing_key();
        let root = make_root_change(&sk, "space-1", b"seed1");
        let mut tree = ObjectTree::new(InMemoryTreeStorage::new());
        tree.add_root(&root).unwrap();
        assert_eq!(tree.heads(), vec![root.id]);
    }

    #[test]
    fn add_change_referencing_root_updates_head() {
        let sk = test_signing_key();
        let root = make_root_change(&sk, "space-1", b"seed1");
        let mut tree = ObjectTree::new(InMemoryTreeStorage::new());
        tree.add_root(&root).unwrap();

        let c1 = make_tree_change(&sk, vec![root.id.clone()], &root.id, b"change1");
        tree.add_change(&c1).unwrap();
        assert_eq!(tree.heads(), vec![c1.id]);
    }

    #[test]
    fn two_changes_referencing_root_creates_fork() {
        let sk = test_signing_key();
        let root = make_root_change(&sk, "space-1", b"seed1");
        let mut tree = ObjectTree::new(InMemoryTreeStorage::new());
        tree.add_root(&root).unwrap();

        let c1 = make_tree_change(&sk, vec![root.id.clone()], &root.id, b"change1");
        let c2 = make_tree_change(&sk, vec![root.id.clone()], &root.id, b"change2");
        tree.add_change(&c1).unwrap();
        tree.add_change(&c2).unwrap();

        let heads = tree.heads();
        assert_eq!(heads.len(), 2);
        assert!(heads.contains(&c1.id));
        assert!(heads.contains(&c2.id));
    }

    #[test]
    fn merge_change_referencing_both_forks_produces_single_head() {
        let sk = test_signing_key();
        let root = make_root_change(&sk, "space-1", b"seed1");
        let mut tree = ObjectTree::new(InMemoryTreeStorage::new());
        tree.add_root(&root).unwrap();

        let c1 = make_tree_change(&sk, vec![root.id.clone()], &root.id, b"change1");
        let c2 = make_tree_change(&sk, vec![root.id.clone()], &root.id, b"change2");
        tree.add_change(&c1).unwrap();
        tree.add_change(&c2).unwrap();

        let merge =
            make_tree_change(&sk, vec![c1.id.clone(), c2.id.clone()], &root.id, b"merge");
        tree.add_change(&merge).unwrap();

        assert_eq!(tree.heads(), vec![merge.id]);
    }

    #[test]
    fn cross_language_fixture_verification() {
        // Generate fixture data and verify it round-trips correctly
        // This test creates the same structure a Dart client would,
        // then verifies CIDs, signatures, and head tracking.
        let sk = test_signing_key();
        let root = make_root_change(&sk, "test-space", b"fixture-seed");
        let mut tree = ObjectTree::new(InMemoryTreeStorage::new());
        tree.add_root(&root).unwrap();
        assert_eq!(tree.heads(), vec![root.id.clone()]);

        // Fork: two changes referencing root
        let c1 = make_tree_change(&sk, vec![root.id.clone()], &root.id, b"fork-left");
        tree.add_change(&c1).unwrap();
        let after_c1_heads = tree.heads();

        let c2 = make_tree_change(&sk, vec![root.id.clone()], &root.id, b"fork-right");
        tree.add_change(&c2).unwrap();
        let after_c2_heads = tree.heads();
        assert_eq!(after_c2_heads.len(), 2);

        // Merge: change referencing both forks
        let merge =
            make_tree_change(&sk, vec![c1.id.clone(), c2.id.clone()], &root.id, b"merge");
        tree.add_change(&merge).unwrap();
        let final_heads = tree.heads();
        assert_eq!(final_heads, vec![merge.id.clone()]);

        // Write fixture file for cross-language verification
        let vk = ed25519::verifying_key(&sk);
        let fixture = serde_json::json!({
            "rootChange": {
                "id": root.id,
                "rawChange": hex::encode(&root.raw_change)
            },
            "changes": [
                {
                    "id": c1.id,
                    "rawChange": hex::encode(&c1.raw_change),
                    "expectedHeads": after_c1_heads
                },
                {
                    "id": c2.id,
                    "rawChange": hex::encode(&c2.raw_change),
                    "expectedHeads": after_c2_heads
                },
                {
                    "id": merge.id,
                    "rawChange": hex::encode(&merge.raw_change),
                    "expectedHeads": final_heads
                }
            ],
            "finalHeads": final_heads,
            "identityPublicKey": hex::encode(vk.to_bytes())
        });

        // Write to test_vectors directory
        let manifest_dir = env!("CARGO_MANIFEST_DIR");
        let workspace_root = std::path::Path::new(manifest_dir)
            .parent()
            .unwrap()
            .parent()
            .unwrap();
        let fixture_dir = workspace_root.join("test_vectors");
        std::fs::create_dir_all(&fixture_dir).unwrap();
        let fixture_path = fixture_dir.join("object_tree_fixture.json");
        std::fs::write(&fixture_path, serde_json::to_string_pretty(&fixture).unwrap()).unwrap();

        // Now re-read fixture and replay to verify cross-language compatibility
        let fixture_str = std::fs::read_to_string(&fixture_path).unwrap();
        let loaded: serde_json::Value = serde_json::from_str(&fixture_str).unwrap();

        // Replay from fixture
        let mut replay_tree = ObjectTree::new(InMemoryTreeStorage::new());

        let root_hex = loaded["rootChange"]["rawChange"].as_str().unwrap();
        let root_raw = hex::decode(root_hex).unwrap();
        let root_id = loaded["rootChange"]["id"].as_str().unwrap().to_string();
        let root_rwi = RawTreeChangeWithId {
            raw_change: root_raw,
            id: root_id,
        };
        replay_tree.add_root(&root_rwi).unwrap();

        for change in loaded["changes"].as_array().unwrap() {
            let change_hex = change["rawChange"].as_str().unwrap();
            let change_raw = hex::decode(change_hex).unwrap();
            let change_id = change["id"].as_str().unwrap().to_string();
            let rwi = RawTreeChangeWithId {
                raw_change: change_raw,
                id: change_id,
            };
            replay_tree.add_change(&rwi).unwrap();

            let expected_heads: Vec<String> = change["expectedHeads"]
                .as_array()
                .unwrap()
                .iter()
                .map(|v| v.as_str().unwrap().to_string())
                .collect();
            let mut expected_sorted = expected_heads.clone();
            expected_sorted.sort();
            assert_eq!(
                replay_tree.heads(),
                expected_sorted,
                "heads mismatch after applying change"
            );
        }

        let expected_final: Vec<String> = loaded["finalHeads"]
            .as_array()
            .unwrap()
            .iter()
            .map(|v| v.as_str().unwrap().to_string())
            .collect();
        let mut expected_final_sorted = expected_final;
        expected_final_sorted.sort();
        assert_eq!(replay_tree.heads(), expected_final_sorted);
    }
}
