//! Cryptographic primitives matching Anytype's key derivation and encryption.
//!
//! Implements:
//! - BIP-39 mnemonic generation/parsing
//! - SLIP-0010 Ed25519 key derivation (identity keys)
//! - SLIP-0021 symmetric key derivation (space keys)
//! - AES-256-GCM encryption/decryption
//! - Ed25519 signing/verification
