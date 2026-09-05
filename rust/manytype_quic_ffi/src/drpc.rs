//! Client-side DRPC operations: invoke, sync_object, and request_object.
//!
//! Uses `DrpcStream` and codec types from `manytype_server::drpc`.

use anyhow::{Context, Result};
use bytes::Bytes;
use tokio::io::{AsyncRead, AsyncWrite};
use tokio::time::{Duration, timeout};

use manytype_server::drpc::codec::{
    DrpcFrame, KIND_CLOSE, KIND_CLOSE_SEND, KIND_ERROR, KIND_INVOKE, KIND_MESSAGE,
};
use manytype_server::drpc::stream::DrpcStream;

const STREAM_ID: u64 = 1;
const EMPTY_UNARY_RESPONSE_TIMEOUT: Duration = Duration::from_secs(2);
const MAX_STREAM_RESPONSE_BYTES: usize = 64 * 1024 * 1024;

fn trace(message: impl FnOnce() -> String) {
    if std::env::var_os("MANYTYPE_QUIC_TRACE").is_some() {
        eprintln!("[manytype_quic_ffi::drpc] {}", message());
    }
}

/// Invoke a unary RPC: send INVOKE+MESSAGE, then read the server response.
///
/// Most Any-Sync unary handlers reply with a MESSAGE frame, including empty
/// protobuf bodies encoded as a zero-length MESSAGE. Some official-node paths
/// close the send side without emitting a MESSAGE body for empty responses.
/// Treat that CLOSE_SEND-or-EOF case as a successful empty payload so unary
/// helpers like SpacePush do not hang waiting for a body that never arrives.
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
    // message -> client closes the stream. In practice, some official-node
    // handlers with empty protobuf responses either terminate with CLOSE_SEND
    // and no MESSAGE or never emit a body frame at all after accepting the
    // request. Accept either shape for the known empty-response methods.
    let allow_empty_timeout = matches!(
        method,
        "/spacesync.SpaceSync/SpacePush" | "/coordinator.Coordinator/SpaceMakeShareable"
    );

    let first_frame = if allow_empty_timeout {
        match timeout(EMPTY_UNARY_RESPONSE_TIMEOUT, drpc_stream.read_frame()).await {
            Ok(result) => result.context("failed to read unary response frame")?,
            Err(_) => {
                trace(|| {
                    format!(
                        "invoke empty-response timeout method={method} timeout_ms={}",
                        EMPTY_UNARY_RESPONSE_TIMEOUT.as_millis()
                    )
                });
                return Ok(Vec::new());
            }
        }
    } else {
        drpc_stream
            .read_frame()
            .await
            .context("failed to read unary response frame")?
    };

    let (response, saw_message) = match first_frame {
        Some(frame) => match frame.kind {
            KIND_MESSAGE => {
                let response = drpc_stream
                    .read_message_after_first(frame)
                    .await
                    .context("failed to read unary response message")?;
                (response, true)
            }
            KIND_CLOSE_SEND | KIND_CLOSE => (Vec::new(), false),
            KIND_ERROR => {
                anyhow::bail!("remote error: {}", String::from_utf8_lossy(&frame.data));
            }
            other => {
                anyhow::bail!("unexpected frame kind={other} while reading unary response");
            }
        },
        None => (Vec::new(), false),
    };
    trace(|| {
        format!(
            "invoke read response method={method} response_len={}",
            response.len()
        )
    });
    trace(|| format!("invoke response shape method={method} saw_message={saw_message}"));

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
/// Official Any-Sync/ObjectSyncStream handlers process the request stream only
/// after the client half-closes with KIND_CLOSE_SEND. Waiting for responses
/// before sending CLOSE_SEND can leave the stream in a limbo state where the
/// server never commits the pushed object changes.
///
/// Returns the collected response payloads.
pub async fn sync_object<T>(
    drpc_stream: &mut DrpcStream<T>,
    changes: &[Vec<u8>],
) -> Result<Vec<Vec<u8>>>
where
    T: AsyncRead + AsyncWrite + Unpin,
{
    exchange_stream(
        drpc_stream,
        "/spacesync.SpaceSync/ObjectSyncStream",
        changes,
    )
    .await
}

/// Request an object via ObjectSyncRequestStream and collect streamed replies.
///
/// Official Any-Sync nodes use ObjectSyncRequestStream for authoritative
/// full-tree responses after a single request message. We still half-close the
/// client send side after that request so the exchange follows the same DRPC
/// lifecycle as the bidirectional helper.
pub async fn request_object<T>(
    drpc_stream: &mut DrpcStream<T>,
    request: &[u8],
) -> Result<Vec<Vec<u8>>>
where
    T: AsyncRead + AsyncWrite + Unpin,
{
    exchange_stream(
        drpc_stream,
        "/spacesync.SpaceSync/ObjectSyncRequestStream",
        &[request.to_vec()],
    )
    .await
}

/// Exchange protobuf messages over an arbitrary bidirectional DRPC stream.
///
/// Sends all request messages, closes the client send side, then collects all
/// server messages until the server closes the stream. A message may span
/// several MESSAGE frames; it is complete once a frame has done=true.
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
    let mut response_bytes = 0usize;
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

        if frame.kind == KIND_CLOSE_SEND || frame.kind == KIND_CLOSE {
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
        let message = drpc_stream
            .read_message_after_first(frame)
            .await
            .context("failed to read stream message")?;
        response_bytes = response_bytes
            .saturating_add(message.len())
            .saturating_add(std::mem::size_of::<u32>());
        anyhow::ensure!(
            response_bytes <= MAX_STREAM_RESPONSE_BYTES,
            "stream responses exceed {MAX_STREAM_RESPONSE_BYTES} byte limit"
        );
        responses.push(message);
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
    async fn test_invoke_empty_response_via_close_send() {
        let (client_io, server_io) = duplex(8192);
        let mut client_stream = DrpcStream::new(client_io);
        let mut server_stream = DrpcStream::new(server_io);

        let server_handle = tokio::spawn(async move {
            let (_, method) = server_stream.read_invoke().await.unwrap();
            assert_eq!(method, "/test.Svc/Empty");

            let msg = server_stream.read_message().await.unwrap();
            assert_eq!(msg, b"test-request");

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

        let response = invoke(&mut client_stream, "/test.Svc/Empty", b"test-request")
            .await
            .unwrap();
        assert!(response.is_empty());

        server_handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_invoke_rejects_response_over_message_limit() {
        let (client_io, server_io) = duplex(8192);
        let mut client_stream = DrpcStream::with_limits(client_io, 1024, 8);
        let mut server_stream = DrpcStream::new(server_io);

        let server_handle = tokio::spawn(async move {
            server_stream.read_invoke().await.unwrap();
            server_stream.read_message().await.unwrap();
            for (chunk, done) in [(&b"12345"[..], false), (&b"6789"[..], true)] {
                server_stream
                    .write_frame(DrpcFrame {
                        kind: KIND_MESSAGE,
                        done,
                        control: false,
                        stream_id: 1,
                        message_id: 1,
                        data: Bytes::copy_from_slice(chunk),
                    })
                    .await
                    .unwrap();
            }
        });

        let error = invoke(&mut client_stream, "/test.Svc/Large", b"request")
            .await
            .unwrap_err();
        assert!(format!("{error:#}").contains("8 byte limit"));

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

                // Send confirmation
                server_stream
                    .write_frame(DrpcFrame {
                        kind: KIND_MESSAGE,
                        done: true,
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
    async fn test_exchange_stream_reassembles_split_messages() {
        let (client_io, server_io) = duplex(8192);
        let mut client_stream = DrpcStream::new(client_io);
        let mut server_stream = DrpcStream::new(server_io);

        let server_handle = tokio::spawn(async move {
            let (_, method) = server_stream.read_invoke().await.unwrap();
            assert_eq!(method, "/spacesync.SpaceSync/StoreElements");

            let request = server_stream.read_message().await.unwrap();
            assert_eq!(request, b"request");

            let close_frame = server_stream.read_frame().await.unwrap().unwrap();
            assert_eq!(close_frame.kind, KIND_CLOSE_SEND);

            for (message_id, chunk, done) in [
                (1, &b"first-"[..], false),
                (1, &b"message-"[..], false),
                (1, &b"body"[..], true),
                (2, &b"second"[..], true),
            ] {
                server_stream
                    .write_frame(DrpcFrame {
                        kind: KIND_MESSAGE,
                        done,
                        control: false,
                        stream_id: 1,
                        message_id,
                        data: Bytes::copy_from_slice(chunk),
                    })
                    .await
                    .unwrap();
            }
            server_stream
                .write_frame(DrpcFrame {
                    kind: KIND_CLOSE_SEND,
                    done: true,
                    control: false,
                    stream_id: 1,
                    message_id: 3,
                    data: Bytes::new(),
                })
                .await
                .unwrap();
        });

        let responses = exchange_stream(
            &mut client_stream,
            "/spacesync.SpaceSync/StoreElements",
            &[b"request".to_vec()],
        )
        .await
        .unwrap();
        assert_eq!(
            responses,
            vec![b"first-message-body".to_vec(), b"second".to_vec()]
        );

        server_handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_exchange_stream_rejects_responses_over_total_limit() {
        let (client_io, server_io) = duplex(1024 * 1024);
        let mut client_stream = DrpcStream::new(client_io);
        let mut server_stream = DrpcStream::new(server_io);

        let server_handle = tokio::spawn(async move {
            server_stream.read_invoke().await.unwrap();
            server_stream.read_frame().await.unwrap().unwrap();

            let chunk = Bytes::from(vec![0u8; 2 * 1024 * 1024]);
            for message_id in 1..=9 {
                for part in 0..4 {
                    let written = server_stream
                        .write_frame(DrpcFrame {
                            kind: KIND_MESSAGE,
                            done: part == 3,
                            control: false,
                            stream_id: 1,
                            message_id,
                            data: chunk.clone(),
                        })
                        .await;
                    if written.is_err() {
                        return;
                    }
                }
            }
        });

        let error = exchange_stream(
            &mut client_stream,
            "/spacesync.SpaceSync/StoreElements",
            &[],
        )
        .await
        .unwrap_err();
        assert!(error.to_string().contains("stream responses exceed"));

        drop(client_stream);
        server_handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_sync_object_waits_until_after_close_send_for_server_frames() {
        let (client_io, server_io) = duplex(8192);
        let mut client_stream = DrpcStream::new(client_io);
        let mut server_stream = DrpcStream::new(server_io);

        let changes = vec![b"change-1".to_vec()];

        let server_handle = tokio::spawn(async move {
            let (_, method) = server_stream.read_invoke().await.unwrap();
            assert_eq!(method, "/spacesync.SpaceSync/ObjectSyncStream");

            let frame = server_stream.read_frame().await.unwrap().unwrap();
            assert_eq!(frame.kind, KIND_MESSAGE);
            assert_eq!(frame.data.as_ref(), b"change-1");

            let close_frame = server_stream.read_frame().await.unwrap().unwrap();
            assert_eq!(close_frame.kind, KIND_CLOSE_SEND);

            server_stream
                .write_frame(DrpcFrame {
                    kind: KIND_MESSAGE,
                    done: true,
                    control: false,
                    stream_id: 0,
                    message_id: 0,
                    data: Bytes::copy_from_slice(b"ack-after-close-send"),
                })
                .await
                .unwrap();
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

        let responses = sync_object(&mut client_stream, &changes).await.unwrap();
        assert_eq!(responses, vec![b"ack-after-close-send".to_vec()]);

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

    #[tokio::test]
    async fn test_request_object_round_trip() {
        let (client_io, server_io) = duplex(8192);
        let mut client_stream = DrpcStream::new(client_io);
        let mut server_stream = DrpcStream::new(server_io);

        let server_handle = tokio::spawn(async move {
            let (_, method) = server_stream.read_invoke().await.unwrap();
            assert_eq!(method, "/spacesync.SpaceSync/ObjectSyncRequestStream");

            let request = server_stream.read_message().await.unwrap();
            assert_eq!(request, b"pull-request");

            let close_frame = server_stream.read_frame().await.unwrap().unwrap();
            assert_eq!(close_frame.kind, KIND_CLOSE_SEND);

            server_stream
                .write_frame(DrpcFrame {
                    kind: KIND_MESSAGE,
                    done: true,
                    control: false,
                    stream_id: 0,
                    message_id: 0,
                    data: Bytes::copy_from_slice(b"pull-response"),
                })
                .await
                .unwrap();
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

        let responses = request_object(&mut client_stream, b"pull-request")
            .await
            .unwrap();
        assert_eq!(responses, vec![b"pull-response".to_vec()]);

        server_handle.await.unwrap();
    }
}
