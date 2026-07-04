import 'package:manytype_core/manytype_core.dart' show generateMnemonic;

const guestDemoDisplayName = 'Demo workspace';
const guestDemoCreatingAccountMessage = 'Creating a fresh local account...';
const guestDemoSeedingTemplateMessage =
    'Copying sample content into your workspace...';

/// Public identity used by the pre-randomized demo flow. It remains detectable
/// only so upgraded installations cannot mistake that known identity for a
/// private account. New demo launches never use it.
const legacySharedDemoAccountId = 'afyreiddzo5xdffd';

bool isLegacySharedDemoAccountId(String? accountId) =>
    accountId == legacySharedDemoAccountId;

typedef GuestDemoAccountCreator =
    Future<String?> Function({
      required String mnemonic,
      required String displayName,
    });

class GuestDemoLaunchResult {
  const GuestDemoLaunchResult({
    required this.accountId,
    required this.templateObjectId,
  });

  final String accountId;
  final String? templateObjectId;
}

/// Creates a normal, recoverable local account and copies the demo template
/// into it. The account creator rejects existing or retired public identities,
/// so even an injected or faulty random source cannot reopen shared state.
Future<GuestDemoLaunchResult> createGuestDemoWorkspace({
  required GuestDemoAccountCreator createAndSelectIfNew,
  required Future<String?> Function() seedTemplate,
  String Function()? mnemonicGenerator,
  void Function(String message)? onProgress,
  int maxIdentityAttempts = 32,
}) async {
  if (maxIdentityAttempts < 1) {
    throw ArgumentError.value(
      maxIdentityAttempts,
      'maxIdentityAttempts',
      'must be positive',
    );
  }

  final generate = mnemonicGenerator ?? generateMnemonic;
  onProgress?.call(guestDemoCreatingAccountMessage);

  for (var attempt = 0; attempt < maxIdentityAttempts; attempt += 1) {
    final mnemonic = generate();
    final accountId = await createAndSelectIfNew(
      mnemonic: mnemonic,
      displayName: guestDemoDisplayName,
    );
    if (accountId == null) continue;
    onProgress?.call(guestDemoSeedingTemplateMessage);
    final templateObjectId = await seedTemplate();
    return GuestDemoLaunchResult(
      accountId: accountId,
      templateObjectId: templateObjectId,
    );
  }

  throw StateError('Could not generate a unique demo account identity.');
}
