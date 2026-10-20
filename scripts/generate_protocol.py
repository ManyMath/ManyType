#!/usr/bin/env python3
"""Reproduce wire types with pinned tools; --check compares a temporary tree."""
import argparse
import os
import re
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
DART = ROOT / 'packages/manytype_protocol/lib/src/generated'
RUST = ROOT / 'rust/manytype_proto/src/generated'


def output(args):
    return subprocess.check_output(args, cwd=ROOT, text=True).strip()


def patch_rust(path):
    # prost 0.5.0 generates colliding message/oneof names from upstream schemas.
    # Preserve our existing public Rust names; fail if schema/tool output changes.
    source = path.read_text()
    replacements = {
        r'\bblock::Content\b': ('block::ContentOneOf', 2),
        r'^    pub enum Content \{': ('    pub enum ContentOneOf {', 1),
        r'\bmetadata::Payload\b': ('metadata::PayloadOneOf', 2),
    }
    for old, (new, count) in replacements.items():
        source, actual = re.subn(old, new, source, flags=re.MULTILINE)
        if actual != count:
            raise RuntimeError(f'Expected {count} occurrences of {old}; inspect generator drift')
    start = source.index('pub mod metadata {')
    end = source.index('\n}', start)
    metadata = source[start:end]
    if metadata.count('pub enum Payload {') != 1:
        raise RuntimeError('Expected metadata::Payload oneof declaration')
    source = source[:start] + metadata.replace('pub enum Payload {', 'pub enum PayloadOneOf {') + source[end:]
    path.write_text(source)


def generated_files(root):
    return {p.relative_to(root): p.read_bytes() for p in root.rglob('*')
            if p.is_file() and p.suffix in {'.dart', '.rs'}}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    if not output(['dart', '--version']).startswith('Dart SDK version: 3.13.2 '):
        raise RuntimeError('Provision Dart 3.13.2 for reproducible protocol generation')
    protoc = os.environ.get('PROTOC', 'protoc')
    prost = shutil.which(os.environ.get('PROTOC_GEN_PROST', 'protoc-gen-prost'))
    if output([protoc, '--version']) != 'libprotoc 3.21.12':
        raise RuntimeError('Provision protoc 3.21.12; generation does not install shared tools')
    if not prost or output([prost, '--version']) != '0.5.0':
        raise RuntimeError('Provision protoc-gen-prost 0.5.0 (PROTOC_GEN_PROST may be absolute)')
    rustfmt = ['rustup', 'run', '1.94.0', 'rustfmt']
    subprocess.run(['dart', 'pub', 'get', '--enforce-lockfile', '--directory',
                    str(ROOT / 'tool/protocol_codegen')], cwd=ROOT, check=True)
    with tempfile.TemporaryDirectory(prefix='manytype-protocol-') as tmp:
        tmp = Path(tmp)
        dart, rust = tmp / 'dart', tmp / 'rust'
        dart.mkdir(); rust.mkdir()
        schemas = sorted(str(p.relative_to(ROOT)) for p in (ROOT / 'proto').rglob('*.proto'))
        subprocess.run([protoc, '-I', 'proto', '-I', '/usr/include',
                        f'--plugin=protoc-gen-prost={prost}',
                        f'--plugin=protoc-gen-dart={ROOT / "scripts/protoc-gen-dart"}',
                        f'--dart_out={dart}', f'--prost_out={rust}', *schemas], cwd=ROOT, check=True)
        patch_rust(rust / 'anytype/model/anytype.model.rs')
        subprocess.run([*rustfmt, '--edition', '2021', *map(str, sorted(rust.rglob('*.rs')))], check=True)
        drift = []
        for generated, checked_in in [(dart, DART), (rust, RUST)]:
            fresh, existing = generated_files(generated), generated_files(checked_in)
            if args.check:
                drift.extend(str(checked_in / p) for p in sorted(fresh.keys() | existing.keys())
                             if fresh.get(p) != existing.get(p))
            else:
                for p in existing.keys() - fresh.keys():
                    (checked_in / p).unlink()
                shutil.copytree(generated, checked_in, dirs_exist_ok=True)
        if drift:
            raise SystemExit('Protocol generation drift:\n' + '\n'.join(drift))
    print('Protocol generated sources match pinned tools.' if args.check else 'Protocol sources regenerated.')


if __name__ == '__main__':
    main()
