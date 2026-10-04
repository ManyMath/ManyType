import 'package:manytype_core/manytype_core.dart' show computeCid;

import 'identity.dart';

/// A local account profile: one mnemonic/identity, addressable by a
/// deterministic [id] derived from the account public key.
class AccountProfile {
  final String id;
  final String displayName;
  final String mnemonic;
  final DateTime createdAt;

  AccountProfile({
    required this.id,
    required this.displayName,
    required this.mnemonic,
    required this.createdAt,
  });

  /// Derive a short, deterministic, filesystem/db-name-safe account id from
  /// a mnemonic. Two calls with the same mnemonic always produce the same
  /// id; two different mnemonics collide only if the first 48 bits of their
  /// account public keys' SHA-256 digests match (CID of the account public
  /// key, truncated).
  static Future<String> deriveAccountId(String mnemonic) async {
    final identity = await Identity.fromMnemonic(mnemonic);
    final cid = await computeCid(identity.accountKeyPair.publicKey);
    // Strip the multibase 'b' prefix and keep 16 base32 chars. The first six
    // ("afyrei") encode the constant CIDv1/dag-cbor/sha2-256 header, so only
    // 48 digest bits remain. Ids are persisted: keep this derivation as is.
    return cid.substring(1, 17);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'mnemonic': mnemonic,
        'createdAt': createdAt.toIso8601String(),
      };

  static AccountProfile fromJson(Map<String, dynamic> json) => AccountProfile(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        mnemonic: json['mnemonic'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

/// Registry-facing summary of an account profile (no mnemonic: the secret
/// stays only in the account's own config, never in the shared registry).
class AccountSummary {
  final String id;
  final String displayName;
  final DateTime createdAt;

  /// True until an app-created starter template has been copied into this
  /// account. Persisting this in the registry lets a later launch resume an
  /// interrupted seed without inferring intent from the display name.
  final bool pendingStarterTemplate;

  /// When set, this account's config/db live at these exact paths instead
  /// of the standard `accounts/<id>/` convention. Used by
  /// [AccountRegistry.migrateLegacyAccount] to register a pre-existing
  /// legacy single-account install (`~/.manytype/config.toml`+`store.db`)
  /// as a real profile without moving or copying any files.
  final String? configPathOverride;
  final String? dbPathOverride;

  AccountSummary({
    required this.id,
    required this.displayName,
    required this.createdAt,
    this.pendingStarterTemplate = false,
    this.configPathOverride,
    this.dbPathOverride,
  });

  AccountSummary copyWith({
    String? displayName,
    bool? pendingStarterTemplate,
  }) =>
      AccountSummary(
        id: id,
        displayName: displayName ?? this.displayName,
        createdAt: createdAt,
        pendingStarterTemplate:
            pendingStarterTemplate ?? this.pendingStarterTemplate,
        configPathOverride: configPathOverride,
        dbPathOverride: dbPathOverride,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'createdAt': createdAt.toIso8601String(),
        if (pendingStarterTemplate) 'pendingStarterTemplate': true,
        if (configPathOverride != null)
          'configPathOverride': configPathOverride,
        if (dbPathOverride != null) 'dbPathOverride': dbPathOverride,
      };

  static AccountSummary fromJson(Map<String, dynamic> json) => AccountSummary(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        pendingStarterTemplate:
            json['pendingStarterTemplate'] as bool? ?? false,
        configPathOverride: json['configPathOverride'] as String?,
        dbPathOverride: json['dbPathOverride'] as String?,
      );
}
