import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:manytype_protocol/manytype_protocol.dart';

import 'acl_record.dart';

/// ACL state machine that tracks permissions for all known identities.
///
/// Processes an ACL chain (root + subsequent records) and maintains
/// a permission map. Supports all AclContentValue variants per D-11.
class AclState {
  final Map<String, AclUserPermissions> _permissions = {};
  final Map<String, AclAccountStatus> _statuses = {};
  final List<VerifiedAclRecord> _records = [];
  final Map<String, _PendingInvite> _pendingInvites = {};
  final Map<String, _PendingRequest> _pendingRequests = {};
  String _headId = '';

  /// CID of the latest record in the chain.
  String get headId => _headId;

  /// All verified records in chain order.
  List<VerifiedAclRecord> get records => List.unmodifiable(_records);

  /// Apply the root record (first record in chain).
  ///
  /// Sets the owner identity with Owner permission.
  void applyRoot(VerifiedAclRecord record) {
    if (!record.isRoot) {
      throw StateError('Expected root record (empty prevId)');
    }
    if (_records.isNotEmpty) {
      throw StateError('Root already applied');
    }

    final identityHex = hex.encode(record.identity);
    _permissions[identityHex] = AclUserPermissions.Owner;
    _statuses[identityHex] = AclAccountStatus.active;
    _headId = record.id;
    _records.add(record);
  }

  /// Apply a subsequent record in the chain.
  ///
  /// Validates that prevId matches the current head, then processes
  /// each AclContentValue in the record's aclData.
  void applyRecord(VerifiedAclRecord record) {
    if (record.isRoot) {
      throw StateError('Cannot apply root record with applyRecord');
    }
    if (record.prevId != _headId) {
      throw StateError(
        'Invalid prevId: expected=$_headId, got=${record.prevId}',
      );
    }

    final aclData = record.aclData;
    if (aclData != null) {
      for (final content in aclData.aclContent) {
        _processContentValue(content, record.id);
      }
    }

    _headId = record.id;
    _records.add(record);
  }

  /// Get the permission level for an identity (hex-encoded public key).
  AclUserPermissions? getPermission(String identityHex) =>
      _permissions[identityHex];

  /// Get the lifecycle status for an identity (hex-encoded public key).
  AclAccountStatus? getStatus(String identityHex) => _statuses[identityHex];

  /// Check if an identity has at least the minimum required permission level.
  ///
  /// Permission levels: Owner(1) > Admin(2) > Writer(3) > Reader(4) > Guest(5).
  /// Lower numeric value = higher permission.
  bool hasPermission(String identityHex, AclUserPermissions minLevel) {
    final perm = _permissions[identityHex];
    if (perm == null) return false;
    // Lower value = higher permission (Owner=1 is highest)
    return perm.value <= minLevel.value && perm.value > 0;
  }

  /// Process a single AclContentValue, updating permissions and state.
  void _processContentValue(AclContentValue content, String recordId) {
    // Check which oneof variant is set
    if (content.hasInvite()) {
      _handleInvite(content.invite, recordId);
    } else if (content.hasInviteRevoke()) {
      _handleInviteRevoke(content.inviteRevoke);
    } else if (content.hasRequestJoin()) {
      _handleRequestJoin(content.requestJoin, recordId);
    } else if (content.hasRequestAccept()) {
      _handleRequestAccept(content.requestAccept);
    } else if (content.hasPermissionChange()) {
      _handlePermissionChange(content.permissionChange);
    } else if (content.hasAccountRemove()) {
      _handleAccountRemove(content.accountRemove);
    } else if (content.hasReadKeyChange()) {
      // Read key changes don't affect permissions
    } else if (content.hasRequestDecline()) {
      _handleRequestDecline(content.requestDecline);
    } else if (content.hasAccountRequestRemove()) {
      // Account request remove: no permission change needed immediately
    } else if (content.hasPermissionChanges()) {
      _handlePermissionChanges(content.permissionChanges);
    } else if (content.hasAccountsAdd()) {
      _handleAccountsAdd(content.accountsAdd);
    } else if (content.hasRequestCancel()) {
      _handleRequestCancel(content.requestCancel);
    } else if (content.hasInviteJoin()) {
      _handleInviteJoin(content.inviteJoin);
    } else if (content.hasInviteChange()) {
      _handleInviteChange(content.inviteChange);
    }
  }

  void _handleInvite(AclAccountInvite invite, String recordId) {
    final inviteKeyHex = _identityHex(invite.inviteKey);
    _pendingInvites[recordId] = _PendingInvite(
      inviteKeyHex: inviteKeyHex,
      permissions: invite.permissions,
    );
  }

  void _handleInviteRevoke(AclAccountInviteRevoke revoke) {
    _pendingInvites.remove(revoke.inviteRecordId);
  }

  void _handleRequestJoin(AclAccountRequestJoin request, String recordId) {
    final identityHex = _identityHex(request.inviteIdentity);
    _pendingRequests[recordId] = _PendingRequest(
      identityHex: identityHex,
      inviteRecordId: request.inviteRecordId,
    );
    _statuses[identityHex] = AclAccountStatus.pending;
  }

  void _handleRequestAccept(AclAccountRequestAccept accept) {
    final identityHex = _identityHex(accept.identity);
    _permissions[identityHex] = accept.permissions;
    _statuses[identityHex] = AclAccountStatus.active;
    _pendingRequests.remove(accept.requestRecordId);
  }

  void _handleRequestDecline(AclAccountRequestDecline decline) {
    final pending = _pendingRequests.remove(decline.requestRecordId);
    if (pending != null) {
      _statuses[pending.identityHex] = AclAccountStatus.declined;
    }
  }

  void _handlePermissionChange(AclAccountPermissionChange change) {
    final identityHex = _identityHex(change.identity);
    if (change.permissions == AclUserPermissions.None) {
      _permissions.remove(identityHex);
      _statuses[identityHex] = AclAccountStatus.removed;
    } else {
      _permissions[identityHex] = change.permissions;
      _statuses[identityHex] = AclAccountStatus.active;
    }
  }

  void _handlePermissionChanges(AclAccountPermissionChanges changes) {
    for (final change in changes.changes) {
      _handlePermissionChange(change);
    }
  }

  void _handleAccountRemove(AclAccountRemove remove) {
    for (final identity in remove.identities) {
      final identityHex = _identityHex(identity);
      _permissions.remove(identityHex);
      _statuses[identityHex] = AclAccountStatus.removed;
    }
  }

  void _handleAccountsAdd(AclAccountsAdd accountsAdd) {
    for (final addition in accountsAdd.additions) {
      final identityHex = _identityHex(addition.identity);
      _permissions[identityHex] = addition.permissions;
      _statuses[identityHex] = AclAccountStatus.active;
    }
  }

  void _handleRequestCancel(AclAccountRequestCancel cancel) {
    final pending = _pendingRequests.remove(cancel.recordId);
    if (pending != null) {
      _statuses[pending.identityHex] = AclAccountStatus.canceled;
    }
  }

  void _handleInviteJoin(AclAccountInviteJoin join) {
    final identityHex = _identityHex(join.identity);
    // Use the permissions from the join message
    _permissions[identityHex] = join.permissions;
    _statuses[identityHex] = AclAccountStatus.active;
  }

  void _handleInviteChange(AclAccountInviteChange change) {
    final invite = _pendingInvites[change.inviteRecordId];
    if (invite != null) {
      _pendingInvites[change.inviteRecordId] = _PendingInvite(
        inviteKeyHex: invite.inviteKeyHex,
        permissions: change.permissions,
      );
    }
  }
}

enum AclAccountStatus {
  active,
  pending,
  declined,
  canceled,
  removed,
}

class _PendingInvite {
  final String inviteKeyHex;
  final AclUserPermissions permissions;

  _PendingInvite({required this.inviteKeyHex, required this.permissions});
}

class _PendingRequest {
  final String identityHex;
  final String inviteRecordId;

  _PendingRequest({required this.identityHex, required this.inviteRecordId});
}

String _identityHex(List<int> identityBytes) =>
    hex.encode(_decodeIdentityPublicKey(identityBytes));

Uint8List _decodeIdentityPublicKey(List<int> identityBytes) {
  try {
    final key = Key.fromBuffer(identityBytes);
    if (key.type == KeyType.Ed25519Public && key.data.length == 32) {
      return Uint8List.fromList(key.data);
    }
  } catch (_) {
    // Fall back to legacy raw 32-byte identities used in earlier local tests.
  }
  return Uint8List.fromList(identityBytes);
}
