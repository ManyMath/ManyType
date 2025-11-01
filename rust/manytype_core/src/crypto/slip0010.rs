use hmac::{Hmac, Mac};
use sha2::Sha512;

type HmacSha512 = Hmac<Sha512>;

/// Result of SLIP-0010 key derivation.
pub struct DerivedKey {
    /// 32-byte Ed25519 private key seed.
    pub private_key: [u8; 32],
    /// 32-byte chain code for further derivation.
    pub chain_code: [u8; 32],
}

/// Derive the master node from a BIP-39 seed using SLIP-0010.
/// Returns (key, chain_code) from HMAC-SHA512(key="ed25519 seed", data=seed).
fn master_node(seed: &[u8]) -> ([u8; 32], [u8; 32]) {
    let mut mac = HmacSha512::new_from_slice(b"ed25519 seed").expect("HMAC accepts any key length");
    mac.update(seed);
    let result = mac.finalize().into_bytes();
    let mut key = [0u8; 32];
    let mut chain_code = [0u8; 32];
    key.copy_from_slice(&result[..32]);
    chain_code.copy_from_slice(&result[32..]);
    (key, chain_code)
}

/// Derive a hardened child key from parent key and chain code.
/// SLIP-0010 Ed25519: 0x00 || parent_key || child_index (big-endian).
fn derive_hardened_child(
    parent_key: &[u8; 32],
    parent_chain_code: &[u8; 32],
    index: u32,
) -> ([u8; 32], [u8; 32]) {
    let child_index = index | 0x80000000; // Set hardened bit
    let mut mac =
        HmacSha512::new_from_slice(parent_chain_code).expect("HMAC accepts any key length");
    mac.update(&[0x00]);
    mac.update(parent_key);
    mac.update(&child_index.to_be_bytes());
    let result = mac.finalize().into_bytes();
    let mut key = [0u8; 32];
    let mut chain_code = [0u8; 32];
    key.copy_from_slice(&result[..32]);
    chain_code.copy_from_slice(&result[32..]);
    (key, chain_code)
}

/// Derive Ed25519 identity keypair from BIP-39 seed.
///
/// Matches Anytype's Go derivation:
/// - Master: HMAC-SHA512(key="ed25519 seed", data=seed)
/// - Path: m/44'/2046'/index'/0'
///
/// The identity key is at the 4th level (with the extra /0' child).
pub fn derive_identity_key(seed: &[u8; 64], index: u32) -> DerivedKey {
    let (mut key, mut chain_code) = master_node(seed);

    // Path: m / 44' / 2046' / index' / 0'
    let path_indices = [44, 2046, index, 0];
    for &idx in &path_indices {
        let (k, cc) = derive_hardened_child(&key, &chain_code, idx);
        key = k;
        chain_code = cc;
    }

    DerivedKey {
        private_key: key,
        chain_code,
    }
}

/// Derive Ed25519 account master key from BIP-39 seed.
///
/// Path: m/44'/2046'/index' (3 levels, not 4).
/// This matches Go's `DeriveMasterNode` at `m/44'/2046'/index'`.
pub fn derive_account_key(seed: &[u8; 64], index: u32) -> DerivedKey {
    let (mut key, mut chain_code) = master_node(seed);

    // Path: m / 44' / 2046' / index'
    let path_indices = [44, 2046, index];
    for &idx in &path_indices {
        let (k, cc) = derive_hardened_child(&key, &chain_code, idx);
        key = k;
        chain_code = cc;
    }

    DerivedKey {
        private_key: key,
        chain_code,
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::crypto::bip39::mnemonic_to_seed;

    #[test]
    fn test_derive_identity_key_deterministic() {
        let seed = mnemonic_to_seed(
            "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
        );
        let key1 = derive_identity_key(&seed, 0);
        let key2 = derive_identity_key(&seed, 0);
        assert_eq!(key1.private_key, key2.private_key);
        assert_eq!(key1.chain_code, key2.chain_code);
    }

    #[test]
    fn test_derive_identity_key_32_bytes() {
        let seed = mnemonic_to_seed(
            "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
        );
        let key = derive_identity_key(&seed, 0);
        assert_eq!(key.private_key.len(), 32);
        assert_eq!(key.chain_code.len(), 32);
    }

    #[test]
    fn test_different_indices_produce_different_keys() {
        let seed = mnemonic_to_seed(
            "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
        );
        let key0 = derive_identity_key(&seed, 0);
        let key1 = derive_identity_key(&seed, 1);
        assert_ne!(key0.private_key, key1.private_key);
    }

    #[test]
    fn test_account_key_differs_from_identity_key() {
        let seed = mnemonic_to_seed(
            "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
        );
        let account = derive_account_key(&seed, 0);
        let identity = derive_identity_key(&seed, 0);
        // Account key is at m/44'/2046'/0', identity is at m/44'/2046'/0'/0'
        // They must be different
        assert_ne!(account.private_key, identity.private_key);
    }

    #[test]
    fn test_master_node_is_correct() {
        // SLIP-0010 test vector from spec (hex seed "000102030405060708090a0b0c0d0e0f")
        let seed = hex::decode("000102030405060708090a0b0c0d0e0f").unwrap();
        let (key, chain_code) = master_node(&seed);
        // SLIP-0010 Ed25519 master key for this seed (from SLIP-0010 spec):
        assert_eq!(
            hex::encode(key),
            "2b4be7f19ee27bbf30c667b642d5f4aa69fd169872f8fc3059c08ebae2eb19e7"
        );
        assert_eq!(
            hex::encode(chain_code),
            "90046a93de5380a72b5e45010748567d5ea02bbf6522f979e05c0d8d8ca9fffb"
        );
    }
}
