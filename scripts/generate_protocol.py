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
RUST = ROOT / 'packages/anytype_flutter/rust/crates/manytype_proto/src/generated'


def output(args):
    return subprocess.check_output(args, cwd=ROOT, text=True).strip()


def protocol_include(protoc, environ=None):
    env = os.environ if environ is None else environ
    explicit = env.get('PROTOC_INCLUDE')
    candidates = ([Path(explicit)] if explicit else
                  [Path(protoc).resolve().parent.parent / 'include', Path('/usr/include')])
    for candidate in candidates:
        if (candidate / 'google/protobuf/struct.proto').is_file():
            return candidate.resolve()
    raise RuntimeError('Provision matching protobuf includes and set PROTOC_INCLUDE '
                       '(google/protobuf/struct.proto is required); no installer fallback')


def pinned_rustfmt():
    # `rustup run ... rustfmt` can fall back to PATH if the component is absent.
    # Resolve the actual pinned component and fail instead of using another SDK.
    path = Path(output(['rustup', 'which', '--toolchain', '1.94.0', 'rustfmt']))
    if not path.is_absolute() or not path.is_file():
        raise RuntimeError('Provision the Rust 1.94.0 rustfmt component; no PATH fallback')
    return path


def generator_environment(rustfmt, environ=None):
    env = dict(os.environ if environ is None else environ)
    env['PATH'] = str(rustfmt.parent) + os.pathsep + env.get('PATH', '')
    env['RUSTFMT'] = str(rustfmt)
    env['RUSTUP_TOOLCHAIN'] = '1.94.0'
    return env


def dart_plugin(os_name=None):
    name = 'protoc-gen-dart.bat' if (os_name or os.name) == 'nt' else 'protoc-gen-dart'
    return ROOT / 'scripts' / name


def canonical_newlines(root):
    # Only fresh generator output is normalized. Checked-in bytes remain the
    # comparison authority, protected from checkout conversion by attributes.
    for path in root.rglob('*'):
        if path.is_file() and path.suffix in {'.dart', '.rs'}:
            path.write_bytes(path.read_bytes().replace(b'\r\n', b'\n'))


def patch_rust(path):
    # prost 0.5.0 generates colliding message/oneof names from upstream schemas.
    # Preserve our existing public Rust names; fail if schema/tool output changes.
    source = path.read_text(encoding='utf-8')
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
    path.write_bytes(source.encode('utf-8'))


def generated_files(root):
    return {p.relative_to(root): p.read_bytes() for p in root.rglob('*')
            if p.is_file() and p.suffix in {'.dart', '.rs'}}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    if not output(['dart', '--version']).startswith('Dart SDK version: 3.13.2 '):
        raise RuntimeError('Provision Dart 3.13.2 for reproducible protocol generation')
    protoc = shutil.which(os.environ.get('PROTOC', 'protoc'))
    prost = shutil.which(os.environ.get('PROTOC_GEN_PROST', 'protoc-gen-prost'))
    if not protoc or output([protoc, '--version']) != 'libprotoc 3.21.12':
        raise RuntimeError('Provision protoc 3.21.12; generation does not install shared tools')
    if not prost or output([prost, '--version']) != '0.5.0':
        raise RuntimeError('Provision protoc-gen-prost 0.5.0 (PROTOC_GEN_PROST may be absolute)')
    include = protocol_include(protoc)
    rustfmt = pinned_rustfmt()
    env = generator_environment(rustfmt)
    print('Protobuf includes:', include)
    print('Pinned formatter:', rustfmt, output([str(rustfmt), '--version']))
    subprocess.run(['dart', 'pub', 'get', '--enforce-lockfile', '--directory',
                    str(ROOT / 'tool/protocol_codegen')], cwd=ROOT, check=True)
    with tempfile.TemporaryDirectory(prefix='manytype-protocol-') as tmp:
        tmp = Path(tmp)
        dart, rust = tmp / 'dart', tmp / 'rust'
        dart.mkdir(); rust.mkdir()
        schemas = sorted(p.relative_to(ROOT).as_posix() for p in (ROOT / 'proto').rglob('*.proto'))
        subprocess.run([protoc, '-I', 'proto', '-I', str(include),
                        f'--plugin=protoc-gen-prost={prost}',
                        f'--plugin=protoc-gen-dart={dart_plugin()}',
                        f'--dart_out={dart}', f'--prost_out={rust}', *schemas], cwd=ROOT, env=env, check=True)
        patch_rust(rust / 'anytype/model/anytype.model.rs')
        subprocess.run([str(rustfmt), '--edition', '2021', '--config', 'newline_style=Unix',
                        *map(str, sorted(rust.rglob('*.rs')))], env=env, check=True)
        canonical_newlines(dart)
        canonical_newlines(rust)
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
