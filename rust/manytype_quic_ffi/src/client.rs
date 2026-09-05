//! QUIC client connection with libp2p TLS and ALPN "anysync".

use std::net::{IpAddr, Ipv4Addr, Ipv6Addr, SocketAddr};
use std::sync::Arc;
use std::time::Duration;

use anyhow::{Context, Result};
use libp2p_identity::Keypair;

use manytype_server::deadline::{self, DeadlineStage};
use manytype_server::drpc::stream::DrpcStream;

use super::handshake::{client_handshake, client_proto_handshake};
use crate::incoming::{ServedTreeCache, new_served_tree_cache, spawn_incoming_stream_server};

const CONNECTION_SETUP_TIMEOUT: Duration = Duration::from_secs(30);
const STREAM_SETUP_TIMEOUT: Duration = Duration::from_secs(30);

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
    deadline::result(
        DeadlineStage::ConnectionSetup,
        CONNECTION_SETUP_TIMEOUT,
        connect_and_handshake(addr, peer_signing_key, account_signing_key),
    )
    .await
}

async fn connect_and_handshake(
    addr: &str,
    peer_signing_key: &ed25519_dalek::SigningKey,
    account_signing_key: &ed25519_dalek::SigningKey,
) -> Result<ConnHandle> {
    trace(|| format!("connect start addr={addr}"));
    let mut peer_seed = peer_signing_key.to_bytes();
    let peer_keypair = Keypair::ed25519_from_bytes(peer_seed.as_mut_slice())
        .map_err(|e| anyhow::anyhow!("failed to derive libp2p identity from seed: {e}"))?;
    let client_config = make_client_config(&peer_keypair)?;

    let (remote_addrs, server_name) = resolve_target(addr).await?;
    let (endpoint, connection) = connect_quic(&remote_addrs, &server_name, client_config).await?;
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

/// Try each resolved address in turn on an endpoint of the matching family.
async fn connect_quic(
    remote_addrs: &[SocketAddr],
    server_name: &str,
    client_config: quinn::ClientConfig,
) -> Result<(quinn::Endpoint, quinn::Connection)> {
    let mut last_error = None;
    for &remote_addr in remote_addrs {
        match connect_quic_addr(remote_addr, server_name, client_config.clone()).await {
            Ok(connected) => return Ok(connected),
            Err(error) => {
                trace(|| format!("connect attempt-failed remote={remote_addr} error={error:#}"));
                last_error = Some(error);
            }
        }
    }
    Err(last_error.unwrap_or_else(|| anyhow::anyhow!("no addresses to connect to")))
}

async fn connect_quic_addr(
    remote_addr: SocketAddr,
    server_name: &str,
    client_config: quinn::ClientConfig,
) -> Result<(quinn::Endpoint, quinn::Connection)> {
    let bind_addr = if remote_addr.is_ipv6() {
        SocketAddr::from((Ipv6Addr::UNSPECIFIED, 0))
    } else {
        SocketAddr::from((Ipv4Addr::UNSPECIFIED, 0))
    };
    let mut endpoint =
        quinn::Endpoint::client(bind_addr).context("failed to create client endpoint")?;
    endpoint.set_default_client_config(client_config);

    let connection = endpoint
        .connect(remote_addr, server_name)?
        .await
        .with_context(|| format!("QUIC connection to {remote_addr} failed"))?;
    Ok((endpoint, connection))
}

/// Resolve `addr` to candidate socket addresses, IPv4 first like Go's
/// `net.ResolveUDPAddr("udp", ...)`, plus the TLS server name.
async fn resolve_target(addr: &str) -> Result<(Vec<SocketAddr>, String)> {
    if let Ok(socket_addr) = addr.parse::<SocketAddr>() {
        return Ok((vec![socket_addr], "localhost".to_string()));
    }

    let host = addr
        .strip_prefix('[')
        .and_then(|value| value.split_once("]:"))
        .map(|(host, _)| host.to_string())
        .or_else(|| addr.rsplit_once(':').map(|(host, _)| host.to_string()))
        .ok_or_else(|| anyhow::anyhow!("address is missing host:port"))?;

    let mut socket_addrs: Vec<SocketAddr> = tokio::net::lookup_host(addr)
        .await
        .context("failed to resolve remote address")?
        .collect();
    anyhow::ensure!(!socket_addrs.is_empty(), "resolved no addresses for {addr}");
    socket_addrs.sort_by_key(SocketAddr::is_ipv6);

    let server_name = if host.parse::<IpAddr>().is_ok() {
        "localhost".to_string()
    } else {
        host
    };

    Ok((socket_addrs, server_name))
}

pub async fn open_drpc_stream(
    connection: &quinn::Connection,
) -> Result<DrpcStream<tokio::io::Join<quinn::RecvStream, quinn::SendStream>>> {
    deadline::result(
        DeadlineStage::StreamSetup,
        STREAM_SETUP_TIMEOUT,
        open_and_negotiate(connection),
    )
    .await
}

async fn open_and_negotiate(
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

#[cfg(test)]
mod tests {
    use super::*;
    use manytype_core::crypto::ed25519;
    use manytype_server::handshake::perform_handshake;
    use manytype_server::transport::quic::{make_server_config, run_quic_listener};

    const SERVER_SEED: [u8; 32] = [7u8; 32];

    /// Accept connections and run the server side of the credential handshake.
    async fn spawn_handshake_server(bind_addr: &str) -> Result<(SocketAddr, String)> {
        let endpoint = run_quic_listener(bind_addr, make_server_config(&SERVER_SEED)?).await?;
        let local_addr = endpoint.local_addr()?;
        let mut seed = SERVER_SEED;
        let identity = Keypair::ed25519_from_bytes(seed.as_mut_slice())?;
        let peer_id = identity.public().to_peer_id().to_string();
        let local_peer_id = peer_id.clone();

        tokio::spawn(async move {
            while let Some(incoming) = endpoint.accept().await {
                let identity = identity.clone();
                let local_peer_id = local_peer_id.clone();
                tokio::spawn(async move {
                    let connection = incoming.await?;
                    let remote_peer_id = tls_peer_id(&connection)?;
                    let (send, recv) = connection.accept_bi().await?;
                    let mut stream = tokio::io::join(recv, send);
                    perform_handshake(&mut stream, &identity, &local_peer_id, &remote_peer_id)
                        .await?;
                    connection.closed().await;
                    Ok::<_, anyhow::Error>(())
                });
            }
        });

        Ok((local_addr, peer_id))
    }

    fn client_key() -> ed25519_dalek::SigningKey {
        ed25519::signing_key_from_seed(&[8u8; 32])
    }

    #[tokio::test]
    async fn connects_to_ipv6_literal() {
        let Ok((server_addr, _)) = spawn_handshake_server("[::1]:0").await else {
            return;
        };

        let handle = connect(&server_addr.to_string(), &client_key(), &client_key())
            .await
            .unwrap();
        assert_eq!(handle.connection.remote_address(), server_addr);
    }

    #[tokio::test]
    async fn connects_by_hostname() {
        let (server_addr, _) = spawn_handshake_server("127.0.0.1:0").await.unwrap();

        let handle = connect(
            &format!("localhost:{}", server_addr.port()),
            &client_key(),
            &client_key(),
        )
        .await
        .unwrap();
        assert_eq!(handle.connection.remote_address(), server_addr);
    }

    #[tokio::test]
    async fn resolve_target_orders_ipv4_first() {
        let (addrs, server_name) = resolve_target("localhost:4830").await.unwrap();
        assert_eq!(server_name, "localhost");
        assert!(!addrs.is_empty());
        assert!(addrs.is_sorted_by_key(SocketAddr::is_ipv6));
    }
}
