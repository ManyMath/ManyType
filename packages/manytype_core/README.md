# manytype_core

Pure Dart building blocks for Any-Sync clients, used by the
[anytype](https://pub.dev/packages/anytype) SDK:

- BIP-39 phrases, SLIP-0010 and SLIP-0021 key derivation.
- AES-GCM, Ed25519 and X25519 helpers in the byte formats Any-Sync uses.
- ACL record building and state.
- CRDT object trees: change building, content IDs, snapshots and replay of
  Anytype block-model objects.

It has no native, storage or network dependencies. Most applications should
use `anytype`, which adds accounts, storage and synchronization on top.

```dart
import 'package:manytype_core/manytype_core.dart';

final phrase = generateMnemonic();
final seed = mnemonicToSeed(phrase);
```

Never log recovery phrases, seeds or private keys.

This is an independent implementation, not made or endorsed by Anytype or
the Any Association. Version 0.0.2 is an early release whose API may change.

## License

MIT. See [LICENSE](LICENSE). The package depends on `manytype_protocol`,
whose Anytype-heart types are under the Any Source Available License 1.0.
