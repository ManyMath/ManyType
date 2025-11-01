//! CIDv1 computation matching Anytype's cidutil.NewCidFromBytes.
//!
//! Algorithm: CIDv1 + dag-cbor (0x71) + SHA2-256 + base32lower

use cid::Cid;
use multihash_codetable::{Code, MultihashDigest};

const DAG_CBOR: u64 = 0x71;

/// Compute a CIDv1 string from raw bytes.
///
/// Matches Anytype's `cidutil.NewCidFromBytes` exactly:
/// CIDv1 + dag-cbor (0x71) + SHA2-256 + base32lower with 'b' prefix.
pub fn compute_cid(data: &[u8]) -> String {
    let hash = Code::Sha2_256.digest(data);
    let c = Cid::new_v1(DAG_CBOR, hash);
    c.to_string_of_base(multibase::Base::Base32Lower)
        .expect("base32lower encoding should not fail")
}

/// Verify that the CID of `data` matches `expected_cid`.
pub fn verify_cid(data: &[u8], expected_cid: &str) -> bool {
    compute_cid(data) == expected_cid
}

#[cfg(test)]
mod tests {
    use super::*;

    /// Shared cross-language test vector.
    /// Input: b"hello anytype"
    /// Expected: computed via CIDv1 + dag-cbor + SHA-256 + base32lower
    const EXPECTED_CID: &str = "bafyreie7ijnjsupdthz7mvg2y76gd6coqvyic5k36tli2p2bnn6mq24ohi";

    #[test]
    fn cross_language_test_vector() {
        let cid_str = compute_cid(b"hello anytype");
        assert_eq!(cid_str, EXPECTED_CID);
    }

    #[test]
    fn starts_with_bafy() {
        let cid_str = compute_cid(b"hello anytype");
        assert!(
            cid_str.starts_with("bafy"),
            "CID should start with 'bafy', got: {}",
            cid_str
        );
    }

    #[test]
    fn verify_cid_correct() {
        assert!(verify_cid(b"hello anytype", EXPECTED_CID));
    }

    #[test]
    fn verify_cid_wrong() {
        assert!(!verify_cid(b"hello anytype", "bafywrongcidvalue"));
    }

    #[test]
    fn different_inputs_different_cids() {
        let cid1 = compute_cid(b"hello anytype");
        let cid2 = compute_cid(b"other data");
        assert_ne!(cid1, cid2);
    }

    #[test]
    fn empty_bytes_produces_valid_cid() {
        let cid_str = compute_cid(b"");
        assert!(cid_str.starts_with("b"));
        assert!(!cid_str.is_empty());
    }
}
