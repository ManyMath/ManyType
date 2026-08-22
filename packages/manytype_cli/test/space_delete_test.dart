import 'package:manytype_cli/src/commands/space_delete.dart';
import 'package:test/test.dart';

void main() {
  group('assessSpaceDeleteContract', () {
    test('accepts the bounded official contract', () {
      final result = assessSpaceDeleteContract(
        ownerSpaceMatches: true,
        preStatus: 'SpaceStatusCreated',
        prePermissions: 'SpacePermissionsOwner',
        responseOk: true,
        responseError: null,
        postStatus: 'SpaceStatusPendingDeletion',
        reconnectStatus: 'SpaceStatusDeleted',
      );

      expect(result.supported, isTrue);
      expect(result.outcome, 'supported-and-verified');
      expect(result.observedSurfaceLabel, 'accepted-space-delete-surface');
    });

    test('labels stub no-op surfaces as unsupported', () {
      final result = assessSpaceDeleteContract(
        ownerSpaceMatches: true,
        preStatus: 'SpaceStatusCreated',
        prePermissions: 'SpacePermissionsOwner',
        responseOk: true,
        responseError: null,
        postStatus: 'SpaceStatusCreated',
        reconnectStatus: 'SpaceStatusCreated',
      );

      expect(result.supported, isFalse);
      expect(result.outcome, 'unsupported-surface-or-scenario');
      expect(result.observedSurfaceLabel, 'stub-no-op-surface');
      expect(result.reason, contains('Deletion could not be verified'));
    });

    test('rejects non-owner preconditions before claiming parity', () {
      final result = assessSpaceDeleteContract(
        ownerSpaceMatches: true,
        preStatus: 'SpaceStatusCreated',
        prePermissions: 'SpacePermissionsWriter',
        responseOk: true,
        responseError: null,
        postStatus: 'SpaceStatusPendingDeletion',
        reconnectStatus: 'SpaceStatusDeleted',
      );

      expect(result.supported, isFalse);
      expect(result.outcome, 'precondition-failed');
      expect(result.reason, contains('owner permissions'));
    });
  });
}
