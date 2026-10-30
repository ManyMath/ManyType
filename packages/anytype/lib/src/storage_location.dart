/// Native storage root shared by the account registry and legacy config.
///
/// Defaults to `.manytype` under `HOME` (or `USERPROFILE` on Windows). Set
/// [directory] before resolving accounts or opening sessions to keep SDK
/// data elsewhere, such as an application support directory or a temporary
/// directory in tests. Changing it while sessions are open does not move
/// their databases.
///
/// Web builds keep account data in OPFS/IndexedDB keyed by account ID and
/// ignore this setting.
abstract final class ManytypeStorage {
  static String? directory;
}
