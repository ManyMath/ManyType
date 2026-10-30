// Disposable pub registry for SDK release candidates.
//
//   dart --packages=.dart_tool/package_config.json \
//     scripts/sdk_registry.dart <port-file> <archive.tar.gz>...
//
// Serves the given `dart pub publish --to-archive` outputs through the hosted
// repository API on 127.0.0.1 and forwards every other package lookup to
// pub.dev. With PUB_HOSTED_URL pointed at it, a consumer resolves the
// candidates exactly as it would once they are published, with no path or
// git overrides. The chosen port is written to <port-file>. Stops on SIGINT
// or SIGTERM.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:yaml/yaml.dart';

const _upstream = 'https://pub.dev';

Future<void> main(List<String> arguments) async {
  if (arguments.length < 2) {
    stderr.writeln('usage: sdk_registry.dart <port-file> <archive.tar.gz>...');
    exit(64);
  }
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final base = 'http://127.0.0.1:${server.port}';

  final candidates = <String, Map<String, Object?>>{};
  final archives = <String, Uint8List>{};
  for (final path in arguments.skip(1)) {
    final bytes = File(path).readAsBytesSync();
    final pubspec =
        _toJson(loadYaml(_pubspecFromArchive(bytes))) as Map<String, Object?>;
    final name = pubspec['name'] as String;
    final version = pubspec['version'] as String;
    final fileName = '$name-$version.tar.gz';
    archives[fileName] = bytes;
    final entry = {
      'version': version,
      'pubspec': pubspec,
      'archive_url': '$base/archives/$fileName',
      'archive_sha256': sha256.convert(bytes).toString(),
    };
    final listing = candidates.putIfAbsent(
        name, () => {'name': name, 'versions': <Object?>[]});
    (listing['versions'] as List).add(entry);
    listing['latest'] = entry;
    stdout.writeln('Serving $name $version');
  }

  final client = HttpClient();
  // Signal subscriptions keep the isolate alive, so leave explicitly.
  ProcessSignal.sigint.watch().listen((_) => exit(0));
  if (!Platform.isWindows) {
    ProcessSignal.sigterm.watch().listen((_) => exit(0));
  }
  File(arguments.first).writeAsStringSync('${server.port}');

  await for (final request in server) {
    final segments = request.uri.pathSegments;
    final response = request.response;
    try {
      if (segments.length == 3 &&
          segments[0] == 'api' &&
          segments[1] == 'packages' &&
          candidates.containsKey(segments[2])) {
        response.headers.contentType =
            ContentType('application', 'vnd.pub.v2+json');
        response.write(jsonEncode(candidates[segments[2]]));
      } else if (segments.length == 2 &&
          segments[0] == 'archives' &&
          archives.containsKey(segments[1])) {
        response.headers.contentType =
            ContentType('application', 'octet-stream');
        response.add(archives[segments[1]]!);
      } else if (segments.length >= 2 &&
          segments[0] == 'api' &&
          segments[1] == 'packages') {
        // Third-party packages come from pub.dev; their archive_url values
        // already point there.
        final upstream =
            await client.getUrl(Uri.parse('$_upstream${request.uri}'));
        upstream.headers.set(HttpHeaders.acceptHeader,
            request.headers.value(HttpHeaders.acceptHeader) ?? '*/*');
        final reply = await upstream.close();
        response.statusCode = reply.statusCode;
        response.headers.contentType = reply.headers.contentType;
        await response.addStream(reply);
      } else {
        response.statusCode = HttpStatus.notFound;
      }
    } catch (error) {
      response.statusCode = HttpStatus.badGateway;
      stderr.writeln('${request.uri}: $error');
    }
    await response.close();
  }
}

String _pubspecFromArchive(Uint8List compressed) {
  final tar = Uint8List.fromList(gzip.decode(compressed));
  var offset = 0;
  while (offset + 512 <= tar.length) {
    final header = tar.sublist(offset, offset + 512);
    final name =
        ascii.decode(header.sublist(0, 100).takeWhile((b) => b != 0).toList());
    if (name.isEmpty) break;
    final sizeField =
        ascii.decode(header.sublist(124, 136)).replaceAll('\x00', '').trim();
    final size = int.parse(sizeField.isEmpty ? '0' : sizeField, radix: 8);
    final body = offset + 512;
    if (name == 'pubspec.yaml' || name == './pubspec.yaml') {
      return utf8.decode(tar.sublist(body, body + size));
    }
    offset = body + (size + 511) ~/ 512 * 512;
  }
  throw StateError('archive has no pubspec.yaml');
}

Object? _toJson(Object? yaml) {
  if (yaml is YamlMap) {
    return {
      for (final entry in yaml.entries) '${entry.key}': _toJson(entry.value)
    };
  }
  if (yaml is YamlList) return [for (final value in yaml) _toJson(value)];
  return yaml;
}
