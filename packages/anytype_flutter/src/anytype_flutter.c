// Shared C source for the iOS and macOS plugin frameworks.
//
// The QUIC bridge's entry points live in libmanytype_quic_ffi (the Rust
// crate), which the podspec force-links into the framework via -force_load.
// This file only has to make the framework non-empty so Xcode compiles it.

void anytype_flutter_keep_alive(void) {}
