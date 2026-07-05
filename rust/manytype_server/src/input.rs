//! Validation for identifiers that cross persistence boundaries.

use anyhow::{Result, ensure};

const MAX_STORAGE_KEY_BYTES: usize = 256;

pub fn validate_space_id(space_id: &str) -> Result<()> {
    validate_storage_key("space id", space_id)
}

pub fn validate_storage_key(label: &str, value: &str) -> Result<()> {
    ensure!(!value.is_empty(), "{label} is empty");
    ensure!(
        value.len() <= MAX_STORAGE_KEY_BYTES,
        "{label} exceeds {MAX_STORAGE_KEY_BYTES} bytes"
    );
    ensure!(value.is_ascii(), "{label} must be ASCII");
    ensure!(
        value != "." && value != "..",
        "{label} is not a safe path component"
    );
    ensure!(
        value
            .bytes()
            .all(|byte| byte.is_ascii_alphanumeric() || matches!(byte, b'-' | b'_' | b'.')),
        "{label} contains unsafe characters"
    );
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn accepts_content_addressed_space_ids() {
        validate_space_id("bafyreicidvalue.16").unwrap();
    }

    #[test]
    fn rejects_path_traversal_and_separators() {
        for value in [
            "../outside",
            "..",
            "/tmp/space",
            "space\\child",
            "space\0child",
        ] {
            assert!(validate_space_id(value).is_err(), "accepted {value:?}");
        }
    }
}
