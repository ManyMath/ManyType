import 'dart:typed_data';

class NativeBridge {
  static const expectedAbiVersion = 2;

  NativeBridge() {
    throw UnsupportedError('NativeBridge is not available on web');
  }

  NativeBridge.forExecutablePath(String executablePath) {
    throw UnsupportedError('NativeBridge is not available on web');
  }

  int get abiVersion {
    throw UnsupportedError('NativeBridge.abiVersion is not available on web');
  }

  int connect(
    String addr,
    Uint8List peerSeed,
    Uint8List accountSeed, {
    String? expectedPeerId,
  }) {
    throw UnsupportedError('NativeBridge.connect is not available on web');
  }

  Uint8List invoke(int handleId, String method, Uint8List payload) {
    throw UnsupportedError('NativeBridge.invoke is not available on web');
  }

  Uint8List syncObject(
    int handleId,
    String spaceId,
    String objectId,
    Uint8List payload,
  ) {
    throw UnsupportedError('NativeBridge.syncObject is not available on web');
  }

  Uint8List requestObject(
    int handleId,
    String spaceId,
    String objectId,
    Uint8List payload,
  ) {
    throw UnsupportedError(
        'NativeBridge.requestObject is not available on web');
  }

  Uint8List syncStore(int handleId, Uint8List messagesData) {
    throw UnsupportedError('NativeBridge.syncStore is not available on web');
  }

  void freeHandle(int handleId) {
    throw UnsupportedError('NativeBridge.freeHandle is not available on web');
  }
}
