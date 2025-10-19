//! QUIC client connection with skip-verify TLS and ALPN "anysync".

use std::sync::Arc;

use anyhow::{Context, Result};
use rustls::client::danger::{HandshakeSignatureValid, ServerCertVerified, ServerCertVerifier};
use rustls::pki_types::{CertificateDer, ServerName, UnixTime};
use rustls::{DigitallySignedStruct, Error, SignatureScheme};

use manytype_server::drpc::stream::DrpcStream;

use super::handshake::client_handshake;

/// Skip all TLS certificate verification (v1 self-signed certs).
#[derive(Debug)]
struct SkipServerVerification;

impl ServerCertVerifier for SkipServerVerification {
    fn verify_server_cert(
        &self,
        _end_entity: &CertificateDer<'_>,
        _intermediates: &[CertificateDer<'_>],
        _server_name: &ServerName<'_>,
        _ocsp_response: &[u8],
        _now: UnixTime,
    ) -> Result<ServerCertVerified, Error> {
        Ok(ServerCertVerified::assertion())
    }

    fn verify_tls12_signature(
        &self,
        _message: &[u8],
        _cert: &CertificateDer<'_>,
        _dss: &DigitallySignedStruct,
    ) -> Result<HandshakeSignatureValid, Error> {
        Ok(HandshakeSignatureValid::assertion())
    }

    fn verify_tls13_signature(
        &self,
        _message: &[u8],
        _cert: &CertificateDer<'_>,
        _dss: &DigitallySignedStruct,
    ) -> Result<HandshakeSignatureValid, Error> {
        Ok(HandshakeSignatureValid::assertion())
    }

    fn supported_verify_schemes(&self) -> Vec<SignatureScheme> {
        // Support all common schemes so TLS handshake succeeds
        vec![
            SignatureScheme::RSA_PKCS1_SHA256,
            SignatureScheme::RSA_PKCS1_SHA384,
            SignatureScheme::RSA_PKCS1_SHA512,
            SignatureScheme::ECDSA_NISTP256_SHA256,
            SignatureScheme::ECDSA_NISTP384_SHA384,
            SignatureScheme::RSA_PSS_SHA256,
            SignatureScheme::RSA_PSS_SHA384,
            SignatureScheme::RSA_PSS_SHA512,
            SignatureScheme::ED25519,
        ]
    }
}

/// Build a quinn ClientConfig with skip-verify TLS and ALPN "anysync".
fn make_client_config() -> Result<quinn::ClientConfig> {
    let mut tls_config = rustls::ClientConfig::builder()
        .dangerous()
        .with_custom_certificate_verifier(Arc::new(SkipServerVerification))
        .with_no_client_auth();

    tls_config.alpn_protocols = vec![b"anysync".to_vec()];

    let quic_client_config =
        quinn::crypto::rustls::QuicClientConfig::try_from(Arc::new(tls_config))
            .context("failed to create QUIC client config from TLS config")?;

    Ok(quinn::ClientConfig::new(Arc::new(quic_client_config)))
}

/// Opaque handle to an established connection with completed handshake.
///
/// Holds the QUIC connection, endpoint (to keep it alive), and the
/// DrpcStream wrapping the handshaked bidi stream.
pub struct ConnHandle {
    #[allow(dead_code)]
    pub endpoint: quinn::Endpoint,
    #[allow(dead_code)]
    pub connection: quinn::Connection,
    pub drpc_stream: DrpcStream<tokio::io::Join<quinn::RecvStream, quinn::SendStream>>,
}

/// Connect to a QUIC server, perform credential handshake, return a ConnHandle.
pub async fn connect(
    addr: &str,
    signing_key: &ed25519_dalek::SigningKey,
) -> Result<ConnHandle> {
    let client_config = make_client_config()?;

    let mut endpoint = quinn::Endpoint::client("0.0.0.0:0".parse()?)
        .context("failed to create client endpoint")?;
    endpoint.set_default_client_config(client_config);

    let connection = endpoint
        .connect(addr.parse()?, "localhost")?
        .await
        .context("QUIC connection failed")?;

    let (send, recv) = connection
        .open_bi()
        .await
        .context("failed to open bidi stream")?;

    let mut stream = tokio::io::join(recv, send);

    // Perform client-side credential handshake
    let _server_peer_id = client_handshake(&mut stream, signing_key)
        .await
        .context("credential handshake failed")?;

    let drpc_stream = DrpcStream::new(stream);

    Ok(ConnHandle {
        endpoint,
        connection,
        drpc_stream,
    })
}
