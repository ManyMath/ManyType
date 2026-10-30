#!/usr/bin/env python3
"""Stage the production QUIC bridge sources into the anytype package.

Copies the crates manytype_quic_ffi links in production into
packages/anytype/native as a standalone Cargo workspace, so the published
archive can build the bridge with no sibling paths. Dev-dependencies are
dropped: they pull in manytype_server for loopback tests, which stay in
rust/. The lockfile is pruned from rust/Cargo.lock without changing any
remaining version, then checked with --locked.

The output is ignored by git and included by packages/anytype/.pubignore.
"""
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tomllib

ROOT = Path(__file__).resolve().parents[1]
RUST = ROOT / 'rust'
DEST = ROOT / 'packages/anytype/native'
CRATES = ['manytype_proto', 'manytype_core', 'manytype_transport', 'manytype_quic_ffi']

README = """# manytype_quic_ffi sources

Production sources of the QUIC bridge used by `package:anytype`, staged from
the ManyType repository's `rust/` workspace by `scripts/stage_sdk_native.py`.
Build them for a project with `dart run anytype:build_native`, or directly:

    cargo build --locked --release -p manytype_quic_ffi

Dev-dependencies and integration tests are left in the repository; the
staged crates build the library but do not run its loopback tests.
Each crate carries its LICENSE. First-party code is MIT licensed.
`manytype_proto` also contains code generated from Any-Sync (MIT) and
Anytype-heart (Any Source Available License 1.0) schemas; its LICENSE says
which files, and `manytype_proto/licenses` holds the upstream notices.
"""


def strip_dev_dependencies(manifest: str) -> str:
    return re.sub(r'(?ms)^\[dev-dependencies\]\n.*?(?=^\[|\Z)', '', manifest).rstrip() + '\n'


def lock_packages(path: Path):
    lock = tomllib.loads(path.read_text())
    return {(pkg['name'], pkg['version']): pkg.get('checksum') for pkg in lock['package']}


def main() -> None:
    if DEST.exists():
        shutil.rmtree(DEST)
    DEST.mkdir(parents=True)

    for crate in CRATES:
        source = RUST / crate
        target = DEST / crate
        target.mkdir()
        manifest = strip_dev_dependencies((source / 'Cargo.toml').read_text())
        for dependency in tomllib.loads(manifest).get('dependencies', {}).values():
            if isinstance(dependency, dict) and 'path' in dependency:
                name = Path(dependency['path']).name
                if name not in CRATES:
                    raise SystemExit(f'{crate} depends on unstaged path crate {name}')
        (target / 'Cargo.toml').write_text(manifest)
        shutil.copyfile(source / 'LICENSE', target / 'LICENSE')
        for directory in ['src', 'licenses']:
            if (source / directory).is_dir():
                shutil.copytree(source / directory, target / directory)

    workspace = (RUST / 'Cargo.toml').read_text()
    members = ''.join(f'    "{crate}",\n' for crate in CRATES)
    workspace = re.sub(r'(?ms)^members = \[\n.*?^\]\n', f'members = [\n{members}]\n', workspace)
    (DEST / 'Cargo.toml').write_text(workspace)
    (DEST / 'README.md').write_text(README)

    shutil.copyfile(RUST / 'Cargo.lock', DEST / 'Cargo.lock')
    cargo = ['cargo', 'metadata', '--format-version', '1',
             '--manifest-path', str(DEST / 'Cargo.toml')]
    subprocess.run(cargo, check=True, stdout=subprocess.DEVNULL)
    subprocess.run(cargo + ['--locked'], check=True, stdout=subprocess.DEVNULL)

    full = lock_packages(RUST / 'Cargo.lock')
    staged = lock_packages(DEST / 'Cargo.lock')
    drifted = sorted(key for key, checksum in staged.items() if full.get(key, '?') != checksum)
    if drifted:
        raise SystemExit(f'staged lockfile drifted from rust/Cargo.lock: {drifted}')
    for name in ['manytype_server', 'redb']:
        if any(key[0] == name for key in staged):
            raise SystemExit(f'staged native graph still contains {name}')

    print(f'Staged {len(CRATES)} crates and {len(staged)} locked packages into '
          f'{DEST.relative_to(ROOT)}')


if __name__ == '__main__':
    sys.exit(main())
