//! Client-side DRPC operations: invoke and sync_object.
//!
//! Uses `DrpcStream` and codec types from `manytype_server::drpc`.

use anyhow::{Context, Result};
use bytes::Bytes;
use tokio::io::{AsyncRead, AsyncWrite};

use manytype_server::drpc::codec::{
    DrpcFrame, KIND_CLOSE, KIND_CLOSE_SEND, KIND_ERROR, KIND_INVOKE, KIND_MESSAGE,
};
use manytype_server::drpc::stream::DrpcStream;

const STREAM_ID: u64 = 1;

fn trace(message: impl FnOnce() -> String) {
    if std::env::var_os("MANYTYPE_QUIC_TRACE").is_some() {
        eprintln!("[manytype_quic_ffi::drpc] {}", message());
    }
}

/// Invoke a unary RPC: send INVOKE+MESSAGE, read response MESSAGE.
pub async fn invoke<T>(
    drpc_stream: &mut DrpcStream<T>,
    method: &str,
    request_bytes: &[u8],
) -> Result<Vec<u8>>
where
    T: AsyncRead + AsyncWrite + Unpin,
{
    trace(|| {
        format!(
            "invoke start method={method} request_len={}",
            request_bytes.len()
        )
    });

    // Write INVOKE frame with method path
    drpc_stream
        .write_frame(DrpcFrame {
            kind: KIND_INVOKE,
            done: true,
            control: false,
            stream_id: STREAM_ID,
            message_id: 1,
            data: Bytes::copy_from_slice(method.as_bytes()),
        })
        .await
        .context("failed to write invoke frame")?;
    trace(|| format!("invoke wrote KIND_INVOKE method={method}"));

    // Write MESSAGE frame with request payload
    drpc_stream
        .write_message(STREAM_ID, 2, request_bytes)
        .await
        .context("failed to write request message")?;
    trace(|| format!("invoke wrote KIND_MESSAGE method={method}"));

    drpc_stream
        .write_frame(DrpcFrame {
            kind: KIND_CLOSE_SEND,
            done: true,
            control: false,
            stream_id: STREAM_ID,
            message_id: 3,
            data: Bytes::new(),
        })
        .await
        .context("failed to write request close-send")?;
    trace(|| format!("invoke wrote KIND_CLOSE_SEND method={method}"));

    // Official dRPC unary semantics are: request message -> CloseSend -> response
    // message -> client closes the stream. Do not block waiting for a server
    // CloseSend here; the official coordinator returns the message body and expects
    // the client to close the stream afterward.
    let response = drpc_stream
        .read_message()
        .await
        .context("failed to read response message")?;
    trace(|| {
        format!(
            "invoke read response method={method} response_len={}",
            response.len()
        )
    });

    if let Err(err) = drpc_stream
        .write_frame(DrpcFrame {
            kind: KIND_CLOSE,
            done: true,
            control: false,
            stream_id: STREAM_ID,
            message_id: 4,
            data: Bytes::new(),
        })
        .await
    {
        trace(|| format!("invoke close ignored method={method} error={err:#}"));
    } else {
        trace(|| format!("invoke wrote KIND_CLOSE method={method}"));
    }

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
            done: true,
            control: false,
            stream_id: STREAM_ID,
            message_id: 1,
            data: Bytes::from_static(b"/spacesync.SpaceSync/ObjectSyncStream"),
        })
        .await
        .context("failed to write invoke frame for ObjectSyncStream")?;

    let mut responses = Vec::with_capacity(changes.len());

    for (i, change) in changes.iter().enumerate() {
        // Write each change as a MESSAGE frame (done=true, self-contained)
        drpc_stream
            .write_message(STREAM_ID, (i as u64) + 2, change)
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
            anyhow::bail!("expected MESSAGE confirmation, got kind={}", frame.kind);
        }
    }

    // Send KIND_CLOSE_SEND to terminate the stream
    drpc_stream
        .write_frame(DrpcFrame {
            kind: KIND_CLOSE_SEND,
            done: true,
            control: false,
            stream_id: STREAM_ID,
            message_id: (changes.len() as u64) + 2,
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

/// Exchange protobuf messages over an arbitrary bidirectional DRPC stream.
///
/// Sends all request messages, closes the client send side, then collects all
/// server MESSAGE frames until the server closes the stream.
pub async fn exchange_stream<T>(
    drpc_stream: &mut DrpcStream<T>,
    method: &str,
    messages: &[Vec<u8>],
) -> Result<Vec<Vec<u8>>>
where
    T: AsyncRead + AsyncWrite + Unpin,
{
    trace(|| {
        format!(
            "exchange_stream start method={method} message_count={}",
            messages.len()
        )
    });
    drpc_stream
        .write_frame(DrpcFrame {
            kind: KIND_INVOKE,
            done: true,
            control: false,
            stream_id: STREAM_ID,
            message_id: 1,
            data: Bytes::copy_from_slice(method.as_bytes()),
        })
        .await
        .context("failed to write invoke frame for bidirectional stream")?;
    trace(|| format!("exchange_stream wrote KIND_INVOKE method={method}"));

    for (index, message) in messages.iter().enumerate() {
        drpc_stream
            .write_message(STREAM_ID, (index as u64) + 2, message)
            .await
            .context("failed to write stream message")?;
        trace(|| {
            format!(
                "exchange_stream wrote KIND_MESSAGE method={method} message_index={} message_len={}",
                index,
                message.len()
            )
        });
    }

    drpc_stream
        .write_frame(DrpcFrame {
            kind: KIND_CLOSE_SEND,
            done: true,
            control: false,
            stream_id: STREAM_ID,
            message_id: (messages.len() as u64) + 2,
            data: Bytes::new(),
        })
        .await
        .context("failed to write close-send")?;
    trace(|| format!("exchange_stream wrote KIND_CLOSE_SEND method={method}"));

    let mut responses = Vec::new();
    loop {
        let frame = drpc_stream
            .read_frame()
            .await
            .context("failed to read stream frame")?
            .context("connection closed before server close-send")?;
        trace(|| {
            format!(
                "exchange_stream read frame method={method} kind={} done={} message_len={}",
                frame.kind,
                frame.done,
                frame.data.len()
            )
        });

        if frame.kind == KIND_CLOSE_SEND {
            break;
        }

        if frame.kind == KIND_ERROR {
            anyhow::bail!(
                "remote stream error: {}",
                String::from_utf8_lossy(frame.data.as_ref())
            );
        }

        anyhow::ensure!(
            frame.kind == KIND_MESSAGE,
            "expected MESSAGE or CLOSE_SEND from server, got kind={}",
            frame.kind
        );
        responses.push(frame.data.to_vec());
    }

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
                .write_message(1, 1, b"test-response")
                .await
                .unwrap();
            server_stream
                .write_frame(DrpcFrame {
                    kind: KIND_CLOSE_SEND,
                    done: true,
                    control: false,
                    stream_id: 1,
                    message_id: 2,
                    data: Bytes::new(),
                })
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
