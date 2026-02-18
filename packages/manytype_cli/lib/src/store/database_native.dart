import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

Future<QueryExecutor> openDatabaseForApp(String dbPath) async {
  final dir = Directory(dbPath).parent;
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return NativeDatabase.createInBackground(File(dbPath));
}

Future<QueryExecutor> openDatabaseForTesting({String? name}) {
  return Future.value(NativeDatabase.memory());
}

Future<Never> openWasmDatabaseForTesting({String? name}) {
  throw UnsupportedError(
    'openWasmDatabaseForTesting is only supported on web',
  );
}
