//! Client-side DRPC operations: invoke and sync_object.
//!
//! Uses `DrpcStream` and codec types from `manytype_server::drpc`.

use anyhow::{Context, Result};
use bytes::Bytes;
use tokio::io::{AsyncRead, AsyncWrite};

use manytype_server::drpc::codec::{DrpcFrame, KIND_CLOSE_SEND, KIND_INVOKE, KIND_MESSAGE};
use manytype_server::drpc::stream::DrpcStream;

/// Invoke a unary RPC: send INVOKE+MESSAGE, read response MESSAGE.
pub async fn invoke<T>(
    drpc_stream: &mut DrpcStream<T>,
    method: &str,
    request_bytes: &[u8],
) -> Result<Vec<u8>>
where
    T: AsyncRead + AsyncWrite + Unpin,
{
    // Write INVOKE frame with method path
    drpc_stream
        .write_frame(DrpcFrame {
            kind: KIND_INVOKE,
            done: false,
            control: false,
            stream_id: 0,
            message_id: 0,
            data: Bytes::copy_from_slice(method.as_bytes()),
        })
        .await
        .context("failed to write invoke frame")?;

    // Write MESSAGE frame with request payload
    drpc_stream
        .write_message(0, 0, request_bytes)
        .await
        .context("failed to write request message")?;

    // Read response message
    let response = drpc_stream
        .read_message()
        .await
        .context("failed to read response message")?;

    Ok(response)
}

/// Sync an object by sending changes via ObjectSyncStream bidirectional RPC.
///
/// Each change is sent as a MESSAGE frame. The server responds with a
/// confirmation for each. After all changes, send KIND_CLOSE_SEND and
/// read the server's KIND_CLOSE_SEND.
///
/// Returns the collected response payloads.
pub async fn sync_object<T>(
    drpc_stream: &mut DrpcStream<T>,
    changes: &[Vec<u8>],
) -> Result<Vec<Vec<u8>>>
where
    T: AsyncRead + AsyncWrite + Unpin,
{
    // Write INVOKE frame for ObjectSyncStream
    drpc_stream
        .write_frame(DrpcFrame {
            kind: KIND_INVOKE,
            done: false,
            control: false,
            stream_id: 0,
            message_id: 0,
            data: Bytes::from_static(b"/spacesync.SpaceSync/ObjectSyncStream"),
        })
        .await
        .context("failed to write invoke frame for ObjectSyncStream")?;

    let mut responses = Vec::with_capacity(changes.len());

    for (i, change) in changes.iter().enumerate() {
        // Write each change as a MESSAGE frame (done=true, self-contained)
        drpc_stream
            .write_message(0, i as u64, change)
            .await
            .context("failed to write change message")?;

        // Read confirmation from server (non-final message frame)
        let frame = drpc_stream
            .read_frame()
            .await
            .context("failed to read confirmation frame")?
            .context("connection closed while awaiting confirmation")?;

        if frame.kind == KIND_MESSAGE {
            responses.push(frame.data.to_vec());
        } else {
            anyhow::bail!(
                "expected MESSAGE confirmation, got kind={}",
                frame.kind
            );
        }
    }

    // Send KIND_CLOSE_SEND to terminate the stream
    drpc_stream
        .write_frame(DrpcFrame {
            kind: KIND_CLOSE_SEND,
            done: true,
            control: false,
            stream_id: 0,
            message_id: 0,
            data: Bytes::new(),
        })
        .await
        .context("failed to write close-send")?;

    // Read server's KIND_CLOSE_SEND
    let frame = drpc_stream
        .read_frame()
        .await
        .context("failed to read server close-send")?
        .context("connection closed before server close-send")?;

    anyhow::ensure!(
        frame.kind == KIND_CLOSE_SEND,
        "expected CLOSE_SEND from server, got kind={}",
        frame.kind
    );

    Ok(responses)
}

#[cfg(test)]
mod tests {
    use super::*;
    use manytype_server::drpc::codec::DrpcFrame;
    use tokio::io::duplex;

    #[tokio::test]
    async fn test_invoke_round_trip() {
        let (client_io, server_io) = duplex(8192);
        let mut client_stream = DrpcStream::new(client_io);
        let mut server_stream = DrpcStream::new(server_io);

        let request_data = b"test-request";
        let response_data = b"test-response";

        // Server side: read INVOKE, read MESSAGE, write MESSAGE response
        let server_handle = tokio::spawn(async move {
            // Read invoke frame
            let (_, method) = server_stream.read_invoke().await.unwrap();
            assert_eq!(method, "/test.Svc/Method");

            // Read request message
            let msg = server_stream.read_message().await.unwrap();
            assert_eq!(msg, b"test-request");

            // Write response
            server_stream
                .write_message(0, 0, b"test-response")
                .await
                .unwrap();
        });

        // Client side: invoke
        let response = invoke(&mut client_stream, "/test.Svc/Method", request_data)
            .await
            .unwrap();
        assert_eq!(response, response_data);

        server_handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_sync_object_round_trip() {
        let (client_io, server_io) = duplex(8192);
        let mut client_stream = DrpcStream::new(client_io);
        let mut server_stream = DrpcStream::new(server_io);

        let changes = vec![b"change-1".to_vec(), b"change-2".to_vec()];

        // Server side: mimics the ObjectSyncStream dispatch handler
        let server_handle = tokio::spawn(async move {
            // Read invoke frame
            let (_, method) = server_stream.read_invoke().await.unwrap();
            assert_eq!(method, "/spacesync.SpaceSync/ObjectSyncStream");

            // Read messages in a loop until CLOSE_SEND
            let mut received = Vec::new();
            loop {
                let frame = server_stream.read_frame().await.unwrap().unwrap();
                if frame.kind == KIND_CLOSE_SEND {
                    break;
                }
                assert_eq!(frame.kind, KIND_MESSAGE);
                received.push(frame.data.to_vec());

                // Send confirmation (non-final)
                server_stream
                    .write_frame(DrpcFrame {
                        kind: KIND_MESSAGE,
                        done: false,
                        control: false,
                        stream_id: 0,
                        message_id: 0,
                        data: Bytes::copy_from_slice(b"ack"),
                    })
                    .await
                    .unwrap();
            }

            // Send server's CLOSE_SEND
            server_stream
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

            assert_eq!(received.len(), 2);
            assert_eq!(received[0], b"change-1");
            assert_eq!(received[1], b"change-2");
        });

        // Client side: sync_object
        let responses = sync_object(&mut client_stream, &changes).await.unwrap();
        assert_eq!(responses.len(), 2);
        assert_eq!(responses[0], b"ack");
        assert_eq!(responses[1], b"ack");

        server_handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_sync_object_empty_changes() {
        let (client_io, server_io) = duplex(8192);
        let mut client_stream = DrpcStream::new(client_io);
        let mut server_stream = DrpcStream::new(server_io);

        // Server side: read invoke, immediately get CLOSE_SEND
        let server_handle = tokio::spawn(async move {
            let (_, method) = server_stream.read_invoke().await.unwrap();
            assert_eq!(method, "/spacesync.SpaceSync/ObjectSyncStream");

            // Should immediately get CLOSE_SEND (no changes)
            let frame = server_stream.read_frame().await.unwrap().unwrap();
            assert_eq!(frame.kind, KIND_CLOSE_SEND);

            // Send server's CLOSE_SEND
            server_stream
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
        });

        let responses = sync_object(&mut client_stream, &[]).await.unwrap();
        assert!(responses.is_empty());

        server_handle.await.unwrap();
    }
}
