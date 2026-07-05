//! Authenticated connection identity passed across DRPC trust boundaries.

use std::collections::HashSet;
use std::str::FromStr;

use anyhow::{Result, ensure};
use libp2p_identity::PeerId;

use crate::config::{DeploymentMode, ServerConfig};

#[derive(Clone, Debug)]
pub struct AccessPolicy {
    restrict: bool,
    peer_ids: HashSet<String>,
    account_identities: HashSet<[u8; 32]>,
}

impl AccessPolicy {
    pub fn from_config(config: &ServerConfig) -> Result<Self> {
        let account_identities = config
            .allowed_account_identities
            .iter()
            .map(|identity| {
                let decoded = hex::decode(identity)?;
                decoded.try_into().map_err(|decoded: Vec<u8>| {
                    anyhow::anyhow!(
                        "allowed account identity must be 32 bytes, got {}",
                        decoded.len()
                    )
                })
            })
            .collect::<Result<HashSet<_>>>()?;
        Ok(Self {
            restrict: config.deployment_mode != DeploymentMode::Development,
            peer_ids: config.allowed_peer_ids.iter().cloned().collect(),
            account_identities,
        })
    }

    pub fn authorize(&self, peer: &AuthenticatedPeer<'_>) -> Result<()> {
        if !self.restrict {
            return Ok(());
        }
        ensure!(
            self.peer_ids.contains(peer.id()),
            "transport peer is not allowlisted"
        );
        ensure!(
            self.account_identities.contains(peer.account_identity()),
            "account identity is not allowlisted"
        );
        Ok(())
    }
}

/// A peer ID proven by the client certificate on the current QUIC connection.
///
/// Space-scoped handlers accept this type instead of a caller-supplied string so
/// authorization decisions remain tied to the transport-authenticated identity.
#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct AuthenticatedPeer<'a> {
    peer_id: &'a str,
    account_identity: [u8; 32],
}

impl<'a> AuthenticatedPeer<'a> {
    pub fn from_connection(peer_id: &'a str, account_identity: &[u8]) -> Result<Self> {
        ensure!(!peer_id.is_empty(), "authenticated peer id is empty");
        PeerId::from_str(peer_id)
            .map_err(|error| anyhow::anyhow!("invalid authenticated peer id: {error}"))?;
        let account_identity = account_identity
            .try_into()
            .map_err(|_| anyhow::anyhow!("authenticated account identity must be 32 bytes"))?;
        Ok(Self {
            peer_id,
            account_identity,
        })
    }

    pub fn id(self) -> &'a str {
        self.peer_id
    }

    pub fn account_identity(&self) -> &[u8; 32] {
        &self.account_identity
    }

    #[cfg(test)]
    pub(crate) fn for_test(peer_id: &'a str) -> Self {
        assert!(!peer_id.is_empty());
        Self {
            peer_id,
            account_identity: [0; 32],
        }
    }

    #[cfg(test)]
    pub(crate) fn for_test_with_account(peer_id: &'a str, account_identity: [u8; 32]) -> Self {
        assert!(!peer_id.is_empty());
        Self {
            peer_id,
            account_identity,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn config_with_allowlist(peer_id: &str, account: [u8; 32]) -> ServerConfig {
        toml::from_str(&format!(
            r#"
                deployment_mode = "private_canary"
                quic_listen = "0.0.0.0:33020"
                health_listen = "127.0.0.1:33021"
                network_id = "manytype-private-canary"
                data_dir = "/var/lib/manytype"
                allowed_peer_ids = ["{peer_id}"]
                allowed_account_identities = ["{}"]
            "#,
            hex::encode(account)
        ))
        .unwrap()
    }

    #[test]
    fn rejects_unparseable_transport_peer_ids() {
        assert!(AuthenticatedPeer::from_connection("not-a-peer-id", &[0; 32]).is_err());
    }

    #[test]
    fn rejects_missing_authenticated_account_identity() {
        let peer_id = libp2p_identity::Keypair::ed25519_from_bytes(&mut [7; 32])
            .unwrap()
            .public()
            .to_peer_id()
            .to_string();
        assert!(AuthenticatedPeer::from_connection(&peer_id, &[]).is_err());
    }

    #[test]
    fn private_policy_requires_both_transport_peer_and_account() {
        let key = libp2p_identity::Keypair::ed25519_from_bytes(&mut [8; 32]).unwrap();
        let peer_id = key.public().to_peer_id().to_string();
        let account = [9; 32];
        let config = config_with_allowlist(&peer_id, account);
        let policy = AccessPolicy::from_config(&config).unwrap();

        policy
            .authorize(&AuthenticatedPeer::from_connection(&peer_id, &account).unwrap())
            .unwrap();
        assert!(
            policy
                .authorize(&AuthenticatedPeer::from_connection(&peer_id, &[7; 32]).unwrap())
                .is_err()
        );

        let other = libp2p_identity::Keypair::ed25519_from_bytes(&mut [10; 32])
            .unwrap()
            .public()
            .to_peer_id()
            .to_string();
        assert!(
            policy
                .authorize(&AuthenticatedPeer::from_connection(&other, &account).unwrap())
                .is_err()
        );
    }
}
