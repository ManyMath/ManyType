//! Manytype server: all four any-sync node roles in a single binary.

mod drpc;
mod storage;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    println!("manytype-server starting...");
    Ok(())
}
