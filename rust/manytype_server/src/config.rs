//! Fail-closed server configuration and durable path resolution.

use std::net::SocketAddr;
use std::path::{Path, PathBuf};
use std::str::FromStr;

use anyhow::{Context, Result, bail, ensure};
use libp2p_identity::PeerId;
use serde::Deserialize;

const DEFAULT_HEALTH_LISTEN: &str = "127.0.0.1:33021";

#[derive(Clone, Copy, Debug, Default, Deserialize, Eq, PartialEq)]
#[serde(rename_all = "snake_case")]
pub enum DeploymentMode {
    #[default]
    Development,
    PrivateCanary,
    Production,
}

#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ServerConfig {
    pub quic_listen: String,
    #[serde(default = "default_health_listen")]
    pub health_listen: String,
    pub network_id: String,
    pub deployment_mode: DeploymentMode,
    pub data_dir: Option<PathBuf>,
    /// Legacy development-only storage location used by compatibility harnesses.
    pub db_path: Option<PathBuf>,
    /// Legacy development-only deterministic identity used by protocol fixtures.
    pub identity_seed: Option<String>,
    #[serde(default)]
    pub allowed_peer_ids: Vec<String>,
    #[serde(default)]
    pub allowed_account_identities: Vec<String>,
    #[serde(default)]
    pub limits: ResourceLimits,
}

#[derive(Clone, Debug, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct ResourceLimits {
    pub max_connections: usize,
    pub max_streams_per_connection: usize,
    pub max_frame_bytes: usize,
    pub max_message_bytes: usize,
    pub max_blob_bytes: u64,
    pub max_space_storage_bytes: u64,
    pub max_account_storage_bytes: u64,
    pub max_total_storage_bytes: u64,
    pub max_sync_state_bytes: u64,
    pub max_file_index_bytes: u64,
}

impl Default for ResourceLimits {
    fn default() -> Self {
        Self {
            max_connections: 32,
            max_streams_per_connection: 16,
            max_frame_bytes: 2 * 1024 * 1024,
            max_message_bytes: 8 * 1024 * 1024,
            max_blob_bytes: 4 * 1024 * 1024,
            max_space_storage_bytes: 512 * 1024 * 1024,
            max_account_storage_bytes: 1024 * 1024 * 1024,
            max_total_storage_bytes: 2 * 1024 * 1024 * 1024,
            max_sync_state_bytes: 512 * 1024 * 1024,
            max_file_index_bytes: 256 * 1024 * 1024,
        }
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct StoragePaths {
    pub data_dir: PathBuf,
    pub sync_root: PathBuf,
    pub files_root: PathBuf,
    pub identity_file: PathBuf,
    pub lock_file: PathBuf,
}

impl ServerConfig {
    pub fn load(path: impl AsRef<Path>) -> Result<Self> {
        let path = path.as_ref();
        let content = std::fs::read_to_string(path)
            .with_context(|| format!("failed to read config {}", path.display()))?;
        let config: Self = toml::from_str(&content)
            .with_context(|| format!("failed to parse config {}", path.display()))?;
        config.validate()?;
        Ok(config)
    }

    pub fn validate(&self) -> Result<()> {
        let _: SocketAddr = self
            .quic_listen
            .parse()
            .context("quic_listen must be a socket address")?;
        let health: SocketAddr = self
            .health_listen
            .parse()
            .context("health_listen must be a socket address")?;
        ensure!(!self.network_id.trim().is_empty(), "network_id is empty");
        self.limits.validate()?;

        match self.deployment_mode {
            DeploymentMode::Development => {
                ensure!(
                    self.data_dir.is_some() || self.db_path.is_some(),
                    "development config requires data_dir or db_path"
                );
                if let Some(seed) = &self.identity_seed {
                    validate_seed(seed)?;
                }
            }
            DeploymentMode::PrivateCanary => {
                ensure!(self.db_path.is_none(), "db_path is development-only");
                ensure!(
                    self.identity_seed.is_none(),
                    "identity_seed is development-only; private canaries generate a persistent identity"
                );
                let data_dir = self
                    .data_dir
                    .as_deref()
                    .context("private_canary requires data_dir")?;
                ensure!(
                    data_dir.is_absolute(),
                    "private_canary data_dir must be absolute"
                );
                ensure!(
                    health.ip().is_loopback(),
                    "private_canary health_listen must stay on loopback"
                );
                ensure!(
                    !self.allowed_peer_ids.is_empty(),
                    "private_canary requires at least one allowed_peer_id"
                );
                ensure!(
                    !self.allowed_account_identities.is_empty(),
                    "private_canary requires at least one allowed_account_identity"
                );
            }
            DeploymentMode::Production => bail!(
                "production deployment is prohibited until the private canary security gate is complete"
            ),
        }

        for peer_id in &self.allowed_peer_ids {
            PeerId::from_str(peer_id)
                .with_context(|| format!("invalid allowed_peer_id {peer_id}"))?;
        }
        for identity in &self.allowed_account_identities {
            let decoded = hex::decode(identity)
                .with_context(|| "allowed_account_identity must be hexadecimal")?;
            ensure!(
                decoded.len() == 32,
                "allowed_account_identity must contain 32 bytes"
            );
        }

        Ok(())
    }

    pub fn storage_paths(&self) -> Result<StoragePaths> {
        if let Some(data_dir) = &self.data_dir {
            return Ok(StoragePaths {
                sync_root: data_dir.join("sync"),
                files_root: data_dir.join("files"),
                identity_file: data_dir.join("identity.key"),
                lock_file: data_dir.join("server.lock"),
                data_dir: data_dir.clone(),
            });
        }

        let legacy_path = self
            .db_path
            .clone()
            .context("config does not define a storage path")?;
        let data_dir = match legacy_path.extension().and_then(|value| value.to_str()) {
            Some("redb") => legacy_path.with_extension(""),
            _ => legacy_path,
        };
        Ok(StoragePaths {
            sync_root: data_dir.clone(),
            files_root: data_dir.clone(),
            identity_file: data_dir.join("identity.key"),
            lock_file: data_dir.join("server.lock"),
            data_dir,
        })
    }
}

impl ResourceLimits {
    fn validate(&self) -> Result<()> {
        ensure!(self.max_connections > 0, "max_connections must be positive");
        ensure!(
            self.max_streams_per_connection > 0,
            "max_streams_per_connection must be positive"
        );
        ensure!(
            u32::try_from(self.max_streams_per_connection).is_ok(),
            "max_streams_per_connection exceeds QUIC capacity"
        );
        ensure!(self.max_frame_bytes >= 1024, "max_frame_bytes is too small");
        ensure!(
            self.max_message_bytes >= self.max_frame_bytes,
            "max_message_bytes must be at least max_frame_bytes"
        );
        ensure!(self.max_blob_bytes > 0, "max_blob_bytes must be positive");
        ensure!(
            self.max_sync_state_bytes > 0,
            "max_sync_state_bytes must be positive"
        );
        ensure!(
            self.max_file_index_bytes > 0,
            "max_file_index_bytes must be positive"
        );
        ensure!(
            self.max_blob_bytes <= self.max_message_bytes as u64,
            "max_blob_bytes must not exceed max_message_bytes"
        );
        ensure!(
            self.max_space_storage_bytes >= self.max_blob_bytes,
            "max_space_storage_bytes must be at least max_blob_bytes"
        );
        ensure!(
            self.max_account_storage_bytes >= self.max_space_storage_bytes,
            "max_account_storage_bytes must be at least max_space_storage_bytes"
        );
        ensure!(
            self.max_total_storage_bytes >= self.max_account_storage_bytes,
            "max_total_storage_bytes must be at least max_account_storage_bytes"
        );
        Ok(())
    }
}

fn default_health_listen() -> String {
    DEFAULT_HEALTH_LISTEN.to_string()
}

fn validate_seed(seed: &str) -> Result<()> {
    let decoded = hex::decode(seed).context("identity_seed must be hexadecimal")?;
    ensure!(decoded.len() == 32, "identity_seed must contain 32 bytes");
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    const PEER_ONE: &str = "12D3KooWGHMiFc5JJNpGWJxaqUd7ozGQASZz2TU9PwfGGjqjrc5J";
    fn private_config() -> String {
        format!(
            r#"
                deployment_mode = "private_canary"
                quic_listen = "0.0.0.0:33020"
                health_listen = "127.0.0.1:33021"
                network_id = "manytype-private-canary"
                data_dir = "/var/lib/manytype"
                allowed_peer_ids = ["{PEER_ONE}"]
                allowed_account_identities = ["0303030303030303030303030303030303030303030303030303030303030303"]
            "#
        )
    }

    #[test]
    fn private_canary_config_is_fail_closed_and_resolves_paths() {
        let config: ServerConfig = toml::from_str(&private_config()).unwrap();
        config.validate().unwrap();
        let paths = config.storage_paths().unwrap();
        assert_eq!(paths.sync_root, Path::new("/var/lib/manytype/sync"));
        assert_eq!(paths.files_root, Path::new("/var/lib/manytype/files"));
        assert_eq!(
            paths.identity_file,
            Path::new("/var/lib/manytype/identity.key")
        );
    }

    #[test]
    fn private_canary_rejects_embedded_identity_and_missing_allowlist() {
        let config: ServerConfig = toml::from_str(
            r#"
                deployment_mode = "private_canary"
                quic_listen = "0.0.0.0:33020"
                network_id = "manytype-private-canary"
                data_dir = "/var/lib/manytype"
                identity_seed = "0101010101010101010101010101010101010101010101010101010101010101"
            "#,
        )
        .unwrap();
        assert!(config.validate().is_err());
    }

    #[test]
    fn production_mode_remains_prohibited() {
        let config: ServerConfig = toml::from_str(
            r#"
                deployment_mode = "production"
                quic_listen = "0.0.0.0:33020"
                network_id = "manytype-production"
                data_dir = "/var/lib/manytype"
            "#,
        )
        .unwrap();
        assert!(
            config
                .validate()
                .unwrap_err()
                .to_string()
                .contains("prohibited")
        );
    }

    #[test]
    fn legacy_config_is_development_only() {
        let config: ServerConfig = toml::from_str(
            r#"
                deployment_mode = "development"
                quic_listen = "127.0.0.1:33020"
                db_path = "/tmp/test.redb"
                identity_seed = "0101010101010101010101010101010101010101010101010101010101010101"
                network_id = "manytype-dev"
            "#,
        )
        .unwrap();
        config.validate().unwrap();
        assert_eq!(
            config.storage_paths().unwrap().sync_root,
            Path::new("/tmp/test")
        );
    }

    #[test]
    fn config_requires_an_explicit_deployment_mode() {
        let error = toml::from_str::<ServerConfig>(
            r#"
                quic_listen = "0.0.0.0:33020"
                network_id = "ambiguous-deployment"
                data_dir = "/var/lib/manytype"
            "#,
        )
        .unwrap_err();

        assert!(error.to_string().contains("deployment_mode"));
    }

    #[test]
    fn resource_limits_reject_unbounded_relationships() {
        let mut config: ServerConfig = toml::from_str(&private_config()).unwrap();
        config.limits.max_message_bytes = config.limits.max_frame_bytes - 1;
        assert!(config.validate().is_err());
    }

    #[test]
    fn resource_limits_require_durable_metadata_budgets() {
        let mut config: ServerConfig = toml::from_str(&private_config()).unwrap();
        config.limits.max_sync_state_bytes = 0;
        assert!(config.validate().is_err());

        config.limits.max_sync_state_bytes = ResourceLimits::default().max_sync_state_bytes;
        config.limits.max_file_index_bytes = 0;
        assert!(config.validate().is_err());
    }
}
