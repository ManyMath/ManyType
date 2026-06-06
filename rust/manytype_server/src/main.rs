//! Manytype server: all four any-sync node roles in a single binary.

mod config;
mod coordinator;
mod drpc;
mod handshake;
mod consensus;
mod file_node;
mod storage;
mod sync_node;
mod transport;

use std::sync::Arc;

use anyhow::Result;
use libp2p_identity::Keypair;
use manytype_core::crypto::ed25519;
use manytype_proto::handshake::{Encoding, ProtoType};

fn is_benign_connection_error(error: &anyhow::Error) -> bool {
    use std::io::ErrorKind;

    let message = error.to_string();
    if message.contains("connection closed before invoke")
        || message.contains("connection closed mid-message")
    {
        return true;
    }

    error.chain().any(|cause| {
        if let Some(io_error) = cause.downcast_ref::<std::io::Error>() {
            return matches!(
                io_error.kind(),
                ErrorKind::BrokenPipe
                    | ErrorKind::ConnectionAborted
                    | ErrorKind::ConnectionReset
                    | ErrorKind::UnexpectedEof
                    | ErrorKind::NotConnected
            );
        }

        if let Some(connection_error) = cause.downcast_ref::<quinn::ConnectionError>() {
            return matches!(
                connection_error,
                quinn::ConnectionError::ApplicationClosed(_)
                    | quinn::ConnectionError::ConnectionClosed(_)
                    | quinn::ConnectionError::LocallyClosed
                    | quinn::ConnectionError::TimedOut
                    | quinn::ConnectionError::Reset
            );
        }

        if let Some(write_error) = cause.downcast_ref::<quinn::WriteError>() {
            return matches!(
                write_error,
                quinn::WriteError::ConnectionLost(_)
                    | quinn::WriteError::ClosedStream
                    | quinn::WriteError::Stopped(_)
                    | quinn::WriteError::ZeroRttRejected
            );
        }

        false
    })
}

#[tokio::main]
async fn main() -> Result<()> {
    // Initialize tracing
    tracing_subscriber::fmt().with_env_filter("info").init();

    // Load config
    let config_path = std::env::args()
        .nth(1)
        .unwrap_or_else(|| "config.toml".to_string());
    let config = config::ServerConfig::load(&config_path)?;

    // Derive signing key from identity seed
    let seed_bytes = hex::decode(&config.identity_seed)?;
    let seed: [u8; 32] = seed_bytes
        .try_into()
        .map_err(|v: Vec<u8>| anyhow::anyhow!("identity_seed must be 32 bytes, got {}", v.len()))?;
    let signing_key = ed25519::signing_key_from_seed(&seed);
    let mut libp2p_seed = seed;
    let local_identity_keypair = Keypair::ed25519_from_bytes(libp2p_seed.as_mut_slice())
        .map_err(|e| anyhow::anyhow!("failed to derive libp2p identity from seed: {e}"))?;
    let local_peer_id_libp2p = local_identity_keypair.public().to_peer_id().to_string();
    let default_seed_hex = "0101010101010101010101010101010101010101010101010101010101010101";
    if config.identity_seed == default_seed_hex {
        tracing::warn!(
            "Server is using the default identity seed; change identity_seed in config for production use"
        );
    }

    let sync_state = sync_node::SharedSyncState::open(&config.db_path)?;
    let file_node = file_node::FileNodeState::open(&config.db_path)?;
    tracing::info!("Opened sync state at {}", config.db_path);
    tracing::info!("Server peer ID: {}", local_peer_id_libp2p);

    // Build shared server state
    let state = Arc::new(drpc::router::ServerState {
        coordinator_config: coordinator::CoordinatorConfig {
            network_id: config.network_id.clone(),
            peer_id: local_peer_id_libp2p.clone(),
            addresses: vec![
                config.quic_listen.clone(),
                format!("quic://{}", config.quic_listen),
            ],
        },
        sync_state,
        file_node,
        local_signing_key: signing_key.clone(),
    });

    // Start QUIC listener
    let server_config = transport::quic::make_server_config(&seed)?;
    let endpoint = transport::quic::run_quic_listener(&config.quic_listen, server_config).await?;
    tracing::info!("Listening on QUIC {}", config.quic_listen);

    // Accept connections
    while let Some(incoming) = endpoint.accept().await {
        let local_peer_id_libp2p = local_peer_id_libp2p.clone();
        let local_identity_keypair = local_identity_keypair.clone();
        let state = Arc::clone(&state);
        tokio::spawn(async move {
            if let Err(e) = handle_connection(
                incoming,
                local_peer_id_libp2p,
                local_identity_keypair,
                state,
            )
            .await
            {
                tracing::error!("Connection error: {}", e);
            }
        });
    }

    Ok(())
}

async fn handle_connection(
    incoming: quinn::Incoming,
    local_peer_id_libp2p: String,
    local_identity_keypair: Keypair,
    state: Arc<drpc::router::ServerState>,
) -> Result<()> {
    let connection = incoming.await?;
    let remote_tls_peer_id = tls_peer_id(&connection)?;
    tracing::info!("New connection from {}", connection.remote_address());

    let (handshake_send, handshake_recv) = connection.accept_bi().await?;
    let mut handshake_stream = tokio::io::join(handshake_recv, handshake_send);
    let remote_peer_id = handshake::perform_handshake(
        &mut handshake_stream,
        &local_identity_keypair,
        &local_peer_id_libp2p,
        &remote_tls_peer_id,
    )
    .await?;
    tracing::info!(
        "Credential handshake complete with peer {}",
        remote_tls_peer_id
    );

    loop {
        let (send, recv) = match connection.accept_bi().await {
            Ok(streams) => streams,
            Err(quinn::ConnectionError::ApplicationClosed(_)) => {
                tracing::info!("Connection closed by peer");
                return Ok(());
            }
            Err(e) => return Err(e.into()),
        };

        let remote_tls_peer_id = remote_tls_peer_id.clone();
        let remote_peer_id = remote_peer_id.clone();
        let state = Arc::clone(&state);
        tokio::spawn(async move {
            if let Err(e) =
                handle_stream(send, recv, remote_tls_peer_id, remote_peer_id, state).await
            {
                if is_benign_connection_error(&e) {
                    tracing::info!("Stream closed by peer");
                    return;
                }
                tracing::error!("Stream error: {}", e);
            }
        });
    }
}

async fn handle_stream(
    send: quinn::SendStream,
    recv: quinn::RecvStream,
    remote_tls_peer_id: String,
    _remote_peer_id: Vec<u8>,
    state: Arc<drpc::router::ServerState>,
) -> Result<()> {
    let mut stream = tokio::io::join(recv, send);
    let trace_file_rpcs = std::env::var_os("MANYTYPE_TRACE_FILE_RPCS").is_some();

    handshake::perform_proto_handshake(&mut stream, ProtoType::Drpc, &[Encoding::None]).await?;
    tracing::info!("Proto handshake complete with peer {}", remote_tls_peer_id);

    // Transition to DRPC dispatch
    let mut drpc_stream = drpc::stream::DrpcStream::new(stream);

    loop {
        let (stream_id, method) = match drpc_stream.read_invoke().await {
            Ok(values) => values,
            Err(error) if is_benign_connection_error(&error) => return Ok(()),
            Err(error) => return Err(error),
        };
        if trace_file_rpcs && method.starts_with("/filesync.File/") {
            tracing::info!(
                "File RPC invoke: method={} peer={} stream_id={}",
                method,
                remote_tls_peer_id,
                stream_id
            );
        }
        if let Err(e) = drpc::router::dispatch(
            stream_id,
            &method,
            &mut drpc_stream,
            &state,
            &remote_tls_peer_id,
        )
        .await
        {
            if is_benign_connection_error(&e) {
                return Ok(());
            }
            tracing::error!("RPC error on {}: {}", method, e);
        }
    }
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
