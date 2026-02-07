import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:manytype_core/manytype_core.dart';
import 'package:manytype_protocol/coordinator.dart';
import 'package:manytype_protocol/manytype_protocol.dart' show Key, KeyType;

import 'identity.dart';
import 'peer_id.dart';

typedef CoordinatorUnaryInvoker = Uint8List Function(
  int handleId,
  String method,
  Uint8List payload,
);

class PreparedSpaceDeleteRequest {
  const PreparedSpaceDeleteRequest({
    required this.peerId,
    required this.payloadId,
    required this.signedPayload,
    required this.request,
  });

  final String peerId;
  final String payloadId;
  final DeletionConfirmPayloadWithSignature signedPayload;
  final SpaceDeleteRequest request;
}

class PreparedAccountDeleteRequest {
  const PreparedAccountDeleteRequest({
    required this.peerId,
    required this.payloadId,
    required this.signedPayload,
    required this.request,
  });

  final String peerId;
  final String payloadId;
  final DeletionConfirmPayloadWithSignature signedPayload;
  final AccountDeleteRequest request;
}

class CoordinatorService {
  CoordinatorService({required CoordinatorUnaryInvoker invoker})
      : _invoker = invoker;

  final CoordinatorUnaryInvoker _invoker;

  NetworkConfigurationResponse networkConfiguration({String currentId = ''}) {
    final request = NetworkConfigurationRequest(
      currentId: currentId,
    ).writeToBuffer();
    final responseBytes = _invoker(
      0,
      '/coordinator.Coordinator/NetworkConfiguration',
      Uint8List.fromList(request),
    );
    return NetworkConfigurationResponse.fromBuffer(responseBytes);
  }

  NetworkConfigurationResponse networkConfigurationForHandle(
    int handleId, {
    String currentId = '',
  }) {
    final request = NetworkConfigurationRequest(
      currentId: currentId,
    ).writeToBuffer();
    final responseBytes = _invoker(
      handleId,
      '/coordinator.Coordinator/NetworkConfiguration',
      Uint8List.fromList(request),
    );
    return NetworkConfigurationResponse.fromBuffer(responseBytes);
  }

  SpaceStatusPayload spaceStatusCheck({
    required int handleId,
    required String spaceId,
  }) {
    final request = SpaceStatusCheckRequest(
      spaceId: spaceId,
    ).writeToBuffer();
    final responseBytes = _invoker(
      handleId,
      '/coordinator.Coordinator/SpaceStatusCheck',
      Uint8List.fromList(request),
    );
    final response = SpaceStatusCheckResponse.fromBuffer(responseBytes);
    if (!response.hasPayload()) {
      throw StateError('SpaceStatusCheck returned no payload for $spaceId');
    }
    return response.payload;
  }

  List<DeletionLogRecord> deletionLog({
    required int handleId,
    String afterId = '',
    int limit = 100,
  }) {
    final request = DeletionLogRequest(
      afterId: afterId,
      limit: limit,
    ).writeToBuffer();
    final responseBytes = _invoker(
      handleId,
      '/coordinator.Coordinator/DeletionLog',
      Uint8List.fromList(request),
    );
    final response = DeletionLogResponse.fromBuffer(responseBytes);
    return response.records.toList(growable: false);
  }

  Future<PreparedSpaceDeleteRequest> prepareSpaceDelete({
    required String spaceId,
    required Identity identity,
    required String networkId,
    int deletionDurationMinutes = 0,
  }) async {
    final peerId = encodeLibp2pPeerId(identity.keyPair.publicKey);
    final signed = await prepareSpaceDeleteConfirmation(
      identity: identity,
      spaceId: spaceId,
      networkId: networkId,
      peerId: peerId,
    );
    final payloadBytes = Uint8List.fromList(signed.writeToBuffer());
    final payloadId = await computeCid(payloadBytes);
    return PreparedSpaceDeleteRequest(
      peerId: peerId,
      payloadId: payloadId,
      signedPayload: signed,
      request: SpaceDeleteRequest(
        spaceId: spaceId,
        deletionPayloadId: payloadId,
        deletionPayload: payloadBytes,
        deletionDuration: Int64(deletionDurationMinutes),
      ),
    );
  }

  SpaceDeleteResponse sendSpaceDelete({
    required int handleId,
    required SpaceDeleteRequest request,
  }) {
    final responseBytes = _invoker(
      handleId,
      '/coordinator.Coordinator/SpaceDelete',
      Uint8List.fromList(request.writeToBuffer()),
    );
    return SpaceDeleteResponse.fromBuffer(responseBytes);
  }

  Future<SpaceDeleteResponse> spaceDelete({
    required int handleId,
    required String spaceId,
    required Identity identity,
    required String networkId,
    int deletionDurationMinutes = 0,
  }) async {
    final prepared = await prepareSpaceDelete(
      spaceId: spaceId,
      identity: identity,
      networkId: networkId,
      deletionDurationMinutes: deletionDurationMinutes,
    );
    return sendSpaceDelete(handleId: handleId, request: prepared.request);
  }

  Future<PreparedAccountDeleteRequest> prepareAccountDelete({
    required Identity identity,
    required String networkId,
  }) async {
    final peerId = encodeLibp2pPeerId(identity.keyPair.publicKey);
    final signed = await prepareAccountDeleteConfirmation(
      identity: identity,
      networkId: networkId,
      peerId: peerId,
    );
    final payloadBytes = Uint8List.fromList(signed.writeToBuffer());
    final payloadId = await computeCid(payloadBytes);
    return PreparedAccountDeleteRequest(
      peerId: peerId,
      payloadId: payloadId,
      signedPayload: signed,
      request: AccountDeleteRequest(
        deletionPayloadId: payloadId,
        deletionPayload: payloadBytes,
      ),
    );
  }

  AccountDeleteResponse sendAccountDelete({
    required int handleId,
    required AccountDeleteRequest request,
  }) {
    final responseBytes = _invoker(
      handleId,
      '/coordinator.Coordinator/AccountDelete',
      Uint8List.fromList(request.writeToBuffer()),
    );
    return AccountDeleteResponse.fromBuffer(responseBytes);
  }

  Future<AccountDeleteResponse> accountDelete({
    required int handleId,
    required Identity identity,
    required String networkId,
  }) async {
    final prepared = await prepareAccountDelete(
      identity: identity,
      networkId: networkId,
    );
    return sendAccountDelete(handleId: handleId, request: prepared.request);
  }
}

Future<DeletionConfirmPayloadWithSignature> prepareSpaceDeleteConfirmation({
  required Identity identity,
  required String spaceId,
  required String networkId,
  String? peerId,
}) async {
  final resolvedPeerId =
      peerId ?? encodeLibp2pPeerId(identity.keyPair.publicKey);
  final payload = DeletionConfirmPayload(
    spaceId: spaceId,
    peerId: resolvedPeerId,
    accountIdentity:
        _marshalEd25519PublicKey(identity.accountKeyPair.publicKey),
    networkId: networkId,
    timestamp: Int64(DateTime.now().millisecondsSinceEpoch ~/ 1000),
  );
  return _signDeletePayload(
    payloadBytes: Uint8List.fromList(payload.writeToBuffer()),
    accountSeed: identity.accountSeed,
  );
}

Future<DeletionConfirmPayloadWithSignature> prepareAccountDeleteConfirmation({
  required Identity identity,
  required String networkId,
  String? peerId,
}) async {
  final resolvedPeerId =
      peerId ?? encodeLibp2pPeerId(identity.keyPair.publicKey);
  final payload = AccountDeletionConfirmPayload(
    peerId: resolvedPeerId,
    accountIdentity:
        _marshalEd25519PublicKey(identity.accountKeyPair.publicKey),
    networkId: networkId,
    timestamp: Int64(DateTime.now().millisecondsSinceEpoch ~/ 1000),
  );
  return _signDeletePayload(
    payloadBytes: Uint8List.fromList(payload.writeToBuffer()),
    accountSeed: identity.accountSeed,
  );
}

Future<DeletionConfirmPayloadWithSignature> _signDeletePayload({
  required Uint8List payloadBytes,
  required Uint8List accountSeed,
}) async {
  final signature = await ed25519Sign(accountSeed, payloadBytes);
  return DeletionConfirmPayloadWithSignature(
    deletionPayload: payloadBytes,
    signature: signature,
  );
}

Uint8List _marshalEd25519PublicKey(Uint8List publicKey) => Uint8List.fromList(
      Key(
        type: KeyType.Ed25519Public,
        data: publicKey,
      ).writeToBuffer(),
    );
