# anytype_flutter example

Loads the QUIC bridge that `anytype_flutter` builds and bundles, shows its ABI
version, then creates a local account in a temporary storage root and adds
notes to it. The recovery phrase is never displayed.

```sh
flutter run -d linux   # or macos, windows, an Android or iOS device
```

Building requires a Rust toolchain installed with rustup, because cargokit
compiles the bridge from `../rust` for the target platform.

Inside the ManyType repository the example is a pub workspace member. To run
a copy downloaded with the package, first delete the `resolution: workspace`
line from its `pubspec.yaml`, since there is no workspace root around it.
