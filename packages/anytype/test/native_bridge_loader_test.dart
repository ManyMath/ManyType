@TestOn('vm')
library;

import 'dart:io';

import 'package:anytype/src/ffi/native_bridge_native.dart';
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
      NativeLibraryLocator.libraryNameForOperatingSystem('ios'),
      NativeLibraryLocator.macOSLibraryName,
    );
    expect(
      NativeLibraryLocator.libraryNameForOperatingSystem('android'),
      NativeLibraryLocator.linuxLibraryName,
    );
    expect(
      NativeLibraryLocator.libraryNameForOperatingSystem('windows'),
      NativeLibraryLocator.windowsLibraryName,
    );
    expect(
      NativeLibraryLocator.libraryNameForOperatingSystem('fuchsia'),
      isNull,
    );
  });

  test('resolves the dylib inside the macOS app Frameworks directory', () {
    final temporaryDirectory = Directory.systemTemp.createTempSync();
    addTearDown(() => temporaryDirectory.deleteSync(recursive: true));
    final separator = Platform.pathSeparator;
    final executable =
        '${temporaryDirectory.path}${separator}ManyType.app'
        '${separator}Contents${separator}MacOS${separator}manytype';

    expect(
      NativeLibraryLocator.macOSBundleLibraryPath(executable),
      '${temporaryDirectory.path}${separator}ManyType.app'
      '${separator}Contents${separator}Frameworks${separator}'
      '${NativeLibraryLocator.macOSLibraryName}',
    );
  });

  test('locates the anytype_flutter bundle beside each app layout', () {
    final separator = Platform.pathSeparator;
    final root = Directory.systemTemp.path;
    String path(List<String> parts) => [root, ...parts].join(separator);

    expect(
      NativeLibraryLocator.pluginBundlePath('linux', path(['bundle', 'app'])),
      path(['bundle', 'lib', NativeLibraryLocator.linuxLibraryName]),
    );
    expect(
      NativeLibraryLocator.pluginBundlePath(
        'windows',
        path(['Release', 'app.exe']),
      ),
      path(['Release', NativeLibraryLocator.windowsLibraryName]),
    );
    expect(
      NativeLibraryLocator.pluginBundlePath(
        'macos',
        path(['App.app', 'Contents', 'MacOS', 'app']),
      ),
      path([
        'App.app',
        'Contents',
        'Frameworks',
        'anytype_flutter.framework',
        'anytype_flutter',
      ]),
    );
    expect(
      NativeLibraryLocator.pluginBundlePath(
        'ios',
        path(['Runner.app', 'Runner']),
      ),
      path([
        'Runner.app',
        'Frameworks',
        'anytype_flutter.framework',
        'anytype_flutter',
      ]),
    );
    expect(
      NativeLibraryLocator.pluginBundlePath('android', path(['app'])),
      isNull,
    );
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

    String target(String root, String profile) => [
      root,
      'rust',
      'target',
      profile,
      NativeLibraryLocator.macOSLibraryName,
    ].join(separator);
    String pluginTarget(String root, String profile) => [
      root,
      'packages',
      'anytype_flutter',
      'rust',
      'target',
      profile,
      NativeLibraryLocator.macOSLibraryName,
    ].join(separator);

    expect(paths.take(8), [
      target(workingDirectory, 'release'),
      target(workingDirectory, 'debug'),
      pluginTarget(workingDirectory, 'release'),
      pluginTarget(workingDirectory, 'debug'),
      target(apps, 'release'),
      target(apps, 'debug'),
      pluginTarget(apps, 'release'),
      pluginTarget(apps, 'debug'),
    ]);
  });
}
