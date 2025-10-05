//! Cryptographic primitives matching Anytype's key derivation and encryption.
//!
//! Implements:
//! - BIP-39 mnemonic generation/parsing
//! - SLIP-0010 Ed25519 key derivation (identity keys)
//! - SLIP-0021 symmetric key derivation (space keys)
//! - AES-256-GCM encryption/decryption
//! - Ed25519 signing/verification

pub mod aes_gcm;
pub mod bip39;
pub mod ed25519;
pub mod slip0010;
pub mod slip0021;
