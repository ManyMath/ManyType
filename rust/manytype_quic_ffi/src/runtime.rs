//! Global Tokio runtime for FFI calls.
//!
//! FFI functions are synchronous from the C caller's perspective.
//! They use `RUNTIME.block_on(...)` to drive async Rust code.

use std::sync::LazyLock;

pub static RUNTIME: LazyLock<tokio::runtime::Runtime> = LazyLock::new(|| {
    tokio::runtime::Builder::new_multi_thread()
        .enable_all()
        .build()
        .expect("Failed to create Tokio runtime")
});
