import 'package:anytype_flutter/anytype_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('re-exports the anytype API', () {
    expect(NativeBridge.expectedAbiVersion, 2);
    expect(ManytypeStorage.directory, isNull);
  });
}
