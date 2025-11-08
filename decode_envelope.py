import json
import base64
import os
import sys

with open("test_vectors/phase27-object-truth.json") as f:
    data = json.load(f)

for ev in data.get("events", []):
    if ev.get("method") == "/spacesync.SpaceSync/ObjectSyncStream" and ev.get("role") == "sync-node":
        for i, msg in enumerate(ev.get("request_messages", [])):
            decoded = base64.b64decode(msg["base64"])
            with open(f"/tmp/msg_env_{i}.bin", "wb") as mf:
                mf.write(decoded)
            print(f"--- Envelope {i} ---")
            os.system(f"protoc --decode=spacesync.ObjectSyncMessage -Iproto/any_sync proto/any_sync/spacesync.proto < /tmp/msg_env_{i}.bin")
