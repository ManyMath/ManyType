// Archive gate helper: entry point of the fresh Flutter consumer that
// scripts/check_sdk_archives.sh builds on the hosted anytype_flutter.
import 'dart:io';

import 'package:anytype_flutter/anytype_flutter.dart';
import 'package:flutter/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  stdout.writeln(
    'anytype_flutter bridge ABI ${AnytypeFlutter.ensureInitialized()}',
  );
  runApp(const SizedBox());
}
