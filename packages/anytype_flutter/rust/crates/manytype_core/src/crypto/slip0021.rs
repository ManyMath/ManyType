use hmac::{Hmac, Mac};
use sha2::Sha512;

type HmacSha512 = Hmac<Sha512>;

/// SLIP-0021: Derive symmetric key from seed at given path.
///
/// Path format: "m/SLIP-0021/segment1/segment2/..."
/// Master: HMAC-SHA512(key="Symmetric key seed", data=seed)
/// Child: HMAC-SHA512(key=parent_derivation_key[0..32], data=0x00 || segment_bytes)
/// Return: node[32..64] (the symmetric key half)
///
/// Matches Anytype's Go implementation in derived.go / go-slip21.
pub fn slip21_derive(seed: &[u8], path: &str) -> [u8; 32] {
    // Master node: HMAC-SHA512(key="Symmetric key seed", data=seed)
    let mut mac =
        HmacSha512::new_from_slice(b"Symmetric key seed").expect("HMAC accepts any key length");
    mac.update(seed);
    let mut node = mac.finalize().into_bytes();

    // Split path after "m/" into labels
    let path_after_m = path.strip_prefix("m/").expect("path must start with m/");
    let segments: Vec<&str> = path_after_m.split('/').collect();

    // Derive each segment: HMAC-SHA512(key=node[0..32], data=0x00 || label)
    for segment in segments {
        let mut mac = HmacSha512::new_from_slice(&node[..32]).expect("HMAC accepts any key length");
        mac.update(&[0x00]);
        mac.update(segment.as_bytes());
        node = mac.finalize().into_bytes();
    }

    let mut key = [0u8; 32];
    key.copy_from_slice(&node[32..64]);
    key
}

/// Derive Anytype space read key.
/// Path: "m/SLIP-0021/anysync/space"
pub fn derive_space_key(seed: &[u8]) -> [u8; 32] {
    slip21_derive(seed, "m/SLIP-0021/anysync/space")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_slip21_spec_vector() {
        // SLIP-0021 test vector computed from the algorithm:
        // Seed: 000102030405060708090a0b0c0d0e0f
        // Master: HMAC-SHA512(key="Symmetric key seed", data=seed)
        //   derivation key [0..32]: e1b2593b65469b0f5b5a245aa1bd2cf0f496ce9892f16620ad87d3cb571d8be7
        //   symmetric key [32..64]: f53c27e79f63cc43d419a9b01c95c4a86c1fb56d33ed47719962253f9e8d7d86
        let seed = hex::decode("000102030405060708090a0b0c0d0e0f").unwrap();

        // Verify master node
        let mut mac =
            HmacSha512::new_from_slice(b"Symmetric key seed").expect("HMAC accepts any key length");
        mac.update(&seed);
        let master = mac.finalize().into_bytes();

        // Master derivation key [0..32]
        assert_eq!(
            hex::encode(&master[..32]),
            "e1b2593b65469b0f5b5a245aa1bd2cf0f496ce9892f16620ad87d3cb571d8be7"
        );
        // Master symmetric key [32..64]
        assert_eq!(
            hex::encode(&master[32..64]),
            "f53c27e79f63cc43d419a9b01c95c4a86c1fb56d33ed47719962253f9e8d7d86"
        );
    }

    #[test]
    fn test_slip21_derive_deterministic() {
        let seed = hex::decode("000102030405060708090a0b0c0d0e0f").unwrap();
        let key1 = slip21_derive(&seed, "m/SLIP-0021/anysync/space");
        let key2 = slip21_derive(&seed, "m/SLIP-0021/anysync/space");
        assert_eq!(key1, key2);
    }

    #[test]
    fn test_derive_space_key_returns_32_bytes() {
        let seed = [0u8; 64];
        let key = derive_space_key(&seed);
        assert_eq!(key.len(), 32);
    }

    #[test]
    fn test_different_paths_produce_different_keys() {
        let seed = hex::decode("000102030405060708090a0b0c0d0e0f").unwrap();
        let key1 = slip21_derive(&seed, "m/SLIP-0021/anysync/space");
        let key2 = slip21_derive(&seed, "m/SLIP-0021/anysync/tree/test");
        assert_ne!(key1, key2);
    }

    #[test]
    fn test_slip21_spec_child_vector() {
        // Verified via Python HMAC-SHA512 computation:
        // m/SLIP-0021/Master encryption key -> symmetric key [32..64]:
        //   6e7738df0e1fa4ab22a5f54173cb20b0669b46c6d37dca2f53250fcfdafec57c
        let seed = hex::decode("000102030405060708090a0b0c0d0e0f").unwrap();
        let key = slip21_derive(&seed, "m/SLIP-0021/Master encryption key");
        assert_eq!(
            hex::encode(key),
            "6e7738df0e1fa4ab22a5f54173cb20b0669b46c6d37dca2f53250fcfdafec57c"
        );
    }

    #[test]
    fn test_slip21_spec_auth_key_vector() {
        // Verified via Python HMAC-SHA512 computation:
        // m/SLIP-0021/Authentication key -> symmetric key [32..64]:
        //   68854ed30f522476cc30fd4d77ec25ac416c0c506986b230b250d058187d3b72
        let seed = hex::decode("000102030405060708090a0b0c0d0e0f").unwrap();
        let key = slip21_derive(&seed, "m/SLIP-0021/Authentication key");
        assert_eq!(
            hex::encode(key),
            "68854ed30f522476cc30fd4d77ec25ac416c0c506986b230b250d058187d3b72"
        );
    }
}
