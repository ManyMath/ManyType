// Builds the manytype_quic_ffi library for the project that runs it:
//
//   dart run anytype:build_native [--debug] [--output-dir <dir>]
//
// The library is placed under the project's .dart_tool/anytype/native,
// where NativeBridge looks for it. Cargo builds from the Rust sources
// shipped in this package with their locked dependency versions.
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:anytype/src/ffi/native_bridge_native.dart';
import 'package:path/path.dart' as p;

const _usage = '''
Build the manytype_quic_ffi library used by package:anytype.

Usage: dart run anytype:build_native [--debug] [--output-dir <dir>]

  --debug              Build without optimizations.
  --output-dir <dir>   Also copy the library into <dir>, e.g. to bundle it.

Requires Rust 1.88 or newer with cargo on PATH.''';

Future<void> main(List<String> arguments) async {
  var release = true;
  String? outputDir;
  for (var i = 0; i < arguments.length; i++) {
    final argument = arguments[i];
    if (argument == '--debug') {
      release = false;
    } else if (argument == '--output-dir' && i + 1 < arguments.length) {
      outputDir = arguments[++i];
    } else if (argument.startsWith('--output-dir=')) {
      outputDir = argument.substring('--output-dir='.length);
    } else {
      stderr.writeln(_usage);
      exitCode = argument == '--help' || argument == '-h' ? 0 : 64;
      return;
    }
  }

  final libraryName = NativeLibraryLocator.libraryNameForOperatingSystem(
    Platform.operatingSystem,
  );
  if (libraryName == null) {
    stderr.writeln(
      'The QUIC bridge is supported on Linux and macOS only, '
      'not ${Platform.operatingSystem}.',
    );
    exitCode = 1;
    return;
  }

  final packageConfig = await Isolate.packageConfig;
  final library = await Isolate.resolvePackageUri(
    Uri.parse('package:anytype/anytype.dart'),
  );
  if (packageConfig == null || library == null) {
    stderr.writeln(
      'Run this with `dart run anytype:build_native` from a '
      'project that depends on anytype.',
    );
    exitCode = 1;
    return;
  }

  final packageRoot = File.fromUri(library).parent.parent.path;
  // A repository checkout builds from the live Rust workspace, never from a
  // staged snapshot that may predate local edits.
  final repositoryRust = p.normalize(p.join(packageRoot, '..', '..', 'rust'));
  final repositoryManifest = p.join(repositoryRust, 'Cargo.toml');
  final inRepository = File(
    p.join(repositoryRust, 'manytype_quic_ffi', 'Cargo.toml'),
  ).existsSync();
  final manifest = inRepository
      ? repositoryManifest
      : p.join(packageRoot, 'native', 'Cargo.toml');
  if (!File(manifest).existsSync()) {
    stderr.writeln('No Rust sources found at $manifest.');
    exitCode = 1;
    return;
  }

  final toolDirectory = p.join(
    File.fromUri(packageConfig).parent.path,
    'anytype',
  );
  final targetDirectory = p.join(toolDirectory, 'cargo');
  final profile = release ? 'release' : 'debug';
  final cargo =
      await Process.start('cargo', [
        'build',
        '--locked',
        if (release) '--release',
        '-p',
        'manytype_quic_ffi',
        '--manifest-path',
        manifest,
        '--target-dir',
        targetDirectory,
      ], mode: ProcessStartMode.inheritStdio).catchError((Object error) {
        stderr.writeln(
          'Could not start cargo ($error). Install Rust 1.88 or '
          'newer, for example from https://rustup.rs.',
        );
        exit(1);
      });
  final cargoExit = await cargo.exitCode;
  if (cargoExit != 0) {
    exitCode = cargoExit;
    return;
  }

  final built = File(p.join(targetDirectory, profile, libraryName));
  if (!built.existsSync()) {
    stderr.writeln(
      'cargo succeeded but ${built.path} does not exist. A configured '
      'build.target or CARGO_BUILD_TARGET moves the output; unset it to '
      'build for this host.',
    );
    exitCode = 1;
    return;
  }
  // Check the build before installing it anywhere the loader would trust.
  final abiVersion = DynamicLibrary.open(
    built.path,
  ).lookupFunction<Uint32 Function(), int Function()>('ffi_abi_version')();
  if (abiVersion != NativeBridge.expectedAbiVersion) {
    stderr.writeln(
      'Built library reports ABI $abiVersion, but this anytype '
      'expects ABI ${NativeBridge.expectedAbiVersion}.',
    );
    exitCode = 1;
    return;
  }

  final destinations = [
    NativeLibraryLocator.projectLibraryPath(
      libraryName,
      packageConfigPath: packageConfig.toFilePath(),
    ),
    if (outputDir != null) p.join(outputDir, libraryName),
  ];
  for (final destination in destinations) {
    Directory(p.dirname(destination)).createSync(recursive: true);
    final staging = '$destination.tmp';
    built.copySync(staging);
    File(staging).renameSync(destination);
  }
  for (final destination in destinations) {
    stdout.writeln('Built $destination (ABI $abiVersion)');
  }
}
