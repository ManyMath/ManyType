import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
// AccountRegistry remains an internal CLI implementation detail until its
// host-configuration API is promoted through the package barrel.
// ignore: implementation_imports
import 'package:manytype_cli/src/account_registry.dart';

import 'src/app.dart';
import 'src/security/platform_recovery_phrase_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    AccountRegistry.configureRecoveryPhraseStore(PlatformRecoveryPhraseStore());
  }
  runApp(const ProviderScope(child: ManyTypeApp()));
}
