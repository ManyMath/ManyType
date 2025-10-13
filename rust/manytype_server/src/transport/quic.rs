//! QUIC transport layer using quinn with ALPN "anysync".

use std::net::SocketAddr;
use std::sync::Arc;

use anyhow::{Context, Result};

/// Build a quinn ServerConfig with a self-signed certificate and ALPN "anysync".
pub fn make_server_config() -> Result<quinn::ServerConfig> {
    // Generate self-signed certificate
    let certified_key = rcgen::generate_simple_self_signed(vec!["localhost".to_string()])
        .context("failed to generate self-signed certificate")?;

    let cert_der = certified_key.cert.der().clone();
    let key_der =
        rustls::pki_types::PrivatePkcs8KeyDer::from(certified_key.signing_key.serialize_der());

    // Build rustls ServerConfig
    let mut tls_config = rustls::ServerConfig::builder()
        .with_no_client_auth()
        .with_single_cert(vec![cert_der], key_der.into())
        .context("failed to build TLS server config")?;

    // Set ALPN protocol identifier
    tls_config.alpn_protocols = vec![b"anysync".to_vec()];

    let quic_server_config = quinn::crypto::rustls::QuicServerConfig::try_from(Arc::new(tls_config))
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
    let endpoint = quinn::Endpoint::server(server_config, socket_addr)
        .context("failed to create QUIC endpoint")?;
    Ok(endpoint)
}
