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
  Pointer<Uint8> identitySeed,
  Uint32 seedLen,
);
typedef FfiConnectDart = Pointer<FfiResult> Function(
  Pointer<Utf8> addr,
  Pointer<Uint8> identitySeed,
  int seedLen,
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

typedef FfiFreeHandleNative = Void Function(Uint64 handleId);
typedef FfiFreeHandleDart = void Function(int handleId);

typedef FfiFreeResultNative = Void Function(Pointer<FfiResult> result);
typedef FfiFreeResultDart = void Function(Pointer<FfiResult> result);

/// Dart FFI bindings to the manytype_quic_ffi Rust cdylib.
///
/// Provides high-level Dart methods that map to the 5 C FFI exports:
/// - [connect] -> ffi_connect
/// - [invoke] -> ffi_invoke
/// - [syncObject] -> ffi_sync_object
/// - [freeHandle] -> ffi_free_handle
/// - (internal) ffi_free_result
class NativeBridge {
  late final DynamicLibrary _lib;
  late final FfiConnectDart _connect;
  late final FfiInvokeDart _invoke;
  late final FfiSyncObjectDart _syncObject;
  late final FfiFreeHandleDart _freeHandle;
  late final FfiFreeResultDart _freeResult;

  NativeBridge() {
    _lib = _loadLibrary();
    _connect =
        _lib.lookupFunction<FfiConnectNative, FfiConnectDart>('ffi_connect');
    _invoke =
        _lib.lookupFunction<FfiInvokeNative, FfiInvokeDart>('ffi_invoke');
    _syncObject = _lib
        .lookupFunction<FfiSyncObjectNative, FfiSyncObjectDart>(
            'ffi_sync_object');
    _freeHandle = _lib
        .lookupFunction<FfiFreeHandleNative, FfiFreeHandleDart>(
            'ffi_free_handle');
    _freeResult = _lib
        .lookupFunction<FfiFreeResultNative, FfiFreeResultDart>(
            'ffi_free_result');
  }

  /// Load the platform-specific shared library.
  static DynamicLibrary _loadLibrary() {
    if (Platform.isLinux) return DynamicLibrary.open('libmanytype_quic_ffi.so');
    if (Platform.isMacOS) {
      return DynamicLibrary.open('libmanytype_quic_ffi.dylib');
    }
    throw UnsupportedError(
        'Unsupported platform: ${Platform.operatingSystem}');
  }

  /// Connect to a QUIC server and perform credential handshake.
  ///
  /// [addr] is the server address (e.g. "127.0.0.1:4830").
  /// [identitySeed] is the 32-byte Ed25519 seed.
  /// Returns a handle ID for subsequent calls.
  int connect(String addr, Uint8List identitySeed) {
    final addrPtr = addr.toNativeUtf8();
    final seedPtr = calloc<Uint8>(identitySeed.length);
    seedPtr.asTypedList(identitySeed.length).setAll(0, identitySeed);

    final result = _connect(addrPtr, seedPtr, identitySeed.length);

    calloc.free(addrPtr);
    calloc.free(seedPtr);

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
  /// [changesData] is the length-prefixed changes payload.
  /// Returns the length-prefixed response bytes.
  Uint8List syncObject(
    int handleId,
    String spaceId,
    String objectId,
    Uint8List changesData,
  ) {
    final spacePtr = spaceId.toNativeUtf8();
    final objPtr = objectId.toNativeUtf8();
    final dataPtr = calloc<Uint8>(changesData.length);
    dataPtr.asTypedList(changesData.length).setAll(0, changesData);

    final result =
        _syncObject(handleId, spacePtr, objPtr, dataPtr, changesData.length);

    calloc.free(spacePtr);
    calloc.free(objPtr);
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
