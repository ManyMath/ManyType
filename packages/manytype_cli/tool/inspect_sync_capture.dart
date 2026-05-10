import 'dart:convert';
import 'dart:io';

import 'package:manytype_protocol/manytype_protocol.dart';
import 'package:manytype_protocol/spacesync.dart';

void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln(
      'Usage: dart run packages/manytype_cli/tool/inspect_sync_capture.dart '
      '<capture.json> <match-id> [match-id...]',
    );
    exit(64);
  }

  final capturePath = args[0];
  final matchIds = args.skip(1).toSet();
  final file = File(capturePath);
  if (!file.existsSync()) {
    stderr.writeln('Capture file not found: $capturePath');
    exit(66);
  }

  final capture = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final events = (capture['events'] as List<dynamic>? ?? const [])
      .cast<Map<String, dynamic>>();

  var matched = 0;
  for (final event in events) {
    if (event['type'] != 'stream_rpc' ||
        event['method'] != '/spacesync.SpaceSync/ObjectSyncStream') {
      continue;
    }

    final requestMessages =
        (event['request_messages'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>();
    final responseMessages =
        (event['response_messages'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>();

    final decodedRequests = _decodeRequestMessages(requestMessages, matchIds);
    final decodedResponses =
        _decodeResponseMessages(responseMessages, matchIds);
    if (decodedRequests.isEmpty && decodedResponses.isEmpty) {
      continue;
    }

    matched++;
    stdout.writeln('=== stream event $matched ===');
    stdout.writeln('role: ${event['role']}');

    if (decodedRequests.isNotEmpty) {
      stdout.writeln('-- requests --');
      for (final line in decodedRequests) {
        stdout.writeln(line);
      }
    }

    if (decodedResponses.isNotEmpty) {
      stdout.writeln('-- responses --');
      for (final line in decodedResponses) {
        stdout.writeln(line);
      }
    }
  }

  if (matched == 0) {
    stdout
        .writeln('No ObjectSyncStream messages matched: ${matchIds.join(",")}');
  }
}

List<String> _decodeRequestMessages(
  List<Map<String, dynamic>> messages,
  Set<String> matchIds,
) {
  final decoded = <String>[];
  for (var i = 0; i < messages.length; i++) {
    final base64 = messages[i]['base64'] as String?;
    if (base64 == null || base64.isEmpty) {
      continue;
    }

    try {
      final tree = TreeSyncMessage.fromBuffer(base64Decode(base64));
      final summary = _summarizeTree(tree);
      if (!_matches(matchIds, summary.matchIds)) {
        continue;
      }
      decoded.add('message ${i + 1}: request');
      decoded.addAll(summary.lines);
    } catch (error) {
      decoded.add('message ${i + 1}: decode error: $error');
    }
  }
  return decoded;
}

List<String> _decodeResponseMessages(
  List<Map<String, dynamic>> messages,
  Set<String> matchIds,
) {
  final decoded = <String>[];
  for (var i = 0; i < messages.length; i++) {
    final base64 = messages[i]['base64'] as String?;
    if (base64 == null || base64.isEmpty) {
      continue;
    }

    try {
      final outer = ObjectSyncMessage.fromBuffer(base64Decode(base64));
      final tree = outer.payload.isEmpty
          ? null
          : TreeSyncMessage.fromBuffer(outer.payload);
      final summary = tree == null ? null : _summarizeTree(tree);
      final outerIds = {
        outer.spaceId,
        outer.objectId,
        outer.requestId,
        outer.replyId,
      }..removeWhere((id) => id.isEmpty);
      final combinedIds = {
        ...outerIds,
        ...?summary?.matchIds,
      };
      if (!_matches(matchIds, combinedIds)) {
        continue;
      }
      decoded.add(
        'message ${i + 1}: response '
        'space=${outer.spaceId} object=${outer.objectId} '
        'requestId=${outer.requestId} replyId=${outer.replyId} '
        'payloadLen=${outer.payload.length}',
      );
      if (summary != null) {
        decoded.addAll(summary.lines);
      }
    } catch (error) {
      decoded.add('message ${i + 1}: decode error: $error');
    }
  }
  return decoded;
}

bool _matches(Set<String> wanted, Set<String> actual) =>
    wanted.any(actual.contains);

({List<String> lines, Set<String> matchIds}) _summarizeTree(
    TreeSyncMessage tree) {
  final lines = <String>[];
  final matchIds = <String>{};
  if (tree.hasRootChange()) {
    lines.add('  rootChange=${tree.rootChange.id}');
    matchIds.add(tree.rootChange.id);
    matchIds.addAll(_decodeEmbeddedIds(tree.rootChange));
  }
  if (!tree.hasContent()) {
    return (lines: lines, matchIds: matchIds);
  }

  final content = tree.content;
  if (content.hasHeadUpdate()) {
    final headUpdate = content.headUpdate;
    lines.add('  kind=headUpdate');
    lines.add('  heads=${headUpdate.heads.join(",")}');
    lines.add('  snapshotPath=${headUpdate.snapshotPath.join(",")}');
    lines.add(
      '  changes=${headUpdate.changes.map((change) => change.id).join(",")}',
    );
    matchIds.addAll(headUpdate.heads);
    matchIds.addAll(headUpdate.snapshotPath);
    for (final change in headUpdate.changes) {
      matchIds.add(change.id);
      matchIds.addAll(_decodeEmbeddedIds(change));
      lines.add('    - ${_describeEmbeddedChange(change)}');
    }
  } else if (content.hasFullSyncRequest()) {
    final request = content.fullSyncRequest;
    lines.add('  kind=fullSyncRequest');
    lines.add('  heads=${request.heads.join(",")}');
    lines.add(
      '  changes=${request.changes.map((change) => change.id).join(",")}',
    );
    matchIds.addAll(request.heads);
    for (final change in request.changes) {
      matchIds.add(change.id);
      matchIds.addAll(_decodeEmbeddedIds(change));
      lines.add('    - ${_describeEmbeddedChange(change)}');
    }
  } else if (content.hasFullSyncResponse()) {
    final response = content.fullSyncResponse;
    lines.add('  kind=fullSyncResponse');
    lines.add('  heads=${response.heads.join(",")}');
    lines.add('  snapshotPath=${response.snapshotPath.join(",")}');
    lines.add(
      '  changes=${response.changes.map((change) => change.id).join(",")}',
    );
    matchIds.addAll(response.heads);
    matchIds.addAll(response.snapshotPath);
    for (final change in response.changes) {
      matchIds.add(change.id);
      matchIds.addAll(_decodeEmbeddedIds(change));
      lines.add('    - ${_describeEmbeddedChange(change)}');
    }
  } else if (content.hasErrorResponse()) {
    final error = content.errorResponse;
    lines.add(
      '  kind=errorResponse code=${error.errCode} error=${error.error}',
    );
  } else {
    lines.add('  kind=other');
  }

  return (lines: lines, matchIds: matchIds);
}

Set<String> _decodeEmbeddedIds(RawTreeChangeWithId wrapped) {
  final ids = <String>{};
  try {
    final raw = RawTreeChange.fromBuffer(wrapped.rawChange);
    if (raw.payload.isEmpty) {
      return ids;
    }
    try {
      final root = RootChange.fromBuffer(raw.payload);
      if (root.spaceId.isNotEmpty) {
        ids.add(root.spaceId);
      }
      if (root.aclHeadId.isNotEmpty) {
        ids.add(root.aclHeadId);
      }
      return ids;
    } catch (_) {
      // Fall through and try TreeChange.
    }
    final tree = TreeChange.fromBuffer(raw.payload);
    if (tree.aclHeadId.isNotEmpty) {
      ids.add(tree.aclHeadId);
    }
    if (tree.snapshotBaseId.isNotEmpty) {
      ids.add(tree.snapshotBaseId);
    }
    ids.addAll(tree.treeHeadIds.where((id) => id.isNotEmpty));
  } catch (_) {
    return ids;
  }
  return ids;
}

String _describeEmbeddedChange(RawTreeChangeWithId wrapped) {
  try {
    final raw = RawTreeChange.fromBuffer(wrapped.rawChange);
    if (raw.payload.isEmpty) {
      return '${wrapped.id} raw(payload=empty)';
    }
    try {
      final root = RootChange.fromBuffer(raw.payload);
      return '${wrapped.id} root(space=${root.spaceId}, acl=${root.aclHeadId}, '
          'type=${root.changeType}, derived=${root.isDerived})';
    } catch (_) {
      // Fall through and try TreeChange.
    }
    final tree = TreeChange.fromBuffer(raw.payload);
    return '${wrapped.id} tree(parents=${tree.treeHeadIds.join(",")}, '
        'snapshotBase=${tree.snapshotBaseId}, acl=${tree.aclHeadId}, '
        'isSnapshot=${tree.isSnapshot}, readKey=${tree.readKeyId})';
  } catch (error) {
    return '${wrapped.id} decode-error($error)';
  }
}
