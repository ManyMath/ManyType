//! DRPC method router -- dispatches incoming RPC calls to handler functions.

use anyhow::{Result, bail};
use tokio::io::{AsyncRead, AsyncWrite};

use super::stream::DrpcStream;

/// Shared server state passed to all RPC handlers.
///
/// Placeholder struct -- will be populated with storage, config, etc.
/// in later plans (03-02 through 03-05).
pub struct ServerState {}

/// Dispatch an RPC call to the appropriate handler based on method path.
///
/// The caller should have already read the invoke frame to obtain the
/// method path and stream_id. This function matches the method and
/// invokes the corresponding handler stub.
pub async fn dispatch<T>(
    method: &str,
    stream: &mut DrpcStream<T>,
    _state: &ServerState,
) -> Result<()>
where
    T: AsyncRead + AsyncWrite + Unpin,
{
    match method {
        "/coordinator.Coordinator/NetworkConfiguration" => {
            handle_network_configuration(stream).await
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

async fn handle_network_configuration<T: AsyncRead + AsyncWrite + Unpin>(
    _stream: &mut DrpcStream<T>,
) -> Result<()> {
    todo!("NetworkConfiguration handler -- implemented in plan 03-02")
}

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

    use crate::drpc::codec::{DrpcFrame, KIND_ERROR, KIND_INVOKE};

    #[tokio::test]
    async fn test_unknown_method_returns_error() {
        let (client, server) = duplex(1024);
        let mut server_stream = DrpcStream::new(server);
        let mut client_stream = DrpcStream::new(client);

        let state = ServerState {};

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
    async fn test_dispatch_known_method_hits_stub() {
        let (client, server) = duplex(1024);
        let mut server_stream = DrpcStream::new(server);
        let state = ServerState {};

        // Known method should hit todo!() -- we catch the panic
        let result = tokio::spawn(async move {
            dispatch(
                "/coordinator.Coordinator/NetworkConfiguration",
                &mut server_stream,
                &state,
            )
            .await
        })
        .await;

        // The task should panic due to todo!()
        assert!(result.is_err(), "known method stub should panic with todo!()");
    }
}
