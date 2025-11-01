use aes_gcm::aead::{Aead, KeyInit};
use aes_gcm::{Aes256Gcm, Key, Nonce};
use rand::RngCore;

/// Encrypt plaintext with AES-256-GCM.
/// Returns: [12-byte nonce][ciphertext + 16-byte GCM tag]
/// Matches Go any-sync/util/crypto/aes.go format.
pub fn encrypt(key: &[u8; 32], plaintext: &[u8]) -> Vec<u8> {
    let cipher = Aes256Gcm::new(Key::<Aes256Gcm>::from_slice(key));
    let mut nonce_bytes = [0u8; 12];
    rand::rng().fill_bytes(&mut nonce_bytes);
    let nonce = Nonce::from_slice(&nonce_bytes);

    let ciphertext = cipher
        .encrypt(nonce, plaintext)
        .expect("AES-GCM encryption should not fail");

    let mut result = Vec::with_capacity(12 + ciphertext.len());
    result.extend_from_slice(&nonce_bytes);
    result.extend_from_slice(&ciphertext);
    result
}

/// Decrypt AES-256-GCM ciphertext.
/// Input format: [12-byte nonce][ciphertext + 16-byte GCM tag]
pub fn decrypt(key: &[u8; 32], data: &[u8]) -> Result<Vec<u8>, aes_gcm::Error> {
    if data.len() < 12 + 16 {
        return Err(aes_gcm::Error);
    }
    let cipher = Aes256Gcm::new(Key::<Aes256Gcm>::from_slice(key));
    let nonce = Nonce::from_slice(&data[..12]);
    cipher.decrypt(nonce, &data[12..])
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_encrypt_decrypt_round_trip() {
        let key = [42u8; 32];
        let plaintext = b"hello anytype";
        let encrypted = encrypt(&key, plaintext);
        let decrypted = decrypt(&key, &encrypted).expect("decryption should succeed");
        assert_eq!(decrypted, plaintext);
    }

    #[test]
    fn test_encrypted_output_length() {
        let key = [42u8; 32];
        let plaintext = b"hello anytype"; // 13 bytes
        let encrypted = encrypt(&key, plaintext);
        // Output: 12 (nonce) + 13 (plaintext) + 16 (GCM tag) = 41
        assert_eq!(encrypted.len(), 41);
    }

    #[test]
    fn test_wrong_key_fails_decrypt() {
        let key = [42u8; 32];
        let wrong_key = [99u8; 32];
        let plaintext = b"secret data";
        let encrypted = encrypt(&key, plaintext);
        assert!(decrypt(&wrong_key, &encrypted).is_err());
    }

    #[test]
    fn test_tampered_ciphertext_fails() {
        let key = [42u8; 32];
        let plaintext = b"test data";
        let mut encrypted = encrypt(&key, plaintext);
        // Tamper with the ciphertext
        if let Some(byte) = encrypted.last_mut() {
            *byte ^= 0xFF;
        }
        assert!(decrypt(&key, &encrypted).is_err());
    }

    #[test]
    fn test_nonce_is_prepended() {
        let key = [42u8; 32];
        let plaintext = b"test";
        let encrypted = encrypt(&key, plaintext);
        // First 12 bytes are the nonce (should not be all zeros in practice)
        assert_eq!(encrypted.len(), 12 + 4 + 16);
    }

    #[test]
    fn test_each_encryption_produces_different_output() {
        let key = [42u8; 32];
        let plaintext = b"same message";
        let enc1 = encrypt(&key, plaintext);
        let enc2 = encrypt(&key, plaintext);
        // Different random nonces should produce different ciphertext
        assert_ne!(enc1, enc2);
        // But both should decrypt to the same plaintext
        assert_eq!(decrypt(&key, &enc1).unwrap(), decrypt(&key, &enc2).unwrap());
    }

    #[test]
    fn test_too_short_input_fails() {
        let key = [42u8; 32];
        let short = [0u8; 20]; // Less than 12 + 16
        assert!(decrypt(&key, &short).is_err());
    }
}
