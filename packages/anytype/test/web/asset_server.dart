import 'dart:io';

import 'package:stream_channel/stream_channel.dart';

Future<void> hybridMain(StreamChannel<Object?> channel) async {
  final assetsDir = Directory('test/web_assets');
  if (!await assetsDir.exists()) {
    throw StateError(
        'test/web_assets/ not found: run tool/fetch_web_test_assets.dart first');
  }

  final server = await HttpServer.bind('localhost', 0);
  server.listen((request) async {
    final path = request.uri.path.replaceFirst('/', '');
    final file = File('${assetsDir.path}/$path');

    request.response.headers.set('Access-Control-Allow-Origin', '*');
    if (request.method == 'OPTIONS') {
      request.response.statusCode = 200;
      await request.response.close();
      return;
    }

    if (!await file.exists()) {
      request.response.statusCode = 404;
      await request.response.close();
      return;
    }

    final contentType = path.endsWith('.wasm')
        ? 'application/wasm'
        : path.endsWith('.js')
            ? 'application/javascript'
            : 'application/octet-stream';

    request.response.headers.set('Content-Type', contentType);
    request.response.statusCode = 200;
    await request.response.addStream(file.openRead());
    await request.response.close();
  });

  channel.sink.add(server.port);
  await channel.stream
      .listen(null)
      .asFuture<void>()
      .then<void>((_) => server.close());
}
