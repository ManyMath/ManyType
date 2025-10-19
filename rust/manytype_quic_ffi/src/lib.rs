//! Rust FFI crate wrapping QUIC client, credential handshake, and DRPC framing.
//!
//! Provides C FFI exports for Dart to call: connect, invoke, sync_object, free.
//! All network protocol complexity stays in Rust; Dart gets simple
//! connect/invoke/sync_object calls through the C ABI.

pub mod client;
pub mod drpc;
pub mod handshake;
pub mod runtime;

use std::collections::HashMap;
use std::ffi::{CStr, CString, c_char};
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{LazyLock, Mutex};

use client::ConnHandle;
use manytype_core::crypto::ed25519;
use runtime::RUNTIME;

/// Global handle storage: maps handle IDs to ConnHandles.
static HANDLES: LazyLock<Mutex<HashMap<u64, ConnHandle>>> =
    LazyLock::new(|| Mutex::new(HashMap::new()));

/// Monotonic counter for handle IDs.
static NEXT_HANDLE_ID: AtomicU64 = AtomicU64::new(1);

/// FFI result returned to Dart/C callers.
///
/// On success: `data` is non-null with `data_len` bytes, `error` is null.
/// On error: `error` is a non-null C string, `data` is null.
#[repr(C)]
#[allow(missing_docs)]
pub struct FfiResult {
    pub data: *mut u8,
    pub data_len: u32,
    pub error: *mut c_char,
}

impl FfiResult {
    fn success(data: Vec<u8>) -> *mut FfiResult {
        let len = data.len() as u32;
        let mut boxed = data.into_boxed_slice();
        let ptr = boxed.as_mut_ptr();
        std::mem::forget(boxed);
        Box::into_raw(Box::new(FfiResult {
            data: ptr,
            data_len: len,
            error: std::ptr::null_mut(),
        }))
    }

    fn error(msg: String) -> *mut FfiResult {
        let c_str = CString::new(msg).unwrap_or_else(|_| CString::new("unknown error").unwrap());
        Box::into_raw(Box::new(FfiResult {
            data: std::ptr::null_mut(),
            data_len: 0,
            error: c_str.into_raw(),
        }))
    }
}

/// Connect to a QUIC server and perform credential handshake.
///
/// `addr`: C string, e.g. "127.0.0.1:4830"
/// `identity_seed`: 32-byte Ed25519 seed
///
/// Returns FfiResult with handle ID (u64 LE) on success.
#[unsafe(no_mangle)]
pub extern "C" fn ffi_connect(
    addr: *const c_char,
    identity_seed: *const u8,
    seed_len: u32,
) -> *mut FfiResult {
    let addr_str = match unsafe { CStr::from_ptr(addr) }.to_str() {
        Ok(s) => s.to_string(),
        Err(e) => return FfiResult::error(format!("invalid addr string: {e}")),
    };

    if seed_len != 32 {
        return FfiResult::error(format!("identity_seed must be 32 bytes, got {seed_len}"));
    }
    let seed_slice = unsafe { std::slice::from_raw_parts(identity_seed, 32) };
    let mut seed = [0u8; 32];
    seed.copy_from_slice(seed_slice);
    let signing_key = ed25519::signing_key_from_seed(&seed);

    match RUNTIME.block_on(client::connect(&addr_str, &signing_key)) {
        Ok(handle) => {
            let id = NEXT_HANDLE_ID.fetch_add(1, Ordering::Relaxed);
            HANDLES.lock().unwrap().insert(id, handle);
            FfiResult::success(id.to_le_bytes().to_vec())
        }
        Err(e) => FfiResult::error(format!("connect failed: {e:#}")),
    }
}

/// Invoke a unary RPC on an established connection.
///
/// `handle_id`: connection handle ID from ffi_connect
/// `method`: RPC method path, e.g. "/coordinator.Coordinator/NetworkConfiguration"
/// `payload`: request protobuf bytes
///
/// Returns FfiResult with response protobuf bytes on success.
#[unsafe(no_mangle)]
pub extern "C" fn ffi_invoke(
    handle_id: u64,
    method: *const c_char,
    payload: *const u8,
    payload_len: u32,
) -> *mut FfiResult {
    let method_str = match unsafe { CStr::from_ptr(method) }.to_str() {
        Ok(s) => s,
        Err(e) => return FfiResult::error(format!("invalid method string: {e}")),
    };

    let payload_slice = if payload_len > 0 {
        unsafe { std::slice::from_raw_parts(payload, payload_len as usize) }
    } else {
        &[]
    };

    let mut handles = HANDLES.lock().unwrap();
    let handle = match handles.get_mut(&handle_id) {
        Some(h) => h,
        None => return FfiResult::error(format!("unknown handle ID: {handle_id}")),
    };

    match RUNTIME.block_on(drpc::invoke(&mut handle.drpc_stream, method_str, payload_slice)) {
        Ok(response) => FfiResult::success(response),
        Err(e) => FfiResult::error(format!("invoke failed: {e:#}")),
    }
}

/// Sync an object by sending changes via ObjectSyncStream.
///
/// `changes_data`: length-prefixed array of changes.
///   Format: [u32 LE length][bytes] repeated for each change.
///
/// Returns FfiResult with responses in the same length-prefixed format.
#[unsafe(no_mangle)]
pub extern "C" fn ffi_sync_object(
    handle_id: u64,
    _space_id: *const c_char,
    _object_id: *const c_char,
    changes_data: *const u8,
    changes_len: u32,
) -> *mut FfiResult {
    // Parse length-prefixed changes
    let changes_slice = if changes_len > 0 {
        unsafe { std::slice::from_raw_parts(changes_data, changes_len as usize) }
    } else {
        &[]
    };

    let mut changes = Vec::new();
    let mut offset = 0usize;
    while offset + 4 <= changes_slice.len() {
        let len = u32::from_le_bytes(
            changes_slice[offset..offset + 4].try_into().unwrap(),
        ) as usize;
        offset += 4;
        if offset + len > changes_slice.len() {
            return FfiResult::error("changes_data truncated".to_string());
        }
        changes.push(changes_slice[offset..offset + len].to_vec());
        offset += len;
    }

    let mut handles = HANDLES.lock().unwrap();
    let handle = match handles.get_mut(&handle_id) {
        Some(h) => h,
        None => return FfiResult::error(format!("unknown handle ID: {handle_id}")),
    };

    match RUNTIME.block_on(drpc::sync_object(&mut handle.drpc_stream, &changes)) {
        Ok(responses) => {
            // Serialize responses as length-prefixed
            let mut out = Vec::new();
            for resp in &responses {
                out.extend_from_slice(&(resp.len() as u32).to_le_bytes());
                out.extend_from_slice(resp);
            }
            FfiResult::success(out)
        }
        Err(e) => FfiResult::error(format!("sync_object failed: {e:#}")),
    }
}

/// Free a connection handle, closing the QUIC connection.
#[unsafe(no_mangle)]
pub extern "C" fn ffi_free_handle(handle_id: u64) {
    HANDLES.lock().unwrap().remove(&handle_id);
}

/// Free an FfiResult and its associated memory.
///
/// # Safety
/// The caller must pass a valid FfiResult pointer obtained from one of the
/// ffi_* functions. Must be called exactly once per result.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ffi_free_result(result: *mut FfiResult) {
    if result.is_null() {
        return;
    }
    let res = unsafe { Box::from_raw(result) };
    if !res.data.is_null() {
        let _ = unsafe {
            Vec::from_raw_parts(res.data, res.data_len as usize, res.data_len as usize)
        };
    }
    if !res.error.is_null() {
        let _ = unsafe { CString::from_raw(res.error) };
    }
}
