//! Client-side 4-step credential handshake.
//!
//! Mirrors the server handshake but the client writes first:
//! 1. Client -> Server: Credentials
//! 2. Server -> Client: Credentials
//! 3. Client -> Server: Ack
//! 4. Server -> Client: Ack

use anyhow::{Result, ensure};
use manytype_core::crypto::ed25519;
use manytype_proto::handshake::{Ack, Credentials, PayloadSignedPeerIds};
use manytype_server::handshake::{build_credentials, read_handshake_msg, write_handshake_msg};
use prost::Message;
use tokio::io::{AsyncRead, AsyncWrite};

/// Perform client-side credential handshake.
///
/// Returns the server's peer identity bytes on success.
pub async fn client_handshake(
    stream: &mut (impl AsyncRead + AsyncWrite + Unpin),
    signing_key: &ed25519_dalek::SigningKey,
) -> Result<Vec<u8>> {
    let local_peer_id = ed25519::verifying_key(signing_key).to_bytes().to_vec();

    // 1. Client sends Credentials (empty remote_peer_id -- don't know server yet)
    let creds = build_credentials(signing_key, &local_peer_id, &[]);
    write_handshake_msg(stream, 1, &creds).await?;

    // 2. Read server Credentials
    let (msg_type, payload) = read_handshake_msg(stream).await?;
    ensure!(msg_type == 1, "expected Credentials (type 1), got type {}", msg_type);
    let server_creds = Credentials::decode(payload.as_slice())?;
    let server_signed = PayloadSignedPeerIds::decode(server_creds.payload.as_slice())?;
    let server_peer_id = server_signed.identity.clone();

    // 3. Client sends Ack (success)
    let ack = Ack { error: 0 };
    write_handshake_msg(stream, 2, &ack.encode_to_vec()).await?;

    // 4. Read server Ack
    let (msg_type, payload) = read_handshake_msg(stream).await?;
    ensure!(msg_type == 2, "expected Ack (type 2), got type {}", msg_type);
    let ack = Ack::decode(payload.as_slice())?;
    ensure!(ack.error == 0, "server sent error in ack: {}", ack.error);

    Ok(server_peer_id)
}

#[cfg(test)]
mod tests {
    use super::*;
    use manytype_core::crypto::ed25519;
    use manytype_server::handshake::perform_handshake;
    use tokio::io::duplex;

    #[tokio::test]
    async fn test_client_server_handshake_round_trip() {
        let (client_io, server_io) = duplex(8192);

        let server_seed = [1u8; 32];
        let server_signing_key = ed25519::signing_key_from_seed(&server_seed);
        let server_vk = ed25519::verifying_key(&server_signing_key);
        let server_peer_id = server_vk.to_bytes().to_vec();

        let client_seed = [2u8; 32];
        let client_signing_key = ed25519::signing_key_from_seed(&client_seed);
        let client_vk = ed25519::verifying_key(&client_signing_key);
        let client_peer_id = client_vk.to_bytes().to_vec();

        let server_peer_id_for_server = server_peer_id.clone();

        // Server side: uses perform_handshake from manytype_server
        let server_handle = tokio::spawn(async move {
            let (recv, send) = tokio::io::split(server_io);
            let mut stream = tokio::io::join(recv, send);
            perform_handshake(&mut stream, &server_signing_key, &server_peer_id_for_server).await
        });

        // Client side: uses our client_handshake
        let client_handle = tokio::spawn(async move {
            let (recv, send) = tokio::io::split(client_io);
            let mut stream = tokio::io::join(recv, send);
            client_handshake(&mut stream, &client_signing_key).await
        });

        // Server should receive client's peer ID
        let remote_id = server_handle.await.unwrap().unwrap();
        assert_eq!(remote_id, client_peer_id);

        // Client should receive server's peer ID
        let server_id = client_handle.await.unwrap().unwrap();
        assert_eq!(server_id, server_peer_id);
    }
}
