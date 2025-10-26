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
use manytype_core::crypto::ed25519;

#[tokio::main]
async fn main() -> Result<()> {
    // Initialize tracing
    tracing_subscriber::fmt()
        .with_env_filter("info")
        .init();

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
    let verifying_key = ed25519::verifying_key(&signing_key);
    let local_peer_id = verifying_key.to_bytes().to_vec();

    let sync_state = sync_node::SharedSyncState::open(&config.db_path)?;
    tracing::info!("Opened sync state at {}", config.db_path);

    // Build shared server state
    let state = Arc::new(drpc::router::ServerState {
        coordinator_config: coordinator::CoordinatorConfig {
            network_id: config.network_id.clone(),
            peer_id: hex::encode(&local_peer_id),
            addresses: vec![config.quic_listen.clone()],
        },
        sync_state,
        local_signing_key: signing_key.clone(),
    });

    // Start QUIC listener
    let server_config = transport::quic::make_server_config()?;
    let endpoint = transport::quic::run_quic_listener(&config.quic_listen, server_config).await?;
    tracing::info!("Listening on QUIC {}", config.quic_listen);

    // Accept connections
    while let Some(incoming) = endpoint.accept().await {
        let signing_key = signing_key.clone();
        let local_peer_id = local_peer_id.clone();
        let state = Arc::clone(&state);
        tokio::spawn(async move {
            if let Err(e) = handle_connection(incoming, signing_key, local_peer_id, state).await {
                tracing::error!("Connection error: {}", e);
            }
        });
    }

    Ok(())
}

async fn handle_connection(
    incoming: quinn::Incoming,
    signing_key: ed25519_dalek::SigningKey,
    local_peer_id: Vec<u8>,
    state: Arc<drpc::router::ServerState>,
) -> Result<()> {
    let connection = incoming.await?;
    tracing::info!("New connection from {}", connection.remote_address());

    loop {
        let (send, recv) = match connection.accept_bi().await {
            Ok(streams) => streams,
            Err(quinn::ConnectionError::ApplicationClosed(_)) => {
                tracing::info!("Connection closed by peer");
                return Ok(());
            }
            Err(e) => return Err(e.into()),
        };

        let signing_key = signing_key.clone();
        let local_peer_id = local_peer_id.clone();
        let state = Arc::clone(&state);
        tokio::spawn(async move {
            if let Err(e) = handle_stream(send, recv, signing_key, local_peer_id, state).await {
                tracing::error!("Stream error: {}", e);
            }
        });
    }
}

async fn handle_stream(
    send: quinn::SendStream,
    recv: quinn::RecvStream,
    signing_key: ed25519_dalek::SigningKey,
    local_peer_id: Vec<u8>,
    state: Arc<drpc::router::ServerState>,
) -> Result<()> {
    let mut stream = tokio::io::join(recv, send);

    // Perform credential handshake
    let remote_peer_id = handshake::perform_handshake(&mut stream, &signing_key, &local_peer_id).await?;
    tracing::info!(
        "Handshake complete with peer {}",
        hex::encode(&remote_peer_id)
    );

    // Transition to DRPC dispatch
    let mut drpc_stream = drpc::stream::DrpcStream::new(stream);

    loop {
        match drpc_stream.read_invoke().await {
            Ok((_stream_id, method)) => {
                if let Err(e) =
                    drpc::router::dispatch(&method, &mut drpc_stream, &state, &remote_peer_id)
                        .await
                {
                    tracing::error!("RPC error on {}: {}", method, e);
                }
            }
            Err(_) => break,
        }
    }

    Ok(())
}
