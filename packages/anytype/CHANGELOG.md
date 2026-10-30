## 0.0.2

- First working release, replacing the 0.0.1-dev.1 placeholder. The SDK is
  ManyType's client library, formerly the unpublished `manytype_client`.
- Accounts derived from BIP-39 recovery phrases, with restore on other
  devices and pluggable platform storage for the phrase.
- Encrypted local object store with create, edit, read, list and delete
  operations on Anytype block-model objects.
- Push and pull synchronization over QUIC through the `manytype_quic_ffi`
  Rust bridge. Flutter apps get it from `anytype_flutter`; Dart programs build
  it from that package's Rust sources.
- `ManytypeStorage.directory` selects the native storage root, and
  `NativeBridge.libraryPath` selects the bridge library.
