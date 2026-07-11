import 'dart:io';

import 'package:manytype_cli/src/ffi/native_bridge_native.dart';
import 'package:test/test.dart';

void main() {
  test('maps supported operating systems to stable library names', () {
    expect(
      NativeLibraryLocator.libraryNameForOperatingSystem('macos'),
      NativeLibraryLocator.macOSLibraryName,
    );
    expect(
      NativeLibraryLocator.libraryNameForOperatingSystem('linux'),
      NativeLibraryLocator.linuxLibraryName,
    );
    expect(
      NativeLibraryLocator.libraryNameForOperatingSystem('windows'),
      isNull,
    );
  });

  test('resolves the dylib inside the macOS app Frameworks directory', () {
    final temporaryDirectory = Directory.systemTemp.createTempSync();
    addTearDown(() => temporaryDirectory.deleteSync(recursive: true));
    final separator = Platform.pathSeparator;
    final executable = '${temporaryDirectory.path}${separator}ManyType.app'
        '${separator}Contents${separator}MacOS${separator}manytype';

    expect(
        NativeLibraryLocator.macOSBundleLibraryPath(executable),
        '${temporaryDirectory.path}${separator}ManyType.app'
        '${separator}Contents${separator}Frameworks${separator}'
        '${NativeLibraryLocator.macOSLibraryName}');
  });

  test('orders release before debug for each development ancestor', () {
    final temporaryDirectory = Directory.systemTemp.createTempSync();
    addTearDown(() => temporaryDirectory.deleteSync(recursive: true));
    final separator = Platform.pathSeparator;
    final repo = '${temporaryDirectory.path}${separator}repo';
    final apps = '$repo${separator}apps';
    final workingDirectory = '$apps${separator}ManyType';
    final paths = NativeLibraryLocator.developmentLibraryPaths(
      NativeLibraryLocator.macOSLibraryName,
      workingDirectory: workingDirectory,
    );

    expect(
      paths.take(4),
      [
        '$workingDirectory${separator}rust${separator}target${separator}release${separator}${NativeLibraryLocator.macOSLibraryName}',
        '$workingDirectory${separator}rust${separator}target${separator}debug${separator}${NativeLibraryLocator.macOSLibraryName}',
        '$apps${separator}rust${separator}target${separator}release${separator}${NativeLibraryLocator.macOSLibraryName}',
        '$apps${separator}rust${separator}target${separator}debug${separator}${NativeLibraryLocator.macOSLibraryName}',
      ],
    );
  });
}
