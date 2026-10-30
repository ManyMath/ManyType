//! TreeStorage trait and in-memory implementation.
//!
//! Per D-09: in-memory for Phase 2 testing; Phase 3 swaps in persistent storage.

use anyhow::Result;

/// Trait abstracting tree change storage.
/// In-memory for Phase 2 testing; Phase 3 swaps in redb persistence.
pub trait TreeStorage: Send + Sync {
    fn add_raw_change(&mut self, id: String, raw: Vec<u8>) -> Result<()>;
    fn get_raw_change(&self, id: &str) -> Result<Option<Vec<u8>>>;
    fn has_change(&self, id: &str) -> bool;
    fn get_heads(&self) -> Vec<String>;
    fn set_heads(&mut self, heads: Vec<String>);
}

/// In-memory implementation for testing and Phase 2 use.
pub struct InMemoryTreeStorage {
    changes: std::collections::HashMap<String, Vec<u8>>,
    heads: Vec<String>,
}

impl InMemoryTreeStorage {
    pub fn new() -> Self {
        Self {
            changes: std::collections::HashMap::new(),
            heads: Vec::new(),
        }
    }
}

impl Default for InMemoryTreeStorage {
    fn default() -> Self {
        Self::new()
    }
}

impl TreeStorage for InMemoryTreeStorage {
    fn add_raw_change(&mut self, id: String, raw: Vec<u8>) -> Result<()> {
        self.changes.insert(id, raw);
        Ok(())
    }

    fn get_raw_change(&self, id: &str) -> Result<Option<Vec<u8>>> {
        Ok(self.changes.get(id).cloned())
    }

    fn has_change(&self, id: &str) -> bool {
        self.changes.contains_key(id)
    }

    fn get_heads(&self) -> Vec<String> {
        self.heads.clone()
    }

    fn set_heads(&mut self, heads: Vec<String>) {
        self.heads = heads;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn add_and_get_raw_change_round_trips() {
        let mut storage = InMemoryTreeStorage::new();
        let data = vec![1, 2, 3, 4, 5];
        storage
            .add_raw_change("id1".to_string(), data.clone())
            .unwrap();
        let retrieved = storage.get_raw_change("id1").unwrap().unwrap();
        assert_eq!(retrieved.as_slice(), &data[..]);
    }

    #[test]
    fn has_change_returns_false_for_unknown_true_after_add() {
        let mut storage = InMemoryTreeStorage::new();
        assert!(!storage.has_change("unknown"));
        storage
            .add_raw_change("known".to_string(), vec![42])
            .unwrap();
        assert!(storage.has_change("known"));
    }

    #[test]
    fn get_heads_empty_initially_returns_set_values() {
        let mut storage = InMemoryTreeStorage::new();
        assert!(storage.get_heads().is_empty());
        storage.set_heads(vec!["head1".to_string(), "head2".to_string()]);
        assert_eq!(
            storage.get_heads(),
            vec!["head1".to_string(), "head2".to_string()]
        );
    }

    #[test]
    fn get_raw_change_returns_none_for_unknown() {
        let storage = InMemoryTreeStorage::new();
        assert!(storage.get_raw_change("nonexistent").unwrap().is_none());
    }
}
