//! Rust FFI crate wrapping QUIC client, credential handshake, and DRPC framing.
//!
//! Provides C FFI exports for Dart to call: connect, invoke, sync_object,
//! request_object, sync_store, free.
//! All network protocol complexity stays in Rust; Dart gets simple
//! connect/invoke/sync_object/sync_store calls through the C ABI.

pub mod client;
pub mod drpc;
pub mod handshake;
pub mod incoming;
pub mod runtime;

use std::collections::HashMap;
use std::ffi::{CStr, CString, c_char};
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{LazyLock, Mutex};

use client::ConnHandle;
use incoming::cache_tree_payload;
use manytype_core::crypto::ed25519;
use manytype_proto::spacesync::{ObjectSyncMessage, ObjectType};
use prost::Message;
use runtime::RUNTIME;

/// Version of the exported C ABI used by native ManyType clients.
pub const FFI_ABI_VERSION: u32 = 1;

/// Return the C ABI version without allocating or initializing a connection.
///
/// Packaging probes use this symbol to verify that the loaded library is the
/// ManyType QUIC bridge expected by the Dart client.
#[unsafe(no_mangle)]
pub extern "C" fn ffi_abi_version() -> u32 {
    FFI_ABI_VERSION
}

/// Global handle storage: maps handle IDs to ConnHandles.
static HANDLES: LazyLock<Mutex<HashMap<u64, ConnHandle>>> =
    LazyLock::new(|| Mutex::new(HashMap::new()));

/// Monotonic counter for handle IDs.
static NEXT_HANDLE_ID: AtomicU64 = AtomicU64::new(1);

fn trace(message: impl FnOnce() -> String) {
    if std::env::var_os("MANYTYPE_QUIC_TRACE").is_some() {
        eprintln!("[manytype_quic_ffi::ffi] {}", message());
    }
}

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
        let sanitized = msg.replace('\0', "\\0");
        let c_str =
            CString::new(sanitized).unwrap_or_else(|_| CString::new("unknown error").unwrap());
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
/// `peer_seed`: 32-byte Ed25519 peer seed used for libp2p TLS/peer ID
/// `account_seed`: 32-byte Ed25519 account seed used for Any-sync credentials
///
/// Returns FfiResult with handle ID (u64 LE) on success.
///
/// # Safety
///
/// - `addr` must be a valid, NUL-terminated C string.
/// - `peer_seed` and `account_seed` must point to at least 32 readable bytes.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ffi_connect(
    addr: *const c_char,
    peer_seed: *const u8,
    peer_seed_len: u32,
    account_seed: *const u8,
    account_seed_len: u32,
) -> *mut FfiResult {
    let addr_str = match unsafe { CStr::from_ptr(addr) }.to_str() {
        Ok(s) => s.to_string(),
        Err(e) => return FfiResult::error(format!("invalid addr string: {e}")),
    };

    if peer_seed_len != 32 {
        return FfiResult::error(format!("peer_seed must be 32 bytes, got {peer_seed_len}"));
    }
    if account_seed_len != 32 {
        return FfiResult::error(format!(
            "account_seed must be 32 bytes, got {account_seed_len}"
        ));
    }
    let peer_seed_slice = unsafe { std::slice::from_raw_parts(peer_seed, 32) };
    let account_seed_slice = unsafe { std::slice::from_raw_parts(account_seed, 32) };
    let mut peer_seed = [0u8; 32];
    peer_seed.copy_from_slice(peer_seed_slice);
    let mut account_seed = [0u8; 32];
    account_seed.copy_from_slice(account_seed_slice);
    let peer_signing_key = ed25519::signing_key_from_seed(&peer_seed);
    let account_signing_key = ed25519::signing_key_from_seed(&account_seed);
    trace(|| format!("ffi_connect start addr={addr_str}"));

    match RUNTIME.block_on(client::connect(
        &addr_str,
        &peer_signing_key,
        &account_signing_key,
    )) {
        Ok(handle) => {
            let id = NEXT_HANDLE_ID.fetch_add(1, Ordering::Relaxed);
            HANDLES.lock().unwrap().insert(id, handle);
            trace(|| format!("ffi_connect success addr={addr_str} handle_id={id}"));
            FfiResult::success(id.to_le_bytes().to_vec())
        }
        Err(e) => {
            trace(|| format!("ffi_connect error addr={addr_str} error={e:#}"));
            FfiResult::error(format!("connect failed: {e:#}"))
        }
    }
}

/// Invoke a unary RPC on an established connection.
///
/// `handle_id`: connection handle ID from ffi_connect
/// `method`: RPC method path, e.g. "/coordinator.Coordinator/NetworkConfiguration"
/// `payload`: request protobuf bytes
///
/// Returns FfiResult with response protobuf bytes on success.
///
/// # Safety
///
/// - `method` must be a valid, NUL-terminated C string.
/// - `payload` must point to at least `payload_len` readable bytes (or be null when `payload_len` is 0).
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ffi_invoke(
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

    let connection = {
        let handles = HANDLES.lock().unwrap();
        match handles.get(&handle_id) {
            Some(h) => h.connection.clone(),
            None => return FfiResult::error(format!("unknown handle ID: {handle_id}")),
        }
    };
    trace(|| {
        format!(
            "ffi_invoke start handle_id={handle_id} method={method_str} payload_len={payload_len}"
        )
    });

    match RUNTIME.block_on(async {
        let mut drpc_stream = client::open_drpc_stream(&connection).await?;
        drpc::invoke(&mut drpc_stream, method_str, payload_slice).await
    }) {
        Ok(response) => {
            trace(|| {
                format!(
                    "ffi_invoke success handle_id={handle_id} method={method_str} response_len={}",
                    response.len()
                )
            });
            FfiResult::success(response)
        }
        Err(e) => {
            trace(|| {
                format!("ffi_invoke error handle_id={handle_id} method={method_str} error={e:#}")
            });
            FfiResult::error(format!("invoke failed: {e:#}"))
        }
    }
}

/// Sync an object by sending a single TreeSyncMessage via ObjectSyncStream.
///
/// `payload`: serialized TreeSyncMessage (or empty for pull).
///
/// Returns raw response bytes (serialized ObjectSyncMessage(s)).
///
/// # Safety
///
/// - `space_id` and `object_id` must be valid, NUL-terminated C strings.
/// - `payload` must point to at least `payload_len` readable bytes (or be null when `payload_len` is 0).
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ffi_sync_object(
    handle_id: u64,
    space_id: *const c_char,
    object_id: *const c_char,
    payload: *const u8,
    payload_len: u32,
) -> *mut FfiResult {
    let space_id = unsafe { CStr::from_ptr(space_id) }
        .to_str()
        .unwrap_or("")
        .to_string();
    let object_id = unsafe { CStr::from_ptr(object_id) }
        .to_str()
        .unwrap_or("")
        .to_string();

    let payload_slice = if payload_len > 0 {
        unsafe { std::slice::from_raw_parts(payload, payload_len as usize) }
    } else {
        &[]
    };

    let main_msg = ObjectSyncMessage {
        space_id: space_id.clone(),
        object_id: object_id.clone(),
        request_id: "req-0".to_string(),
        payload: payload_slice.to_vec(),
        object_type: ObjectType::Tree as i32,
        ..Default::default()
    };

    let messages: Vec<Vec<u8>> = vec![main_msg.encode_to_vec()];

    let (connection, served_trees) = {
        let handles = HANDLES.lock().unwrap();
        match handles.get(&handle_id) {
            Some(h) => (h.connection.clone(), h.served_trees.clone()),
            None => return FfiResult::error(format!("unknown handle ID: {handle_id}")),
        }
    };

    if payload_len > 0 {
        cache_tree_payload(
            &served_trees,
            &space_id,
            &object_id,
            payload_slice,
            ObjectType::Tree as i32,
        );
    }

    match RUNTIME.block_on(async {
        let mut drpc_stream = client::open_drpc_stream(&connection).await?;
        drpc::sync_object(&mut drpc_stream, &messages).await
    }) {
        Ok(responses) => {
            trace(|| {
                format!(
                    "ffi_sync_object success handle_id={} responses={}",
                    handle_id,
                    responses.len()
                )
            });
            let mut out = Vec::new();
            for resp in responses {
                out.extend_from_slice(&(resp.len() as u32).to_le_bytes());
                out.extend_from_slice(&resp);
            }
            FfiResult::success(out)
        }
        Err(e) => {
            trace(|| format!("ffi_sync_object error handle_id={} err={:#}", handle_id, e));
            FfiResult::error(format!("sync_object failed: {e:#}"))
        }
    }
}

/// Request an object by sending a single TreeSyncMessage via
/// ObjectSyncRequestStream.
///
/// `payload`: serialized TreeSyncMessage full-sync request bytes.
///
/// Returns raw response bytes (serialized ObjectSyncMessage(s)).
///
/// # Safety
///
/// - `space_id` and `object_id` must be valid, NUL-terminated C strings.
/// - `payload` must point to at least `payload_len` readable bytes (or be null when `payload_len` is 0).
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ffi_request_object(
    handle_id: u64,
    space_id: *const c_char,
    object_id: *const c_char,
    payload: *const u8,
    payload_len: u32,
) -> *mut FfiResult {
    let space_id = unsafe { CStr::from_ptr(space_id) }
        .to_str()
        .unwrap_or("")
        .to_string();
    let object_id = unsafe { CStr::from_ptr(object_id) }
        .to_str()
        .unwrap_or("")
        .to_string();

    let payload_slice = if payload_len > 0 {
        unsafe { std::slice::from_raw_parts(payload, payload_len as usize) }
    } else {
        &[]
    };

    let request = ObjectSyncMessage {
        space_id,
        object_id,
        request_id: "req-0".to_string(),
        payload: payload_slice.to_vec(),
        object_type: ObjectType::Tree as i32,
        ..Default::default()
    }
    .encode_to_vec();

    let connection = {
        let handles = HANDLES.lock().unwrap();
        match handles.get(&handle_id) {
            Some(h) => h.connection.clone(),
            None => return FfiResult::error(format!("unknown handle ID: {handle_id}")),
        }
    };

    match RUNTIME.block_on(async {
        let mut drpc_stream = client::open_drpc_stream(&connection).await?;
        drpc::request_object(&mut drpc_stream, &request).await
    }) {
        Ok(responses) => {
            trace(|| {
                format!(
                    "ffi_request_object success handle_id={} responses={}",
                    handle_id,
                    responses.len()
                )
            });
            let mut out = Vec::new();
            for resp in responses {
                out.extend_from_slice(&(resp.len() as u32).to_le_bytes());
                out.extend_from_slice(&resp);
            }
            FfiResult::success(out)
        }
        Err(e) => {
            trace(|| {
                format!(
                    "ffi_request_object error handle_id={} err={:#}",
                    handle_id, e
                )
            });
            FfiResult::error(format!("request_object failed: {e:#}"))
        }
    }
}

/// Exchange StoreKeyValue messages over StoreElements.
///
/// `messages_data` is a length-prefixed array of serialized StoreKeyValue
/// protobuf messages. Responses are returned in the same format.
///
/// # Safety
///
/// - `messages_data` must point to at least `messages_len` readable bytes (or be null when `messages_len` is 0).
#[unsafe(no_mangle)]
pub unsafe extern "C" fn ffi_sync_store(
    handle_id: u64,
    messages_data: *const u8,
    messages_len: u32,
) -> *mut FfiResult {
    trace(|| format!("ffi_sync_store start handle_id={handle_id} messages_len={messages_len}"));
    let messages_slice = if messages_len > 0 {
        unsafe { std::slice::from_raw_parts(messages_data, messages_len as usize) }
    } else {
        &[]
    };

    let mut messages = Vec::new();
    let mut offset = 0usize;
    while offset + 4 <= messages_slice.len() {
        let len =
            u32::from_le_bytes(messages_slice[offset..offset + 4].try_into().unwrap()) as usize;
        offset += 4;
        if offset + len > messages_slice.len() {
            return FfiResult::error("messages_data truncated".to_string());
        }
        messages.push(messages_slice[offset..offset + len].to_vec());
        offset += len;
    }

    let connection = {
        let handles = HANDLES.lock().unwrap();
        match handles.get(&handle_id) {
            Some(h) => h.connection.clone(),
            None => return FfiResult::error(format!("unknown handle ID: {handle_id}")),
        }
    };

    match RUNTIME.block_on(async {
        let mut drpc_stream = client::open_drpc_stream(&connection).await?;
        drpc::exchange_stream(
            &mut drpc_stream,
            "/spacesync.SpaceSync/StoreElements",
            &messages,
        )
        .await
    }) {
        Ok(responses) => {
            trace(|| {
                format!(
                    "ffi_sync_store success handle_id={handle_id} response_count={}",
                    responses.len()
                )
            });
            let mut out = Vec::new();
            for resp in responses {
                out.extend_from_slice(&(resp.len() as u32).to_le_bytes());
                out.extend_from_slice(&resp);
            }
            FfiResult::success(out)
        }
        Err(e) => {
            trace(|| format!("ffi_sync_store error handle_id={handle_id} error={e:#}"));
            FfiResult::error(format!("sync_store failed: {e:#}"))
        }
    }
}

/// Free a connection handle, closing the QUIC connection.
#[unsafe(no_mangle)]
pub extern "C" fn ffi_free_handle(handle_id: u64) {
    if let Some(handle) = HANDLES.lock().unwrap().remove(&handle_id) {
        handle.connection.close(0u32.into(), b"ffi_free_handle");
    }
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
        let _ =
            unsafe { Vec::from_raw_parts(res.data, res.data_len as usize, res.data_len as usize) };
    }
    if !res.error.is_null() {
        let _ = unsafe { CString::from_raw(res.error) };
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn exported_abi_version_is_stable() {
        assert_eq!(ffi_abi_version(), 1);
    }
}
