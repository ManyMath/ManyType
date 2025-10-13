//! TOML configuration loading for the Manytype server.

use serde::Deserialize;

/// Server configuration loaded from a TOML file.
#[derive(Debug, Deserialize)]
pub struct ServerConfig {
    /// QUIC listen address, e.g., "0.0.0.0:33020"
    pub quic_listen: String,
    /// Path to redb database file
    pub db_path: String,
    /// Ed25519 identity seed (hex-encoded 32 bytes)
    pub identity_seed: String,
    /// Network ID for this deployment
    pub network_id: String,
}

impl ServerConfig {
    /// Load configuration from a TOML file at the given path.
    pub fn load(path: &str) -> anyhow::Result<Self> {
        let content = std::fs::read_to_string(path)?;
        let config: ServerConfig = toml::from_str(&content)?;
        Ok(config)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_deserialize_config() {
        let toml_str = r#"
            quic_listen = "127.0.0.1:33020"
            db_path = "/tmp/test.redb"
            identity_seed = "0101010101010101010101010101010101010101010101010101010101010101"
            network_id = "manytype-dev"
        "#;
        let config: ServerConfig = toml::from_str(toml_str).unwrap();
        assert_eq!(config.quic_listen, "127.0.0.1:33020");
        assert_eq!(config.db_path, "/tmp/test.redb");
        assert_eq!(config.identity_seed.len(), 64); // 32 bytes hex
        assert_eq!(config.network_id, "manytype-dev");
    }

    #[test]
    fn test_missing_field_errors() {
        let toml_str = r#"
            quic_listen = "127.0.0.1:33020"
        "#;
        let result: Result<ServerConfig, _> = toml::from_str(toml_str);
        assert!(result.is_err());
    }
}
