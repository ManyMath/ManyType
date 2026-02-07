//! QUIC client connection with libp2p TLS and ALPN "anysync".

use std::net::{IpAddr, SocketAddr};
use std::sync::Arc;

use anyhow::{Context, Result};
use libp2p_identity::Keypair;

use manytype_server::drpc::stream::DrpcStream;

use super::handshake::{client_handshake, client_proto_handshake};
use crate::incoming::{ServedTreeCache, new_served_tree_cache, spawn_incoming_stream_server};

fn trace(message: impl FnOnce() -> String) {
    if std::env::var_os("MANYTYPE_QUIC_TRACE").is_some() {
        eprintln!("[manytype_quic_ffi::client] {}", message());
    }
}

/// Build a quinn ClientConfig with libp2p TLS and ALPN "anysync".
fn make_client_config(identity_keypair: &Keypair) -> Result<quinn::ClientConfig> {
    let mut tls_config = libp2p_tls::make_client_config(identity_keypair, None)
        .context("failed to build libp2p TLS client config")?;

    tls_config.alpn_protocols = vec![b"anysync".to_vec()];

    let quic_client_config =
        quinn::crypto::rustls::QuicClientConfig::try_from(Arc::new(tls_config))
            .context("failed to create QUIC client config from TLS config")?;

    Ok(quinn::ClientConfig::new(Arc::new(quic_client_config)))
}

/// Opaque handle to an established connection with completed handshake.
///
/// Holds the QUIC connection and endpoint needed to open follow-on substreams.
pub struct ConnHandle {
    #[allow(dead_code)]
    pub endpoint: quinn::Endpoint,
    pub connection: quinn::Connection,
    pub served_trees: ServedTreeCache,
}

/// Connect to a QUIC server, perform credential handshake, return a ConnHandle.
pub async fn connect(
    addr: &str,
    peer_signing_key: &ed25519_dalek::SigningKey,
    account_signing_key: &ed25519_dalek::SigningKey,
) -> Result<ConnHandle> {
    trace(|| format!("connect start addr={addr}"));
    let mut peer_seed = peer_signing_key.to_bytes();
    let peer_keypair = Keypair::ed25519_from_bytes(peer_seed.as_mut_slice())
        .map_err(|e| anyhow::anyhow!("failed to derive libp2p identity from seed: {e}"))?;
    let client_config = make_client_config(&peer_keypair)?;

    let mut endpoint = quinn::Endpoint::client("0.0.0.0:0".parse()?)
        .context("failed to create client endpoint")?;
    endpoint.set_default_client_config(client_config);

    let (remote_addr, server_name) = resolve_target(addr).await?;
    let connection = endpoint
        .connect(remote_addr, &server_name)?
        .await
        .context("QUIC connection failed")?;
    trace(|| {
        format!(
            "connect quic-established addr={addr} remote={}",
            connection.remote_address()
        )
    });
    let server_peer_id = tls_peer_id(&connection)?;
    trace(|| format!("connect tls-peer-id addr={addr} peer_id={server_peer_id}"));

    let (send, recv) = connection
        .open_bi()
        .await
        .context("failed to open bidi stream")?;
    trace(|| format!("connect opened-handshake-stream addr={addr}"));

    let mut stream = tokio::io::join(recv, send);

    // Perform client-side credential handshake
    let _server_peer_id = client_handshake(
        &mut stream,
        &peer_keypair,
        account_signing_key,
        &server_peer_id,
    )
    .await
    .context("credential handshake failed")?;
    trace(|| format!("connect credential-handshake-complete addr={addr}"));

    let served_trees = new_served_tree_cache();
    spawn_incoming_stream_server(connection.clone(), Arc::clone(&served_trees));

    Ok(ConnHandle {
        endpoint,
        connection,
        served_trees,
    })
}

async fn resolve_target(addr: &str) -> Result<(SocketAddr, String)> {
    if let Ok(socket_addr) = addr.parse::<SocketAddr>() {
        return Ok((socket_addr, "localhost".to_string()));
    }

    let host = addr
        .strip_prefix('[')
        .and_then(|value| value.split_once("]:"))
        .map(|(host, _)| host.to_string())
        .or_else(|| addr.rsplit_once(':').map(|(host, _)| host.to_string()))
        .ok_or_else(|| anyhow::anyhow!("address is missing host:port"))?;

    let socket_addr = tokio::net::lookup_host(addr)
        .await
        .context("failed to resolve remote address")?
        .next()
        .ok_or_else(|| anyhow::anyhow!("resolved no addresses for {addr}"))?;

    let server_name = if host.parse::<IpAddr>().is_ok() {
        "localhost".to_string()
    } else {
        host
    };

    Ok((socket_addr, server_name))
}

pub async fn open_drpc_stream(
    connection: &quinn::Connection,
) -> Result<DrpcStream<tokio::io::Join<quinn::RecvStream, quinn::SendStream>>> {
    let (send, recv) = connection
        .open_bi()
        .await
        .context("failed to open DRPC bidi stream")?;
    trace(|| {
        format!(
            "open_drpc_stream opened remote={}",
            connection.remote_address()
        )
    });
    let mut stream = tokio::io::join(recv, send);
    client_proto_handshake(&mut stream)
        .await
        .context("proto handshake failed")?;
    trace(|| {
        format!(
            "open_drpc_stream proto-handshake-complete remote={}",
            connection.remote_address()
        )
    });
    Ok(DrpcStream::new(stream))
}

fn tls_peer_id(connection: &quinn::Connection) -> Result<String> {
    let identity = connection
        .peer_identity()
        .ok_or_else(|| anyhow::anyhow!("peer did not present a TLS identity"))?;
    let certs = identity
        .downcast::<Vec<rustls::pki_types::CertificateDer<'static>>>()
        .map_err(|_| anyhow::anyhow!("unexpected peer identity type"))?;
    let cert = certs
        .first()
        .ok_or_else(|| anyhow::anyhow!("peer certificate chain was empty"))?;
    let cert = libp2p_tls::certificate::parse(cert)
        .map_err(|e| anyhow::anyhow!("invalid libp2p TLS certificate: {e}"))?;
    Ok(cert.peer_id().to_string())
}
