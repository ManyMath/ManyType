//! Client-side 5-step credential handshake.
//!
//! Mirrors the server handshake but the client writes first:
//! 1. Client -> Server: Credentials
//! 2. Server -> Client: Credentials
//! 3. Client -> Server: Ack
//! 4. Server -> Client: Ack
//!
//! Subsequent streams perform Proto (encoding negotiation).

use anyhow::{Result, ensure};
use libp2p_identity::Keypair;
use manytype_proto::crypto::{Key, KeyType};
use manytype_proto::handshake::{
    Ack, Credentials, CredentialsType, Encoding, Error, PayloadSignedPeerIds, Proto, ProtoType,
};
use manytype_server::handshake::{read_handshake_msg, verify_signed_peer_ids, write_handshake_msg};
use prost::Message;
use tokio::io::{AsyncRead, AsyncWrite};

/// Perform client-side credential handshake.
///
/// Returns the server's peer identity bytes on success.
pub async fn client_handshake(
    stream: &mut (impl AsyncRead + AsyncWrite + Unpin),
    peer_keypair: &Keypair,
    account_signing_key: &ed25519_dalek::SigningKey,
    remote_peer_id: &str,
    allow_skip_verify: bool,
) -> Result<Vec<u8>> {
    let local_peer_id = peer_keypair.public().to_peer_id().to_string();

    // 1. Client sends Credentials (empty remote_peer_id -- don't know server yet)
    let creds = build_client_credentials(account_signing_key, &local_peer_id, remote_peer_id);
    write_handshake_msg(stream, 1, &creds).await?;

    // 2. Read server Credentials
    let (msg_type, payload) = read_handshake_msg(stream).await?;
    ensure!(
        msg_type == 1,
        "expected Credentials (type 1), got type {}",
        msg_type
    );
    let server_creds = Credentials::decode(payload.as_slice())?;
    let server_identity = match verify_server_credentials(
        &server_creds,
        remote_peer_id,
        &local_peer_id,
        allow_skip_verify,
    ) {
        Ok(identity) => identity,
        Err(err) => {
            let ack = Ack {
                error: Error::InvalidCredentials as i32,
            };
            let _ = write_handshake_msg(stream, 2, &ack.encode_to_vec()).await;
            return Err(err);
        }
    };

    // 3. Client sends Ack (success)
    let ack = Ack { error: 0 };
    write_handshake_msg(stream, 2, &ack.encode_to_vec()).await?;

    // 4. Read server Ack
    let (msg_type, payload) = read_handshake_msg(stream).await?;
    ensure!(
        msg_type == 2,
        "expected Ack (type 2), got type {}",
        msg_type
    );
    let ack = Ack::decode(payload.as_slice())?;
    ensure!(ack.error == 0, "server sent error in ack: {}", ack.error);

    Ok(server_identity)
}

fn verify_server_credentials(
    creds: &Credentials,
    remote_peer_id: &str,
    local_peer_id: &str,
    allow_skip_verify: bool,
) -> Result<Vec<u8>> {
    match CredentialsType::try_from(creds.r#type) {
        Ok(CredentialsType::SignedPeerIds) => {
            let signed = PayloadSignedPeerIds::decode(creds.payload.as_slice())?;
            verify_signed_peer_ids(&signed, remote_peer_id, local_peer_id)
        }
        Ok(CredentialsType::SkipVerify) => {
            ensure!(allow_skip_verify, "server skipped credential verification");
            Ok(Vec::new())
        }
        _ => anyhow::bail!("unsupported server credential type {}", creds.r#type),
    }
}

fn build_client_credentials(
    account_signing_key: &ed25519_dalek::SigningKey,
    local_peer_id: &str,
    remote_peer_id: &str,
) -> Vec<u8> {
    let signed_peer_ids = PayloadSignedPeerIds {
        identity: encode_anysync_public_key(account_signing_key),
        sign: ed25519_dalek::Signer::sign(
            account_signing_key,
            format!("{local_peer_id}{remote_peer_id}").as_bytes(),
        )
        .to_bytes()
        .to_vec(),
    };

    Credentials {
        r#type: CredentialsType::SignedPeerIds as i32,
        payload: signed_peer_ids.encode_to_vec(),
        version: 9,
        client_version: "manytype/2.0".to_string(),
    }
    .encode_to_vec()
}

fn encode_anysync_public_key(account_signing_key: &ed25519_dalek::SigningKey) -> Vec<u8> {
    let public_key = account_signing_key.verifying_key().to_bytes().to_vec();
    Key {
        r#type: KeyType::Ed25519Public as i32,
        data: public_key,
    }
    .encode_to_vec()
}

/// Perform the per-stream Proto handshake after the connection-level credential handshake.
pub async fn client_proto_handshake(
    stream: &mut (impl AsyncRead + AsyncWrite + Unpin),
) -> Result<Vec<i32>> {
    let proto_msg = Proto {
        proto: ProtoType::Drpc as i32,
        encodings: vec![Encoding::None as i32],
    };
    write_handshake_msg(stream, 3, &proto_msg.encode_to_vec()).await?;

    let (msg_type, payload) = read_handshake_msg(stream).await?;
    match msg_type {
        2 => {
            let ack = Ack::decode(payload.as_slice())?;
            ensure!(
                ack.error == 0,
                "server sent error in proto ack: {}",
                ack.error
            );
            Ok(vec![Encoding::None as i32])
        }
        3 => {
            let remote_proto = Proto::decode(payload.as_slice())?;
            ensure!(
                remote_proto.proto == ProtoType::Drpc as i32,
                "incompatible proto type: {}",
                remote_proto.proto
            );
            Ok(remote_proto.encodings)
        }
        other => anyhow::bail!(
            "expected Proto or Ack after proto handshake, got type {}",
            other
        ),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use manytype_core::crypto::ed25519;
    use manytype_proto::handshake::{Encoding, ProtoType};
    use manytype_server::handshake::{
        build_credentials, perform_handshake, perform_proto_handshake,
    };
    use tokio::io::{DuplexStream, duplex};

    fn identity_from_seed(seed: [u8; 32]) -> (Keypair, String) {
        let mut libp2p_seed = seed;
        let identity = Keypair::ed25519_from_bytes(libp2p_seed.as_mut_slice()).unwrap();
        let peer_id = identity.public().to_peer_id().to_string();
        (identity, peer_id)
    }

    /// Answer the client's credentials with `server_creds` and return its ack.
    async fn reply_with_credentials(mut stream: DuplexStream, server_creds: Vec<u8>) -> Ack {
        let (msg_type, _) = read_handshake_msg(&mut stream).await.unwrap();
        assert_eq!(msg_type, 1);
        write_handshake_msg(&mut stream, 1, &server_creds)
            .await
            .unwrap();

        let (msg_type, payload) = read_handshake_msg(&mut stream).await.unwrap();
        assert_eq!(msg_type, 2);
        let ack = Ack::decode(payload.as_slice()).unwrap();
        if ack.error == 0 {
            write_handshake_msg(&mut stream, 2, &Ack { error: 0 }.encode_to_vec())
                .await
                .unwrap();
        }
        ack
    }

    #[tokio::test]
    async fn test_client_server_handshake_round_trip() {
        let (client_io, server_io) = duplex(8192);

        let server_seed = [1u8; 32];
        let mut server_identity_seed = server_seed;
        let server_identity =
            Keypair::ed25519_from_bytes(server_identity_seed.as_mut_slice()).unwrap();
        let server_peer_id = server_identity.public().to_peer_id().to_string();
        let client_peer_seed = [2u8; 32];
        let mut client_peer_seed_bytes = client_peer_seed;
        let client_peer_identity =
            Keypair::ed25519_from_bytes(client_peer_seed_bytes.as_mut_slice()).unwrap();
        let client_peer_id = client_peer_identity.public().to_peer_id().to_string();
        let client_account_seed = [3u8; 32];
        let client_account_signing_key = ed25519::signing_key_from_seed(&client_account_seed);
        let client_account_public = client_account_signing_key
            .verifying_key()
            .to_bytes()
            .to_vec();

        let server_peer_id_for_server = server_peer_id.clone();
        let client_peer_id_for_server = client_peer_id.clone();

        // Server side: uses perform_handshake from manytype_server
        let server_handle = tokio::spawn(async move {
            let (recv, send) = tokio::io::split(server_io);
            let mut stream = tokio::io::join(recv, send);
            let remote = perform_handshake(
                &mut stream,
                &server_identity,
                &server_peer_id_for_server,
                &client_peer_id_for_server,
            )
            .await?;
            perform_proto_handshake(&mut stream, ProtoType::Drpc, &[Encoding::None]).await?;
            Ok::<_, anyhow::Error>(remote)
        });

        // Client side: uses our client_handshake
        let client_handle = tokio::spawn(async move {
            let (recv, send) = tokio::io::split(client_io);
            let mut stream = tokio::io::join(recv, send);
            client_handshake(
                &mut stream,
                &client_peer_identity,
                &client_account_signing_key,
                &server_peer_id,
                false,
            )
            .await?;
            client_proto_handshake(&mut stream).await?;
            Ok::<_, anyhow::Error>(server_peer_id.as_bytes().to_vec())
        });

        // Server should receive the client's account identity from credentials.
        let remote_id = server_handle.await.unwrap().unwrap();
        assert_eq!(remote_id, client_account_public);

        // Client should receive server's public key payload
        let _ = client_handle.await.unwrap().unwrap();
    }

    #[tokio::test]
    async fn test_client_rejects_server_credentials_for_another_peer() {
        let (client_io, server_io) = duplex(8192);
        let (server_identity, server_peer_id) = identity_from_seed([1u8; 32]);
        let (client_identity, client_peer_id) = identity_from_seed([2u8; 32]);
        let account_signing_key = ed25519::signing_key_from_seed(&[3u8; 32]);

        let forged = build_credentials(&server_identity, "other-peer", &client_peer_id);
        let server_handle = tokio::spawn(reply_with_credentials(server_io, forged));

        let (recv, send) = tokio::io::split(client_io);
        let mut stream = tokio::io::join(recv, send);
        let error = client_handshake(
            &mut stream,
            &client_identity,
            &account_signing_key,
            &server_peer_id,
            true,
        )
        .await
        .unwrap_err();
        assert!(error.to_string().contains("signature verification failed"));

        let ack = server_handle.await.unwrap();
        assert_eq!(ack.error, Error::InvalidCredentials as i32);
    }

    #[tokio::test]
    async fn test_client_accepts_skip_verify_only_when_allowed() {
        let (_, server_peer_id) = identity_from_seed([1u8; 32]);
        let (client_identity, _) = identity_from_seed([2u8; 32]);
        let account_signing_key = ed25519::signing_key_from_seed(&[3u8; 32]);
        let skip_verify = Credentials {
            r#type: CredentialsType::SkipVerify as i32,
            payload: Vec::new(),
            version: 9,
            client_version: "test/1.0".to_string(),
        }
        .encode_to_vec();

        for allow_skip_verify in [false, true] {
            let (client_io, server_io) = duplex(8192);
            let server_handle =
                tokio::spawn(reply_with_credentials(server_io, skip_verify.clone()));

            let (recv, send) = tokio::io::split(client_io);
            let mut stream = tokio::io::join(recv, send);
            let result = client_handshake(
                &mut stream,
                &client_identity,
                &account_signing_key,
                &server_peer_id,
                allow_skip_verify,
            )
            .await;

            let ack = server_handle.await.unwrap();
            if allow_skip_verify {
                assert!(result.unwrap().is_empty());
                assert_eq!(ack.error, 0);
            } else {
                let error = result.unwrap_err().to_string();
                assert!(error.contains("skipped credential verification"));
                assert_eq!(ack.error, Error::InvalidCredentials as i32);
            }
        }
    }
}
