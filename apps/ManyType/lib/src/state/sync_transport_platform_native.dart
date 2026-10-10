import 'dart:io';

/// The native QUIC bridge is only built for macOS and Linux; loading it
/// anywhere else throws [UnsupportedError].
bool get nativeSyncTransportAvailable => Platform.isMacOS || Platform.isLinux;
