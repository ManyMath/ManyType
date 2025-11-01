//! QUIC transport layer using libp2p-compatible TLS over QUIC.

use std::net::SocketAddr;
use std::sync::Arc;

use anyhow::{Context, Result};
use libp2p_identity::Keypair;

/// Build a quinn ServerConfig with a libp2p-compliant certificate bound to the node identity.
pub fn make_server_config(identity_seed: &[u8; 32]) -> Result<quinn::ServerConfig> {
    let mut seed = *identity_seed;
    let identity_keypair = Keypair::ed25519_from_bytes(seed.as_mut_slice())
        .map_err(|e| anyhow::anyhow!("failed to derive libp2p identity from seed: {e}"))?;
    let mut tls_config = libp2p_tls::make_server_config(&identity_keypair)
        .context("failed to build libp2p TLS server config")?;
    tls_config.alpn_protocols = vec![b"anysync".to_vec()];

    let quic_server_config =
        quinn::crypto::rustls::QuicServerConfig::try_from(Arc::new(tls_config))
            .context("failed to create QUIC server config from TLS config")?;

    Ok(quinn::ServerConfig::with_crypto(Arc::new(
        quic_server_config,
    )))
}

/// Create a QUIC endpoint listening on the given address.
pub async fn run_quic_listener(
    addr: &str,
    server_config: quinn::ServerConfig,
) -> Result<quinn::Endpoint> {
    let socket_addr: SocketAddr = addr
        .parse()
        .context("failed to parse QUIC listen address")?;
    quinn::Endpoint::server(server_config, socket_addr).context("failed to create QUIC endpoint")
}
