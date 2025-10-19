//! Rust FFI crate wrapping QUIC client, credential handshake, and DRPC framing.
//!
//! Provides C FFI exports for Dart to call: connect, invoke, sync_object, free.

pub mod runtime;
pub mod client;
pub mod handshake;
