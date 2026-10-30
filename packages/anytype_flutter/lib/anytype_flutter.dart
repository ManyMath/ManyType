/// Flutter integration for the `anytype` SDK.
///
/// Depending on this package builds the `manytype_quic_ffi` QUIC bridge for
/// your app with cargokit and bundles it, so `anytype`'s synchronization
/// works with no further native setup. It re-exports the full `anytype` API.
///
/// ```dart
/// import 'package:anytype_flutter/anytype_flutter.dart';
///
/// void main() {
///   AnytypeFlutter.ensureInitialized();
///   // ManytypeSession, AccountRegistry, ... as in package:anytype.
/// }
/// ```
library;

import 'package:anytype/anytype.dart';

export 'package:anytype/anytype.dart';

/// Flutter-side helpers over `package:anytype`.
abstract final class AnytypeFlutter {
  /// Loads the bundled bridge now and returns its C ABI version.
  ///
  /// The SDK otherwise loads the bridge on its first network operation.
  /// Calling this at startup surfaces a missing or mismatched library
  /// immediately: it throws a [StateError] when no library loads, or when
  /// the loaded library's ABI differs from [NativeBridge.expectedAbiVersion].
  static int ensureInitialized() => NativeBridge().abiVersion;
}
