import json
import base64
import subprocess
import os

import sys

with open(sys.argv[1]) as f:
    data = json.load(f)

for ev in data.get("events", []):
    if ev.get("method") == "/spacesync.SpaceSync/ObjectSyncStream":
        print(f"Role: {ev.get('role')}")
        print("Request messages:")
        for i, msg in enumerate(ev.get("request_messages", [])):
            decoded = base64.b64decode(msg["base64"])
            with open(f"/tmp/msg_{i}.bin", "wb") as mf:
                mf.write(decoded)
            print(f"--- Msg {i} ---")
            os.system(f"protoc --decode=treechange.TreeSyncMessage -Iproto/any_sync proto/any_sync/treechange.proto < /tmp/msg_{i}.bin")
