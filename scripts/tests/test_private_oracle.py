"""Host-safe regression: a wrong daemon identity stops before any stack mutation."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]


class PrivateOracleSafetyTest(unittest.TestCase):
    def test_wrong_daemon_root_cleans_only_owned_child(self):
        with tempfile.TemporaryDirectory(prefix='oracle-safety-') as tmp:
            tmp = Path(tmp)
            bins = tmp / 'bin'
            bins.mkdir()
            calls, pid = tmp / 'calls.jsonl', tmp / 'daemon.pid'
            scripts = {
                'dockerd-rootless.sh': '#!/bin/sh\necho $$ > "$TEST_DAEMON_PID"\nexec sleep 60\n',
                'docker': '''#!/usr/bin/env python3
import json, os, sys
with open(os.environ['TEST_DOCKER_CALLS'], 'a') as f:
    f.write(json.dumps({'args': sys.argv[1:], 'host': os.environ['DOCKER_HOST'],
                        'context': os.environ.get('DOCKER_CONTEXT')}) + '\\n')
if '--format' in sys.argv:
    print('/unexpected/reused/docker-data')
''',
                'rustup': '#!/bin/sh\nexit 0\n',
                'flutter': '#!/bin/sh\nexit 0\n',
                'dart': '#!/bin/sh\nexit 0\n',
            }
            for name, source in scripts.items():
                p = bins / name
                p.write_text(source)
                p.chmod(0o755)
            env = dict(os.environ, PATH=str(bins) + ':' + os.environ['PATH'],
                       RUNNER_TEMP=str(tmp), PRIMARY_SERVER='https://git.manymath.com',
                       DOCKER_HOST='unix:///unrelated/docker.sock', DOCKER_CONTEXT='unrelated',
                       TEST_DOCKER_CALLS=str(calls), TEST_DAEMON_PID=str(pid))
            result = subprocess.run(['bash', str(ROOT / 'scripts/run_private_oracle.sh')],
                                    env=env, capture_output=True, text=True, timeout=30)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('Private oracle state and logs retained', result.stdout)
            records = [json.loads(x) for x in calls.read_text().splitlines()]
            self.assertTrue(records)
            self.assertTrue(all(x['args'][0] == 'info' for x in records))
            self.assertTrue(all(x['host'].startswith('unix://' + str(tmp) + '/manytype-oracle.')
                                and x['context'] is None for x in records))
            self.assertFalse(Path('/proc/' + pid.read_text().strip()).exists())


if __name__ == '__main__':
    unittest.main()
