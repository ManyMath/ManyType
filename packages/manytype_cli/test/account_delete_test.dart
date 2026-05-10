import 'package:manytype_cli/src/commands/account_delete.dart';
import 'package:test/test.dart';

void main() {
  group('assessAccountDeleteContract', () {
    test('labels a rejected request as unsupported', () {
      final result = assessAccountDeleteContract(
        responseOk: false,
        responseError: 'account is deleted',
      );

      expect(result.supported, isFalse);
      expect(result.outcome, 'unsupported-surface-or-scenario');
      expect(result.observedSurfaceLabel, 'request-rejected');
      expect(result.reason, contains('account is deleted'));
    });

    test(
        'labels a successful response with no second-call proof as '
        'unsupported-and-unverifiable, never claiming acceptance from a '
        'single response alone', () {
      final result = assessAccountDeleteContract(
        responseOk: true,
        responseError: null,
      );

      expect(result.supported, isFalse);
      expect(result.outcome, 'unsupported-surface-or-scenario');
      expect(
          result.observedSurfaceLabel, 'response-succeeded-but-unverifiable');
      expect(result.reason, contains(kAccountDeleteVerificationCaveat));
    });

    test(
        'accepts the bounded contract when a second call for the same '
        'identity is rejected as already-deleted', () {
      final result = assessAccountDeleteContract(
        responseOk: true,
        responseError: null,
        secondCallOk: false,
        secondCallError:
            'Exception: FFI error: remote error: account is deleted',
      );

      expect(result.supported, isTrue);
      expect(result.outcome, 'supported-and-verified');
      expect(
        result.observedSurfaceLabel,
        'accepted-account-delete-idempotency-surface',
      );
      expect(result.reason, contains('account is deleted'));
    });

    test(
        'does not accept when the second call succeeds instead of being '
        'rejected (stub/no-op surface)', () {
      final result = assessAccountDeleteContract(
        responseOk: true,
        responseError: null,
        secondCallOk: true,
        secondCallError: null,
      );

      expect(result.supported, isFalse);
      expect(result.outcome, 'unsupported-surface-or-scenario');
      expect(
        result.observedSurfaceLabel,
        'response-succeeded-but-unverifiable',
      );
    });

    test('does not accept when the second call fails for an unrelated reason',
        () {
      final result = assessAccountDeleteContract(
        responseOk: true,
        responseError: null,
        secondCallOk: false,
        secondCallError: 'Exception: connection reset',
      );

      expect(result.supported, isFalse);
      expect(result.outcome, 'unsupported-surface-or-scenario');
    });
  });
}
