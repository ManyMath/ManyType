//! DRPC stream abstraction for reading/writing typed messages.
//!
//! Wraps a `tokio_util::codec::Framed<T, DrpcCodec>` to provide
//! higher-level operations like `read_invoke`, `write_message`, etc.

use anyhow::{Context, Result, bail};
use bytes::Bytes;
use futures::{SinkExt, StreamExt};
use tokio::io::{AsyncRead, AsyncWrite};
use tokio_util::codec::Framed;

use crate::deadline::{self, DeadlineStage};

use super::codec::{
    DEFAULT_MAX_FRAME_BYTES, DrpcCodec, DrpcFrame, KIND_CANCEL, KIND_CLOSE, KIND_CLOSE_SEND,
    KIND_ERROR, KIND_INVOKE, KIND_INVOKE_METADATA, KIND_MESSAGE, marshal_error, unmarshal_error,
};

const DEFAULT_MAX_MESSAGE_BYTES: usize = 8 * 1024 * 1024;
const DEFAULT_IO_TIMEOUT: std::time::Duration = std::time::Duration::from_secs(30);
const MAX_METHOD_BYTES: usize = 1024;
/// drpc's default frame split size (`drpcwire.SplitData`).
const MAX_SPLIT_BYTES: usize = 64 * 1024;

/// A bidirectional DRPC stream over an async transport.
pub struct DrpcStream<T> {
    framed: Framed<T, DrpcCodec>,
    split_bytes: usize,
    max_message_bytes: usize,
    io_timeout: std::time::Duration,
}

impl<T> DrpcStream<T>
where
    T: AsyncRead + AsyncWrite + Unpin,
{
    /// Create a new DRPC stream wrapping the given IO transport.
    pub fn new(io: T) -> Self {
        Self::with_limits_and_timeout(
            io,
            DEFAULT_MAX_FRAME_BYTES,
            DEFAULT_MAX_MESSAGE_BYTES,
            DEFAULT_IO_TIMEOUT,
        )
    }

    pub fn with_limits(io: T, max_frame_bytes: usize, max_message_bytes: usize) -> Self {
        Self::with_limits_and_timeout(io, max_frame_bytes, max_message_bytes, DEFAULT_IO_TIMEOUT)
    }

    pub fn with_limits_and_timeout(
        io: T,
        max_frame_bytes: usize,
        max_message_bytes: usize,
        io_timeout: std::time::Duration,
    ) -> Self {
        Self {
            framed: Framed::new(io, DrpcCodec::with_max_frame_bytes(max_frame_bytes)),
            split_bytes: max_frame_bytes.min(MAX_SPLIT_BYTES),
            max_message_bytes,
            io_timeout,
        }
    }

    /// Read the next frame from the stream.
    pub async fn read_frame(&mut self) -> Result<Option<DrpcFrame>> {
        let next = deadline::value(
            DeadlineStage::StreamRead,
            self.io_timeout,
            self.framed.next(),
        )
        .await?;
        match next {
            Some(Ok(frame)) => Ok(Some(frame)),
            Some(Err(e)) => Err(e).context("failed to read DRPC frame"),
            None => Ok(None),
        }
    }

    /// Write a frame to the stream.
    pub async fn write_frame(&mut self, frame: DrpcFrame) -> Result<()> {
        deadline::result(DeadlineStage::StreamWrite, self.io_timeout, async {
            self.framed
                .send(frame)
                .await
                .context("failed to write DRPC frame")
        })
        .await
    }

    /// Read KIND_INVOKE frame, returning (stream_id, method_path).
    pub async fn read_invoke(&mut self) -> Result<(u64, String)> {
        let mut stream_id = None;

        let frame = loop {
            let frame = self
                .read_frame()
                .await?
                .context("connection closed before invoke")?;

            match frame.kind {
                KIND_INVOKE_METADATA => {
                    if let Some(expected_stream_id) = stream_id {
                        if frame.stream_id != expected_stream_id {
                            bail!(
                                "invoke metadata stream_id changed from {} to {}",
                                expected_stream_id,
                                frame.stream_id
                            );
                        }
                    } else {
                        stream_id = Some(frame.stream_id);
                    }
                    continue;
                }
                KIND_CLOSE | KIND_CLOSE_SEND | KIND_CANCEL => {
                    continue;
                }
                _ => {}
            }

            break frame;
        };

        if frame.kind != KIND_INVOKE {
            bail!("expected KIND_INVOKE frame, got kind={}", frame.kind);
        }

        let method = String::from_utf8(frame.data.to_vec())
            .context("invoke method path is not valid UTF-8")?;
        if method.len() > MAX_METHOD_BYTES {
            bail!("invoke method exceeds {MAX_METHOD_BYTES} byte limit");
        }

        Ok((frame.stream_id, method))
    }

    /// Read KIND_MESSAGE frames, collecting data until done=true.
    /// Returns the concatenated body bytes.
    pub async fn read_message(&mut self) -> Result<Vec<u8>> {
        let frame = self
            .read_frame()
            .await?
            .context("connection closed mid-message")?;
        self.read_message_after_first(frame).await
    }

    pub async fn read_message_after_first(&mut self, first: DrpcFrame) -> Result<Vec<u8>> {
        let stream_id = first.stream_id;
        let mut next = Some(first);
        let mut body = Vec::new();
        loop {
            let frame = match next.take() {
                Some(frame) => frame,
                None => self
                    .read_frame()
                    .await?
                    .context("connection closed mid-message")?,
            };

            if frame.stream_id != stream_id {
                bail!(
                    "message stream_id changed from {stream_id} to {}",
                    frame.stream_id
                );
            }

            match frame.kind {
                KIND_MESSAGE => {
                    let new_len = body
                        .len()
                        .checked_add(frame.data.len())
                        .context("DRPC message length overflow")?;
                    if new_len > self.max_message_bytes {
                        bail!("DRPC message exceeds {} byte limit", self.max_message_bytes);
                    }
                    body.extend_from_slice(&frame.data);
                    if frame.done {
                        return Ok(body);
                    }
                }
                KIND_ERROR => {
                    let (code, msg) = unmarshal_error(&frame.data);
                    bail!("remote error (code {code}): {msg}");
                }
                other => {
                    bail!("unexpected frame kind={other} while reading message");
                }
            }
        }
    }

    /// Write a message as KIND_MESSAGE frames that share one message id,
    /// split like drpc does with done=true only on the last frame.
    pub async fn write_message(
        &mut self,
        stream_id: u64,
        message_id: u64,
        data: &[u8],
    ) -> Result<()> {
        let data = Bytes::copy_from_slice(data);
        let mut start = 0;
        loop {
            let end = data.len().min(start + self.split_bytes);
            let done = end == data.len();
            self.write_frame(DrpcFrame {
                kind: KIND_MESSAGE,
                done,
                control: false,
                stream_id,
                message_id,
                data: data.slice(start..end),
            })
            .await?;
            if done {
                return Ok(());
            }
            start = end;
        }
    }

    /// Write a KIND_ERROR frame without a specific error code.
    pub async fn write_error(
        &mut self,
        stream_id: u64,
        message_id: u64,
        message: &str,
    ) -> Result<()> {
        self.write_error_with_code(stream_id, message_id, 0, message)
            .await
    }

    /// Write a KIND_ERROR frame carrying an Any-Sync error code.
    pub async fn write_error_with_code(
        &mut self,
        stream_id: u64,
        message_id: u64,
        code: u64,
        message: &str,
    ) -> Result<()> {
        self.write_frame(DrpcFrame {
            kind: KIND_ERROR,
            done: true,
            control: false,
            stream_id,
            message_id,
            data: marshal_error(code, message),
        })
        .await
    }
}

#[cfg(test)]
mod tests {
    use std::pin::Pin;
    use std::task::{Context as TaskContext, Poll};

    use super::*;
    use bytes::Bytes;
    use tokio::io::{AsyncRead, AsyncWrite, ReadBuf, duplex};

    struct PendingIo;

    impl AsyncRead for PendingIo {
        fn poll_read(
            self: Pin<&mut Self>,
            _context: &mut TaskContext<'_>,
            _buffer: &mut ReadBuf<'_>,
        ) -> Poll<std::io::Result<()>> {
            Poll::Pending
        }
    }

    impl AsyncWrite for PendingIo {
        fn poll_write(
            self: Pin<&mut Self>,
            _context: &mut TaskContext<'_>,
            _buffer: &[u8],
        ) -> Poll<std::io::Result<usize>> {
            Poll::Pending
        }

        fn poll_flush(
            self: Pin<&mut Self>,
            _context: &mut TaskContext<'_>,
        ) -> Poll<std::io::Result<()>> {
            Poll::Pending
        }

        fn poll_shutdown(
            self: Pin<&mut Self>,
            _context: &mut TaskContext<'_>,
        ) -> Poll<std::io::Result<()>> {
            Poll::Pending
        }
    }

    #[tokio::test]
    async fn incomplete_frame_hits_typed_read_deadline() {
        let (_client, server) = duplex(64);
        let mut reader =
            DrpcStream::with_limits_and_timeout(server, 1024, 1024, std::time::Duration::ZERO);

        let error = reader.read_frame().await.unwrap_err();
        let exceeded = deadline::exceeded(&error).unwrap();
        assert_eq!(exceeded.stage(), DeadlineStage::StreamRead);
    }

    #[tokio::test]
    async fn blocked_frame_write_hits_typed_write_deadline() {
        let mut writer =
            DrpcStream::with_limits_and_timeout(PendingIo, 1024, 1024, std::time::Duration::ZERO);

        let error = writer
            .write_frame(DrpcFrame {
                kind: KIND_MESSAGE,
                done: true,
                control: false,
                stream_id: 1,
                message_id: 1,
                data: Bytes::from_static(b"payload"),
            })
            .await
            .unwrap_err();
        let exceeded = deadline::exceeded(&error).unwrap();
        assert_eq!(exceeded.stage(), DeadlineStage::StreamWrite);
    }

    #[tokio::test]
    async fn large_message_is_split_into_bounded_frames_and_reassembled() {
        let (client, server) = duplex(64 * 1024);
        let mut writer = DrpcStream::with_limits(client, 1024 * 1024, 1024 * 1024);
        let mut reader = DrpcStream::with_limits(server, 1024 * 1024, 1024 * 1024);
        let message: Vec<u8> = (0..2 * MAX_SPLIT_BYTES + 100)
            .map(|index| index as u8)
            .collect();

        let sent = message.clone();
        let write = tokio::spawn(async move {
            writer.write_message(3, 7, &sent).await.unwrap();
            writer.write_message(3, 8, &sent).await.unwrap();
        });

        let mut frames = Vec::new();
        loop {
            let frame = reader.read_frame().await.unwrap().unwrap();
            let done = frame.done;
            frames.push(frame);
            if done {
                break;
            }
        }
        assert_eq!(
            frames
                .iter()
                .map(|frame| (frame.data.len(), frame.done))
                .collect::<Vec<_>>(),
            [
                (MAX_SPLIT_BYTES, false),
                (MAX_SPLIT_BYTES, false),
                (100, true)
            ]
        );
        assert!(frames.iter().all(|frame| frame.kind == KIND_MESSAGE
            && frame.stream_id == 3
            && frame.message_id == 7));
        assert_eq!(
            frames
                .iter()
                .flat_map(|frame| frame.data.iter().copied())
                .collect::<Vec<_>>(),
            message
        );

        assert_eq!(reader.read_message().await.unwrap(), message);
        write.await.unwrap();
    }

    #[tokio::test]
    async fn split_size_respects_smaller_frame_limit_and_empty_messages() {
        let (client, server) = duplex(4096);
        let mut writer = DrpcStream::with_limits(client, 1024, 4096);
        let mut reader = DrpcStream::with_limits(server, 1024, 4096);

        writer.write_message(1, 1, &[7; 1500]).await.unwrap();
        let first = reader.read_frame().await.unwrap().unwrap();
        let second = reader.read_frame().await.unwrap().unwrap();
        assert_eq!((first.data.len(), first.done), (1024, false));
        assert_eq!((second.data.len(), second.done), (476, true));
        assert_eq!(second.message_id, first.message_id);

        writer.write_message(1, 2, &[]).await.unwrap();
        let empty = reader.read_frame().await.unwrap().unwrap();
        assert!(empty.data.is_empty());
        assert!(empty.done);
    }

    #[tokio::test]
    async fn rejects_fragmented_message_over_total_limit() {
        let (client, server) = duplex(4096);
        let mut writer = DrpcStream::new(client);
        let mut reader = DrpcStream::with_limits(server, 1024, 5);
        writer
            .write_frame(DrpcFrame {
                kind: KIND_MESSAGE,
                done: false,
                control: false,
                stream_id: 1,
                message_id: 1,
                data: Bytes::from_static(b"abc"),
            })
            .await
            .unwrap();
        writer
            .write_frame(DrpcFrame {
                kind: KIND_MESSAGE,
                done: true,
                control: false,
                stream_id: 1,
                message_id: 2,
                data: Bytes::from_static(b"def"),
            })
            .await
            .unwrap();

        assert!(
            reader
                .read_message()
                .await
                .unwrap_err()
                .to_string()
                .contains("limit")
        );
    }
}
