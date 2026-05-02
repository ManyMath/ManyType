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
        'labels a successful response as unsupported-and-unverifiable, '
        'never claiming acceptance from response alone', () {
      final result = assessAccountDeleteContract(
        responseOk: true,
        responseError: null,
      );

      expect(result.supported, isFalse);
      expect(result.outcome, 'unsupported-surface-or-scenario');
      expect(result.observedSurfaceLabel, 'response-succeeded-but-unverifiable');
      expect(result.reason, contains(kAccountDeleteVerificationCaveat));
    });
  });
}
