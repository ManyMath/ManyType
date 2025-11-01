use ed25519_dalek::{Signature, Signer, SigningKey, Verifier, VerifyingKey};

const LIBP2P_ED25519_PEER_ID_PREFIX: [u8; 6] = [0x00, 0x24, 0x08, 0x01, 0x12, 0x20];

/// Encode an Ed25519 public key as a libp2p peer ID string.
pub fn ed25519_pubkey_to_libp2p_peer_id(pubkey: &[u8; 32]) -> String {
    let mut payload = Vec::with_capacity(38);
    payload.extend_from_slice(&LIBP2P_ED25519_PEER_ID_PREFIX);
    payload.extend_from_slice(pubkey);
    bs58::encode(payload).into_string()
}

/// Create an Ed25519 signing key from a 32-byte seed.
pub fn signing_key_from_seed(seed: &[u8; 32]) -> SigningKey {
    SigningKey::from_bytes(seed)
}

/// Get the public (verifying) key from a signing key.
pub fn verifying_key(signing_key: &SigningKey) -> VerifyingKey {
    signing_key.verifying_key()
}

/// Sign a message with Ed25519.
pub fn sign(signing_key: &SigningKey, message: &[u8]) -> Signature {
    signing_key.sign(message)
}

/// Verify an Ed25519 signature.
pub fn verify(verifying_key: &VerifyingKey, message: &[u8], signature: &Signature) -> bool {
    verifying_key.verify(message, signature).is_ok()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_sign_verify_round_trip() {
        let seed = [1u8; 32];
        let sk = signing_key_from_seed(&seed);
        let vk = verifying_key(&sk);
        let message = b"test message";
        let sig = sign(&sk, message);
        assert!(verify(&vk, message, &sig));
    }

    #[test]
    fn test_tampered_message_fails_verification() {
        let seed = [1u8; 32];
        let sk = signing_key_from_seed(&seed);
        let vk = verifying_key(&sk);
        let message = b"test message";
        let sig = sign(&sk, message);
        assert!(!verify(&vk, b"tampered message", &sig));
    }

    #[test]
    fn test_wrong_key_fails_verification() {
        let seed1 = [1u8; 32];
        let seed2 = [2u8; 32];
        let sk1 = signing_key_from_seed(&seed1);
        let sk2 = signing_key_from_seed(&seed2);
        let vk2 = verifying_key(&sk2);
        let message = b"test message";
        let sig = sign(&sk1, message);
        assert!(!verify(&vk2, message, &sig));
    }

    #[test]
    fn test_deterministic_signing() {
        let seed = [1u8; 32];
        let sk = signing_key_from_seed(&seed);
        let message = b"deterministic test";
        let sig1 = sign(&sk, message);
        let sig2 = sign(&sk, message);
        assert_eq!(sig1, sig2);
    }

    #[test]
    fn test_signature_is_64_bytes() {
        let seed = [1u8; 32];
        let sk = signing_key_from_seed(&seed);
        let sig = sign(&sk, b"test");
        assert_eq!(sig.to_bytes().len(), 64);
    }

    #[test]
    fn test_slip0010_derived_key_signs_correctly() {
        // Integration test: derive identity key with SLIP-0010, then sign with Ed25519
        use crate::crypto::bip39::mnemonic_to_seed;
        use crate::crypto::slip0010::derive_identity_key;

        let seed = mnemonic_to_seed(
            "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
        );
        let derived = derive_identity_key(&seed, 0);
        let sk = signing_key_from_seed(&derived.private_key);
        let vk = verifying_key(&sk);
        let message = b"anytype test message";
        let sig = sign(&sk, message);
        assert!(verify(&vk, message, &sig));
    }

    #[test]
    fn test_libp2p_peer_id_starts_with_12d3koow() {
        let seed = [1u8; 32];
        let sk = signing_key_from_seed(&seed);
        let vk = verifying_key(&sk);
        let peer_id = ed25519_pubkey_to_libp2p_peer_id(&vk.to_bytes());
        assert!(peer_id.starts_with("12D3KooW"), "got: {}", peer_id);
    }

    #[test]
    fn test_libp2p_peer_id_is_deterministic() {
        let seed = [1u8; 32];
        let sk = signing_key_from_seed(&seed);
        let vk = verifying_key(&sk);
        let pubkey = vk.to_bytes();
        let id1 = ed25519_pubkey_to_libp2p_peer_id(&pubkey);
        let id2 = ed25519_pubkey_to_libp2p_peer_id(&pubkey);
        assert_eq!(id1, id2);
    }
}
