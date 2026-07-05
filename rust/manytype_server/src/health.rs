//! Minimal unauthenticated liveness and readiness endpoints.

use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};
use std::time::Duration;

use anyhow::{Context, Result};
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::{TcpListener, TcpStream};
use tokio_util::sync::CancellationToken;

const MAX_REQUEST_BYTES: usize = 1024;
const REQUEST_TIMEOUT: Duration = Duration::from_secs(2);

#[derive(Clone, Debug, Default)]
pub struct HealthState {
    ready: Arc<AtomicBool>,
}

impl HealthState {
    pub fn set_ready(&self, ready: bool) {
        self.ready.store(ready, Ordering::Release);
    }

    fn is_ready(&self) -> bool {
        self.ready.load(Ordering::Acquire)
    }
}

pub async fn serve(
    listener: TcpListener,
    state: HealthState,
    shutdown: CancellationToken,
) -> Result<()> {
    loop {
        tokio::select! {
            _ = shutdown.cancelled() => return Ok(()),
            accepted = listener.accept() => {
                let (socket, _) = accepted.context("health listener accept failed")?;
                if let Err(error) = respond(socket, &state).await {
                    tracing::warn!(
                        event = "health_request_failed",
                        error = %error
                    );
                }
            }
        }
    }
}

async fn respond(mut socket: TcpStream, state: &HealthState) -> Result<()> {
    let mut request = [0u8; MAX_REQUEST_BYTES];
    let read = tokio::time::timeout(REQUEST_TIMEOUT, socket.read(&mut request))
        .await
        .context("health request timed out")??;
    let request_line = std::str::from_utf8(&request[..read])
        .context("health request is not UTF-8")?
        .lines()
        .next()
        .unwrap_or_default();
    let mut parts = request_line.split_ascii_whitespace();
    let method = parts.next().unwrap_or_default();
    let path = parts.next().unwrap_or_default();

    let (status, body) = match (method, path) {
        ("GET", "/healthz") => ("200 OK", r#"{"status":"ok"}"#),
        ("GET", "/readyz") if state.is_ready() => ("200 OK", r#"{"status":"ready"}"#),
        ("GET", "/readyz") => ("503 Service Unavailable", r#"{"status":"starting"}"#),
        _ => ("404 Not Found", r#"{"status":"not_found"}"#),
    };
    let response = format!(
        "HTTP/1.1 {status}\r\nContent-Type: application/json\r\nCache-Control: no-store\r\nConnection: close\r\nContent-Length: {}\r\n\r\n{body}",
        body.len()
    );
    tokio::time::timeout(REQUEST_TIMEOUT, socket.write_all(response.as_bytes()))
        .await
        .context("health response timed out")??;
    socket.shutdown().await?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    async fn request(address: std::net::SocketAddr, path: &str) -> String {
        let mut stream = TcpStream::connect(address).await.unwrap();
        stream
            .write_all(format!("GET {path} HTTP/1.1\r\nHost: localhost\r\n\r\n").as_bytes())
            .await
            .unwrap();
        let mut response = String::new();
        stream.read_to_string(&mut response).await.unwrap();
        response
    }

    #[tokio::test]
    async fn readiness_changes_without_disclosing_server_details() {
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let address = listener.local_addr().unwrap();
        let state = HealthState::default();
        let shutdown = CancellationToken::new();
        let task = tokio::spawn(serve(listener, state.clone(), shutdown.clone()));

        let health = request(address, "/healthz").await;
        assert!(health.starts_with("HTTP/1.1 200 OK"));
        assert!(health.ends_with(r#"{"status":"ok"}"#));
        let not_ready = request(address, "/readyz").await;
        assert!(not_ready.starts_with("HTTP/1.1 503 Service Unavailable"));
        state.set_ready(true);
        let ready = request(address, "/readyz").await;
        assert!(ready.starts_with("HTTP/1.1 200 OK"));
        assert!(!ready.contains("peer"));
        assert!(!ready.contains("version"));

        shutdown.cancel();
        task.await.unwrap().unwrap();
    }

    #[tokio::test]
    async fn unknown_health_route_does_not_fall_through() {
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let address = listener.local_addr().unwrap();
        let shutdown = CancellationToken::new();
        let task = tokio::spawn(serve(listener, HealthState::default(), shutdown.clone()));

        assert!(
            request(address, "/config")
                .await
                .starts_with("HTTP/1.1 404")
        );
        shutdown.cancel();
        task.await.unwrap().unwrap();
    }
}
