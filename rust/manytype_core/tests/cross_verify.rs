//! Cross-verification: Rust crypto must match Go reference vectors.
//!
//! Same vectors are tested in Dart:
//!   packages/manytype_core/test/crypto/cross_verify_test.dart
//!
//! If both Dart and Rust match these vectors, they are interoperable.

use manytype_core::crypto::{bip39, ed25519, slip0010, slip0021};

/// Standard BIP-39 test mnemonic: "abandon" x 11 + "about"
const TEST_MNEMONIC: &str =
    "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";

const TEST_SEED_HEX: &str = "5eb00bbddcf069084889a8ab9155568165f5c453ccb85e70811aaed6f6da5fc19a5ac40b389cd370d086206dec8aa6c43daea6690f20ad3d8d48b2d2ce9e38e4";

const TEST_IDENTITY_PRIVATE_KEY_HEX: &str =
    "9fb70eabab6626779573378193b8a200cf6167c7a050e02535747379a647ee72";

const TEST_IDENTITY_PUBLIC_KEY_HEX: &str =
    "546f0a2d6a8cfdea65ccdfebf086c4e5543527c8fe9b5b072eac8b4890e45586";

const TEST_ACCOUNT_PRIVATE_KEY_HEX: &str =
    "dc9eccf762dfda3c45af595519af889d3ef3a04dd2384e8cc77eae5e778fddeb";

const TEST_SPACE_KEY_HEX: &str = "cb5118d8e9f9b5019ba41f9f90306281378577c83596014cbc5ecbb1c84ae741";

// SLIP-0021 spec vectors (seed = 000102030405060708090a0b0c0d0e0f)
const TEST_SLIP21_MASTER_ENC_KEY_HEX: &str =
    "6e7738df0e1fa4ab22a5f54173cb20b0669b46c6d37dca2f53250fcfdafec57c";
const TEST_SLIP21_AUTH_KEY_HEX: &str =
    "68854ed30f522476cc30fd4d77ec25ac416c0c506986b230b250d058187d3b72";

#[test]
fn cross_bip39_seed_matches_reference() {
    let seed = bip39::mnemonic_to_seed(TEST_MNEMONIC);
    assert_eq!(hex::encode(seed), TEST_SEED_HEX);
}

#[test]
fn cross_slip0010_identity_key_matches_reference() {
    let seed = bip39::mnemonic_to_seed(TEST_MNEMONIC);
    let derived = slip0010::derive_identity_key(&seed, 0);
    assert_eq!(
        hex::encode(derived.private_key),
        TEST_IDENTITY_PRIVATE_KEY_HEX
    );
}

#[test]
fn cross_slip0010_account_key_matches_reference() {
    let seed = bip39::mnemonic_to_seed(TEST_MNEMONIC);
    let derived = slip0010::derive_account_key(&seed, 0);
    assert_eq!(
        hex::encode(derived.private_key),
        TEST_ACCOUNT_PRIVATE_KEY_HEX
    );
}

#[test]
fn cross_ed25519_public_key_matches_reference() {
    let seed = bip39::mnemonic_to_seed(TEST_MNEMONIC);
    let derived = slip0010::derive_identity_key(&seed, 0);
    let sk = ed25519::signing_key_from_seed(&derived.private_key);
    let vk = ed25519::verifying_key(&sk);
    assert_eq!(hex::encode(vk.as_bytes()), TEST_IDENTITY_PUBLIC_KEY_HEX);
}

#[test]
fn cross_slip0021_space_key_matches_reference() {
    let seed = bip39::mnemonic_to_seed(TEST_MNEMONIC);
    let space_key = slip0021::derive_space_key(&seed);
    assert_eq!(hex::encode(space_key), TEST_SPACE_KEY_HEX);
}

#[test]
fn cross_slip0021_spec_master_encryption_key() {
    let seed = hex::decode("000102030405060708090a0b0c0d0e0f").unwrap();
    let key = slip0021::slip21_derive(&seed, "m/SLIP-0021/Master encryption key");
    assert_eq!(hex::encode(key), TEST_SLIP21_MASTER_ENC_KEY_HEX);
}

#[test]
fn cross_slip0021_spec_authentication_key() {
    let seed = hex::decode("000102030405060708090a0b0c0d0e0f").unwrap();
    let key = slip0021::slip21_derive(&seed, "m/SLIP-0021/Authentication key");
    assert_eq!(hex::encode(key), TEST_SLIP21_AUTH_KEY_HEX);
}

#[test]
fn cross_aes_gcm_format_nonce_ciphertext_tag() {
    use manytype_core::crypto::aes_gcm;

    let key = [42u8; 32];
    let plaintext = b"hello anytype";
    let encrypted = aes_gcm::encrypt(&key, plaintext);

    // Format: 12 (nonce) + 13 (plaintext) + 16 (GCM tag) = 41
    assert_eq!(encrypted.len(), 41);

    // Round-trip
    let decrypted = aes_gcm::decrypt(&key, &encrypted).unwrap();
    assert_eq!(decrypted, plaintext);
}

#[test]
fn cross_ed25519_sign_verify_with_identity_key() {
    let seed = bip39::mnemonic_to_seed(TEST_MNEMONIC);
    let derived = slip0010::derive_identity_key(&seed, 0);
    let sk = ed25519::signing_key_from_seed(&derived.private_key);
    let vk = ed25519::verifying_key(&sk);
    let message = b"test change payload";
    let sig = ed25519::sign(&sk, message);
    assert_eq!(sig.to_bytes().len(), 64);
    assert!(ed25519::verify(&vk, message, &sig));
}
