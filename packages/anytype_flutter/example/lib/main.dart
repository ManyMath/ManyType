import 'dart:io';

import 'package:anytype_flutter/anytype_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

/// Loads the bundled QUIC bridge, then creates a local account and objects
/// in a temporary storage root. The recovery phrase is never shown.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AnytypeExampleApp());
}

class AnytypeExampleApp extends StatefulWidget {
  const AnytypeExampleApp({super.key});

  @override
  State<AnytypeExampleApp> createState() => _AnytypeExampleAppState();
}

class _AnytypeExampleAppState extends State<AnytypeExampleApp> {
  String _bridge = 'loading';
  final List<String> _objects = [];
  ManytypeSession? _session;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    String bridge;
    try {
      bridge = 'QUIC bridge ABI ${AnytypeFlutter.ensureInitialized()}';
    } catch (error) {
      bridge = 'QUIC bridge unavailable: $error';
    }
    final root = await Directory.systemTemp.createTemp('anytype_example_');
    ManytypeStorage.directory = p.join(root.path, 'store');
    await createAccountCommand(name: 'Example');
    final session = await ManytypeSession.open();
    if (!mounted) {
      await session.close();
      return;
    }
    setState(() {
      _bridge = bridge;
      _session = session;
    });
  }

  Future<void> _addNote() async {
    final session = _session;
    if (session == null) return;
    await session.objects.create('Note ${_objects.length + 1}');
    final objects = await session.objects.list();
    setState(() {
      _objects
        ..clear()
        ..addAll(objects.map((object) => object.name ?? object.id));
    });
  }

  @override
  void dispose() {
    _session?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('anytype_flutter')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(_bridge),
            const SizedBox(height: 16),
            for (final name in _objects) Text(name),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _session == null ? null : _addNote,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
