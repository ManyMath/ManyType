#!/usr/bin/env python3
"""Verify the vendored cargokit tree against its recorded provenance.

Needs no checkout of the private cargokit fork: every tracked file under
packages/anytype_flutter/cargokit must appear in VENDOR_PROVENANCE.json with
a matching SHA-256 (and nothing recorded may be missing) and the file mode the
recipe records, the recipe's patch files must match their recorded hashes, and
the provenance must name the committed recipe, tool/cargokit/manifest.json.
A full rebuild from the fork remains `tool/cargokit_sync.py --check`.
"""
from pathlib import Path
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[1]
TREE = 'packages/anytype_flutter/cargokit'
PROVENANCE = 'VENDOR_PROVENANCE.json'


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


provenance = json.loads((ROOT / TREE / PROVENANCE).read_text())
recipe = json.loads((ROOT / 'tool/cargokit/manifest.json').read_text())
expected = provenance['installed_files_sha256']
modes = {}
for line in subprocess.check_output(['git', 'ls-files', '-s', TREE], cwd=ROOT, text=True).splitlines():
    meta, name = line.split('\t', 1)
    modes[name[len(TREE) + 1:]] = meta.split()[0]
tracked = set(modes) - {PROVENANCE}
problems = [f'untracked by provenance: {name}' for name in sorted(tracked - set(expected))]
problems += [f'missing: {name}' for name in sorted(set(expected) - tracked)]
problems += [f'modified: {name}' for name in sorted(tracked & set(expected))
             if not (ROOT / TREE / name).is_file()
             or sha256(ROOT / TREE / name) != expected[name]]
problems += [f'mode {modes[name]} instead of {recipe["files"][name]["mode"]}: {name}'
             for name in sorted(tracked & set(recipe['files']))
             if modes[name] != recipe['files'][name]['mode']]
problems += [f'patch differs: {patch["file"]}' for patch in recipe['patches']
             if sha256(ROOT / 'tool/cargokit' / patch['file']) != patch['sha256']]
if sha256(ROOT / 'tool/cargokit/manifest.json') != provenance['recipe_sha256']:
    problems.append('tool/cargokit/manifest.json does not match the recorded recipe')
if problems:
    raise SystemExit('Vendored cargokit differs from its provenance:\n  ' + '\n  '.join(problems))
print(f'Vendored cargokit matches its provenance ({len(expected)} files, '
      f'revision {provenance["revision"][:12]}, {len(provenance["patches"])} patches).')
