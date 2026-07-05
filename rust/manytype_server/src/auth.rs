//! Authenticated connection identity passed across DRPC trust boundaries.

use std::str::FromStr;

use anyhow::{Result, ensure};
use libp2p_identity::PeerId;

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
}
