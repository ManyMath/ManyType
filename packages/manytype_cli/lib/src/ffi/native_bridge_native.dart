import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

/// FFI struct matching Rust FfiResult.
///
/// On success: `data` is non-null with `dataLen` bytes, `error` is null.
/// On error: `error` is a non-null C string, `data` is null.
final class FfiResult extends Struct {
  external Pointer<Uint8> data;

  @Uint32()
  external int dataLen;

  external Pointer<Utf8> error;
}

// Native (C ABI) function signatures.
typedef FfiConnectNative = Pointer<FfiResult> Function(
  Pointer<Utf8> addr,
  Pointer<Utf8> expectedPeerId,
  Pointer<Uint8> peerSeed,
  Uint32 peerSeedLen,
  Pointer<Uint8> accountSeed,
  Uint32 accountSeedLen,
);
typedef FfiConnectDart = Pointer<FfiResult> Function(
  Pointer<Utf8> addr,
  Pointer<Utf8> expectedPeerId,
  Pointer<Uint8> peerSeed,
  int peerSeedLen,
  Pointer<Uint8> accountSeed,
  int accountSeedLen,
);

typedef FfiInvokeNative = Pointer<FfiResult> Function(
  Uint64 handleId,
  Pointer<Utf8> method,
  Pointer<Uint8> payload,
  Uint32 payloadLen,
);
typedef FfiInvokeDart = Pointer<FfiResult> Function(
  int handleId,
  Pointer<Utf8> method,
  Pointer<Uint8> payload,
  int payloadLen,
);

typedef FfiSyncObjectNative = Pointer<FfiResult> Function(
  Uint64 handleId,
  Pointer<Utf8> spaceId,
  Pointer<Utf8> objectId,
  Pointer<Uint8> changesData,
  Uint32 changesLen,
);
typedef FfiSyncObjectDart = Pointer<FfiResult> Function(
  int handleId,
  Pointer<Utf8> spaceId,
  Pointer<Utf8> objectId,
  Pointer<Uint8> changesData,
  int changesLen,
);

typedef FfiRequestObjectNative = Pointer<FfiResult> Function(
  Uint64 handleId,
  Pointer<Utf8> spaceId,
  Pointer<Utf8> objectId,
  Pointer<Uint8> requestData,
  Uint32 requestLen,
);
typedef FfiRequestObjectDart = Pointer<FfiResult> Function(
  int handleId,
  Pointer<Utf8> spaceId,
  Pointer<Utf8> objectId,
  Pointer<Uint8> requestData,
  int requestLen,
);

typedef FfiFreeHandleNative = Void Function(Uint64 handleId);
typedef FfiFreeHandleDart = void Function(int handleId);

typedef FfiFreeResultNative = Void Function(Pointer<FfiResult> result);
typedef FfiFreeResultDart = void Function(Pointer<FfiResult> result);

/// Dart FFI bindings to the manytype_quic_ffi Rust cdylib.
///
/// Provides high-level Dart methods that map to the 6 C FFI exports:
/// - [connect] -> ffi_connect
/// - [invoke] -> ffi_invoke
/// - [syncObject] -> ffi_sync_object
/// - [requestObject] -> ffi_request_object
/// - [syncStore] -> ffi_sync_store
/// - [freeHandle] -> ffi_free_handle
/// - (internal) ffi_free_result
typedef FfiSyncStoreNative = Pointer<FfiResult> Function(
  Uint64 handleId,
  Pointer<Uint8> messagesData,
  Uint32 messagesLen,
);
typedef FfiSyncStoreDart = Pointer<FfiResult> Function(
  int handleId,
  Pointer<Uint8> messagesData,
  int messagesLen,
);

typedef FfiAbiVersionNative = Uint32 Function();
typedef FfiAbiVersionDart = int Function();

/// Resolves locations used by the native QUIC bridge loader.
///
/// The macOS bundle layout is kept here, next to the loader,
/// so package verification exercises the same path contract as the app.
class NativeLibraryLocator {
  static const macOSLibraryName = 'libmanytype_quic_ffi.dylib';
  static const linuxLibraryName = 'libmanytype_quic_ffi.so';

  static String? libraryNameForOperatingSystem(String operatingSystem) {
    return switch (operatingSystem) {
      'linux' => linuxLibraryName,
      'macos' => macOSLibraryName,
      _ => null,
    };
  }

  static String macOSBundleLibraryPath(String executablePath) {
    final contentsDirectory = File(executablePath).absolute.parent.parent;
    return '${contentsDirectory.path}/Frameworks/$macOSLibraryName';
  }

  static List<String> developmentLibraryPaths(
    String libraryName, {
    required String workingDirectory,
  }) {
    final paths = <String>[];
    var directory = Directory(workingDirectory).absolute;
    while (true) {
      paths
        ..add('${directory.path}/rust/target/release/$libraryName')
        ..add('${directory.path}/rust/target/debug/$libraryName');
      if (directory.parent.path == directory.path) {
        break;
      }
      directory = directory.parent;
    }
    return paths;
  }
}

class NativeBridge {
  /// C ABI version these bindings are written against.
  static const expectedAbiVersion = 2;

  final DynamicLibrary _lib;
  late final FfiAbiVersionDart _abiVersion;
  late final FfiConnectDart _connect;
  late final FfiInvokeDart _invoke;
  late final FfiSyncObjectDart _syncObject;
  late final FfiRequestObjectDart _requestObject;
  late final FfiSyncStoreDart _syncStore;
  late final FfiFreeHandleDart _freeHandle;
  late final FfiFreeResultDart _freeResult;

  NativeBridge() : this._(_loadLibrary());

  /// Load as if [executablePath] were the running macOS app executable.
  ///
  /// This is exposed only from the package's internal FFI
  /// implementation so release tooling can probe an assembled `.app` using
  /// the exact production bundle-path resolver.
  NativeBridge.forExecutablePath(String executablePath)
      : this._(_loadLibrary(resolvedExecutablePath: executablePath));

  NativeBridge._(this._lib) {
    _abiVersion = _lib.lookupFunction<FfiAbiVersionNative, FfiAbiVersionDart>(
        'ffi_abi_version');
    final loadedAbiVersion = _abiVersion();
    if (loadedAbiVersion != expectedAbiVersion) {
      throw StateError(
          'ManyType QUIC FFI ABI $loadedAbiVersion does not match the '
          'expected ABI $expectedAbiVersion; rebuild manytype_quic_ffi');
    }
    _connect =
        _lib.lookupFunction<FfiConnectNative, FfiConnectDart>('ffi_connect');
    _invoke = _lib.lookupFunction<FfiInvokeNative, FfiInvokeDart>('ffi_invoke');
    _syncObject = _lib.lookupFunction<FfiSyncObjectNative, FfiSyncObjectDart>(
        'ffi_sync_object');
    _requestObject =
        _lib.lookupFunction<FfiRequestObjectNative, FfiRequestObjectDart>(
            'ffi_request_object');
    _syncStore = _lib
        .lookupFunction<FfiSyncStoreNative, FfiSyncStoreDart>('ffi_sync_store');
    _freeHandle = _lib.lookupFunction<FfiFreeHandleNative, FfiFreeHandleDart>(
        'ffi_free_handle');
    _freeResult = _lib.lookupFunction<FfiFreeResultNative, FfiFreeResultDart>(
        'ffi_free_result');
  }

  /// Load the platform-specific shared library.
  static DynamicLibrary _loadLibrary({String? resolvedExecutablePath}) {
    final libName = NativeLibraryLocator.libraryNameForOperatingSystem(
        Platform.operatingSystem);
    if (libName == null) {
      throw UnsupportedError(
          'Unsupported platform: ${Platform.operatingSystem}');
    }

    final explicitPath = Platform.environment['MANYTYPE_QUIC_FFI_PATH'];
    if (explicitPath != null && explicitPath.isNotEmpty) {
      return DynamicLibrary.open(explicitPath);
    }

    if (Platform.isMacOS) {
      final packagedPath = NativeLibraryLocator.macOSBundleLibraryPath(
          resolvedExecutablePath ?? Platform.resolvedExecutable);
      if (File(packagedPath).existsSync()) {
        // A present bundle library is authoritative. Do not silently load a
        // developer build if its signature, architecture, or ABI is invalid.
        return DynamicLibrary.open(packagedPath);
      }
    }

    try {
      return DynamicLibrary.open(libName);
    } catch (_) {
      // Fallback for local dev/test: try to load the Rust cdylib from this repo.
      // This avoids requiring callers to set LD_LIBRARY_PATH manually.
      final candidates = NativeLibraryLocator.developmentLibraryPaths(
        libName,
        workingDirectory: Directory.current.path,
      );
      for (final candidate in candidates) {
        if (File(candidate).existsSync()) {
          return DynamicLibrary.open(candidate);
        }
      }
      rethrow;
    }
  }

  /// Version of the loaded native C ABI.
  int get abiVersion => _abiVersion();

  /// Connect to a QUIC server and perform credential handshake.
  ///
  /// [addr] is the server address (e.g. "127.0.0.1:4830").
  /// [peerSeed] is the 32-byte Ed25519 peer seed for libp2p TLS.
  /// [accountSeed] is the 32-byte Ed25519 account seed for credentials.
  /// [expectedPeerId] is the server's libp2p peer ID; when null or empty the
  /// server's identity is not verified.
  /// Returns a handle ID for subsequent calls.
  int connect(
    String addr,
    Uint8List peerSeed,
    Uint8List accountSeed, {
    String? expectedPeerId,
  }) {
    final addrPtr = addr.toNativeUtf8();
    final expectedPeerIdPtr = expectedPeerId == null || expectedPeerId.isEmpty
        ? nullptr
        : expectedPeerId.toNativeUtf8();
    final peerSeedPtr = calloc<Uint8>(peerSeed.length);
    final accountSeedPtr = calloc<Uint8>(accountSeed.length);

    final Pointer<FfiResult> result;
    try {
      peerSeedPtr.asTypedList(peerSeed.length).setAll(0, peerSeed);
      accountSeedPtr.asTypedList(accountSeed.length).setAll(0, accountSeed);
      result = _connect(
        addrPtr,
        expectedPeerIdPtr,
        peerSeedPtr,
        peerSeed.length,
        accountSeedPtr,
        accountSeed.length,
      );
    } finally {
      peerSeedPtr.asTypedList(peerSeed.length).fillRange(0, peerSeed.length, 0);
      accountSeedPtr
          .asTypedList(accountSeed.length)
          .fillRange(0, accountSeed.length, 0);
      calloc.free(addrPtr);
      if (expectedPeerIdPtr != nullptr) {
        calloc.free(expectedPeerIdPtr);
      }
      calloc.free(peerSeedPtr);
      calloc.free(accountSeedPtr);
    }

    return _processHandleResult(result);
  }

  /// Invoke a unary RPC on an established connection.
  ///
  /// [handleId] is the connection handle from [connect].
  /// [method] is the RPC path (e.g. "/coordinator.Coordinator/NetworkConfiguration").
  /// [payload] is the request protobuf bytes.
  /// Returns the response protobuf bytes.
  Uint8List invoke(int handleId, String method, Uint8List payload) {
    final methodPtr = method.toNativeUtf8();
    final payloadPtr = calloc<Uint8>(payload.length);
    payloadPtr.asTypedList(payload.length).setAll(0, payload);

    final result = _invoke(handleId, methodPtr, payloadPtr, payload.length);

    calloc.free(methodPtr);
    calloc.free(payloadPtr);

    return _processDataResult(result);
  }

  /// Sync one object's changes via ObjectSyncStream.
  ///
  /// [handleId] is the connection handle from [connect].
  /// [spaceId] and [objectId] identify the object.
  /// [payload] is the serialized TreeSyncMessage (or empty for pull).
  /// Returns raw response bytes (length-prefixed ObjectSyncMessages).
  Uint8List syncObject(
    int handleId,
    String spaceId,
    String objectId,
    Uint8List payload,
  ) {
    final spacePtr = spaceId.toNativeUtf8();
    final objPtr = objectId.toNativeUtf8();
    final dataPtr = calloc<Uint8>(payload.length);
    dataPtr.asTypedList(payload.length).setAll(0, payload);

    final result =
        _syncObject(handleId, spacePtr, objPtr, dataPtr, payload.length);

    calloc.free(spacePtr);
    calloc.free(objPtr);
    calloc.free(dataPtr);

    return _processDataResult(result);
  }

  /// Request one object's full sync state via ObjectSyncRequestStream.
  ///
  /// [payload] is the serialized TreeSyncMessage full-sync request.
  /// Returns raw response bytes (length-prefixed ObjectSyncMessages).
  Uint8List requestObject(
    int handleId,
    String spaceId,
    String objectId,
    Uint8List payload,
  ) {
    final spacePtr = spaceId.toNativeUtf8();
    final objPtr = objectId.toNativeUtf8();
    final dataPtr = calloc<Uint8>(payload.length);
    dataPtr.asTypedList(payload.length).setAll(0, payload);

    final result =
        _requestObject(handleId, spacePtr, objPtr, dataPtr, payload.length);

    calloc.free(spacePtr);
    calloc.free(objPtr);
    calloc.free(dataPtr);

    return _processDataResult(result);
  }

  /// Exchange serialized StoreKeyValue messages via StoreElements.
  ///
  /// [messagesData] is a length-prefixed sequence of protobuf messages.
  Uint8List syncStore(int handleId, Uint8List messagesData) {
    final dataPtr = calloc<Uint8>(messagesData.length);
    dataPtr.asTypedList(messagesData.length).setAll(0, messagesData);

    final result = _syncStore(handleId, dataPtr, messagesData.length);

    calloc.free(dataPtr);
    return _processDataResult(result);
  }

  /// Free a connection handle, closing the QUIC connection.
  void freeHandle(int handleId) => _freeHandle(handleId);

  /// Extract handle ID (u64 LE) from FfiResult data bytes.
  int _processHandleResult(Pointer<FfiResult> result) {
    final r = result.ref;
    if (r.error != nullptr) {
      final msg = r.error.toDartString();
      _freeResult(result);
      throw Exception('FFI error: $msg');
    }
    final data = r.data.asTypedList(r.dataLen);
    // Parse u64 LE from first 8 bytes
    final bd = ByteData.sublistView(Uint8List.fromList(data));
    final handleId = bd.getUint64(0, Endian.little);
    _freeResult(result);
    return handleId;
  }

  /// Extract data bytes from FfiResult, freeing the native memory.
  Uint8List _processDataResult(Pointer<FfiResult> result) {
    final r = result.ref;
    if (r.error != nullptr) {
      final msg = r.error.toDartString();
      _freeResult(result);
      throw Exception('FFI error: $msg');
    }
    final data = Uint8List.fromList(r.data.asTypedList(r.dataLen));
    _freeResult(result);
    return data;
  }
}
