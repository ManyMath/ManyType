//! Typed runtime deadlines for untrusted transport work.

use std::fmt;
use std::future::Future;
use std::time::Duration;

use anyhow::Result;

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub enum DeadlineStage {
    ConnectionSetup,
    StreamSetup,
    StreamRead,
    StreamWrite,
}

impl DeadlineStage {
    pub const fn as_str(self) -> &'static str {
        match self {
            Self::ConnectionSetup => "connection_setup",
            Self::StreamSetup => "stream_setup",
            Self::StreamRead => "stream_read",
            Self::StreamWrite => "stream_write",
        }
    }
}

#[derive(Debug)]
pub struct DeadlineExceeded {
    stage: DeadlineStage,
    timeout: Duration,
}

impl DeadlineExceeded {
    pub const fn stage(&self) -> DeadlineStage {
        self.stage
    }

    pub const fn timeout(&self) -> Duration {
        self.timeout
    }
}

impl fmt::Display for DeadlineExceeded {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            formatter,
            "{} deadline exceeded after {} ms",
            self.stage.as_str(),
            self.timeout.as_millis()
        )
    }
}

impl std::error::Error for DeadlineExceeded {}

pub async fn value<T>(
    stage: DeadlineStage,
    timeout: Duration,
    future: impl Future<Output = T>,
) -> Result<T> {
    tokio::time::timeout(timeout, future)
        .await
        .map_err(|_| DeadlineExceeded { stage, timeout }.into())
}

pub async fn result<T>(
    stage: DeadlineStage,
    timeout: Duration,
    future: impl Future<Output = Result<T>>,
) -> Result<T> {
    value(stage, timeout, future).await?
}

pub fn exceeded(error: &anyhow::Error) -> Option<&DeadlineExceeded> {
    error
        .chain()
        .find_map(|cause| cause.downcast_ref::<DeadlineExceeded>())
}

#[cfg(test)]
mod tests {
    use std::future;

    use super::*;

    #[tokio::test]
    async fn timeout_error_preserves_stage_and_duration() {
        let error = result(
            DeadlineStage::ConnectionSetup,
            Duration::ZERO,
            future::pending::<Result<()>>(),
        )
        .await
        .unwrap_err();

        let exceeded = exceeded(&error).unwrap();
        assert_eq!(exceeded.stage(), DeadlineStage::ConnectionSetup);
        assert_eq!(exceeded.timeout(), Duration::ZERO);
        assert_eq!(
            error.to_string(),
            "connection_setup deadline exceeded after 0 ms"
        );
    }

    #[tokio::test]
    async fn ready_result_is_not_delayed() {
        let value = result(
            DeadlineStage::StreamSetup,
            Duration::from_secs(1),
            future::ready(Ok(7)),
        )
        .await
        .unwrap();

        assert_eq!(value, 7);
    }
}
