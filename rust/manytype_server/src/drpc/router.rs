//! DRPC method router -- dispatches incoming RPC calls to handler functions.

use anyhow::{Result, bail};
use prost::Message;
use tokio::io::{AsyncRead, AsyncWrite};

use super::stream::DrpcStream;
use crate::coordinator::{self, CoordinatorConfig};

/// Shared server state passed to all RPC handlers.
///
/// Extended as new handler modules are wired in.
pub struct ServerState {
    pub coordinator_config: CoordinatorConfig,
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
            handle_head_sync(stream).await
        }
        "/spacesync.SpaceSync/ObjectSyncStream" => {
            handle_object_sync_stream(stream).await
        }
        "/spacesync.SpaceSync/SpacePush" => {
            handle_space_push(stream).await
        }
        "/consensusProto.Consensus/LogAdd" => {
            handle_log_add(stream).await
        }
        "/consensusProto.Consensus/RecordAdd" => {
            handle_record_add(stream).await
        }
        "/filesync.File/BlockPush" => {
            handle_block_push(stream).await
        }
        unknown => {
            stream
                .write_error(0, &format!("unknown method: {unknown}"))
                .await?;
            bail!("unknown method: {unknown}");
        }
    }
}

// --- Handler stubs (implemented in later plans) ---

async fn handle_head_sync<T: AsyncRead + AsyncWrite + Unpin>(
    _stream: &mut DrpcStream<T>,
) -> Result<()> {
    todo!("HeadSync handler -- implemented in plan 03-03")
}

async fn handle_object_sync_stream<T: AsyncRead + AsyncWrite + Unpin>(
    _stream: &mut DrpcStream<T>,
) -> Result<()> {
    todo!("ObjectSyncStream handler -- implemented in plan 03-03")
}

async fn handle_space_push<T: AsyncRead + AsyncWrite + Unpin>(
    _stream: &mut DrpcStream<T>,
) -> Result<()> {
    todo!("SpacePush handler -- implemented in plan 03-03")
}

async fn handle_log_add<T: AsyncRead + AsyncWrite + Unpin>(
    _stream: &mut DrpcStream<T>,
) -> Result<()> {
    todo!("LogAdd handler -- implemented in plan 03-04")
}

async fn handle_record_add<T: AsyncRead + AsyncWrite + Unpin>(
    _stream: &mut DrpcStream<T>,
) -> Result<()> {
    todo!("RecordAdd handler -- implemented in plan 03-04")
}

async fn handle_block_push<T: AsyncRead + AsyncWrite + Unpin>(
    _stream: &mut DrpcStream<T>,
) -> Result<()> {
    todo!("BlockPush handler -- implemented in plan 03-05")
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
}
