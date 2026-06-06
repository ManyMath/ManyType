use std::collections::HashMap;
use std::sync::{Arc, Mutex};

use anyhow::{Context, Result, bail};
use manytype_proto::spacesync::ObjectSyncMessage;
use manytype_proto::treechange::{
    RawTreeChangeWithId, TreeFullSyncResponse, TreeHeadUpdate, TreeSyncContentValue,
    TreeSyncMessage, tree_sync_content_value,
};
use manytype_server::drpc::codec::{DrpcFrame, KIND_CLOSE, KIND_CLOSE_SEND};
use manytype_server::drpc::stream::DrpcStream;
use prost::Message;

use crate::handshake::client_proto_handshake;

pub type ServedTreeCache = Arc<Mutex<HashMap<(String, String), CachedTree>>>;

#[derive(Clone, Debug)]
pub struct CachedTree {
    pub heads: Vec<String>,
    pub snapshot_path: Vec<String>,
    pub root: Option<RawTreeChangeWithId>,
    pub changes: Vec<RawTreeChangeWithId>,
    pub object_type: i32,
}

fn trace(message: impl FnOnce() -> String) {
    if std::env::var_os("MANYTYPE_QUIC_TRACE").is_some() {
        eprintln!("[manytype_quic_ffi::incoming] {}", message());
    }
}

pub fn new_served_tree_cache() -> ServedTreeCache {
    Arc::new(Mutex::new(HashMap::new()))
}

pub fn cache_tree_payload(
    cache: &ServedTreeCache,
    space_id: &str,
    object_id: &str,
    payload: &[u8],
    object_type: i32,
) {
    let Some(cached_tree) = cached_tree_from_payload(payload, object_type) else {
        return;
    };
    cache
        .lock()
        .unwrap()
        .insert((space_id.to_string(), object_id.to_string()), cached_tree);
}

pub fn spawn_incoming_stream_server(connection: quinn::Connection, cache: ServedTreeCache) {
    tokio::spawn(async move {
        if let Err(error) = serve_incoming_streams(connection, cache).await {
            trace(|| format!("incoming stream server stopped with error: {error:#}"));
        }
    });
}

fn cached_tree_from_payload(payload: &[u8], object_type: i32) -> Option<CachedTree> {
    let tree_msg = TreeSyncMessage::decode(payload).ok()?;
    let head_update = tree_msg
        .content
        .as_ref()
        .and_then(|content| content.value.as_ref())
        .and_then(|value| match value {
            tree_sync_content_value::Value::HeadUpdate(head_update) => Some(head_update),
            _ => None,
        })?;

    Some(cached_tree_from_head_update(
        head_update,
        tree_msg.root_change,
        object_type,
    ))
}

fn cached_tree_from_head_update(
    head_update: &TreeHeadUpdate,
    root_change: Option<RawTreeChangeWithId>,
    object_type: i32,
) -> CachedTree {
    let mut changes = head_update.changes.clone();
    if let Some(root) = root_change.as_ref()
        && !changes.iter().any(|change| change.id == root.id)
    {
        changes.insert(0, root.clone());
    }

    CachedTree {
        heads: head_update.heads.clone(),
        snapshot_path: head_update.snapshot_path.clone(),
        root: root_change,
        changes,
        object_type,
    }
}

async fn serve_incoming_streams(
    connection: quinn::Connection,
    cache: ServedTreeCache,
) -> Result<()> {
    loop {
        let (send, recv) = match connection.accept_bi().await {
            Ok(streams) => streams,
            Err(quinn::ConnectionError::ApplicationClosed(_))
            | Err(quinn::ConnectionError::ConnectionClosed(_))
            | Err(quinn::ConnectionError::LocallyClosed)
            | Err(quinn::ConnectionError::Reset)
            | Err(quinn::ConnectionError::TimedOut) => return Ok(()),
            Err(error) => return Err(error.into()),
        };

        let cache = Arc::clone(&cache);
        tokio::spawn(async move {
            if let Err(error) = handle_incoming_stream(send, recv, cache).await {
                trace(|| format!("incoming stream error: {error:#}"));
            }
        });
    }
}

async fn handle_incoming_stream(
    send: quinn::SendStream,
    recv: quinn::RecvStream,
    cache: ServedTreeCache,
) -> Result<()> {
    let mut stream = tokio::io::join(recv, send);
    client_proto_handshake(&mut stream)
        .await
        .context("incoming stream proto handshake failed")?;

    let mut drpc_stream = DrpcStream::new(stream);
    let (stream_id, method) = drpc_stream
        .read_invoke()
        .await
        .context("failed to read incoming invoke")?;

    match method.as_str() {
        "/spacesync.SpaceSync/ObjectSyncRequestStream" => {
            handle_object_sync_request_stream(stream_id, &mut drpc_stream, &cache).await
        }
        _ => {
            write_error(
                &mut drpc_stream,
                stream_id,
                1,
                &format!("unsupported method: {method}"),
            )
            .await?;
            write_close_send(&mut drpc_stream, stream_id, 2).await?;
            write_close(&mut drpc_stream, stream_id, 3).await
        }
    }
}

async fn handle_object_sync_request_stream<T>(
    stream_id: u64,
    drpc_stream: &mut DrpcStream<T>,
    cache: &ServedTreeCache,
) -> Result<()>
where
    T: tokio::io::AsyncRead + tokio::io::AsyncWrite + Unpin,
{
    let request_bytes = drpc_stream
        .read_message()
        .await
        .context("failed to read ObjectSyncRequestStream request")?;
    let response = build_cached_object_sync_response(&request_bytes, cache)?;

    drpc_stream
        .write_message(stream_id, 1, &response)
        .await
        .context("failed to write ObjectSyncRequestStream response")?;
    write_close_send(drpc_stream, stream_id, 2).await?;
    write_close(drpc_stream, stream_id, 3).await
}

fn build_cached_object_sync_response(
    request_bytes: &[u8],
    cache: &ServedTreeCache,
) -> Result<Vec<u8>> {
    let request = ObjectSyncMessage::decode(request_bytes)
        .context("failed to decode inbound ObjectSyncMessage request")?;
    ensure_full_sync_request(&request)?;

    let cached_tree = cache
        .lock()
        .unwrap()
        .get(&(request.space_id.clone(), request.object_id.clone()))
        .cloned()
        .with_context(|| {
            format!(
                "no cached tree for space_id={} object_id={}",
                request.space_id, request.object_id
            )
        })?;
    let response_object_type = if request.object_type != 0 {
        request.object_type
    } else {
        cached_tree.object_type
    };

    let response_payload = TreeSyncMessage {
        content: Some(TreeSyncContentValue {
            value: Some(tree_sync_content_value::Value::FullSyncResponse(
                TreeFullSyncResponse {
                    heads: cached_tree.heads,
                    changes: cached_tree.changes,
                    snapshot_path: cached_tree.snapshot_path,
                },
            )),
        }),
        root_change: cached_tree.root,
    }
    .encode_to_vec();

    Ok(ObjectSyncMessage {
        space_id: request.space_id,
        request_id: String::new(),
        reply_id: request.request_id,
        payload: response_payload,
        object_id: request.object_id,
        object_type: response_object_type,
    }
    .encode_to_vec())
}

fn ensure_full_sync_request(request: &ObjectSyncMessage) -> Result<()> {
    let tree_msg = TreeSyncMessage::decode(request.payload.as_slice())
        .context("failed to decode TreeSyncMessage request payload")?;
    let is_full_sync_request = tree_msg
        .content
        .as_ref()
        .and_then(|content| content.value.as_ref())
        .is_some_and(|value| matches!(value, tree_sync_content_value::Value::FullSyncRequest(_)));
    if !is_full_sync_request {
        bail!("unexpected tree sync request type");
    }
    Ok(())
}

async fn write_error<T>(
    drpc_stream: &mut DrpcStream<T>,
    stream_id: u64,
    message_id: u64,
    message: &str,
) -> Result<()>
where
    T: tokio::io::AsyncRead + tokio::io::AsyncWrite + Unpin,
{
    drpc_stream
        .write_error(stream_id, message_id, message)
        .await
        .context("failed to write DRPC error frame")
}

async fn write_close_send<T>(
    drpc_stream: &mut DrpcStream<T>,
    stream_id: u64,
    message_id: u64,
) -> Result<()>
where
    T: tokio::io::AsyncRead + tokio::io::AsyncWrite + Unpin,
{
    drpc_stream
        .write_frame(DrpcFrame {
            kind: KIND_CLOSE_SEND,
            done: true,
            control: false,
            stream_id,
            message_id,
            data: bytes::Bytes::new(),
        })
        .await
        .context("failed to write CLOSE_SEND frame")
}

async fn write_close<T>(
    drpc_stream: &mut DrpcStream<T>,
    stream_id: u64,
    message_id: u64,
) -> Result<()>
where
    T: tokio::io::AsyncRead + tokio::io::AsyncWrite + Unpin,
{
    drpc_stream
        .write_frame(DrpcFrame {
            kind: KIND_CLOSE,
            done: true,
            control: false,
            stream_id,
            message_id,
            data: bytes::Bytes::new(),
        })
        .await
        .context("failed to write CLOSE frame")
}

#[cfg(test)]
mod tests {
    use super::*;
    use manytype_proto::spacesync::ObjectType;
    use manytype_proto::treechange::{
        RawTreeChangeWithId, TreeFullSyncRequest, TreeHeadUpdate, TreeSyncContentValue,
        TreeSyncMessage, tree_sync_content_value,
    };

    #[test]
    fn cache_tree_payload_serves_full_sync_response_from_head_update() {
        let cache = new_served_tree_cache();
        let root = RawTreeChangeWithId {
            id: "root-change".to_string(),
            raw_change: b"root".to_vec(),
        };
        let snapshot = RawTreeChangeWithId {
            id: "snapshot-change".to_string(),
            raw_change: b"snapshot".to_vec(),
        };
        let payload = TreeSyncMessage {
            content: Some(TreeSyncContentValue {
                value: Some(tree_sync_content_value::Value::HeadUpdate(TreeHeadUpdate {
                    heads: vec![snapshot.id.clone()],
                    changes: vec![root.clone(), snapshot.clone()],
                    snapshot_path: vec![snapshot.id.clone(), root.id.clone()],
                })),
            }),
            root_change: Some(root.clone()),
        }
        .encode_to_vec();

        cache_tree_payload(
            &cache,
            "space-1",
            "object-1",
            payload.as_slice(),
            ObjectType::Tree as i32,
        );

        let request = ObjectSyncMessage {
            space_id: "space-1".to_string(),
            request_id: "req-42".to_string(),
            payload: TreeSyncMessage {
                content: Some(TreeSyncContentValue {
                    value: Some(tree_sync_content_value::Value::FullSyncRequest(
                        TreeFullSyncRequest::default(),
                    )),
                }),
                ..Default::default()
            }
            .encode_to_vec(),
            object_id: "object-1".to_string(),
            object_type: ObjectType::Tree as i32,
            ..Default::default()
        };

        let response_bytes =
            build_cached_object_sync_response(&request.encode_to_vec(), &cache).unwrap();
        let response = ObjectSyncMessage::decode(response_bytes.as_slice()).unwrap();
        assert_eq!(response.reply_id, "req-42");
        assert_eq!(response.space_id, "space-1");
        assert_eq!(response.object_id, "object-1");

        let tree_response = TreeSyncMessage::decode(response.payload.as_slice()).unwrap();
        let full_sync_response = tree_response
            .content
            .as_ref()
            .and_then(|content| content.value.as_ref())
            .and_then(|value| match value {
                tree_sync_content_value::Value::FullSyncResponse(response) => Some(response),
                _ => None,
            })
            .unwrap();
        assert_eq!(tree_response.root_change.unwrap().id, "root-change");
        assert_eq!(full_sync_response.heads, vec!["snapshot-change"]);
        assert_eq!(
            full_sync_response.snapshot_path,
            vec!["snapshot-change", "root-change"]
        );
        assert_eq!(full_sync_response.changes.len(), 2);
        assert_eq!(full_sync_response.changes[0].id, "root-change");
        assert_eq!(full_sync_response.changes[1].id, "snapshot-change");
    }
}
