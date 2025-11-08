import 'dart:typed_data';
import 'package:manytype_protocol/changes.dart';
import 'package:manytype_protocol/models.dart';

void main() {
  final root = RootChange(
    aclHeadId: "bafyreih...",
    spaceId: "space-1",
  );
  final raw = RawTreeChange(payload: root.writeToBuffer());
  final tree = TreeChange.fromBuffer(raw.payload);
  print(tree.treeHeadIds);
}
