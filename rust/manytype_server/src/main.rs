//! Manytype server: all four any-sync node roles in a single binary.

use std::path::PathBuf;
use std::sync::Arc;
use std::time::Duration;

use anyhow::{Context, Result, bail};
use libp2p_identity::Keypair;
use manytype_core::crypto::ed25519;
use manytype_proto::handshake::{Encoding, ProtoType};
use manytype_server::{
    auth, config, coordinator, drpc, file_node, handshake, health, identity, ops, sync_node,
    transport,
};
use tokio::net::TcpListener;
use tokio::sync::{OwnedSemaphorePermit, Semaphore};
use tokio::task::JoinSet;
use tokio_util::sync::CancellationToken;

const SHUTDOWN_GRACE: Duration = Duration::from_secs(30);

#[derive(Debug, Eq, PartialEq)]
enum Command {
    Serve {
        config: PathBuf,
    },
    CheckConfig {
        config: PathBuf,
    },
    Backup {
        config: PathBuf,
        output: PathBuf,
    },
    Restore {
        config: PathBuf,
        input: PathBuf,
        force: bool,
    },
}

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
    let filter = tracing_subscriber::EnvFilter::try_from_default_env()
        .unwrap_or_else(|_| tracing_subscriber::EnvFilter::new("info"));
    tracing_subscriber::fmt()
        .json()
        .with_env_filter(filter)
        .init();

    match parse_command(std::env::args().skip(1))? {
        Command::Serve { config } => serve(config).await,
        Command::CheckConfig { config } => {
            config::ServerConfig::load(&config)?;
            println!("configuration valid: {}", config.display());
            Ok(())
        }
        Command::Backup { config, output } => {
            let config = config::ServerConfig::load(&config)?;
            ops::create_backup(&config.storage_paths()?, &output)?;
            println!("backup created: {}", output.display());
            Ok(())
        }
        Command::Restore {
            config,
            input,
            force,
        } => {
            let config = config::ServerConfig::load(&config)?;
            ops::restore_backup(&config.storage_paths()?, &input, force)?;
            println!("backup restored: {}", input.display());
            Ok(())
        }
    }
}

async fn serve(config_path: PathBuf) -> Result<()> {
    let config = config::ServerConfig::load(&config_path)?;
    let storage_paths = config.storage_paths()?;
    let _server_lock = ops::ServerLock::acquire(&storage_paths)?;

    let seed = match config.identity_seed.as_deref() {
        Some(seed) => hex::decode(seed)?.try_into().map_err(|value: Vec<u8>| {
            anyhow::anyhow!("identity_seed must be 32 bytes, got {}", value.len())
        })?,
        None => identity::load_or_create(&storage_paths.identity_file)?,
    };
    let signing_key = ed25519::signing_key_from_seed(&seed);
    let mut libp2p_seed = seed;
    let local_identity_keypair = Keypair::ed25519_from_bytes(libp2p_seed.as_mut_slice())
        .map_err(|e| anyhow::anyhow!("failed to derive libp2p identity from seed: {e}"))?;
    let local_peer_id_libp2p = local_identity_keypair.public().to_peer_id().to_string();
    let sync_state = sync_node::SharedSyncState::open(&storage_paths.sync_root)?;
    let file_node = file_node::FileNodeState::open_with_limits(
        &storage_paths.files_root,
        config.limits.clone(),
    )?;
    let access_policy = Arc::new(auth::AccessPolicy::from_config(&config)?);
    tracing::info!(
        event = "storage_opened",
        sync_root = %storage_paths.sync_root.display(),
        files_root = %storage_paths.files_root.display()
    );

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
    let mut server_config = transport::quic::make_server_config(&seed)?;
    transport::quic::apply_stream_limit(
        &mut server_config,
        config.limits.max_streams_per_connection,
    )?;
    let endpoint = transport::quic::run_quic_listener(&config.quic_listen, server_config).await?;
    let health_listener = TcpListener::bind(&config.health_listen)
        .await
        .with_context(|| format!("failed to bind health listener {}", config.health_listen))?;
    let health_state = health::HealthState::default();
    let health_shutdown = CancellationToken::new();
    let mut health_task = tokio::spawn(health::serve(
        health_listener,
        health_state.clone(),
        health_shutdown.clone(),
    ));
    let connection_limit = Arc::new(Semaphore::new(config.limits.max_connections));
    let mut connection_tasks = JoinSet::new();
    let shutdown = shutdown_signal();
    tokio::pin!(shutdown);
    health_state.set_ready(true);
    tracing::info!(
        event = "server_ready",
        deployment_mode = ?config.deployment_mode,
        peer_id = %local_peer_id_libp2p,
        quic_listen = %config.quic_listen,
        health_listen = %config.health_listen
    );

    loop {
        tokio::select! {
            signal_result = &mut shutdown => {
                signal_result?;
                tracing::info!(event = "shutdown_started", reason = "signal");
                break;
            }
            health_result = &mut health_task => {
                health_result.context("health task panicked")??;
                bail!("health task exited before shutdown");
            }
            Some(join_result) = connection_tasks.join_next(), if !connection_tasks.is_empty() => {
                if let Err(error) = join_result {
                    tracing::error!(event = "connection_task_panicked", error = %error);
                }
            }
            incoming = endpoint.accept() => {
                let Some(incoming) = incoming else {
                    bail!("QUIC listener stopped before shutdown");
                };
                let connection_permit = match Arc::clone(&connection_limit).try_acquire_owned() {
                    Ok(permit) => permit,
                    Err(_) => {
                        tracing::warn!(event = "connection_rejected", reason = "connection_limit");
                        incoming.refuse();
                        continue;
                    }
                };
                let local_peer_id_libp2p = local_peer_id_libp2p.clone();
                let local_identity_keypair = local_identity_keypair.clone();
                let state = Arc::clone(&state);
                let access_policy = Arc::clone(&access_policy);
                let limits = config.limits.clone();
                connection_tasks.spawn(async move {
                    if let Err(error) = handle_connection(
                        incoming,
                        local_peer_id_libp2p,
                        local_identity_keypair,
                        state,
                        access_policy,
                        limits,
                        connection_permit,
                    )
                    .await
                    {
                        if is_benign_connection_error(&error) {
                            tracing::info!(event = "connection_closed");
                        } else {
                            tracing::warn!(event = "connection_failed", error = %error);
                        }
                    }
                });
            }
        }
    }

    health_state.set_ready(false);
    endpoint.close(quinn::VarInt::from_u32(0), b"server shutdown");
    health_shutdown.cancel();
    let drain_result = tokio::time::timeout(SHUTDOWN_GRACE, async {
        endpoint.wait_idle().await;
        while let Some(result) = connection_tasks.join_next().await {
            if let Err(error) = result {
                tracing::error!(event = "connection_task_panicked", error = %error);
            }
        }
    })
    .await;
    if drain_result.is_err() {
        tracing::warn!(
            event = "shutdown_forced",
            grace_seconds = SHUTDOWN_GRACE.as_secs()
        );
        connection_tasks.abort_all();
        while connection_tasks.join_next().await.is_some() {}
    }
    health_task.await.context("health task panicked")??;
    tracing::info!(event = "shutdown_complete");
    Ok(())
}

fn parse_command(args: impl IntoIterator<Item = String>) -> Result<Command> {
    let args = args.into_iter().collect::<Vec<_>>();
    match args.as_slice() {
        [] => Ok(Command::Serve {
            config: PathBuf::from("config.toml"),
        }),
        [config] if !config.starts_with('-') && !is_command(config) => Ok(Command::Serve {
            config: PathBuf::from(config),
        }),
        [command, flag, config] if command == "serve" && flag == "--config" => Ok(Command::Serve {
            config: PathBuf::from(config),
        }),
        [command, flag, config] if command == "check-config" && flag == "--config" => {
            Ok(Command::CheckConfig {
                config: PathBuf::from(config),
            })
        }
        [command, config_flag, config, output_flag, output]
            if command == "backup" && config_flag == "--config" && output_flag == "--output" =>
        {
            Ok(Command::Backup {
                config: PathBuf::from(config),
                output: PathBuf::from(output),
            })
        }
        [command, config_flag, config, input_flag, input, force]
            if command == "restore"
                && config_flag == "--config"
                && input_flag == "--input"
                && force == "--force" =>
        {
            Ok(Command::Restore {
                config: PathBuf::from(config),
                input: PathBuf::from(input),
                force: true,
            })
        }
        _ => bail!(
            "usage: manytype_server [CONFIG] | serve --config CONFIG | check-config --config CONFIG | backup --config CONFIG --output DIRECTORY | restore --config CONFIG --input DIRECTORY --force"
        ),
    }
}

fn is_command(value: &str) -> bool {
    matches!(value, "serve" | "check-config" | "backup" | "restore")
}

async fn shutdown_signal() -> Result<()> {
    #[cfg(unix)]
    {
        let mut terminate =
            tokio::signal::unix::signal(tokio::signal::unix::SignalKind::terminate())
                .context("failed to install SIGTERM handler")?;
        tokio::select! {
            result = tokio::signal::ctrl_c() => result.context("failed to install Ctrl-C handler")?,
            _ = terminate.recv() => {},
        }
    }

    #[cfg(not(unix))]
    tokio::signal::ctrl_c()
        .await
        .context("failed to install Ctrl-C handler")?;

    Ok(())
}

async fn handle_connection(
    incoming: quinn::Incoming,
    local_peer_id_libp2p: String,
    local_identity_keypair: Keypair,
    state: Arc<drpc::router::ServerState>,
    access_policy: Arc<auth::AccessPolicy>,
    limits: config::ResourceLimits,
    _connection_permit: OwnedSemaphorePermit,
) -> Result<()> {
    let connection = incoming.await?;
    let remote_tls_peer_id = tls_peer_id(&connection)?;
    tracing::info!(
        event = "connection_accepted",
        remote_address = %connection.remote_address(),
        peer_id = %remote_tls_peer_id
    );

    let (handshake_send, handshake_recv) = connection.accept_bi().await?;
    let mut handshake_stream = tokio::io::join(handshake_recv, handshake_send);
    let remote_account_identity = handshake::perform_handshake(
        &mut handshake_stream,
        &local_identity_keypair,
        &local_peer_id_libp2p,
        &remote_tls_peer_id,
    )
    .await?;
    tracing::info!(event = "credential_authenticated", peer_id = %remote_tls_peer_id);
    let stream_limit = Arc::new(Semaphore::new(limits.max_streams_per_connection));
    let mut stream_tasks = JoinSet::new();

    loop {
        let accepted = tokio::select! {
            Some(result) = stream_tasks.join_next(), if !stream_tasks.is_empty() => {
                if let Err(error) = result {
                    tracing::error!(event = "stream_task_panicked", error = %error);
                }
                continue;
            }
            accepted = connection.accept_bi() => accepted,
        };
        let (send, recv) = match accepted {
            Ok(streams) => streams,
            Err(
                quinn::ConnectionError::ApplicationClosed(_)
                | quinn::ConnectionError::ConnectionClosed(_)
                | quinn::ConnectionError::LocallyClosed,
            ) => break,
            Err(error) => return Err(error.into()),
        };

        let stream_permit = match Arc::clone(&stream_limit).try_acquire_owned() {
            Ok(permit) => permit,
            Err(_) => {
                tracing::warn!(
                    event = "stream_rejected",
                    peer_id = %remote_tls_peer_id,
                    reason = "stream_limit"
                );
                drop(send);
                drop(recv);
                continue;
            }
        };

        let remote_tls_peer_id = remote_tls_peer_id.clone();
        let remote_account_identity = remote_account_identity.clone();
        let state = Arc::clone(&state);
        let access_policy = Arc::clone(&access_policy);
        let limits = limits.clone();
        stream_tasks.spawn(async move {
            let _stream_permit = stream_permit;
            if let Err(error) = handle_stream(
                send,
                recv,
                remote_tls_peer_id.clone(),
                remote_account_identity,
                state,
                access_policy,
                limits,
            )
            .await
            {
                if is_benign_connection_error(&error) {
                    tracing::debug!(event = "stream_closed", peer_id = %remote_tls_peer_id);
                    return;
                }
                tracing::warn!(event = "stream_failed", peer_id = %remote_tls_peer_id, error = %error);
            }
        });
    }

    while let Some(result) = stream_tasks.join_next().await {
        if let Err(error) = result {
            tracing::error!(event = "stream_task_panicked", error = %error);
        }
    }
    Ok(())
}

async fn handle_stream(
    send: quinn::SendStream,
    recv: quinn::RecvStream,
    remote_tls_peer_id: String,
    remote_account_identity: Vec<u8>,
    state: Arc<drpc::router::ServerState>,
    access_policy: Arc<auth::AccessPolicy>,
    limits: config::ResourceLimits,
) -> Result<()> {
    let mut stream = tokio::io::join(recv, send);
    let trace_file_rpcs = std::env::var_os("MANYTYPE_TRACE_FILE_RPCS").is_some();

    handshake::perform_proto_handshake(&mut stream, ProtoType::Drpc, &[Encoding::None]).await?;
    tracing::debug!(event = "protocol_negotiated", peer_id = %remote_tls_peer_id);
    let authenticated_peer =
        auth::AuthenticatedPeer::from_connection(&remote_tls_peer_id, &remote_account_identity)?;
    access_policy.authorize(&authenticated_peer)?;

    // Transition to DRPC dispatch
    let mut drpc_stream = drpc::stream::DrpcStream::with_limits(
        stream,
        limits.max_frame_bytes,
        limits.max_message_bytes,
    );

    loop {
        let (stream_id, method) = match drpc_stream.read_invoke().await {
            Ok(values) => values,
            Err(error) if is_benign_connection_error(&error) => return Ok(()),
            Err(error) => return Err(error),
        };
        if trace_file_rpcs && method.starts_with("/filesync.File/") {
            tracing::info!(
                event = "file_rpc_invoked",
                method,
                peer_id = %remote_tls_peer_id,
                stream_id
            );
        }
        if let Err(error) = drpc::router::dispatch(
            stream_id,
            &method,
            &mut drpc_stream,
            &state,
            &authenticated_peer,
        )
        .await
        {
            if is_benign_connection_error(&error) {
                return Ok(());
            }
            tracing::warn!(
                event = "rpc_failed",
                method,
                peer_id = %remote_tls_peer_id,
                error = %error
            );
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

#[cfg(test)]
mod cli_tests {
    use super::*;

    fn args(values: &[&str]) -> Vec<String> {
        values.iter().map(|value| (*value).to_string()).collect()
    }

    #[test]
    fn legacy_config_argument_still_starts_server() {
        assert_eq!(
            parse_command(args(&["fixture.toml"])).unwrap(),
            Command::Serve {
                config: PathBuf::from("fixture.toml")
            }
        );
    }

    #[test]
    fn restore_requires_force_in_command_shape() {
        assert!(
            parse_command(args(&[
                "restore",
                "--config",
                "server.toml",
                "--input",
                "snapshot"
            ]))
            .is_err()
        );
        assert_eq!(
            parse_command(args(&[
                "restore",
                "--config",
                "server.toml",
                "--input",
                "snapshot",
                "--force"
            ]))
            .unwrap(),
            Command::Restore {
                config: PathBuf::from("server.toml"),
                input: PathBuf::from("snapshot"),
                force: true,
            }
        );
    }
}
