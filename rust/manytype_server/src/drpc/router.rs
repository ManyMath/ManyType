//! DRPC method router -- dispatches incoming RPC calls to handler functions.

use anyhow::{Result, bail};
use prost::Message;
use tokio::io::{AsyncRead, AsyncWrite};

use super::codec::KIND_CLOSE_SEND;
use super::stream::DrpcStream;
use crate::consensus;
use crate::coordinator::{self, CoordinatorConfig};
use crate::file_node;
use crate::sync_node::{self, SharedSyncState};

/// Shared server state passed to all RPC handlers.
///
/// Contains all subsystems needed by the various RPC handlers.
pub struct ServerState {
    pub coordinator_config: CoordinatorConfig,
    pub sync_state: SharedSyncState,
}

/// Dispatch an RPC call to the appropriate handler based on method path.
///
/// The caller should have already read the invoke frame to obtain the
/// method path and stream_id. This function matches the method and
/// invokes the corresponding handler.
pub async fn dispatch<T>(
    method: &str,
    stream: &mut DrpcStream<T>,
    state: &ServerState,
) -> Result<()>
where
    T: AsyncRead + AsyncWrite + Unpin,
{
    match method {
        "/coordinator.Coordinator/NetworkConfiguration" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = coordinator::handle_network_configuration(
                &request_bytes,
                &state.coordinator_config,
            )?;
            stream.write_message(0, 0, &response_bytes).await
        }
        "/spacesync.SpaceSync/HeadSync" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes =
                sync_node::handle_head_sync(&request_bytes, &state.sync_state)?;
            stream.write_message(0, 0, &response_bytes).await
        }
        "/spacesync.SpaceSync/ObjectSyncStream" => {
            // Bidirectional stream: read messages in a loop until the
            // client signals close. For each message, process it and
            // send back a confirmation.
            loop {
                let frame = match stream.read_frame().await? {
                    Some(f) => f,
                    None => break, // connection closed
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

                let response_bytes =
                    sync_node::handle_object_sync_message(&msg_bytes, &state.sync_state)?;
                // Write response as non-final message (stream continues)
                stream.write_frame(super::codec::DrpcFrame {
                    kind: super::codec::KIND_MESSAGE,
                    done: false,
                    control: false,
                    stream_id: 0,
                    message_id: 0,
                    data: bytes::Bytes::from(response_bytes),
                }).await?;
            }

            // Send close-send to signal we're done
            stream.write_frame(super::codec::DrpcFrame {
                kind: KIND_CLOSE_SEND,
                done: true,
                control: false,
                stream_id: 0,
                message_id: 0,
                data: bytes::Bytes::new(),
            }).await
        }
        "/spacesync.SpaceSync/SpacePush" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes =
                sync_node::handle_space_push(&request_bytes, &state.sync_state)?;
            stream.write_message(0, 0, &response_bytes).await
        }
        "/consensusProto.Consensus/LogAdd" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = consensus::handle_log_add(&request_bytes)?;
            stream.write_message(0, 0, &response_bytes).await
        }
        "/consensusProto.Consensus/RecordAdd" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = consensus::handle_record_add(&request_bytes)?;
            stream.write_message(0, 0, &response_bytes).await
        }
        "/filesync.File/BlockPush" => {
            let request_bytes = stream.read_message().await?;
            let response_bytes = file_node::handle_block_push(&request_bytes)?;
            stream.write_message(0, 0, &response_bytes).await
        }
        unknown => {
            stream
                .write_error(0, &format!("unknown method: {unknown}"))
                .await?;
            bail!("unknown method: {unknown}");
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use bytes::Bytes;
    use tokio::io::duplex;

    use crate::drpc::codec::{DrpcFrame, KIND_ERROR, KIND_INVOKE, KIND_MESSAGE};

    fn test_state() -> ServerState {
        ServerState {
            coordinator_config: CoordinatorConfig {
                network_id: "test-net".to_string(),
                peer_id: "test-peer".to_string(),
                addresses: vec!["127.0.0.1:4830".to_string()],
            },
            sync_state: sync_node::new_shared_sync_state(),
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
            let result = dispatch("/unknown.Service/Method", &mut server_stream, &state).await;
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
                "/coordinator.Coordinator/NetworkConfiguration",
                &mut server_stream,
                &state,
            )
            .await
            .unwrap();
        });

        // Client sends the request as a message frame
        let request = NetworkConfigurationRequest::default();
        let request_bytes = request.encode_to_vec();
        client_stream.write_message(0, 0, &request_bytes).await.unwrap();

        // Read the response message frame
        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_MESSAGE);
        assert!(frame.done);

        let response =
            NetworkConfigurationResponse::decode(frame.data.as_ref()).unwrap();
        assert_eq!(response.network_id, "test-net");
        assert!(!response.nodes.is_empty());
        assert_eq!(response.nodes[0].peer_id, "test-peer");

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
                "/spacesync.SpaceSync/HeadSync",
                &mut server_stream,
                &state,
            )
            .await
            .unwrap();
        });

        let request = HeadSyncRequest {
            space_id: "test-space".to_string(),
            ..Default::default()
        };
        client_stream
            .write_message(0, 0, &request.encode_to_vec())
            .await
            .unwrap();

        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_MESSAGE);
        assert!(frame.done);
        let response = HeadSyncResponse::decode(frame.data.as_ref()).unwrap();
        // Unknown space should return empty results
        assert!(response.results.is_empty());

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

        let handle = tokio::spawn(async move {
            dispatch(
                "/spacesync.SpaceSync/SpacePush",
                &mut server_stream,
                &state,
            )
            .await
            .unwrap();
        });

        let request = SpacePushRequest {
            payload: Some(SpacePayload {
                space_header: Some(RawSpaceHeaderWithId {
                    raw_header: b"header".to_vec(),
                    id: "sp-1".to_string(),
                }),
                ..Default::default()
            }),
            ..Default::default()
        };
        client_stream
            .write_message(0, 0, &request.encode_to_vec())
            .await
            .unwrap();

        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_MESSAGE);
        assert!(frame.done);
        let _response = SpacePushResponse::decode(frame.data.as_ref()).unwrap();

        handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_dispatch_object_sync_stream() {
        use manytype_proto::spacesync::ObjectSyncMessage;

        let (client, server) = duplex(4096);
        let mut server_stream = DrpcStream::new(server);
        let mut client_stream = DrpcStream::new(client);

        let state = test_state();

        let handle = tokio::spawn(async move {
            dispatch(
                "/spacesync.SpaceSync/ObjectSyncStream",
                &mut server_stream,
                &state,
            )
            .await
            .unwrap();
        });

        // Send one ObjectSyncMessage as a message frame (done=true per message)
        let msg = ObjectSyncMessage {
            space_id: "sp-1".to_string(),
            object_id: "obj-1".to_string(),
            request_id: "req-1".to_string(),
            payload: b"change-data".to_vec(),
            ..Default::default()
        };
        client_stream
            .write_message(0, 0, &msg.encode_to_vec())
            .await
            .unwrap();

        // Read the confirmation response (non-final -- stream continues)
        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_MESSAGE);
        let response = ObjectSyncMessage::decode(frame.data.as_ref()).unwrap();
        assert_eq!(response.space_id, "sp-1");
        assert_eq!(response.object_id, "obj-1");
        assert_eq!(response.reply_id, "req-1");

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

        handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_dispatch_log_add() {
        use manytype_proto::consensus::{LogAddRequest, Ok as ConsensusOk};

        let (client, server) = duplex(4096);
        let mut server_stream = DrpcStream::new(server);
        let mut client_stream = DrpcStream::new(client);

        let state = test_state();

        let handle = tokio::spawn(async move {
            dispatch(
                "/consensusProto.Consensus/LogAdd",
                &mut server_stream,
                &state,
            )
            .await
            .unwrap();
        });

        let request = LogAddRequest {
            log_id: "test-log".to_string(),
            ..Default::default()
        };
        client_stream
            .write_message(0, 0, &request.encode_to_vec())
            .await
            .unwrap();

        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_MESSAGE);
        assert!(frame.done);
        let _ok = ConsensusOk::decode(frame.data.as_ref()).unwrap();

        handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_dispatch_block_push() {
        use manytype_proto::filesync::{BlockPushRequest, Ok as FilesyncOk};

        let (client, server) = duplex(4096);
        let mut server_stream = DrpcStream::new(server);
        let mut client_stream = DrpcStream::new(client);

        let state = test_state();

        let handle = tokio::spawn(async move {
            dispatch(
                "/filesync.File/BlockPush",
                &mut server_stream,
                &state,
            )
            .await
            .unwrap();
        });

        let request = BlockPushRequest {
            space_id: "sp1".to_string(),
            file_id: "f1".to_string(),
            data: b"data".to_vec(),
            ..Default::default()
        };
        client_stream
            .write_message(0, 0, &request.encode_to_vec())
            .await
            .unwrap();

        let frame = client_stream.read_frame().await.unwrap().unwrap();
        assert_eq!(frame.kind, KIND_MESSAGE);
        assert!(frame.done);
        let _ok = FilesyncOk::decode(frame.data.as_ref()).unwrap();

        handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_integration_space_push_then_head_sync() {
        use manytype_proto::spacesync::{
            HeadSyncRequest, HeadSyncResponse, RawSpaceHeaderWithId,
            SpacePayload, SpacePushRequest, SpacePushResponse,
        };

        let sync_state = sync_node::new_shared_sync_state();

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
            };

            let handle = tokio::spawn(async move {
                dispatch("/spacesync.SpaceSync/SpacePush", &mut server_stream, &state)
                    .await
                    .unwrap();
            });

            let request = SpacePushRequest {
                payload: Some(SpacePayload {
                    space_header: Some(RawSpaceHeaderWithId {
                        raw_header: b"hdr".to_vec(),
                        id: "integration-space".to_string(),
                    }),
                    ..Default::default()
                }),
                ..Default::default()
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
            };

            let handle = tokio::spawn(async move {
                dispatch("/spacesync.SpaceSync/HeadSync", &mut server_stream, &state)
                    .await
                    .unwrap();
            });

            let request = HeadSyncRequest {
                space_id: "integration-space".to_string(),
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
