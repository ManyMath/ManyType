#!/usr/bin/env python3
"""Check the production package graph and its public consumer imports."""
from pathlib import Path
import re
import subprocess
import tomllib

ROOT = Path(__file__).resolve().parents[1]
for directory in ['apps/ManyType', 'packages/manytype_cli']:
    for source in (ROOT / directory).rglob('*.dart'):
        text = source.read_text()
        if 'package:anytype/src/' in text:
            raise SystemExit(f'Private client import in consumer: {source}')
        if directory.startswith('apps/') and 'package:manytype_cli/' in text:
            raise SystemExit(f'App still depends on CLI: {source}')
for source in (ROOT / 'packages/anytype/lib').rglob('*.dart'):
    if 'package:manytype_cli/' in source.read_text():
        raise SystemExit(f'Client depends on CLI: {source}')
SDK_PACKAGES = ['anytype', 'manytype_core', 'manytype_protocol']
for package in SDK_PACKAGES:
    pubspec = (ROOT / 'packages' / package / 'pubspec.yaml').read_text()
    if re.search(r'^    (path|git|sdk):', pubspec, re.M) or 'publish_to:' in pubspec:
        raise SystemExit(f'SDK package {package} is not publishable with hosted dependencies')
    for forbidden in ['flutter', 'manyui', 'manytype_cli', 'manytype_server']:
        if re.search(rf'^\s+{forbidden}[a-z_]*:', pubspec, re.M):
            raise SystemExit(f'SDK package {package} depends on {forbidden}')
    for source in (ROOT / 'packages' / package).rglob('*.dart'):
        if re.search(r"package:(flutter|manyui[a-z_]*|manytype_cli)/", source.read_text()):
            raise SystemExit(f'SDK source imports an application package: {source}')
PLUGIN = ROOT / 'packages/anytype_flutter'
pubspec = (PLUGIN / 'pubspec.yaml').read_text()
if re.search(r'^    (path|git):', pubspec, re.M) or 'publish_to:' in pubspec:
    raise SystemExit('anytype_flutter is not publishable with hosted dependencies')
if not re.search(r'^  anytype: \^', pubspec, re.M):
    raise SystemExit('anytype_flutter must depend on hosted anytype')
for forbidden in ['manyui', 'manytype_cli', 'manytype_server']:
    if re.search(rf'^\s+{forbidden}[a-z_]*:', pubspec, re.M):
        raise SystemExit(f'anytype_flutter depends on {forbidden}')
for source in (PLUGIN / 'lib').rglob('*.dart'):
    if re.search(r"package:(manyui[a-z_]*|manytype_cli)/", source.read_text()):
        raise SystemExit(f'Plugin source imports an application package: {source}')

PLUGIN_RUST = PLUGIN / 'rust/Cargo.toml'
tree = subprocess.check_output(['cargo', 'tree', '--locked', '--manifest-path',
    str(PLUGIN_RUST), '-p', 'manytype_quic_ffi', '--edges', 'normal'], text=True)
if 'manytype_server ' in tree or 'redb ' in tree:
    raise SystemExit('Client FFI links server implementation or server database')
manifest = tomllib.loads(PLUGIN_RUST.read_text())
assert 'manytype_transport' in manifest['dependencies']
if 'manytype_server' in manifest.get('dev-dependencies', {}):
    raise SystemExit('The plugin crate cannot reference the repository server')


def locked(path):
    return {(pkg['name'], pkg['version']): pkg.get('checksum')
            for pkg in tomllib.loads(path.read_text())['package']}


server_lock = locked(ROOT / 'rust/Cargo.lock')
drifted = sorted(key for key, checksum in locked(PLUGIN / 'rust/Cargo.lock').items()
                 if server_lock.get(key, '?') != checksum)
if drifted:
    raise SystemExit(f'Plugin and server lockfiles disagree: {drifted}')
print('Public client imports, publishable SDK and plugin graphs, server-free '
      'production FFI graph and matching lockfiles verified.')
