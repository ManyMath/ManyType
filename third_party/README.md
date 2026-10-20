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

At the implementation baseline, first-party ManyType code has no explicit
license grant. All new modules remain private/unpublished pending the owner's
license selection. This notice grants no new rights and does not replace any
upstream terms. Docker and font assets retain their existing separate notices.
