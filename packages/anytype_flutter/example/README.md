# anytype_flutter example

Loads the QUIC bridge that `anytype_flutter` builds and bundles, shows its ABI
version, then creates a local account in a temporary storage root and adds
notes to it. The recovery phrase is never displayed.

```sh
flutter run -d linux   # or macos, windows, an Android or iOS device
```

Building requires a Rust toolchain installed with rustup, because cargokit
compiles the bridge from `../rust` for the target platform.
