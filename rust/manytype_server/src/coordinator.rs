//! Coordinator node handler -- provides network configuration to connecting clients.

use anyhow::Result;
use prost::Message;

use manytype_proto::coordinator::{
    NetworkConfigurationRequest, NetworkConfigurationResponse, Node, NodeType,
};

/// Configuration for the coordinator subsystem.
pub struct CoordinatorConfig {
    pub network_id: String,
    pub peer_id: String,
    pub addresses: Vec<String>,
}

/// Handle /coordinator.Coordinator/NetworkConfiguration
///
/// Returns the network configuration with this node's addresses and supported
/// roles. In manytype's single-binary architecture, one node advertises all
/// four roles (tree, file, coordinator, consensus).
pub fn handle_network_configuration(
    request_bytes: &[u8],
    config: &CoordinatorConfig,
) -> Result<Vec<u8>> {
    // Decode request (validates it's well-formed protobuf)
    let _request = NetworkConfigurationRequest::decode(request_bytes)?;

    // Build response with this server as the only node.
    // NodeType enum values: TreeApi=0, FileApi=1, CoordinatorApi=2, ConsensusApi=3
    let node = Node {
        peer_id: config.peer_id.clone(),
        addresses: config.addresses.clone(),
        types: vec![
            NodeType::TreeApi as i32,
            NodeType::FileApi as i32,
            NodeType::CoordinatorApi as i32,
            NodeType::ConsensusApi as i32,
        ],
    };

    let response = NetworkConfigurationResponse {
        network_id: config.network_id.clone(),
        nodes: vec![node],
        configuration_id: "manytype-v1".to_string(),
        creation_time_unix: std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs(),
    };

    Ok(response.encode_to_vec())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_network_configuration_returns_valid_response() {
        let config = CoordinatorConfig {
            network_id: "manytype-test-net".to_string(),
            peer_id: "12D3KooWTestPeer".to_string(),
            addresses: vec!["127.0.0.1:4830".to_string()],
        };

        // Empty request (all fields default)
        let request = NetworkConfigurationRequest::default();
        let request_bytes = request.encode_to_vec();

        let response_bytes =
            handle_network_configuration(&request_bytes, &config).unwrap();
        let response =
            NetworkConfigurationResponse::decode(response_bytes.as_slice()).unwrap();

        assert_eq!(response.network_id, "manytype-test-net");
        assert_eq!(response.configuration_id, "manytype-v1");
        assert!(!response.nodes.is_empty(), "should have at least one node");
        assert!(response.creation_time_unix > 0, "creation time should be set");
    }

    #[test]
    fn test_node_has_peer_id_address_and_all_roles() {
        let config = CoordinatorConfig {
            network_id: "test-net".to_string(),
            peer_id: "12D3KooWTestPeer".to_string(),
            addresses: vec!["127.0.0.1:4830".to_string(), "192.168.1.1:4830".to_string()],
        };

        let request_bytes = NetworkConfigurationRequest::default().encode_to_vec();
        let response_bytes =
            handle_network_configuration(&request_bytes, &config).unwrap();
        let response =
            NetworkConfigurationResponse::decode(response_bytes.as_slice()).unwrap();

        let node = &response.nodes[0];
        assert_eq!(node.peer_id, "12D3KooWTestPeer");
        assert_eq!(node.addresses.len(), 2);
        assert_eq!(node.addresses[0], "127.0.0.1:4830");

        // Should advertise all four roles
        assert!(
            node.types.contains(&(NodeType::TreeApi as i32)),
            "should have TreeApi"
        );
        assert!(
            node.types.contains(&(NodeType::CoordinatorApi as i32)),
            "should have CoordinatorApi"
        );
        assert!(
            node.types.contains(&(NodeType::FileApi as i32)),
            "should have FileApi"
        );
        assert!(
            node.types.contains(&(NodeType::ConsensusApi as i32)),
            "should have ConsensusApi"
        );
    }
}
