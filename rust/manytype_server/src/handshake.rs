//! Credential handshake protocol over 5-byte header framing.
//!
//! Implements the Anytype credential handshake:
//! 1. Client -> Server: Credentials
//! 2. Server -> Client: Credentials
//! 3. Client -> Server: Ack (error=Null)
//! 4. Server -> Client: Ack (error=Null)
//!
//! Header format: [type: u8][length: u32 LE]
//! Type 1 = Credentials, Type 2 = Ack

use anyhow::Result;
use manytype_core::crypto::ed25519;
use manytype_proto::handshake::{Ack, Credentials, CredentialsType, PayloadSignedPeerIds};
use prost::Message;
use tokio::io::{AsyncReadExt, AsyncWriteExt};

const MSG_TYPE_CREDENTIALS: u8 = 1;
const MSG_TYPE_ACK: u8 = 2;
#[allow(dead_code)]
const MSG_TYPE_PROTO: u8 = 3;
const MAX_HANDSHAKE_MSG_SIZE: u32 = 204800; // 200 KB

/// Write a handshake message with 5-byte header framing.
pub async fn write_handshake_msg(
    stream: &mut (impl tokio::io::AsyncWrite + Unpin),
    msg_type: u8,
    payload: &[u8],
) -> Result<()> {
    let mut header = [0u8; 5];
    header[0] = msg_type;
    header[1..5].copy_from_slice(&(payload.len() as u32).to_le_bytes());
    stream.write_all(&header).await?;
    stream.write_all(payload).await?;
    Ok(())
}

/// Read a handshake message with 5-byte header framing.
pub async fn read_handshake_msg(
    stream: &mut (impl tokio::io::AsyncRead + Unpin),
) -> Result<(u8, Vec<u8>)> {
    let mut header = [0u8; 5];
    stream.read_exact(&mut header).await?;
    let msg_type = header[0];
    let length = u32::from_le_bytes(header[1..5].try_into().unwrap());
    if length > MAX_HANDSHAKE_MSG_SIZE {
        anyhow::bail!("handshake message too large: {} bytes", length);
    }
    let mut payload = vec![0u8; length as usize];
    stream.read_exact(&mut payload).await?;
    Ok((msg_type, payload))
}

/// Build a Credentials protobuf message with SignedPeerIds.
pub fn build_credentials(
    signing_key: &ed25519_dalek::SigningKey,
    local_peer_id: &[u8],
    remote_peer_id: &[u8],
) -> Vec<u8> {
    let verifying_key = ed25519::verifying_key(signing_key);
    let mut sign_payload = Vec::new();
    sign_payload.extend_from_slice(local_peer_id);
    sign_payload.extend_from_slice(remote_peer_id);
    let signature = ed25519::sign(signing_key, &sign_payload);

    let signed_peer_ids = PayloadSignedPeerIds {
        identity: verifying_key.to_bytes().to_vec(),
        sign: signature.to_bytes().to_vec(),
    };

    let credentials = Credentials {
        r#type: CredentialsType::SignedPeerIds as i32,
        payload: signed_peer_ids.encode_to_vec(),
        version: 1,
        client_version: "manytype/0.1".to_string(),
    };
    credentials.encode_to_vec()
}

/// Perform server-side (responder) credential handshake.
///
/// Returns the remote peer's identity bytes on success.
pub async fn perform_handshake(
    stream: &mut (impl tokio::io::AsyncRead + tokio::io::AsyncWrite + Unpin),
    signing_key: &ed25519_dalek::SigningKey,
    local_peer_id: &[u8],
) -> Result<Vec<u8>> {
    // 1. Read client Credentials
    let (msg_type, payload) = read_handshake_msg(stream).await?;
    anyhow::ensure!(
        msg_type == MSG_TYPE_CREDENTIALS,
        "expected Credentials, got type {}",
        msg_type
    );
    let client_creds = Credentials::decode(payload.as_slice())?;
    let client_signed = PayloadSignedPeerIds::decode(client_creds.payload.as_slice())?;
    let remote_peer_id = client_signed.identity.clone();

    // 2. Send our Credentials
    let our_creds = build_credentials(signing_key, local_peer_id, &remote_peer_id);
    write_handshake_msg(stream, MSG_TYPE_CREDENTIALS, &our_creds).await?;

    // 3. Read client Ack
    let (msg_type, payload) = read_handshake_msg(stream).await?;
    anyhow::ensure!(
        msg_type == MSG_TYPE_ACK,
        "expected Ack, got type {}",
        msg_type
    );
    let ack = Ack::decode(payload.as_slice())?;
    anyhow::ensure!(ack.error == 0, "client sent error in ack: {}", ack.error);

    // 4. Send our Ack (success)
    let our_ack = Ack { error: 0 };
    write_handshake_msg(stream, MSG_TYPE_ACK, &our_ack.encode_to_vec()).await?;

    Ok(remote_peer_id)
}

#[cfg(test)]
mod tests {
    use super::*;
    use manytype_core::crypto::ed25519;
    use tokio::io::duplex;

    #[tokio::test]
    async fn test_write_read_handshake_msg_round_trip() {
        let (mut client, mut server) = duplex(4096);
        let payload = b"hello handshake";

        // Write from client side
        write_handshake_msg(&mut client, MSG_TYPE_CREDENTIALS, payload)
            .await
            .unwrap();
        drop(client); // close write side so read completes

        // Read from server side
        let (msg_type, data) = read_handshake_msg(&mut server).await.unwrap();
        assert_eq!(msg_type, MSG_TYPE_CREDENTIALS);
        assert_eq!(data, payload);
    }

    #[tokio::test]
    async fn test_header_format_is_type_then_le_length() {
        let (mut writer, mut reader) = duplex(4096);
        let payload = vec![0xAA; 10];

        write_handshake_msg(&mut writer, 2, &payload).await.unwrap();
        drop(writer);

        // Read raw bytes to verify header format
        let mut raw = Vec::new();
        reader.read_to_end(&mut raw).await.unwrap();

        assert_eq!(raw[0], 2u8); // type byte
        let len = u32::from_le_bytes(raw[1..5].try_into().unwrap());
        assert_eq!(len, 10); // LE u32 length
        assert_eq!(&raw[5..], &payload); // payload follows
    }

    #[tokio::test]
    async fn test_rejects_oversized_message() {
        let (mut writer, mut reader) = duplex(4096);

        // Manually write a header claiming 300KB payload
        let mut header = [0u8; 5];
        header[0] = MSG_TYPE_CREDENTIALS;
        header[1..5].copy_from_slice(&(300_000u32).to_le_bytes());
        tokio::io::AsyncWriteExt::write_all(&mut writer, &header)
            .await
            .unwrap();
        drop(writer);

        let result = read_handshake_msg(&mut reader).await;
        assert!(result.is_err());
        let err = result.unwrap_err().to_string();
        assert!(
            err.contains("too large"),
            "expected 'too large' error, got: {}",
            err
        );
    }

    #[tokio::test]
    async fn test_build_credentials_contains_signed_peer_ids() {
        let seed = [1u8; 32];
        let signing_key = ed25519::signing_key_from_seed(&seed);
        let local_peer_id = b"local-peer";
        let remote_peer_id = b"remote-peer";

        let creds_bytes = build_credentials(&signing_key, local_peer_id, remote_peer_id);

        // Decode and verify
        let creds = Credentials::decode(creds_bytes.as_slice()).unwrap();
        assert_eq!(creds.r#type, CredentialsType::SignedPeerIds as i32);
        assert_eq!(creds.version, 1);
        assert_eq!(creds.client_version, "manytype/0.1");

        // Verify payload contains identity and valid signature
        let signed = PayloadSignedPeerIds::decode(creds.payload.as_slice()).unwrap();
        let vk = ed25519::verifying_key(&signing_key);
        assert_eq!(signed.identity, vk.to_bytes().to_vec());
        assert_eq!(signed.sign.len(), 64); // Ed25519 signature is 64 bytes

        // Verify the signature is valid
        let mut sign_payload = Vec::new();
        sign_payload.extend_from_slice(local_peer_id);
        sign_payload.extend_from_slice(remote_peer_id);
        let sig = ed25519_dalek::Signature::from_bytes(
            &signed.sign.try_into().expect("64 bytes"),
        );
        assert!(ed25519::verify(&vk, &sign_payload, &sig));
    }

    #[tokio::test]
    async fn test_full_handshake_round_trip() {
        let (client_io, server_io) = duplex(8192);

        let server_seed = [1u8; 32];
        let server_signing_key = ed25519::signing_key_from_seed(&server_seed);
        let server_vk = ed25519::verifying_key(&server_signing_key);
        let server_peer_id = server_vk.to_bytes().to_vec();

        let client_seed = [2u8; 32];
        let client_signing_key = ed25519::signing_key_from_seed(&client_seed);
        let client_vk = ed25519::verifying_key(&client_signing_key);
        let client_peer_id = client_vk.to_bytes().to_vec();

        let server_peer_id_clone = server_peer_id.clone();
        let client_peer_id_clone = client_peer_id.clone();

        // Server side
        let server_handle = tokio::spawn(async move {
            let (recv, send) = tokio::io::split(server_io);
            let mut stream = tokio::io::join(recv, send);
            perform_handshake(&mut stream, &server_signing_key, &server_peer_id_clone).await
        });

        // Client side (simulates the 4-step handshake)
        let client_handle = tokio::spawn(async move {
            let (recv, send) = tokio::io::split(client_io);
            let mut stream = tokio::io::join(recv, send);

            // 1. Client sends Credentials
            let creds = build_credentials(&client_signing_key, &client_peer_id_clone, &server_peer_id);
            write_handshake_msg(&mut stream, MSG_TYPE_CREDENTIALS, &creds).await.unwrap();

            // 2. Client reads server Credentials
            let (msg_type, _payload) = read_handshake_msg(&mut stream).await.unwrap();
            assert_eq!(msg_type, MSG_TYPE_CREDENTIALS);

            // 3. Client sends Ack (success)
            let ack = Ack { error: 0 };
            write_handshake_msg(&mut stream, MSG_TYPE_ACK, &ack.encode_to_vec()).await.unwrap();

            // 4. Client reads server Ack
            let (msg_type, payload) = read_handshake_msg(&mut stream).await.unwrap();
            assert_eq!(msg_type, MSG_TYPE_ACK);
            let ack = Ack::decode(payload.as_slice()).unwrap();
            assert_eq!(ack.error, 0);
        });

        let remote_id = server_handle.await.unwrap().unwrap();
        assert_eq!(remote_id, client_peer_id);
        client_handle.await.unwrap();
    }
}
