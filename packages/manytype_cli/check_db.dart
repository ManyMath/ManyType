import 'dart:convert';
import 'package:anytype/anytype.dart';

import 'package:manytype_core/manytype_core.dart';

void main() async {
  final db = ManytypeDatabase('test_db.db');
  final config = CliConfig(
    mnemonic: generateMnemonic(),
    serverAddress: '127.0.0.1:33020',
  );
  await createCommand("test text", db, config);

  final objects = await db.getAllObjects();
  for (final obj in objects) {
    print('Object: ${obj.id}');
    final changes = await db.getChangesForObject(obj.id);
    for (final c in changes) {
      final parents = jsonDecode(c.parentHeads) as List;
      print('  Change: ${c.id}, parents: $parents, isRoot: ${parents.isEmpty}');
    }
  }
  await db.close();
}
