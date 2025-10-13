//! Manytype server: all four any-sync node roles in a single binary.

mod config;
mod drpc;
mod handshake;
mod storage;
mod transport;

use anyhow::Result;

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

    // Start QUIC listener
    let server_config = transport::quic::make_server_config()?;
    let endpoint = transport::quic::run_quic_listener(&config.quic_listen, server_config).await?;
    tracing::info!("Listening on QUIC {}", config.quic_listen);

    // Accept connections
    while let Some(incoming) = endpoint.accept().await {
        tokio::spawn(async move {
            if let Err(e) = handle_connection(incoming).await {
                tracing::error!("Connection error: {}", e);
            }
        });
    }

    Ok(())
}

/// Handle an incoming QUIC connection.
///
/// Placeholder: accepts connection and logs peer address.
/// Full handshake + DRPC dispatch wiring added in Task 2.
async fn handle_connection(incoming: quinn::Incoming) -> Result<()> {
    let connection = incoming.await?;
    tracing::info!("New connection from {}", connection.remote_address());

    // Accept bidirectional streams (placeholder -- handshake + DRPC in Task 2)
    loop {
        match connection.accept_bi().await {
            Ok((_send, _recv)) => {
                tracing::info!("Accepted bidirectional stream from {}", connection.remote_address());
            }
            Err(quinn::ConnectionError::ApplicationClosed(_)) => {
                tracing::info!("Connection closed by peer");
                return Ok(());
            }
            Err(e) => return Err(e.into()),
        }
    }
}
