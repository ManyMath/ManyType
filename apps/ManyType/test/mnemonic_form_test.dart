import 'package:flutter_test/flutter_test.dart';
import 'package:manytype/src/onboarding/mnemonic_form.dart';

const _valid =
    'abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon abandon about';

void main() {
  group('normalizeMnemonic', () {
    test('collapses whitespace and lowercases', () {
      expect(
        normalizeMnemonic('  Abandon\n abandon\tABANDON  '),
        'abandon abandon abandon',
      );
    });
  });

  group('mnemonicInputError', () {
    test('accepts a valid 12-word phrase', () {
      expect(mnemonicInputError(_valid), isNull);
    });

    test('accepts a valid phrase with messy whitespace and caps', () {
      expect(mnemonicInputError('  ${_valid.toUpperCase()}\n'), isNull);
    });

    test('rejects empty input', () {
      expect(mnemonicInputError('   '), 'Enter your recovery phrase.');
    });

    test('rejects wrong word count', () {
      expect(
        mnemonicInputError('abandon abandon abandon'),
        contains('12 or 24 words'),
      );
    });

    test('rejects a bad checksum', () {
      final badChecksum = '${_valid.substring(0, _valid.length - 5)}zebra';
      expect(
        mnemonicInputError(badChecksum),
        contains('not a valid recovery phrase'),
      );
    });
  });
}
