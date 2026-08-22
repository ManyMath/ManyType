// Verifies which WasmStorageImplementation a *real* same-origin web
// deployment of manytype_cli resolves to.
//
// `dart test -p chrome` cannot answer this: it has no origin root to serve
// `drift_worker.dart.js` from same-origin as the test page, so
// WasmDatabase.open always falls back to WasmStorageImplementation.inMemory
// under that harness (see database_web.dart, app_persistence_test.dart).
// This script instead compiles tool/web_probe/probe.dart the way a real app
// build would, serves the whole bundle (probe JS, sqlite3.wasm,
// drift_worker.dart.js) same-origin with the COOP/COEP headers OPFS's full
// implementations require, and drives a real headless Chrome against it via
// the DevTools protocol: the one thing `dart test -p chrome` structurally
// can't do.
//
// (`--dump-dom`/`--virtual-time-budget` was tried first and doesn't work
// here: virtual time doesn't advance the dedicated Worker drift's storage
// backend runs in, so the probe's async chain never completes before the
// dump fires. Polling real DOM state over CDP avoids that.)
//
// Usage: dart run tool/verify_opfs_same_origin.dart
// Requires: test/web_assets/ populated (tool/fetch_web_test_assets.dart) and
// a Chrome/Chromium binary (override with CHROME_EXECUTABLE env var).
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final assetsDir = Directory('test/web_assets');
  if (!await assetsDir.exists()) {
    stderr.writeln(
        'test/web_assets/ not found: run tool/fetch_web_test_assets.dart first');
    exit(1);
  }

  final buildDir =
      await Directory.systemTemp.createTemp('manytype-opfs-probe-');
  final userDataDir =
      await Directory.systemTemp.createTemp('manytype-opfs-chrome-');
  HttpServer? server;
  Process? chrome;
  try {
    stdout.writeln('Compiling probe to JS...');
    final compile = await Process.run('dart', [
      'compile',
      'js',
      'tool/web_probe/probe.dart',
      '-o',
      '${buildDir.path}/probe.dart.js',
    ]);
    if (compile.exitCode != 0) {
      stderr.writeln(compile.stdout);
      stderr.writeln(compile.stderr);
      stderr.writeln('dart compile js failed');
      exit(1);
    }

    await File('tool/web_probe/index.html').copy('${buildDir.path}/index.html');
    await File('${assetsDir.path}/sqlite3.wasm')
        .copy('${buildDir.path}/sqlite3.wasm');
    await File('${assetsDir.path}/drift_worker.dart.js')
        .copy('${buildDir.path}/drift_worker.dart.js');

    server = await HttpServer.bind('localhost', 0);
    stdout.writeln('Serving probe bundle at http://localhost:${server.port}');
    server.listen((request) async {
      final path = request.uri.path == '/' ? '/index.html' : request.uri.path;
      final file = File('${buildDir.path}$path');
      // Cross-origin isolation is required for OPFS's full-featured
      // implementations (opfsShared/opfsLocks use SharedArrayBuffer); a
      // real deployment that wants durable OPFS storage must set these too.
      request.response.headers.set('Cross-Origin-Opener-Policy', 'same-origin');
      request.response.headers
          .set('Cross-Origin-Embedder-Policy', 'require-corp');
      if (!await file.exists()) {
        request.response.statusCode = 404;
        await request.response.close();
        return;
      }
      final contentType = path.endsWith('.wasm')
          ? 'application/wasm'
          : path.endsWith('.js')
              ? 'application/javascript'
              : path.endsWith('.html')
                  ? 'text/html'
                  : 'application/octet-stream';
      request.response.headers.set('Content-Type', contentType);
      await request.response.addStream(file.openRead());
      await request.response.close();
    });

    final chromeExecutable =
        Platform.environment['CHROME_EXECUTABLE'] ?? 'google-chrome';
    final cdpPort = await _findFreePort();
    stdout.writeln('Launching headless Chrome (CDP on $cdpPort)...');
    chrome = await Process.start(chromeExecutable, [
      '--headless=new',
      '--disable-gpu',
      '--no-sandbox',
      '--user-data-dir=${userDataDir.path}',
      '--remote-debugging-port=$cdpPort',
      'about:blank',
    ]);
    chrome.stdout.drain<void>();
    chrome.stderr.drain<void>();

    await _waitForCdp(cdpPort);

    final targetUrl = 'http://localhost:${server.port}/index.html';
    final newTarget = await HttpClient()
        .putUrl(Uri.parse('http://localhost:$cdpPort/json/new?$targetUrl'))
        .then((r) => r.close())
        .then((r) => r.transform(utf8.decoder).join());
    final target = jsonDecode(newTarget) as Map<String, Object?>;
    final wsUrl = target['webSocketDebuggerUrl'] as String;

    final ws = await WebSocket.connect(wsUrl);
    var msgId = 0;
    void send(String method, [Map<String, Object?>? params]) {
      ws.add(jsonEncode({
        'id': ++msgId,
        'method': method,
        if (params != null) 'params': params
      }));
    }

    final replies = <int, Map<String, Object?>>{};
    ws.listen((event) {
      final decoded = jsonDecode(event as String) as Map<String, Object?>;
      final id = decoded['id'];
      if (id is int) replies[id] = decoded;
    });

    send('Runtime.enable');

    Map<String, Object?>? probeResult;
    final deadline = DateTime.now().add(const Duration(seconds: 20));
    while (DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final id = ++msgId;
      ws.add(jsonEncode({
        'id': id,
        'method': 'Runtime.evaluate',
        'params': {
          'expression': "document.getElementById('result')?.textContent ?? ''"
        },
      }));
      final deadlineForReply = DateTime.now().add(const Duration(seconds: 2));
      while (!replies.containsKey(id) &&
          DateTime.now().isBefore(deadlineForReply)) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      final reply = replies.remove(id);
      final value = (reply?['result'] as Map<String, Object?>?)?['result']
          as Map<String, Object?>?;
      final text = value?['value'] as String?;
      if (text != null && text.isNotEmpty) {
        probeResult = jsonDecode(text) as Map<String, Object?>;
        break;
      }
    }
    await ws.close();

    if (probeResult == null) {
      stderr.writeln('Timed out waiting for probe result.');
      exit(1);
    }

    stdout.writeln(
        'Probe result: ${const JsonEncoder.withIndent('  ').convert(probeResult)}');

    if (probeResult['ok'] != true) {
      stderr.writeln('Probe threw: ${probeResult['error']}');
      exit(1);
    }

    final implementation = probeResult['implementationName'];
    final isDurable = probeResult['isDurable'];
    final rowSurvived = probeResult['rowSurvivedReopen'];
    stdout.writeln('chosenImplementation=$implementation '
        'isDurable=$isDurable isMultiTabSafe=${probeResult['isMultiTabSafe']} '
        'rowSurvivedReopen=$rowSurvived '
        'missingFeatures=${probeResult['missingFeatures']}');

    if (isDurable != true || rowSurvived != true) {
      stderr.writeln('FAIL: same-origin deployment did not resolve to a '
          'durable, persisting storage implementation.');
      exit(1);
    }

    final isOpfs =
        implementation == 'opfsShared' || implementation == 'opfsLocks';
    if (!isOpfs) {
      stdout.writeln('WARN: durable and persisted, but did not resolve to OPFS '
          '(got $implementation): headless Chrome may be missing a '
          'feature a real browser has.');
    }

    stdout.writeln('PASS: same-origin deployment resolved to a durable '
        'implementation ($implementation) and persisted across reopen.');
  } finally {
    if (chrome != null) {
      chrome.kill();
      await chrome.exitCode;
    }
    await server?.close(force: true);
    await buildDir.delete(recursive: true);
    await userDataDir.delete(recursive: true);
  }
}

Future<int> _findFreePort() async {
  final socket = await ServerSocket.bind('localhost', 0);
  final port = socket.port;
  await socket.close();
  return port;
}

Future<void> _waitForCdp(int port) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (DateTime.now().isBefore(deadline)) {
    try {
      final client = HttpClient();
      final request =
          await client.getUrl(Uri.parse('http://localhost:$port/json/version'));
      final response = await request.close();
      await response.drain<void>();
      client.close();
      if (response.statusCode == 200) return;
    } catch (_) {
      // Chrome not ready yet.
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  throw StateError('Chrome DevTools endpoint on port $port never came up');
}
