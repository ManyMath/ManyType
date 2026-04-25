// `--file-relation <path>` reads from the local filesystem, a dart:io
// feature with no browser equivalent. Web callers have no filesystem to
// point a path at: use editCommand's fileRelationBytes/fileRelationFileName
// form instead (see M016, docs/m016-web-api-surface.md).
import 'dart:typed_data';

Future<Uint8List> readFileRelationSourceBytes(String path) {
  throw UnsupportedError(
    'fileRelationPath is vm-only; pass fileRelationBytes on web',
  );
}
