//! DRPC wire protocol frame codec.
//!
//! Implements the Storj DRPC wire format:
//! `[header: 1 byte] [stream_id: varint] [message_id: varint] [length: varint] [data: length bytes]`
//!
//! Header byte layout:
//! - bit 7 (MSB): control flag
//! - bits 6-1: kind (6 bits)
//! - bit 0 (LSB): done flag

use bytes::{Buf, BufMut, Bytes, BytesMut};
use prost::encoding::{decode_varint, encode_varint};
use tokio_util::codec::{Decoder, Encoder};

/// Frame kind constants matching the DRPC wire protocol.
pub const KIND_INVOKE: u8 = 1;
pub const KIND_MESSAGE: u8 = 2;
pub const KIND_ERROR: u8 = 3;
pub const KIND_CANCEL: u8 = 4;
pub const KIND_CLOSE: u8 = 5;
pub const KIND_CLOSE_SEND: u8 = 6;
pub const KIND_INVOKE_METADATA: u8 = 7;

/// A single DRPC wire frame.
#[derive(Debug, Clone, PartialEq)]
pub struct DrpcFrame {
    pub kind: u8,
    pub done: bool,
    pub control: bool,
    pub stream_id: u64,
    pub message_id: u64,
    pub data: Bytes,
}

/// Encode the header byte from kind, done, and control flags.
///
/// Layout: `[control (bit 7)] [kind (bits 6-1)] [done (bit 0)]`
pub fn encode_header(kind: u8, done: bool, control: bool) -> u8 {
    let mut h: u8 = 0;
    if control {
        h |= 0x80; // bit 7
    }
    h |= (kind & 0x3F) << 1; // bits 6-1
    if done {
        h |= 0x01; // bit 0
    }
    h
}

/// Decode the header byte into (control, kind, done).
pub fn decode_header(h: u8) -> (bool, u8, bool) {
    let control = (h & 0x80) != 0;
    let kind = (h >> 1) & 0x3F;
    let done = (h & 0x01) != 0;
    (control, kind, done)
}

/// Encode a KIND_ERROR payload like `drpcwire.MarshalError`: an 8-byte
/// big-endian error code followed by the message. Code 0 means no code.
pub fn marshal_error(code: u64, message: &str) -> Bytes {
    let mut data = BytesMut::with_capacity(8 + message.len());
    data.put_u64(code);
    data.put_slice(message.as_bytes());
    data.freeze()
}

/// Decode a KIND_ERROR payload into its error code and message.
pub fn unmarshal_error(data: &[u8]) -> (u64, String) {
    match data.split_first_chunk::<8>() {
        Some((code, message)) => (
            u64::from_be_bytes(*code),
            String::from_utf8_lossy(message).into_owned(),
        ),
        None => (0, String::from_utf8_lossy(data).into_owned()),
    }
}

pub const DEFAULT_MAX_FRAME_BYTES: usize = 2 * 1024 * 1024;

/// Tokio codec for DRPC frames.
#[derive(Debug)]
pub struct DrpcCodec {
    max_frame_bytes: usize,
}

impl Default for DrpcCodec {
    fn default() -> Self {
        Self::new()
    }
}

impl DrpcCodec {
    pub fn new() -> Self {
        Self::with_max_frame_bytes(DEFAULT_MAX_FRAME_BYTES)
    }

    pub fn with_max_frame_bytes(max_frame_bytes: usize) -> Self {
        Self { max_frame_bytes }
    }
}

impl Encoder<DrpcFrame> for DrpcCodec {
    type Error = std::io::Error;

    fn encode(&mut self, frame: DrpcFrame, dst: &mut BytesMut) -> Result<(), Self::Error> {
        if frame.data.len() > self.max_frame_bytes {
            return Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                format!("DRPC frame exceeds {} byte limit", self.max_frame_bytes),
            ));
        }
        // Header byte
        dst.put_u8(encode_header(frame.kind, frame.done, frame.control));

        // Varints for stream_id, message_id, data length
        encode_varint(frame.stream_id, dst);
        encode_varint(frame.message_id, dst);
        encode_varint(frame.data.len() as u64, dst);

        // Data payload
        dst.extend_from_slice(&frame.data);

        Ok(())
    }
}

/// Longest valid varint encoding of a u64.
const MAX_VARINT_BYTES: usize = 10;

/// Decode one header varint, returning `None` while it may still be incomplete.
fn decode_header_varint(cursor: &mut std::io::Cursor<&[u8]>) -> std::io::Result<Option<u64>> {
    let available = cursor.remaining();
    match decode_varint(cursor) {
        Ok(value) => Ok(Some(value)),
        Err(_) if available < MAX_VARINT_BYTES => Ok(None),
        Err(_) => Err(std::io::Error::new(
            std::io::ErrorKind::InvalidData,
            "DRPC frame header contains a malformed varint",
        )),
    }
}

impl Decoder for DrpcCodec {
    type Item = DrpcFrame;
    type Error = std::io::Error;

    fn decode(&mut self, src: &mut BytesMut) -> Result<Option<Self::Item>, Self::Error> {
        if src.is_empty() {
            return Ok(None);
        }

        // Try to decode the entire frame without consuming `src` yet.
        // We work on a Cursor so we can rewind if data is incomplete.
        let mut cursor = std::io::Cursor::new(&src[..]);

        // Header byte
        if cursor.remaining() < 1 {
            return Ok(None);
        }
        let header = cursor.get_u8();
        let (control, kind, done) = decode_header(header);

        // Decode three varints: stream_id, message_id, length
        let Some(stream_id) = decode_header_varint(&mut cursor)? else {
            // Incomplete varint -- need more data
            src.reserve(1);
            return Ok(None);
        };

        let Some(message_id) = decode_header_varint(&mut cursor)? else {
            src.reserve(1);
            return Ok(None);
        };

        let Some(data_len) = decode_header_varint(&mut cursor)? else {
            src.reserve(1);
            return Ok(None);
        };
        let data_len = usize::try_from(data_len).map_err(|_| {
            std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                "DRPC frame length does not fit in memory",
            )
        })?;

        if data_len > self.max_frame_bytes {
            return Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                format!(
                    "DRPC frame length {data_len} exceeds {} byte limit",
                    self.max_frame_bytes
                ),
            ));
        }

        // Check if we have enough data bytes
        if cursor.remaining() < data_len {
            // Reserve enough space for the remaining data
            src.reserve(data_len - cursor.remaining());
            return Ok(None);
        }

        // We have a complete frame. Record how many bytes we consumed.
        let pos = cursor.position() as usize;
        let total_frame_len = pos + data_len;

        // Extract data
        let data = Bytes::copy_from_slice(&src[pos..pos + data_len]);

        // Advance src past the entire frame
        src.advance(total_frame_len);

        Ok(Some(DrpcFrame {
            kind,
            done,
            control,
            stream_id,
            message_id,
            data,
        }))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use bytes::BytesMut;
    use tokio_util::codec::{Decoder, Encoder};

    #[test]
    fn test_encode_header_invoke() {
        // KIND_INVOKE=1, done=false, control=false -> kind<<1 = 0x02
        assert_eq!(encode_header(KIND_INVOKE, false, false), 0x02);
    }

    #[test]
    fn test_encode_header_message_done() {
        // KIND_MESSAGE=2, done=true, control=false -> (2<<1)|1 = 0x05
        assert_eq!(encode_header(KIND_MESSAGE, true, false), 0x05);
    }

    #[test]
    fn test_decode_header_roundtrip() {
        for kind in 0..=0x3F {
            for done in [false, true] {
                for control in [false, true] {
                    let h = encode_header(kind, done, control);
                    let (c, k, d) = decode_header(h);
                    assert_eq!((c, k, d), (control, kind, done), "header byte {h:#04x}");
                }
            }
        }
    }

    #[test]
    fn error_payload_carries_big_endian_code_prefix() {
        let data = marshal_error(201, "CIDNotFound: cid not found");
        assert_eq!(&data[..8], &[0, 0, 0, 0, 0, 0, 0, 201]);
        assert_eq!(&data[8..], b"CIDNotFound: cid not found");
        assert_eq!(
            unmarshal_error(&data),
            (201, "CIDNotFound: cid not found".to_string())
        );
        assert_eq!(unmarshal_error(b"short"), (0, "short".to_string()));
    }

    #[test]
    fn test_roundtrip_invoke_frame() {
        let mut codec = DrpcCodec::new();
        let frame = DrpcFrame {
            kind: KIND_INVOKE,
            done: false,
            control: false,
            stream_id: 1,
            message_id: 0,
            data: Bytes::from_static(b"/pkg.Svc/Method"),
        };

        let mut buf = BytesMut::new();
        codec.encode(frame.clone(), &mut buf).unwrap();

        let decoded = codec.decode(&mut buf).unwrap().unwrap();
        assert_eq!(decoded, frame);
    }

    #[test]
    fn test_roundtrip_message_frame() {
        let mut codec = DrpcCodec::new();
        let frame = DrpcFrame {
            kind: KIND_MESSAGE,
            done: false,
            control: false,
            stream_id: 1,
            message_id: 1,
            data: Bytes::from_static(b"\x08\x01"),
        };

        let mut buf = BytesMut::new();
        codec.encode(frame.clone(), &mut buf).unwrap();

        let decoded = codec.decode(&mut buf).unwrap().unwrap();
        assert_eq!(decoded, frame);
    }

    #[test]
    fn test_roundtrip_close_send_done() {
        let mut codec = DrpcCodec::new();
        let frame = DrpcFrame {
            kind: KIND_CLOSE_SEND,
            done: true,
            control: false,
            stream_id: 1,
            message_id: 0,
            data: Bytes::new(),
        };

        let mut buf = BytesMut::new();
        codec.encode(frame.clone(), &mut buf).unwrap();

        let decoded = codec.decode(&mut buf).unwrap().unwrap();
        assert_eq!(decoded, frame);
    }

    #[test]
    fn test_partial_frame_returns_none() {
        let mut codec = DrpcCodec::new();
        let frame = DrpcFrame {
            kind: KIND_INVOKE,
            done: false,
            control: false,
            stream_id: 1,
            message_id: 0,
            data: Bytes::from_static(b"/pkg.Svc/Method"),
        };

        let mut buf = BytesMut::new();
        codec.encode(frame, &mut buf).unwrap();

        // Truncate to simulate partial data (just the header byte)
        buf.truncate(1);

        let result = codec.decode(&mut buf).unwrap();
        assert!(result.is_none(), "partial frame should return Ok(None)");
    }

    #[test]
    fn test_empty_buffer_returns_none() {
        let mut codec = DrpcCodec::new();
        let mut buf = BytesMut::new();

        let result = codec.decode(&mut buf).unwrap();
        assert!(result.is_none(), "empty buffer should return Ok(None)");
    }

    #[test]
    fn test_multiple_frames_in_buffer() {
        let mut codec = DrpcCodec::new();
        let frame1 = DrpcFrame {
            kind: KIND_INVOKE,
            done: false,
            control: false,
            stream_id: 1,
            message_id: 0,
            data: Bytes::from_static(b"/method"),
        };
        let frame2 = DrpcFrame {
            kind: KIND_MESSAGE,
            done: true,
            control: false,
            stream_id: 1,
            message_id: 1,
            data: Bytes::from_static(b"\x08\x01"),
        };

        let mut buf = BytesMut::new();
        codec.encode(frame1.clone(), &mut buf).unwrap();
        codec.encode(frame2.clone(), &mut buf).unwrap();

        let decoded1 = codec.decode(&mut buf).unwrap().unwrap();
        assert_eq!(decoded1, frame1);

        let decoded2 = codec.decode(&mut buf).unwrap().unwrap();
        assert_eq!(decoded2, frame2);

        // Buffer should be empty now
        assert!(buf.is_empty());
    }

    #[test]
    fn rejects_claimed_frame_length_before_reserving_payload() {
        let mut codec = DrpcCodec::with_max_frame_bytes(1024);
        let mut buf = BytesMut::new();
        buf.put_u8(encode_header(KIND_MESSAGE, true, false));
        encode_varint(1, &mut buf);
        encode_varint(1, &mut buf);
        encode_varint(1025, &mut buf);

        let error = codec.decode(&mut buf).unwrap_err();
        assert_eq!(error.kind(), std::io::ErrorKind::InvalidData);
        assert!(error.to_string().contains("exceeds"));
    }

    #[test]
    fn rejects_malformed_header_varints() {
        for field in 0..3 {
            for last_byte in [0xFF, 0x02] {
                let mut codec = DrpcCodec::new();
                let mut buf = BytesMut::new();
                buf.put_u8(encode_header(KIND_MESSAGE, true, false));
                for _ in 0..field {
                    encode_varint(1, &mut buf);
                }
                buf.put_slice(&[0xFF; MAX_VARINT_BYTES - 1]);
                assert!(
                    codec.decode(&mut buf).unwrap().is_none(),
                    "field {field} should wait for the rest of its varint"
                );

                buf.put_u8(last_byte);
                let error = codec.decode(&mut buf).unwrap_err();
                assert_eq!(
                    error.kind(),
                    std::io::ErrorKind::InvalidData,
                    "field {field} last byte {last_byte:#04x}"
                );
            }
        }
    }

    #[test]
    fn rejects_oversized_outbound_frame() {
        let mut codec = DrpcCodec::with_max_frame_bytes(2);
        let mut buf = BytesMut::new();
        let error = codec
            .encode(
                DrpcFrame {
                    kind: KIND_MESSAGE,
                    done: true,
                    control: false,
                    stream_id: 1,
                    message_id: 1,
                    data: Bytes::from_static(b"too large"),
                },
                &mut buf,
            )
            .unwrap_err();
        assert_eq!(error.kind(), std::io::ErrorKind::InvalidData);
    }
}
