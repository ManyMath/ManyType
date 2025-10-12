//! DRPC stream abstraction for reading/writing typed messages.
//!
//! Wraps a `tokio_util::codec::Framed<T, DrpcCodec>` to provide
//! higher-level operations like `read_invoke`, `write_message`, etc.

use anyhow::{Context, Result, bail};
use bytes::Bytes;
use futures::{SinkExt, StreamExt};
use tokio::io::{AsyncRead, AsyncWrite};
use tokio_util::codec::Framed;

use super::codec::{
    DrpcCodec, DrpcFrame, KIND_ERROR, KIND_INVOKE, KIND_MESSAGE,
};

/// A bidirectional DRPC stream over an async transport.
pub struct DrpcStream<T> {
    framed: Framed<T, DrpcCodec>,
}

impl<T> DrpcStream<T>
where
    T: AsyncRead + AsyncWrite + Unpin,
{
    /// Create a new DRPC stream wrapping the given IO transport.
    pub fn new(io: T) -> Self {
        Self {
            framed: Framed::new(io, DrpcCodec::new()),
        }
    }

    /// Read the next frame from the stream.
    pub async fn read_frame(&mut self) -> Result<Option<DrpcFrame>> {
        match self.framed.next().await {
            Some(Ok(frame)) => Ok(Some(frame)),
            Some(Err(e)) => Err(e).context("failed to read DRPC frame"),
            None => Ok(None),
        }
    }

    /// Write a frame to the stream.
    pub async fn write_frame(&mut self, frame: DrpcFrame) -> Result<()> {
        self.framed
            .send(frame)
            .await
            .context("failed to write DRPC frame")
    }

    /// Read KIND_INVOKE frame, returning (stream_id, method_path).
    pub async fn read_invoke(&mut self) -> Result<(u64, String)> {
        let frame = self
            .read_frame()
            .await?
            .context("connection closed before invoke")?;

        if frame.kind != KIND_INVOKE {
            bail!(
                "expected KIND_INVOKE frame, got kind={}",
                frame.kind
            );
        }

        let method = String::from_utf8(frame.data.to_vec())
            .context("invoke method path is not valid UTF-8")?;

        Ok((frame.stream_id, method))
    }

    /// Read KIND_MESSAGE frames, collecting data until done=true.
    /// Returns the concatenated body bytes.
    pub async fn read_message(&mut self) -> Result<Vec<u8>> {
        let mut body = Vec::new();
        loop {
            let frame = self
                .read_frame()
                .await?
                .context("connection closed mid-message")?;

            match frame.kind {
                KIND_MESSAGE => {
                    body.extend_from_slice(&frame.data);
                    if frame.done {
                        return Ok(body);
                    }
                }
                KIND_ERROR => {
                    let msg = String::from_utf8_lossy(&frame.data);
                    bail!("remote error: {msg}");
                }
                other => {
                    bail!("unexpected frame kind={other} while reading message");
                }
            }
        }
    }

    /// Write a single KIND_MESSAGE frame with done=true.
    pub async fn write_message(
        &mut self,
        stream_id: u64,
        message_id: u64,
        data: &[u8],
    ) -> Result<()> {
        self.write_frame(DrpcFrame {
            kind: KIND_MESSAGE,
            done: true,
            control: false,
            stream_id,
            message_id,
            data: Bytes::copy_from_slice(data),
        })
        .await
    }

    /// Write a KIND_ERROR frame.
    pub async fn write_error(
        &mut self,
        stream_id: u64,
        message: &str,
    ) -> Result<()> {
        self.write_frame(DrpcFrame {
            kind: KIND_ERROR,
            done: true,
            control: false,
            stream_id,
            message_id: 0,
            data: Bytes::copy_from_slice(message.as_bytes()),
        })
        .await
    }
}
