import 'package:manytype_cli/src/account_profile.dart';
import 'package:test/test.dart';

void main() {
  // Known BIP-39 test vector mnemonics (also used in identity_test.dart).
  const mnemonicA =
      'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
  const mnemonicB =
      'guilt universe cup credit night tissue pencil window brother ecology marriage over';

  group('AccountProfile.deriveAccountId', () {
    test('is deterministic for the same mnemonic', () async {
      final idA1 = await AccountProfile.deriveAccountId(mnemonicA);
      final idA2 = await AccountProfile.deriveAccountId(mnemonicA);
      expect(idA1, idA2);
    });

    test('differs across distinct mnemonics', () async {
      final idA = await AccountProfile.deriveAccountId(mnemonicA);
      final idB = await AccountProfile.deriveAccountId(mnemonicB);
      expect(idA, isNot(idB));
    });

    test('is filesystem/db-name safe (lowercase alphanumeric only)', () async {
      final id = await AccountProfile.deriveAccountId(mnemonicA);
      expect(id, matches(RegExp(r'^[a-z0-9]+$')));
      expect(id.length, 16);
    });
  });

  group('AccountProfile JSON round-trip', () {
    test('toJson/fromJson preserves all fields', () {
      final createdAt = DateTime.utc(2026, 7, 1, 12);
      final profile = AccountProfile(
        id: 'abc123',
        displayName: 'work',
        mnemonic: mnemonicA,
        createdAt: createdAt,
      );

      final decoded = AccountProfile.fromJson(profile.toJson());

      expect(decoded.id, profile.id);
      expect(decoded.displayName, profile.displayName);
      expect(decoded.mnemonic, profile.mnemonic);
      expect(decoded.createdAt, createdAt);
    });
  });

  group('AccountSummary JSON round-trip', () {
    test('toJson/fromJson preserves all fields (no mnemonic)', () {
      final createdAt = DateTime.utc(2026, 7, 1, 12);
      final summary = AccountSummary(
        id: 'abc123',
        displayName: 'work',
        createdAt: createdAt,
        pendingStarterTemplate: true,
      );

      final decoded = AccountSummary.fromJson(summary.toJson());

      expect(decoded.id, summary.id);
      expect(decoded.displayName, summary.displayName);
      expect(decoded.createdAt, createdAt);
      expect(decoded.pendingStarterTemplate, isTrue);
      expect(summary.toJson().containsKey('mnemonic'), isFalse);
    });

    test('older JSON defaults starter-template state to complete', () {
      final decoded = AccountSummary.fromJson(<String, dynamic>{
        'id': 'abc123',
        'displayName': 'work',
        'createdAt': DateTime.utc(2026, 7, 1, 12).toIso8601String(),
      });

      expect(decoded.pendingStarterTemplate, isFalse);
    });
  });
}
