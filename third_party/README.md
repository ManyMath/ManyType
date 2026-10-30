# Protocol source provenance and licenses

`proto/PROVENANCE.json` records exact local hashes, immutable upstream comparison
URLs, upstream hashes, and whether each checked-in schema is byte-identical.
Local schema edits are retained; this work does not replace the maintained
protocol with a fresh upstream version. Original `proto/VERSION` and schema
headers remain historical lineage evidence.

- Any-Sync v0.9.9, commit `3fde2219e9e698dbb144941331a29073726a499a`: MIT,
  Copyright 2023 Any Association. Exact license SHA256:
  `9a373cbe9a10c23caaf3237903a19ce65beedcc3e557c939def57db627f528f8`.
- Anytype-heart explicit commit `cfb7ec902abbce2db714de9be3832a1cb0691d8c`:
  Any Source Available License 1.0. Exact license SHA256:
  `daad9eb95adc6262b07115ba2cf87cd4c64acaca4b45d48e0fd3b15a72a31dc1`.
  The old VERSION file also cites v0.48.5, a different revision. No assertion of
  equivalence is made. Both revisions' root license is ASAL 1.0; the inspected
  upstream trees have no more-specific schema-directory license.

Exact upstream notices are copied into `proto/licenses`,
`packages/manytype_protocol/licenses`, and `rust/manytype_proto/licenses` so the
schemas and generated source packages carry their notices. Generated protocol
types must not be labeled wholly MIT or Apache merely because a first-party
license is chosen. ASAL includes non-commercial/Allowed Networks conditions;
public distribution and intended network use need owner review before release.

## First-party licensing

On 2026-10-29 the owner chose the MIT License for the first-party code of the
SDK candidate: the Dart packages `anytype`, `manytype_core` and
`manytype_protocol`, and the Rust crates `manytype_quic_ffi`,
`manytype_transport`, `manytype_core` and `manytype_proto`. Each of those
directories has its own LICENSE. The protocol packages' LICENSE files keep the
upstream terms above for generated code and do not relabel it MIT.

That decision covers only those packages. The app, CLI, server, site, Docker
material and repository tooling still have no explicit license grant. Docker
and font assets retain their existing separate notices.

Software built on the SDK necessarily includes the ASAL-derived block model
types. Public distribution and the intended commercial or network use remain
subject to ASAL's Non-Commercial Use and Allowed Networks conditions.
