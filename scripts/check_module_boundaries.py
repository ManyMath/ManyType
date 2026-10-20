#!/usr/bin/env python3
"""Check the production package graph and its public consumer imports."""
from pathlib import Path
import subprocess
import tomllib

ROOT = Path(__file__).resolve().parents[1]
for directory in ['apps/ManyType', 'packages/manytype_cli']:
    for source in (ROOT / directory).rglob('*.dart'):
        text = source.read_text()
        if 'package:manytype_client/src/' in text:
            raise SystemExit(f'Private client import in consumer: {source}')
        if directory.startswith('apps/') and 'package:manytype_cli/' in text:
            raise SystemExit(f'App still depends on CLI: {source}')
for source in (ROOT / 'packages/manytype_client/lib').rglob('*.dart'):
    if 'package:manytype_cli/' in source.read_text():
        raise SystemExit(f'Client depends on CLI: {source}')
tree = subprocess.check_output(['cargo', 'tree', '--locked', '--manifest-path',
    str(ROOT / 'rust/Cargo.toml'), '-p', 'manytype_quic_ffi', '--edges', 'normal'], text=True)
if 'manytype_server ' in tree or 'redb ' in tree:
    raise SystemExit('Client FFI links server implementation or server database')
manifest = tomllib.loads((ROOT / 'rust/manytype_quic_ffi/Cargo.toml').read_text())
assert 'manytype_transport' in manifest['dependencies']
print('Public client imports and server-free production FFI graph verified.')
