use bip39::{Language, Mnemonic};

/// Generate a new 12-word BIP-39 mnemonic.
pub fn generate_mnemonic() -> String {
    let mut entropy = [0u8; 16]; // 128 bits = 12 words
    rand::fill(&mut entropy);
    let mnemonic = Mnemonic::from_entropy_in(Language::English, &entropy)
        .expect("mnemonic generation should not fail");
    mnemonic.to_string()
}

/// Parse a mnemonic string and derive a 64-byte seed.
/// Passphrase is empty string (Anytype uses no passphrase).
pub fn mnemonic_to_seed(mnemonic: &str) -> [u8; 64] {
    let mnemonic =
        Mnemonic::parse_in(Language::English, mnemonic).expect("invalid mnemonic");
    mnemonic.to_seed("")
}

/// Validate a mnemonic string.
pub fn validate_mnemonic(mnemonic: &str) -> bool {
    Mnemonic::parse_in(Language::English, mnemonic).is_ok()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_generate_mnemonic_returns_12_words() {
        let mnemonic = generate_mnemonic();
        let words: Vec<&str> = mnemonic.split_whitespace().collect();
        assert_eq!(words.len(), 12);
    }

    #[test]
    fn test_generated_mnemonic_is_valid() {
        let mnemonic = generate_mnemonic();
        assert!(validate_mnemonic(&mnemonic));
    }

    #[test]
    fn test_known_vector_abandon_seed() {
        // Standard BIP-39 test vector: "abandon" x11 + "about"
        let mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";
        assert!(validate_mnemonic(mnemonic));
        let seed = mnemonic_to_seed(mnemonic);
        let seed_hex = hex::encode(&seed[..20]);
        // Known BIP-39 seed prefix for this mnemonic with empty passphrase
        assert_eq!(&seed_hex[..40], "5eb00bbddcf069084889a8ab9155568165f5c453");
    }

    #[test]
    fn test_mnemonic_to_seed_deterministic() {
        let mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";
        let seed1 = mnemonic_to_seed(mnemonic);
        let seed2 = mnemonic_to_seed(mnemonic);
        assert_eq!(seed1, seed2);
    }

    #[test]
    fn test_invalid_mnemonic() {
        assert!(!validate_mnemonic("not a valid mnemonic phrase"));
    }
}
