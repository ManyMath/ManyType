//! DRPC method router -- dispatches incoming RPC calls to handler functions.

use anyhow::{Result, bail};
use prost::Message;
use tokio::io::{AsyncRead, AsyncWrite};

use super::codec::{KIND_CLOSE, KIND_CLOSE_SEND};
use super::stream::DrpcStream;
use crate::auth::AuthenticatedPeer;
use crate::consensus;
use crate::coordinator::{self, CoordinatorConfig};
use crate::file_node;
use crate::sync_node::{self, SharedSyncState};
use manytype_proto::spacesync::ObjectSyncMessage;
use manytype_proto::spacesync::StoreKeyValue;
use manytype_proto::treechange::{self, TreeSyncMessage};

/// Shared server state passed to all RPC handlers.
///
/// Contains all subsystems needed by the various RPC handlers.
pub struct ServerState {
    pub coordinator_config: CoordinatorConfig,
    pub sync_state: SharedSyncState,
    pub file_node: file_node::FileNodeState,
    pub local_signing_key: ed25519_dalek::SigningKey,
}

/// Dispatch an RPC call to the appropriate handler based on method path.
///
/// The caller should have already read the invoke frame to obtain the
/// method path and stream_id. This function matches the method and
/// invokes the corresponding handler.
pub async fn dispatch<T>(
    stream_id: u64,
    method: &str,
    stream: &mut DrpcStream<T>,
    state: &ServerState,
    authenticated_peer: &AuthenticatedPeer<'_>,
) -> Result<()>
where
    T: AsyncRead + AsyncWrite + Unpin,
{
    let mut next_message_id = 1u64;

    fn is_benign_disconnect(error: &anyhow::Error) -> bool {
        use std::io::ErrorKind;

        error.chain().any(|cause| {
            if let Some(io_error) = cause.downcast_ref::<std::io::Error>() {
                return matches!(
                    io_error.kind(),
                    ErrorKind::BrokenPipe
                        | ErrorKind::ConnectionAborted
                        | ErrorKind::ConnectionReset
                        | ErrorKind::UnexpectedEof
                        | ErrorKind::NotConnected
                );
            }

            if let Some(write_error) = cause.downcast_ref::<quinn::WriteError>() {
                return matches!(
                    write_error,
                    quinn::WriteError::ConnectionLost(_)
                        | quinn::WriteError::ClosedStream
                        | quinn::WriteError::Stopped(_)
                        | quinn::WriteError::ZeroRttRejected
                );
            }

            if let Some(connection_error) = cause.downcast_ref::<quinn::ConnectionError>() {
                return matches!(
                    connection_error,
                    quinn::ConnectionError::ApplicationClosed(_)
                        | quinn::ConnectionError::ConnectionClosed(_)
                        | quinn::ConnectionError::LocallyClosed
                        | quinn::ConnectionError::TimedOut
                        | quinn::ConnectionError::Reset
                );
            }

            false
        })
    }

    async fn write_response<T>(
        stream: &mut DrpcStream<T>,
        stream_id: u64,
        next_message_id: &mut u64,
        data: &[u8],
    ) -> Result<()>
    where
        T: AsyncRead + AsyncWrite + Unpin,
    {
        let message_id = *next_message_id;
        *next_message_id += 1;
        if let Err(error) = stream.write_message(stream_id, message_id, data).await {
            if is_benign_disconnect(&error) {
                return Ok(());
            }
            return Err(error);
        }
        Ok(())
    }

    async fn write_close_send<T>(
        stream: &mut DrpcStream<T>,
        stream_id: u64,
        next_message_id: &mut u64,
    ) -> Result<()>
    where
        T: AsyncRead + AsyncWrite + Unpin,
    {
        if let Err(error) = write_frame(
            stream,
            stream_id,
            next_message_id,
            KIND_CLOSE_SEND,
            true,
            bytes::Bytes::new(),
        )
        .await
        {
            if is_benign_disconnect(&error) {
                return Ok(());
            }
            return Err(error);
        }
        Ok(())
    }

    async fn write_close<T>(
        stream: &mut DrpcStream<T>,
        stream_id: u64,
        next_message_id: &mut u64,
    ) -> Result<()>
    where
        T: AsyncRead + AsyncWrite + Unpin,
    {
        if let Err(error) = write_frame(
            stream,
            stream_id,
            next_message_id,
            KIND_CLOSE,
            true,
            bytes::Bytes::new(),
        )
        .await
        {
            if is_benign_disconnect(&error) {
                return Ok(());
            }
            return Err(error);
        }
        Ok(())
    }

    async fn write_unary_response<T>(
        stream: &mut DrpcStream<T>,
        stream_id: u64,
        next_message_id: &mut u64,
        data: &[u8],
    ) -> Result<()>
    where
        T: AsyncRead + AsyncWrite + Unpin,
    {
        write_response(stream, stream_id, next_message_id, data).await?;
        write_close_send(stream, stream_id, next_message_id).await
    }

    async fn write_error_response<T>(
        stream: &mut DrpcStream<T>,
        stream_id: u64,
        next_message_id: &mut u64,
        message: &str,
    ) -> Result<()>
    where
        T: AsyncRead + AsyncWrite + Unpin,
    {
        let message_id = *next_message_id;
        *next_message_id += 1;
        if let Err(error) = stream.write_error(stream_id, message_id, message).await {
            if is_benign_disconnect(&error) {
                return Ok(());
            }
            return Err(error);
        }
        Ok(())
    }

    async fn write_frame<T>(
        stream: &mut DrpcStream<T>,
        stream_id: u64,
        next_message_id: &mut u64,
        kind: u8,
        done: bool,
        data: bytes::Bytes,
    ) -> Result<()>
    where
        T: AsyncRead + AsyncWrite + Unpin,
    {
        let message_id = *next_message_id;
        *next_message_id += 1;
        if let Err(error) = stream
            .write_frame(super::codec::DrpcFrame {
                kind,
                done,
                control: false,
                stream_id,
                message_id,
                data,
            })
            .await
        {
            if is_benign_disconnect(&error) {
                return Ok(());
            }
            return Err(error);
        }
        Ok(())
    }

    fn object_sync_error_message(response_bytes: &[u8]) -> Option<String> {
        let msg = ObjectSyncMessage::decode(response_bytes).ok()?;
        if msg.payload.is_empty() {
            return None;
        }

        let tree_msg = TreeSyncMessage::decode(msg.payload.as_slice()).ok()?;
        let content = tree_msg.content?;
        let value = content.value?;
        let treechange::tree_sync_content_value::Value::ErrorResponse(err) = value else {
            return None;
        };

        if err.error.is_empty() {
            Some(format!("tree sync error code {}", err.err_code))
        } else {
            Some(err.error)
        }
    }

    match method {
        "/coordinator.Coordinator/NetworkConfiguration" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = coordinator::handle_network_configuration(
                &request_bytes,
                &state.coordinator_config,
            )?;
            write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes).await
        }
        "/coordinator.Coordinator/SpaceSign" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = coordinator::handle_space_sign(
                &request_bytes,
                &state.coordinator_config,
                &state.local_signing_key,
                authenticated_peer,
                &state.sync_state,
            )?;
            write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes).await
        }
        "/coordinator.Coordinator/SpaceStatusCheck" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = coordinator::handle_space_status_check(
                &request_bytes,
                &state.sync_state,
                authenticated_peer,
            )?;
            write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes).await
        }
        "/coordinator.Coordinator/SpaceMakeShareable" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = coordinator::handle_space_make_shareable(
                &request_bytes,
                &state.sync_state,
                authenticated_peer,
            )?;
            write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes).await
        }
        "/coordinator.Coordinator/AclAddRecord" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = coordinator::handle_acl_add_record(
                &request_bytes,
                &state.sync_state,
                &state.local_signing_key,
                authenticated_peer,
            )?;
            write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes).await
        }
        "/coordinator.Coordinator/AclGetRecords" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = coordinator::handle_acl_get_records(
                &request_bytes,
                &state.sync_state,
                authenticated_peer,
            )?;
            write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes).await
        }
        "/coordinator.Coordinator/AclUploadInvite" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes =
                coordinator::handle_acl_upload_invite(&request_bytes, &state.file_node)?;
            write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes).await
        }
        "/coordinator.Coordinator/SpaceDelete" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = coordinator::handle_space_delete(
                &request_bytes,
                &state.sync_state,
                authenticated_peer,
            )?;
            write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes).await
        }
        "/coordinator.Coordinator/AccountDelete" => {
            let request_bytes = stream.read_message().await?;
            match coordinator::handle_account_delete(&request_bytes, &state.sync_state) {
                Ok(response_bytes) => {
                    write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes)
                        .await
                }
                Err(error) => {
                    write_error_response(
                        stream,
                        stream_id,
                        &mut next_message_id,
                        &error.to_string(),
                    )
                    .await?;
                    bail!("{error}");
                }
            }
        }
        "/coordinator.Coordinator/DeletionLog" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = coordinator::handle_deletion_log(&request_bytes)?;
            write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes).await
        }
        "/spacesync.SpaceSync/HeadSync" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes =
                sync_node::handle_head_sync(&request_bytes, &state.sync_state, authenticated_peer)?;
            write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes).await
        }
        "/spacesync.SpaceSync/StoreDiff" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = sync_node::handle_store_diff(
                &request_bytes,
                &state.sync_state,
                authenticated_peer,
            )?;
            write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes).await
        }
        "/spacesync.SpaceSync/StoreElements" => {
            // Bidirectional stream: official clients expect the server to
            // respond while the request stream is still open (they may not
            // send CLOSE_SEND until after reading responses). Implement a
            // minimal interactive StoreElements loop: accept upserts and reply
            // to lookup requests immediately.
            let mut active_space_id = String::new();

            loop {
                let frame = match stream.read_frame().await {
                    Ok(Some(frame)) => frame,
                    Ok(None) => break,
                    Err(error) if is_benign_disconnect(&error) => break,
                    Err(error) => return Err(error),
                };

                if frame.kind == KIND_CLOSE_SEND {
                    break;
                }

                let msg_bytes = if frame.done {
                    frame.data.to_vec()
                } else {
                    let mut buf = frame.data.to_vec();
                    loop {
                        let next = stream
                            .read_frame()
                            .await?
                            .ok_or_else(|| anyhow::anyhow!("connection closed mid-message"))?;
                        buf.extend_from_slice(&next.data);
                        if next.done {
                            break;
                        }
                    }
                    buf
                };

                let mut msg = match StoreKeyValue::decode(msg_bytes.as_slice()) {
                    Ok(msg) => msg,
                    Err(_) => continue,
                };

                if !msg.space_id.is_empty() {
                    active_space_id = msg.space_id.clone();
                }

                if msg.space_id.is_empty() {
                    msg.space_id = active_space_id.clone();
                }

                if !msg.space_id.is_empty() {
                    state
                        .sync_state
                        .authorize_space(&msg.space_id, authenticated_peer.id())?;
                }

                // Terminator: empty StoreKeyValue (no spaceId + no key/value).
                if msg.space_id.is_empty()
                    && msg.key_peer_id.is_empty()
                    && msg.value.is_empty()
                    && msg.identity_signature.is_empty()
                    && msg.peer_signature.is_empty()
                {
                    break;
                }

                // Initial "spaceId only" message: no-op, but keeps active space.
                if msg.key_peer_id.is_empty() {
                    continue;
                }

                if msg.space_id.is_empty() {
                    bail!("missing space id for StoreElements");
                }

                if msg.value.is_empty() {
                    if let Some(entry) = state
                        .sync_state
                        .get_store_entry(&msg.space_id, &msg.key_peer_id)
                    {
                        tracing::info!(
                            "store: serve space_id={} key_peer_id={} value_len={}",
                            msg.space_id,
                            msg.key_peer_id,
                            entry.value.len()
                        );
                        write_frame(
                            stream,
                            stream_id,
                            &mut next_message_id,
                            super::codec::KIND_MESSAGE,
                            true,
                            bytes::Bytes::from(entry.encode_to_vec()),
                        )
                        .await?;
                    } else {
                        tracing::warn!(
                            "store: missing entry space_id={} key_peer_id={}",
                            msg.space_id,
                            msg.key_peer_id
                        );
                    }
                } else {
                    tracing::info!(
                        "store: upsert space_id={} key_peer_id={} value_len={}",
                        msg.space_id,
                        msg.key_peer_id,
                        msg.value.len()
                    );
                    state.sync_state.upsert_store_entry(msg)?;
                }
            }

            // Always terminate the response stream with an empty StoreKeyValue.
            write_frame(
                stream,
                stream_id,
                &mut next_message_id,
                super::codec::KIND_MESSAGE,
                true,
                bytes::Bytes::from(StoreKeyValue::default().encode_to_vec()),
            )
            .await?;

            write_close_send(stream, stream_id, &mut next_message_id).await?;
            write_close(stream, stream_id, &mut next_message_id).await
        }
        "/spacesync.SpaceSync/ObjectSync" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = sync_node::handle_object_sync_message(
                &request_bytes,
                &state.sync_state,
                authenticated_peer,
            )?;
            write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes).await
        }
        "/spacesync.SpaceSync/ObjectSyncStream" => {
            // Bidirectional stream: read messages in a loop until the
            // client signals close. For each message, process it and
            // send back a confirmation.
            loop {
                let frame = match stream.read_frame().await {
                    Ok(Some(frame)) => frame,
                    Ok(None) => break,
                    Err(error) if is_benign_disconnect(&error) => break,
                    Err(error) => return Err(error),
                };

                if frame.kind == KIND_CLOSE_SEND {
                    break;
                }

                // Accumulate message data (handle multi-frame messages)
                let msg_bytes = if frame.done {
                    frame.data.to_vec()
                } else {
                    // For multi-frame messages, collect until done
                    let mut buf = frame.data.to_vec();
                    loop {
                        let next = stream
                            .read_frame()
                            .await?
                            .ok_or_else(|| anyhow::anyhow!("connection closed mid-message"))?;
                        buf.extend_from_slice(&next.data);
                        if next.done {
                            break;
                        }
                    }
                    buf
                };

                let response_bytes = sync_node::handle_object_sync_message(
                    &msg_bytes,
                    &state.sync_state,
                    authenticated_peer,
                )?;
                // Official Anytype clients treat server->client stream messages
                // as semantic updates, not per-message acks. Avoid sending
                // empty responses for push-style requests, but still respond
                // to SpaceSubscription control messages (objectId empty).
                let should_write = match ObjectSyncMessage::decode(response_bytes.as_slice()) {
                    Ok(msg) => !msg.payload.is_empty() || msg.object_id.is_empty(),
                    Err(_) => true,
                };
                if should_write {
                    write_frame(
                        stream,
                        stream_id,
                        &mut next_message_id,
                        super::codec::KIND_MESSAGE,
                        true,
                        bytes::Bytes::from(response_bytes),
                    )
                    .await?;
                }
            }

            // Send close-send to signal we're done
            write_close_send(stream, stream_id, &mut next_message_id).await?;
            write_close(stream, stream_id, &mut next_message_id).await
        }
        "/spacesync.SpaceSync/ObjectSyncRequestStream" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = sync_node::handle_object_sync_message(
                &request_bytes,
                &state.sync_state,
                authenticated_peer,
            )?;
            if let Some(error_message) = object_sync_error_message(&response_bytes) {
                write_error_response(stream, stream_id, &mut next_message_id, &error_message)
                    .await?;
                bail!("{error_message}");
            }
            write_response(stream, stream_id, &mut next_message_id, &response_bytes).await?;
            write_close_send(stream, stream_id, &mut next_message_id).await?;
            write_close(stream, stream_id, &mut next_message_id).await
        }
        "/spacesync.SpaceSync/AclAddRecord" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = coordinator::handle_acl_add_record(
                &request_bytes,
                &state.sync_state,
                &state.local_signing_key,
                authenticated_peer,
            )?;
            write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes).await
        }
        "/spacesync.SpaceSync/AclGetRecords" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = coordinator::handle_acl_get_records(
                &request_bytes,
                &state.sync_state,
                authenticated_peer,
            )?;
            write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes).await
        }
        "/spacesync.SpaceSync/SpacePush" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = sync_node::handle_space_push(
                &request_bytes,
                &state.sync_state,
                &state.coordinator_config,
                &state.local_signing_key,
                authenticated_peer,
            )?;
            write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes).await
        }
        "/spacesync.SpaceSync/SpacePull" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = sync_node::handle_space_pull(
                &request_bytes,
                &state.sync_state,
                authenticated_peer,
            )?;
            write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes).await
        }
        "/consensusProto.Consensus/LogAdd" => {
            let request_bytes = stream.read_message().await?;
            let request =
                manytype_proto::consensus::LogAddRequest::decode(request_bytes.as_slice())?;
            state
                .sync_state
                .authorize_space(&request.log_id, authenticated_peer.id())?;
            if consensus::has_persisted_space_linked_log(&request.log_id, &state.sync_state) {
                anyhow::bail!("consensus log already exists");
            }
            let response_bytes = consensus::handle_log_add(&request_bytes)?;
            consensus::persist_space_linked_log_add(&request, &state.sync_state)?;
            write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes).await
        }
        "/consensusProto.Consensus/RecordAdd" => {
            let request_bytes = stream.read_message().await?;
            let request =
                manytype_proto::consensus::RecordAddRequest::decode(request_bytes.as_slice())?;
            state
                .sync_state
                .authorize_space(&request.log_id, authenticated_peer.id())?;
            consensus::ensure_log_exists_from_sync_state(&request.log_id, &state.sync_state);
            let response_bytes =
                consensus::handle_record_add(&request_bytes, &state.local_signing_key)?;
            let raw_with_id =
                manytype_proto::consensus::RawRecordWithId::decode(response_bytes.as_slice())?;
            consensus::persist_space_linked_record_add(
                &request.log_id,
                response_bytes.as_slice(),
                &raw_with_id.id,
                &state.sync_state,
            )?;
            write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes).await
        }
        "/filesync.File/BlocksCheck" => {
            let request_bytes = stream.read_message().await?;
            match file_node::handle_blocks_check(
                &request_bytes,
                &state.file_node,
                &state.sync_state,
                authenticated_peer,
            ) {
                Ok(response_bytes) => {
                    write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes)
                        .await
                }
                Err(error) => {
                    write_error_response(
                        stream,
                        stream_id,
                        &mut next_message_id,
                        &error.to_string(),
                    )
                    .await?;
                    bail!("{error}");
                }
            }
        }
        "/filesync.File/BlockGet" => {
            let request_bytes = stream.read_message().await?;
            match file_node::handle_block_get(
                &request_bytes,
                &state.file_node,
                &state.sync_state,
                authenticated_peer,
            ) {
                Ok(response_bytes) => {
                    write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes)
                        .await
                }
                Err(error) => {
                    write_error_response(
                        stream,
                        stream_id,
                        &mut next_message_id,
                        &error.to_string(),
                    )
                    .await?;
                    bail!("{error}");
                }
            }
        }
        "/filesync.File/BlockPush" => {
            let request_bytes = stream.read_message().await?;
            match file_node::handle_block_push(
                &request_bytes,
                &state.file_node,
                &state.sync_state,
                authenticated_peer,
            ) {
                Ok(response_bytes) => {
                    write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes)
                        .await
                }
                Err(error) => {
                    write_error_response(
                        stream,
                        stream_id,
                        &mut next_message_id,
                        &error.to_string(),
                    )
                    .await?;
                    bail!("{error}");
                }
            }
        }
        "/filesync.File/BlockPushMany" => {
            let request_bytes = stream.read_message().await?;
            match file_node::handle_block_push_many(
                &request_bytes,
                &state.file_node,
                &state.sync_state,
                authenticated_peer,
            ) {
                Ok(response_bytes) => {
                    write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes)
                        .await
                }
                Err(error) => {
                    write_error_response(
                        stream,
                        stream_id,
                        &mut next_message_id,
                        &error.to_string(),
                    )
                    .await?;
                    bail!("{error}");
                }
            }
        }
        "/filesync.File/BlocksBind" => {
            let request_bytes = stream.read_message().await?;
            match file_node::handle_blocks_bind(
                &request_bytes,
                &state.file_node,
                &state.sync_state,
                authenticated_peer,
            ) {
                Ok(response_bytes) => {
                    write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes)
                        .await
                }
                Err(error) => {
                    write_error_response(
                        stream,
                        stream_id,
                        &mut next_message_id,
                        &error.to_string(),
                    )
                    .await?;
                    bail!("{error}");
                }
            }
        }
        "/filesync.File/Check" => {
            let request_bytes = stream.read_message().await?;
            match file_node::handle_check(&request_bytes, &state.sync_state, authenticated_peer) {
                Ok(response_bytes) => {
                    write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes)
                        .await
                }
                Err(error) => {
                    write_error_response(
                        stream,
                        stream_id,
                        &mut next_message_id,
                        &error.to_string(),
                    )
                    .await?;
                    bail!("{error}");
                }
            }
        }
        "/filesync.File/FilesDelete" => {
            let request_bytes = stream.read_message().await?;
            match file_node::handle_files_delete(
                &request_bytes,
                &state.file_node,
                &state.sync_state,
                authenticated_peer,
            ) {
                Ok(response_bytes) => {
                    write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes)
                        .await
                }
                Err(error) => {
                    write_error_response(
                        stream,
                        stream_id,
                        &mut next_message_id,
                        &error.to_string(),
                    )
                    .await?;
                    bail!("{error}");
                }
            }
        }
        "/filesync.File/SpaceInfo" => {
            let request_bytes = stream.read_message().await?;
            match file_node::handle_space_info(
                &request_bytes,
                &state.file_node,
                &state.sync_state,
                authenticated_peer,
            ) {
                Ok(response_bytes) => {
                    write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes)
                        .await
                }
                Err(error) => {
                    write_error_response(
                        stream,
                        stream_id,
                        &mut next_message_id,
                        &error.to_string(),
                    )
                    .await?;
                    bail!("{error}");
                }
            }
        }
        "/filesync.File/AccountInfo" => {
            let request_bytes = stream.read_message().await?;
            match file_node::handle_account_info(
                &request_bytes,
                &state.file_node,
                &state.sync_state,
                authenticated_peer,
            ) {
                Ok(response_bytes) => {
                    write_unary_response(stream, stream_id, &mut next_message_id, &response_bytes)
                        .await
                }
                Err(error) => {
                    write_error_response(
                        stream,
                        stream_id,
                        &mut next_message_id,
                        &error.to_string(),
                    )
                    .await?;
                    bail!("{error}");
                }
            }
        }
        "/coordinator.Coordinator/NotifySubscribe" => {
            let _request_bytes = stream.read_message().await?;
            loop {
                let Some(frame) = stream.read_frame().await? else {
                    break;
                };
                if matches!(
                    frame.kind,
                    super::codec::KIND_CLOSE | super::codec::KIND_CANCEL
                ) {
                    break;
                }
            }
            Ok(())
        }
        unknown => {
            tracing::warn!("drpc: unknown method: {unknown}");
            stream
                .write_error(
                    stream_id,
                    next_message_id,
                    &format!("unknown method: {unknown}"),
                )
                .await?;
            bail!("unknown method: {unknown}");
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::auth::AuthenticatedPeer;
    use bytes::Bytes;
    use prost::Message;
    use std::sync::atomic::{AtomicU64, Ordering};
    use std::time::{SystemTime, UNIX_EPOCH};
    use tokio::io::duplex;

    use crate::drpc::codec::{DrpcFrame, KIND_ERROR, KIND_MESSAGE};
    use ed25519_dalek::Signer;
    use manytype_core::crdt::cid::compute_cid;
    use manytype_core::crypto::ed25519;
    use manytype_proto::crypto::{Key, KeyType};
    use manytype_proto::spacesync::{StoreKeyInner, StoreKeyValue};

    static NEXT_TEST_STATE_ID: AtomicU64 = AtomicU64::new(0);

    fn test_peer() -> AuthenticatedPeer<'static> {
        let account_identity = ed25519::signing_key_from_seed(&[2; 32])
            .verifying_key()
            .to_bytes();
        AuthenticatedPeer::for_test_with_account("peer", account_identity)
    }

    fn valid_space_header(seed: u8) -> (String, Vec<u8>, Vec<u8>) {
        use manytype_proto::spacesync::{RawSpaceHeader, SpaceHeader};

        let account_key = ed25519::signing_key_from_seed(&[seed; 32]);
        let account_identity = Key {
            r#type: KeyType::Ed25519Public as i32,
            data: account_key.verifying_key().to_bytes().to_vec(),
        }
        .encode_to_vec();
        let header_bytes = SpaceHeader {
            identity: account_identity.clone(),
            replication_key: 42,
            ..Default::default()
        }
        .encode_to_vec();
        let raw_header = RawSpaceHeader {
            signature: account_key.sign(&header_bytes).to_bytes().to_vec(),
            space_header: header_bytes,
        }
        .encode_to_vec();
        let space_id = format!("{}.16", compute_cid(&raw_header));
        (space_id, raw_header, account_identity)
    }

    fn test_state() -> ServerState {
        let nonce = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default()
            .as_nanos();
        let sequence = NEXT_TEST_STATE_ID.fetch_add(1, Ordering::Relaxed);
        let sync_state = sync_node::new_shared_sync_state();
        sync_state
            .upsert_space_metadata(
                "space-1",
                Some(vec![1]),
                None,
                None,
                None,
                None,
                Some(false),
                Some("peer".to_string()),
            )
            .unwrap();
        ServerState {
            coordinator_config: CoordinatorConfig {
                network_id: "test-net".to_string(),
                peer_id: "test-peer".to_string(),
                addresses: vec!["127.0.0.1:4830".to_string()],
            },
            sync_state,
            file_node: file_node::FileNodeState::open(std::env::temp_dir().join(format!(
                "manytype-file-node-router-{}-{nonce}-{sequence}.redb",
                std::process::id()
            )))
            .unwrap(),
            local_signing_key: ed25519::signing_key_from_seed(&[1u8; 32]),
        }
    }

    fn make_store_entry(space_id: &str, key_peer_id: &str, timestamp_micro: i64) -> StoreKeyValue {
        StoreKeyValue {
            key_peer_id: key_peer_id.to_string(),
            value: StoreKeyInner {
                peer: vec![1; 32],
                identity: vec![2; 32],
                value: vec![3; 32],
                timestamp_micro,
                acl_head_id: "acl-head".to_string(),
                key: key_peer_id.to_string(),
            }
            .encode_to_vec(),
            identity_signature: vec![4; 64],
            peer_signature: vec![5; 64],
            space_id: space_id.to_string(),
        }
    }

    #[tokio::test]
    async fn test_unknown_method_returns_error() {
        let (client, server) = duplex(1024);
        let mut server_stream = DrpcStream::new(server);
        let mut client_stream = DrpcStream::new(client);

        let state = test_state();

        // Spawn dispatch for an unknown method
        let handle = tokio::spawn(async move {
            let result = dispatch(
                1,
                "/unknown.Service/Method",
                &mut server_stream,
                &state,
                &test_peer(),
            )
            .await;
            assert!(result.is_err());
            let err_msg = result.unwrap_err().to_string();
            assert!(
                err_msg.contains("unknown method"),
                "error should mention unknown method, got: {err_msg}"
            );
        });

        // Client side: read the error frame that dispatch sends
        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_ERROR);
        let error_text = String::from_utf8(frame.data.to_vec()).unwrap();
        assert!(
            error_text.contains("unknown method"),
            "error frame should contain 'unknown method', got: {error_text}"
        );

        handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_filesync_check_returns_response() {
        use manytype_proto::filesync::{CheckRequest, CheckResponse};

        let (client, server) = duplex(1024);
        let mut server_stream = DrpcStream::new(server);
        let mut client_stream = DrpcStream::new(client);
        let state = test_state();

        let handle = tokio::spawn(async move {
            dispatch(
                1,
                "/filesync.File/Check",
                &mut server_stream,
                &state,
                &test_peer(),
            )
            .await
            .unwrap();
        });

        client_stream
            .write_message(1, 1, &CheckRequest {}.encode_to_vec())
            .await
            .unwrap();
        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_MESSAGE);
        let response = CheckResponse::decode(frame.data.as_ref()).unwrap();
        assert!(response.allow_write);

        handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_filesync_space_info_returns_response() {
        use manytype_proto::filesync::{SpaceInfoRequest, SpaceInfoResponse};

        let (client, server) = duplex(1024);
        let mut server_stream = DrpcStream::new(server);
        let mut client_stream = DrpcStream::new(client);
        let state = test_state();

        let handle = tokio::spawn(async move {
            dispatch(
                1,
                "/filesync.File/SpaceInfo",
                &mut server_stream,
                &state,
                &test_peer(),
            )
            .await
            .unwrap();
        });

        client_stream
            .write_message(
                1,
                1,
                &SpaceInfoRequest {
                    space_id: "space-1".to_string(),
                }
                .encode_to_vec(),
            )
            .await
            .unwrap();
        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_MESSAGE);
        let response = SpaceInfoResponse::decode(frame.data.as_ref()).unwrap();
        assert_eq!(response.space_id, "space-1");

        handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_object_sync_request_stream_returns_message() {
        use manytype_proto::spacesync::ObjectSyncMessage;

        let (client, server) = duplex(4096);
        let mut server_stream = DrpcStream::new(server);
        let mut client_stream = DrpcStream::new(client);
        let state = test_state();

        let handle = tokio::spawn(async move {
            dispatch(
                1,
                "/spacesync.SpaceSync/ObjectSyncRequestStream",
                &mut server_stream,
                &state,
                &test_peer(),
            )
            .await
            .unwrap();
        });

        let request = ObjectSyncMessage {
            space_id: "space-1".to_string(),
            object_id: "obj-1".to_string(),
            request_id: "req-1".to_string(),
            payload: vec![1, 2, 3],
            ..Default::default()
        };
        client_stream
            .write_message(1, 1, &request.encode_to_vec())
            .await
            .unwrap();

        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_MESSAGE);
        let response = ObjectSyncMessage::decode(frame.data.as_ref()).unwrap();
        assert_eq!(response.reply_id, "req-1");

        handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_object_sync_request_stream_returns_error_for_missing_tree() {
        use manytype_proto::spacesync::ObjectSyncMessage;
        use manytype_proto::treechange::{
            self, TreeFullSyncRequest, TreeSyncContentValue, TreeSyncMessage,
        };

        let (client, server) = duplex(4096);
        let mut server_stream = DrpcStream::new(server);
        let mut client_stream = DrpcStream::new(client);
        let state = test_state();

        let handle = tokio::spawn(async move {
            let result = dispatch(
                1,
                "/spacesync.SpaceSync/ObjectSyncRequestStream",
                &mut server_stream,
                &state,
                &test_peer(),
            )
            .await;
            assert!(result.is_err());
            assert!(result.unwrap_err().to_string().contains("tree not found"));
        });

        let request = ObjectSyncMessage {
            space_id: "space-1".to_string(),
            object_id: "missing-obj".to_string(),
            request_id: "req-404".to_string(),
            payload: TreeSyncMessage {
                content: Some(TreeSyncContentValue {
                    value: Some(treechange::tree_sync_content_value::Value::FullSyncRequest(
                        TreeFullSyncRequest {
                            heads: vec!["head-1".to_string()],
                            ..Default::default()
                        },
                    )),
                }),
                ..Default::default()
            }
            .encode_to_vec(),
            ..Default::default()
        };
        client_stream
            .write_message(1, 1, &request.encode_to_vec())
            .await
            .unwrap();

        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_ERROR);
        let error_text = String::from_utf8(frame.data.to_vec()).unwrap();
        assert!(error_text.contains("tree not found"));

        handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_dispatch_network_configuration() {
        use manytype_proto::coordinator::{
            NetworkConfigurationRequest, NetworkConfigurationResponse,
        };

        let (client, server) = duplex(4096);
        let mut server_stream = DrpcStream::new(server);
        let mut client_stream = DrpcStream::new(client);

        let state = test_state();

        // Spawn dispatch handler
        let handle = tokio::spawn(async move {
            dispatch(
                1,
                "/coordinator.Coordinator/NetworkConfiguration",
                &mut server_stream,
                &state,
                &test_peer(),
            )
            .await
            .unwrap();
        });

        // Client sends the request as a message frame
        let request = NetworkConfigurationRequest::default();
        let request_bytes = request.encode_to_vec();
        client_stream
            .write_message(0, 0, &request_bytes)
            .await
            .unwrap();

        // Read the response message frame
        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_MESSAGE);
        assert!(frame.done);
        assert_eq!(frame.stream_id, 1);
        assert_eq!(frame.message_id, 1);

        let response = NetworkConfigurationResponse::decode(frame.data.as_ref()).unwrap();
        assert_eq!(response.network_id, "test-net");
        assert!(!response.nodes.is_empty());
        assert_eq!(response.nodes[0].peer_id, "test-peer");

        let close_frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(close_frame.kind, KIND_CLOSE_SEND);
        assert_eq!(close_frame.stream_id, 1);
        assert_eq!(close_frame.message_id, 2);

        handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_dispatch_head_sync() {
        use manytype_proto::spacesync::{HeadSyncRequest, HeadSyncResponse};

        let (client, server) = duplex(4096);
        let mut server_stream = DrpcStream::new(server);
        let mut client_stream = DrpcStream::new(client);

        let state = test_state();

        let handle = tokio::spawn(async move {
            dispatch(
                1,
                "/spacesync.SpaceSync/HeadSync",
                &mut server_stream,
                &state,
                &test_peer(),
            )
            .await
            .unwrap();
        });

        let request = HeadSyncRequest {
            space_id: "space-1".to_string(),
            ..Default::default()
        };
        client_stream
            .write_message(0, 0, &request.encode_to_vec())
            .await
            .unwrap();

        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_MESSAGE);
        assert!(frame.done);
        assert_eq!(frame.stream_id, 1);
        assert_eq!(frame.message_id, 1);
        let response = HeadSyncResponse::decode(frame.data.as_ref()).unwrap();
        // A registered space with no object heads returns one empty range.
        assert_eq!(response.results.len(), 1);
        assert!(response.results[0].elements.is_empty());

        let close_frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(close_frame.kind, KIND_CLOSE_SEND);
        assert_eq!(close_frame.stream_id, 1);
        assert_eq!(close_frame.message_id, 2);

        handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_dispatch_space_push() {
        use manytype_proto::spacesync::{
            RawSpaceHeaderWithId, SpacePayload, SpacePushRequest, SpacePushResponse,
        };

        let (client, server) = duplex(4096);
        let mut server_stream = DrpcStream::new(server);
        let mut client_stream = DrpcStream::new(client);

        let state = test_state();
        let (space_id, raw_header, account_identity) = valid_space_header(2);
        state
            .sync_state
            .claim_space_owner(&space_id, test_peer().id())
            .unwrap();
        let credential = coordinator::build_signed_space_receipt(
            &space_id,
            test_peer().id(),
            &account_identity,
            &state.coordinator_config,
            &state.local_signing_key,
        )
        .unwrap()
        .encode_to_vec();

        let handle = tokio::spawn(async move {
            dispatch(
                1,
                "/spacesync.SpaceSync/SpacePush",
                &mut server_stream,
                &state,
                &test_peer(),
            )
            .await
            .unwrap();
        });
        let request = SpacePushRequest {
            payload: Some(SpacePayload {
                space_header: Some(RawSpaceHeaderWithId {
                    raw_header,
                    id: space_id,
                }),
                ..Default::default()
            }),
            credential,
        };
        client_stream
            .write_message(0, 0, &request.encode_to_vec())
            .await
            .unwrap();

        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_MESSAGE);
        assert!(frame.done);
        assert_eq!(frame.stream_id, 1);
        assert_eq!(frame.message_id, 1);
        let _response = SpacePushResponse::decode(frame.data.as_ref()).unwrap();

        let close_frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(close_frame.kind, KIND_CLOSE_SEND);
        assert_eq!(close_frame.stream_id, 1);
        assert_eq!(close_frame.message_id, 2);

        handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_dispatch_object_sync_stream() {
        use manytype_proto::spacesync::{ObjectSyncMessage, SpaceSubscription};

        let (client, server) = duplex(4096);
        let mut server_stream = DrpcStream::new(server);
        let mut client_stream = DrpcStream::new(client);

        let state = test_state();
        state
            .sync_state
            .claim_space_owner("sp-1", test_peer().id())
            .unwrap();

        let handle = tokio::spawn(async move {
            dispatch(
                1,
                "/spacesync.SpaceSync/ObjectSyncStream",
                &mut server_stream,
                &state,
                &test_peer(),
            )
            .await
            .unwrap();
        });

        // Official any-sync clients open ObjectSyncStream with a
        // SpaceSubscription control message (empty object_id). The server
        // always acks these regardless of payload contents.
        let subscription_msg = ObjectSyncMessage {
            space_id: "sp-1".to_string(),
            object_id: String::new(),
            request_id: "req-1".to_string(),
            payload: SpaceSubscription {
                space_ids: vec!["sp-1".to_string()],
                ..Default::default()
            }
            .encode_to_vec(),
            ..Default::default()
        };
        client_stream
            .write_message(0, 0, &subscription_msg.encode_to_vec())
            .await
            .unwrap();

        // Read the subscription ack (non-final -- stream continues)
        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_MESSAGE);
        assert_eq!(frame.stream_id, 1);
        assert_eq!(frame.message_id, 1);
        let response = ObjectSyncMessage::decode(frame.data.as_ref()).unwrap();
        assert_eq!(response.space_id, "sp-1");
        assert_eq!(response.reply_id, "req-1");

        // A per-object push-style message with a payload the server can't
        // interpret as a recognized tree message produces no ack: official
        // clients treat these as semantic updates, not per-message acks
        // (see handle_object_sync_message's should_write comment above).
        // Send it followed directly by close-send; the server's close-send
        // response is the first frame we expect back.
        let push_msg = ObjectSyncMessage {
            space_id: "sp-1".to_string(),
            object_id: "obj-1".to_string(),
            request_id: "req-2".to_string(),
            payload: b"change-data".to_vec(),
            ..Default::default()
        };
        client_stream
            .write_message(0, 0, &push_msg.encode_to_vec())
            .await
            .unwrap();

        // Send close-send to end the stream
        client_stream
            .write_frame(DrpcFrame {
                kind: KIND_CLOSE_SEND,
                done: true,
                control: false,
                stream_id: 0,
                message_id: 0,
                data: Bytes::new(),
            })
            .await
            .unwrap();

        // Read server's close-send response
        let close_frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(close_frame.kind, KIND_CLOSE_SEND);
        assert_eq!(close_frame.stream_id, 1);
        assert_eq!(close_frame.message_id, 2);

        handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_dispatch_store_diff() {
        use manytype_proto::spacesync::{StoreDiffRequest, StoreDiffResponse};

        let (client, server) = duplex(4096);
        let mut server_stream = DrpcStream::new(server);
        let mut client_stream = DrpcStream::new(client);

        let state = test_state();
        state
            .sync_state
            .claim_space_owner("sp-1", test_peer().id())
            .unwrap();
        state
            .sync_state
            .upsert_store_entry(make_store_entry("sp-1", "settings-peer-1", 10))
            .unwrap();

        let handle = tokio::spawn(async move {
            dispatch(
                1,
                "/spacesync.SpaceSync/StoreDiff",
                &mut server_stream,
                &state,
                &test_peer(),
            )
            .await
            .unwrap();
        });

        let request = StoreDiffRequest {
            space_id: "sp-1".to_string(),
            ..Default::default()
        };
        client_stream
            .write_message(0, 0, &request.encode_to_vec())
            .await
            .unwrap();

        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_MESSAGE);
        assert_eq!(frame.stream_id, 1);
        assert_eq!(frame.message_id, 1);
        let response = StoreDiffResponse::decode(frame.data.as_ref()).unwrap();
        assert_eq!(response.results.len(), 1);
        assert_eq!(response.results[0].elements[0].id, "settings-peer-1");

        let close_frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(close_frame.kind, KIND_CLOSE_SEND);
        assert_eq!(close_frame.stream_id, 1);
        assert_eq!(close_frame.message_id, 2);

        handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_dispatch_store_elements() {
        let (client, server) = duplex(4096);
        let mut server_stream = DrpcStream::new(server);
        let mut client_stream = DrpcStream::new(client);

        let state = test_state();
        state
            .sync_state
            .claim_space_owner("sp-1", test_peer().id())
            .unwrap();
        state
            .sync_state
            .upsert_store_entry(make_store_entry("sp-1", "settings-peer-1", 10))
            .unwrap();

        let handle = tokio::spawn(async move {
            dispatch(
                1,
                "/spacesync.SpaceSync/StoreElements",
                &mut server_stream,
                &state,
                &test_peer(),
            )
            .await
            .unwrap();
        });

        for message in [
            StoreKeyValue {
                space_id: "sp-1".to_string(),
                ..Default::default()
            },
            StoreKeyValue {
                key_peer_id: "settings-peer-1".to_string(),
                ..Default::default()
            },
            StoreKeyValue::default(),
        ] {
            client_stream
                .write_message(0, 0, &message.encode_to_vec())
                .await
                .unwrap();
        }
        client_stream
            .write_frame(DrpcFrame {
                kind: KIND_CLOSE_SEND,
                done: true,
                control: false,
                stream_id: 0,
                message_id: 0,
                data: Bytes::new(),
            })
            .await
            .unwrap();

        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_MESSAGE);
        assert_eq!(frame.stream_id, 1);
        assert_eq!(frame.message_id, 1);
        let response = StoreKeyValue::decode(frame.data.as_ref()).unwrap();
        assert_eq!(response.key_peer_id, "settings-peer-1");

        let terminator = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(terminator.kind, KIND_MESSAGE);
        assert_eq!(terminator.stream_id, 1);
        assert_eq!(terminator.message_id, 2);
        let terminator_msg = StoreKeyValue::decode(terminator.data.as_ref()).unwrap();
        assert!(terminator_msg.key_peer_id.is_empty());

        let close_frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(close_frame.kind, KIND_CLOSE_SEND);
        assert_eq!(close_frame.stream_id, 1);
        assert_eq!(close_frame.message_id, 3);

        handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_dispatch_log_add() {
        use manytype_proto::consensus::{LogAddRequest, Ok as ConsensusOk};

        let (client, server) = duplex(4096);
        let mut server_stream = DrpcStream::new(server);
        let mut client_stream = DrpcStream::new(client);

        let state = test_state();
        state
            .sync_state
            .claim_space_owner("router-test-log-add", test_peer().id())
            .unwrap();

        let handle = tokio::spawn(async move {
            dispatch(
                1,
                "/consensusProto.Consensus/LogAdd",
                &mut server_stream,
                &state,
                &test_peer(),
            )
            .await
            .unwrap();
        });

        let request = LogAddRequest {
            log_id: "router-test-log-add".to_string(),
            record: Some(manytype_proto::consensus::RawRecordWithId {
                payload: b"root".to_vec(),
                id: compute_cid(b"root"),
            }),
        };
        client_stream
            .write_message(0, 0, &request.encode_to_vec())
            .await
            .unwrap();

        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_MESSAGE);
        assert!(frame.done);
        assert_eq!(frame.stream_id, 1);
        assert_eq!(frame.message_id, 1);
        let _ok = ConsensusOk::decode(frame.data.as_ref()).unwrap();

        let close_frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(close_frame.kind, KIND_CLOSE_SEND);
        assert_eq!(close_frame.stream_id, 1);
        assert_eq!(close_frame.message_id, 2);

        handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_dispatch_block_push() {
        use manytype_core::crdt::cid::cid_string_to_bytes;
        use manytype_proto::filesync::{BlockPushRequest, Ok as FilesyncOk};

        let (client, server) = duplex(4096);
        let mut server_stream = DrpcStream::new(server);
        let mut client_stream = DrpcStream::new(client);

        let state = test_state();
        state
            .sync_state
            .claim_space_owner("sp1", test_peer().id())
            .unwrap();
        state
            .sync_state
            .upsert_space_metadata(
                "sp1",
                Some(vec![1]),
                None,
                None,
                None,
                None,
                Some(false),
                None,
            )
            .unwrap();

        let handle = tokio::spawn(async move {
            dispatch(
                1,
                "/filesync.File/BlockPush",
                &mut server_stream,
                &state,
                &test_peer(),
            )
            .await
            .unwrap();
        });

        let payload = b"data".to_vec();
        let request = BlockPushRequest {
            space_id: "sp1".to_string(),
            file_id: "f1".to_string(),
            cid: cid_string_to_bytes(&compute_cid(&payload)).unwrap(),
            data: payload,
        };
        client_stream
            .write_message(0, 0, &request.encode_to_vec())
            .await
            .unwrap();

        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_MESSAGE);
        assert!(frame.done);
        assert_eq!(frame.stream_id, 1);
        assert_eq!(frame.message_id, 1);
        let _ok = FilesyncOk::decode(frame.data.as_ref()).unwrap();

        let close_frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(close_frame.kind, KIND_CLOSE_SEND);
        assert_eq!(close_frame.stream_id, 1);
        assert_eq!(close_frame.message_id, 2);

        handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_dispatch_block_get_missing_returns_error_frame() {
        use manytype_core::crdt::cid::cid_string_to_bytes;
        use manytype_proto::filesync::BlockGetRequest;

        let (client, server) = duplex(4096);
        let mut server_stream = DrpcStream::new(server);
        let mut client_stream = DrpcStream::new(client);

        let state = test_state();

        let handle = tokio::spawn(async move {
            let result = dispatch(
                1,
                "/filesync.File/BlockGet",
                &mut server_stream,
                &state,
                &test_peer(),
            )
            .await;
            assert!(result.is_err());
            assert!(result.unwrap_err().to_string().contains("CIDNotFound"));
        });

        let request = BlockGetRequest {
            space_id: "space-1".to_string(),
            cid: cid_string_to_bytes(&compute_cid(b"missing")).unwrap(),
            wait: false,
        };
        client_stream
            .write_message(0, 0, &request.encode_to_vec())
            .await
            .unwrap();

        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_ERROR);
        let error_text = String::from_utf8(frame.data.to_vec()).unwrap();
        assert!(error_text.contains("CIDNotFound"));

        handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_integration_space_push_then_head_sync() {
        use manytype_proto::spacesync::{
            HeadSyncRequest, HeadSyncResponse, RawSpaceHeaderWithId, SpacePayload,
            SpacePushRequest, SpacePushResponse,
        };

        let sync_state = sync_node::new_shared_sync_state();
        let (space_id, raw_header, account_identity) = valid_space_header(2);
        sync_state
            .claim_space_owner(&space_id, test_peer().id())
            .unwrap();

        // Step 1: SpacePush
        {
            let (client, server) = duplex(4096);
            let mut server_stream = DrpcStream::new(server);
            let mut client_stream = DrpcStream::new(client);

            let state = ServerState {
                coordinator_config: CoordinatorConfig {
                    network_id: "test".to_string(),
                    peer_id: "p".to_string(),
                    addresses: vec![],
                },
                sync_state: sync_state.clone(),
                file_node: file_node::FileNodeState::open(std::env::temp_dir().join(format!(
                    "manytype-file-node-int-{}-1.redb",
                    SystemTime::now()
                        .duration_since(UNIX_EPOCH)
                        .unwrap_or_default()
                        .as_nanos()
                )))
                .unwrap(),
                local_signing_key: ed25519::signing_key_from_seed(&[1u8; 32]),
            };

            let handle = tokio::spawn(async move {
                dispatch(
                    1,
                    "/spacesync.SpaceSync/SpacePush",
                    &mut server_stream,
                    &state,
                    &test_peer(),
                )
                .await
                .unwrap();
            });

            let credential = coordinator::build_signed_space_receipt(
                &space_id,
                test_peer().id(),
                &account_identity,
                &CoordinatorConfig {
                    network_id: "test".to_string(),
                    peer_id: "p".to_string(),
                    addresses: vec![],
                },
                &ed25519::signing_key_from_seed(&[1u8; 32]),
            )
            .unwrap()
            .encode_to_vec();
            let request = SpacePushRequest {
                payload: Some(SpacePayload {
                    space_header: Some(RawSpaceHeaderWithId {
                        raw_header,
                        id: space_id.clone(),
                    }),
                    ..Default::default()
                }),
                credential,
            };
            client_stream
                .write_message(0, 0, &request.encode_to_vec())
                .await
                .unwrap();
            let frame = client_stream.read_frame().await.unwrap().unwrap();
            let _resp = SpacePushResponse::decode(frame.data.as_ref()).unwrap();
            handle.await.unwrap();
        }

        // Step 2: HeadSync should see the space
        {
            let (client, server) = duplex(4096);
            let mut server_stream = DrpcStream::new(server);
            let mut client_stream = DrpcStream::new(client);

            let state = ServerState {
                coordinator_config: CoordinatorConfig {
                    network_id: "test".to_string(),
                    peer_id: "p".to_string(),
                    addresses: vec![],
                },
                sync_state: sync_state.clone(),
                file_node: file_node::FileNodeState::open(std::env::temp_dir().join(format!(
                    "manytype-file-node-int-{}-2.redb",
                    SystemTime::now()
                        .duration_since(UNIX_EPOCH)
                        .unwrap_or_default()
                        .as_nanos()
                )))
                .unwrap(),
                local_signing_key: ed25519::signing_key_from_seed(&[1u8; 32]),
            };

            let handle = tokio::spawn(async move {
                dispatch(
                    1,
                    "/spacesync.SpaceSync/HeadSync",
                    &mut server_stream,
                    &state,
                    &test_peer(),
                )
                .await
                .unwrap();
            });

            let request = HeadSyncRequest {
                space_id,
                ..Default::default()
            };
            client_stream
                .write_message(0, 0, &request.encode_to_vec())
                .await
                .unwrap();
            let frame = client_stream.read_frame().await.unwrap().unwrap();
            let response = HeadSyncResponse::decode(frame.data.as_ref()).unwrap();
            assert!(
                !response.results.is_empty(),
                "HeadSync should find the pushed space"
            );
            handle.await.unwrap();
        }
    }
}
