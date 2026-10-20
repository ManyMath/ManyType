/// Reports which storage backend a web [ManytypeDatabase] ended up using.
///
/// Mirrors the fields of drift's own `WasmDatabaseResult` (see
/// `database_web.dart`) without leaking web-only types into
/// `ManytypeDatabase`'s cross-platform constructor: drift's own docs on
/// `WasmDatabaseResult.chosenImplementation` note that callers "may want to
/// show a warning to the user if persistence is important in your app" when
/// the resolved implementation isn't durable or isn't multi-tab safe, but
/// nothing surfaced that choice to callers of the public constructor before
/// this: the diagnostic was only reachable via the test-only
/// `openWasmDatabaseForApp`.
class WebStorageDiagnostics {
  /// Name of the resolved `WasmStorageImplementation` (e.g. `opfsShared`,
  /// `unsafeIndexedDb`, `inMemory`).
  final String implementationName;

  /// False only for `inMemory`: data does not survive a reload.
  final bool isDurable;

  /// False for `unsafeIndexedDb` and `inMemory`; true for the implementations
  /// drift documents as safe when the app is opened in multiple tabs at once
  /// (`opfsShared`, `opfsLocks`, `sharedIndexedDb`).
  final bool isMultiTabSafe;

  /// Names of browser features that were missing and narrowed the choice of
  /// implementation.
  final List<String> missingFeatures;

  const WebStorageDiagnostics({
    required this.implementationName,
    required this.isDurable,
    required this.isMultiTabSafe,
    required this.missingFeatures,
  });

  @override
  String toString() => 'WebStorageDiagnostics($implementationName, '
      'durable: $isDurable, multiTabSafe: $isMultiTabSafe, '
      'missingFeatures: $missingFeatures)';
}

/// Invoked with [WebStorageDiagnostics] once a web [ManytypeDatabase] has
/// resolved its storage backend. Ignored on native, where storage is always
/// a real file on disk.
typedef WebStorageDiagnosticsCallback = void Function(
    WebStorageDiagnostics diagnostics);
