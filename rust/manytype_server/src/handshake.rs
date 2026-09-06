//! Credential handshake protocol over 5-byte header framing.
//!
//! Implements the Anytype credential handshake:
//! 1. Client -> Server: Credentials
//! 2. Server -> Client: Credentials
//! 3. Client -> Server: Ack (error=Null)
//! 4. Server -> Client: Ack (error=Null)
//!
//! Header format: [type: u8][length: u32 LE]
//! Type 1 = Credentials, Type 2 = Ack, Type 3 = Proto

use anyhow::Result;
use libp2p_identity::Keypair;
use manytype_core::crypto::ed25519;
use manytype_proto::handshake::{
    Ack, Credentials, CredentialsType, Encoding, PayloadSignedPeerIds, Proto, ProtoType,
};
use prost::{Enumeration, Message};
use tokio::io::{AsyncReadExt, AsyncWriteExt};

const MSG_TYPE_CREDENTIALS: u8 = 1;
const MSG_TYPE_ACK: u8 = 2;
const MSG_TYPE_PROTO: u8 = 3;
const MAX_HANDSHAKE_MSG_SIZE: u32 = 204800; // 200 KB

#[derive(Clone, Copy, Debug, PartialEq, Eq, Enumeration)]
enum AnysyncKeyType {
    Ed25519Public = 0,
    Ed25519Private = 1,
    Aes = 2,
}

#[derive(Clone, PartialEq, Message)]
struct AnysyncKey {
    #[prost(enumeration = "AnysyncKeyType", tag = "1")]
    r#type: i32,
    #[prost(bytes = "vec", tag = "2")]
    data: Vec<u8>,
}

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
    identity_keypair: &Keypair,
    local_peer_id: &str,
    remote_peer_id: &str,
) -> Vec<u8> {
    let signed_peer_ids = PayloadSignedPeerIds {
        identity: encode_anysync_public_key(identity_keypair),
        sign: identity_keypair
            .sign(format!("{local_peer_id}{remote_peer_id}").as_bytes())
            .expect("ed25519 identity key should sign"),
    };

    let credentials = Credentials {
        r#type: CredentialsType::SignedPeerIds as i32,
        payload: signed_peer_ids.encode_to_vec(),
        version: 9,
        client_version: "manytype/2.0".to_string(),
    };
    credentials.encode_to_vec()
}

/// Perform server-side (responder) credential handshake.
///
/// Returns the remote peer's identity bytes on success.
pub async fn perform_handshake(
    stream: &mut (impl tokio::io::AsyncRead + tokio::io::AsyncWrite + Unpin),
    identity_keypair: &Keypair,
    local_peer_id: &str,
    remote_peer_id: &str,
) -> Result<Vec<u8>> {
    // 1. Read client Credentials
    let (msg_type, payload) = read_handshake_msg(stream).await?;
    anyhow::ensure!(
        msg_type == MSG_TYPE_CREDENTIALS,
        "expected Credentials, got type {}",
        msg_type
    );
    let client_creds = Credentials::decode(payload.as_slice())?;

    // Validate client version is in the compatible set [8, 9, 12]
    const COMPATIBLE_VERSIONS: &[u32] = &[8, 9, 12];
    if !COMPATIBLE_VERSIONS.contains(&client_creds.version) {
        let reject_ack = Ack {
            error: manytype_proto::handshake::Error::IncompatibleVersion as i32,
        };
        write_handshake_msg(stream, MSG_TYPE_ACK, &reject_ack.encode_to_vec()).await?;
        anyhow::bail!(
            "incompatible credential version {}: must be one of {:?}",
            client_creds.version,
            COMPATIBLE_VERSIONS
        );
    }

    let remote_identity = match CredentialsType::try_from(client_creds.r#type) {
        Ok(CredentialsType::SignedPeerIds) => {
            let client_signed = PayloadSignedPeerIds::decode(client_creds.payload.as_slice())?;
            verify_signed_peer_ids(&client_signed, remote_peer_id, local_peer_id)?
        }
        Ok(CredentialsType::SkipVerify) => Vec::new(),
        _ => anyhow::bail!("unsupported credential type {}", client_creds.r#type),
    };

    // 2. Send our Credentials
    let our_creds = build_credentials(identity_keypair, local_peer_id, remote_peer_id);
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

    Ok(remote_identity)
}

/// Perform the per-stream Proto handshake after a connection-level credential handshake.
pub async fn perform_proto_handshake(
    stream: &mut (impl tokio::io::AsyncRead + tokio::io::AsyncWrite + Unpin),
    expected_proto: ProtoType,
    supported_encodings: &[Encoding],
) -> Result<Vec<i32>> {
    let (msg_type, payload) = read_handshake_msg(stream).await?;
    anyhow::ensure!(
        msg_type == MSG_TYPE_PROTO,
        "expected Proto (type 3), got type {}",
        msg_type
    );
    let remote_proto = Proto::decode(payload.as_slice())?;
    if remote_proto.proto != expected_proto as i32 {
        let ack = Ack {
            error: manytype_proto::handshake::Error::IncompatibleProto as i32,
        };
        write_handshake_msg(stream, MSG_TYPE_ACK, &ack.encode_to_vec()).await?;
        anyhow::bail!("incompatible proto type: {}", remote_proto.proto);
    }

    if remote_proto.encodings.is_empty() {
        let ack = Ack { error: 0 };
        write_handshake_msg(stream, MSG_TYPE_ACK, &ack.encode_to_vec()).await?;
        return Ok(vec![Encoding::None as i32]);
    }

    let chosen = remote_proto
        .encodings
        .iter()
        .copied()
        .find(|encoding| {
            supported_encodings
                .iter()
                .any(|supported| *encoding == *supported as i32)
        })
        .map(|encoding| vec![encoding])
        .unwrap_or_else(|| vec![Encoding::None as i32]);

    let response = Proto {
        proto: expected_proto as i32,
        encodings: chosen.clone(),
    };
    write_handshake_msg(stream, MSG_TYPE_PROTO, &response.encode_to_vec()).await?;

    Ok(chosen)
}

/// Verify a remote peer's signature over `{remote_peer_id}{local_peer_id}`.
///
/// Returns the remote peer's raw Ed25519 identity key on success.
pub fn verify_signed_peer_ids(
    signed_peer_ids: &PayloadSignedPeerIds,
    remote_peer_id: &str,
    local_peer_id: &str,
) -> Result<Vec<u8>> {
    let public_key = decode_anysync_public_key(&signed_peer_ids.identity)?;
    let verifying_key = ed25519_dalek::VerifyingKey::from_bytes(&public_key)
        .map_err(|e| anyhow::anyhow!("invalid ed25519 public key: {e}"))?;
    let signature = ed25519_dalek::Signature::from_bytes(
        &signed_peer_ids
            .sign
            .as_slice()
            .try_into()
            .map_err(|_| anyhow::anyhow!("invalid ed25519 signature length"))?,
    );
    anyhow::ensure!(
        ed25519::verify(
            &verifying_key,
            format!("{remote_peer_id}{local_peer_id}").as_bytes(),
            &signature,
        ),
        "credential signature verification failed"
    );
    Ok(public_key.to_vec())
}

fn encode_anysync_public_key(identity_keypair: &Keypair) -> Vec<u8> {
    let public_key = identity_keypair
        .public()
        .try_into_ed25519()
        .expect("identity key should be ed25519")
        .to_bytes()
        .to_vec();
    AnysyncKey {
        r#type: AnysyncKeyType::Ed25519Public as i32,
        data: public_key,
    }
    .encode_to_vec()
}

fn decode_anysync_public_key(bytes: &[u8]) -> Result<[u8; 32]> {
    let key = AnysyncKey::decode(bytes)?;
    anyhow::ensure!(
        key.r#type == AnysyncKeyType::Ed25519Public as i32,
        "credential identity must be an Ed25519 public key"
    );
    key.data
        .as_slice()
        .try_into()
        .map_err(|_| anyhow::anyhow!("credential identity must be 32 bytes"))
}

#[cfg(test)]
mod tests {
    use super::*;
    use tokio::io::duplex;

    fn identity_from_seed(seed: [u8; 32]) -> (Keypair, String, Vec<u8>) {
        let mut libp2p_seed = seed;
        let identity = Keypair::ed25519_from_bytes(libp2p_seed.as_mut_slice()).unwrap();
        let peer_id = identity.public().to_peer_id().to_string();
        let raw_public = identity
            .public()
            .try_into_ed25519()
            .unwrap()
            .to_bytes()
            .to_vec();
        (identity, peer_id, raw_public)
    }

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
        let mut libp2p_seed = seed;
        let identity_keypair = Keypair::ed25519_from_bytes(libp2p_seed.as_mut_slice()).unwrap();
        let local_peer_id = "local-peer";
        let remote_peer_id = "remote-peer";

        let creds_bytes = build_credentials(&identity_keypair, local_peer_id, remote_peer_id);

        // Decode and verify
        let creds = Credentials::decode(creds_bytes.as_slice()).unwrap();
        assert_eq!(creds.r#type, CredentialsType::SignedPeerIds as i32);
        assert_eq!(creds.version, 9);
        assert_eq!(creds.client_version, "manytype/2.0");

        // Verify payload contains identity and valid signature
        let signed = PayloadSignedPeerIds::decode(creds.payload.as_slice()).unwrap();
        assert_eq!(
            signed.identity,
            encode_anysync_public_key(&identity_keypair)
        );
        assert_eq!(signed.sign.len(), 64);
        let decoded_key = decode_anysync_public_key(&signed.identity).unwrap();
        let verifying_key = ed25519_dalek::VerifyingKey::from_bytes(&decoded_key).unwrap();
        let signature =
            ed25519_dalek::Signature::from_bytes(&signed.sign.as_slice().try_into().unwrap());
        assert!(ed25519::verify(
            &verifying_key,
            format!("{local_peer_id}{remote_peer_id}").as_bytes(),
            &signature
        ));
    }

    #[tokio::test]
    async fn test_full_handshake_round_trip() {
        let (client_io, server_io) = duplex(8192);

        let (server_identity, server_peer_id, _) = identity_from_seed([1u8; 32]);
        let (client_identity, client_peer_id, client_raw_identity) = identity_from_seed([2u8; 32]);
        let server_peer_id_for_server = server_peer_id.clone();
        let client_peer_id_for_server = client_peer_id.clone();
        let server_peer_id_for_client = server_peer_id.clone();
        let client_peer_id_for_client = client_peer_id.clone();

        // Server side
        let server_handle = tokio::spawn(async move {
            let (recv, send) = tokio::io::split(server_io);
            let mut stream = tokio::io::join(recv, send);
            perform_handshake(
                &mut stream,
                &server_identity,
                &server_peer_id_for_server,
                &client_peer_id_for_server,
            )
            .await
        });

        // Client side (simulates the 4-step credential handshake)
        let client_handle = tokio::spawn(async move {
            let (recv, send) = tokio::io::split(client_io);
            let mut stream = tokio::io::join(recv, send);

            // 1. Client sends Credentials
            let creds = build_credentials(
                &client_identity,
                &client_peer_id_for_client,
                &server_peer_id_for_client,
            );
            write_handshake_msg(&mut stream, MSG_TYPE_CREDENTIALS, &creds)
                .await
                .unwrap();

            // 2. Client reads server Credentials
            let (msg_type, _payload) = read_handshake_msg(&mut stream).await.unwrap();
            assert_eq!(msg_type, MSG_TYPE_CREDENTIALS);

            // 3. Client sends Ack (success)
            let ack = Ack { error: 0 };
            write_handshake_msg(&mut stream, MSG_TYPE_ACK, &ack.encode_to_vec())
                .await
                .unwrap();

            // 4. Client reads server Ack
            let (msg_type, payload) = read_handshake_msg(&mut stream).await.unwrap();
            assert_eq!(msg_type, MSG_TYPE_ACK);
            let ack = Ack::decode(payload.as_slice()).unwrap();
            assert_eq!(ack.error, 0);
        });

        let remote_id = server_handle.await.unwrap().unwrap();
        assert_eq!(remote_id, client_raw_identity);
        client_handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_version_validation_boundary() {
        let (server_identity, server_peer_id, _) = identity_from_seed([1u8; 32]);
        let (client_identity, client_peer_id, _) = identity_from_seed([2u8; 32]);

        // versions to test: (version, should_accept)
        for (version, should_accept) in [
            (7u32, false),
            (8u32, true),
            (9u32, true),
            (12u32, true),
            (13u32, false),
        ] {
            let (client_io, server_io) = duplex(8192);

            let identity = server_identity.clone();
            let local_peer_id = server_peer_id.clone();
            let remote_peer_id = client_peer_id.clone();

            let server_handle = tokio::spawn(async move {
                let (recv, send) = tokio::io::split(server_io);
                let mut stream = tokio::io::join(recv, send);
                perform_handshake(&mut stream, &identity, &local_peer_id, &remote_peer_id).await
            });

            let client_identity = client_identity.clone();
            let client_peer_id = client_peer_id.clone();
            let server_peer_id = server_peer_id.clone();
            let client_handle = tokio::spawn(async move {
                let (recv, send) = tokio::io::split(client_io);
                let mut stream = tokio::io::join(recv, send);

                // Build credentials with the test version
                let signed_peer_ids = manytype_proto::handshake::PayloadSignedPeerIds {
                    identity: encode_anysync_public_key(&client_identity),
                    sign: client_identity
                        .sign(format!("{client_peer_id}{server_peer_id}").as_bytes())
                        .unwrap(),
                };
                let creds = Credentials {
                    r#type: CredentialsType::SignedPeerIds as i32,
                    payload: signed_peer_ids.encode_to_vec(),
                    version,
                    client_version: "test/1.0".to_string(),
                };
                write_handshake_msg(&mut stream, MSG_TYPE_CREDENTIALS, &creds.encode_to_vec())
                    .await
                    .unwrap();

                // If rejected, server sends an Ack with error before closing
                // If accepted, server sends its Credentials next
                let (msg_type, payload) = read_handshake_msg(&mut stream).await.unwrap();
                if msg_type == MSG_TYPE_ACK {
                    // Rejection path: Ack with error
                    let ack = Ack::decode(payload.as_slice()).unwrap();
                    assert!(
                        ack.error != 0,
                        "version {} should have been rejected but got success Ack",
                        version
                    );
                    (false, ack.error)
                } else {
                    // Acceptance path: got Credentials back
                    assert_eq!(msg_type, MSG_TYPE_CREDENTIALS);
                    (true, 0)
                }
            });

            let server_result = server_handle.await.unwrap();
            let (client_accepted, _) = client_handle.await.unwrap();

            if should_accept {
                // Server and client may both error here since the client doesn't finish the handshake
                // The key assertion: server didn't reject with IncompatibleVersion
                assert!(
                    client_accepted,
                    "version {} should be accepted but was rejected",
                    version
                );
            } else {
                assert!(
                    server_result.is_err(),
                    "version {} should have caused server to return Err, but it returned Ok",
                    version
                );
                assert!(
                    !client_accepted,
                    "version {} should be rejected but was accepted",
                    version
                );
            }
        }
    }

    #[tokio::test]
    async fn test_proto_step_negotiation() {
        let (client_io, server_io) = duplex(8192);

        let server_handle = tokio::spawn(async move {
            let (recv, send) = tokio::io::split(server_io);
            let mut stream = tokio::io::join(recv, send);
            perform_proto_handshake(&mut stream, ProtoType::Drpc, &[Encoding::None]).await
        });

        let client_handle = tokio::spawn(async move {
            let (recv, send) = tokio::io::split(client_io);
            let mut stream = tokio::io::join(recv, send);

            // Proto exchange: client sends first, then reads
            let proto_msg = Proto {
                proto: ProtoType::Drpc as i32,
                encodings: vec![Encoding::None as i32],
            };
            write_handshake_msg(&mut stream, MSG_TYPE_PROTO, &proto_msg.encode_to_vec())
                .await
                .unwrap();
            let (msg_type, payload) = read_handshake_msg(&mut stream).await.unwrap();
            assert_eq!(
                msg_type, MSG_TYPE_PROTO,
                "server should send Proto (type 3)"
            );
            let server_proto = Proto::decode(payload.as_slice()).unwrap();
            assert_eq!(
                server_proto.proto,
                ProtoType::Drpc as i32,
                "server Proto should be DRPC"
            );
            assert_eq!(
                server_proto.encodings,
                vec![Encoding::None as i32],
                "server should advertise [None] encoding only"
            );
        });

        let encodings = server_handle.await.unwrap().unwrap();
        assert_eq!(encodings, vec![Encoding::None as i32]);
        client_handle.await.unwrap();
    }

    #[tokio::test]
    async fn test_proto_step_negotiates_down_from_snappy() {
        let (client_io, server_io) = duplex(8192);

        let server_handle = tokio::spawn(async move {
            let (recv, send) = tokio::io::split(server_io);
            let mut stream = tokio::io::join(recv, send);
            perform_proto_handshake(&mut stream, ProtoType::Drpc, &[Encoding::None]).await
        });

        let client_handle = tokio::spawn(async move {
            let (recv, send) = tokio::io::split(client_io);
            let mut stream = tokio::io::join(recv, send);

            let proto_msg = Proto {
                proto: ProtoType::Drpc as i32,
                encodings: vec![Encoding::Snappy as i32],
            };
            write_handshake_msg(&mut stream, MSG_TYPE_PROTO, &proto_msg.encode_to_vec())
                .await
                .unwrap();
            let (msg_type, payload) = read_handshake_msg(&mut stream).await.unwrap();
            assert_eq!(msg_type, MSG_TYPE_PROTO);
            let server_proto = Proto::decode(payload.as_slice()).unwrap();
            assert_eq!(server_proto.proto, ProtoType::Drpc as i32);
            assert_eq!(server_proto.encodings, vec![Encoding::None as i32]);
        });

        let encodings = server_handle.await.unwrap().unwrap();
        assert_eq!(encodings, vec![Encoding::None as i32]);
        client_handle.await.unwrap();
    }
}
